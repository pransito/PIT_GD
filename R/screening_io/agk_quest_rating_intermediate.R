###############################
## intermediate higher order ##
###############################

## FROM HERE ON IT IS READING IN VPPG AND VPPG02 PERTAINING TO QUEST AND RATING ##
## BEGIN INTERMEDIATE HIGHER ORDER ##

# report
print('Beginning read-in quest and ratings data.')

# import the data as done by sosci scripts
# start with Bilderrating_VPPG
# go to folder
setwd(path_data)
imp_data = list()
# patterns for import scripts and csv's
pats     = c('import_Bilderrating_VPPG_',
             'import_Biderrating_VPPG02_')
pats_csv = c('rdata_Bilderrating_VPPG_',
             'rdata_Biderrating_VPPG02_')

for (ii in 1:length (pats)) {
  # read in script as string and change the first few lines
  # so that no more user interaction is required
  cur_file = dir(pattern = pats[ii])
  cur_csv  = dir(pattern = '.csv')
  cur_csv  = cur_csv[grep(pats_csv[ii],cur_csv)]
  mystring = read_file(cur_file)
  tbrep_1  = 'data_file = file.choose()\r\n'
  tbrep_2  = '# setwd(\"./\")\r\n'
  # for thbrep_3 we need to use regexp
  # times of download can be a bit off and 
  # then requested data file in R import
  # script is wrong, making it flexible here
  tbrep_3  = regexpr('\"rdata_.*csv',mystring)
  tbrep_3  = substr(mystring,tbrep_3[1],
                    tbrep_3[1]+attr(tbrep_3,'match.length'))
  tbrep_4  = '# data_file = '
  
  # replacement strings for the R import script
  rep_1    = ''
  rep_2    = 'setwd(\"./\")\r\n'
  rep_3    = paste0('\"',cur_csv,'\"')
  rep_4    = 'data_file = '
  # doing the replacements
  mystring = gsub(tbrep_1,rep_1,mystring,fixed = T)
  mystring = gsub(tbrep_2,rep_2,mystring,fixed = T)
  mystring = gsub(tbrep_3,rep_3,mystring,fixed = T)
  mystring = gsub(tbrep_4,rep_4,mystring,fixed = T)
  # removing carriage returns cause we have \n already
  # for every line break
  mystring = gsub('\r','',mystring,fixed = T)
  
  # evaluating the code in mystring
  eval(parse(text=mystring))
  # writing the current import script with changes
  #write(mystring, 'quest_temp.R')
  # running the current import script
  #source('quest_temp.R')
  imp_data[[ii]] = data
  #file.remove('quest_temp.R')
  
  # get the fNameBase
  if (ii == 1) {
    tmp        = strsplit(cur_file,'_VPPG_')
    tmp        = strsplit(tmp[[1]][2],'_')
    fNameBase  = paste0('Bilderrating_VPPG_',tmp[[1]][1],'_Questionnaires')
  }
}

data_VPPG   = imp_data[[1]] # Milan's "data"
data_VPPG02 = imp_data[[2]] # Milan's "data_VPPG02"
rm(list = c('imp_data'))

# in case something gets lost on the way we save here attributes
# (which include comments)
# comments explain the variable/give verbatim question
# attributes store levels and labels of factors
data_VPPG_names   = names(data_VPPG)
data_VPPG02_names = names(data_VPPG02)
data_VPPG_attr    = lapply(data_VPPG,attributes)
data_VPPG02_attr  = lapply(data_VPPG02,attributes)

# comments
data_VPPG_comm    = lapply(data_VPPG,comment)
data_VPPG02_comm  = lapply(data_VPPG02,comment)

# BEGIN CLEANING SUBJECTS
# intermediate higher order: this section and also everything above is needed for both
# questionnaires and ratings export; this means create an overall higher order script, which
# operates the screening and the intermediate higher order (prep quest and ratings and execute)
# the prepatory higher order is a script which has everything above and the following section
# this prepatory scripts prepares the quest export and the ratings export by reading in data
# and cleaning the subjects
# data_VPPGc is data_VPPG but with cleaned subjects
# data_VPPG02c is data_VPPG02 but with cleaned subjects

# kick out NA subs
data_VPPGc = data_VPPG[!is.na(data_VPPG$P104_01),]

