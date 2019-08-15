## FROM HERE QUEST SPECIFIC ##

# home wd
home_wd = getwd()

# editing the data (code by Milan, edited by AGK)
# data_VPPGc
# variables of interest
# TODO: write so that variables of interest get chosen based on real names in comments
vars_of_int = c('QUESTNNR','P104_01','P106_01','STARTED','FINISHED',
                'LASTPAGE','MAXPAGE','MISSING','MISSREL','DEG_TIME',
                'A101_01','A102','A102_03','A106','A106_06','A109','A113',
                'A113_06','A114_01','A115_01','A135','D101_01','D101_02','D101_03',
                'D101_04','D101_05','D101_06','D101_07','D101_08','D101_09','D101_10',
                'D101_11','D101_12','D101_13','D101_14','D101_15','D202_01','D202_02',
                'D202_03','D202_04','D202_05','D202_06','D202_07','D202_08','D202_09',
                'D202_10','D202_11','D202_12','D202_14','D202_15','D202_16','D202_17',
                'D202_18','D202_19','D202_20','D202_21','D202_22','D301_01','D301_02',
                'D301_03','D301_04','D301_05','D301_06','D301_07','D301_08','D301_09',
                'D301_10','D302','D303','D304','D305','D306','D307_01',
                'D307_02','D307_03','D307_04','D307_05','D307_06','D308_01','D308_02',
                'D308_03','D308_04','D308_05','D308_06','D308_07','D308_08','D308_09',
                'D308_10','D308_11','D309_01','D310_08','D310_09','D401_01',
                'D401_02','D401_03','D401_04','D401_05','D401_06','D401_07','D401_08',
                'D401_09','D401_10','D401_11','D401_12','D401_13','D401_14','D401_15',
                'E101','E102','E103','E104','E105','E106','E107',
                'E108','E109','E110','F101','F102','F103','F104',
                'F105','F106','G101','G102','G103','G104','G105','G106','G107','G108','G109','G110',
                'G111','G112','G113','G114','G115','G116','G117',
                'G118','G119','G120','G121','L101_01','L101_02','L101_03',
                'L101_04','L101_05','L101_06','L101_07','L101_08','L101_09','L101_10',
                'L101_11','L101_12','L101_13','L101_14','L101_15','L101_16','L101_17',
                'L101_18','L101_19','L101_20','L101_21','L101_22','L101_23','L101_24',
                'P101_01','P101_02','P101_03','P101_04','P101_05','P101_06','P101_07',
                'P101_08','P101_08a','P101_09','P101_10','P102','P103',
                'P105','P201_01','P202_01','P203_01','P203_02','P203_03',
                'P203_04','P203_05','P203_06','P203_06a','P204_01','P204_02',
                'P204_03','P204_04','P204_05','P204_06','P205_01','P206_01','P207_01',
                'P207_02','P207_03','P207_04','P207_05','P207_06','P207_06a',
                'P208_01','P208_02','P208_03','P208_04','P208_05','P208_06','TIME_SUM','LASTDATA')

# TODO: check if column names are still the same as oppsoed what I expect them to be JPA can do this;
data_var = data_VPPGc[vars_of_int]

# selecting a specific Cohort
data_A = data_var[data_var$QUESTNNR == 'PGpilotA01',]
# trim the data rows that do not have mandatory answers given
# (questionnaire aborted early) using P101_01 (chosen/not chosen variable)
# (this is a strategy question for PDT)
data_A = data_A[!is.na(data_A$P101_01),]

# check if no more duplicates, else throw error
if (!sum(duplicated(data_A$P104_01)) == 0) {
  warning('In quest import, part data_A: You have a problem with these duplicates!')
  print(data_A$P104_01[duplicated(data_A$P104_01)])
  stop('Unchecked duplicated in questimport, data_A!')
}

# some fewer columns are selected
data_At=data_A[c('P104_01','STARTED','FINISHED',
                 'LASTPAGE','MAXPAGE','MISSING','MISSREL','DEG_TIME',
                 'TIME_SUM','LASTDATA', 'P105','P101_01','P101_02',
                 'P101_03','P101_04','P101_05','P101_06','P101_07',
                 'P101_08','P101_08a','P101_09','P101_10')]

# PGpilotB
data_B = data_var[data_var$QUESTNNR == 'PGpilotB01',]

# trim the data columns that do not belong to the questionnaire
# and trim rows (subs) that do not have mandatory answers given
# (questionnaire aborted early) using the P104_01 (VP number 
# variable), and D101_01 (BIG scale), where answer is mandatory
data_B = data_B[!is.na(data_B$D101_01) & !is.na(data_B$P104_01),]

# check if no more duplicates, else throw errorr
if (!sum(duplicated(data_B$P104_01)) == 0) {
  warning('In quest import, part data_B: You have a problem with these duplicates!')
  print(data_B$P104_01[duplicated(data_B$P104_01)])
  stop('Unchecked duplicated in questimport, data_B!')
}

# data_VPPG02

