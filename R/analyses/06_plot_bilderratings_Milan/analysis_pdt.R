

###########################################################
#          prep VD-ANALYSEN PDT                           #
###########################################################

# 28.04.2015

# fitting a Generalized Mixed Model to the PDT data
# using lme4
# DV: accept_reject
# IV (fixed): gain, loss, cat
# IV (randm): subject random

## clear workspace
rm(list = ls())## parameters that may be set

# currently centered-only (gain, loss)
use_z          <- 1 
# use absolute value of loss as predictor
loss_abs       <- 1
# if set to 1 then people with too many missings will be dropped
missing_check  <- 1  
# if there are more than x% percent missings in response then drop-out
missing_cutoff <- 0.1
# what kind of pca to extract features? (if no kernel pca then normal pca)
do_kernelpca <- 0

## paths
user     <- "milan.an\\"
base     <- paste("C:\\Users\\",user,"Google Drive\\VPPG_Exchange\\",sep="")
base_bgg <- paste("C:\\Users\\",user,"Google Drive\\VPPG_Exchange\\",sep="")

path_ana <- paste(base,"Experimente\\PDT\\analysis\\scripts\\R",sep="")
path_dat <- paste(base,"Experimente\\PDT\\Daten\\pilot",sep="")
path_res <- paste(base,"Experimente\\PDT\\analysis\\results",sep="")

path_rat <- paste(base,"Bilderrating\\Results_Pretest\\Result files\\",sep="")
path_rrs <- paste(base,"Bilderrating\\analysis\\results",sep="")
path_bgg <- paste("C:\\Users\\",user,"\\Google Drive\\Diplom\\LA\\daten_behav_test_finale_SP_Diplom\\Results",sep="")


############################################################

## load libraries and functions
setwd(path_ana)
source ('functions_pdt.R')
setwd(path_ana)
source ("get_fixef_functions.R")

## prep some variables
subject        <- c()
p              <- c()
r              <- c()
missing_people <- list()

## get all the data in long format
setwd(path_ana)
source("get_data_pdt.R")
setwd(path_ana)
source("get_physio_aggregates.R")
setwd(path_ana)
source("get_data_ratings.R")
setwd(path_dat)

# put ratings data onto the pdt data
colnames(ratings)[1] <- "stim"
ratings$subject <- as.factor(ratings$subject)
data_pdt <-merge(data_pdt, ratings, by=c("subject", "stim"),all.x = T,all.y=T)

# get proper leveling for "cat" variable
levels(data_pdt$cat) <- c("gam","neg","pos","neu","nap", "awneu", "awneg", "awpos" )
data_pdt$cat <- as.character(data_pdt$cat)
data_pdt$imageGroup <- as.character(data_pdt$imageGroup)
for(kk in 1:length(data_pdt$imageGroup)) {
  if(is.na(data_pdt$cat[kk])) {
    data_pdt$cat[kk] <- data_pdt$imageGroup[kk]
  }
}
data_pdt$cat <- as.factor(data_pdt$cat)

# data_pdt bcp
data_pdt_bcp <- data_pdt

# get gry into the fit_cluster variable
for (ii in 1:length(data_pdt[,1])) {
  if(is.na(data_pdt$cat[ii])) {next}
  if(data_pdt$cat[ii] == "gry") {data_pdt$fit_cluster[ii] <- 5}
}

data_pdt$fit_cluster <- as.factor(data_pdt$fit_cluster)
levels(data_pdt$fit_cluster) <- c("gam","neg","pos","neu","gry")

################################################################

## prep different ways of defining category
# defined category
contrasts(data_pdt$cat) <- contr.treatment(n = 6,base=2)
colnames(contrasts(data_pdt$cat)) <- c("gam", "nap", "neg","neu","pos")

# 4 cluster approach of rating data
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$valence[ii])) {
    data_pdt$emo_cat[ii] <- NA
    if (!is.na(data_pdt$cat[ii])) {
      if (data_pdt$cat[ii] == "gry") {data_pdt$emo_cat[ii] <- "gr"}
    }
    next}
  if (data_pdt$valence[ii] > 0 & data_pdt$arousal[ii] > 0) {data_pdt$emo_cat[ii] <- "pa"}
  if (data_pdt$valence[ii] > 0 & data_pdt$arousal[ii] <= 0 ) {data_pdt$emo_cat[ii] <- "pc"}
  if (data_pdt$valence[ii] <=  0 & data_pdt$arousal[ii] > 0) {data_pdt$emo_cat[ii] <- "na"}
  if (data_pdt$valence[ii] <=  0 & data_pdt$arousal[ii] <=  0) {data_pdt$emo_cat[ii] <- "nc"}
}
data_pdt$emo_cat <- as.factor(data_pdt$emo_cat)
contrasts(data_pdt$emo_cat) <- contr.treatment(n = 5,base=1)
colnames(contrasts(data_pdt$emo_cat)) <- c("na", "nc", "pa", "pc")

