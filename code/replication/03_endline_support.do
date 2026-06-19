*** Purpose: Step 3, build maintained endline survey shared support outputs.

version 16
set more off

if "$repo_root" == "" {
    display as error "repo_root global is not defined. Run code/replication/run_replication.do from the repository root."
    exit 198
}

if "$esvy_raw" == "" {
    display as error "esvy_raw global is not defined. Run code/replication/00_header.do before endline support."
    exit 198
}

if "$esvy_clean" == "" {
    display as error "esvy_clean global is not defined. Run code/replication/00_header.do before endline support."
    exit 198
}

if "$esvy_processed" == "" {
    display as error "esvy_processed global is not defined. Run code/replication/00_header.do before endline support."
    exit 198
}

if "$bsvy_clean" == "" {
    display as error "bsvy_clean global is not defined. Run code/replication/00_header.do before endline support."
    exit 198
}

if "$merged" == "" {
    display as error "merged global is not defined. Run code/replication/00_header.do before endline support."
    exit 198
}

display as text "Endline raw source root: $esvy_raw"
display as text "Endline staged clean source root: $esvy_clean"
display as text "Baseline staged clean source root: $bsvy_clean"
display as text "Merged staged source root: $merged"
display as text "Endline maintained output root: $esvy_processed"
display as text "Intentional difference from staged reference files: maintained endline support outputs are written under data/processed/stata/endline_survey, not data/raw/endline_survey."

assert_maintained_generated_path "$esvy_processed" "esvy_processed"
assert_stata_intermediate_path "$esvy_processed" "esvy_processed"

display as text "Checking staged endline inputs:"
foreach required_input in ///
    `"$esvy_raw/fenix_clean_pii_20200830_rep.dta"' ///
    `"$esvy_clean/2_educ_indiv.dta"' ///
    `"$esvy_clean/3A_assets_hh.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required staged endline input: `required_input'"
        display as error "Run python code/setup/prepare_raw_files.py before running maintained Stata modules."
        exit 601
    }
    display as text "staged endline input: `required_input'"
}

display as text "Checking staged baseline and merged inputs:"
foreach required_input in ///
    `"$bsvy_clean/2_roster.dta"' ///
    `"$bsvy_clean/9_hhincome.dta"' ///
    `"$merged/key_rep.dta"' {
    capture confirm file "`required_input'"
    if _rc {
        display as error "Missing required staged support input for endline support: `required_input'"
        display as error "Run python code/setup/prepare_raw_files.py before running maintained Stata modules."
        exit 601
    }
    display as text "staged support input: `required_input'"
}

display as text "Step 3.1: endline survey sections (d10_construct_esvysec_2.do)"
display as text "BEGIN original source boundary: d10_construct_esvysec_2.do"
do "$repo_root/code/replication/support/endline/d10_construct_esvysec_2.do"
display as text "END original source boundary: d10_construct_esvysec_2.do"

display as text "Step 3.2: female education index (f1_educ_index_prep_female.do)"
display as text "BEGIN original source boundary: f1_educ_index_prep_female.do"
do "$repo_root/code/replication/support/endline/f1_educ_index_prep_female.do"
display as text "END original source boundary: f1_educ_index_prep_female.do"

display as text "Step 3.3: male education index (f2_educ_index_prep_male.do)"
display as text "BEGIN original source boundary: f2_educ_index_prep_male.do"
do "$repo_root/code/replication/support/endline/f2_educ_index_prep_male.do"
display as text "END original source boundary: f2_educ_index_prep_male.do"

foreach expected_output in ///
    `"$esvy_processed/1_hhinfo.dta"' ///
    `"$esvy_processed/3B_land.dta"' ///
    `"$esvy_processed/4_busassets.dta"' ///
    `"$esvy_processed/4_comassets_val.dta"' ///
    `"$esvy_processed/6A_rdypyloanuse.dta"' ///
    `"$esvy_processed/7_wellbeing.dta"' ///
    `"$esvy_processed/7_wellbeing_hh.dta"' ///
    `"$esvy_processed/9_lockedoccurences.dta"' ///
    `"$esvy_processed/9_lockedoccurences_hh.dta"' ///
    `"$esvy_processed/femaleeduc.dta"' ///
    `"$esvy_processed/maleeduc.dta"' {
    capture confirm file "`expected_output'"
    if _rc {
        display as error "Missing expected maintained endline output: `expected_output'"
        exit 601
    }
    display as result "Wrote maintained endline output: `expected_output'"
}

display as result "Endline survey support construction completed."