# bind VPPG02 (SLM questions and ratings in core study) to data_B
# (quest from PGpilotB01)
data_Bt  = rbind.fill(data_B, data_VPPG02c)
col_idx  = grep('P104_01', names(data_Bt))
data_Bt  = data_Bt[, c(col_idx, (1:ncol(data_Bt))[-col_idx])]

# add A,B to variable names, because they come from different quest sessions
data_par = merge(data_At,data_Bt,by='P104_01',all.x =T,all.y=T,
                 suffixes = c('A', 'B'))
for (i in 2 : length(data_Bt)-1) {
  comment(data_par[,i+length(data_At)])= comment(data_Bt[,i+1])
}

# add attributes that are missing (got lost) in data_par from data_Bt
varnames=colnames(data_par)[colnames(data_par) %in% colnames(data_Bt)]
for (i in varnames) {
  eval(parse(text=paste0('attributes(data_par$',i,') = attributes(data_Bt$',i,')')))
}

# retrieve variable labels from comment lines
# using comments from data_VPPG, data_VPPGc
coms                               = c()
data_par_no_coms_found_pre_scoring = c()
ct                                 = 0
data_par_names                     = names(data_par)
for (ii in 1:length(data_par_names)) {
  # what is the current variable
  cur_name = data_par_names[ii]
  
  # will we find the comment in data_par already?
  if (!is.null(comment(data_par[[ii]]))) {
    coms[ii] = comment(data_par[[ii]])
    next
  }
  
  # comments set per default to NULL
  cur_com_VPPG   = NULL
  cur_com_VPPG02 = NULL
  
  # do we find a comment VPPG?
  name_hash_VPPG = which(data_VPPG_names == cur_name)
  if (length(name_hash_VPPG)!=0) {
    cur_com_VPPG = trimws(data_VPPG_comm[[which(data_VPPG_names == cur_name)]])
  }
  
  # do we find a comment in VPPG02?
  name_hash_VPPG02 = which(data_VPPG02_names == cur_name)
  if (length(name_hash_VPPG02)!=0) {
    cur_com_VPPG02 = trimws(data_VPPG02_comm[[which(data_VPPG02_names == cur_name)]])
  }
  
  # if we have found comments in both data.frames
  # make sure they are the same if not throw error
  if (!is.null(cur_com_VPPG) & !is.null(cur_com_VPPG02)) {
    # prep for comparison
    # trim any white space
    cur_com_VPPGt   = gsub(' ','',cur_com_VPPG)
    cur_com_VPPG02t = gsub(' ','',cur_com_VPPG02)
    
    # compare
    if(cur_com_VPPGt != cur_com_VPPG02t) {
      stop('Current comments of data_VPPG and data_VPPG02 are conflicted!')
    } else {
      coms[ii]                = cur_com_VPPG
      comment(data_par[[ii]]) = cur_com_VPPG
    }
  } else if (!is.null(cur_com_VPPG)) {
    coms[ii]                = cur_com_VPPG
    comment(data_par[[ii]]) = cur_com_VPPG
  } else if (!is.null(cur_com_VPPG02)) {
    coms[ii]                = cur_com_VPPG02
    comment(data_par[[ii]]) = cur_com_VPPG02
  } else {
    ct = ct + 1
    data_par_no_coms_found_pre_scoring[ct] = cur_name
  }
}
coms=t(t(coms))

# check if no more duplicates, else throw error
if (!sum(duplicated(data_par$P104_01))== 0) {
  stop(paste('In quest import, part data_par: You have a problem with these duplicates:',
                paste(data_par$P104_01[duplicated(data_par$P104_01)], collapse = ' ')))
}

############################
## SCORING QUESTIONNAIRS  ##
############################

# BIG
# TODO: nicer would be to find the variable names by searching comments!
cur_set = c('D101_01','D101_02','D101_03',
            'D101_04','D101_05','D101_06','D101_07','D101_08','D101_09','D101_10',
            'D101_11','D101_12','D101_13','D101_14','D101_15')
BIG_set = data_par[cur_set]

# find the decoding rule
cur_attr = data_VPPG02_attr$D101_01
cur_levs = names(cur_attr)
cur_levs = cur_levs[!cur_levs %in% c('comment','class')]
cur_labs = as.character(unlist(cur_attr[cur_levs]))
cur_yes  = as.numeric(cur_levs[cur_labs=='ja'])

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# sum score, mean if not more than 10% missing, sum score based on aforementioned mean
data_par$BIG           = rowSums(BIG_set==cur_yes)


data_par$BIG_mean_rmna = apply(BIG_set==cur_yes,MARGIN = 1,
                               FUN = agk.mean.rmna.percent,percent = perc_na_allowed)
data_par$BIG_sum_rmna  = apply(BIG_set==cur_yes,MARGIN = 1,
                               FUN = agk.sum.rmna.percent,percent = perc_na_allowed)
