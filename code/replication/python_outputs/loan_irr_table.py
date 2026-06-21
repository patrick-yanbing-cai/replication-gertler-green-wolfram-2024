"""Generate the monthly IRR table for loan portfolios."""

from __future__ import annotations

import random
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import numpy_financial as npf
import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[3]
INPUT_PATH = REPO_ROOT / "data" / "raw" / "interim" / "tab_cf_loan_level.csv"
TABLE_DIR = REPO_ROOT / "output" / "results" / "tables"
OUTPUT_PATH = TABLE_DIR / "r_treatment_irr_withCI.tex"

BOOTSTRAP_ITERATIONS = 1000
BOOTSTRAP_SEED = 20240620
TREATMENTS = ["T1_L", "T2_U", "Old"]
RISK_GROUPS = ["0_1_3", "1_3_2_3", "2_3_1"]
TREATMENT_IRR_COLUMNS = ["irr_T1_L", "irr_T2_U", "irr_Old"]
TREATMENT_RISK_IRR_COLUMNS = [
    "irr_T1_L_0_1_3",
    "irr_T1_L_1_3_2_3",
    "irr_T1_L_2_3_1",
    "irr_T2_U_0_1_3",
    "irr_T2_U_1_3_2_3",
    "irr_T2_U_2_3_1",
    "irr_Old_0_1_3",
    "irr_Old_1_3_2_3",
    "irr_Old_2_3_1",
]


@dataclass(frozen=True)
class TreatmentCashflows:
    cashflows: np.ndarray
    risk_groups: np.ndarray


def load_cashflows(input_path: Path = INPUT_PATH) -> pd.DataFrame:
    if not input_path.exists():
        raise FileNotFoundError(
            f"Missing staged loan cash-flow input: {input_path}. "
            "Run python code/setup/prepare_raw_files.py before generating Python outputs."
        )

    return pd.read_csv(
        input_path,
        usecols=[
            "loanid",
            "accountpercentlocked_group",
            "loandayselapsed",
            "treatmenttype_encode",
            "cf",
        ],
    )


def calculate_monthly_irr(cashflows: np.ndarray) -> float:
    return float(npf.irr(cashflows) * 30)


def calculate_monthly_irrs(cashflows: np.ndarray) -> np.ndarray:
    cashflow_matrix = np.atleast_2d(np.asarray(cashflows, dtype=float))
    days = np.arange(cashflow_matrix.shape[1], dtype=float)
    low = np.full(cashflow_matrix.shape[0], -0.02)
    high = np.full(cashflow_matrix.shape[0], 0.02)

    def npv(rates: np.ndarray) -> np.ndarray:
        discounts = np.power(1 + rates[:, None], -days)
        return np.sum(cashflow_matrix * discounts, axis=1)

    low_npv = npv(low)
    high_npv = npv(high)
    bracketed = (low_npv >= 0) & (high_npv <= 0)
    result = np.empty(cashflow_matrix.shape[0])

    bracket_low = low[bracketed]
    bracket_high = high[bracketed]
    bracket_matrix = cashflow_matrix[bracketed]

    if bracket_matrix.size:
        bracket_days = np.arange(bracket_matrix.shape[1], dtype=float)

        def bracket_npv(rates: np.ndarray) -> np.ndarray:
            discounts = np.power(1 + rates[:, None], -bracket_days)
            return np.sum(bracket_matrix * discounts, axis=1)

        for _ in range(60):
            midpoint = (bracket_low + bracket_high) / 2
            midpoint_npv = bracket_npv(midpoint)
            low_side = midpoint_npv > 0
            bracket_low[low_side] = midpoint[low_side]
            bracket_high[~low_side] = midpoint[~low_side]

        result[bracketed] = ((bracket_low + bracket_high) / 2) * 30

    if (~bracketed).any():
        result[~bracketed] = [
            calculate_monthly_irr(row) for row in cashflow_matrix[~bracketed]
        ]

    return result


