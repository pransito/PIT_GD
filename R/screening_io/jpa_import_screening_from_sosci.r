# script for getting the data out of online survey SocSi
# TODO: email addresses need to go private

#########################################################################################################################
#### GET DATA FROM SOSCI                                                                                            #####
#### modify script from SoSci and run                                                                               #####
#########################################################################################################################

setwd(path_data)

### read in script as string and change the first few lines
# so that no more user interaction is required
cur_file = dir(pattern = "import_VPPG_Screen_")
if (length(cur_file) >= 2){
  stop(c("Found more than one import script: ", cur_file, "\nPlease provide only one script!"))
}
cur_csv  = dir(pattern = '.csv')
cur_csv  = cur_csv[grep("rdata_VPPG_Screen_",cur_csv)]
if (length(cur_csv) >= 2){
  stop(c("Found more than on data file: ", cur_csv, "\nPlease provide only one data csv!"))
}
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

# set fname
tmp        = strsplit(cur_file,'_')
fNameBase  = paste0('/Screening_VPPG_',tmp[[1]][4])



#########################################################################################################################
#### HANDLE OLD DATA IMPORTED FROM THE OLD SOCI SERVER                                                              #####
#### add the previous data (data gathered until jan 2016 when we separated the Screening from the overall database) #####
#########################################################################################################################

################  old data from 2016-01-26 ################ 
data_sub_old_1 <- loadRData(paste0(path_oldS, "/Screening_VPPG_2016-01-26_SubjectInfo.Rda"))
data_ano_old_1 <- loadRData(paste0(path_oldS, "/Screening_VPPG_2016-01-26_Data-label.Rda"))

# add primkey
data_sub_old_1$primKey = seq.int(nrow(data_sub_old_1))
data_ano_old_1$primKey = seq.int(nrow(data_ano_old_1))
lastKey = nrow(data_ano_old_1)

# reorder so that the order is same as new dataset
data_sub_old_1 = data_sub_old_1[,c(ncol(data_sub_old_1),1:ncol(data_sub_old_1)-1)]
data_ano_old_1 = data_ano_old_1[,c(ncol(data_ano_old_1),1:ncol(data_ano_old_1)-1)]


################ old data from 2016-01-28 ################ 
data_sub_old_2 <- loadRData(paste0(path_oldS,"/Screening_VPPG_2016-01-28_SubjectInfo.Rda"))
data_ano_old_2 <- loadRData(paste0(path_oldS,"/Screening_VPPG_2016-01-28_Data-label.Rda"))

# add missing participant
data_sub_old_2=data_sub_old_2[data_sub_old_2$VPPG =='VPPG_0047'|row.names(data_sub_old_2)=='611',]
data_sub_old_2$VPPG[1]='VPPG_0080'

data_ano_old_2=data_ano_old_2[data_ano_old_2$VPPG =='VPPG_0047'|row.names(data_ano_old_2)=='611',]
data_ano_old_2$VPPG[1]='VPPG_0080'
data_ano_old_2$VPNum= c(66,68)

# add primKey
data_sub_old_2$primKey = seq.int(lastKey+1,lastKey+1 + nrow(data_sub_old_2)-1)
data_ano_old_2$primKey = seq.int(lastKey+1,lastKey+1 + nrow(data_ano_old_2)-1)
lastKey = lastKey + nrow(data_ano_old_2)-1

# reorder so that the order is same as new dataset
data_sub_old_2 = data_sub_old_2[,c(ncol(data_sub_old_2),1:ncol(data_sub_old_2)-1)]
data_ano_old_2 = data_ano_old_2[,c(ncol(data_ano_old_2),1:ncol(data_ano_old_2)-1)]


################ concat to old dataset ################ 
# bring together old_data_1 and old_data_2 data
data_sub_old= rbind(data_sub_old_1, data_sub_old_2)
data_ano_old= rbind.fill(data_ano_old_1,data_ano_old_2)