# commenting
base_comment                    = 'Berliner Inventar zum Glücksspielverhalten'
comment(data_par$BIG)           = paste0(base_comment,' Sum')
comment(data_par$BIG_mean_rmna) = paste0(base_comment, ' Mean rm.na ',
                                        perc_na_allowed,'% missing allowed')
comment(data_par$BIG_sum_rmna)  = paste0(base_comment, ' Sum rm.na ',
                                         perc_na_allowed,'% missing allowed')

# GBQ
# TODO: nicer would be to find the variable names by searching comments!
cur_set = c('D202_01','D202_02',
            'D202_03','D202_04','D202_05','D202_06','D202_07','D202_08','D202_09',
            'D202_10','D202_11','D202_12','D202_14','D202_15','D202_16','D202_17',
            'D202_18','D202_19','D202_20','D202_21','D202_22')
GBQ_set = data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# sum score, mean if not more than perc_na_allowed percent missing,
# sum score based on aforementioned mean
data_par$GBQ           = rowSums(GBQ_set)
data_par$GBQ_mean_rmna = apply(GBQ_set,MARGIN = 1,
                               FUN = agk.mean.rmna.percent,percent = perc_na_allowed)
data_par$GBQ_sum_rmna  = apply(GBQ_set,MARGIN = 1,
                              FUN = agk.sum.rmna.percent,percent = perc_na_allowed)
# commenting
base_comment                    = 'Gamblers Belief Questionnaire'
comment(data_par$GBQ)           = paste0(base_comment,' Sum')
comment(data_par$GBQ_mean_rmna) = paste0(base_comment, ' Mean rm.na ',
                                         perc_na_allowed,'% missing allowed')
comment(data_par$GBQ_sum_rmna)  = paste0(base_comment, ' Sum rm.na ',
                                         perc_na_allowed,'% missing allowed')

# SOGS
cur_set  = c('D304','D305','D306','D307_01',
            'D307_02','D307_03','D307_04','D307_05','D308_01','D308_02',
            'D308_03','D308_04','D308_05','D308_06','D308_07','D308_08','D308_09',
            'D309_01','D310_08','D310_09')
SOGS_set = data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# scoring
# TODO: get the codes from comment; here by hand adapted from MAH by AGK
sss = SOGS_set
SOGS_ones=data.frame()
q4=c()
q4[sss$D304!='nie'] = 1
SOGS_ones=data.frame(q4)
SOGS_ones$q5[sss$D305       != 'nie (oder nie gespielt)'] = 1
SOGS_ones$q6[sss$D306       != 'nein']= 1
SOGS_ones$q7[sss$D307_01    == 2] = 1
SOGS_ones$q8[sss$D307_02    == 2] = 1
SOGS_ones$q9[sss$D307_03    == 2] = 1
SOGS_ones$q10[sss$D307_04   == 2] = 1
SOGS_ones$q11[sss$D307_05   == 2] = 1
SOGS_ones$q12[sss$D309_01   == 2] = 1
SOGS_ones$q13[sss$D310_08   == 2] = 1
SOGS_ones$q14[sss$D310_09   == 2] = 1
SOGS_ones$q15[sss$D308_01   == TRUE] = 1
SOGS_ones$q16a[sss$D308_02  == TRUE] = 1
SOGS_ones$q16b[sss$D308_03  == TRUE] = 1
SOGS_ones$q16c[sss$D308_04  == TRUE] = 1
SOGS_ones$q16d[sss$D308_05  == TRUE] = 1
SOGS_ones$q16e[sss$D308_06  == TRUE] = 1
SOGS_ones$q16f[sss$D308_07  == TRUE] = 1
SOGS_ones$q16g[sss$D308_08  == TRUE] = 1
SOGS_ones$q16h[sss$D308_09  == TRUE] = 1
SOGS_ones[is.na(SOGS_ones)] = 0

# sum score, mean if not more than perc_na_allowed percent missing,
# sum score based on aforementioned mean
data_par$SOGS           = rowSums(SOGS_ones)
data_par$SOGS_mean_rmna = apply(SOGS_ones,MARGIN = 1,
                               FUN = agk.mean.rmna.percent,percent = perc_na_allowed)
data_par$SOGS_sum_rmna  = apply(SOGS_ones,MARGIN = 1,
                               FUN = agk.sum.rmna.percent,percent = perc_na_allowed)

# commenting
base_comment                     = 'South Oaks Gambling Screen'
comment(data_par$SOGS)           = paste0(base_comment,' Sum')
comment(data_par$SOGS_mean_rmna) = paste0(base_comment, ' Mean rm.na ',
                                         perc_na_allowed,'% missing allowed')
comment(data_par$SOGS_sum_rmna)  = paste0(base_comment, ' Sum rm.na ',
                                         perc_na_allowed,'% missing allowed')

# AUDIT
cur_set = c('E101','E102','E103','E104','E105','E106','E107',
            'E108','E109','E110')
