## PREAMBLE ===================================================================
# prep behavioral analyses PDT
# 19.09.2018
# Alexander Genauck

# IMPORT OF PDT non-fMRI DATA
# PRETEST,PILOT-HC,SANITY,PILOT-PG,MRI-PG,MRI-HC

## clear workspace
rm(list = ls())

warning('VPPG0115 still has two P structs. Behav data now only from first. Adapt import behav and ss models MRI')


## PARAMETERS =================================================================
## parameters that may be set
# export data to PIT GD MRI or PIT GD behav release
# none, MRI, behav
data_release             = 'none'
# use last exisiting import
import_existing_imp      = 1
# import from scratch (choice data, ratings, etc.; takes a bit)
# if 0 will take an older saved version
import_from_scratch      = 0
# do any matching or non at all?
do_matching_MRI          = 1
# do any matching or non at all?
do_matching_PP           = 1
# save the data_pdt? only off for debug
do_save                  = 1
# you may tunr off the export of the info_mri selection for debugging;
# this is to write the Sjinfo.mat file on MATLAB side
write_info_mri_selection = 1
# scaling: currently centered-only (gain, loss)
use_z                    = 1 
# accept rject is not binary but 1 through 4 (metric)
acc_num                  = 0
# use absolute value of loss as predictor
loss_abs                 = 1
# if set to 1 then people with too many missings will be dropped
missing_check            = 1  
# if there are more than x% percent missings in response then drop-out
missing_cutoff           = 0.8
# exclude if physio is missing?
# CAREFUL: ONLY SO FAR WORKS IF DATA IS IMPORTED FROM SCRATCH
# TODO!!!
physio_excl              = 1
# which physio sum stat data to use (mean or max or median or...)
# 'all' if you wanna put all summary stas in the CV (preferrable)
physio_sum_fun           = 'all'
# exclude according to TN-Liste? (should be always 1)
# this is to exclude according to include variable
# ADD Pretest cohort to TN-Liste, or get it from second sheet
# excluding before adding rating; rating can bring in subs that were excluded
# before or are not even in TN list
tnl_excl                 = 1
# exclude after adding ratings, (...)  to only have subs which have complete data
# should be 1 if you need complete data, should be 0 if you are interested in ratings
# and other data and not in all the complete behav and others data;
# if 0 then check get_data_ratings_2.R for the TODO at the length check
tnl_compl_excl           = 1
# what kind of pca to extract features? (if no kernel pca then normal pca)
do_kernelpca             = 0
# write the matching tables (should always be 1)
write_match_tables       = 1
# should bootstrapping be used instead of normal t-test when checking for mathcing?
# 1: yes; 2: TODO! permutation test will be used
match_boot               = 2
# get the MRI behav data as well? (only makes sense if the data is accessible)
get_MRI_behav_data       = 1
# estimate LA classical for MRI ss analysis? (using lmlist; quick!)
get_LAcl_for_MRI         = 0
# estimate LA Charpentier for MRI ss analysis? (CAREFUL: TAKES A WHILE)
get_LAch_for_MRI         = 0
# get MRI BOLD extracts (to be done in matlab and moved to google drive)
get_MRI_extr             = 0
# how much aggregate (3 is from 12by12 to 4by4 because 12/3 == 4; 1 would be no aggregation)
cur_agg                  = 3
# use aggregation in the analyses? will be used in select_study in PIT_GD repo version
use_agg                  = 0
# matching criterion p-value (for matching experimental groups)
m_crit                   = 0.12
# KFG cut off equal and above is PG (16 or 25)
KFG_cutoff               = 16
# for matching: which studies to do it on, and what are the group sizes?
# set desired_n to too high value if you do not want to do the matching for a particular study
which_studies            = c("MRI","POSTPILOT")
# how many subjects per group desired?
desired_n                = list(c(35,35),c(40,40))
# for matching (dom: do matching variables, do matching variables narrowed for elimination of couples)
# cut out: 'edu_years_voca','edu_hollingshead'

#cur_names_dom            = c('edu_years_sum','income_personal','smoking_ftdt','Age','audit','dem_gender','handedness','unemployed')
#cur_names_dom_narrowed   = c('edu_years_sum','Age','smoking_ftdt')
cur_names_dom            = c('edu_years','income_personal','smoking_ftdt','Age','audit','dem_gender','handedness','unemployed')
cur_names_dom_narrowed   = c('edu_years','Age','smoking_ftdt')
# for mri extraction data: which extraction to use in fMRI; glc: gain, loss, category; ngm: no gamble model, only category
fmri_extr                = 'glc'

## EXCLUSION/EXEMPTION LISTS ==================================================
# subjects that are exempt of physio; have been checked; do not have physio
# and physio is not recoverable, these subs will still be excluded if phys_excl == 1
# however, if a sub has no physio and is not on this list, an error will
# be thrown
phys_exempt  = c("VPPG0401","VPPG0705","VPPG0842",'VPPG0257a','VPPG0036','VPPG0326')
behav_exempt = paste0('Pretest',sprintf("%02d",seq(1,16)))
if (physio_excl) {
  behav_exempt = c(behav_exempt,phys_exempt)
}
# TODO: adding some more to behav_exempt; VPPG0289a is MRI and his data from S: needs to be arranged!
# TODO: VPPG0896 is a new MRI sub; needs to be arranged, behav data exported; etc.
# NOTE: subs without behav data will be disregarded in all further analyses/reports/matching
behav_exempt = c(behav_exempt,'baseNAPS0008', 'baseNAPS0013', 'baseNAPS0014',
                 'baseNAPS0015', 'baseNAPS0016', 'baseNAPS09','baseNAPS99999')

# excl subs by hand (should be always empty!!!)
# only for quick and dirty emergency
subs_excl_hand  = c()

## DETERMINE THE WORKING LOCATION =============================================
agk.get.working.location = function() {
  # on which computer are we working right now?
  user    = paste0(as.character(Sys.info()["login"]),"/")
  root_wd = rstudioapi::getSourceEditorContext()$path
  
  # get the github folder
  res      = regexpr('GitHub',root_wd)
  path_ghb = substr(root_wd,1,res[1]+attributes(res)$'match.length'-1)
  
  # get the google drive folder
  e_true = length(grep(pattern = 'E:',root_wd,fixed=T)) > 0
  c_true = length(grep(pattern = 'C:',root_wd,fixed=T)) > 0
  
  if (e_true & !c_true) {
    base_gd = "E:/Google Drive"
  } else if (c_true & !e_true) {
    base_gd = paste("C:/Users/",user,"Google Drive",sep="")
  } else {
    stop('Unknown case for working location.')
  }
  
  return(list(path_ghb = path_ghb, base_gd = base_gd))
  
}

res      = agk.get.working.location()
base_gd  = res$base_gd
path_ghb = res$path_ghb

## PATHS ======================================================================
# paths to VPPG exchange
base     = file.path(base_gd,'01_Promotion/VPPG/VPPG_Exchange')
base_bgg = base

# paths for getting data
#base_dat          = 'S:/AG/AG-Spielsucht2/Daten/VPPG_Daten/Adlershof/Daten/PDT'
base_dat          = file.path(base_gd,'02_Library/01_Data/PIT_GD/behav')
base_dat_GD       = file.path(base,'Experimente/PDT/Daten/')
path_dat          = file.path(base_dat,"pilot")
path_dat_GD       = file.path(base_dat_GD,"pilot")
path_postpilot_pg = file.path(base_dat,"POSTPILOT/PG")
path_postpilot_hc = file.path(base_dat,"POSTPILOT/HC")
path_pg           = file.path(base_dat,"PG")

# path for results
base_res          = file.path(base_gd,'02_Library/02_Results/PIT_GD')
path_res_classif  = file.path(base_res,'R/analyses/01_classification')

# path to the matching of names and subject codes
path_mtk          = 'S:/AG/AG-Spielsucht2/Daten/Probanden'

# path to LA study results
path_bgg          = file.path(base_gd,'09_Diplom/LA/daten_behav_test_finale_SP_Diplom/Results')