################ fix old data ################ 
# VPPG Number
data_sub_old$VPPG[data_sub_old$primKey == 52] = "VPPG_0051a"
data_ano_old$VPPG[data_ano_old$primKey == 52] = "VPPG_0051a"
data_sub_old$VPPG[data_sub_old$primKey == 53] = "VPPG_0051b"
data_ano_old$VPPG[data_ano_old$primKey == 53] = "VPPG_0051b"

## FIX KFG that were skipped but are HC
data_ano_old$KFG[data_ano_old$primKey == 21 ] = NA   #"VPPG_0021"
data_ano_old$KFG[data_ano_old$primKey == 32 ] = NA   #"VPPG_0031"


#########################################################################################################################
#### HANDLE NEW DATA                                                                                                #####
#########################################################################################################################

# backup the data for later use
data_bckp=data

# add a auto increment primary key to identify data and reorder
data$primKey <- seq.int(lastKey+1,lastKey+1 + nrow(data)-1)
comment(data$primKey)='primary key to identify each row'
data = data[,c(ncol(data),1:ncol(data)-1)]

# set data to use:
data$use=data$FINISHED
data$use[data$S110_01=='NA' ] = FALSE
# special case were to use data although it is not finished:
data$use[data$primKey == 276] = TRUE # VPPG_0619
data$use[data$primKey == 285] = TRUE # VPPG_0817


# set data to further analyse 
data= subset(data, use == TRUE)

# wherever this comes from... we filter them...
selectCols = c("primKey", "S108_04","S108_02","S108_03","S109_01","S109_02","S109_03","S110_01","S110_02","S110_03",
               "S110_04","S108_04","S201","S202","S203","S204","S205_01","S206_01","S208_01","S208_02","S208_03",
               "S208_04","S208_05","S208_06","S208_07","S208_08","S208_09","S209","S211_01","S211_02","S212_01",
               "S212_02","S212_03","S212_04","S212_05","S212_06","S213_01","S213_02","S210_01","S214_01","S215_01",
               "S217_01","S217_02","S218","S226_02","S226_03","S226","S228_02","S228","S227_01","S227_02","S227_03",
               "S227_04","S227_05","S227_06","S227_07","S227_08","S227_09","S227_10","S227_11","S227_12","S227_13",
               "S230_02","S230","S231_02","S231","S232_02","S232","S233_02","S233","S234_02","S234","S235_02","S235",
               "S236_02","S236","S267_02","S267","S268_02","S268","S237_02","S237","S238_02","S238","S239_02","S239",
               "S240_02","S240","S241_02","S241","S243_02","S243","S246_02","S246","S242_02","S242","S245_02","S245",
               "S247_02","S247","S248_01","S248_02","S248_03","S248_11","S248_12","S248_13","S248_14","S248_15","S248_16",
               "S248_17","S248_18","S248_19","S248_20","S248_21","S248_22","S248_23","S248_24","S248_25","S248_26",
               "S248_27","S248_28","S248_32","S269_01","S269_02","S269_03","S269_04","S269_05","S269_06","S269_07",
               "S269_08","S269_09","S270_01","S271_01","S271_02","S271_03","S271_04","S271_05","S271_06","S271_07",
               "S271_08","S271_09","S272_01","S252_02","S252","S253_01","S253_02","S253_03","S253_04","S253_05","S253_06",
               "S253_07","S253_08","S253_09","S253_10","S253_11","S253_12","S253_13","S253_14","S253_15","S253_16",
               "S253_17","S253_18","S253_19","S253_20","S254_01","S254_02","S254_03","S254_04","S254_05","S255_01",
               "S255_02","S301","S302","S303_01","S304_01","S305_01","S305_02","S305_03","S305_04","S305_05","S306",
               "S307_02","S307","S308_02","S308","S309","S310_01","S310_02","S311","S312_01","S312_02","S312_03","S312_04",
               "S313","S314_01","S314_02","S315_01","S315_02","S316_01","S316_02","S317_01","S317_02","S318","S319",
               "S320","S321_01","S322","S330","S324","S326_01","S327_01","S327_02","S327_03","S328_05","S328",
               "S329_01","S332","S332_02","S334_01","S333_01","S335","E101","E102","E103","E104","E105","E106",
               "E107","E108","E109","E110")

