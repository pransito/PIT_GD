agk.pred.group.CV = function(outer_CV,do_permut,addfeat,add_cr_pp_ma,add_cr_ra_ma,des_seed,addfeat_only = F,c_mod=F) {
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
  #
  # addfeat_only: only added features, no behavior; is a special case, so it needs this variable
  #
  # c_mod: control model; e.g. running only on covariates of no-interest
  
  ## processing the inputs
  set.seed(des_seed)
  if(outer_CV) {
    CV        = 'wio'
    if (addfeat_only) {
      cur_title      = "Rounds outer and inner CV only physio, mri, or rating. Estimating generalization performance."
    } else {
      cur_title = "Rounds outer and inner CV. Estimating generalization performance."
    }
    
    if (c_mod) {
      cur_title   = "Rounds outer and inner CV. Control model."
    }
    
  } else {
    CV        = 'noo'
    cur_title = 'Rounds no outer CV. Estimating the complete model using nested CV.'
  }
  if (addfeat_only) {cur_title = paste(cur_title,'Everything but behavioral data.')}
  if (do_permut) {cur_title = paste(cur_title,'With permutations.')}
  
  # add cue reactivity predictors to full model: peripheral physiology
  # can be set to 0, if feature selection and adding should not be done on this
  add_cr_pp   = add_cr_pp_ma
  add_cr_ra   = add_cr_ra_ma
  # only physio,ratings,MRI?
  if(addfeat_only) {
    use_behav_params = F
  } else {
    use_behav_params = T
  }

  # old inputs (static)
  do_feat_sel = 0 # feature selection for MRI, rating, p.p.
  pred_grp    = 1 # we only do group prediction, so never change
  add_rt      = 0 # adding reaction time; experimental feature, not fully implemented
  
  # make file name for saving
  if(addfeat)      {afnm = 'wiaddfeat'} else {afnm = 'noaddfeat'}
  if(addfeat_only) {afnm = 'onlyPhys'}
  if(c_mod)        {afnm = 'conmod'}
  if(do_permut) {dpnm = 'wi_perm'} else {dpnm = 'no_perm'}
  svfnm = paste('_rounds',CV,afnm,dpnm,sep='_')
  
  ## initializations
  # run the models (for param extraction in exp)
  # TODO: can we turn this off?
  est_models  = 1
  # assign the variables created so far to global environment
  agk.assign.envtoenv(environment(),globalenv())
  # run the init (the CV of) group pred
  cur_res = agk.group.pred.init()
  agk.assign.envtoenv(cur_res,globalenv())
  # initialize where we will collect the results
  CV_res_list = list()
  if (CV == 'noo') {
    cur_mod_sel_nooCV           = c()
    list_winning_model_c_nooCV  = list()
    list_winning_model_l_nooCV  = list()
  }
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
    if (CV == 'noo') {
      cur_mod_sel_nooCV[hh] = cur_mod_sel_n
      
      # getting the complete final model's coefs
      full_mod_tmp = full_mod_cv[[1]]
      if (!is.numeric(full_mod_tmp)) {
        cur_labs = colnames(full_mod_tmp$coef)
        cur_labs = gsub(cur_labs,pattern="pred_",replacement="")
        cur_labs = gsub(cur_labs,pattern="(Intercept)",replacement="grp_classifier_intercept",fixed=T)
        cur_coef = full_mod_tmp$coef
      } else {
        cur_labs = names(full_mod_tmp)
        cur_coef = full_mod_tmp
      }
      
      # packing
      list_winning_model_c_nooCV[[hh]] = cur_coef
      list_winning_model_l_nooCV[[hh]] = cur_labs
      
    }
    curpbset(pb,hh, title=paste(cur_title, round(hh/runs*100),"% done"))
  }
  close(pb)
  
  # rename variables
  if (do_permut) {
    CVp_res_list = CV_res_list
    CV_res_list  = NULL
  }
  if (CV == 'noo') {
    CVnoo_res_list = CV_res_list
    CV_res_list    = NULL
  }
  if (c_mod) {
    CVcm_res_list = CV_res_list
    CV_res_list   = NULL
  }
  
  if (addfeat_only) {
    if (CV == 'noo') {
      CVnoo_res_list_op              = CV_res_list
      list_winning_model_c_nooCV_op  = list_winning_model_c_nooCV
      list_winning_model_l_nooCV_op  = list_winning_model_l_nooCV
      cur_mod_sel_nooCV_op           = cur_mod_sel_nooCV
      
      list_winning_model_c_nooCV     = NULL
      list_winning_model_l_nooCV     = NULL
      cur_mod_sel_nooCV              = NULL
    } else {
      if (do_permut == F) {
        CV_res_list_op = CV_res_list
      } else {
        CVp_res_list_op = CV_res_list
      }
    }
    CV_res_list                    = NULL
  }
  
  ## saving
  cur_home = getwd()
  dir.create(file.path(cur_home, paste0('results/',runs)),recursive=T)
  setwd(file.path(cur_home, paste0('results/',runs)))
  if (do_permut == F) {
    if (CV == 'wio') {
      if (addfeat_only) {
        cur_var_list = c('CV_res_list_op','fm','des_seed')
      } else {
        cur_var_list = c('CV_res_list','fm','des_seed')
      }
    } else if (CV == 'noo') {
      if (addfeat_only) {
        cur_var_list = c('list_winning_model_c_nooCV_op','list_winning_model_l_nooCV_op',
                         'CVnoo_res_list_op','fm','des_seed')
      } else {
        cur_var_list = c('list_winning_model_c_nooCV','list_winning_model_l_nooCV',
                         'CVnoo_res_list','cur_mod_sel_nooCV','fm','des_seed')
      }

    } else {
      stop('CV has unknown value.')
    }
    
    if (c_mod) {
      cur_var_list = c('CVcm_res_list','fm','des_seed')
    }
    
  } else if (do_permut == T) {
    if (addfeat_only) {
      cur_var_list = c('CVp_res_list_op','fm','des_seed')
    } else {
      cur_var_list = c('CVp_res_list','fm','des_seed')
    }
  } else {
    stop('do_permut has unknown value')
  }
  save(file = paste0(which_study,'_predGrp',pred_grp,svfnm,'.RData'),
       list = cur_var_list)
  setwd(cur_home)
}