AUDIT_set=data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# scoring AUDIT
AUDIT_set_w = AUDIT_set
# replace NAs
AUDIT_set_w[is.na(AUDIT_set_w)] = NA
cur_f = function(x) {return(length(levels(x)))}
if (!all(unlist(lapply(AUDIT_set_w[c(1:8)],cur_f)) == 6)) {
  stop('Unexpected amount of levels encountered in AUDIT quest data')
}
if (!all(unlist(lapply(AUDIT_set_w[c(9:10)],cur_f)) == 4)) {
  stop('Unexpected amount of levels encountered in AUDIT quest data')
}
# make numeric
AUDIT_num = sapply(AUDIT_set_w, as.numeric)-1
# set to 0 if first question is zero
for (ll in 1:length(AUDIT_num[,1])) {
  if (is.na(AUDIT_num[ll,1])) {next}
  if (AUDIT_num[ll,1] == 0) {
    AUDIT_num[ll,] = 0
  }
}

AUDIT_num[,9][AUDIT_num[,9]==1]   = 2
AUDIT_num[,9][AUDIT_num[,9]==2]   = 4
AUDIT_num[,10][AUDIT_num[,10]==1] = 2
AUDIT_num[,10][AUDIT_num[,10]==2] = 4

# TODO: do not get the mah.sum0 function yet; and how to deal with NAs
data_par$AUDIT = apply(AUDIT_num,1, mah.sum0)
comment(data_par$AUDIT)='Alcohol Use Disorders Identification Test Sum0'

# FTND
# THIS IS WRONG, GETS CORRECTED IN data_import
# TODO: fix already here, but somehow works different here than in data_import.R
# TODO: deal with NAs as above in other questionnaires
cur_set = c('F101','F102','F103','F104','F105','F106')
FTND_set=data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

FTND_num=(sapply(FTND_set, as.numeric))*-1+4
FTND_num[is.na(FTND_num)]=0
data_par$FTND=rowSums(FTND_num)
comment(data_par$FTND)='Fagerström Test for Nicotine Dependence Sum'

# BDI
cur_set = c('G101','G102','G103','G104','G105','G106','G107','G108','G109','G110',
            'G111','G112','G113','G114','G115','G116','G117',
            'G118','G119','G120','G121')
BDI_set = data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# scoring
BDI_num = (sapply(BDI_set, as.numeric))-1
BDI_num[,16][BDI_num[,16]==2]=1
BDI_num[,16][BDI_num[,16]==3]=2
BDI_num[,16][BDI_num[,16]==4]=2
BDI_num[,16][BDI_num[,16]==5]=3
BDI_num[,16][BDI_num[,16]==6]=3
BDI_num[,18][BDI_num[,18]==2]=1
BDI_num[,18][BDI_num[,18]==3]=2
BDI_num[,18][BDI_num[,18]==4]=2
BDI_num[,18][BDI_num[,18]==5]=3
BDI_num[,18][BDI_num[,18]==6]=3

data_par$BDI = rowSums(BDI_num)
comment(data_par$BDI)='Beck Depression Inventory II'

# LOC
cur_set = c('L101_01','L101_02','L101_03',
            'L101_04','L101_05','L101_06','L101_07','L101_08','L101_09','L101_10',
            'L101_11','L101_12','L101_13','L101_14','L101_15','L101_16','L101_17',
            'L101_18','L101_19','L101_20','L101_21','L101_22','L101_23','L101_24')
LOC_set = data_par[cur_set]

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

LOC_num = (sapply(LOC_set, as.numeric))-4

data_par$LOC_Internal=rowSums(LOC_num[, c(1, 4, 5, 9, 18, 19, 21,23)])+24
data_par$LOC_PowerfulOthers=rowSums(LOC_num[, c(3, 8, 11, 13, 15, 17, 20, 22)])+24
data_par$LOC_Chance=rowSums(LOC_num[, c(2, 6, 7, 10, 12, 14, 16, 24)])+24

comment(data_par$LOC_Internal)='LOC - Internal Locus of Control'
comment(data_par$LOC_PowerfulOthers)='LOC - Powerful Others'
comment(data_par$LOC_Chance)='LOC - Chance'

# BIS
cur_set = c('D401_01','D401_02','D401_03','D401_04','D401_05','D401_06','D401_07','D401_08',
            'D401_09','D401_10','D401_11','D401_12','D401_13','D401_14','D401_15')
BIS_set = data_par[cur_set]
BIS_num = (sapply(BIS_set, as.numeric))

# attach the attributes
# for (ii in 1:length(cur_set)) {
#   attributes(data_par[cur_set[ii]]) = data_VPPG02_attr[cur_set[ii]]
# }

# BIS was already inverted in SoSci
data_par$BIS=rowSums(BIS_num)
data_par$BIS_Mot=rowSums(BIS_num[, c(1,2,3,4,5)])
data_par$BIS_NPlanImp=rowSums(BIS_num[, c(6,7,8,9,10)])
data_par$BIS_AmBasImp=rowSums(BIS_num[, c(11,12,13,14,15)])

