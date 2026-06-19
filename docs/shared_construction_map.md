# Shared Source Construction Map

This M1 audit maps the original shared construction scripts that sit upstream of
the final table and figure scripts. Paths use the staged `data/raw/` equivalents
from `docs/staged_input_coverage.md`; original-script evidence keeps the
Dataverse globals and line numbers so the dependency can be rechecked.

The original package writes several files back into folders that this maintained
repo stages under `data/raw/`. Those staged copies are reference inputs here.
Maintained replacements should be generated outside `data/raw/`.

## Script Audit

| Original script | Purpose | Staged inputs read | Intermediate outputs written | Consumer evidence |
|---|---|---|---|---|
| `c2_build_asset_prices.do` | Builds LSMS household asset price lookups at district, region, and national levels. | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/GSEC1.dta`; `AGSEC6A.dta`; `AGSEC6B.dta`; `AGSEC6C.dta`; `AGSEC10.dta`; `GSEC14.dta`; `GSEC15D.dta` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/Asset prices data/asset_prices_dist.dta`; `asset_prices_reg.dta`; `asset_prices_nat.dta` | `d9_construct_bsvysec_2.do:828`, `:831`, and `:835` merge these files while constructing baseline asset values. |
| `c3_build_busasset_prices.do` | Builds LSMS business-asset price lookups at district, region, and national levels. | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/GSEC1.dta`; `AGSEC10.dta`; `GSEC14.dta`; `GSEC15C.dta`; `GSEC15D.dta` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/Asset prices data/asset_busprices_dist.dta`; `asset_busprices_reg.dta`; `asset_busprices_nat.dta` | `d9_construct_bsvysec_2.do:1250`, `:1253`, and `:1257` merge these files while constructing baseline business assets. |
| `c4_build_lsms_chars.do` | Builds compact LSMS individual demographic and labor characteristics. | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/gsec2.dta`; `GSEC8.dta`; `GSEC1.dta` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/lsms2018_vars.dta` | `g6_admin_demos.do:47` uses `lsms2018_vars.dta`. `g6_admin_demos.do` is not currently a final-output row in `docs/output_map.md`. |
| `d9_construct_bsvysec_2.do` | Builds baseline survey section-level and household-level clean datasets from the baseline raw survey, including valued household and business assets. | `data/raw/baseline_survey/raw/fenix_clean2_rep.dta`; pre-staged `data/raw/baseline_survey/clean/1_cover_hh.dta`; pre-staged `9_hhincome.dta`; LSMS asset price outputs from `c2_build_asset_prices.do`; LSMS business-asset price outputs from `c3_build_busasset_prices.do` | `data/raw/baseline_survey/clean/4_energy.dta`; `4_energy_hh.dta`; `5_shs.dta`; `5_shs_hh.dta`; `6_solarlantern.dta`; `6_solarlantern_hh.dta`; `7_landhome.dta`; `7_landhome_hh.dta`; `8_assets.dta`; `8_assets_hh.dta`; `9_busassets.dta`; `10A_coop.dta`; `10A_coop_hh.dta`; `10B_loans.dta`; `10B_loans_hh.dta`; `10C_savings.dta`; `10C_savings_hh.dta`; `10D_lending.dta`; `10D_lending_hh.dta` | `e1_build_bsvysec.do:51-78` merges the household-level outputs into `hhvars_baseline.dta`; `g13_endline_moneyborrowed.do:32`, `g15_compliance_day200.do:26`, `g5_endline_analysis.do:37`, and `rl2_takeupbywtp.do:36` consume `hhvars_baseline.dta`. |
| `d10_construct_esvysec_2.do` | Builds endline survey clean datasets for household info, assets, loan-use readiness, wellbeing, and lock occurrences. | `data/raw/endline_survey/raw/fenix_clean_pii_20200830_rep.dta`; pre-staged `data/raw/endline_survey/clean/3A_assets_hh.dta`; pre-staged baseline `data/raw/baseline_survey/clean/2_roster.dta`; pre-staged `9_hhincome.dta` | `data/raw/endline_survey/clean/1_hhinfo.dta`; `3B_land.dta`; `4_busassets.dta`; `4_comassets_val.dta`; `6A_rdypyloanuse.dta`; `7_wellbeing.dta`; `7_wellbeing_hh.dta`; `9_lockedoccurences.dta`; `9_lockedoccurences_hh.dta` | `g1_paper_facts.do:187` uses `6A_rdypyloanuse.dta`; `g1_paper_facts.do:486` and `g5_endline_analysis.do:53` use `7_wellbeing_hh.dta`; `h3_iv_ols_wtpintcat.do:44` and `rl2_takeupbywtp.do:39` use `9_lockedoccurences_hh.dta`. |
| `d11_lsms_vars_build.do` | Builds LSMS income, individual education/labor variables, and household education/progress variables. | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/GSEC1.dta`; `GSEC2.dta`; `GSEC4.dta`; `GSEC7_4.dta`; `GSEC8.dta`; `GSEC12_2.dta`; `AGSEC5A.dta`; `AGSEC5B.dta`; `AGSEC8A.dta`; `AGSEC8B.dta`; `AGSEC8C.dta`; `AGSEC11.dta` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/income.dta`; `lsms_vars_indiv.dta`; `lsms_vars_hh.dta` | `g1_paper_facts.do:257` uses `lsms_vars_indiv.dta`; `g1_paper_facts.do:263` uses `lsms_vars_hh.dta`; `d11_lsms_vars_build.do:309` reuses its own `income.dta`. |
| `e1_build_bsvysec.do` | Aggregates baseline clean household sections into one baseline household covariate file. | Pre-staged `data/raw/baseline_survey/clean/1_cover_hh.dta`; `2_roster_hh.dta`; `3A_school_dist_hh.dta`; `3B_educ1_hh.dta`; `3C_educ2_hh.dta`; `3D_educ_attitudes_hh.dta`; `9_hhincome_hh.dta`; generated household sections from `d9_construct_bsvysec_2.do` | `data/raw/baseline_survey/clean/hhvars_baseline.dta` | `g1_paper_facts.do:156`, `g5_endline_analysis.do:37`, `g13_endline_moneyborrowed.do:32`, `g15_compliance_day200.do:26`, `g7_baseline_analysis_takeupcomp.do:28`, `g8_baseline_chars.do:34`, and `rl2_takeupbywtp.do:36` merge `hhvars_baseline.dta`. |
| `f1_educ_index_prep_female.do` | Builds female education-index outcomes using the merged experiment key and endline individual education data. | `data/raw/merged/key_rep.dta`; `data/raw/endline_survey/clean/2_educ_indiv.dta` | `data/raw/interim/mei_std_h1.dta` through `mei_std_h4.dta` during standardization; `data/raw/endline_survey/clean/femaleeduc.dta` | `g4_endline_educ_indiv.do:89` merges `femaleeduc.dta`. The `mei_std_h*.dta` files are temporary standardization inputs inside this script. |
| `f2_educ_index_prep_male.do` | Builds male education-index outcomes using the merged experiment key and endline individual education data. | `data/raw/merged/key_rep.dta`; `data/raw/endline_survey/clean/2_educ_indiv.dta` | `data/raw/interim/mei_std_h1.dta` through `mei_std_h4.dta` during standardization; `data/raw/endline_survey/clean/maleeduc.dta` | `g4_endline_educ_indiv.do:84` merges `maleeduc.dta`. The `mei_std_h*.dta` files are temporary standardization inputs inside this script. |