# a two cluster approach (arousal)
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$arousal[ii])) {
    data_pdt$emo_aro[ii] <- NA
    if (!is.na(data_pdt$cat[ii])) {
      if (data_pdt$cat[ii] == "gry") {data_pdt$emo_aro[ii] <- "gr"}
    }
    next}
  
  if (data_pdt$arousal[ii] >  0) {data_pdt$emo_aro[ii] <- "aro"}
  if (data_pdt$arousal[ii] <= 0) {data_pdt$emo_aro[ii] <- "clm"}
  
}
data_pdt$emo_aro <- as.factor(data_pdt$emo_aro)
contrasts(data_pdt$emo_aro) <- contr.treatment(n = 3,base=3)
colnames(contrasts(data_pdt$emo_aro)) <- c("aro", "clm")

# a two cluster approach (valence)
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$valence[ii])) {
    data_pdt$emo_val[ii] <- NA
    if (!is.na(data_pdt$cat[ii])) {
      if (data_pdt$cat[ii] == "gry") {data_pdt$emo_val[ii] <- "gr"}
    }
    next}
  
  if (data_pdt$valence[ii] >  0) {data_pdt$emo_val[ii] <- "pos"}
  if (data_pdt$valence[ii] <= 0) {data_pdt$emo_val[ii] <- "neg"}  
}
data_pdt$emo_val <- as.factor(data_pdt$emo_val)
contrasts(data_pdt$emo_val) <- contr.treatment(n = 3,base=1)
colnames(contrasts(data_pdt$emo_val)) <- c("pos", "neg")

# a 4 cluster approach zygo/corr; eda (NO GRAY here!)
data_pdt$valphys <- data_pdt$zygo - data_pdt$corr_auc
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$valphys[ii])) {
    data_pdt$emo_pva[ii] <- NA
    next}
  if (data_pdt$valphys[ii]  > 0 & data_pdt$eda[ii]  > 0) {data_pdt$emo_pva[ii] <- "pa"}
  if (data_pdt$valphys[ii]  > 0 & data_pdt$eda[ii] <= 0) {data_pdt$emo_pva[ii] <- "pc"}
  if (data_pdt$valphys[ii] <= 0 & data_pdt$eda[ii]  > 0) {data_pdt$emo_pva[ii] <- "na"}
  if (data_pdt$valphys[ii] <= 0 & data_pdt$eda[ii] <= 0) {data_pdt$emo_pva[ii] <- "nc"}
}
data_pdt$emo_pva <- as.factor(data_pdt$emo_pva)
contrasts(data_pdt$emo_pva) <- contr.treatment(n = 4,base=2)
colnames(contrasts(data_pdt$emo_pva)) <- c("na", "pa", "pc")

# a two cluster approach (phys valence) (NO GRAY here!)
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$valphys[ii])) {
    data_pdt$emo_phv[ii] <- NA
    next}
  
  if (data_pdt$valphys[ii] >  0) {data_pdt$emo_phv[ii] <- "pos"}
  if (data_pdt$valphys[ii] <= 0) {data_pdt$emo_phv[ii] <- "neg"}  
}
data_pdt$emo_phv <- as.factor(data_pdt$emo_phv)
contrasts(data_pdt$emo_phv) <- contr.treatment(n = 2,base=1)
colnames(contrasts(data_pdt$emo_phv)) <- c("pos")

# a two cluster approach (phys arousal) (NO GRAY here!)
for (ii in 1:length(data_pdt[,1])) {
  if (is.na(data_pdt$eda[ii])) {
    data_pdt$emo_pha[ii] <- NA
    next}
  
  if (data_pdt$eda[ii] >  0) {data_pdt$emo_pha[ii] <- "aro"}
  if (data_pdt$eda[ii] <= 0) {data_pdt$emo_pha[ii] <- "clm"}  
}
data_pdt$emo_pha <- as.factor(data_pdt$emo_pha)
contrasts(data_pdt$emo_pha) <- contr.treatment(n = 2,base=2)
colnames(contrasts(data_pdt$emo_pha)) <- c("aro")

## qualitative categories: use categories as seen by subjects
contrasts(data_pdt$fit_cluster) <- contr.treatment(n = 5,base=5)
colnames(contrasts(data_pdt$fit_cluster)) <- c("gam", "neg", "pos", "neu")

## pca approach of rating and physio data
setwd(path_ana)
source("pca_kpca_pdt.R")

## split the data set into pilot study and sanity study
f <- function(x) {if((length(grep(pattern = "PhysioVP004",x = x))>0) | (length(grep(pattern = "PhysioVP005",x = x))>0))  {return (1)} else{return(0)}}
data_pdt$pilot <- sapply(data_pdt$subject,FUN=f)
data_pdt$pilot <- factor(data_pdt$pilot,levels = c(1,0),labels=c("sanity","pilot"))

complete_data <- data_pdt