comment(data_par$BIS)='Barratt Impulsiveness Scale 15'
comment(data_par$BIS_Mot)='BIS 15 - Subskala motorische Impulsivität'
comment(data_par$BIS_NPlanImp)='BIS 15 - Subskala nicht-planende Impulsivität'
comment(data_par$BIS_AmBasImp)='BIS 15 - Subskala aufmerksamkeitsbasierte Impulsivität'
comment(data_par$P105A)='gamblingThumbRule: Spielen Sie regelmäßig um Geld?'
comment(data_par$TIME_RSI)='Maluspunkte für schnelles Ausfüllen'

# retrieve variable labels from comment lines
# using comments from data_VPPG, data_VPPGc
# TODO: check if names in both data.frames mean the same
coms                   = c()
data_par_no_coms_found = c()
ct                     = 0
data_par_names         = names(data_par)
for (ii in 1:length(data_par_names)) {
  # what is the current variable
  cur_name = data_par_names[ii]
  
  # will we find the comment in data_par already?
  if (!is.null(comment(data_par[[ii]]))) {
    coms[ii] = comment(data_par[[ii]])
    next
  }
  
  # comments set per default to NULL
  cur_com_VPPG   = NULL
  cur_com_VPPG02 = NULL
  
  # do we find a comment VPPG?
  name_hash_VPPG = which(data_VPPG_names == cur_name)
  if (length(name_hash_VPPG)!=0) {
    cur_com_VPPG = trimws(data_VPPG_comm[[which(data_VPPG_names == cur_name)]])
  }
  
  # do we find a comment in VPPG02?
  name_hash_VPPG02 = which(data_VPPG02_names == cur_name)
  if (length(name_hash_VPPG02)!=0) {
    cur_com_VPPG02 = trimws(data_VPPG02_comm[[which(data_VPPG02_names == cur_name)]])
  }
  
  # if we have found comments in both data.frames
  # make sure they are the same if not throw error
  if (!is.null(cur_com_VPPG) & !is.null(cur_com_VPPG02)) {
    # prep for comparison
    # trim any white space
    cur_com_VPPGt   = gsub(' ','',cur_com_VPPG)
    cur_com_VPPG02t = gsub(' ','',cur_com_VPPG02)
    
    # compare
    if(cur_com_VPPGt != cur_com_VPPG02t) {
      stop('Current comments of data_VPPG and data_VPPG02 are conflicted!')
    } else {
      coms[ii]                = cur_com_VPPG
      comment(data_par[[ii]]) = cur_com_VPPG
    }
  } else if (!is.null(cur_com_VPPG)) {
    coms[ii]                = cur_com_VPPG
    comment(data_par[[ii]]) = cur_com_VPPG
  } else if (!is.null(cur_com_VPPG02)) {
    coms[ii]                = cur_com_VPPG02
    comment(data_par[[ii]]) = cur_com_VPPG02
  } else {
    ct = ct + 1
    data_par_no_coms_found[ct] = cur_name
  }
}
#if (ct > 0) {warning(paste('Comments for these vars in data_par not found:',
#                           paste(data_par_no_coms_found,collapse=' ')))}
coms=t(t(coms))

# create an easily readable excel sheet
# and save the R data frame
wb    = createWorkbook(type='xlsx')
sheet = createSheet(wb, sheetName = 'Questionnaire Data')
addDataFrame(x = coms, sheet, row.names = FALSE, col.names=FALSE, startRow = 1)
addDataFrame(x = data_par, sheet, row.names = FALSE, startRow = 2)
saveWorkbook(wb, paste0(path_rslt,'/',fNameBase, '_Data-label.xlsx'))
save(data_par, file = paste0(path_rslt,'/',fNameBase, '_Data-label.RData'))

# give useful names to the BIG and GBQ sets
BIG = mah.dfRenameQ(BIG_set,'BIG')
GBQ = mah.dfRenameQ(GBQ_set,'GBQ')