# trim white space
data_VPPGc$P104_01=sub(' ', '', data_VPPGc$P104_01)

# the NAPS study gets its own code
# TODO: what is this cohort?!?!
cur_rep = paste0('baseNAPS',data_VPPGc$P104_01[data_VPPGc$QUESTNNR == 'baseNAPS01'])
data_VPPGc$P104_01[data_VPPGc$QUESTNNR == 'baseNAPS01'] = cur_rep

## DANGEROUS CODE CAUSE IT USES ABSOLUTE ROW NUMBERS

# trim the rest of the data rows that were made by us testing the questionnaire 
# each line was checked against the Teilnehmerliste and all the relevant questionnaires
# were kept and the list of lines to delete is:
# CUT AWAY: 572-583, 628, 638, 646, 801, 818, 840-842
rmrows     = c(572:574, 576:583, 628, 638, 646, 801, 805, 818, 824, 834, 840:842,877,892, 921,924, 926, 933, 934, 937, 946)
data_VPPGc = data_VPPGc[!rownames(data_VPPGc) %in% as.character(rmrows), ]
data_VPPGc = mah.subset.preserve(data_VPPGc, !rownames(data_VPPGc) %in% as.character(rmrows))

## DANGEROUS CODE CAUSE IT USES ABSOLUTE ROW NUMBERS

# THIS IS THE SECTION TO WRITE ABSOLUTE CODE
# TO DEAL WITH DUPLICATES, add a line of code if necessary
# repair the id variable (by Milan)
# Alex: did not change it; it is ugly because
# again absolute row.names (but this is a stable primary key, at least in this data.frame)
# but it seems to work
# TODO: use Teilnehmerliste to do away with doings things by hand
cur_cond = as.numeric(rownames(data_VPPGc))<702 & data_VPPGc$QUESTNNR != 'baseNAPS01'
cur_rep  = paste0('PhysioVP', data_VPPGc$P104_01[cur_cond])
data_VPPGc$P104_01[cur_cond] = cur_rep
cur_row_names = c(761, 778,779,785:814,819,822, 835,837,852,865,866,884)
cur_rep       = paste0('VPPG', data_VPPGc$P104_01[is.element(as.numeric(rownames(data_VPPGc)),cur_row_names)])
data_VPPGc$P104_01[is.element(as.numeric(rownames(data_VPPGc)),cur_row_names)]= cur_rep
data_VPPGc$P104_01[rownames(data_VPPGc)=='830'] = paste0('PhysioVP',data_VPPGc$P104_01[rownames(data_VPPGc)=='830'])
data_VPPGc$P104_01[rownames(data_VPPGc)=='836'] = paste0('PhysioVP',data_VPPGc$P104_01[rownames(data_VPPGc)=='836'])
data_VPPGc$P104_01[rownames(data_VPPGc)=='844'] = paste0('PhysioVP',data_VPPGc$P104_01[rownames(data_VPPGc)=='844'])
data_VPPGc$P104_01[rownames(data_VPPGc)=='802'] = paste0(data_VPPGc$P104_01[rownames(data_VPPGc)=='802'],'b')

# observing the Teilnehmerliste and the data_VPPGc Milan found also
# that the following rows need to be repaired
data_VPPGc$P104_01[rownames(data_VPPGc)=='762'] = 'VPPG0037'
data_VPPGc$P104_01[rownames(data_VPPGc)=='855'] = 'VPPG0001b'
data_VPPGc$P104_01[rownames(data_VPPGc)=='883'] = 'VPPG0112'
data_VPPGc$P104_01[rownames(data_VPPGc)=='890'] = 'VPPG0044'
data_VPPGc$P104_01[rownames(data_VPPGc)=='939'] = 'VPPG0712'
data_VPPGc$P104_01[rownames(data_VPPGc)=='940'] = 'VPPG0270'
data_VPPGc$P104_01[rownames(data_VPPGc)=='952'] = 'VPPG0619'
data_VPPGc$P104_01[rownames(data_VPPGc)=='954'] = 'VPPG0815'
data_VPPGc$P104_01[rownames(data_VPPGc)=='947'] = 'VPPG0810'
data_VPPGc$P104_01[rownames(data_VPPGc)=='968'] = 'VPPG0842'
data_VPPGc$P104_01[rownames(data_VPPGc)=='985'] = 'VPPG0289a'

