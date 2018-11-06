agk.pred.group.CV = function(outer_CV,do_permut,addfeat,add_cr_pp_ma,add_cr_pp_ma,des_seed) {
  # wrapper function to run the CV loop
  #
  # outer_CV: if yes then algorithm is cross-validated and all other CV is nested
  # good for estimating the generalization performance
  # if no, then good for estimating final model
  #
  # do_permut: legacy, should always be 0
  # permutation is very slow and technically needs to be done for each round a large
  # amount of times; gets infeasable; instead we are
  # using a control model (e.g. an empty model, i.e. random classification
  # or a model with just covariate as predictor)
  # that we can easily and quickly run with the same N and balanced labels as
  # our original data but for many thousand times to get a distribution under H0
  #
  # addfeat: should any features be added to the behavioral data (physiology, MRI, ratings)
  #
  # add_cr_pp_ma: for addfeat, should peripheral-physiology be added?
  #
  # add_cr_pp_ma: should ratings be added?
  # 
  # des_seed: a seed (some integer); keep constant to make results reproducible
  
  ## processing the inputs
  set.seed(des_seed)
  if(outer_CV) {
    CV        = 'wio'
    cur_title = "Rounds outer and inner CV. Estimating generalization performance."
  } else {
    cur_title = 'Rounds no outer CV. Estimating the complete model using nested CV.'
  }
  if (do_permut) {cur_title = paste(cur_title,'With permutations.')}
  
  # add cue reactivity predictors to full model: peripheral physiology
  # can be set to 0, if feature selection and adding should not be done on this
  if (outer_cv_wiaddfeat_noperm) {
    add_cr_pp   = add_cr_pp_ma
    add_cr_ra   = add_cr_ra_ma
  } else {
    add_cr_pp   = 0
    add_cr_ra   = 0
  }
  
  # old inputs (static)
  do_feat_sel = 0
  pred_grp    = 1
  
  # make file name for saving
  if(addfeat)   {afnm = 'wiaddfeat'} else {afnm = 'noaddfeat'}
  if(do_permut) {dpnm = 'wi_perm'} else {dpnm = 'no_perm'}
  svfnm = paste('_rounds',CV,afnm,dpnm,sep='_')
  
  ## initializations
  # run the models (for param extraction in exp)
  # TODO: can we turn this off?
  est_models  = 1
  # run the init (the CV of) group pred
  source('group_pred_init_v6.R')
  CV_res_list = list()
  # prep progress bar
  pb = curpbfun(title = cur_title, min = 0,max = runs, width = box_width)
  
  # OLD
  #list_winning_model = list()
  #cur_mod_sel_vec    = c()
  # OLD
  
  ## run the loop for (outer) CV
  for(hh in 1:runs) {
    source('group_pred_6_wioCV.R')
    CV_res_list[[hh]]        = CV_res
    curpbset(pb,hh, title=paste(cur_title, round(hh/runs*100),"% done"))
  }
  close(pb)
  # rename variable
  if (do_permut) {
    CVp_res_list = CV_res_list
    CV_res_list  = NULL
  }
  
  ## saving
  cur_home = getwd()
  dir.create(file.path(cur_home, paste0('results/',runs)),recursive=T)
  setwd(file.path(cur_home, paste0('results/',runs)))
  if (do_permut == F) {
    save(file = paste0(which_study,'_predGrp',pred_grp,svfnm,'.RData'),
         list = c('CV_res_list','fm','des_seed'))
  } else {
    save(file = paste0(which_study,'_predGrp',pred_grp,svfnm,'.RData'),
         list = c('CVp_res_list','fm','des_seed'))
  }
  setwd(cur_home)
}


