# Output Map

This source-audit map tracks the final replication targets and the original artifacts that produce them.
Later M1 audit work should fill in the `Staged inputs`, `Intermediate outputs`, and `Planned maintained module` fields before any porting work starts.

Status values:

- `script-located`: the final output filename is directly referenced in an original script.
- `unmapped`: no exact final output filename has been found in the original scripts yet.
- `audited`: original script, staged inputs, intermediate outputs, and planned maintained module have been checked.
- `n/a`: intentionally excluded, with explanation in `Notes`.

## Fields

| Field | Description |
|---|---|
| Output filename | Final table or figure file required for the maintained replication target. |
| Output type | `table` or `figure`. |
| Reference path | Staged reference output copied from the original Dataverse package. |
| Original script | Original Dataverse script that directly references the final output filename, or `TBD`. |
| Script location | Original script path and line number for the final output write command, or `TBD`. |
| Staged inputs | `data/raw/` files needed by the original script path, to be filled during source audit. |
| Intermediate outputs | Generated files needed between staged inputs and final output, to be filled during source audit. |
| Planned maintained module | Future Stata or Python module expected to reproduce the output, to be filled during source audit. |
| Status | Current audit status for this row. |
| Notes | Short audit notes or caveats. |

## Outputs

| Output filename | Output type | Reference path | Original script | Script location | Staged inputs | Intermediate outputs | Planned maintained module | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|
| assets99_lvl_ITT_v2.tex | table | data/raw/reference_outputs/tables/assets99_lvl_ITT_v2.tex | g5_endline_analysis.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g5_endline_analysis.do:127 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| assetsbal99_lvl_ITT_v2.tex | table | data/raw/reference_outputs/tables/assetsbal99_lvl_ITT_v2.tex | g5_endline_analysis.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g5_endline_analysis.do:174 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| compliance_tab.tex | table | data/raw/reference_outputs/tables/compliance_tab.tex | g15_compliance_day200.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g15_compliance_day200.do:97 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| endline_educ_hh.tex | table | data/raw/reference_outputs/tables/endline_educ_hh.tex | g4_endline_educ_hh.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g4_endline_educ_hh.do:209 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| endline_educ_hh_full.tex | table | data/raw/reference_outputs/tables/endline_educ_hh_full.tex | g4_endline_educ_hh_full.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g4_endline_educ_hh_full.do:196 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| endline_educ_indiv.tex | table | data/raw/reference_outputs/tables/endline_educ_indiv.tex | g4_endline_educ_indiv.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g4_endline_educ_indiv.do:129 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| endline_moneyborrowed.tex | table | data/raw/reference_outputs/tables/endline_moneyborrowed.tex | g13_endline_moneyborrowed.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g13_endline_moneyborrowed.do:119 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| income99_lvl_ITT.tex | table | data/raw/reference_outputs/tables/income99_lvl_ITT.tex | g14_endline_income.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g14_endline_income.do:67 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_ITT_110.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_ITT_110.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:378 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_ITT_150.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_ITT_150.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:402 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_ITT_200.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_ITT_200.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:426 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_LATE_110.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_LATE_110.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:303 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_LATE_150.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_LATE_150.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:328 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_earlyadopt_LATE_200.tex | table | data/raw/reference_outputs/tables/LASMH_complete_earlyadopt_LATE_200.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:353 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_ITT_110.tex | table | data/raw/reference_outputs/tables/LASMH_complete_ITT_110.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:565 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_ITT_150.tex | table | data/raw/reference_outputs/tables/LASMH_complete_ITT_150.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:588 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_ITT_200.tex | table | data/raw/reference_outputs/tables/LASMH_complete_ITT_200.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:611 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_LATE_110.tex | table | data/raw/reference_outputs/tables/LASMH_complete_LATE_110.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:397 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_LATE_150.tex | table | data/raw/reference_outputs/tables/LASMH_complete_LATE_150.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:421 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_LATE_200.tex | table | data/raw/reference_outputs/tables/LASMH_complete_LATE_200.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:445 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_riskinteract_ITT.tex | table | data/raw/reference_outputs/tables/LASMH_complete_riskinteract_ITT.tex | h2_iv_ols_riskintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h2_iv_ols_riskintcat.do:223 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_riskinteract_LATE.tex | table | data/raw/reference_outputs/tables/LASMH_complete_riskinteract_LATE.tex | h2_iv_ols_riskintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h2_iv_ols_riskintcat.do:188 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_complete_wtpinteract_LATE.tex | table | data/raw/reference_outputs/tables/LASMH_complete_wtpinteract_LATE.tex | h3_iv_ols_wtpintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h3_iv_ols_wtpintcat.do:156 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_ITT_100.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_ITT_100.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:182 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_ITT_150.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_ITT_150.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:206 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_ITT_200.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_ITT_200.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:230 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_LATE_100.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_LATE_100.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:107 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_LATE_150.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_LATE_150.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:132 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_earlyadopt_LATE_200.tex | table | data/raw/reference_outputs/tables/LASMH_repay_earlyadopt_LATE_200.tex | h4_iv_ols_earlyadopt.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h4_iv_ols_earlyadopt.do:157 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_ITT_100.tex | table | data/raw/reference_outputs/tables/LASMH_repay_ITT_100.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:273 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_ITT_150.tex | table | data/raw/reference_outputs/tables/LASMH_repay_ITT_150.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:296 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_ITT_200.tex | table | data/raw/reference_outputs/tables/LASMH_repay_ITT_200.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:319 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_LATE_100.tex | table | data/raw/reference_outputs/tables/LASMH_repay_LATE_100.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:105 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_LATE_150.tex | table | data/raw/reference_outputs/tables/LASMH_repay_LATE_150.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:129 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_LATE_200.tex | table | data/raw/reference_outputs/tables/LASMH_repay_LATE_200.tex | h1_iv_ols_main.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h1_iv_ols_main.do:153 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_riskinteract_ITT.tex | table | data/raw/reference_outputs/tables/LASMH_repay_riskinteract_ITT.tex | h2_iv_ols_riskintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h2_iv_ols_riskintcat.do:144 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_riskinteract_LATE.tex | table | data/raw/reference_outputs/tables/LASMH_repay_riskinteract_LATE.tex | h2_iv_ols_riskintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h2_iv_ols_riskintcat.do:110 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| LASMH_repay_wtpinteract_LATE.tex | table | data/raw/reference_outputs/tables/LASMH_repay_wtpinteract_LATE.tex | h3_iv_ols_wtpintcat.do | dataverse_files/Gertler. Green. and Wolfram/scripts/h3_iv_ols_wtpintcat.do:112 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| r_treatment_irr_withCI.tex | table | data/raw/reference_outputs/tables/r_treatment_irr_withCI.tex | rl5_irr.ipynb | dataverse_files/Gertler. Green. and Wolfram/scripts/rl5_irr.ipynb:282 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| sacreg.tex | table | data/raw/reference_outputs/tables/sacreg.tex | g10_sac_regression.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g10_sac_regression.do:65 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| shock_A.tex | table | data/raw/reference_outputs/tables/shock_A.tex | g5_endline_analysis.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g5_endline_analysis.do:200 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| shock_B.tex | table | data/raw/reference_outputs/tables/shock_B.tex | g5_endline_analysis.do | dataverse_files/Gertler. Green. and Wolfram/scripts/g5_endline_analysis.do:217 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| diff_complete.pdf | figure | data/raw/reference_outputs/figures/diff_complete.pdf | completionrates.R | dataverse_files/Gertler. Green. and Wolfram/scripts/completionrates.R:142 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| diff_repayments.pdf | figure | data/raw/reference_outputs/figures/diff_repayments.pdf | repaymentrates.R | dataverse_files/Gertler. Green. and Wolfram/scripts/repaymentrates.R:142 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| IRRs_cdf.eps | figure | data/raw/reference_outputs/figures/IRRs_cdf.eps | rl6_loanlevelirr.m | dataverse_files/Gertler. Green. and Wolfram/scripts/rl6_loanlevelirr.m:382 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| IRRs_cdf.png | figure | data/raw/reference_outputs/figures/IRRs_cdf.png | rl6_loanlevelirr.m | dataverse_files/Gertler. Green. and Wolfram/scripts/rl6_loanlevelirr.m:381 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| IRRs_terciles.eps | figure | data/raw/reference_outputs/figures/IRRs_terciles.eps | rl6_loanlevelirr.m | dataverse_files/Gertler. Green. and Wolfram/scripts/rl6_loanlevelirr.m:310 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| IRRs_terciles.png | figure | data/raw/reference_outputs/figures/IRRs_terciles.png | rl6_loanlevelirr.m | dataverse_files/Gertler. Green. and Wolfram/scripts/rl6_loanlevelirr.m:309 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| loancompleteratesgrey.pdf | figure | data/raw/reference_outputs/figures/loancompleteratesgrey.pdf | completionrates.R | dataverse_files/Gertler. Green. and Wolfram/scripts/completionrates.R:114 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| repaymentratesgrey.pdf | figure | data/raw/reference_outputs/figures/repaymentratesgrey.pdf | repaymentrates.R | dataverse_files/Gertler. Green. and Wolfram/scripts/repaymentrates.R:114 | TBD | TBD | TBD | script-located | Output filename found in original script. |
| takeupbywtp_dif.png | figure | data/raw/reference_outputs/figures/takeupbywtp_dif.png | rl2_takeupbywtp.do | dataverse_files/Gertler. Green. and Wolfram/scripts/rl2_takeupbywtp.do:128 | TBD | TBD | TBD | script-located | Output filename found in original script. |
