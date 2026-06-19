# M2, M3, and M4 Handoff Notes

This handoff summarizes the M1 source audit for the next implementation
milestones. It uses `docs/output_map.md` as the final source of truth, with
supporting path and dependency details from `docs/staged_input_coverage.md` and
`docs/shared_construction_map.md`.

M1 currently covers 51 final replication targets: 42 table outputs and 9 figure
outputs. Every target row in `docs/output_map.md` is marked `audited`.

## M2 Stata Foundation Requirements

M2 should build the shared Stata foundation before any final-output script is
ported. The foundation should provide one controlled replacement for the
original `a1_globals.do` assumptions.

Required path globals:

| Original global | Maintained source or output path |
|---|---|
| `bsvy_raw` | `data/raw/baseline_survey/raw` |
| `esvy_raw` | `data/raw/endline_survey/raw` |
| `bsvy_clean` | `data/raw/baseline_survey/clean` |
| `esvy_clean` | `data/raw/endline_survey/clean` |
| `temp` | staged reference inputs from `data/raw/interim`; maintained generated intermediates should use a non-raw output directory |
| `lsms2018` | `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12` |
| `merged` | `data/raw/merged` |
| `repay_clean` | `data/raw/repayment` |
| `tables` | maintained table outputs in `output/results/tables` |

Foundation work needed before M3:

- Create output directories for `output/results/tables` and
  `output/results/figures`.
- Create a generated-intermediate directory outside `data/raw/`; M1 treats
  `data/raw/interim` and generated-looking files under `data/raw/lsms/...` as
  staged source/reference inputs.
- Add a single Stata entrypoint that initializes globals, opens logs, checks
  dependencies, and runs numbered research-step modules in a deterministic
  order.
- Keep selector-style invocation out of the normal researcher workflow. The
  public interface should be opening and running `code/replication/run_replication.do`;
  lower-level support scripts should sit behind numbered pipeline steps.
- Check Stata-side dependencies used by audited scripts: `esttab`/`eststo`
  from `estout`, `blindschemes` for `rl2_takeupbywtp.do`, and the `ivregress2`
  command calls in the risk, WTP, and early-adoption IV scripts.
- Keep the original `Tables` versus `tables` case mismatch out of maintained
  code by routing all maintained table writes through `output/results/tables`.

Shared construction modules that M2 should account for:

| Future support area | Original scripts | Main downstream use |
|---|---|---|
| LSMS support | `c2_build_asset_prices.do`, `c3_build_busasset_prices.do`, `c4_build_lsms_chars.do`, `d11_lsms_vars_build.do` | asset price lookups, `lsms2018_vars.dta`, `income.dta`, `lsms_vars_indiv.dta`, `lsms_vars_hh.dta` |
| Baseline survey support | `d9_construct_bsvysec_2.do`, `e1_build_bsvysec.do` | `hhvars_baseline.dta` and baseline household section files |
| Endline survey support | `d10_construct_esvysec_2.do`, `f1_educ_index_prep_female.do`, `f2_educ_index_prep_male.do` | endline household, wellbeing, lock-occurrence, and education-index files |

Current maintained Stata workflow structure:

| Ordered step | Script | Role |
|---|---|---|
| Entrypoint | `code/replication/run_replication.do` | Detect the repository root, open the deterministic Stata log, dispatch ordered steps, and exit consistently on failure. |
| Step 0 | `code/replication/00_header.do` | Resolve repo-relative paths, create maintained output directories, check source paths, and verify Stata dependencies. |
| Step 1 | `code/replication/01_lsms_support.do` | Build maintained LSMS support outputs under `data/processed/stata/lsms` while preserving the four original source-script boundaries under `code/replication/support/lsms/`. |
| Planned Step 2 | `code/replication/02_baseline_support.do` | Build maintained baseline survey support outputs when the baseline support issue is implemented. |
| Planned Step 3 | `code/replication/03_endline_support.do` | Build maintained endline survey support outputs when the endline support issue is implemented. |

## M3 Stata Table and Figure Modules

M3 should keep the Stata-generated final outputs grouped by audited final-output
module. These groups are implementation-ready boundaries because each group maps
to one original final-output script and one planned maintained module in
`docs/output_map.md`.