# forgotten "VPPG" prefix
data_VPPGc$P104_01[data_VPPGc$P104_01=='08103'] = 'VPPG08103'
data_VPPGc$P104_01[rownames(data_VPPGc)=='997'] = 'VPPG0326'
data_VPPGc$P104_01[data_VPPGc$P104_01=='08106'] = 'VPPG08106'

# duplicates because of unfinished questionnaires
# will be fixed later in script
data_VPPGc$P104_01[data_VPPGc$P104_01 == '0201'] = 'VPPG0201'
data_VPPGc$P104_01[data_VPPGc$P104_01 == '0207'] = 'VPPG0207'

# duplicates because quest (the one after SLM) filled in twice (PhysioVP0068)
rmrows     = c('642')
data_VPPGc = data_VPPGc[!rownames(data_VPPGc) %in% rmrows, ]

# repair further some VPPG code names
data_VPPGc$P104_01=sub('_', '', data_VPPGc$P104_01)
data_VPPGc$P104_01=sub('-', '', data_VPPGc$P104_01)

# remove rows which have test id codes
data_VPPGc = mah.subset.preserve(data_VPPGc, !data_VPPGc$P104_01 %in% test_codes)

# here data seems to be finished reading in
# ready to check for duplicates
# 1) stop the script below
# 2) inspect data_VPPGc
#    check for duplicates
# 3) add a line of code above

# duplicates due to unfinished questionnaires
# will go through all subquests and if there are duplicates
# then drops ALL (!) unfinished quests
cur_quests = unique(data_VPPGc$QUESTNNR)
for (kk in 1:length(cur_quests)) {
  
  # get the current questionnaire from the data
  cur_df = mah.subset.preserve(data_VPPGc,
                               data_VPPGc$QUESTNNR == cur_quests[kk])
  
  cur_subs = cur_df$P104_01[duplicated(cur_df$P104_01)]
  tfv = NULL
  for (ii in 1:length(cur_subs)) {
    
    # in case no subs are duplicated we break
    if (ii == 0) {break}
    
    # else we go ahead and clean unfinished quests
    cur_sub    = cur_subs[ii]
    cur_tfv = as.matrix(!(cur_df$P104_01 == cur_sub & cur_df$FINISHED == FALSE))
    if (is.null(tfv)) {
      tfv = cur_tfv
    } else {
      tfv = cbind(tfv,cur_tfv)
    }
  }
  
  # in case subs were dupli in this quest we finish cleaning work
  if (ii != 0) {
    res_tfv = apply(tfv,MARGIN=1,mean)
    res_tfv = which(as.logical(ifelse(res_tfv==1,1,0)))
    cur_df  = mah.subset.preserve(cur_df,res_tfv)
  }
  
  # save the cleaned cur_df
  if (kk == 1) {
    data_VPPGcuf = cur_df
  } else {
    data_VPPGcuf = rbind(data_VPPGcuf,cur_df)
  }
}
data_VPPGc = data_VPPGcuf
rm(data_VPPGcuf)


# another fix
data_VPPGc$P104_01[rownames(data_VPPGc)=='778'] = 'VPPG0051a'
data_VPPGc$P104_01[rownames(data_VPPGc)=='779'] = 'VPPG0051a'

# fix subs that do not have VPPG in front (STILL)
# find the 4-digit ones
cur_regres = regexpr('^(\\d{4})$',as.character(data_VPPGc$P104_01))
cur_regres = cur_regres == 1
data_VPPGc$P104_01[cur_regres] = paste0('VPPG',data_VPPGc$P104_01[cur_regres])

# NO DUPLICATE CHECK HERE; doing it later in quest and ratings core

# more cleaning of VPPG
## DANGEROUS CODE BECAUSE IT REMOVES ABSOLUTE ROWS

# 555, 573 my own testing 630 aborted and then presumably started it over again at home and finished it;
# 641 person did it twice so we are using the second one; 767 our quest testing
# 110 - xxxx was the VPPG so persumably a test 
# 112 had number VPPG0609 and not many answers, it was not in the Teilnehmerliste
# 130 132 133 138 obviously just someone of us trying the questionnaire out vppg 9999
#rmrows=c(555, 573, 630, 641, 767)

