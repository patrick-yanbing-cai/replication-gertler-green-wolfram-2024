"""Run maintained Python final-output modules."""

from __future__ import annotations

from python_outputs.repayment_rate_figures import generate_figures


def main() -> None:
    outputs = generate_figures()
    for output in outputs:
        print(f"Wrote maintained Python figure output: {output}")


if __name__ == "__main__":
    main()
