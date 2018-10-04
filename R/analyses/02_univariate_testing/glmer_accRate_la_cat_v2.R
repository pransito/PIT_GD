## PREAMBLE ===================================================================
# univariate tests; classical group-mean-differences tests/mixed ANOVAs
# script to describe acceptance rate
# script to fit glmer models to answer questions on acceptance rate,
# loss aversion, effects of category and group
# model comparison to get significance of overall effect of e.g. group or category
# fixed effects of parameters and CIs will be based on bootstrapping non-parametrically
# the fixed effects
# permutation test to get p-value for parameters

# BEFORE RUNNING THIS SCRIPT
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


## SETTINGS ===================================================================
# control object for the glmer fitting
cur_control = glmerControl(check.conv.grad="ignore",
                           check.conv.singular="ignore",
                           check.conv.hess="ignore",
                           optCtrl=list(optimizer = "nloptwrap",maxfun=250))
# do the boot / permutation test or just load prepared results?
# attention: it takes over an hours to run the permuation test for loss aversion group comparison
doBootPerm = 0
# wd for saving the results of the bootstraps
setwd(root_wd)
setwd('..')
setwd('02_univariate_testing/results/effects_under_0_la')
if (which_study == 'MRT') {
  cd('MRI')
} else if (which_study == 'POSTPILOT_HCPG') {
  cd('behav')
} else {
  stop('which_study is set to an unknown value!')
}
bootResWd = getwd()
# how many bootstraps/permutations?
cur_num   = 300
# how many cpus to use?
cur_cpus  = detectCores()-1
# fit glmer models?
# careful this takes on an intel core i7 with 8GB RAM about 10 minutes
doFitGlmer = 1

## PROCESS SETTINGS ===========================================================
message_fixef_setting =  function(put_in_original_fe) {
  if (put_in_original_fe) {
    message('using original fixef values for plotting and as estimates of fixef')
  } else {
    message('using mean of bootstrap instead of fixef values as means and as estimates of fixef')
  }
}
message_fixef_setting(put_in_original_fe)


