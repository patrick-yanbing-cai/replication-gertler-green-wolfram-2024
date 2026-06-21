"""Run maintained Python final-output modules."""

from __future__ import annotations

from python_outputs.loan_irr_table import generate_table
from python_outputs.repayment_rate_figures import generate_figures


def main() -> None:
    figure_outputs = generate_figures()
    for output in figure_outputs:
        print(f"Wrote maintained Python figure output: {output}")
    print(f"Wrote maintained Python table output: {generate_table()}")


if __name__ == "__main__":
    main()