## Intermediate Dependency Map

| Intermediate dataset | Producing original script | Downstream final-output scripts identified | Evidence |
|---|---|---|---|
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/Asset prices data/asset_prices_dist.dta`; `asset_prices_reg.dta`; `asset_prices_nat.dta` | `c2_build_asset_prices.do` | Indirectly supports final-output scripts that use `hhvars_baseline.dta`, through `d9_construct_bsvysec_2.do` and `e1_build_bsvysec.do`. | Produced at `c2_build_asset_prices.do:580`, `:646`, `:712`; consumed at `d9_construct_bsvysec_2.do:828`, `:831`, `:835`. |
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/Asset prices data/asset_busprices_dist.dta`; `asset_busprices_reg.dta`; `asset_busprices_nat.dta` | `c3_build_busasset_prices.do` | Indirectly supports final-output scripts that use `hhvars_baseline.dta`, through `d9_construct_bsvysec_2.do` and `e1_build_bsvysec.do`. | Produced at `c3_build_busasset_prices.do:559`, `:650`, `:740`; consumed at `d9_construct_bsvysec_2.do:1250`, `:1253`, `:1257`. |
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/lsms2018_vars.dta` | `c4_build_lsms_chars.do` | `g6_admin_demos.do`, not currently in `docs/output_map.md`. | Produced at `c4_build_lsms_chars.do:85`; consumed at `g6_admin_demos.do:47`. |
| Baseline clean household sections `4_energy_hh.dta`, `5_shs_hh.dta`, `6_solarlantern_hh.dta`, `7_landhome_hh.dta`, `8_assets_hh.dta`, `10A_coop_hh.dta`, `10B_loans_hh.dta`, `10C_savings_hh.dta`, `10D_lending_hh.dta` | `d9_construct_bsvysec_2.do` | Indirectly supports `g1_paper_facts.do`, `g5_endline_analysis.do`, `g7_baseline_analysis_takeupcomp.do`, `g8_baseline_chars.do`, `g13_endline_moneyborrowed.do`, `g15_compliance_day200.do`, and `rl2_takeupbywtp.do` through `hhvars_baseline.dta`. | Produced at `d9_construct_bsvysec_2.do:272`, `:452`, `:518`, `:631`, `:1078`, `:1434`, `:1615`, `:1695`, `:1764`; merged at `e1_build_bsvysec.do:51-78`. |
| `data/raw/baseline_survey/clean/hhvars_baseline.dta` | `e1_build_bsvysec.do` | `g1_paper_facts.do`; `g5_endline_analysis.do`; `g7_baseline_analysis_takeupcomp.do`; `g8_baseline_chars.do`; `g13_endline_moneyborrowed.do`; `g15_compliance_day200.do`; `rl2_takeupbywtp.do` | Produced at `e1_build_bsvysec.do:83`; consumed at `g1_paper_facts.do:156`, `g5_endline_analysis.do:37`, `g7_baseline_analysis_takeupcomp.do:28`, `g8_baseline_chars.do:34`, `g13_endline_moneyborrowed.do:32`, `g15_compliance_day200.do:26`, `rl2_takeupbywtp.do:36`. |
| `data/raw/endline_survey/clean/6A_rdypyloanuse.dta` | `d10_construct_esvysec_2.do` | `g1_paper_facts.do` | Produced at `d10_construct_esvysec_2.do:284`; consumed at `g1_paper_facts.do:187`. |
| `data/raw/endline_survey/clean/7_wellbeing_hh.dta` | `d10_construct_esvysec_2.do` | `g1_paper_facts.do`; `g5_endline_analysis.do` | Produced at `d10_construct_esvysec_2.do:505`; consumed at `g1_paper_facts.do:486` and `g5_endline_analysis.do:53`. |
| `data/raw/endline_survey/clean/9_lockedoccurences_hh.dta` | `d10_construct_esvysec_2.do` | `h3_iv_ols_wtpintcat.do`; `rl2_takeupbywtp.do` | Produced at `d10_construct_esvysec_2.do:569`; consumed at `h3_iv_ols_wtpintcat.do:44` and `rl2_takeupbywtp.do:39`. |
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/income.dta` | `d11_lsms_vars_build.do` | Internal input for `lsms_vars_hh.dta`; no direct final-output consumer found. | Produced at `d11_lsms_vars_build.do:178`; reused at `d11_lsms_vars_build.do:309`. |
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/lsms_vars_indiv.dta` | `d11_lsms_vars_build.do` | `g1_paper_facts.do` | Produced at `d11_lsms_vars_build.do:285`; consumed at `g1_paper_facts.do:257`. |
| `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12/lsms_vars_hh.dta` | `d11_lsms_vars_build.do` | `g1_paper_facts.do` | Produced at `d11_lsms_vars_build.do:418`; consumed at `g1_paper_facts.do:263`. |
| `data/raw/endline_survey/clean/femaleeduc.dta` | `f1_educ_index_prep_female.do` | `g4_endline_educ_indiv.do` | Produced at `f1_educ_index_prep_female.do:146`; consumed at `g4_endline_educ_indiv.do:89`. |
| `data/raw/endline_survey/clean/maleeduc.dta` | `f2_educ_index_prep_male.do` | `g4_endline_educ_indiv.do` | Produced at `f2_educ_index_prep_male.do:148`; consumed at `g4_endline_educ_indiv.do:84`. |

## Pre-Staged Or Unmapped Inputs

These staged inputs are read by the audited scripts or downstream final-output
scripts, but this audit did not find a producer among the nine shared
construction scripts named in Issue 3.

| Staged dataset | Where it is read | Audit note |
|---|---|---|
| `data/raw/merged/key_rep.dta` | Broadly used by final-output scripts, including `h1_iv_ols_main.do:36`, `h2_iv_ols_riskintcat.do:36`, `h3_iv_ols_wtpintcat.do:36`, `h4_iv_ols_earlyadopt.do:36`, `g5_endline_analysis.do:30`, `g13_endline_moneyborrowed.do:25`, `g14_endline_income.do:25`, `g15_compliance_day200.do:23`, and `rl2_takeupbywtp.do:22`. | Staged as an author-provided merged source/reference dataset. No producer is maintained in this repo. |
| Baseline clean `1_cover_hh.dta`, `2_roster.dta`, `2_roster_hh.dta`, `3A_school_dist_hh.dta`, `3B_educ1_hh.dta`, `3C_educ2_hh.dta`, `3D_educ_attitudes_hh.dta`, `9_hhincome.dta`, `9_hhincome_hh.dta` | `d9_construct_bsvysec_2.do:672`, `:1088`, `:1094`; `d10_construct_esvysec_2.do:358`, `:376`; `e1_build_bsvysec.do:26-48`, `:66`. | Present under `data/raw/baseline_survey/clean/`; no matching `save` statement was found in the nine audited scripts. Treat as pre-staged until a separate source audit identifies producers. |
| Endline clean `2_educ_indiv.dta`, `2_educ_hh.dta`, `3A_assets_hh.dta` | `f1_educ_index_prep_female.do:30`; `f2_educ_index_prep_male.do:32`; `d10_construct_esvysec_2.do:159`; `g4_endline_educ_hh.do:23`, `:39`; `g4_endline_educ_hh_full.do:24`, `:42`; `g4_endline_educ_indiv.do:30`; `g5_endline_analysis.do:45`; `g13_endline_moneyborrowed.do:40`. | Present under `data/raw/endline_survey/clean/`; no matching `save` statement was found in the nine audited scripts. Treat as pre-staged until a separate source audit identifies producers. |
| `data/raw/repayment/fenix_repay_extend_07172020_strict_rep.dta`; `data/raw/repayment/commissions.dta` | R figure scripts read the repayment file; `g1_paper_facts.do:453` reads `commissions.dta`; multiple repayment regressions merge repayment data with `key_rep.dta`. | Staged repayment source/reference data copied from Dataverse, not produced by the shared construction scripts. |
| `data/raw/interim/tab_cf_loan_level.csv`; `loanlevelirrT1L.csv`; `loanlevelirrT2U.csv`; `loanlevelirrOld.csv`; `irrby*.mat` | `rl5_irr.ipynb:26` reads `tab_cf_loan_level.csv`; `rl6_loanlevelirr.m:12`, `:106`, `:210`, and `:257-265` read CSV/MAT interim files. | Staged author-provided or Matlab-generated interim files. They are outside the Stata shared construction scripts audited here. |

## Maintained Module Boundary Notes

- The maintained LSMS support step, `code/replication/01_lsms_support.do`,
  covers `c2_build_asset_prices.do`, `c3_build_busasset_prices.do`,
  `c4_build_lsms_chars.do`, and `d11_lsms_vars_build.do`.
- The maintained baseline survey support step,
  `code/replication/02_baseline_support.do`, covers
  `d9_construct_bsvysec_2.do` and `e1_build_bsvysec.do`.
- The maintained endline survey support step,
  `code/replication/03_endline_support.do`, covers
  `d10_construct_esvysec_2.do`, `f1_educ_index_prep_female.do`, and
  `f2_educ_index_prep_male.do`.
- `key_rep.dta`, repayment data, and IRR interim files should remain explicit
  staged dependencies until a later issue defines their maintained producers.

## Maintained LSMS Output Mapping

The maintained LSMS step preserves the original source-script boundaries but
routes every generated LSMS support file to `data/processed/stata/lsms` instead
of writing back into the staged `data/raw/lsms` source tree.

| Original source script | Maintained output |
|---|---|
| `c2_build_asset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_prices_dist.dta` |
| `c2_build_asset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_prices_reg.dta` |
| `c2_build_asset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_prices_nat.dta` |
| `c3_build_busasset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_busprices_dist.dta` |
| `c3_build_busasset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_busprices_reg.dta` |
| `c3_build_busasset_prices.do` | `data/processed/stata/lsms/Asset prices data/asset_busprices_nat.dta` |
| `c4_build_lsms_chars.do` | `data/processed/stata/lsms/lsms2018_vars.dta` |
| `d11_lsms_vars_build.do` | `data/processed/stata/lsms/income.dta` |
| `d11_lsms_vars_build.do` | `data/processed/stata/lsms/lsms_vars_indiv.dta` |
| `d11_lsms_vars_build.do` | `data/processed/stata/lsms/lsms_vars_hh.dta` |

## Maintained Baseline Survey Output Mapping

The maintained baseline support step preserves the original
`d9_construct_bsvysec_2.do` and `e1_build_bsvysec.do` source-script boundaries.
It reads pre-staged baseline clean inputs from `data/raw/baseline_survey/clean`
where no maintained producer has been identified, consumes maintained LSMS asset
price outputs from `data/processed/stata/lsms/Asset prices data`, and routes
newly generated baseline support files to
`data/processed/stata/baseline_survey`.

| Original source script | Maintained output |
|---|---|
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/4_energy.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/4_energy_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/5_shs.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/5_shs_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/6_solarlantern.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/6_solarlantern_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/7_landhome.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/7_landhome_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/8_assets.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/8_assets_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/9_busassets.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10A_coop.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10A_coop_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10B_loans.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10B_loans_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10C_savings.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10C_savings_hh.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10D_lending.dta` |
| `d9_construct_bsvysec_2.do` | `data/processed/stata/baseline_survey/10D_lending_hh.dta` |
| `e1_build_bsvysec.do` | `data/processed/stata/baseline_survey/hhvars_baseline.dta` |

