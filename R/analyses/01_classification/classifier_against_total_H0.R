# script to get p-value against total H0

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
runs0 = 10000

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
  for (jj in 1:8) {
    # get truth
    inner_truths = c(inner_truths,as.character(get.truth()))
    # get response
    inner_resps  = c(inner_resps,as.numeric(randn(1,6)*10))
  }
  # 4
  for (jj in 9:10) {
    # get truth
    inner_truths = c(inner_truths,as.character(get.truth.4()))
    # get response
    inner_resps  = c(inner_resps,as.numeric(randn(1,8)*10))
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
# 200 is for MRI: no cleaning
# 201 is for MRI: cleaning with BIC criterion
# 202 is for MRI: cleaning with AIC criterion
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/201')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/202')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/45')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/46')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/200')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/50')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/51')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/54')
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/55')
e = new.env()
load('MRT_predGrp1_rounds_wio_onlyPhys_no_perm.RData',envir = e)

cur_fun_auc = function(x) {return(x$auc)}
cur_fun_acc = function(x) {return(x$acc$accuracy)}
cur_fun_sen = function(x) {return(x$acc$cur_sens)}
cur_fun_spe = function(x) {return(x$acc$cur_spec)}

auc         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_auc)))
acc         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_acc)))
sen         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_sen)))
spe         = mean(unlist(lapply(e$CV_res_list_op,FUN = cur_fun_spe)))

## density plots ==============================================================
# only auc but multiple classifiers
# old mean_auc = 0.6475 (where is this from)
#cur_dat_be = data.frame(H_0 = all_aucs,mean_auc = auc,classifier = 'prev_behav_glmnet')
cur_dat_gl = data.frame(H_0 = all_aucs,mean_auc = mean(auc),classifier = 'MRI_glmnet')
#cur_dat_sv = data.frame(H_0 = all_aucs,mean_auc = mean(real_aucs_svm),classifier = 'MRI_svm')

cur_dat              = rbind(cur_dat_gl) #rbind(cur_dat_be,cur_dat_gl,cur_dat_sv)
cur_dat              = melt(cur_dat,id.vars = c('classifier'))
cur_dat_H_0          = subset(cur_dat,variable == 'H_0')
cur_dat_H_0$mean_auc = cur_dat$value[cur_dat$variable == 'mean_auc']
cur_dat              = cur_dat_H_0
p = ggplot(cur_dat,aes(x=value, fill=variable)) + geom_density(alpha=0.25)
p = p + facet_grid(classifier ~ .) + ggtitle('AUC densities for different classifiers compared to random classifier')
p = p + geom_vline(aes(xintercept = mean_auc),colour = 'green',size= 1.5)
print(p)

## test glmnet
1-agk.density_p.c(all_aucs,auc)
1-agk.density_p.c(all_accs,acc)
1-agk.density_p.c(all_sens,sen)
1-agk.density_p.c(all_spec,spe)
