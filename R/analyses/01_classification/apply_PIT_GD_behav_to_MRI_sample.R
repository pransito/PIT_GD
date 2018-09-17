# script to apply PIT_GD_behav classifier to MRI data
# which_study must be MRT
# pred_loop must be run with everything set to 0 so that only init runs

# load libraries
agk.load.ifnot.install('Matching')

# functions
get.truth = function() {
  sample(c(rep('HC',3),rep('PG',3)))
}

get.truth.4 = function() {
  sample(c(rep('HC',4),rep('PG',4)))
}

get.truth.2 = function() {
  sample(c(rep('HC',2),rep('PG',2)))
}


# set runs
runs0 = 4000

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
  # # 4
  # for (jj in 9:9) {
  #   # get truth
  #   inner_truths = c(inner_truths,as.character(get.truth.4()))
  #   # get response
  #   inner_resps  = c(inner_resps,as.numeric(randn(1,8)*10))
  # }
  # 2
  # for (jj in 9:9) {
  #   # get truth
  #   inner_truths = c(inner_truths,as.character(get.truth.4()))
  #   # get response
  #   inner_resps  = c(inner_resps,as.numeric(randn(1,8)*10))
  # }
  
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

## use a weighted mean model from PDT behav ===================================
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
load('POSTPILOT_HCPG_predGrp1_rounds_noo_noaddfeat.RData')

# get the weights
mod_weights = as.matrix(table(cur_mod_sel_nooCV))
mod_weights = mod_weights/sum(mod_weights)
win_mods    = row.names(mod_weights)

# winning model beta values
mean_PP_mod = list()
for (mm in 1:length(win_mods)) {
  winning_mod = win_mods[mm]
  win_mods_distr_c = list_winning_model_c_nooCV[which(winning_mod == cur_mod_sel_nooCV)]
  win_mods_distr_l = list_winning_model_l_nooCV[which(winning_mod == cur_mod_sel_nooCV)]
  
  # make a data frame of it:
  win_mod_coefs        = as.matrix(win_mods_distr_c[[1]])
  win_mod_coefs        = as.data.frame(t(win_mod_coefs))
  names(win_mod_coefs) = win_mods_distr_l[[1]]
  
  for (ii in 2:length(win_mods_distr_c)) {
    cur_win_mod_coefs        = as.matrix(t(win_mods_distr_c[[ii]]))
    cur_win_mod_coefs        = as.data.frame(cur_win_mod_coefs)
    names(cur_win_mod_coefs) = win_mods_distr_l[[ii]]
    win_mod_coefs = rbind.fill(win_mod_coefs,cur_win_mod_coefs)
  }
  #imp_0 = function(x) {x[is.na(x)] = 0; return(x)}
  #win_mod_coefs = as.data.frame(lapply(win_mod_coefs,FUN=imp_0))
  mean_PP_mod[[mm]] = colMeans(as.matrix(win_mod_coefs))
}

# get the standardization
message('The application of standardization from POSTPILOT needs to be seamless!')
# # first load postpilot data [prep for publication a new workspace]
# setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
# win_mods = agk.recode(win_mods,c('acc'),c('ac'))
# for (mm in 1:length(win_mods)) {
#   pp_b_dat = featmod_coefs[[win_mods[mm]]]
#   pp_b_dat = pp_b_dat[,grep('HCPG',names(pp_b_dat),invert=TRUE)]
#   pp_b_dat = data.frame(pp_b_dat,pred_smoking_ftdt=dat_match$smoking_ftdt)
#   pp_b_dat = scale(pp_b_dat)
#   save(pp_b_dat, file=paste0('POSTPILOT_',win_mods[mm],'_stand.RData'))
# }

# apply the standardization and get decision value
win_mods    = agk.recode(win_mods,c('acc'),c('ac'))
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
responses = list()
for (mm in 1:length(win_mods)) {
  
  load(paste0('POSTPILOT_', win_mods[mm],'_stand.RData'))
  pp_scale = attributes(pp_b_dat)
  
  mr_b_dat = featmod_coefs[[win_mods[mm]]]
  mr_b_dat = mr_b_dat[,grep('HCPG',names(mr_b_dat),invert=T)]
  mr_b_dat = data.frame(mr_b_dat,pred_smoking_ftdt = dat_match$smoking_ftdt)
  mr_b_dat = scale(mr_b_dat,center = pp_scale$`scaled:center`, scale = pp_scale$`scaled:scale`)
  mr_b_dat = data.frame(ones(length(mr_b_dat[,1]),1),mr_b_dat)
  
  # prediction
  responses[[mm]] = t(as.matrix(mean_PP_mod[[mm]])) %*% t(as.matrix(mr_b_dat))
}

