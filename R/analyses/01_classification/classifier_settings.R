## PREAMBLE ===================================================================
# script what to run, already set like in paper;
# tip: set runs to a smaller number than 1010 if you do not want to wait hours
# number of runs to get the CV results distribution, >=1000 recommended
# runs also will be the name of the results folder
# available results in results folder and their contents described further down
# for a result (try 10 for starters)

## WHAT TO RUN ================================================================
# just the behavioral parameter sets
outer_cv_noaddfeat      = 1 # with outer CV, getting generalization error, Ha
noout_cv_noaddfeat      = 1 # no outer CV, get complete model on whole sample

# # behavior plus peripheral-physiological stuff
# outer_cv_wiaddfeat      = 0 # adding physio, Ha
# noout_cv_wiaddfeat      = 0 # adding physio, get complete model
# 
# # only peripheral-physiological / MRI / rating (all saved under "phys")
outer_cv_addfeaton      = 0 # Ha only, i.e. physio/MRI  
noout_cv_addfeaton      = 0 # to get the complete model 

# control model
outer_cv_c_model        = 1 # control model/null-model for classification; predict with covariate
# not needed for MRI case (p-value comp in dfferent script, using random classification)

# what to report
do_report                 = 0
do_report_no_added_feat   = 0
#do_report_with_added_feat = 0
do_report_feat_only       = 0

# number of runs to get the CV results distribution, >=1000 recommended
# runs also will be the name of the results folder
# folder is described here:
# 300 : p. physio pred (PIT GD behav paper)
# 1010: behav predictions (PIT GD behav paper) (also 1009, repeat after ed fix (correctly aggregated at level 3)) 
# 1011: behav predictions (PIT GD behav paper) (NO within-z; class; cleaning AIC)
# 1012: behav predictions (PIT GD behav paper) (NO within-z; class; control)

# 1023: fMRI predictors with AIC cleaning
# 1024: fMRI predictor with BIC cleaning
# 1025: fMRI predictor with no cleaning
# 1000: fMRI against control model
# 15: kitchen sink model; all behav in (for paper review)
# 18: rating only as a "cue reactivity model only"
# 21: behav; NO within-z; class; cleaning AIC
# 22: behav; NO within-z; mse; cleaning AIC
# 24: behav; NO within-z; auc; no cleaning; control model instead with smoking
# 20: behav: no cleaning; ed: no aggregation; still on MRI application AUC = 0.64
# 21: behav: no cleaning; ed, gain, loss: no aggregation
# 22: MRI: no cleaning; ngm model
# 23: behav: no cleaning; ed, gain, loss: no aggregation (part b; then combine with # 21)
# 44: behav: no cleaning; ed, gain, loss: no aggregation (combination of 21 and 23; all in one file saved (noo file))
# 45: behav: no cleaning; ed, gain, loss: aggregation at level 2
# 1008: behav: no cleaning; ed, gain, loss: no aggregation
runs = 1

# advanced settings for other studies =========================================
# [cannot be used in PIT GD behav release] 
if (which_study == 'MRI') {
  # Any reporting of p-values against null? Set to F if you do that in a separate script.
  report_CV_p = T
} else {
  # Any reporting of p-values against null? Set to F if you do that in a separate script.
  report_CV_p = T
}

# no other features, only behavior
# master add cue reactivity: peripheral physiology or MRI
if (outer_cv_noaddfeat == T | noout_cv_noaddfeat == T | do_report_no_added_feat == T) {
  add_cr_pp_ma = F
} else {
  add_cr_pp_ma = T
}

# master add cue reactivity: ratings
# should never be done, cause ratings are post-experiment
add_cr_ra_ma         = F