# ??? make a SOGS df?
# what is this for?
SOGS_1a  = data_par$D301_01
SOGS_1b  = data_par$D301_02
SOGS_1c  = data_par$D301_03
SOGS_1d  = data_par$D301_04
SOGS_1e  = data_par$D301_05
SOGS_1f  = data_par$D301_06
SOGS_1g  = data_par$D301_07
SOGS_1h  = data_par$D301_08
SOGS_1i  = data_par$D301_09
SOGS_1j  = data_par$D301_10
SOGS_2   = data_par$D302
SOGS_3   = data_par$D303
SOGS_4   = data_par$D304
SOGS_5   = data_par$D305
SOGS_6   = data_par$D306
SOGS_7   = data_par$D307_01
SOGS_8   = data_par$D307_02
SOGS_9   = data_par$D307_03
SOGS_10  = data_par$D307_04
SOGS_11  = data_par$D307_05
SOGS_12  = data_par$D307_06
SOGS_13  = data_par$D309_01
SOGS_14  = data_par$D310_08
SOGS_15  = data_par$D310_09
SOGS_16a = data_par$D308_01
SOGS_16b = data_par$D308_02
SOGS_16c = data_par$D308_03
SOGS_16d = data_par$D308_04
SOGS_16e = data_par$D308_05
SOGS_16f = data_par$D308_06
SOGS_16g = data_par$D308_07
SOGS_16h = data_par$D308_08
SOGS_16i = data_par$D308_09
SOGS_16j = data_par$D308_10
SOGS_16k = data_par$D308_11
SOGS     = data.frame(SOGS_1a, SOGS_1b, SOGS_1c, SOGS_1d, SOGS_1e, SOGS_1f,
                SOGS_1g, SOGS_1h, SOGS_1i, SOGS_1j,
                SOGS_2, SOGS_3, SOGS_4, SOGS_5, SOGS_6, SOGS_7, SOGS_8,
                SOGS_9, SOGS_10, SOGS_11, SOGS_12, SOGS_13, SOGS_14, SOGS_15,
                SOGS_16a, SOGS_16b, SOGS_16c, SOGS_16d, SOGS_16e, SOGS_16f,
                SOGS_16g, SOGS_16h, SOGS_16i, SOGS_16j, SOGS_16k)

# useful names to AUDIT/FTND/BDI
AUDIT = mah.dfRenameQ(AUDIT_set,'AUDIT')
FTND  = mah.dfRenameQ(FTND_set,'FTND')
BDI   = mah.dfRenameQ(BDI_set,'BDI') # BDI comments are still here

# LOC scale 'I'
LOC_I = LOC_set[, c(1, 4, 5, 9, 18, 19, 21,23)]
LOC_I = mah.dfRenameQ(LOC_I ,'LOC_I')

# LOC scale 'A'
LOC_A = LOC_set[, c(3, 8, 11, 13, 15, 17, 20, 22)]
LOC_A = mah.dfRenameQ(LOC_A ,'LOC_A')

# LOC scale 'Z'
LOC_Z = LOC_set[, c(2, 6, 7, 10, 12, 14, 16, 24)]
LOC_Z = mah.dfRenameQ(LOC_Z ,'LOC_Z')

# rename LOC and BIS usefully
LOC   = mah.dfRenameQ(LOC_set,'LOC')
BIS   = mah.dfRenameQ(BIS_set,'BIS')

# SLM data frame
SLM1_1  = data_par$P201_01
SLM1_2  = data_par$P202_01
SLM1_3a = data_par$P203_01
SLM1_3b = data_par$P203_02
SLM1_3c = data_par$P203_03
SLM1_3d = data_par$P203_04
SLM1_3e = data_par$P203_05
SLM1_3f = data_par$P203_06
SLM1_3g = data_par$P203_06a
SLM1_4  = data_par$P204_01
SLM1_5  = data_par$P204_02
SLM1_6  = data_par$P204_03
SLM1_7  = data_par$P204_04
SLM1_8  = data_par$P204_05
SLM1_9  = data_par$P204_06
SLM2_1  = data_par$P205_01
SLM2_2  = data_par$P206_01
SLM2_3a = data_par$P207_01
SLM2_3b = data_par$P207_02
SLM2_3c = data_par$P207_03
SLM2_3d = data_par$P207_04
SLM2_3e = data_par$P207_05
SLM2_3f = data_par$P207_06
SLM2_3g = data_par$P207_06a
SLM2_4  = data_par$P208_01
SLM2_5  = data_par$P208_02
SLM2_6  = data_par$P208_03
SLM2_7  = data_par$P208_04
SLM2_8  = data_par$P208_05
SLM2_9  = data_par$P208_06
SLM     = data.frame(SLM1_1, SLM1_2, SLM1_3a, SLM1_3b, SLM1_3c, SLM1_3d, SLM1_3e,
               SLM1_3f, SLM1_3g,
               SLM1_4, SLM1_5, SLM1_6, SLM1_7, SLM1_8, SLM1_9,
               SLM2_1, SLM2_2, SLM2_3a, SLM2_3b, SLM2_3c, SLM2_3d, SLM2_3e,
               SLM2_3f, SLM2_3g,
               SLM2_4, SLM2_5, SLM2_6, SLM2_7, SLM2_8, SLM2_9)

data_q    = data.frame(data_par$P104_01, BIG, GBQ, SOGS, AUDIT, FTND, BDI, LOC_I, LOC_A, LOC_Z, BIS, SLM)