# consensus (weighted sum of decision values)
weighted_responses = mod_weights[1]*responses[[1]]
for (mm in 2:length(win_mods)) {
  weighted_responses = weighted_responses + mod_weights[mm]*responses[[mm]]
}
preds     = ifelse(weighted_responses <= 0, 'HC','PG')

acc = mean(preds == dat_match$HCPG)
roc = pROC::roc(dat_match$HCPG,predictor=weighted_responses)
auc = roc$auc
cm  = confusionMatrix(as.factor(preds),dat_match$HCPG)
sen = cm$byClass[1]
spe = cm$byClass[2]

# test
1-agk.density_p.c(all_accs,acc)
1-agk.density_p.c(all_aucs,auc)
1-agk.density_p.c(all_sens,sen)
1-agk.density_p.c(all_spec,spe)

# weighted models auc
weighted_mod_mean_auc = auc

## use just the winning model mean model ======================================
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
load('POSTPILOT_HCPG_predGrp1_rounds_noo_noaddfeat.RData')

# get the weights
mod_weights = as.matrix(table(cur_mod_sel_nooCV))
mod_weights = mod_weights/sum(mod_weights)
win_mods    = row.names(mod_weights)

# winning model beta values
mean_PP_mod = list()
for (mm in 1:length(win_mods)) {
  winning_mod = win_mods[mm]
  win_mods_distr_c = list_winning_model_c_nooCV[which(winning_mod == cur_mod_sel_nooCV)]
  win_mods_distr_l = list_winning_model_l_nooCV[which(winning_mod == cur_mod_sel_nooCV)]
  
  # make a data frame of it:
  win_mod_coefs        = as.matrix(win_mods_distr_c[[1]])
  win_mod_coefs        = as.data.frame(t(win_mod_coefs))
  names(win_mod_coefs) = win_mods_distr_l[[1]]
  
  for (ii in 2:length(win_mods_distr_c)) {
    cur_win_mod_coefs        = as.matrix(t(win_mods_distr_c[[ii]]))
    cur_win_mod_coefs        = as.data.frame(cur_win_mod_coefs)
    names(cur_win_mod_coefs) = win_mods_distr_l[[ii]]
    win_mod_coefs = rbind.fill(win_mod_coefs,cur_win_mod_coefs)
  }
  #imp_0 = function(x) {x[is.na(x)] = 0; return(x)}
  #win_mod_coefs = as.data.frame(lapply(win_mod_coefs,FUN=imp_0))
  mean_PP_mod[[mm]] = colMeans(as.matrix(win_mod_coefs))
}

# use just the first model (the winning model) hard coded
mean_PP_mod = mean_PP_mod[1]
win_mods    = win_mods[1]

# get the standardization
message('The application of standardization from POSTPILOT needs to be seamless!')
# # first load postpilot data [prep for publication a new workspace]
# setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
# win_mods = agk.recode(win_mods,c('acc'),c('ac'))
# for (mm in 1:length(win_mods)) {
#   pp_b_dat = featmod_coefs[[win_mods[mm]]]
#   pp_b_dat = pp_b_dat[,grep('HCPG',names(pp_b_dat),invert=TRUE)]
#   pp_b_dat = data.frame(pp_b_dat,pred_smoking_ftdt=dat_match$smoking_ftdt)
#   pp_b_dat = scale(pp_b_dat)
#   save(pp_b_dat, file=paste0('POSTPILOT_',win_mods[mm],'_stand.RData'))
# }

# apply the standardization and get decision value
win_mods    = agk.recode(win_mods,c('acc'),c('ac'))
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
responses = list()
for (mm in 1:length(win_mods)) {
  
  load(paste0('POSTPILOT_', win_mods[mm],'_stand.RData'))
  pp_scale = attributes(pp_b_dat)
  
  mr_b_dat = featmod_coefs[[win_mods[mm]]]
  mr_b_dat = mr_b_dat[,grep('HCPG',names(mr_b_dat),invert=T)]
  mr_b_dat = data.frame(mr_b_dat,pred_smoking_ftdt = dat_match$smoking_ftdt)
  mr_b_dat = scale(mr_b_dat,center = pp_scale$`scaled:center`, scale = pp_scale$`scaled:scale`)
  mr_b_dat = data.frame(ones(length(mr_b_dat[,1]),1),mr_b_dat)
  
  # prediction
  responses[[mm]] = t(as.matrix(mean_PP_mod[[mm]])) %*% t(as.matrix(mr_b_dat))
}

# consensus (weighted sum of decision values)
weighted_responses = mod_weights[1]*responses[[1]]
preds     = ifelse(weighted_responses <= 0, 'HC','PG')

