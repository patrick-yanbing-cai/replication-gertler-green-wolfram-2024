"""Generate loan-level IRR tercile and CDF figures."""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

import matplotlib

os.environ.setdefault("SOURCE_DATE_EPOCH", "1704067200")
matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import numpy_financial as npf
import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[3]
INTERIM_DIR = REPO_ROOT / "data" / "raw" / "interim"
FIGURE_DIR = REPO_ROOT / "output" / "results" / "figures"

BOOTSTRAP_ITERATIONS = 500
BOOTSTRAP_SEED = 20240620
N_QUANTILES = 3
EPS_METADATA = {
    "Creator": "code/replication/python_outputs/loan_irr_figures.py",
}
PNG_METADATA = {
    "Software": "matplotlib",
}


@dataclass(frozen=True)
class LoanGroupSpec:
    code: str
    label: str
    input_path: Path
    color: str
    marker: str


@dataclass(frozen=True)
class LoanGroupResult:
    spec: LoanGroupSpec
    loan_irrs: np.ndarray
    quantile_irrs: np.ndarray
    bootstrap_quantile_irrs: np.ndarray


GROUP_SPECS = [
    LoanGroupSpec(
        code="T1L",
        label="Secured",
        input_path=INTERIM_DIR / "loanlevelirrT1L.csv",
        color="red",
        marker="^",
    ),
    LoanGroupSpec(
        code="T2U",
        label="Unsecured",
        input_path=INTERIM_DIR / "loanlevelirrT2U.csv",
        color="green",
        marker="o",
    ),
    LoanGroupSpec(
        code="Old",
        label="Prior School-Fee\nLoans (Secured)",
        input_path=INTERIM_DIR / "loanlevelirrOld.csv",
        color="black",
        marker="D",
    ),
]


def load_loan_cashflows(input_path: Path) -> np.ndarray:
    if not input_path.exists():
        raise FileNotFoundError(
            f"Missing staged loan-level IRR input: {input_path}. "
            "Run python code/setup/prepare_raw_files.py before generating Python outputs."
        )

    data = pd.read_csv(input_path, usecols=["loandayselapsed", "cf"])
    if data["loandayselapsed"].min() != 0:
        raise ValueError(f"Expected {input_path} to start at loan day 0.")

    loan_days = int(data["loandayselapsed"].max()) + 1
    if len(data) % loan_days != 0:
        raise ValueError(
            f"{input_path} row count is not a complete loan-day panel."
        )

    loan_count = len(data) // loan_days
    return data["cf"].to_numpy(dtype=float).reshape((loan_count, loan_days))


def calculate_daily_irrs(cashflow_rows: np.ndarray) -> np.ndarray:
    cashflows = np.atleast_2d(np.asarray(cashflow_rows, dtype=float))
    days = np.arange(cashflows.shape[1], dtype=float)
    low = np.full(cashflows.shape[0], -0.5)
    high = np.full(cashflows.shape[0], 1.0)

    def npv(rates: np.ndarray, rows: np.ndarray = cashflows) -> np.ndarray:
        with np.errstate(over="ignore", invalid="ignore"):
            discounts = np.power(1 + rates[:, None], -days)
            return np.sum(rows * discounts, axis=1)

    low_npv = npv(low)
    high_npv = npv(high)
    bracketed = np.isfinite(low_npv) & np.isfinite(high_npv) & (low_npv >= 0) & (
        high_npv <= 0
    )
    result = np.full(cashflows.shape[0], np.nan)

    bracket_low = low[bracketed]
    bracket_high = high[bracketed]
    bracket_rows = cashflows[bracketed]

    if bracket_rows.size:
        for _ in range(80):
            midpoint = (bracket_low + bracket_high) / 2
            midpoint_npv = npv(midpoint, bracket_rows)
            low_side = midpoint_npv > 0
            bracket_low[low_side] = midpoint[low_side]
            bracket_high[~low_side] = midpoint[~low_side]

        result[bracketed] = (bracket_low + bracket_high) / 2

    for row_index in np.flatnonzero(~bracketed):
        fallback = npf.irr(cashflows[row_index])
        if np.isfinite(fallback):
            result[row_index] = fallback

    return result