| Maintained module boundary | Outputs | Shared dependencies to stage or produce first |
|---|---|---|
| `g4_endline_educ_hh` | `endline_educ_hh.tex` | `data/raw/merged/key_rep.dta`; `data/raw/endline_survey/clean/2_educ_indiv.dta`; `2_educ_hh.dta`; script-local `num_520e_info` |
| `g4_endline_educ_hh_full` | `endline_educ_hh_full.tex` | same education household inputs as `g4_endline_educ_hh` |
| `g4_endline_educ_indiv` | `endline_educ_indiv.tex` | `key_rep.dta`; `2_educ_indiv.dta`; `femaleeduc.dta`; `maleeduc.dta`; script-local `indiv` |
| `g5_endline_analysis` | `assets99_lvl_ITT_v2.tex`; `assetsbal99_lvl_ITT_v2.tex`; `shock_A.tex`; `shock_B.tex` | `key_rep.dta`; `3A_assets_hh.dta`; `6_bsl.dta`; `hhvars_baseline.dta`; `7_wellbeing_hh.dta` |
| `g10_sac_regression` | `sacreg.tex` | `2_educ_indiv.dta`; `key_rep.dta`; script-local `num_520e_info` |
| `g13_endline_moneyborrowed` | `endline_moneyborrowed.tex` | `key_rep.dta`; `3A_assets_hh.dta`; `6_bsl.dta`; `hhvars_baseline.dta` |
| `g14_endline_income` | `income99_lvl_ITT.tex` | `key_rep.dta`; `adult_labor_supply_hh.dta` |
| `g15_compliance_day200` | `compliance_tab.tex` | `key_rep.dta`; `fenix_repay_extend_07172020_rep.dta`; `hhvars_baseline.dta`; script-local `complierinfo` |
| `h1_iv_ols_main` | `LASMH_repay_LATE_100.tex`; `LASMH_repay_LATE_150.tex`; `LASMH_repay_LATE_200.tex`; `LASMH_repay_ITT_100.tex`; `LASMH_repay_ITT_150.tex`; `LASMH_repay_ITT_200.tex`; `LASMH_complete_LATE_110.tex`; `LASMH_complete_LATE_150.tex`; `LASMH_complete_LATE_200.tex`; `LASMH_complete_ITT_110.tex`; `LASMH_complete_ITT_150.tex`; `LASMH_complete_ITT_200.tex` | `fenix_repay_extend_07172020_rep.dta`; `key_rep.dta`; script-local `all`, `data*_strict`, and `as_sample` |
| `h2_iv_ols_riskintcat` | `LASMH_repay_riskinteract_LATE.tex`; `LASMH_repay_riskinteract_ITT.tex`; `LASMH_complete_riskinteract_LATE.tex`; `LASMH_complete_riskinteract_ITT.tex` | `fenix_repay_extend_07172020_rep.dta`; `key_rep.dta`; script-local `all`, `data150_strict`, and `data200_strict` |
| `h3_iv_ols_wtpintcat` | `LASMH_repay_wtpinteract_LATE.tex`; `LASMH_complete_wtpinteract_LATE.tex` | `fenix_repay_extend_07172020_rep.dta`; `key_rep.dta`; `9_lockedoccurences_hh.dta`; script-local `all`, `data150_strict`, and `data200_strict` |
| `h4_iv_ols_earlyadopt` | `LASMH_repay_earlyadopt_LATE_100.tex`; `LASMH_repay_earlyadopt_LATE_150.tex`; `LASMH_repay_earlyadopt_LATE_200.tex`; `LASMH_repay_earlyadopt_ITT_100.tex`; `LASMH_repay_earlyadopt_ITT_150.tex`; `LASMH_repay_earlyadopt_ITT_200.tex`; `LASMH_complete_earlyadopt_LATE_110.tex`; `LASMH_complete_earlyadopt_LATE_150.tex`; `LASMH_complete_earlyadopt_LATE_200.tex`; `LASMH_complete_earlyadopt_ITT_110.tex`; `LASMH_complete_earlyadopt_ITT_150.tex`; `LASMH_complete_earlyadopt_ITT_200.tex` | `fenix_repay_extend_07172020_rep.dta`; `key_rep.dta`; script-local `all` and `data*_bsvy_allrestrict_new` |
| `rl2_takeupbywtp` | `takeupbywtp_dif.png` | `key_rep.dta`; `hhvars_baseline.dta`; `9_lockedoccurences_hh.dta`; `blindschemes`/`plottig` graph scheme |

## M4 Python Replacement Modules

M4 should replace non-Stata final outputs in Python, using the M1 module
boundaries rather than preserving R, Matlab, or notebook execution as-is.