# make sure that selected colname exist so that there will be not error when SoSci Script has changed
includeCols = c()
for (column in selectCols){
  if (!column %in% colnames(data)){
    warnings(cat("Column name " , column, " selected. This name is not existent in data frame. Please change list! Proceeding without these column..."))
  }else{
    includeCols = c(includeCols, column)
  }
}
# filter columns of interest
data=data[includeCols]

# edit VPPG_nummer, string "VPPG_" always followed by 4 Digits 
data$VPPG=str_pad(data$S108_04, 4, pad = "0")
data$VPPG[data$VPPG == '3040'] = '0340'
cond_1 = grep("^0",data$VPPG,invert = T)
cond_2 = grep("^9",data$VPPG,invert = T)
cond_3 = which(!is.na(data$VPPG))
cond_c = cond_3[which(as.logical((cond_3 %in% cond_1) * (cond_3 %in% cond_2)))]
data$VPPG[cond_c] = paste0('0',data$VPPG[cond_c])
data$VPPG=paste0("VPPG_", data$VPPG)
comment(data$VPPG)='VPPG'

# sperate data in those with private Information and in those without
data_sub = data[,c("primKey", "VPPG", "S108_04", "S108_02", "S108_03", "S109_01" ,"S109_02" ,"S109_03", "S110_01" ,"S110_02", "S110_03", "S110_04", "S108_04","S327_03")]
data_ano = data[,c("primKey", "VPPG", "S110_01", "S110_02", names(data[13:ncol(data)-1])) ]
names(data_sub)[length(names(data_sub))] = 'contact_again_2_is_yes'

# Initiste the old useless VPNum variable just so that when we import the old data it matches well
data_ano$VPNum=NA
comment(data_ano$VPNum)= "VP Number"


################ KFG ################ 
# extragt KFG Questions and calculate KFG overall score
KFG_set=data_ano[c('S253_01','S253_02','S253_03','S253_04','S253_05','S253_06','S253_07','S253_08','S253_09','S253_10',
                       'S253_11','S253_12','S253_13','S253_14','S253_15','S253_16','S253_17','S253_18','S253_19','S253_20')]
KFG_num=sapply(KFG_set, as.numeric)
data_ano$KFG= apply(KFG_num,1, sum) - 20

comment(data_ano$KFG)='KFG overall score'


################ AUDIT ################
# extract AUDIT score questions and calculate AUDIT score
AUDIT_set=data_ano[c("E101","E102","E103","E104","E105","E106","E107", "E108","E109","E110")]

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

data_ano$AUDIT=apply(AUDIT_num,1, mah.sum0)
comment(data_ano$AUDIT)='Alcohol Use Disorders Identification Test'

data_ano_bckp=data_ano

################ Fix Data  ################ 