#data_B=data_B[!rownames(data_B) %in% as.character(rmrows), ]
#data_B=mah.subset.preserve(data_B, !rownames(data_B) %in% as.character(rmrows))

## DANGEROUS CODE BECAUSE IT REMOVES ABSOLUTE ROWS

# cleaning data_B
# this is already done above

# cleaning of VPPG02
data_VPPG02c = data_VPPG02
data_VPPG02c = data_VPPG02c[!is.na(data_VPPG02c$P104_01),]
# putting the id_col first
col_idx      = grep('P104_01', names(data_VPPG02c))
data_VPPG02c = data_VPPG02c[, c(col_idx, (1:ncol(data_VPPG02c))[-col_idx])]

# TODO: alot of ugly rowname based changes
cur_rep = paste0('PhysioVP', data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(29,35))])
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(29,35))] = cur_rep

cur_row_names = c(6:19,22,23,31,34, 38, 39, 40, 47,48,58)
cur_rep       = paste0('VPPG', data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),cur_row_names)])
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),cur_row_names)] = cur_rep
data_VPPG02c$P104_01[rownames(data_VPPG02c)=='6']=paste0(data_VPPG02c$P104_01[rownames(data_VPPG02c)=='6'],'b')
data_VPPG02c$P104_01[rownames(data_VPPG02c)=='40']=paste0(data_VPPG02c$P104_01[rownames(data_VPPG02c)=='40'],'b')
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(63))]= 'VPPG0112'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(70))]= 'VPPG0223'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(69))]= 'VPPG0230'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(73))]= 'VPPG0044'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(82))]= 'VPPG0250'
data_VPPG02c$P106_01[is.element(as.numeric(rownames(data_VPPG02c)),c(82))]= 'PhysioVP0121'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(96))]= 'VPPG0257a'
data_VPPG02c$P106_01[is.element(as.numeric(rownames(data_VPPG02c)),c(96))]= 'PhysioVP0127'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(107))]= 'VPPG0264'
data_VPPG02c$P106_01[is.element(as.numeric(rownames(data_VPPG02c)),c(107))]= 'PhysioVP0130'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(119))]= 'VPPG0712'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(127))]= 'VPPG0810'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(135))]= 'VPPG0064'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(139))]= 'VPPG0821'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(143))]= 'VPPG0619'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(145))]= 'VPPG0815'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(158))]= 'VPPG0842'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(183))]= 'VPPG0289a'
data_VPPG02c$P104_01[is.element(as.numeric(rownames(data_VPPG02c)),c(163))]= 'VPPG0272'
data_VPPG02c$P104_01[data_VPPG02c$P104_01 == '0608'] = 'VPPG0608'
data_VPPG02c$P104_01[data_VPPG02c$P104_01 == '08106'] = 'VPPG08106'

## DANGEROUS CODE CAUSE IT WORKS WITH ABSOLUTE ROWNAMES

# remove rows identified as irrelevant
# 110 - xxxx was the VPPG so persumably a test 
# 112 had number VPPG0609 and not many answers, it was not in the teilnehmerliste
# 130 132 133 138 obviously just someone of us trying the questionnaire out vppg 9999
# 170 started a second time under 171 because person closed unfinished questionnaire accidentally
# rmrows=c(43,46,85, 110, 112, 130, 132, 133, 138, 170)
# data_VPPG02c=mah.subset.preserve(data_VPPG02c, !rownames(data_VPPG02c) %in% as.character(rmrows))
# data_VPPG02c=data_VPPG02c[!rownames(data_VPPG02c) %in% as.character(rmrows), ]

## DANGEROUS CODE CAUSE IT WORKS WITH ABSOLUTE ROWNAMES

# better:
# remove rows which have test id codes
data_VPPG02c = mah.subset.preserve(data_VPPG02c, !data_VPPG02c$P104_01 %in% test_codes)

# strip white and rm dashes, underscores
data_VPPG02c$P104_01 = trimws(data_VPPG02c$P104_01)
data_VPPG02c$P104_01 = gsub('-','',data_VPPG02c$P104_01)
data_VPPG02c$P104_01 = gsub('_','',data_VPPG02c$P104_01)

