"""Generate Figure 4 repayment and completion rate panels."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[3]
INPUT_PATH = REPO_ROOT / "data" / "raw" / "repayment" / "fenix_repay_extend_07172020_strict_rep.dta"
FIGURE_DIR = REPO_ROOT / "output" / "results" / "figures"

TREATMENT_LABELS = {
    "R T1-L": "Secured",
    "R T1-U": "Surprise Unsecured",
    "R T2-U": "Unsecured",
    "R T3": "Choice",
    "R C": "Control",
}
TREATMENT_ORDER = ["Secured", "Surprise Unsecured", "Unsecured"]
TREATMENT_COLORS = {
    "Secured": "red",
    "Surprise Unsecured": "orange",
    "Unsecured": "green",
}
EFFECT_ORDER = ["Total Effect", "Moral Hazard", "Selection"]
EFFECT_COLORS = {
    "Total Effect": "red",
    "Moral Hazard": "black",
    "Selection": "blue",
}
PDF_METADATA = {
    "Creator": "code/replication/python_outputs/repayment_rate_figures.py",
    "Producer": "matplotlib",
    "CreationDate": datetime(2024, 1, 1, tzinfo=timezone.utc),
    "ModDate": datetime(2024, 1, 1, tzinfo=timezone.utc),
}


@dataclass(frozen=True)
class RateFigureSpec:
    measure: str
    rate_filename: str
    diff_filename: str
    rate_ylabel: str
    diff_ylabel: str
    x_limits: tuple[int, int]
    x_ticks: list[int]
    rate_y_limits: tuple[float, float]
    rate_y_ticks: list[float]
    diff_y_limits: tuple[float, float]
    diff_y_ticks: list[float]


FIGURE_SPECS = [
    RateFigureSpec(
        measure="frac_lpp_maxip",
        rate_filename="repaymentratesgrey.pdf",
        diff_filename="diff_repayments.pdf",
        rate_ylabel="Fraction of principal repaid",
        diff_ylabel="Difference in fraction of principal repaid",
        x_limits=(50, 200),
        x_ticks=[50, 100, 150, 200],
        rate_y_limits=(0.24, 0.72),
        rate_y_ticks=[0.24, 0.36, 0.48, 0.60, 0.72],
        diff_y_limits=(0.01, 0.13),
        diff_y_ticks=[0.01, 0.03, 0.05, 0.07, 0.09, 0.11, 0.13],
    ),
    RateFigureSpec(
        measure="completeloan",
        rate_filename="loancompleteratesgrey.pdf",
        diff_filename="diff_complete.pdf",
        rate_ylabel="Fraction completed",
        diff_ylabel="Difference in fraction completed",
        x_limits=(100, 200),
        x_ticks=[100, 150, 200],
        rate_y_limits=(0.21, 0.65),
        rate_y_ticks=[0.21, 0.32, 0.43, 0.54, 0.65],
        diff_y_limits=(-0.03, 0.17),
        diff_y_ticks=[-0.03, 0.01, 0.05, 0.09, 0.13, 0.17],
    ),
]


def load_repayment_data(input_path: Path = INPUT_PATH) -> pd.DataFrame:
    if not input_path.exists():
        raise FileNotFoundError(
            f"Missing staged repayment input: {input_path}. "
            "Run python code/setup/prepare_raw_files.py before generating Python outputs."
        )

    data = pd.read_stata(input_path)
    data = data.loc[data["loandayselapsed"] <= 200].copy()
    data["treatmenttype"] = data["treatmenttype_sh"].replace(TREATMENT_LABELS)
    data = data.loc[data["treatmenttype"].isin(TREATMENT_ORDER)].copy()
    data["treatmenttype"] = pd.Categorical(
        data["treatmenttype"], categories=TREATMENT_ORDER, ordered=True
    )
    data["completeloan"] = data["completeloan"].astype(str).map({"No": 0, "Yes": 1})
    return data


def summarize_rates(data: pd.DataFrame, measure: str) -> pd.DataFrame:
    return (
        data.groupby(["loandayselapsed", "treatmenttype"], observed=True)[measure]
        .mean()
        .reset_index()
        .sort_values(["treatmenttype", "loandayselapsed"])
    )


def summarize_differences(rate_summary: pd.DataFrame, measure: str) -> pd.DataFrame:
    rates = rate_summary.pivot(
        index="loandayselapsed", columns="treatmenttype", values=measure
    )
    pieces = [
        ("Total Effect", rates["Secured"] - rates["Unsecured"]),
        ("Moral Hazard", rates["Secured"] - rates["Surprise Unsecured"]),
        ("Selection", rates["Surprise Unsecured"] - rates["Unsecured"]),
    ]
    return pd.concat(
        [
            values.rename("diff")
            .reset_index()
            .assign(type=label)
            .loc[:, ["loandayselapsed", "diff", "type"]]
            for label, values in pieces
        ],
        ignore_index=True,
    )


def style_axis(ax: plt.Axes, x_limits: tuple[int, int], x_ticks: list[int]) -> None:
    ax.set_xlim(*x_limits)
    ax.set_xticks(x_ticks)
    ax.set_xlabel("Days elapsed since loan creation")
    ax.set_facecolor("none")
    for spine in ax.spines.values():
        spine.set_edgecolor("0.75")
    ax.tick_params(axis="both", color="0.85", labelsize=10)


def save_rate_figure(rate_summary: pd.DataFrame, spec: RateFigureSpec) -> Path:
    path = FIGURE_DIR / spec.rate_filename
    fig, ax = plt.subplots(figsize=(4, 3))
    for treatment in TREATMENT_ORDER:
        series = rate_summary.loc[rate_summary["treatmenttype"] == treatment]
        ax.plot(
            series["loandayselapsed"],
            series[spec.measure],
            color=TREATMENT_COLORS[treatment],
            linewidth=0.5,
            label=treatment,
        )
    style_axis(ax, spec.x_limits, spec.x_ticks)
    ax.set_ylim(*spec.rate_y_limits)
    ax.set_yticks(spec.rate_y_ticks)
    ax.set_ylabel(spec.rate_ylabel)
    ax.legend(loc="lower right", frameon=False, fontsize=6, handlelength=2)
    fig.subplots_adjust(left=0.19, right=0.96, bottom=0.22, top=0.93)
    fig.savefig(path, metadata=PDF_METADATA)
    plt.close(fig)
    return path


def save_diff_figure(diff_summary: pd.DataFrame, spec: RateFigureSpec) -> Path:
    path = FIGURE_DIR / spec.diff_filename
    fig, ax = plt.subplots(figsize=(4, 3))
    for effect in EFFECT_ORDER:
        series = diff_summary.loc[diff_summary["type"] == effect]
        ax.plot(
            series["loandayselapsed"],
            series["diff"],
            color=EFFECT_COLORS[effect],
            linewidth=0.5,
            label=effect,
        )
    style_axis(ax, spec.x_limits, spec.x_ticks)
    ax.set_ylim(*spec.diff_y_limits)
    ax.set_yticks(spec.diff_y_ticks)
    ax.set_ylabel(spec.diff_ylabel)
    ax.legend(loc="lower right", frameon=False, fontsize=6, handlelength=2)
    fig.subplots_adjust(left=0.19, right=0.96, bottom=0.22, top=0.93)
    fig.savefig(path, metadata=PDF_METADATA)
    plt.close(fig)
    return path


def generate_figures() -> list[Path]:
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    data = load_repayment_data()
    outputs: list[Path] = []
    for spec in FIGURE_SPECS:
        rates = summarize_rates(data, spec.measure)
        diffs = summarize_differences(rates, spec.measure)
        outputs.append(save_rate_figure(rates, spec))
        outputs.append(save_diff_figure(diffs, spec))
    return outputs


def main() -> None:
    for output in generate_figures():
        print(f"Wrote maintained Python figure output: {output}")


if __name__ == "__main__":
    main()
