## PREAMBLE
# ...

## Plots means and CIs of physio variables (stim)==============================
if (which_study != 'MRI') {
  # means and CIs
  des_vars = c('zygo_auc','corr_auc','SCR')
  
  if (plot_physio) {
    cfint_list = list()
    for (ii in 1:length(des_vars)) {
      
      cur_form = as.formula(paste(des_vars[ii],'~ cat | subject'))
      cur_lml  = lmList(cur_form,data = data_pdt)
      cur_lml  = coef(cur_lml)
      cur_lml  = cur_lml[-which(names(cur_lml) == '(Intercept)')]
      cur_lml  = melt(cur_lml)
      
      cur_form = as.formula('value ~ variable')
      cfint = aggregate(cur_form,data = cur_lml,FUN=agk.boot.ci,
                        cur_fun = mean,lower=0.025, upper=0.975,R=5000)
      
      cfint = as.data.frame(cbind(cfint[c('variable')],cfint[[2]]))
      names(cfint)[c(2:4)] = c('mean','lower','upper')
      cfint$channel    = des_vars[ii]
      cfint_list[[ii]] = cfint
    }
    cfint = cfint_list[[1]]
    for(ii in 2:length(cfint_list)) {
      cfint = rbind(cfint,cfint_list[[ii]])
    }
    
    # plotting (faceting by category)
    mRat  = ggplot(cfint, aes(variable, mean))
    mRat  = mRat + labs(x='category', y=paste('Mean (',0.95*100,'% CI, bootstrapped)'))
    mRat  = mRat + ggtitle("Physio reactions to different categories of stimuli (cue only phase)")
    mRat  = mRat + geom_bar(position="dodge", stat="identity")
    dodge = position_dodge(width=0.9)
    mRat  = mRat + geom_bar(position=dodge, stat="identity")
    mRat  = mRat + geom_errorbar(aes(ymin = lower, ymax = upper), position=dodge, width=0.25) 
    mRat  = mRat + facet_grid(channel ~ .)
    mRatg = mRat + theme_bw()
    print(mRatg)
    
    # interaction cue reactivity*group
    cfint_list = list()
    lmlcf      = list()
    for (ii in 1:length(des_vars)) {
      cur_form        = as.formula(paste(des_vars[ii],'~ cat | subject'))
      cur_lml         = lmList(cur_form,data = data_pdt)
      cur_lml         = coef(cur_lml)
      lmlcf[[ii]]     = cur_lml
      cur_lml         = cur_lml[-which(names(cur_lml) == '(Intercept)')]
      cur_lml$HCPG    = agk.recode.c(row.names(cur_lml),dat_match$VPPG,dat_match$HCPG)
      cur_lml         = melt(cur_lml)
      
      cur_form = as.formula('value ~ variable + HCPG')
      cfint = aggregate(cur_form,data = cur_lml,FUN=agk.boot.ci,
                        cur_fun = mean,lower=0.025, upper=0.975,R=5000)
      
      cfint = as.data.frame(cbind(cfint[c('variable','HCPG')],cfint[[3]]))
      names(cfint)[c(3:5)] = c('mean','lower','upper')
      cfint$channel = des_vars[ii]
      cfint_list[[ii]] = cfint
    }
    cfint = cfint_list[[1]]
    for(ii in 2:length(cfint_list)) {
      cfint = rbind(cfint,cfint_list[[ii]])
    }
    
    # plotting (faceting by category)
    names(cfint)[names(cfint) == 'HCPG'] = 'Group'
    cfint$Group                          = agk.recode.c(cfint$Group,'PG','GD')
    mRat  = ggplot(cfint, aes(variable, mean,fill=Group))
    mRat  = mRat + labs(x='Group', y=paste('Mean (',0.95*100,'% CI, bootstrapped)'))
    mRat  = mRat + ggtitle("Physio reactions to different categories of cues")
    mRat  = mRat + geom_bar(position="dodge", stat="identity")
    dodge = position_dodge(width=0.9)
    mRat  = mRat + geom_bar(position=dodge, stat="identity")
    mRat  = mRat + geom_errorbar(aes(ymin = lower, ymax = upper), position=dodge, width=0.25) 
    mRat  = mRat + facet_grid(channel ~ .)
    mRatg = mRat + theme_bw()
    print(mRatg)
    
    # stats
    stats_res = list()
    for (dd in 1:length(des_vars)) {
      # init
      res = list()
      
      # formulas
      cur_form_00 = paste0(des_vars[dd],' ~ 1 + (1 | subject) + (1 | stim)')
      cur_form_c0 = paste0(des_vars[dd],' ~ cat + (cat | subject) + (1 | stim)')
      cur_form_cg = paste0(des_vars[dd],' ~ cat*HCPG + (cat | subject) + (1 | stim)')
      
      # fitting
      res$mod_00 = lmer(cur_form_00,data = data_pdt,REML = F)
      res$mod_c0 = lmer(cur_form_c0,data = data_pdt,REML = F)
      res$mod_cg = lmer(cur_form_cg,data = data_pdt, REML = F)
      # packing
      stats_res[[dd]] = res
    }
    
    for (dd in 1:length(des_vars)) {
      print(anova(stats_res[[dd]]$mod_00,stats_res[[dd]]$mod_c0,stats_res[[dd]]$mod_cg))
    }
    print(agk.lme.summary(stats_res[[dd]]$mod_cg,type='norm'))
  }
  
  ## Plots means and CIs of physio variables (GAMBLE Phase) =====================
  if (which_study == 'POSTPILOT_HCPG' & plot_physio) {
    cr_pp   = c("corr","zygo","SCR")
    if (physio_sum_fun == 'all') {
      # use all the available summary stats
      all_phys_names = c()
      for (ii in 1:length(cr_pp)) {
        all_phys_names = c(all_phys_names,names(data_pdt)[grep(cr_pp[ii],names(data_pdt))])
      }
      cr_pp = all_phys_names
    }
    # here take out the phys names for gamble phase
    all_phys_names_gamble = all_phys_names[grep('_gamble',all_phys_names)]
    cr_pp                 = all_phys_names[grep('_gamble',all_phys_names,invert = T)]
    
    # take out what is too much; only mean
    all_phys_names_gamble = c(all_phys_names_gamble[grep('_auc',all_phys_names_gamble)],all_phys_names_gamble[grep('SCR',all_phys_names_gamble)])
    
    cur_cr_gam            = data_pdt[all_phys_names_gamble]
    cur_cr_la             = data_pdt[c('cat','accept_reject','subject')]
    cur_cr_gamStim        = cur_cr_gam
    all_vars_of_int       = names(cur_cr_gamStim)
    cur_cr_gamStim        = cbind(cur_cr_gamStim,cur_cr_la)
    
    all_coefs_df          = list()
    imp_missing = function(x) {x[is.na(x)] = mean.rmna(x); return(x)}
    for (gg in 1:length(all_vars_of_int)) {
      cur_var              = all_vars_of_int[gg]
      cur_form             = as.formula(paste(cur_var,'~','accept_reject*cat|subject'))
      cur_coefs            = coef(lmList(cur_form, data = cur_cr_gamStim,pool = F))
      cur_subs             = row.names(cur_coefs)
      cur_coefs            = as.data.frame(lapply(cur_coefs,FUN=imp_missing))
      row.names(cur_coefs) = cur_subs
      # selecting only PDT variables
      cur_coefs            = cur_coefs[,grep('reject1.cat',names(cur_coefs))]
      # packing for prediction analyses
      lmlcf[[length(lmlcf)+1]] = cur_coefs
      # more editing for the plots
      cur_coefs$subject        = cur_subs
      cur_coefs$channel        = all_vars_of_int[gg]
      all_coefs_df[[gg]]       = cur_coefs
    }
    
    # merging
    physGam_mf = all_coefs_df[[1]]
    for (gg in 2:length(all_coefs_df)) {
      physGam_mf = rbind(physGam_mf,all_coefs_df[[gg]])
    }
    
    # grouping var
    physGam_mf$HCPG = agk.recode.c(physGam_mf$subject,dat_match$VPPG,dat_match$HCPG)
    
    # getting means and CIs
    cfint_list = list()
    for (gg in as.numeric(which(unlist(lapply(physGam_mf,is.numeric))))) {
      cur_form = as.formula(paste(names(physGam_mf)[gg],'~ HCPG + channel'))
      cfint = aggregate(cur_form,data = physGam_mf,FUN=agk.boot.ci,
                        cur_fun = mean,lower=0.025, upper=0.975,R=5000)
      
      cfint = as.data.frame(cbind(cfint[c('HCPG','channel')],cfint[[3]]))
      names(cfint)[c(3:5)] = c('mean','lower','upper')
      cfint$variable = names(physGam_mf)[gg]
      
      # adding a channel variable
      cfint_list[[gg]] = cfint
    }
    
    
    # packing to df
    cfint = cfint_list[[1]]
    for(ii in 2:length(cfint_list)) {
      cfint = rbind(cfint,cfint_list[[ii]])
    }
    
    # cleaning var names
    cfint$channel = gsub('_auc','',cfint$channel)
    cfint$channel = gsub('_gambleStim','',cfint$channel)
    
    # plotting (faceting by category)
    mRat  = ggplot(cfint, aes(HCPG, mean,fill=variable))
    mRat  = mRat + labs(x='Group', y=paste('Mean (',0.95*100,'% CI, bootstrapped)'))
    mRat  = mRat + ggtitle("Physio reaction shifts in gamble phase: interactions (PIT effects)")
    mRat  = mRat + geom_bar(position="dodge", stat="identity")
    dodge = position_dodge(width=0.9)
    mRat  = mRat + geom_bar(position=dodge, stat="identity")
    mRat  = mRat + geom_errorbar(aes(ymin = lower, ymax = upper), position=dodge, width=0.25) 
    mRat  = mRat + facet_grid(channel ~ .)
    mRatg = mRat + theme_bw() #+ theme(legend.position="bottom")
    print(mRatg)
  }
}

