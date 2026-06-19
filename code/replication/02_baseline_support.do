*** Purpose: Step 2, build maintained baseline survey shared support outputs.

version 16
set more off

if "$repo_root" == "" {
    display as error "repo_root global is not defined. Run code/replication/run_replication.do from the repository root."
    exit 198
}

if "$bsvy_raw" == "" {
    display as error "bsvy_raw global is not defined. Run code/replication/00_header.do before baseline support."
    exit 198
}

if "$bsvy_clean" == "" {
    display as error "bsvy_clean global is not defined. Run code/replication/00_header.do before baseline support."
    exit 198
}

if "$bsvy_processed" == "" {
    display as error "bsvy_processed global is not defined. Run code/replication/00_header.do before baseline support."
    exit 198
}

if "$lsms_asset_prices" == "" {
    display as error "lsms_asset_prices global is not defined. Run code/replication/00_header.do before baseline support."
    exit 198
}

display as text "Baseline raw source root: $bsvy_raw"
display as text "Baseline staged clean source root: $bsvy_clean"
display as text "Baseline maintained output root: $bsvy_processed"
display as text "Maintained LSMS asset price input root: $lsms_asset_prices"
display as text "Intentional difference from staged reference files: maintained baseline support outputs are written under data/processed/stata/baseline_survey, not data/raw/baseline_survey."

assert_maintained_generated_path "$bsvy_processed" "bsvy_processed"
assert_stata_intermediate_path "$bsvy_processed" "bsvy_processed"

display as text "Checking staged baseline inputs:"
foreach required_input in ///
    `"$bsvy_raw/fenix_clean2_rep.dta"' ///
    `"$bsvy_clean/1_cover_hh.dta"' ///
    `"$bsvy_clean/2_roster_hh.dta"' ///
    `"$bsvy_clean/3A_school_dist_hh.dta"' ///
    `"$bsvy_clean/3B_educ1_hh.dta"' ///
    `"$bsvy_clean/3C_educ2_hh.dta"' ///
    `"$bsvy_clean/3D_educ_attitudes_hh.dta"' ///
    `"$bsvy_clean/9_hhincome.dta"' ///
    `"$bsvy_clean/9_hhincome_hh.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required staged baseline input: `required_input'"
        display as error "Run python code/setup/prepare_raw_files.py before running maintained Stata modules."
        exit 601
    }
    display as text "staged baseline input: `required_input'"
}

display as text "Checking maintained LSMS inputs:"
foreach required_input in ///
    `"$lsms_asset_prices/asset_prices_dist.dta"' ///
    `"$lsms_asset_prices/asset_prices_reg.dta"' ///
    `"$lsms_asset_prices/asset_prices_nat.dta"' ///
    `"$lsms_asset_prices/asset_busprices_dist.dta"' ///
    `"$lsms_asset_prices/asset_busprices_reg.dta"' ///
    `"$lsms_asset_prices/asset_busprices_nat.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required maintained LSMS input for baseline support: `required_input'"
        display as error "Run Step 1 LSMS support construction before baseline support."
        exit 601
    }
    display as text "maintained LSMS input: `required_input'"
}

display as text "Step 2.1: baseline survey sections (d9_construct_bsvysec_2.do)"
display as text "BEGIN original source boundary: d9_construct_bsvysec_2.do"
do "$repo_root/code/replication/support/baseline/d9_construct_bsvysec_2.do"
display as text "END original source boundary: d9_construct_bsvysec_2.do"

display as text "Step 2.2: baseline household variables (e1_build_bsvysec.do)"
display as text "BEGIN original source boundary: e1_build_bsvysec.do"
do "$repo_root/code/replication/support/baseline/e1_build_bsvysec.do"
display as text "END original source boundary: e1_build_bsvysec.do"

foreach expected_output in ///
    `"$bsvy_processed/4_energy.dta"' ///
    `"$bsvy_processed/4_energy_hh.dta"' ///
    `"$bsvy_processed/5_shs.dta"' ///
    `"$bsvy_processed/5_shs_hh.dta"' ///
    `"$bsvy_processed/6_solarlantern.dta"' ///
    `"$bsvy_processed/6_solarlantern_hh.dta"' ///
    `"$bsvy_processed/7_landhome.dta"' ///
    `"$bsvy_processed/7_landhome_hh.dta"' ///
    `"$bsvy_processed/8_assets.dta"' ///
    `"$bsvy_processed/8_assets_hh.dta"' ///
    `"$bsvy_processed/9_busassets.dta"' ///
    `"$bsvy_processed/10A_coop.dta"' ///
    `"$bsvy_processed/10A_coop_hh.dta"' ///
    `"$bsvy_processed/10B_loans.dta"' ///
    `"$bsvy_processed/10B_loans_hh.dta"' ///
    `"$bsvy_processed/10C_savings.dta"' ///
    `"$bsvy_processed/10C_savings_hh.dta"' ///
    `"$bsvy_processed/10D_lending.dta"' ///
    `"$bsvy_processed/10D_lending_hh.dta"' ///
    `"$bsvy_processed/hhvars_baseline.dta"' {
    capture confirm file "`expected_output'"
    if _rc {
        display as error "Missing expected maintained baseline output: `expected_output'"
        exit 601
    }
    display as result "Wrote maintained baseline output: `expected_output'"
}

display as result "Baseline survey support construction completed."