M3 Stata consumers should read the maintained
`data/processed/stata/baseline_survey/hhvars_baseline.dta` path instead of the
staged reference copy under `data/raw/baseline_survey/clean`.

## Maintained Endline Survey Output Mapping

The maintained endline support step preserves the original
`d10_construct_esvysec_2.do`, `f1_educ_index_prep_female.do`, and
`f2_educ_index_prep_male.do` source-script boundaries. It reads pre-staged
endline clean inputs from `data/raw/endline_survey/clean` where no maintained
producer has been identified, and routes newly generated endline support files
to `data/processed/stata/endline_survey`.

| Original source script | Maintained output |
|---|---|
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/1_hhinfo.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/3B_land.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/4_busassets.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/4_comassets_val.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/6A_rdypyloanuse.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/7_wellbeing.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/7_wellbeing_hh.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/9_lockedoccurences.dta` |
| `d10_construct_esvysec_2.do` | `data/processed/stata/endline_survey/9_lockedoccurences_hh.dta` |
| `f1_educ_index_prep_female.do` | `data/processed/stata/endline_survey/femaleeduc.dta` |
| `f2_educ_index_prep_male.do` | `data/processed/stata/endline_survey/maleeduc.dta` |

M3 Stata consumers should read maintained endline support files from
`data/processed/stata/endline_survey` when a maintained producer exists. Staged
inputs without maintained producers, including `2_educ_indiv.dta`,
`2_educ_hh.dta`, `3A_assets_hh.dta`, `6_bsl.dta`, and
`adult_labor_supply_hh.dta`, remain explicit author-provided inputs under
`data/raw/endline_survey/clean`.