# TODO: here the summed questionnaires with NA removed aren't exported yet
data_rest = data_par[c('STARTEDA', 'FINISHEDA', 'LASTPAGEA', 'MAXPAGEA', 'MISSINGA', 'MISSRELA',
                      'DEG_TIMEA', 'TIME_SUMA', 'LASTDATAA',
                      'P105A', 'P101_01A', 'P101_02A', 'P101_03A', 'P101_04A', 'P101_05A', 'P101_06A',
                      'P101_07A', 'P101_08A', 'P101_08aA', 'P101_09A', 'P101_10A',
                      'QUESTNNR', 'P101_04B', 'STARTEDB', 'FINISHEDB', 'LASTPAGEB', 'MAXPAGEB',
                      'MISSINGB', 'MISSRELB',  'DEG_TIMEB',
                      'A101_01', 'A102', 'A102_03', 'A106', 'A106_06', 'A109',
                      'A113', 'A113_06', 'A114_01', 'A115_01', 'A135',
                      'TIME_SUMB', 'LASTDATAB',
                      'BIG', 'GBQ', 'SOGS', 'AUDIT', 'FTND', 'BDI', 'LOC_Internal', 'LOC_PowerfulOthers',
                      'LOC_Chance', 'BIS', 'BIS_Mot', 'BIS_NPlanImp', 'BIS_AmBasImp')]

# Strategy questions
names(data_rest)[names(data_rest)=='P101_01A']  = 'PDT_stra_winn'
names(data_rest)[names(data_rest)=='P101_02A']  = 'PDT_stra_loss'
names(data_rest)[names(data_rest)=='P101_03A']  = 'PDT_stra_substract'
names(data_rest)[names(data_rest)=='P101_04A']  = 'PDT_stra_divide'
names(data_rest)[names(data_rest)=='P101_05A']  = 'PDT_stra_maxloss'
names(data_rest)[names(data_rest)=='P101_06A']  = 'PDT_stra_minwinn'
names(data_rest)[names(data_rest)=='P101_07A']  = 'PDT_stra_20eur'
names(data_rest)[names(data_rest)=='P101_09A']  = 'PDT_stra_distribution'
names(data_rest)[names(data_rest)=='P101_10A']  = 'PDT_stra_smallChanges'
names(data_rest)[names(data_rest)=='P101_08A']  = 'PDT_stra_other'
names(data_rest)[names(data_rest)=='P101_08aA'] = 'PDT_stra_other_freetext'

# Demographics
names(data_rest)[names(data_rest)=='A101_01'] = 'dem_age'
names(data_rest)[names(data_rest)=='A102']    = 'dem_gender'
names(data_rest)[names(data_rest)=='A102_03'] = 'dem_gender_other'
names(data_rest)[names(data_rest)=='A106']    = 'dem_familyStat'
names(data_rest)[names(data_rest)=='A106_06'] = 'dem_familyStat_other'
names(data_rest)[names(data_rest)=='A109']    = 'dem_edu_bildungsgrad'
names(data_rest)[names(data_rest)=='A113']    = 'dem_occupation'
names(data_rest)[names(data_rest)=='A113_06'] = 'dem_occupation_other'
names(data_rest)[names(data_rest)=='A114_01'] = 'dem_houseIncome'
names(data_rest)[names(data_rest)=='A115_01'] = 'dem_housePpl'
names(data_rest)[names(data_rest)=='A135']    = 'dem_smoke'
names(data_rest)[names(data_rest)=='P105A']   = 'dem_gamRuleOfThumb'

# combining
data_quest = data.frame(data_q, data_rest)

# check if no more duplicates, else throw error
if (!sum(duplicated(data_quest$data_par.P104_01)) == 0) {
  warning(paste('In quest import, part data_quest: You have a problem with these duplicates!',
                data_quest$data_par.P104_01[duplicated(data_quest$data_par.P104_01)]))
  stop('Unchecked duplicated in questimport, data_quest!')
}

# Check if all subjects in TN-List have questionnaires
gqs_subs = data_quest$data_par.P104_01
no_quest = tnl$VPPG[!trimws(tnl$VPPG) %in% trimws(gqs_subs)]

# check against exception list (acceptable no questionnaire)
no_quest          = no_quest[!no_quest %in% quest_exempt_list]

# Report
# TODO: later into report PDF for overall SoSci export
if (length(no_quest)) {
  warning(paste('No questionnaires exported for these non-exempt subjects:',
                as.character(no_quest)))
} else {
  print('All expected questionnaires have been exported from SoSci.')
}

