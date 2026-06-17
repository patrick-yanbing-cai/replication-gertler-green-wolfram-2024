"""Stage the original Dataverse package into a clean raw-data layout.

This script does not modify the downloaded Dataverse package. It clears and
rebuilds data/raw/ from dataverse_files/Gertler. Green. and Wolfram/.
"""

from __future__ import annotations

import shutil
from datetime import datetime
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
ORIGINAL_PACKAGE = REPO_ROOT / "dataverse_files" / "Gertler. Green. and Wolfram"
RAW_ROOT = REPO_ROOT / "data" / "raw"


DATA_DIRS = {
    "baseline survey": "baseline_survey",
    "endline survey": "endline_survey",
    "interim": "interim",
    "lsms": "lsms",
    "merged": "merged",
    "repayment": "repayment",
}


def ensure_original_package() -> None:
    if not ORIGINAL_PACKAGE.exists():
        raise SystemExit(
            "Original Dataverse package not found.\n"
            f"Expected: {ORIGINAL_PACKAGE}\n"
            "Download and extract the package under dataverse_files/ before running this script."
        )


def clear_raw_root() -> None:
    expected = REPO_ROOT / "data" / "raw"
    raw_resolved = RAW_ROOT.resolve()
    expected_resolved = expected.resolve()

    if raw_resolved != expected_resolved:
        raise SystemExit(f"Refusing to clear unexpected path: {RAW_ROOT}")

    if RAW_ROOT.exists():
        shutil.rmtree(RAW_ROOT)
    RAW_ROOT.mkdir(parents=True, exist_ok=True)


def copy_tree(src: Path, dst: Path) -> None:
    if not src.exists():
        raise SystemExit(f"Required source path not found: {src}")
    shutil.copytree(src, dst)


def copy_file(src: Path, dst: Path) -> None:
    if not src.exists():
        raise SystemExit(f"Required source file not found: {src}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def stage_data_dirs() -> None:
    data_root = ORIGINAL_PACKAGE / "data"
    for original_name, clean_name in DATA_DIRS.items():
        copy_tree(data_root / original_name, RAW_ROOT / clean_name)


def stage_reference_outputs() -> None:
    ref_root = RAW_ROOT / "reference_outputs"
    copy_tree(ORIGINAL_PACKAGE / "tables", ref_root / "tables")
    copy_tree(ORIGINAL_PACKAGE / "figures", ref_root / "figures")


def stage_documentation_inputs() -> None:
    questionnaires = ORIGINAL_PACKAGE / "survey questionnaires"
    if questionnaires.exists():
        copy_tree(questionnaires, RAW_ROOT / "questionnaires")

    copy_file(
        ORIGINAL_PACKAGE / "data_information_availability.xlsx",
        RAW_ROOT / "metadata" / "data_information_availability.xlsx",
    )
    copy_file(
        ORIGINAL_PACKAGE / "project_file_description.docx",
        RAW_ROOT / "metadata" / "project_file_description.docx",
    )


def write_marker() -> None:
    marker = RAW_ROOT / ".prepared_from_dataverse.txt"
    marker.write_text(
        "\n".join(
            [
                "Prepared raw inputs for Gertler, Green, and Wolfram (2024).",
                f"Source: {ORIGINAL_PACKAGE}",
                f"Prepared at: {datetime.now().isoformat(timespec='seconds')}",
                "",
            ]
        ),
        encoding="utf-8",
    )


def main() -> None:
    ensure_original_package()
    clear_raw_root()
    stage_data_dirs()
    stage_reference_outputs()
    stage_documentation_inputs()
    write_marker()
    print(f"Prepared raw inputs at: {RAW_ROOT}")


if __name__ == "__main__":
    main()