def aggregate_treatment_irrs(cashflows: pd.DataFrame) -> pd.Series:
    aggregate = (
        cashflows.groupby(["treatmenttype_encode", "loandayselapsed"], sort=True)["cf"]
        .sum()
        .reset_index()
        .sort_values(["treatmenttype_encode", "loandayselapsed"])
    )
    return pd.Series(
        {
            treatment: calculate_monthly_irr(
                aggregate.loc[
                    aggregate["treatmenttype_encode"] == treatment, "cf"
                ].to_numpy()
            )
            for treatment in TREATMENTS
        }
    )


def aggregate_treatment_risk_irrs(cashflows: pd.DataFrame) -> pd.Series:
    aggregate = (
        cashflows.groupby(
            ["treatmenttype_encode", "accountpercentlocked_group", "loandayselapsed"],
            sort=True,
        )["cf"]
        .sum()
        .reset_index()
        .sort_values(
            ["treatmenttype_encode", "accountpercentlocked_group", "loandayselapsed"]
        )
    )
    return pd.Series(
        {
            f"{treatment}_{risk_group}": calculate_monthly_irr(
                aggregate.loc[
                    (aggregate["treatmenttype_encode"] == treatment)
                    & (aggregate["accountpercentlocked_group"] == risk_group),
                    "cf",
                ].to_numpy()
            )
            for treatment in TREATMENTS
            for risk_group in RISK_GROUPS
        }
    )


def prepare_treatment_cashflows(
    cashflows: pd.DataFrame, treatment: str
) -> TreatmentCashflows:
    treatment_cashflows = cashflows.loc[
        cashflows["treatmenttype_encode"] == treatment
    ].copy()
    risk_counts = treatment_cashflows.groupby("loanid")[
        "accountpercentlocked_group"
    ].nunique()
    if (risk_counts != 1).any():
        raise ValueError(f"Each loan must have one risk group for {treatment}.")

    matrix = treatment_cashflows.pivot_table(
        index="loanid",
        columns="loandayselapsed",
        values="cf",
        aggfunc="sum",
        fill_value=0,
        sort=True,
    )
    all_days = range(
        int(cashflows["loandayselapsed"].min()),
        int(cashflows["loandayselapsed"].max()) + 1,
    )
    matrix = matrix.reindex(columns=all_days, fill_value=0)
    risk_groups = (
        treatment_cashflows.groupby("loanid")["accountpercentlocked_group"]
        .first()
        .reindex(matrix.index)
        .to_numpy()
    )
    return TreatmentCashflows(
        cashflows=matrix.to_numpy(dtype=float),
        risk_groups=risk_groups,
    )