## make a data.frame of these data ============================================
if (which_study != 'MRI' & plot_physio) {
  all_des_vars = c(des_vars,all_vars_of_int)
  crdf        = agk.clean.intercept.name(lmlcf[[1]])
  names(crdf) = paste0(names(crdf),'_',all_des_vars[1])
  for (ll in 2:length(lmlcf)) {
    cur_df        = agk.clean.intercept.name(lmlcf[[ll]])
    names(cur_df) = paste0(names(cur_df),'_',all_des_vars[ll])
    crdf          = data.frame(crdf,cur_df)
  }
  cr_agg_pp = crdf
  cr_agg_pp$subject = row.names(cr_agg_pp)
}


## exclude subjects who do not have everything (rating/physio) ================
all_subs  = cr_agg_pp$subject
if (plot_physio) {
  cr_agg_pp = na.omit(cr_agg_pp)
}
cr_agg_ra = na.omit(cr_agg_ra)

cur_drp_pp = c()
cur_drp_ra = c()
if (add_cr_pp & plot_physio) {
  cur_drp_pp  = all_subs[which(!all_subs %in% cr_agg_pp$subject)]
}
if (add_cr_ra) {
  cur_drp_ra  = all_subs[which(!all_subs %in% cr_agg_ra$subject)]
}
data_pdt  = data_pdt[!data_pdt$subject %in% cur_drp_pp,]
data_pdt  = data_pdt[!data_pdt$subject %in% cur_drp_ra,]
dat_match = dat_match[!dat_match$VPPG %in% cur_drp_pp,]
dat_match = dat_match[!dat_match$VPPG %in% cur_drp_ra,]
if (which_study != 'MRI') {
  message("Dropped these subs due to missing physio in data_pdt and dat_match:")
  print(as.character(cur_drp_pp))
} else {
  stopifnot(isempty(cur_drp_pp))
}
message("Dropped these subs due to missing rating in data_pdt and dat_match:")
print(as.character(cur_drp_ra))
# drop the subject variable; it is in row.names
cr_agg_pp$subject           = NULL
cr_agg_ra$subject           = NULL
