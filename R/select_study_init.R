## initialization settings [DEFAULT, DO NOT CHANGE] ===========================
# just the behavioral parameter sets
outer_cv_noaddfeat      = 0 # with outer CV, getting generalization error, Ha
noout_cv_noaddfeat      = 0 # no outer CV, get complete model on whole sample

# behavior plus peripheral-physiological stuff
outer_cv_wiaddfeat      = 0 # adding physio, Ha
noout_cv_wiaddfeat      = 0 # adding physio, get complete model

# only peripheral-physiological / MRI / rating (all saved under "phys")
outer_cv_addfeaton      = 0 # Ha only, i.e. physio/MRI  
noout_cv_addfeaton      = 0 # to get the complete model 

# control model
outer_cv_c_model        = 0 # control model/null-model for classification; predict with covariate
# not needed for MRI case (p-value comp in dfferent script, using random classification)

# what to report
do_report                 = 0
do_report_no_added_feat   = 0
do_report_with_added_feat = 0
do_report_feat_only       = 0

if (which_study == 'MRI') {
  # Any reporting of p-values against null? Set to F if you do that in a separate script.
  report_CV_p = T
} else {
  # Any reporting of p-values against null? Set to F if you do that in a separate script.
  report_CV_p = F
}

# no other features, only behavior
# master add cue reactivity: peripheral physiology or MRI
add_cr_pp_ma         = F
# master add cue reactivity: ratings
# should never be done, cause ratings are post-experiment
add_cr_ra_ma         = F