def build_bootstrap_frames(
    cashflows: pd.DataFrame,
    iterations: int = BOOTSTRAP_ITERATIONS,
    seed: int = BOOTSTRAP_SEED,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    prepared = {
        treatment: prepare_treatment_cashflows(cashflows, treatment)
        for treatment in TREATMENTS
    }
    rng = random.Random(seed)
    sample_counts_by_treatment: dict[str, np.ndarray] = {}

    for treatment in TREATMENTS:
        loan_count = prepared[treatment].cashflows.shape[0]
        sample_counts_by_treatment[treatment] = np.zeros(
            (iterations, loan_count), dtype=np.int16
        )

    for iteration in range(iterations):
        for treatment in TREATMENTS:
            loan_count = prepared[treatment].cashflows.shape[0]
            sample = rng.choices(range(loan_count), k=loan_count)
            sample_counts_by_treatment[treatment][iteration] = np.bincount(
                sample, minlength=loan_count
            )

    treatment_results: dict[str, np.ndarray] = {}
    treatment_risk_results: dict[str, np.ndarray] = {}

    for treatment in TREATMENTS:
        treatment_cashflows = prepared[treatment]
        sample_counts = sample_counts_by_treatment[treatment]
        treatment_results[f"irr_{treatment}"] = calculate_monthly_irrs(
            sample_counts @ treatment_cashflows.cashflows
        )

        for risk_group in RISK_GROUPS:
            risk_mask = treatment_cashflows.risk_groups == risk_group
            treatment_risk_results[f"irr_{treatment}_{risk_group}"] = (
                calculate_monthly_irrs(
                    sample_counts[:, risk_mask]
                    @ treatment_cashflows.cashflows[risk_mask]
                )
            )

    return (
        pd.DataFrame(treatment_results, columns=TREATMENT_IRR_COLUMNS),
        pd.DataFrame(treatment_risk_results, columns=TREATMENT_RISK_IRR_COLUMNS),
    )


def standard_error(frame: pd.DataFrame, column: str) -> str:
    return format(np.std(frame[column].to_numpy()) * 100, ".1f")


def render_table(
    bootstrap_by_treatment: pd.DataFrame,
    bootstrap_by_treatment_risk: pd.DataFrame,
) -> str:
    p_value = format(
        np.mean(
            bootstrap_by_treatment["irr_T1_L"]
            < bootstrap_by_treatment["irr_T2_U"]
        ),
        ".3f",
    )
    return (
        "\\begin{table}[htbp]\\centering\n"
        "\\small\n"
        "\\def\\sym#1{\\ifmmode^{#1}\\else\\(^{#1}\\)\\fi}\n"
        "\\caption{Monthly IRRs of Loan Portfolios \\label{tab:r_treatment_irr}}\n"
        "\\begin{tabular}{l*{5}{c}}\n"
        "\\toprule\n"
        "Treatment Group  & \\multicolumn{3}{c}{\\begin{tabular}{@{}c@{}}"
        "\\underline{Account percent locked} \\\\ \\end{tabular}} & "
        "\\begin{tabular}{@{}c@{}}All \\\\ \\end{tabular} & $n$ \\\\\n"
        "& 1st tercile & 2nd tercile & 3rd tercile & & \\\\\\addlinespace\n"
        "& (1) & (2) & (3) & (4) \\\\\n"
        "\\midrule\n"
        "Secured & 0.2\\% & -2.5\\% & -8.4\\% & -3.7\\%  & 217 \\\\\n"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T1_L_0_1_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T1_L_1_3_2_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T1_L_2_3_1')})"
        f"&({standard_error(bootstrap_by_treatment, 'irr_T1_L')})\\\\ \n"
        "& [0.00, 0.06] & [0.06, 0.19] & [0.19, 0.57] & [0.00, 0.57]  & \\\\ \\addlinespace \n"
        "Unsecured & -3.7  & -6.3 & -10.2 & -6.9 & 438 \\\\\n"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T2_U_0_1_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T2_U_1_3_2_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_T2_U_2_3_1')})"
        f"&({standard_error(bootstrap_by_treatment, 'irr_T2_U')})\\\\ \n"
        "& [0.00, 0.05] & [0.05, 0.19] & [0.19, 0.64] & [0.00, 0.64]  & \\\\ \\addlinespace \n"
        f"p-value & & & &{p_value}& \\\\ \\addlinespace \n"
        "\\midrule\n"
        "Prior School-Fee & 6.6  & 6.0 & 3.2 & 5.1  & 1377 \\\\\n"
        f"Loans (Secured) &({standard_error(bootstrap_by_treatment_risk, 'irr_Old_0_1_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_Old_1_3_2_3')})"
        f"&({standard_error(bootstrap_by_treatment_risk, 'irr_Old_2_3_1')})"
        f"&({standard_error(bootstrap_by_treatment, 'irr_Old')})\\\\ \n"
        "& [0.00, 0.04] & [0.04, 0.13] & [0.13, 0.30] & [0.00, 0.30]  & \\\\ \n"
        "\\addlinespace\\bottomrule\n"
        "\\end{tabular}\n"
        "\\end{table}\n"
    )


def generate_table(
    output_path: Path = OUTPUT_PATH,
    iterations: int = BOOTSTRAP_ITERATIONS,
    seed: int = BOOTSTRAP_SEED,
) -> Path:
    TABLE_DIR.mkdir(parents=True, exist_ok=True)
    cashflows = load_cashflows()
    bootstrap_by_treatment, bootstrap_by_treatment_risk = build_bootstrap_frames(
        cashflows, iterations=iterations, seed=seed
    )
    output_path.write_text(
        render_table(bootstrap_by_treatment, bootstrap_by_treatment_risk),
        encoding="utf-8",
    )
    return output_path


def main() -> None:
    print(f"Wrote maintained Python table output: {generate_table()}")


if __name__ == "__main__":
    main()