# paths to scripts
path_ana          = file.path(path_ghb,"PIT_GD/R/analyses")
path_anp          = file.path(path_ana,"01_classification")
path_lib          = file.path(path_ghb,"R")
path_plb          = path_ana
path_mod          = file.path(path_ana,"model_calculation")
path_imp          = file.path(base,'Bilderrating/Bildmaterial/VPPG_stim_04_reresized')

# paths to VPPG exchange (data and other)
path_res          = file.path(base,"Experimente/PDT/analysis/results")
path_mtc          = file.path(base,"BCAN/Probandenlisten/matching")
path_rat          = file.path(base,"Bilderrating/Results_Pretest/Result files")
path_rrs          = file.path(base,"Bilderrating/analysis/results")
path_que          = file.path(base,"Bilderrating/Results_Pretest/Result files/questionnaires - organize in R")
path_que_pp       = file.path(base,"Bilderrating/Results_Pretest/Result files/import old physio pretest questions")
path_scr          = path_que
path_MRI          = file.path(base_dat,'MRI')
path_led          = file.path(base,"Experimente/PDT/ledaLab_anal")

# path to ROIs
path_mes          = file.path(base_gd,'02_Library/MATLAB/PDT/MRI/sl/ROIs/from_ext_HD/ROIs/ROIs_ss_model')
path_mep          = file.path(base_gd,'02_Library/MATLAB/PDT/MRI/sl/ROIs/from_ext_HD/ROIs/ROIs_gPPI_targets')

# if working at home (what paths are those?)
#warning('path_mep and path_mes are set to working at home')
path_mes          = path_dat_GD
path_mep          = path_dat_GD

## LIBRARIES AND FUNCTIONS ====================================================
setwd(path_lib)
source ('agk_library.R')
setwd(path_ana)
source('perform_matching_tests.R')
#source('get_fixef_functions.R')

## which function to use for matching tests?
if (match_boot==1) {
  warning("Bootstrapping is used for matching. So f.summary is not used and instead determined by f.difftest (case 'boot'); Default there is 'mean'")
  warning("Bootstrapping is used for matching. So p(boot) is enough to determine if matched or not. Non-param. k ignored.")
  warning("Means deterimned and reported by imputing group means for missings.")
} else if (match_boot==2) {
  warning("Permutation lm is used for matching. So f.summary is not used and instead determined by f.difftest (case 'permute'); hence mean is used")
  warning("Permutation lm is used for matching. So p(perm) is enough to determine if matched or not. Non-param. k ignored.")
  warning("Means deterimned and reported by imputing group means for missings.")
} else if (match_boot==0) {
  warning('Simple t.tests used for matching plus non-parametric tests. NOT RECOMMENDED.')
} else {
  stop('match_boot is set to an uninterpretable value.')
}

## LOAD PARTICIPANT'S LIST
## participant's list (to get the VPPG numbers)
tnl           = read_excel(file.path(base, 'BCAN/Probandenlisten/Teilnehmerliste_VPPG_ONLY_USE_THIS_ONE.xlsx'),
                           sheet = 1,col_names = T)
tnl$VPPG      = as.character(tnl$VPPG)
tnl           = tnl[!is.na(tnl$VPPG),]
tnl$VPPG      = trimws(tnl$VPPG)
tnl$PhysioVP  = paste0("PhysioVP",tnl$PhysioVP)
tnl$PhysioVP  = trimws(tnl$PhysioVP)

# prelimn check that there are no duplicates in tnl
if (sum(duplicated(tnl$VPPG))) {
  mes_1 = 'You have these duplicate VPPG numbers in Teilnehmerliste. Fix first!\n'
  mes_2 = paste(tnl$VPPG[duplicated(tnl$VPPG)],collapse= ' ')
  stop(paste(mes_1,mes_2))
}

# prelimn check that inlcude/exclude variable is ok
if (any(is.na(tnl$Einschluss))) {
  stop('You have NAs in tnl$Einschluss. Fix first!')
}
if (any(!(tnl$Einschluss == 1 || tnl$Einschluss == 0))) {
  stop('Other values than 0 and 1 used in tnl$Einschluss. Fix first!')
}

# check who is eligible for POSTPILOT
subs_eligible_POSTPILOT = tnl$VPPG[(tnl$Cohort == 'POSTPILOT' | tnl$Cohort == 'PGPilot') & tnl$Einschluss == 1]