def monthly_irr_percent(daily_irrs: np.ndarray) -> np.ndarray:
    with np.errstate(over="ignore", invalid="ignore"):
        monthly_irrs = (np.power(1 + daily_irrs, 30) * 100) - 100
    monthly_irrs[np.isposinf(monthly_irrs)] = -np.inf
    return monthly_irrs


def sorted_loan_cashflows(loan_cashflows: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    loan_irrs = calculate_daily_irrs(loan_cashflows)
    loan_irrs = np.where(np.isnan(loan_irrs), -np.inf, loan_irrs)
    order = np.lexsort((np.arange(len(loan_irrs)), loan_irrs))
    return loan_cashflows[order], loan_irrs[order]


def quantile_portfolios(sorted_cashflows: np.ndarray) -> np.ndarray:
    chunk_size = int(np.ceil(sorted_cashflows.shape[0] / N_QUANTILES))
    portfolios = []
    for quantile in range(N_QUANTILES):
        start = chunk_size * quantile
        stop = min(chunk_size * (quantile + 1), sorted_cashflows.shape[0])
        portfolios.append(sorted_cashflows[start:stop].sum(axis=0))
    return np.vstack(portfolios)


def bootstrap_quantile_irrs(
    loan_cashflows: np.ndarray,
    loan_irrs: np.ndarray,
    rng: np.random.Generator,
    iterations: int,
) -> np.ndarray:
    loan_count, day_count = loan_cashflows.shape
    boot_portfolios = np.empty((iterations, N_QUANTILES, day_count))

    for iteration in range(iterations):
        sample = rng.integers(0, loan_count, loan_count)
        order = np.lexsort((np.arange(loan_count), loan_irrs[sample]))
        ordered_sample = sample[order]
        boot_portfolios[iteration] = quantile_portfolios(
            loan_cashflows[ordered_sample]
        )

    return calculate_daily_irrs(
        boot_portfolios.reshape(iterations * N_QUANTILES, day_count)
    ).reshape(iterations, N_QUANTILES)


def build_group_result(
    spec: LoanGroupSpec,
    rng: np.random.Generator,
    iterations: int,
) -> LoanGroupResult:
    loan_cashflows = load_loan_cashflows(spec.input_path)
    sorted_cashflows, loan_irrs = sorted_loan_cashflows(loan_cashflows)
    quantile_irrs = calculate_daily_irrs(quantile_portfolios(sorted_cashflows))
    bootstrap_irrs = bootstrap_quantile_irrs(
        sorted_cashflows,
        loan_irrs,
        rng=rng,
        iterations=iterations,
    )
    return LoanGroupResult(
        spec=spec,
        loan_irrs=loan_irrs,
        quantile_irrs=quantile_irrs,
        bootstrap_quantile_irrs=bootstrap_irrs,
    )


def save_tercile_figure(results: list[LoanGroupResult]) -> list[Path]:
    png_path = FIGURE_DIR / "IRRs_terciles.png"
    eps_path = FIGURE_DIR / "IRRs_terciles.eps"
    x_values = np.arange(1, N_QUANTILES + 1)

    fig, ax = plt.subplots(figsize=(6, 3.5))
    for result in results:
        y_values = monthly_irr_percent(result.quantile_irrs)
        ax.plot(
            x_values,
            y_values,
            linewidth=1,
            marker=result.spec.marker,
            markersize=4,
            color=result.spec.color,
            markerfacecolor=result.spec.color,
            label=result.spec.label,
        )
        ax.errorbar(
            x_values,
            y_values,
            yerr=np.std(result.bootstrap_quantile_irrs, axis=0, ddof=1)
            * 1.96
            * 30
            * 100,
            linestyle="none",
            linewidth=1,
            color=result.spec.color,
        )

    label_offsets = {
        "T1L": [
            (0.02, 0, "left", "top"),
            (-0.04, 0, "right", "center"),
            (0.08, 2, "left", "bottom"),
        ],
        "T2U": [
            (0.02, 0, "left", "top"),
            (-0.04, 0, "left", "top"),
            (0.08, -4, "left", "top"),
        ],
        "Old": [
            (0.02, 0, "left", "top"),
            (0, 0, "right", "bottom"),
            (0, 3, "center", "bottom"),
        ],
    }
    for result in results:
        y_values = monthly_irr_percent(result.quantile_irrs)
        for index, y_value in enumerate(y_values):
            x_offset, y_offset, horizontal, vertical = label_offsets[result.spec.code][
                index
            ]
            ax.text(
                x_values[index] + x_offset,
                y_value + y_offset,
                f"{y_value:.0f}%",
                fontsize=12,
                horizontalalignment=horizontal,
                verticalalignment=vertical,
            )

    ax.set_xticks(x_values)
    ax.set_xticklabels([str(value) for value in x_values])
    ax.set_xlim(0.9, 3.5)
    ax.set_ylim(-60, 25)
    ax.set_ylabel("Monthly IRR of portfolio of loans (%)")
    ax.set_xlabel("Terciles by the IRR of individual loans")
    ax.legend(loc="lower right", frameon=False)
    fig.tight_layout()
    fig.savefig(png_path, dpi=100, metadata=PNG_METADATA)
    fig.savefig(eps_path, format="eps", metadata=EPS_METADATA)
    plt.close(fig)
    return [png_path, eps_path]


def cdf_series(loan_irrs: np.ndarray) -> np.ndarray:
    edges = np.arange(-34.5, 25.0, 1.0)
    monthly_irrs = monthly_irr_percent(loan_irrs)
    hist = np.empty(len(edges) + 1)
    hist[0] = np.sum((monthly_irrs <= edges[0]) | np.isneginf(monthly_irrs))
    for index in range(len(edges) - 1):
        hist[index + 1] = np.sum(
            (monthly_irrs > edges[index]) & (monthly_irrs <= edges[index + 1])
        )
    hist[-1] = np.sum((monthly_irrs > edges[-1]) & ~np.isneginf(monthly_irrs))
    return np.cumsum(hist / len(loan_irrs))


def save_cdf_figure(results: list[LoanGroupResult]) -> list[Path]:
    png_path = FIGURE_DIR / "IRRs_cdf.png"
    eps_path = FIGURE_DIR / "IRRs_cdf.eps"
    dot_positions = np.arange(-35, 26)
    label_positions = np.arange(-35, 26, 5)
    labels = [str(value) for value in label_positions]
    labels[0] = "<-30%"
    labels[-1] = ">20%"

    fig, ax = plt.subplots(figsize=(6, 3.5))
    for result in results:
        ax.plot(
            dot_positions,
            cdf_series(result.loan_irrs),
            linewidth=1,
            color=result.spec.color,
            label=result.spec.label,
        )

    ax.set_xticks(label_positions)
    ax.set_xticklabels(labels)
    ax.set_ylim(0, 1)
    ax.set_ylabel("Cumulative probability density")
    ax.set_xlabel("Monthly IRR of loans (%)")
    ax.legend(loc="lower right", frameon=False)
    fig.tight_layout()
    fig.savefig(png_path, dpi=100, metadata=PNG_METADATA)
    fig.savefig(eps_path, format="eps", metadata=EPS_METADATA)
    plt.close(fig)
    return [png_path, eps_path]


def generate_loan_irr_figures(
    iterations: int = BOOTSTRAP_ITERATIONS,
    seed: int = BOOTSTRAP_SEED,
) -> list[Path]:
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    rng = np.random.default_rng(seed)
    results = [
        build_group_result(spec, rng=rng, iterations=iterations)
        for spec in GROUP_SPECS
    ]
    return save_tercile_figure(results) + save_cdf_figure(results)


def main() -> None:
    for output in generate_loan_irr_figures():
        print(f"Wrote maintained Python figure output: {output}")


if __name__ == "__main__":
    main()