for (i in 1:2) {
  if (i==1){
    data_rep=data_ano
  } else {
    data_rep=data_sub
  }

  ### VPPG Number
  data_rep$VPPG[data_rep$primKey == 72 ] = "VPPG_0069a"   #"VPPG_0069"
  data_rep$VPPG[data_rep$primKey == 71 ] = "VPPG_0069b"   #"VPPG_0069"
  # VPPG_0001 was again assigned in March 2016, and this is the one that gets a suffix b
  data_rep$VPPG[data_rep$primKey == 99 ] = "VPPG_0001b"   #"VPPG_0001"
  # VPPG0107 has been assigned twice in the screening
  data_rep$VPPG[data_rep$primKey == 108 ] = "VPPG_0107b"   #"VPPG_0107"
  # VPPG0112 has been assigned twice in the screening, and then one of them was tested as VPPG0112, the other one gets a suffix b
  data_rep$VPPG[data_rep$primKey == 128 ] = "VPPG0112b"
  # VPPG0257 has been assigned twice in the screening: katha sent an email in advance
  data_rep$VPPG[data_rep$primKey == 175 ] = "VPPG_0257a"
  data_rep$VPPG[data_rep$primKey == 176 ] = "VPPG_0257b"
  # VPPG0823 has been assigned twice in the screening: I sent an email
  data_rep$VPPG[data_rep$primKey == 297 ] = "VPPG_0823a"
  data_rep$VPPG[data_rep$primKey == 299 ] = "VPPG_0823b"
  # during rearranging import/export scripts we found out that number VPPG_0289 was duplicated assigned -> first is getting a, secound b
  data_rep$VPPG[data_rep$primKey == 404 ] = "VPPG_0289a"
  data_rep$VPPG[data_rep$primKey == 406 ] = "VPPG_0289b"
  data_rep$VPPG[data_rep$primKey == 516 ] = "VPPG_0115" # KD assigned VPPG_0116 instead of VPPG_0115
  data_rep$VPPG[data_rep$primKey == 268 ] = "VPPG_0617" # accidentally assigned twice; AG 6.12.2017
  data_rep$VPPG[data_rep$primKey == 545 ] = "VPPG_0671" # accidentally assigned as VPPG_0617 but is VPPG_0671
  data_rep$VPPG[data_rep$VPPG == 'VPPG_0006'] = "VPPG_0006b" # on 23 Oct 2017 somebody assigned VPPG0006 which is completely wrong, cause assigned back in the day

  ### throw out
  #data_rep = data_rep[!data_rep$primKey == 88 ,] #VPPG0205 -> throwed out without a reason... i just don't know why
  #data_rep = data_rep[!data_rep$primKey == 102 ,] #VPPG0302 -> is a faulty line in the screening
  data_rep = data_rep[!data_rep$primKey == 136,] #VPPG_0106 -> VPPG0106 has been assigned twice in the screening one of them is an unfinished screening
  #VPPG_0815, screening was modified by alisa because she was not happy with what she selected 
  #for this person during the screening, so she filled it up again based on the collected data
  #the newer version should be used and the old one should be discarded
  data_rep = data_rep[!data_rep$primKey == 283,]
  data_rep[!data_rep$primKey == 282,] # vppg_0815 screened three times for what reason
  data_rep[!data_rep$primKey == 283,] # vppg_0815 screened three times for what reason
  data_rep[!data_rep$primKey == 353,] # something went wrong here. 
  
  # TODO: Filter for all theses unvalid vppg nuumbers!
  # VPPG_9999 are tests run by us, i am deleting them as well
  data_rep = data_rep[!(data_rep$VPPG =="VPPG_9999"),]
  data_rep = data_rep[!(data_rep$VPPG =="VPPG_999999"),]
  data_rep = data_rep[!(data_rep$VPPG =="VPPG_99999"),]
  data_rep = data_rep[!(data_rep$VPPG =="VPPG_NA"),]

  if (i==1){ data_ano=data_rep }
  else{ data_sub=data_rep }
  
}
# check for duplicate VPPG and ERROR if
duplVPPG = data_ano$VPPG[duplicated(data_ano$VPPG,fromLast=TRUE) | duplicated(data_ano$VPPG)]
duplVPPG2 = data_sub$VPPG[duplicated(data_sub$VPPG,fromLast=TRUE) | duplicated(data_sub$VPPG)]
if (length(duplVPPG)>0){
  stop(cat("ERROR: Found duplicate VPPG Number(s): " ,duplVPPG))
}
# NOTE: From this part on VPPG_# is a primary key! so we can use them to identify subjects

## FIX KFG that were skipped but are HC
data_ano$KFG[data_ano$VPPG== "VPPG_0100"] = 0
data_ano$KFG[data_ano$VPPG== "VPPG_0254"] = 0

# Add missing response to the VPPG0611
data_ano$S332[data_ano$VPPG== 'VPPG_0611'] = 'Ja,'
data_ano$S332_02[data_ano$VPPG== 'VPPG_0611'] = 'aber vorher separaten, mrt-unabh?ngigen Drogentest und abkl?ren, welche Narkose f?r Operation am 20.09. verwendet, um ihm frei von Medikamenten im Blut einen Testtermin anzubieten'