if (import_existing_imp == 0) {
  ## GETTING DATA (TAKES A WHILE)  ============================================
  if (import_from_scratch == 1) {
    ## GETTING DATA FROM SCRATCH ==============================================
    # get all the data in long format
    setwd(path_ana)
    ## IS IT OKAY THAT ALL SUBS HAVE SLIGHTLY DIFFERENT GAIN LOSS AGG STEP?
    source("get_data_pdt.R")
    source("get_physio_aggregates.R")
    
    # INTERIM
    #data_pdt        = (data_pdt[,grep('.x',names(data_pdt),fixed = T,invert=T)])
    #names(data_pdt) = gsub('.y','',names(data_pdt),fixed=T)
    #data_pdt_bcp = data_pdt
    
    source("get_data_ratings_2.R")
    
    # INTERIM
    data_pdt        = (data_pdt[,grep('.x',names(data_pdt),fixed = T,invert=T)])
    names(data_pdt) = gsub('.y','',names(data_pdt),fixed=T)
    data_pdt_bcp    = data_pdt
    
    # save the result of import from scratch
    setwd(path_dat)
    save(file = "pure_data_pdt.RData",list = c("data_pdt","ratings"))
  } else {
    setwd(path_dat)
    load("pure_data_pdt.RData")
  }
  ## END OF DATA_PDT GATHERING
  
  ## DATA CLEANING ============================================================
  # dropping subjects due to always accept or reject
  disp("checking if have to exclude due to always accepted or rejected")
  
  ## subjects that ALWAYS ACCEPT or REJECT
  # ignores subs that have only NAs
  often_acc = c()
  often_rej = c()
  all_subs  = as.character(unique(data_pdt$subject))
  for (kk in 1:length(all_subs)) {
    cur_dat = subset(data_pdt, subject == all_subs[kk])
    cur_dat = subset(cur_dat, !is.na(accept_reject))
    if (length(cur_dat[,1]) == 0) {
      next
    }
    cur_acc = sum(cur_dat$accept_reject==1)/length(cur_dat$accept_reject)
    cur_rej = sum(cur_dat$accept_reject==0)/length(cur_dat$accept_reject)
    
    if (cur_acc == 1) {
      often_acc = c(often_acc,all_subs[kk])
    }
    if (cur_rej == 1) {
      often_rej = c(often_rej,all_subs[kk])
    }
  }
  
  ## throw always reject out
  data_pdt      = data_pdt[(!data_pdt$subject %in% often_rej),]
  data_pdt      = data_pdt[(!data_pdt$subject %in% often_acc),]
  if (length(often_rej) != 0 | length(often_acc) != 0) {
    warning(paste("Excluded subject(s) due to always accepted/rejected.",
                  paste0(paste(often_rej,collapse=''),paste(often_acc,collapse=''))))
  }
  
  # create workspace backup
  data_pdt_pure = data_pdt
  
  # end data cleaning and excluding subjects
  # after here YOU ARE NOT ALLOWED ANYMORE TO EXCLUDE
  # SUBS (?!)
  
  ### END DATA CLEANING
  
  ## LEDA IMPORT ==============================================================
  ## TODO: LEDA IMPORT!
  ## ADD LEDALAB
  # data_leda      = read.csv(paste0(path_led,'Data/EDA_ResultsR.csv'))
  # data_leda_cont = read.csv(paste0(path_led,'Data_control/EDA_ResultsR.csv'))
  # data_leda_pp   = read.csv(paste0(path_led,'Postpilot/Data/EDA_ResultsR.csv'))
  # data_leda      = rbind(data_leda,data_leda_cont,data_leda_pp)
  # data_leda$subject_new = agk.recode.c(as.character(data_leda$subject),tnl$PhysioVP,tnl$VPPG)
  # data_leda$subject_new = as.factor(as.character(data_leda$subject_new))
  # data_leda$subject     = data_leda$subject_new
  # data_leda$subject_new = NULL
  
  # data_leda_long      = read.csv(paste0(path_led,'Data_onsetFixStimGam/EDA_ResultsR.csv'))
  # 
  # data_leda_fix = data_leda_long[data_leda_long$onset==0,]
  # colnames(data_leda_fix)[4:10] = paste0(colnames(data_leda_long), '_fix')[4:10]
  # 
  # data_leda_stim = data_leda_long[data_leda_long$onset==1,]
  # colnames(data_leda_stim)[4:10] = paste0(colnames(data_leda_long), '_stim')[4:10]
  # 
  # data_leda_gam = data_leda_long[data_leda_long$onset==2,]
  # colnames(data_leda_gam)[4:10] = paste0(colnames(data_leda_long), '_gam')[4:10]
  # 
  # data_leda_m1=merge(data_leda_fix, data_leda_stim,  by=c('subject','trial'))
  # data_leda=merge(data_leda_m1, data_leda_gam, by=c('subject','trial'))
  # 
  # data_leda$subject_new = agk.recode.c(as.character(data_leda$subject),tnl$PhysioVP,tnl$VPPG)
  # data_leda$subject_new = as.factor(as.character(data_leda$subject_new))
  # data_leda$subject     = data_leda$subject_new
  # data_leda$subject_new = NULL
  # 
  # data_leda$onset=NULL
  # data_leda$onset.x=NULL
  # data_leda$onset.y=NULL
  # 
  # data_pdt_leda  = merge(data_pdt, data_leda, by=c('subject','trial')) 
  # data_pdt       = merge(data_pdt, data_leda, by=c('subject','trial'), all=TRUE)
  
  ## QUESTIONNAIRE DATA =======================================================
  load(paste0(path_que, '/Bilderrating_VPPG_Quest.Rda'))
  
  # Fagerström neu zusammenrechnen #
  # TODO: move to quest import
  FTND_set=data_quest[c("FTND_1","FTND_2","FTND_3","FTND_4","FTND_5","FTND_6")]
  # get number of levels
  num_levels = c()
  for (ff in 1:length(FTND_set)) {num_levels[ff] = (length(levels(FTND_set[[ff]]))-1)}
  FTND_num=(sapply(FTND_set, as.numeric))*-1
  FTND_num[FTND_set=="[NA] nicht beantwortet"] = NA
  for (ff in 1:length(FTND_num[1,])) {FTND_num[,ff] = FTND_num[,ff] + num_levels[ff]}
  FTND_num[is.na(FTND_num)]=0
  data_quest$FTND=rowSums(FTND_num)
  
  # getting the questionnaires var names
  questionnaires_vars_names = c()
  for(ii in 1:ncol(data_quest)) {
    cur_com = comment(eval(parse(text=paste0("data_quest$", attr(data_quest[ii],'name')))))
    if (length(cur_com) == 0) {
      questionnaires_vars_names[ii] = NA
      next 
    } else {
      questionnaires_vars_names[ii] =comment(eval(parse(text=paste0("data_quest$", attr(data_quest[ii],'name')))))
    }
  }
  
  # get GBQ split by subscales
  names_GBQ            <- grep("^GBQ_", names(data_quest), value=TRUE)
  GBQ_persi_ids        = c(4, 6, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21)
  GBQ_illus_ids        = c(1, 2, 3, 5, 7, 8, 9, 19)
  tmp                  <- data_quest[names_GBQ]
  data_quest$GBQ_illus <- apply(tmp[,c(1,2,3,5,7,8,9,19)],FUN = mean.rmna,MARGIN = 1)
  data_quest$GBQ_persi <- apply(tmp[,c(4,6,10,11,12,13,14,15,16,17,18,20,21)],FUN = mean.rmna,MARGIN = 1)
  
  ## QUESTIONNAIRE DATA from the pretests and physio pretests
  data_quest_pp                  = readRDS(paste0(path_que_pp, '/data_quest_physplt.rds'))
  data_quest_pp$data_par.P104_01 = data_quest_pp$PhysioVP
  data_quest_pp                  =  data_quest_pp[rownames(data_quest_pp)!='508',]
  
  data_quest_bckp=data_quest
  data_quest= rbind.fill(data_quest, data_quest_pp)
  
  #  make a VPPG variable
  data_quest$VPPG = data_quest$data_par.P104_01
  data_quest$VPPG = agk.recode.c(data_quest$VPPG,tnl$PhysioVP,tnl$VPPG)
  
  
  ## SCREENING DATA ===========================================================
  setwd(path_scr)
  load("Screening_VPPG_Data-label.Rda")
  
  # getting the screening var names
  screening_vars_names = c()
  for(ii in 1:ncol(data_ano)) {
    cur_com = (comment(eval(parse(text=paste0("data_ano$", attr(data_ano[ii],'name'))))))
    if (length(cur_com) == 0) {
      screening_vars_names[ii] = NA
      next 
    } else {
      screening_vars_names[ii] =(comment(eval(parse(text=paste0("data_ano$", attr(data_ano[ii],'name'))))))
    }
  }
  
  # ... and levels
  screening_vars_levels = list()
  for(ii in 1:ncol(data_ano)) {
    cur_com = attr(data_ano[[ii]],'levels')
    if (length(cur_com) == 0) {
      screening_vars_levels[[ii]] = NA
      next 
    } else {
      screening_vars_levels[[ii]] =cur_com
    }
  }
  
  # categorize subjects into HC and PG based on KFG score
  data_ano$HCPG   = factor(as.numeric(data_ano$KFG>=KFG_cutoff), levels=c(NA, 0,1), labels=c('HC','PG'))
  data_ano$Cohort = agk.recode.c(as.character(data_ano$VPPG),as.character(tnl$VPPG),as.character(tnl$Cohort))
  
  # recode VPPG0051 to VPPG0051a
  # TODO: should be done in screening
  # wrote to Jan Philipp Albrecht
  data_ano$VPPG[data_ano$VPPG == "VPPG_0051"] = "VPPG_0051a"
  
  # cleaning
  # TODO: needs to be done in screening export
  data_ano$VPPG = gsub('_', '', data_ano$VPPG)
  
  ## GET MATCHING TABLES  =====================================================
  # get other variables of interest (for matching: years of edu, income) from screening
  dat_match        = data_ano[c('VPPG','S209','HCPG', 'S201','KFG', 'S313','S314_01', 'S314_02','S320','S321_01', 'S322', 'S323')]
  names(dat_match) = c("VPPG", "gender",'HCPG','handedness',"KFG", "edu_highest_deg","edu_tert_years","edu_tert_months","income_household","income_for_how_many",
                       "debt_overall","debt_gambling")
  if(!all(duplicated(dat_match$VPPG) == FALSE)) {
    stop('duplicates in dat_match$VPPG! after just reading data_ano')
  }
  
  #dat_match$debt_gambling[is.na(dat_match$debt_gambling)] = 0
  dat_match$debt_gambling = factor(dat_match$debt_gambling,levels = c(0:6),
                                   labels = c("0","10000","25000","50000","100000","200000","300000"))
  dat_match$edu_tert_months     = as.numeric(dat_match$edu_tert_months) 
  dat_match$edu_tert_years      = as.numeric(dat_match$edu_tert_years)
  names_match_quest  = names(data_quest[,c("dem_age","dem_edu_bildungsgrad","dem_occupation" ,"dem_houseIncome","dem_housePpl","dem_smoke","AUDIT","FTND")])
  rnames_match_quest = c("Age", "edu_deg_secondary", "occup","income_hh_quest", "income_people_hh_quest","smoking","audit","ftdt") ## CAREFUL: from 23.05.2016 audit is in screening!
  
  if(!all(duplicated(dat_match$VPPG) == FALSE)) {
    stop('duplicates in dat_match$VPPG!')
  }
  
  ## QUESTIONNAIRE DATA WITH MATCH DATA
  dat_match       = merge(dat_match,tnl, by=c("VPPG"))
  dat_match       = merge(dat_match,data_quest,by=c("VPPG"))
  names(dat_match)[which(names(dat_match) %in% names_match_quest)] = rnames_match_quest
  tmp = data.frame(dat_match[grep(pattern="^edu",names(dat_match))])
  
  # add KFG to quest
  #add a line in data_quest for everyone in the teilnehmerliste who also has an entry in data_ano
  # TODO: DUNNO WHAT THIS IS!!!
  # screened_tested_noquest=data_ano$VPPG[data_ano$VPPG %in% tnl$VPPG[!tnl$VPPG %in% data_quest$VPPG]]
  # data_quest[(length(data_quest$VPPG)+1):(length(data_quest$VPPG)+length(screened_tested_noquest)),]$VPPG=screened_tested_noquest
  # DUNNO WHAT THIS IS!!!
  data_quest = merge(data_quest,as.data.frame(data_ano[c("VPPG","KFG")]),by=c("VPPG"),all.x = TRUE)
  
  # Resolve AUDIT: take from screening, if NA use the quest
  # TODO: AUDIT: items: some are numeric some are labels
  data_ano_audit=data_ano[c("VPPG","E101","E102","E103","E104","E105","E106","E107",
                            "E108","E109","E110", "AUDIT")]
  names(data_ano_audit)=c("VPPG",'AUDIT_1','AUDIT_2','AUDIT_3','AUDIT_4','AUDIT_5','AUDIT_6','AUDIT_7','AUDIT_8','AUDIT_9','AUDIT_10','AUDIT')
  data_quest_bckp2=data_quest
  data_quest=merge(data_quest, data_ano_audit, by = 'VPPG', suffixes = c(".que",".scr"))
  data_quest$AUDIT=data_quest$AUDIT.scr
  data_quest$AUDIT[is.na(data_quest$AUDIT.scr)]=data_quest$AUDIT.que[is.na(data_quest$AUDIT.scr)]
  for (i in 1:10) {
    eval(parse(text=paste0('data_quest$AUDIT_',i, '=data_quest$AUDIT_', i, '.scr')))
    eval(parse(text=paste0('data_quest$AUDIT_',i, '=as.character(data_quest$AUDIT_', i,')')))
    eval(parse(text=paste0('data_quest$AUDIT_',i, '[is.na(data_quest$AUDIT_', i,
                           '.scr)]=data_quest$AUDIT_', i, '.que[is.na(data_quest$AUDIT_', i, '.scr)]')))
  }
  warning('Still double-check AUDIT and other quests if correctly tallied!')
  
  if(!all(duplicated(dat_match$VPPG) == FALSE)) {
    stop('duplicates in dat_match$VPPG!')
  }
  
  # get matching ready for analysis
  # education (make a years of education variable)
  # using a dictionary with all known(!) combinations
  setwd(path_mtc)
  cur_dic_tab = xlsx::read.xlsx("dic_edu.xlsx",1)
  dat_match$edu_years        = NA
  dat_match$edu_years_voca   = NA
  dat_match$edu_hollingshead = NA
  cur_dic_tab$dat_match.edu_highest_deg   = as.character(cur_dic_tab$dat_match.edu_highest_deg)
  cur_dic_tab$dat_match.edu_deg_secondary = as.character(cur_dic_tab$dat_match.edu_deg_secondary)
  agk.as.char.NA = function(x){
    if (is.na(x)) {
      return("NA")
    } else {
      as.character(x)
    }
  }
  
  for (ii in 1:length(dat_match$VPPG)) {
    cur_education = c(as.character(dat_match$edu_highest_deg[ii]),as.character(dat_match$edu_deg_secondary[ii]))
    cur_education[grep('[NA]',cur_education,fixed = T)] = 'NA'
    first_match                    = cur_dic_tab[,c(1)] == agk.as.char.NA(cur_education[1])
    secnd_match                    = cur_dic_tab[,c(2)] == agk.as.char.NA(cur_education[2])
    cur_match                      = first_match*secnd_match
    cur_years                      = cur_dic_tab$transl[which(cur_match==1)]
    cur_years_voca                 = cur_dic_tab$transl_vocational[which(cur_match==1)]
    cur_years_holl                 = cur_dic_tab$Hollingshead[which(cur_match==1)]
    dat_match$edu_years[ii]        = as.numeric(as.character(cur_years))
    dat_match$edu_years_voca[ii]   = as.numeric(as.character(cur_years_voca))
    dat_match$edu_hollingshead[ii] = as.numeric(as.character(cur_years_holl))
  }
  
  # making a sum education variable
  dat_match$edu_years_sum = dat_match$edu_years + dat_match$edu_years_voca
  
  # income
  tmp = data.frame(dat_match[c(grep(pattern="VPPG",names(dat_match)),
                               grep(pattern="^income",names(dat_match)))])
  cur_source          = attr(tmp$income_household,"levels")
  cur_transl          = c("500","1000","1500","2000","2500","3000","3500","4000","4500","5000","7000")
  tmp$income_personal = as.numeric(agk.recode(as.character(tmp$income_household),cur_source,cur_transl))
  # fixing income_hh_quest
  tmp$income_hh_quest = gsub('k.A.',NA,tmp$income_hh_quest)
  tmp$income_hh_quest = gsub(',00','',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub('.','',tmp$income_hh_quest,fixed = T)
  tmp$income_hh_quest = gsub(',-','',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub('2000-2500','2250',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub('ALG II','700',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub('€','',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub(' ','',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub(',','',tmp$income_hh_quest)
  tmp$income_hh_quest = gsub("~",'',tmp$income_hh_quest,fixed=T)
  tmp$income_hh_quest[tmp$VPPG == 'VPPG0045'] = '770'
  tmp$income_hh_quest[tmp$VPPG == 'VPPG0842'] = '451'
  tmp$income_hh_quest = gsub('NA',NA,tmp$income_hh_quest)
  cur_num_na_before = sum(is.na(tmp$income_hh_quest))
  cur_num_na_after  = sum(is.na(as.numeric(tmp$income_hh_quest)))
  if(cur_num_na_after>cur_num_na_before) {
    stop('NAs were created during income processing. Check tmp$income_hh_quest')
  }
  # replacing income personal with more refined income_hh_quest if not NA
  for (ii in 1:length(tmp$income_hh_quest)) {
    if (!is.na(tmp$income_hh_quest[ii])) {
      tmp$income_personal[ii] = tmp$income_hh_quest[ii]
    }
  }
  
  # replacing people household if NA
  for (ii in 1:length(tmp$income_for_how_many)) {
    if (is.na(tmp$income_for_how_many[ii])) {
      tmp$income_for_how_many[ii] = tmp$income_people_hh_quest[ii]
    }
  }
  # dividing by people in household
  cur_num_na_before = sum(is.na(tmp$income_personal))
  cur_num_na_after  = sum(is.na(as.numeric(tmp$income_personal)))
  if(cur_num_na_after>cur_num_na_before) {
    stop('NAs were created during income processing. Check tmp$income_hh_quest')
  }
  cur_num_na_before = sum(is.na(tmp$income_for_how_many))
  cur_num_na_after  = sum(is.na(as.numeric(tmp$income_for_how_many)))
  if(cur_num_na_after>cur_num_na_before) {
    stop('NAs were created during income processing. Check tmp$income_hh_quest')
  }
  
  # correction of tmp$income_for_how_many: 0 is not allowed; will be 1
  tmp$income_for_how_many = as.numeric(tmp$income_for_how_many)
  tmp$income_for_how_many = ifelse(tmp$income_for_how_many == 0,1,tmp$income_for_how_many)
  
  # dividing by number of people in household
  tmp$income_personal = as.numeric(tmp$income_personal)/as.numeric(tmp$income_for_how_many)
  
  dat_match = merge(dat_match,tmp,by=c('VPPG'))
  
  # smoking
  names(dat_match)[which(names(dat_match) == "ftdt")] = "smoking_ftdt"
  
  # debt
  cur_source = attr(dat_match$debt_overall,"levels")
  cur_transl = c("0","10000","25000","50000","100000","200000","300000","10000","25000","50000","100000","200000","300000","NA")
  dat_match$debt_overall_num = as.numeric(agk.recode(as.character(dat_match$debt_overall),cur_source,cur_transl))
  
  # TODO: should work with levels again; wrote Jan Philipp! 31.05.2016
  #cur_source = attr(dat_match$debt_gambling,"levels")
  #cur_transl = c("0","10000","25000","50000","100000","200000","300000")
  dat_match$debt_gambling_num = as.numeric(as.character(dat_match$debt_gambling))
  #dat_match$debt_gambling_num = as.numeric(agk.recode(as.character(dat_match$debt_gambling),cur_source,cur_transl))
  dat_match$debt_gambling_num = ifelse(is.na(dat_match$debt_gambling_num),0,dat_match$debt_gambling_num)
  dat_match$debt_gambling_num = ifelse(is.na(dat_match$debt_overall_num),NA,dat_match$debt_gambling_num)
  
  # occupation
  dat_match$unemployed = ifelse(dat_match$occup == "arbeitslos","unemployed","not unemployed")
  
  # gender
  cur_levels       = levels(dat_match$gender)[c(1,2)]
  dat_match$gender = ifelse(dat_match$gender == "männlich" | dat_match$gender == "weiblich",dat_match$gender,NA)
  dat_match$gender = as.factor(as.character(dat_match$gender))
  levels(dat_match$gender) = cur_levels
  
  # dem_gender: 'anderes' will be weiblich
  # TODO: take this out here and into quest export
  cur_ind = which(names(dat_match) == 'dem_gender')
  dat_match[[cur_ind]][grep('anderes', dat_match[[cur_ind]])] = 'weiblich'
  dat_match[[cur_ind]] = droplevels(dat_match[[cur_ind]])
  
  # now throw out all subs in dat_match that are not in data_pdt
  # this way dat_match always just worries about data_pdt subjects
  # YOU SHOULD NOT EXCLUDE ANY SUBS LATER AS THIS WILL NOT 
  # FIGURE IN DAT_MATCH THEN
  dat_match = dat_match[dat_match$VPPG %in% data_pdt$subject,]
  
  # cleaning those NA. variables
  cur_vars_drop  = grep('^NA.',names(dat_match))
  if (length(cur_vars_drop)) {
    dat_match      = dat_match[,-cur_vars_drop] 
  }
  
  # recode MRI
  dat_match$Cohort = agk.recode(dat_match$Cohort,'MRT','MRI')
  
  ## END OF GETTING MATCHING TABLES
  
  ## PERFORM MATCHING TESTS ===================================================
  # performing the matching tests and writing results
  # getting the info on available phys data; based on subs_good_phys variable
  # get the MATLAB report on good and existent physio
  setwd(path_dat)
  setwd('..')
  subs_good_phys        = read.table('good_physio_data.txt',header=T)
  subs_good_phys        = subs_good_phys$subs_with_good_physio_data
  subs_good_phys        = agk.recode.c(subs_good_phys,tnl$PhysioVP,tnl$VPPG)
  
  # handedness "beide" will be "rechts"
  # unemployed as factor
  dat_match$handedness[dat_match$handedness == "beide"] = "rechts"
  dat_match$handedness = droplevels(dat_match$handedness)
  dat_match$unemployed = as.factor(dat_match$unemployed)
  dat_match$smoking[dat_match$smoking == "manchmal"] = "ja"
  dat_match$smoking = droplevels(dat_match$smoking)
  
  # splitting the dat_match
  cur_res      = agk.perform.matching.splitdfs(dat_match)
  dfs          = cur_res$dfs
  cur_groups   = cur_res$cur_groups
  cur_matching = cur_res$cur_matching
  cur_names    = cur_res$cur_names
  cur_gr_levs  = list(c("HC","PG"),c("HC","PG"),c("männlich","weiblich"),c("HC","PG"))
  
  # interpolating using mean per group
  dfs = agk.interpolating.dat_match(dfs,cur_groups,cur_names,cur_gr_levs)
  
  # get complete (unmatched MRI sample)
  dat_match_MRIum = subset(dat_match, Cohort == 'MRI')
  data_pdt_MRIum  = subset(data_pdt, cohort == 'MRI')
  
  if (do_matching_MRI) {
    # do matching: find best matching subject for each subject [mainly for Postpilot because MRI set to c(32,32)]
    matching_res          = agk.domatch(which_studies,desired_n,dfs,cur_groups,cur_names_dom)
    dfs                   = matching_res$dfs
    dropped_subs_matching = matching_res$dropped_HCs_PGs
    
    # get the matching that worked from autumn 2018
    # also back upped here: S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\MRT\MRT_sample
    setwd(path_dat_GD)
    sjinfo_30_30 = R.matlab::readMat('Sjinfo_30_30.mat')
    mri_incl    = as.character(unlist(sjinfo_30_30$'Sjinfo'[1][1][[1]][1]))
    mri_excl    = dfs[[1]]$VPPG[!dfs[[1]]$VPPG %in% mri_incl]
    mri_excl_PG = dfs[[1]]$VPPG[!dfs[[1]]$VPPG[dfs[[1]]$HCPG == 'PG'] %in% mri_incl]
    mri_excl_HC = dfs[[1]]$VPPG[!dfs[[1]]$VPPG[dfs[[1]]$HCPG == 'HC'] %in% mri_incl]
    message('I am cutting MRI sample to improve matching...')
    cur_text = paste("In study", which_studies[1],"these subjects were dropped to improve matching:\n",
                     "HC:",paste(mri_excl_HC,collapse = " "),"\n",
                     "PG:",paste(mri_excl_PG,collapse = " "))
    message(cur_text)
  }
  
  # get complete (unmatched MRI sample)
  dat_match_PPum = subset(dat_match,(Cohort == "PGPilot" | Cohort == "POSTPILOT"))
  data_pdt_PPum  = subset(data_pdt,(cohort == "PGPilot" | cohort == "POSTPILOT"))
  
  if (do_matching_PP) {
    # get the matching that worked from autumn 2018 (postpilot)
    # also back upped here: S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten\PDT\POSTPILOT\sample
    setwd(path_dat_GD)
    load('all_subjects_POSTPILOT.RData')
    pp_incl     = all_subjects_POSTPILOT
    pp_excl     = dfs[[2]]$VPPG[!dfs[[2]]$VPPG %in% pp_incl]
    pp_excl_PG  = dfs[[2]]$VPPG[!dfs[[2]]$VPPG[dfs[[2]]$HCPG == 'PG'] %in% pp_incl]
    pp_excl_HC  = dfs[[2]]$VPPG[!dfs[[2]]$VPPG[dfs[[2]]$HCPG == 'HC'] %in% pp_incl]
    message('I am cutting Postpilot sample to improve matching...')
    cur_text = paste("In study", which_studies[2],"these subjects were dropped to improve matching:\n",
                     "HC:",paste(pp_excl_HC,collapse = " "),"\n",
                     "PG:",paste(pp_excl_PG,collapse = " "))
    message(cur_text)
  }
  
  # # elimate further, in the MRI study at least, to improve matching [MRI: study 1]
  # message('I am cutting MRI sample further to improve matching on...')
  # message(paste(cur_names_dom_narrowed,collapse = ' '))
  # elim_res                                       = agk.domatch.elim(which_studies[1],dfs[1],cur_groups[1],cur_names_dom_narrowed)
  # dfs[[1]]                                       = elim_res$dfs[[1]]
  # dropped_subs_matching[[1]]$dropped_HC_matching = c(dropped_subs_matching[[1]]$dropped_HC_matching,elim_res$dropped_HCs_PGs[[1]]$dropped_HC_matching)
  # dropped_subs_matching[[1]]$dropped_PG_matching = c(dropped_subs_matching[[1]]$dropped_PG_matching,elim_res$dropped_HCs_PGs[[1]]$dropped_PG_matching)
  # 
  
  # # reporting who was dropped due to matching
  # for (ii in 1:length(which_studies)) {
  #   cur_text = paste("In study", which_studies[ii],"these subjects were dropped to improve matching:\n",
  #                    "HC:",paste(dropped_subs_matching[[ii]]$dropped_HC_matching,collapse = " "),"\n",
  #                    "PG:",paste(dropped_subs_matching[[ii]]$dropped_PG_matching,collapse = " "))
  #   warning(cur_text)
  # }
  
  # align data_pdt and dat_match after do matching
  warning(paste0("dat_match and data_pdt subjects are aligned after dropping subjects due to matching.\n",
                 "But dat_match has no interpolation of missing data as was used for printing demography tables."))
  # for (ii in 1:length(which_studies)) {
  #   data_pdt  = data_pdt[!data_pdt$subject %in% dropped_subs_matching[[ii]]$dropped_HC_matching,]
  #   data_pdt  = data_pdt[!data_pdt$subject %in% dropped_subs_matching[[ii]]$dropped_PG_matching,]
  #   dat_match = dat_match[!dat_match$VPPG %in% dropped_subs_matching[[ii]]$dropped_HC_matching,]
  #   dat_match = dat_match[!dat_match$VPPG %in% dropped_subs_matching[[ii]]$dropped_PG_matching,]
  # }
  
  if (do_matching_MRI) {
    # further drops for MRI study
    dfs[[1]]  = dfs[[1]][dfs[[1]]$VPPG %in% mri_incl,]
    data_pdt  = data_pdt[!data_pdt$subject %in% mri_excl,]
    dat_match = dat_match[!dat_match$VPPG %in% mri_excl,]
  }
  
  if (do_matching_PP) {
    # further drops for PP study
    dfs[[2]]  = dfs[[2]][dfs[[2]]$VPPG %in% pp_incl,]
    data_pdt  = data_pdt[!data_pdt$subject %in% pp_excl,]
    dat_match = dat_match[!dat_match$VPPG %in% pp_excl,]
  }
  
  
  # MRI cohort: drop due to Age, edu years, lefthandedness
  # dat_match_MRI     = subset(dat_match,Cohort == 'MRI')
  # subs_drop_Age_MRI = dat_match_MRI$VPPG[dat_match_MRI$Age <20] # relevant in HC
  # subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$Age >60 & dat_match_MRI$HCPG == 'PG'])
  # subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$Age ==57 & dat_match_MRI$HCPG == 'PG' & dat_match_MRI$handedness == 'links'])
  # subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$Age ==43 & dat_match_MRI$HCPG == 'PG' & dat_match_MRI$handedness == 'links'])
  # subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$edu_years > 20]) # relevant in HC
  
  
  #subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$edu_years_voca == 8 & dat_match_MRI$HCPG == 'HC']) # relevant in HC
  #subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$edu_years_voca == 5 & dat_match_MRI$HCPG == 'HC']) # relevant in HC
  #subs_drop_Age_MRI = c(subs_drop_Age_MRI,dat_match_MRI$VPPG[dat_match_MRI$edu_years_voca == 4 & dat_match_MRI$HCPG == 'HC']) # relevant in HC
  
  # align the dfs MRI
  # dfs[[1]] = subset(dfs[[1]],!VPPG %in% subs_drop_Age_MRI)
  
  # # reporting who was dropped due to by-hand matching
  # cur_grp               = agk.recode(subs_drop_Age_MRI,dat_match$VPPG,as.character(dat_match$HCPG))
  # elim_matching_by_hand = data.frame(subs_drop_Age_MRI,cur_grp,stringsAsFactors = F)
  # cur_text = paste('In MRI study these subs were dropped by hand to improve matching',paste(elim_matching_by_hand,collapse=' '))
  # warning(cur_text)
  # 
  # # align data_pdt and dat_match after do matching
  # warning(paste0("dat_match and data_pdt subjects are aligned after dropping subjects due to matching by hand.\n",
  #                "But dat_match has no interpolation of missing data as was used for printing demography tables."))
  # data_pdt  = data_pdt[!data_pdt$subject %in% subs_drop_Age_MRI,]
  # dat_match = dat_match[!dat_match$VPPG %in% subs_drop_Age_MRI,]
  
  # core perfoming matching tests
  disp('Checking matching and printing tables.')
  match_result_tables = agk.perform.matching.tests(dfs,cur_groups,cur_matching,path_mtc,
                                                   write_match_tables = 1,cur_names)
  
  ## SETTING COHORT AND GROUP VARS FOR DATA_PDT ===============================
  
  # TODO: not so pretty yet!
  # data_pdt$cohort (lower case c) is already needed in physio aggregate
  # we use it here
  # make the Cohort-Variable and HCPG variable according to KFG
  data_pdt$Cohort     = as.character(data_pdt$cohort)
  data_pdt$cohort     = NULL
  data_pdt$HCPG       = agk.recode.c(data_pdt$subject,dat_match$VPPG,dat_match$HCPG)
  # set all the physio pilot people to HC
  data_pdt[data_pdt$Cohort == "PhysioPilot",]$HCPG = "HC" 
  complete_data       = data_pdt
  
  # TODO: where are those Pretest subs?
  # Resolve issues with the Cohort variable  - Milan 6.7.2016
  # - Make Pretest a single cohort
  data_pdt$Cohort[grep("Pretest", data_pdt$Cohort)]="Pretest"
  # - Separate the Pretest01, Pretest02, Pretest03 from the Pretest cohort because those did a different questionnaire - pretest01 who
  # had extra different gambling images, and pretest02 and 03 who gave an online feedback during the ratings, thus the PretestOral
  data_pdt$Cohort[data_pdt$subject=='Pretest01']= 'PretestO1'
  data_pdt$Cohort[data_pdt$subject=='Pretest02' | data_pdt$subject=='Pretest03']= 'PretestOral'
  
  # explanation of variables
  # TODO! FIX! with comments
  # data_pdt_vars = names(data_pdt)
  # data_pdt_vars_explanations = c("subject_ID","trial number within task","stimulus ID","gain value presented",
  #                                "loss value presented","choice by subject 1: yes 2: rather yes 3: rather no 3: no",
  #                                "reaction time", "category of stimulus 1:gam 2:neg 3:pos 4:neutr 5:Polish neutral 6:weinreich neg 7: weinreich pos 8: weinreich neutr",
  #                                "side: where was the gain value shown?", "how long was the stimulus shown?","age of participant", "sex of partic",
  #                                "gain uncentered", "loss uncentered", "gainxloss agg centered and agg", "gainxloss in orig form","euclidean distance of gamble from gamble matrix diagonal","euclidean distance of gamble from gamble matrix diagonal stand.",
  #                                "expected value of gamble","ratio of gamble options","difference between options","Risk according to Minati", "risk according to Alex G",
  #                                "risk according to Martino","Skew of gamble according to Minati","expected value uncentered",
  #                                "choice dichotomized","bold extracted from ROI z-score_l_precun","bold_post_cing","bold_r_precun","bold_sup_temp","corrugator mean activity","zygomaticus mean activity","eda mean activity","number when picture of this trial was shown in post hoc rating",
  #                                "category of picture but not used anymore","craving for gambling question for picture","representative of gambling question of pic","pic representative for negative consequences of gambling",
  #                                "pic repres for positive consequences of abstaining","pic makes you question your gambling habits?","arousal rating of pic SAM","dominance rating of pic SAM","valence ratings of pic SAM",
  #                                "how many seconds did subject spend on rating (not SAM) this picture","how long did they spend on SAM ratings","arousal rating unstand","valence rating unstand","dominance rating unst",
  #                                "craving for gambling question for picture stand.","representative of gambling question of pic stand.","pic representative for negative consequences of gambling stand.",
  #                                "pic repres for positive consequences of abstaining stand.","pic makes you question gambling stand.","an old image ID vars, not used anymore","question that changed depending on cat, neg, pos, gambling question see above; only used with early subjects",
  #                                "old image ID variable, only useful in processing, not for analysis",
  #                                "fixation cross - number of estimated SCR peaks according to LEDA","fixation cross - latency of first SCR peak (LEDA)","fixation cross - sum of amplitudes of all reconvolved SCR with onset in response window",
  #                                "fixation cross - average phasic driver activity within response window","fixation cross - integrated phasic driver activity within response window","fixation cross - maximum phasic response(?)","fixation cross - tonic response",
  #                                "image stimulus onset - number of estimated SCR peaks according to LEDA","image stimulus onset - latency of first SCR peak (LEDA)","image stimulus onset - sum of amplitudes of all reconvolved SCR with onset in response window",
  #                                "image stimulus onset - average phasic driver activity within response window","image stimulus onset - integrated phasic driver activity within response window","image stimulus onset - maximum phasic response(?)","image stimulus onset - tonic response",
  #                                "gamble onset - number of estimated SCR peaks according to LEDA","gamble onset - latency of first SCR peak (LEDA)","gamble onset - sum of amplitudes of all reconvolved SCR with onset in response window",
  #                                "gamble onset - average phasic driver activity within response window","gamble onset - integrated phasic driver activity within response window","gamble onset - maximum phasic response(?)","gamble onset - tonic response",
  #                                "which part of study was this subject part of","HC or PG according to KFG>16")
  # 
  # 
  # variables_explained_pdt = data.frame(data_pdt_vars,data_pdt_vars_explanations)
  
  if (write_info_mri_selection) {
    # get an MRI Sjinfo for SPM
    cur_MRI        = aggregate(data_pdt[c("HCPG","Cohort")],by=list(data_pdt$subject),FUN=first)
    cur_MRI        = subset(cur_MRI, Cohort == "MRI")
    cur_MRI$Cohort = NULL
    names(cur_MRI) = c("subject","group") 
    cur_MRI$group  = ifelse(cur_MRI$group == "PG",1,0)
    # add the covariates info
    dat_match$edu_years_sum = dat_match$edu_years + dat_match$edu_years_voca 
    cur_MRI                 = merge(cur_MRI,dat_match[c('VPPG','edu_years','smoking_ftdt')],by.x = c('subject'),by.y = c('VPPG'))
    write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
    
    setwd(path_dat)
    write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
    
    setwd(path_dat_GD)
    write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
  }
  
  if (do_save) {
    # save the import
    setwd(path_dat)
    save(file="data_pdt.rda",list = c("data_pdt","dat_match"))
    # save the workspace
    setwd(path_dat)
    save(file="data_pdt_Maja.rda",list = ls())
    
    # get the backup
    data_pdt_bcp = data_pdt
    dat_match_bcp = dat_match
    
    tryCatch({
      if (write_info_mri_selection) {
        # google drive
        setwd(path_dat_GD)
        write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
      }
      setwd(path_dat_GD)
      save(file="data_pdt_Maja.rda",list = ls())
      setwd(path_dat_GD)
      save(file="data_pdt.rda",list = c("data_pdt","dat_match"))
    }, error = function (e) {
      disp('No saving to Google Drive possible.')
    })
  } else {
    message('Saving of data_pdt is off!!!')
  }
} else {
  # import from existing import
  # check what paths work
  path_GD = tryCatch({
    setwd(path_dat_GD)
    path_GD = T
  }, error = function(e) {
    path_GD = F
  })
  
  path_S = tryCatch({
    setwd(path_dat)
    path_SD = T
  }, error = function(e) {
    path_SD = F
  })
  
  if (path_GD == F & path_S == F) {
    stop('Cannot access neither Google Drive nor S:')
  }
  
  if (path_S == T) {
    # access to S:?
    disp('Trying to access S:')
    setwd(path_dat)
    load("data_pdt.rda")
  }
  
  if (path_GD == T & path_S == F) {
    disp('Loading from google drive because S path not accessible.')
    setwd(path_dat_GD)
    load("data_pdt.rda")
  }
  
  # recode MRI
  data_pdt$Cohort = agk.recode(data_pdt$Cohort,'MRT','MRI')
  
  # get an MRI Sjinfo for SPM
  cur_MRI        = aggregate(data_pdt[c("HCPG","Cohort")],by=list(data_pdt$subject),FUN=first)
  cur_MRI        = subset(cur_MRI, Cohort == "MRI")
  cur_MRI$Cohort = NULL
  names(cur_MRI) = c("subject","group") 
  cur_MRI$group  = ifelse(cur_MRI$group == "PG",1,0)
  # add the covariates info
  dat_match$edu_years_sum = dat_match$edu_years + dat_match$edu_years_voca 
  if (write_info_mri_selection) {
    cur_MRI                 = merge(cur_MRI,dat_match[c('VPPG','edu_years','smoking_ftdt')],by.x = c('subject'),by.y = c('VPPG'))
    write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
    
    setwd(path_dat_GD)
    write.table(file="info_mri_selection_30_30.csv",x = cur_MRI,sep = "\t",row.names = F,quote = F)
  }
  
  if (path_S == F) {
    disp('loaded GD data_pdt_bcp, dat_match_bcp')
  }
  
  if (path_GD == T) {
    # save the import
    setwd(path_dat_GD)
    save(file="data_pdt.rda",list = c("data_pdt","dat_match"))
    # save the workspace
    setwd(path_dat_GD)
    save(file="data_pdt_Maja.rda",list = ls())
  }
  
  if (path_S == T) {
    # save the import
    setwd(path_dat)
    save(file="data_pdt.rda",list = c("data_pdt","dat_match"))
    # save the workspace
    setwd(path_dat)
    save(file="data_pdt_Maja.rda",list = ls())
  }
}

# here we will add the ledalab data
# init
data_pdt$SCR          = NULL
data_pdt$SCR_gamble   = NULL
# get data
setwd(path_dat_GD)
leda_dat       = read.table('ledalab_out.csv',sep=',',header=T)
kick_out       = which(names(leda_dat) %in% c('Latency','AmpSum','ISCR','nSCR','PhasicMax','Tonic') == FALSE)
leda_dat       = leda_dat[,kick_out]
leda_dat$VPPG  = agk.recode.c(leda_dat$subject,tnl$PhysioVP,tnl$VPPG)

leda_dat_st    = subset(leda_dat,onset != 'gamble')
leda_dat_gam   = subset(leda_dat,onset == 'gamble')
leda_dat       = leda_dat_st

# change name to SCR_gamble
names(leda_dat_gam)[names(leda_dat_gam) == 'SCR'] = 'SCR_gamble'

kick_out       = which(names(leda_dat) %in% c('subject','onset') == FALSE)
leda_dat       = leda_dat[,kick_out]
leda_dat_gam   = leda_dat_gam[,kick_out]
data_pdt       = merge(data_pdt,leda_dat,by.x = c('subject','trial'),by.y = c('VPPG','trial'),all.x = T,all.y = F)
data_pdt       = merge(data_pdt,leda_dat_gam,by.x = c('subject','trial'),by.y = c('VPPG','trial'),all.x = T,all.y = F)


# scale per subject SCR
all_subs = unique(data_pdt$subject)
for (ss in 1:length(all_subs)) {
  cur_dat                                        = data_pdt$SCR[data_pdt$subject == all_subs[ss]]
  cur_dat                                        = scale(get.log(cur_dat))
  data_pdt$SCR[data_pdt$subject == all_subs[ss]] = cur_dat
  
  cur_dat                                               = data_pdt$SCR_gamble[data_pdt$subject == all_subs[ss]]
  cur_dat                                               = scale(get.log(cur_dat))
  data_pdt$SCR_gamble[data_pdt$subject == all_subs[ss]] = cur_dat
}

# numeric accept_reject (no good!)
if (acc_num == 1) {
  data_pdt$accept_reject = NA
  data_pdt$accept_reject = data_pdt$choice
  data_pdt$accept_reject[data_pdt$accept_reject == 5] = NA
  data_pdt_bcp = data_pdt
}

# correct the Cohort label for MRI
data_pdt$Cohort     = agk.recode(data_pdt$Cohort,c('MRT'),c('MRI'))

# get the MRI features
# loading
setwd(file.path(path_ghb,'PIT_GD/R/analyses/01_classification'))
source("get_phys_and_rating_params_MRI.R")
setwd(file.path(path_ghb,'PIT_GD/R/analyses/01_classification'))

# reducing
if (fmri_extr == 'ngm' | fmri_extr == 'glc') {
  cr_agg_pp_r = cr_agg_pp[c(names(cr_agg_pp)[c(grep('PicGamOnxAccx',names(cr_agg_pp)),grep('PicGamOnxaccX',names(cr_agg_pp)),grep('SS__grp01_noCov_Pic..._ROI_',names(cr_agg_pp)))],names(cr_agg_pp)[c(grep('subject',names(cr_agg_pp)))])]
} else if (fmri_extr == 'val') {
  cr_agg_pp_r = cr_agg_pp[c(names(cr_agg_pp)[c(grep('PicGamOnxvalx',names(cr_agg_pp)),grep('PicGamOnxvalX',names(cr_agg_pp)),grep('SS__grp01_noCov_Pic..._ROI_',names(cr_agg_pp)))],names(cr_agg_pp)[c(grep('subject',names(cr_agg_pp)))])]
}

cr_agg_pp_r = cr_agg_pp_r[grep('SS__.*DRN_8',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__.*AIns',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__.*PIns',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('_BA_',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('_ACgG',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__grp01.*_.OrG',names(cr_agg_pp_r),invert = T)] # OFC none-gppi extracts
cr_agg_pp_r = cr_agg_pp_r[grep('SS__grp01.*_MFC',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__grp01.*_MSFG',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_.*_MFC',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_.*_MSFG',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_.*_full_midbrain',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._Acc.*_._.OrG',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._Acc.*_._Caudate',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._Amy.*_._Amy',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._Acc.*_._Acc',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('.*Caudate$',names(cr_agg_pp_r),invert = T)]
cr_agg_pp_r = cr_agg_pp_r[grep('.*Putamen$',names(cr_agg_pp_r),invert = T)]

# take out PPI StrAs
cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAs',names(cr_agg_pp_r),invert = T)]

# take out StrAs in general
cr_agg_pp_r = cr_agg_pp_r[grep('SS__.*_StrAs',names(cr_agg_pp_r),invert = T)]

# rename
cr_agg_pp_r_MRI = cr_agg_pp_r
rm(list=c('cr_agg_pp_r','cr_agg_pp'))

# allow PPI StrAs but only caudate and putamen split and do not allow self-connectivities
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAs_',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsPut.*_._StrAsPut',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsCaud.*_._StrAsCaud',names(cr_agg_pp_r),invert = T)]
# allow only StrAs to OFC
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsCaud.*_._StrAsPut',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsCaud.*_._Acc',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsCaud.*_._Amy',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsPut.*_._StrAsCaud',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsPut.*_._Acc',names(cr_agg_pp_r),invert = T)]
#cr_agg_pp_r = cr_agg_pp_r[grep('SS__PPI_._StrAsPut.*_._Amy',names(cr_agg_pp_r),invert = T)]


# create bcp for select study and other analysis scripts
data_pdt_bcp  = data_pdt
dat_match_bcp = dat_match

## prep valence and arousal measure peripheral phys
data_pdt$scr_arousal  = data_pdt$SCR
data_pdt$cozy_valence = data_pdt$zygo_auc_stim - data_pdt$corr_auc_stim 

# init of analyses not done yet
init_done = F

## SAVE THE WORKSPACE FOR CLASSIFICATION AND OTHER ANALYSES ===================
# for data release the aggregation needs to be clear
agk.select.aggregation = function(data_pdt,data_release) {
  
  if (data_release == 'behav') {
    # if behav then we do not aggregate
    unagg_names                    = names(data_pdt)[grep('_unagg',names(data_pdt))]
    unagg_names_stripped           = gsub('_unagg','',unagg_names)
    data_pdt[unagg_names_stripped] = NULL
    names(data_pdt)                = gsub('_unagg','',names(data_pdt))
  } else if (data_release == 'MRI') {
    # if MRI then we want the aggr values only
    unagg_names                    = names(data_pdt)[grep('_unagg',names(data_pdt))]
    data_pdt[unagg_names]          = NULL
  } else {
    # do nothing
  }
  return(data_pdt)
}

# saving generally without selecting aggregated or not aggregated
setwd(path_ana)
save.image()

# selecting aggregation according to release
data_pdt = agk.select.aggregation (data_pdt,data_release)

if (data_release == 'behav' | data_release == 'MRI') {
  ## save also to release repository [but discard the cr_agg_pp_r_MRI data, and pp data]
  to_discard = c('zygo_','corr_','eda_','SCR','cozy_')
  for (dd in 1:length(to_discard)) {
    cur_vars_to_disc = grep(to_discard[dd],names(data_pdt))
    data_pdt[cur_vars_to_disc] =  NA
  }
  if (data_release != 'MRI') {
    cr_agg_pp_r_MRI = NA
  }
  setwd(path_ghb)
  # discard all the path information
  rm(list = ls()[grep('path',ls())])
  if (data_release == 'behav') {
    setwd('PIT_GD_bv_release/R/analyses')
  } else {
    ## deleting some more:
    #rm(list = c('dat_match_MRIum','data_pdt_MRIum','data_pdt_PPum','data_pdt_PPum'))
    setwd('PIT_GD_MRI_release/R/analyses')
  }
  save.image()
} else if (data_release == 'none') {
  # do nothing
} else {
  stop('unknown value for data_release')
}





## OLD ========================================================================
# # some descriptives
# data_pdt_agg = aggregate(cbind(age,sex,pilot) ~ subject, data = data_pdt,first)
# describeBy(as.numeric(as.character(data_pdt_agg$age)),group = data_pdt_agg$pilot)
# xtabs(~pilot+sex,data = data_pdt_agg)

## fit behavioral models and export model params for MRI analysis
# path
# if user allows
# source optimization scripts based on data_pdt

# if (get_LAch_for_MRI) {
#   setwd(path_mod)
#   setwd("LA_Charpentier")
#   source("MLE_Charpentier_updated.R")
# }
# 
# if (get_LAch_for_MRI) {
#   setwd(path_mod)
#   setwd("LA_cl")
#   source("MLE_Genauck.R")
# }

# if (get_MRI_extr == 1) {
#   data_pdt_MRI = subset(data_pdt,Cohort== "MRI")
#   bold_overall = aggregate(data_pdt_MRI$bold,by=list(data_pdt_MRI$stim),FUN=median,na.rm=T)
#   names(bold_overall) = c("stim","bold_overall")
#   bold_bygroup = aggregate(data_pdt_MRI$bold,by=list(data_pdt_MRI$stim,data_pdt_MRI$HCPG),FUN=median,na.rm=T)
#   names(bold_bygroup) = c("stim","HCPG","bold_bygroup")
#   data_pdt = merge(data_pdt,bold_overall,by=c("stim"))
#   data_pdt = merge(data_pdt,bold_bygroup,by=c("stim","HCPG"))
#   data_pdt_bcp = data_pdt
#   }


## temp ##
#cur_list = lmList(accept_reject ~ gain + loss |subject, pool =F, na.action = NULL, family = "binomial",data =data_pdt)
#BICtry = function(x) {
#  out <- tryCatch(
#    {
#      BIC(x)
#    },
#    error=function(cond)
#    {
#      NA
#    })
#  return(out)
#}


# for Guillaume
# # BGG study
# setwd('S:/AG/AG-Spielsucht2/Daten/VPPG_Daten/OFC_project_Guillaume/data_sent_to_Guillaume_Sescousse/Data/VPPG/Behav')
# cur_dat = xlsx::read.xlsx("VPPG_01_all_behav_AG.xlsx",1)
# desired_vars=c('VPPG','BIS')
# cur_dat_match = dat_match[desired_vars]
# cur_dat=merge(cur_dat,cur_dat_match,by.x="ID",by.y="VPPG",all.x = T,all.y = F)
# xlsx::write.xlsx(cur_dat,file="VPPG_01_all_behav_AG_ed_2016_11_25.xlsx")