| Maintained module boundary | Original source | Outputs | Required staged inputs and intermediates |
|---|---|---|---|
| `repayment_rate_figures` | `completionrates.R`; `repaymentrates.R` | `loancompleteratesgrey.pdf`; `diff_complete.pdf`; `repaymentratesgrey.pdf`; `diff_repayments.pdf` | `data/raw/repayment/fenix_repay_extend_07172020_strict_rep.dta`; script-local completion and repayment summary frames |
| `loan_irr_table` | `rl5_irr.ipynb` | `r_treatment_irr_withCI.tex` | `data/raw/interim/tab_cf_loan_level.csv`; aggregate cash-flow frame `agg_cf`; bootstrap frames `BS_irr_bytreat` and `BS_irr_bytreatrisk` |
| `loan_irr_figures` | `rl6_loanlevelirr.m`; `rl6_loanlevelirr_old.m` | `IRRs_terciles.png`; `IRRs_terciles.eps`; `IRRs_cdf.png`; `IRRs_cdf.eps` | `loanlevelirrT1L.csv`; `loanlevelirrT2U.csv`; `loanlevelirrOld.csv`; `irrbyquantiles_allboots_*.mat`; `irrbyloan_*.mat` under `data/raw/interim` |

Python replacement risks to handle explicitly:

- The R scripts hardcode the original author home path. Python replacements
  should read only from repo-relative `data/raw/` paths and write to
  `output/results/figures`.
- `rl5_irr.ipynb` depends on `pandas`, `numpy`, and `numpy_financial`; its
  bootstrap uses Python `random` without an explicit seed in the audited source.
- `rl6_loanlevelirr.m` depends on Matlab functions such as `irr` and
  `randsample`, and also depends on old MAT files produced by
  `rl6_loanlevelirr_old.m`.

## Remaining Source-Audit Risks

These risks remain after M1 and should shape later milestone work.

| Risk | Affected outputs |
|---|---|
| `data/raw/interim` contains staged author-provided or generated-looking reference intermediates. M2/M4 must decide which are treated as immutable source inputs and which get maintained producers before writing replacements. | `r_treatment_irr_withCI.tex`; `IRRs_terciles.png`; `IRRs_terciles.eps`; `IRRs_cdf.png`; `IRRs_cdf.eps` |
| Parts of `data/raw/lsms/UGA_2018_UNPS_v01_M_STATA12` contain generated/reference files, not only raw external inputs. M2 should avoid writing maintained LSMS outputs back into `data/raw`. | Any output that depends on `hhvars_baseline.dta`; indirectly `assets99_lvl_ITT_v2.tex`; `assetsbal99_lvl_ITT_v2.tex`; `shock_A.tex`; `shock_B.tex`; `endline_moneyborrowed.tex`; `compliance_tab.tex`; `takeupbywtp_dif.png` |
| `key_rep.dta` has no maintained producer identified in M1 and remains an author-provided merged input. | All M3 module outputs listed above: education, assets/shocks, SAC, money borrowed, income, compliance, repayment/completion IV tables, and `takeupbywtp_dif.png` |
| Several baseline and endline clean files are pre-staged with no producer found among the shared construction scripts audited in M1. | `endline_educ_hh.tex`; `endline_educ_hh_full.tex`; `endline_educ_indiv.tex`; `assets99_lvl_ITT_v2.tex`; `assetsbal99_lvl_ITT_v2.tex`; `shock_A.tex`; `shock_B.tex`; `endline_moneyborrowed.tex`; `sacreg.tex`; `LASMH_complete_wtpinteract_LATE.tex`; `LASMH_repay_wtpinteract_LATE.tex`; `takeupbywtp_dif.png` |
| Stata dependency handling is not centralized in the original scripts. `estout`, `blindschemes`, and the `ivregress2` calls should be checked before ported modules run. | All Stata table outputs using `esttab`; `takeupbywtp_dif.png`; risk/WTP/early-adoption IV outputs from `h2_iv_ols_riskintcat`, `h3_iv_ols_wtpintcat`, and `h4_iv_ols_earlyadopt` |
| Non-Stata scripts contain environment assumptions or stochastic routines that need deterministic maintained replacements. | `loancompleteratesgrey.pdf`; `diff_complete.pdf`; `repaymentratesgrey.pdf`; `diff_repayments.pdf`; `r_treatment_irr_withCI.tex`; `IRRs_terciles.png`; `IRRs_terciles.eps`; `IRRs_cdf.png`; `IRRs_cdf.eps` |
