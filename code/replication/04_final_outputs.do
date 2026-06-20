*** Purpose: Step 4, build maintained Stata final outputs.

version 16
set more off

if "$repo_root" == "" {
    display as error "repo_root global is not defined. Run code/replication/run_replication.do from the repository root."
    exit 198
}

if "$tables" == "" {
    display as error "tables global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

if "$esvy_clean" == "" {
    display as error "esvy_clean global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

if "$esvy_processed" == "" {
    display as error "esvy_processed global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

if "$bsvy_processed" == "" {
    display as error "bsvy_processed global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

if "$merged" == "" {
    display as error "merged global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

display as text "Final table output root: $tables"
display as text "Endline staged clean source root: $esvy_clean"
display as text "Baseline maintained support root: $bsvy_processed"
display as text "Endline maintained support root: $esvy_processed"
display as text "Merged staged source root: $merged"
display as text "Intentional difference from staged reference files: maintained final tables are written under output/results/tables, not data/raw/reference_outputs/tables."

assert_maintained_generated_path "$tables" "tables"
assert_maintained_generated_path "$bsvy_processed" "bsvy_processed"
assert_maintained_generated_path "$esvy_processed" "esvy_processed"
assert_stata_intermediate_path "$bsvy_processed" "bsvy_processed"
assert_stata_intermediate_path "$esvy_processed" "esvy_processed"

display as text "Checking staged final-output inputs:"
foreach required_input in ///
    `"$merged/key_rep.dta"' ///
    `"$esvy_clean/2_educ_indiv.dta"' ///
    `"$esvy_clean/2_educ_hh.dta"' ///
    `"$esvy_clean/3A_assets_hh.dta"' ///
    `"$esvy_clean/6_bsl.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required staged final-output input: `required_input'"
        display as error "Run python code/setup/prepare_raw_files.py before running maintained Stata modules."
        exit 601
    }
    display as text "staged final-output input: `required_input'"
}

display as text "Checking maintained final-output support inputs:"
foreach required_input in ///
    `"$bsvy_processed/hhvars_baseline.dta"' ///
    `"$esvy_processed/femaleeduc.dta"' ///
    `"$esvy_processed/maleeduc.dta"' ///
    `"$esvy_processed/7_wellbeing_hh.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required maintained final-output support input: `required_input'"
        display as error "Run code/replication/02_baseline_support.do and code/replication/03_endline_support.do before final-output modules."
        exit 601
    }
    display as text "maintained final-output support input: `required_input'"
}

display as text "Step 4.1: endline household education table (g4_endline_educ_hh.do)"
display as text "BEGIN original source boundary: g4_endline_educ_hh.do"
do "$repo_root/code/replication/final_outputs/g4_endline_educ_hh.do"
display as text "END original source boundary: g4_endline_educ_hh.do"

capture confirm file "$tables/endline_educ_hh.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/endline_educ_hh.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/endline_educ_hh.tex"

display as text "Step 4.2: endline household education table with households without school-aged children (g4_endline_educ_hh_full.do)"
display as text "BEGIN original source boundary: g4_endline_educ_hh_full.do"
do "$repo_root/code/replication/final_outputs/g4_endline_educ_hh_full.do"
display as text "END original source boundary: g4_endline_educ_hh_full.do"

capture confirm file "$tables/endline_educ_hh_full.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/endline_educ_hh_full.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/endline_educ_hh_full.tex"

display as text "Step 4.3: endline individual education table (g4_endline_educ_indiv.do)"
display as text "BEGIN original source boundary: g4_endline_educ_indiv.do"
do "$repo_root/code/replication/final_outputs/g4_endline_educ_indiv.do"
display as text "END original source boundary: g4_endline_educ_indiv.do"

capture confirm file "$tables/endline_educ_indiv.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/endline_educ_indiv.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/endline_educ_indiv.tex"

display as text "Step 4.4: endline assets and shocks tables (g5_endline_analysis.do)"
display as text "BEGIN original source boundary: g5_endline_analysis.do"
do "$repo_root/code/replication/final_outputs/g5_endline_analysis.do"
display as text "END original source boundary: g5_endline_analysis.do"

foreach expected_output in ///
    "assets99_lvl_ITT_v2.tex" ///
    "assetsbal99_lvl_ITT_v2.tex" ///
    "shock_A.tex" ///
    "shock_B.tex" {
    capture confirm file "$tables/`expected_output'"
    if _rc {
        display as error "Missing expected maintained final table output: $tables/`expected_output'"
        exit 601
    }
    display as result "Wrote maintained final table output: $tables/`expected_output'"
}

display as text "Step 4.5: SAC regression table (g10_sac_regression.do)"
display as text "BEGIN original source boundary: g10_sac_regression.do"
do "$repo_root/code/replication/final_outputs/g10_sac_regression.do"
display as text "END original source boundary: g10_sac_regression.do"

capture confirm file "$tables/sacreg.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/sacreg.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/sacreg.tex"

display as text "Step 4.6: endline money borrowed table (g13_endline_moneyborrowed.do)"
display as text "BEGIN original source boundary: g13_endline_moneyborrowed.do"
do "$repo_root/code/replication/final_outputs/g13_endline_moneyborrowed.do"
display as text "END original source boundary: g13_endline_moneyborrowed.do"

capture confirm file "$tables/endline_moneyborrowed.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/endline_moneyborrowed.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/endline_moneyborrowed.tex"

display as result "Stata final-output construction completed."