#########################################################################################################################
#### bring together old and new data and renew attributes                                                           #####
#########################################################################################################################

# TODO: JOIN STATT RBIND
data_sub_old = data_sub_old$contact_again_2_is_yes = NA
data_sub= rbind(data_sub_old, data_sub)
data_ano= rbind.fill(data_ano_old,data_ano)

# now remove primKey... thats not of interest
data_sub = data_sub[,c(2:ncol(data_sub))]
data_ano = data_ano[,c(2:ncol(data_ano))]

################ rewrite attributes ################ 
# rewrite attributes of each column which magically have been dissapeared for what reason...
varnames = colnames(data_ano)[!colnames(data_ano) %in% colnames(data_ano_bckp)]
for (i in varnames) {
  eval(parse(text=paste0('attributes(data_ano$',i,') = attributes(data_ano_bckp$',i,')')))
}
# rewrite all the others
varnames_data=colnames(data_ano)[colnames(data_ano) %in% colnames(data_bckp)]
for (i in varnames) {
  if (eval(parse(text=paste0('!is.null(attributes(data_bckp$',i,'))' )))){
    eval(parse(text=paste0('attributes(data_ano$',i,') = attributes(data_bckp$',i,')'))) # AGK made this change on 24.05.2017; seems to be bug; data_ano_lab is old
    # eval(parse(text=paste0('attributes(data_ano_lab$',i,') = attributes(data_bckp$',i,')'))) 
  }
}

#########################################################################################################################
#### HANDLE DATA IN TEILNEHMERLISTE                                                                                 #####
#### for every VPPG_XXXX in Teilnehmerliste there will be checked if a corresponding VPPG_XXXX Screening exists!    #####
#########################################################################################################################

# Check if all subjects in TN-List have screenings
noScreening = tnl$VPPG[!trimws(tnl$VPPG) %in%   trimws(gsub("_","",data_ano$VPPG))]
if (length(noScreening) != 0) {
  print('You have these VPPG numbers in Teilnehmerliste without screening! Please fix that!!')
  print(as.character(noScreening))
  #error('VPPG numbers in Teilnehmerliste without screening!')
}


#########################################################################################################################
#### write to disk                                                                                                  #####
#########################################################################################################################

# check duplicates
if (!all(duplicated(data_ano$VPPG) == FALSE)) {
  stop('Duplicates in screening export!')
}

# write output for data_sub in private dir
write.xlsx(data_sub, paste0(path_rslt_private, fNameBase, "_SubjectInfo.xlsx")) #as xlsx
save(data_sub, file=paste0(path_rslt_private, fNameBase, "_SubjectInfo.Rda"))   # as R readable file

# TODO:write output for data_sub in private dir WITHOUT datum in name

# write output for data_ano 
save(data_ano, file=paste0(path_rslt, fNameBase, "_Data-label.Rda"))

# write output for data_ano WITHOUT datum in name
save(data_ano, file=paste0(path_rslt, "/Screening_VPPG", "_Data-label.Rda"))


### write out comments in xlsx 
# get all cols that exist in data and in data_ano
varnames_data=colnames(data_ano)[colnames(data_ano) %in% colnames(data_bckp)]

# get comments
coms=data.frame(matrix(ncol = ncol(data_ano), nrow = 1))
colnames(coms)= names(data_ano)
for (name in varnames_data) {
  com = comment(eval(parse(text=paste0('data$', name))))
  if (!is.null(com)){
    eval(parse(text=paste0('coms$',name, "=com" )))
  }
}

# write data.frame as matrix
coms = as.matrix.data.frame(coms)

# create workbook table
wb<-createWorkbook(type="xlsx")
sheet <- createSheet(wb, sheetName = "Screening Data")
addDataFrame(x = coms, sheet, row.names = FALSE, col.names=FALSE, startRow = 1)
addDataFrame(x = data_ano, sheet, row.names = FALSE, startRow = 2) 
saveWorkbook(wb, paste0(path_rslt, fNameBase, "_Data-label.xlsx")) # and of course you need to save it.