acc = mean(preds == dat_match$HCPG)
roc = pROC::roc(dat_match$HCPG,predictor=weighted_responses)
auc = roc$auc
cm  = confusionMatrix(as.factor(preds),dat_match$HCPG)
sen = cm$byClass[1]
spe = cm$byClass[2]

# test
1-agk.density_p.c(all_accs,acc)
1-agk.density_p.c(all_aucs,auc)
1-agk.density_p.c(all_sens,sen)
1-agk.density_p.c(all_spec,spe)

# weighted models auc
weighted_mod_mean_auc = auc

## use a consensus of ALL models from PDT behav ===============================
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
load('POSTPILOT_HCPG_predGrp1_rounds_noo_noaddfeat.RData')

# predict with each model
responses = list()
cur_mod_sel_nooCV = agk.recode(cur_mod_sel_nooCV,c('acc'),c('ac'))
for (mm in 1:length(list_winning_model_c_nooCV)) {
  cur_c = list_winning_model_c_nooCV[[mm]]
  cur_l = list_winning_model_l_nooCV[[mm]]
  cur_m = cur_mod_sel_nooCV[mm]
  
  # apply the standardization and get decision value
  setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification/results/1010')
  
  load(paste0('POSTPILOT_', cur_m,'_stand.RData'))
  pp_scale = attributes(pp_b_dat)
  
  mr_b_dat = featmod_coefs[[cur_m]]
  mr_b_dat = mr_b_dat[,grep('HCPG',names(mr_b_dat),invert=T)]
  mr_b_dat = data.frame(mr_b_dat,pred_smoking_ftdt = dat_match$smoking_ftdt)
  mr_b_dat = scale(mr_b_dat,center = pp_scale$`scaled:center`, scale = pp_scale$`scaled:scale`)
  mr_b_dat = data.frame(ones(length(mr_b_dat[,1]),1),mr_b_dat)
  
  # prediction
  responses[[mm]] = t(as.matrix(cur_c)) %*% t(as.matrix(mr_b_dat))
}

# consensus (weighted sum of decision values)
weighted_responses = responses[[1]]
for (mm in 2:length(responses)) {
  weighted_responses = weighted_responses + responses[[mm]]
}
preds     = ifelse(weighted_responses <= 0, 'HC','PG')

acc = mean(preds == dat_match$HCPG)
roc = pROC::roc(dat_match$HCPG,predictor=weighted_responses)
auc = roc$auc
cm  = confusionMatrix(as.factor(preds),dat_match$HCPG)
sen = cm$byClass[1]
spe = cm$byClass[2]

# test
1-agk.density_p.c(all_accs,acc)
1-agk.density_p.c(all_aucs,auc)
1-agk.density_p.c(all_sens,sen)
1-agk.density_p.c(all_spec,spe)

# weighted models auc
all_mod_mean_auc = auc

## density plots ==============================================================
# only auc but multiple classifiers
# old mean_auc = 0.6475 (where is this from)
cur_dat_be = data.frame(H_0 = all_aucs,mean_auc = mean(weighted_mod_mean_auc),classifier = 'prev_behav_glmnet')
#cur_dat_gl = data.frame(H_0 = all_aucs,mean_auc = mean(real_aucs_glmnet),classifier = 'MRI_glmnet')
#cur_dat_sv = data.frame(H_0 = all_aucs,mean_auc = mean(real_aucs_svm),classifier = 'MRI_svm')

cur_dat              = rbind(cur_dat_be) #,cur_dat_gl,cur_dat_sv)
cur_dat              = melt(cur_dat,id.vars = c('classifier'))
cur_dat_H_0          = subset(cur_dat,variable == 'H_0')
cur_dat_H_0$mean_auc = cur_dat$value[cur_dat$variable == 'mean_auc']
cur_dat              = cur_dat_H_0
p = ggplot(cur_dat,aes(x=value, fill=variable)) + geom_density(alpha=0.25)
p = p + facet_grid(classifier ~ .) + ggtitle('AUC densities for different classifiers compared to random classifier')
p = p + geom_vline(aes(xintercept = mean_auc),colour = 'green',size= 1.5)
print(p)

## test glmnet and SVM
# glmnet
1-agk.density_p.c(all_aucs,mean(real_aucs_glmnet))
1-agk.density_p.c(all_aucs,mean(real__glmnet))
1-agk.density_p.c(all_aucs,mean(real_aucs_glmnet))
1-agk.density_p.c(all_aucs,mean(real_aucs_glmnet))
1-agk.density_p.c(all_aucs,mean(real_aucs_svm))