# cleaning VPPG02 of duplicates
# duplicates due to unfinished questionnaires
# duplicates due to unfinished questionnaires
# will go through all subquests and if there are duplicates
# then drops ALL (!) unfinished quests
cur_quests = unique(data_VPPG02c$QUESTNNR)
for (kk in 1:length(cur_quests)) {
  
  # get the current questionnaire from the data
  cur_df = mah.subset.preserve(data_VPPG02c,
                               (data_VPPG02c$QUESTNNR == cur_quests[kk]))
  
  cur_subs = cur_df$P104_01[duplicated(cur_df$P104_01)]
  tfv = NULL
  for (ii in 1:length(cur_subs)) {
    
    # in case no subs are duplicated we break
    if (ii == 0) {break}
    
    # else we go ahead and clean unfinished quests
    cur_sub    = cur_subs[ii]
    cur_tfv = as.matrix(!(cur_df$P104_01 == cur_sub & cur_df$FINISHED == FALSE))
    if (is.null(tfv)) {
      tfv = cur_tfv
    } else {
      tfv = cbind(tfv,cur_tfv)
    }
  }
  
  # in case subs were dupli in this quest we finish cleaning work
  if (ii != 0) {
    res_tfv = apply(tfv,MARGIN=1,mean)
    res_tfv = which(as.logical(ifelse(res_tfv==1,1,0)))
    cur_df  = mah.subset.preserve(cur_df,res_tfv)
  }
  
  # save the cleaned cur_df
  if (kk == 1) {
    data_VPPG02cuf = cur_df
  } else {
    data_VPPG02cuf = rbind(data_VPPG02cuf,cur_df)
  }
}
data_VPPG02c = data_VPPG02cuf
rm(data_VPPG02cuf)

# OLD
# cur_subs = data_VPPG02c$P104_01[duplicated(data_VPPG02c$P104_01)]
# for (ii in 1:length(cur_subs)) {
#   cur_sub = cur_subs[ii]
#   tfv         = !(data_VPPG02c$P104_01 == cur_sub & data_VPPG02c$FINISHED == FALSE)
#   data_VPPG02c = mah.subset.preserve(data_VPPG02c,tfv)
# }

# check if no more duplicates, else throw error
if (!sum(duplicated(data_VPPG02c$P104_01)) == 0) {
  
  stop(paste('Unchecked duplicated in questimport, VPPG02:',
             paste(data_VPPG02c$P104_01[duplicated(data_VPPG02c$P104_01)],
                   collapse = ' ')))
}

# fix subs that do not have VPPG in front (STILL)
# DANGEROUS: cause cannot decide if it is maybe PhysioVP!
# find the 4-digit ones
cur_regres = regexpr('^(\\d{4})$',as.character(data_VPPG02c$P104_01))
cur_regres = cur_regres == 1
data_VPPG02c$P104_01[cur_regres] = paste0('VPPG',data_VPPG02c$P104_01[cur_regres])


# recoding to only work with VPPG numbers furthermore
data_VPPGc$P104_01_bcp   = data_VPPGc$P104_01_bcp
data_VPPGc$P104_01       = agk.recode(data_VPPGc$P104_01,tnl$PhysioVP,tnl$VPPG)
data_VPPG02c$P104_01_bcp = data_VPPG02c$P104_01_bcp
data_VPPG02c$P104_01     = agk.recode(data_VPPG02c$P104_01,tnl$PhysioVP,tnl$VPPG)


# # check if no more duplicates, else throw error
# # VPPG02c
# if (!sum(duplicated(data_VPPG02c$P104_01)) == 0) {
#   
#   stop(paste('Unchecked duplicated in questimport, VPPG02:',
#              paste(data_VPPG02c$P104_01[duplicated(data_VPPG02c$P104_01)],
#                    collapse = ' ')))
# }
# 
# # VPPGc
# if (!sum(duplicated(data_VPPGc$P104_01)) == 0) {
#   
#   stop(paste('Unchecked duplicated in questimport, VPPG:',
#              paste(data_VPPGc$P104_01[duplicated(data_VPPGc$P104_01)],
#                    collapse = ' ')))
# }


## END OF CLEANING SUBJECTS ##
## END INTERMEDIATE HIGHER ORDER ##

#TODO
setwd(path_data)
source('agk_import_quest_from_sosci_core.R')
source('agk_import_ratings_from_sosci_core.R')

