# script to get the fMRI ss and gPPI extracts as pp variables
# per sub
# discards subs that have missings in pp
# need to set and add_cr_pp

# getting MRI ss and gppi extracts per subject ================================
if (fmri_extr == 'ngm') {
  setwd(path_mep)
  cr_agg_pp_mep = read.table('ssgPPI_extr.csv',header = T,sep='\t')
  setwd(path_mes)
  cr_agg_pp_mes = read.table('ss_extr.csv',header = T,sep='\t')
  cr_agg_pp     = merge(cr_agg_pp_mes,cr_agg_pp_mep,by='subject')
} else if (fmri_extr == 'val') {
  setwd(path_mep)
  cr_agg_pp_mep = read.table('ssgPPI_extr_val.csv',header = T,sep='\t')
  setwd(path_mes)
  cr_agg_pp_mes = read.table('ss_extr_val.csv',header = T,sep='\t')
  cr_agg_pp     = merge(cr_agg_pp_mes,cr_agg_pp_mep,by='subject')
} else if (fmri_extr == 'glc') {
  setwd(path_mep)
  cr_agg_pp_mep = read.table('ssgPPI_extr_glc.csv',header = T,sep='\t')
  setwd(path_mes)
  cr_agg_pp_mes = read.table('ss_extr_glc.csv',header = T,sep='\t')
  cr_agg_pp     = merge(cr_agg_pp_mes,cr_agg_pp_mep,by='subject')
} else {
  stop('Not implemented this extr fmri yet.')
}

# exclude areas who do not have info from all subs (rating/physio) ============
all_subs      = unique(data_pdt$subject)
variable_drop = na.omit(t(cr_agg_pp))
vars_keep     = row.names(variable_drop)
all_vars      = names(cr_agg_pp)
cr_agg_pp     = cr_agg_pp[vars_keep]

message("Dropped these variables due to missing fMRI extraction data in some or all subs")
print(as.character(all_vars[!all_vars %in% names(cr_agg_pp)]))

# # exclude subjects who do not have everything (rating/physio) =================
# all_subs      = unique(data_pdt$subject)
# variable_drop = na.omit(t(cr_agg_pp))
# row.names(variable_drop)
# 
# cur_drp_pp = c()
# if (add_cr_pp) {
#   cur_drp_pp  = all_subs[which(!all_subs %in% cr_agg_pp$subject)]
# }
# 
# data_pdt  = data_pdt[!data_pdt$subject %in% cur_drp_pp,]
# dat_match = dat_match[!dat_match$VPPG %in% cur_drp_pp,]
# message("Dropped these subs due to missing fMRI extraction data:")
# print(as.character(cur_drp_pp))