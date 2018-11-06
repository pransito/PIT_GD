## PREAMBLE =====================================================================
# script to get p-value against total H0

# YOU HAVE TO run the group_pred_loop_v6.R script once with these settings:

# # WHAT TO RUN =================================================================
# # just the behavioral parameter sets
# outer_cv_noaddfeat_noperm = 0 # with outer CV, getting generalization error
# outer_cv_noaddfeat_wiperm = 0 # with permutation [not recommended*]
# noout_cv_noaddfeat_noperm = 0 # no outer CV, get class on whole sample
# 
# # behavior plus peripheral-physiological stuff
# outer_cv_wiaddfeat_noperm = 0 # adding physio
# outer_cv_addfeaton_wiperm = 0 # with permutation [not recommended*]
# noout_cv_wiaddfeat_noperm = 0 # adding physio
# 
# # only peripheral-physiological / MRI
# outer_cv_addfeaton_noperm = 0 # Ha only, i.e. physio/MRI  
# outer_cv_addfeaton_wiperm = 0 # with permutation [not recommended*]
# noout_cv_addfeaton_noperm = 0 # to get the complete model 
# 
# outer_cv_c_model_noperm   = 0 # control model/null-model for classification;
# # not needed for MRI case (p-value comp in dfferent script)
# 
# # what to report
# do_report                 = 0
# do_report_no_added_feat   = 0
# do_report_with_added_feat = 0
# do_report_feat_only       = 0


## SCRIPT STARTS ==============================================================
# load libraries
agk.load.ifnot.install('Matching')

# functions
get.truth = function() {
  sample(c(rep('HC',3),rep('PG',3)))
}

get.truth.4 = function() {
  sample(c(rep('HC',4),rep('PG',4)))
}

# set runs
runs0 = 1000

# under 0
# pooled
all_aucs  = c()
all_aucsl = list()
all_accs  = c()
all_accsl = list()
all_sens  = c()
all_spec  = c()
for (ii in 1:runs0) {
  print(ii)
  inner_truths = c()
  inner_resps  = c()
  # 3
  for (jj in 1:10) {
    # get truth
    inner_truths = c(inner_truths,as.character(get.truth()))
    # get response
    inner_resps  = c(inner_resps,as.numeric(randn(1,6)*10))
  }
  
  # cur_auc
  cur_roc         = roc(inner_truths,inner_resps)
  all_aucs[ii]    = cur_roc$auc
  all_aucsl[[ii]] = cur_roc
  
  # accuracy
  inner_preds     = ifelse(inner_resps<0,'HC','PG')
  all_accsl[[ii]] = inner_truths == inner_preds
  all_accs[ii]    = mean(all_accsl[[ii]])
  
  # sens and spec
  cur_cm = caret::confusionMatrix(table(inner_truths,inner_preds))
  all_sens[ii]    = cur_cm$byClass[1]
  all_spec[ii]    = cur_cm$byClass[2]
}

## get the auc, acc, sens, spec ===============================================
# setting the path to the result folder wil result in the followin result evaluation
# 1023: fMRI predictors with AIC cleaning
# 1024: fMRI predictor with BIC cleaning
# 1025: fMRI predictor with no cleaning
setwd(paste0(root_wd, '/results/1011'))
e = new.env()
#load('MRT_predGrp1_rounds_wio_onlyPhys_no_perm.RData',envir = e)
load('POSTPILOT_HCPG_predGrp1_rounds_wio_noaddfeat_no_perm.RData',envir = e)
e$CV_res_list_op = e$CV_res_list


cur_fun_auc = function(x) {return(x$auc)}
cur_fun_acc = function(x) {return(x$acc$accuracy)}
cur_fun_sen = function(x) {return(x$acc$cur_sens)}
cur_fun_spe = function(x) {return(x$acc$cur_spec)}
# add precision

auc         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_auc)))
acc         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_acc)))
sen         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_sen)))
spe         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_spe)))

## density plots ==============================================================
# only auc will be plotted cause it is the most informative performance measure
# only H0 and mean AUC of classifier performance will be plotted
cur_dat_gl           = data.frame(H_0 = all_aucs,mean_auc = mean(auc),classifier = 'MRI_glmnet')
cur_dat              = rbind(cur_dat_gl) #rbind(cur_dat_be,cur_dat_gl,cur_dat_sv)
cur_dat              = melt(cur_dat,id.vars = c('classifier'))
cur_dat_H_0          = subset(cur_dat,variable == 'H_0')
cur_dat_H_0$mean_auc = cur_dat$value[cur_dat$variable == 'mean_auc']
cur_dat              = cur_dat_H_0

# plot
p = ggplot(cur_dat,aes(x=value, fill=variable)) + geom_density(alpha=0.25)
p = p + facet_grid(classifier ~ .) + ggtitle('AUC densities for different classifiers compared to random classifier')
p = p + geom_vline(aes(xintercept = mean_auc),colour = 'green',size= 1.5)
print(p)

## density plots with two densities ============================================
# plots also the density of the performance of the classifier
Ha_auc               = unlist(lapply(e$CV_res_list_op,FUN = cur_fun_auc))
Ha_auc               = rep_len(Ha_auc,length.out = length(all_aucs))
cur_dat_gl           = data.frame(H0 = all_aucs,Ha_auc = Ha_auc,classifier = 'MRI_glmnet')
cur_dat              = rbind(cur_dat_gl) #rbind(cur_dat_be,cur_dat_gl,cur_dat_sv)
cur_dat              = melt(cur_dat,id.vars = c('classifier'))

# plot
p = ggplot(cur_dat,aes(x=value, fill=variable)) + geom_density(alpha=0.25)
p = p + facet_grid(classifier ~ .) + ggtitle('AUC densities for MRI glmnet classifier compared to random classifier')
p = p + geom_vline(aes(xintercept = mean(auc)),colour = 'green',size= 1.5)
print(p+theme_bw())

## p-values test glmnet
message('The values and p-values for fMRI classifier for AUC, accuracy, sensitivity, specificity are:')
message(' ')
message(auc)
message(1-agk.density_p.c(all_aucs,auc))
message(' ')
message(acc)
message(1-agk.density_p.c(all_accs,acc))
message(' ')
message(sen)
message(1-agk.density_p.c(all_sens,sen))
message(' ')
message(spe)
message(1-agk.density_p.c(all_spec,spe))

