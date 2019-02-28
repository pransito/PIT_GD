# explorative correlations
# LA, PIT variables and BDI, BIS, AUDIT, KFG, GBQ, edu, ftnd

# need to add bootstrapped p-values cause there are extreme outliers

# run select_study (which_study = "MRI_and_POSTPILOT")

# packages
agk.load.ifnot.install('xlsx')


# preparing
row.names(dat_match)  = dat_match$VPPG
pit_vars              = fm$ac
pit_vars              = agk.clean.intercept.name(pit_vars)
names(pit_vars)       = paste0('ac_',names(pit_vars))
#pit_vars$ac_Intercept = NULL
la_vars               = fm$la_LA
la_vars               = la_vars[c('gain','loss','LA')]
names(la_vars)        = paste0('la_',names(la_vars))
#stopifnot(which_study == "MRI_and_POSTPILOT")


# merging
cur_merge = agk.merge.df.by.row.names(dat_match,pit_vars)
cur_merge = agk.merge.df.by.row.names(cur_merge,la_vars)
#cur_merge = subset(cur_merge, HCPG == 'PG')

# selecting vars
pitla_params    = cur_merge[c(grep('^ac_',names(cur_merge)),grep('^la_',names(cur_merge)))]

# correlation
r_sp   = corr.test(pitla_params,adjust = 'none',method = 'spearman')
r_ps   = corr.test(pitla_params,adjust = 'none',method = 'pearson')
r_ps_p = r_ps$p
r_sp_p = r_sp$p

# plot function if sig
agk.plot.cor.if.sig = function(r_ps_p,r_sp_p,behav_params, constr_params, criterion) {
  ct = 0
  stopifnot(all(dim(r_ps_p) == dim(r_sp_p)))
  for (ii in 1:length(r_ps_p[,1])) {
    for (jj in 1:length(r_ps_p[1,])) {
      cur_p_ps = r_ps_p[ii,jj]
      cur_p_sp = r_sp_p[ii,jj]
      if (criterion == 'both') {
        cur_test = (cur_p_sp < 0.05 & cur_p_ps < 0.05)
      } else if (criterion == 'spearman_only') {
        cur_test = cur_p_sp < 0.05
      } else if (criterion == 'pearson_only') {
        cur_test = cur_p_ps < 0.05
      } else {
        stop('Unknown criterion')
      }
      if (cur_test) {
        ct = ct + 1
        plot(behav_params[[ii]],constr_params[[jj]],
             ylab=names(constr_params)[jj],
             xlab=names(behav_params)[ii])
      }
    }
  }
  message(paste0('There were ', ct, ' sig. correlations found with criterion ', criterion,'.'))
}

# table function if sig.
agk.table.cor.if.sig(r_ps,r_ps_p,r_sp_p) {
  # function that will print to excel a table with stars according to sig level
  # it will use the r_ps provided (can be any matrix giving correlation values)
  # just size must fit
  # both p-value must be below <0.5 in both cases
  
  r_ps_df   = data.frame(r_ps$r)
  r_ps_p_df = data.frame(r_ps_p)
  r_sp_p_df = data.frame(r_sp_p)
  
  # pearson or any correlation matrix will be prepped as string
  r_ps_df = round(r_ps_df,digits = 3)
  rnames  = row.names(r_ps_df)
  r_ps_df = data.frame(lapply(r_ps_df,FUN=as.character),stringsAsFactors = F)
  row.names(r_ps_df) = rnames
  r_ps_df[r_ps_p_df < 0.05 & r_sp_p_df < 0.05] = paste0(r_ps_df[r_ps_p_df < 0.05 & r_sp_p_df < 0.05],'*')
  r_ps_df[r_ps_p_df < 0.05 & r_sp_p_df < 0.01] = paste0(r_ps_df[r_ps_p_df < 0.01 & r_sp_p_df < 0.01],'*')
  r_ps_df[r_ps_p_df < 0.05 & r_sp_p_df < 0.001] = paste0(r_ps_df[r_ps_p_df < 0.001 & r_sp_p_df < 0.001],'*')
  r_ps_df[lower.tri(r_ps_df,diag = T)] = ''
  
  # write to excel
  write.xlsx(r_ps_df, 'name-of-your-excel-file.xlsx')
  
}


agk.plot.cor.if.sig(r_sp$p,r_ps$p,pitla_params,pitla_params,'both')
agk.table.cor.if.sig(r_ps,r_ps_p,r_sp_p)
