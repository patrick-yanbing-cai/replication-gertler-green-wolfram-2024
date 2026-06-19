*** Purpose: Step 1, build maintained LSMS shared support outputs.

version 16
set more off

if "$repo_root" == "" {
    display as error "repo_root global is not defined. Run code/replication/run_replication.do from the repository root."
    exit 198
}

if "$lsms2018" == "" {
    display as error "lsms2018 global is not defined. Run code/replication/00_header.do before LSMS support."
    exit 198
}

if "$lsms_processed" == "" {
    display as error "lsms_processed global is not defined. Run code/replication/00_header.do before LSMS support."
    exit 198
}

display as text "LSMS source root: $lsms2018"
display as text "LSMS maintained output root: $lsms_processed"
display as text "LSMS asset price output root: $lsms_asset_prices"
display as text "Intentional difference from staged reference files: maintained LSMS support outputs are written under data/processed/stata/lsms, not data/raw/lsms."

assert_maintained_generated_path "$lsms_processed" "lsms_processed"
assert_stata_intermediate_path "$lsms_processed" "lsms_processed"
assert_maintained_generated_path "$lsms_asset_prices" "lsms_asset_prices"
assert_stata_intermediate_path "$lsms_asset_prices" "lsms_asset_prices"

display as text "Step 1.1: LSMS household asset prices (c2_build_asset_prices.do)"
display as text "BEGIN original source boundary: c2_build_asset_prices.do"
do "$repo_root/code/replication/support/lsms/c2_build_asset_prices.do"
display as text "END original source boundary: c2_build_asset_prices.do"

display as text "Step 1.2: LSMS business asset prices (c3_build_busasset_prices.do)"
display as text "BEGIN original source boundary: c3_build_busasset_prices.do"
do "$repo_root/code/replication/support/lsms/c3_build_busasset_prices.do"
display as text "END original source boundary: c3_build_busasset_prices.do"

display as text "Step 1.3: LSMS characteristics (c4_build_lsms_chars.do)"
display as text "BEGIN original source boundary: c4_build_lsms_chars.do"
do "$repo_root/code/replication/support/lsms/c4_build_lsms_chars.do"
display as text "END original source boundary: c4_build_lsms_chars.do"

display as text "Step 1.4: LSMS income/individual/household variables (d11_lsms_vars_build.do)"
display as text "BEGIN original source boundary: d11_lsms_vars_build.do"
do "$repo_root/code/replication/support/lsms/d11_lsms_vars_build.do"
display as text "END original source boundary: d11_lsms_vars_build.do"

foreach expected_output in ///
    `"$lsms_asset_prices/asset_prices_dist.dta"' ///
    `"$lsms_asset_prices/asset_prices_reg.dta"' ///
    `"$lsms_asset_prices/asset_prices_nat.dta"' ///
    `"$lsms_asset_prices/asset_busprices_dist.dta"' ///
    `"$lsms_asset_prices/asset_busprices_reg.dta"' ///
    `"$lsms_asset_prices/asset_busprices_nat.dta"' ///
    `"$lsms_processed/lsms2018_vars.dta"' ///
    `"$lsms_processed/income.dta"' ///
    `"$lsms_processed/lsms_vars_indiv.dta"' ///
    `"$lsms_processed/lsms_vars_hh.dta"' {
    capture confirm file "`expected_output'"
    if _rc {
        display as error "Missing expected maintained LSMS output: `expected_output'"
        exit 601
    }
    display as result "Wrote maintained LSMS output: `expected_output'"
}

display as result "LSMS support construction completed."