if (check_against_oldDB) {
  # check against oldDB
  e = new.env()
  load(path_oldDB,e)
  dqn = data_quest
  dqo = e$data_quest
  # load only the subjects that both df's have
  dqn = dqn[which(dqn$data_par.P104_01 %in% dqo$data_par.P104_01),]
  dqo = dqo[which(dqo$data_par.P104_01 %in% dqn$data_par.P104_01),]
  if (mean(dqo$data_par.P104_01==dqo$data_par.P104_01) != 1) {
    stop('Subjects of old an new quest export do not align. Cannot check export consistency.')
  }
  if (mean(names(dqo)==names(dqn)) != 1) {
    stop('Variables of old an new quest export do not align. Cannot check export consistency.')
  }
  # cutting out exempt subjects
  dqn = dqn[which(!dqn$data_par.P104_01 %in% exempt_from_oldDB_chksb),]
  dqo = dqo[which(!dqo$data_par.P104_01 %in% exempt_from_oldDB_chksb),]
  
  dqob = dqo
  dqnb = dqn
  
  # testing match of old and new export
  cur_match = c()
  for (ii in 1:length(names(dqn))) {
    # is the check exempt?
    if (names(dqn[ii]) %in% exempt_from_oldDB_check) {
      cur_match[ii] = NaN
      next
    }
    # get current relevant attributes:
    cur_attr = attributes(dqn[[ii]])
    cur_attr = cur_attr[!names(cur_attr) %in% c('comment','class')]
    if (length(cur_attr) != 0) {
      if (!"levels" %in% names(cur_attr)) {
        cur_codes  = names(cur_attr)
        label_list = as.character(unlist(cur_attr))
        dqo[[ii]]  = agk.recode(dqo[[ii]],label_list,cur_codes) 
      }
    } else if (mean(agk.unique.narm(dqn[[ii]]) %in% c(1,2)) == 1) {
      # no attributes but it is a 1,2 question, then this is the meaning:
      # TODO GET THESE ATTRIBUTES EXPORTED
      dqo[[ii]] = agk.recode(dqo[[ii]],c('ja','nein'),c(2,1))
    }
    
    # trouble with euro signs when using oldDB
    # and with dash, hyphen, minus
    dqo[[ii]] = gsub('?','',x = dqo[[ii]],fixed = T)
    dqn[[ii]] = gsub('€','',x = dqn[[ii]],fixed = T)
    dqo[[ii]] = gsub('-','',x = dqo[[ii]],fixed = T)
    dqn[[ii]] = gsub('-','',x = dqn[[ii]],fixed = T)
    dqo[[ii]] = gsub(' ','',x = dqo[[ii]],fixed = T)
    dqn[[ii]] = gsub(' ','',x = dqn[[ii]],fixed = T)
    x = "zwischen1–10"
    dqn[[ii]] = gsub(x,replacement = 'zwischen110',dqn[[ii]])
    dqn[[ii]] = gsub('–',replacement = '',dqn[[ii]])
    
    # converting NA to "NA"
    dqn[[ii]] = as.character(dqn[[ii]])
    dqo[[ii]] = as.character(dqo[[ii]])
    dqn[[ii]][is.na(dqn[[ii]])] = 'NA'
    dqo[[ii]][is.na(dqo[[ii]])] = 'NA'
    dqn[[ii]] = gsub('[NA]nichtbeantwortet',replacement = 'NA',dqn[[ii]],fixed=T)
    
    # checking match
    cur_match[ii] = mean(as.character(dqn[[ii]]) == as.character(dqo[[ii]]))
    print(which(!as.character(dqn[[ii]]) == as.character(dqo[[ii]])))
  }
  
  # summary cur_match
  print('Ignoring these variables when checking against old DB:')
  print(exempt_from_oldDB_check)
  cur_match_ne = subset(cur_match,!is.nan(cur_match))
  if(sum(is.na(cur_match_ne)) != 0) {
    stop('Match with oldDB yielded unexpected NAs. Go check!!!')
  }
  if(mean(cur_match_ne == 1) == 1) {
    print('Match with oldDB is perfect on non-exempt variables and subjects.')
  } else {
    stop('Match with oldDB is imperfect. Go and check!')
  }
  
  # Report on match with oldDB
  print('Careful and check: BIG is exempt from check against oldDB because it seemed to have been tallied up wrong there.')
  print('Careful and check: SOGS is exempt from check against oldDB because it seemed to have been tallied up wrong there.')
}

# check if there are missing comments
got_attr         = lapply(data_quest,FUN=comment)
att_null         = as.logical(unlist(lapply(got_attr,FUN=is.null)))
att_null         = names(got_attr)[att_null]
# what of those are in data_par?
data_par_attsel  = data_par[names(data_par)[names(data_par) %in% att_null]]
dp_comments      = lapply(data_par_attsel,comment)
# what of those are in data_rest?
data_rest_attsel = data_rest[names(data_rest)[names(data_rest) %in% att_null]]
dr_comments      = lapply(data_rest_attsel,comment)
needed_comments  = c(dp_comments,dr_comments)
if (length(needed_comments) != 0) {
  for (ii in 1:length(needed_comments)) {
    comment(data_quest[[names(needed_comments)[ii]]]) = needed_comments[[ii]]
  }
}

# some comments filled in by hand
comment(data_quest$data_par.P104_01) = comment(data_par$P104_01)

# check again
got_attr         = lapply(data_quest,FUN=comment)
att_null         = as.logical(unlist(lapply(got_attr,FUN=is.null)))
att_null         = names(got_attr)[att_null]
if (length(att_null) != 0) {
  stop('Not all variables in the final data_quest have comments! Please check!')
}

# final save
save(data_quest, file = paste0(path_rslt, '/',fNameBase, '.Rda'))
save(data_quest, file = paste0(path_rslt, '/','Bilderrating_VPPG_Quest.Rda'))
print('Export questionnaires successfully completed and saved!')

# go home
setwd(home_wd)