## glmer models acceptance rate ===============================================
if (doFitGlmer) {
  moda_00  = glmer(accept_reject ~ 1 + (1|subject) + (1|stim) + (1|cat),data = data_pdt,family = 'binomial')
  moda_01  = glmer(accept_reject ~ cat + (cat|subject) + (1|stim),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  moda_02  = glmer(accept_reject ~ cat*HCPG + (cat|subject) + (1|stim),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  moda_01b = glmer(accept_reject ~ HCPG + (1|subject) + (1|stim) + (1|cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
}

## glmer models la ============================================================
if (doFitGlmer) {
  modla_00  = glmer(accept_reject ~ 1 + (1|subject) + (1|stim) + (1|cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_01  = glmer(accept_reject ~ gain + loss  + (gain + loss |subject) + (gain + loss |stim) + (gain + loss |cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_0g  = glmer(accept_reject ~ (gain + loss )*HCPG + (gain + loss |subject) + (gain + loss |stim)  + (gain + loss |cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_c0  = glmer(accept_reject ~ (gain + loss ) + cat + (gain + loss + cat|subject) + (gain + loss |stim) + (gain + loss |cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_cg  = glmer(accept_reject ~ (gain + loss )*HCPG + cat*HCPG + (gain + loss + cat |subject) + (gain + loss |stim)  + (gain + loss |cat),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_cgi = glmer(accept_reject ~ (gain + loss )*cat*HCPG + ((gain + loss )*cat|subject) + (gain + loss |stim),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
  modla_ci  = glmer(accept_reject ~ (gain + loss )*cat + ((gain + loss )*cat|subject) + (gain + loss |stim),data = data_pdt,family = 'binomial',nAGQ = 0,control=cur_control)
}

## check model fit per subject
cur_dp         = modla_cg@frame
cur_dp$pred_00 = as.numeric(as.numeric(predict(modla_00) >= 0) == cur_dp$accept_reject)
cur_dp$pred_cg = as.numeric(as.numeric(predict(modla_cg) >= 0) == cur_dp$accept_reject)
dens_df        = aggregate(cbind(pred_00,pred_cg) ~ subject + HCPG, data = cur_dp, FUN = mean)
message('The model modla_cg makes better predictions than modla_00 in ...')
message(' ')
message(mean(dens_df$pred_cg > dens_df$pred_00)*100)
message(' ')
message('... percent subjects.')

## acceptance rate and under different cue conditions #########################
# acceptance rate graph, descriptives (CIs over subjects; better SD?)
mod_acc        = aggregate(as.numeric(as.character(data_pdt$accept_reject)),by=list(data_pdt$subject,data_pdt$cat), FUN=mean.rmna)
names(mod_acc) = c('subject','category','mean_acceptance')
mod_acc$Group  = agk.recode.c(mod_acc$subject,dat_match$VPPG,dat_match$HCPG)
mod_acc        = aggregate(mod_acc$mean_acceptance,by=list(mod_acc$Group,mod_acc$cat),FUN=agk.boot.ci,R=2000,lower=0.025,upper=0.975,cur_fun=mean)
mod_acc        = data.frame(mod_acc[[1]], mod_acc[[2]],mod_acc[[3]])
names(mod_acc) = c('Group','category','mean_acceptance','ci_0025','ci_0975')
mod_acc$Group  = agk.recode.c(mod_acc$Group,'PG','GD')

mRat  = ggplot(mod_acc, aes(category, mean_acceptance,fill=Group))
mRat  = mRat + labs(x='category', y=paste('Mean of acceptance (',0.95*100,'% CI, bootstrapped)'))
mRat  = mRat + ggtitle("Mean acceptance across categories")
mRat  = mRat + geom_bar(position="dodge", stat="identity")
dodge = position_dodge(width=0.9)
mRat  = mRat + geom_bar(position=dodge, stat="identity")
mRat  = mRat + geom_errorbar(aes(ymin = ci_0025, ymax = ci_0975), position=dodge, width=0.25) + theme_bw()
print(mRat)

# acceptance rate only between group
mod_accnc        = aggregate(as.numeric(as.character(data_pdt$accept_reject)),by=list(data_pdt$subject), FUN=mean.rmna)
names(mod_accnc) = c('subject','mean_acceptance')
mod_accnc$Group  = agk.recode.c(mod_accnc$subject,dat_match$VPPG,dat_match$HCPG)
mod_accnc        = aggregate(mod_accnc$mean_acceptance,by=list(mod_accnc$Group),FUN=agk.boot.ci,R=2000,lower=0.025,upper=0.975,cur_fun=mean)
mod_accnc        = data.frame(mod_accnc[[1]],mod_accnc[[2]])
names(mod_accnc) = c('Group','mean_acceptance','ci_0025','ci_0975')
mod_accnc$Group  = agk.recode.c(mod_accnc$Group,'PG','GD')

# stats
anova(moda_00,moda_01,moda_02)

# stats without cat (simple acceptance rate difference between groups)
anova(moda_00,moda_01b)

## loss aversion (la) overall and group comparison ############################
# stats glmer
anova(modla_00,modla_01,modla_0g,modla_cg,modla_cgi)
anova(modla_00,modla_01,modla_0g)

# permutation tests of single parameters
if (doBootPerm) {
  setwd(bootResWd)
  
  fun_extr = function(cur_mod) {
    ## extraction function to return fixeffect and mse
    cur_fe  = fixef(cur_mod)
    cur_mse = mean((1/(1+exp(-predict(cur_mod)))-as.numeric(as.character(cur_mod@frame$accept_reject)))^2)
    cur_fe  = c(cur_fe,cur_mse)
    names(cur_fe)[length(cur_fe)] = 'mse'
    return(cur_fe)
  }
  
  # PERMUTATION TESTS
  # bootstrap p-value modla_0g (permutation)
  effects_under_0_0g = agk.boot.p.mermod(mermod = modla_0g,mermod0 = modla_01,num_cpus = cur_cpus,num = cur_num,fun_extract = fun_extr,cur_control = cur_control,permvars = c('HCPG'),type='perm')
  save(file= 'effects_under_0_0g_perm_1000_wc.RData',list=c('effects_under_0_0g'))
}

# just la and using the fixef of the model
setwd(bootResWd)
load('effects_under_0_0g_perm_1000_wc.RData')
la_HC     = -bl_HC/bg_HC
la_PG     = -bl_PG/bg_PG
la_HCgrPG = la_HC-la_PG 
obs_e     = get_la_fixef_pdt(modla_0g)
message('P-value that loss aversion coefficient is different between HC and GD (two-sided test):')
message(agk.density_p(la_HCgrPG,obs_e['x_la_HCgrPG'],type = 'two.sided'))

# overall permuation test; is the MSE of modla_0g better than the permuted version of modla_0g?
message('overall permuation test; is the MSE of modla_0g better than the permuted version of modla_0g?')
message((paste('p-value ofermutation test group for:','mse')))
mse_a = mean((1/(1+exp(-predict(modla_0g)))-as.numeric(as.character(modla_0g@frame$accept_reject)))^2)
message(' ')
message((agk.density_p(mse,mse_a)))