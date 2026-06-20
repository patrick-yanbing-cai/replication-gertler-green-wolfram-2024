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

if "$repay_clean" == "" {
    display as error "repay_clean global is not defined. Run code/replication/00_header.do before final outputs."
    exit 198
}

display as text "Final table output root: $tables"
display as text "Endline staged clean source root: $esvy_clean"
display as text "Baseline maintained support root: $bsvy_processed"
display as text "Endline maintained support root: $esvy_processed"
display as text "Merged staged source root: $merged"
display as text "Repayment staged source root: $repay_clean"
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
    `"$esvy_clean/6_bsl.dta"' ///
    `"$esvy_clean/adult_labor_supply_hh.dta"' ///
    `"$repay_clean/fenix_repay_extend_07172020_rep.dta"' {
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
    `"$esvy_processed/7_wellbeing_hh.dta"' ///
    `"$esvy_processed/9_lockedoccurences_hh.dta"' {
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

display as text "Step 4.7: endline adult income table (g14_endline_income.do)"
display as text "BEGIN original source boundary: g14_endline_income.do"
do "$repo_root/code/replication/final_outputs/g14_endline_income.do"
display as text "END original source boundary: g14_endline_income.do"

capture confirm file "$tables/income99_lvl_ITT.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/income99_lvl_ITT.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/income99_lvl_ITT.tex"

display as text "Step 4.8: day-200 compliance table (g15_compliance_day200.do)"
display as text "BEGIN original source boundary: g15_compliance_day200.do"
do "$repo_root/code/replication/final_outputs/g15_compliance_day200.do"
display as text "END original source boundary: g15_compliance_day200.do"

capture confirm file "$tables/compliance_tab.tex"
if _rc {
    display as error "Missing expected maintained final table output: $tables/compliance_tab.tex"
    exit 601
}
display as result "Wrote maintained final table output: $tables/compliance_tab.tex"

display as text "Step 4.9: main repayment and completion ITT/LATE tables (h1_iv_ols_main.do)"
display as text "BEGIN original source boundary: h1_iv_ols_main.do"
do "$repo_root/code/replication/final_outputs/h1_iv_ols_main.do"
display as text "END original source boundary: h1_iv_ols_main.do"

foreach expected_output in ///
    "LASMH_repay_LATE_100.tex" ///
    "LASMH_repay_LATE_150.tex" ///
    "LASMH_repay_LATE_200.tex" ///
    "LASMH_repay_ITT_100.tex" ///
    "LASMH_repay_ITT_150.tex" ///
    "LASMH_repay_ITT_200.tex" ///
    "LASMH_complete_LATE_110.tex" ///
    "LASMH_complete_LATE_150.tex" ///
    "LASMH_complete_LATE_200.tex" ///
    "LASMH_complete_ITT_110.tex" ///
    "LASMH_complete_ITT_150.tex" ///
    "LASMH_complete_ITT_200.tex" {
    capture confirm file "$tables/`expected_output'"
    if _rc {
        display as error "Missing expected maintained final table output: $tables/`expected_output'"
        exit 601
    }
    display as result "Wrote maintained final table output: $tables/`expected_output'"
}

display as text "Step 4.10: risk-interaction repayment and completion ITT/LATE tables (h2_iv_ols_riskintcat.do)"
display as text "BEGIN original source boundary: h2_iv_ols_riskintcat.do"
do "$repo_root/code/replication/final_outputs/h2_iv_ols_riskintcat.do"
display as text "END original source boundary: h2_iv_ols_riskintcat.do"

foreach expected_output in ///
    "LASMH_repay_riskinteract_LATE.tex" ///
    "LASMH_repay_riskinteract_ITT.tex" ///
    "LASMH_complete_riskinteract_LATE.tex" ///
    "LASMH_complete_riskinteract_ITT.tex" {
    capture confirm file "$tables/`expected_output'"
    if _rc {
        display as error "Missing expected maintained final table output: $tables/`expected_output'"
        exit 601
    }
    display as result "Wrote maintained final table output: $tables/`expected_output'"
}

display as text "Step 4.11: WTP-interaction repayment and completion LATE tables (h3_iv_ols_wtpintcat.do)"
display as text "BEGIN original source boundary: h3_iv_ols_wtpintcat.do"
do "$repo_root/code/replication/final_outputs/h3_iv_ols_wtpintcat.do"
display as text "END original source boundary: h3_iv_ols_wtpintcat.do"

foreach expected_output in ///
    "LASMH_repay_wtpinteract_LATE.tex" ///
    "LASMH_complete_wtpinteract_LATE.tex" {
    capture confirm file "$tables/`expected_output'"
    if _rc {
        display as error "Missing expected maintained final table output: $tables/`expected_output'"
        exit 601
    }
    display as result "Wrote maintained final table output: $tables/`expected_output'"
}

display as text "Step 4.12: early-adoption repayment and completion ITT/LATE tables (h4_iv_ols_earlyadopt.do)"
display as text "BEGIN original source boundary: h4_iv_ols_earlyadopt.do"
do "$repo_root/code/replication/final_outputs/h4_iv_ols_earlyadopt.do"
display as text "END original source boundary: h4_iv_ols_earlyadopt.do"

foreach expected_output in ///
    "LASMH_repay_earlyadopt_LATE_100.tex" ///
    "LASMH_repay_earlyadopt_LATE_150.tex" ///
    "LASMH_repay_earlyadopt_LATE_200.tex" ///
    "LASMH_repay_earlyadopt_ITT_100.tex" ///
    "LASMH_repay_earlyadopt_ITT_150.tex" ///
    "LASMH_repay_earlyadopt_ITT_200.tex" ///
    "LASMH_complete_earlyadopt_LATE_110.tex" ///
    "LASMH_complete_earlyadopt_LATE_150.tex" ///
    "LASMH_complete_earlyadopt_LATE_200.tex" ///
    "LASMH_complete_earlyadopt_ITT_110.tex" ///
    "LASMH_complete_earlyadopt_ITT_150.tex" ///
    "LASMH_complete_earlyadopt_ITT_200.tex" {
    capture confirm file "$tables/`expected_output'"
    if _rc {
        display as error "Missing expected maintained final table output: $tables/`expected_output'"
        exit 601
    }
    display as result "Wrote maintained final table output: $tables/`expected_output'"
}

display as result "Stata final-output construction completed."
