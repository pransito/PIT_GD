###########################
## HIGHER ORDER ###########
###########################

# import the questionnaire data from sosci server data
# this is a subscript of the export_from_sosci_routine
# it requires the rdata files from R (Bilderrating_VPPG &
# Bilderrating_VPPG02) and the pertinent Sosci R scripts
# which read in these data into R data frames 

# Bilderrating_VPPG download
# Download the data in the R format from sosci: 
# Variables: any data stored in the data set, includinf those 
# from deleted question and items time spent per page and other 
# variables, data quality parameters, all the data -- All records, 
# mode all unchecked,  Item-nonresponse <=  100 %
# this is old questionnaires data
# this is also the old database where all the data was stored 
# before january 2016

# Bilderrating_VPPG02 download
# Read the data from the VPPG_02 questionnaires file
# this is where most of the questionnaire answers are stored
# same as Bilderrating_VPPG

# SLM fruits are rated in the VPPG02 sosci session together with
# all the questionnaires and stored in the VPPG02. The fruit
# picture IDs start with nine. All the other ratings are done in
# the first questionnaire session, and are stored in the VPPG.

# TODO: the first read-in is also needed for Bilderrating
# so this should move to a higher order routine

# requires:
# path_data: folder with all the exported data and scripts
# from sosci from the current export
# path_exch: folder where the VPPG_exchange stuff lies
# path_rslt_private: folder where the subject specific data is stored
#   usually this is a network folder

# TODO: primary key in the script should be row.names of sosci data
# within data.frame; especially when fixing VPPG numbers

# TODO path_data and path_exch should be chosen with path.choose
user      = paste0(as.character(Sys.info()["login"]))
path_data = paste0('C:/Users/', user, '/Google Drive/Library/R/PDT/',
                   'Screening_Export/How_To_Export/quest')
path_exch = paste0('C:/Users/', user,'/Google Drive/Promotion',
                   '/VPPG/VPPG_Exchange')
path_rslt = paste0(path_exch,'/Bilderrating/Results_Pretest',
                   '/Result files/questionnaires - organize in R')
path_oldS = paste0('C:/Users/',user,'/Google Drive/Library/R/PDT/',
                   'Screening_Export')

# at home lenovo
# user      = paste0(as.character(Sys.info()["login"]))
# path_data = paste0('E:/Google Drive/Library/R/PDT/',
#                    'Screening_Export/How_To_Export/quest')
# path_exch = paste0('E:/Google Drive/Promotion',
#                    '/VPPG/VPPG_Exchange')
# path_rslt = paste0(path_exch,'/Bilderrating/Results_Pretest',
#                    '/Result files/questionnaires - organize in R')
# path_oldS = paste0('E:/Google Drive/Library/R/PDT/',
#                    'Screening_Export')

# MUST must be an S: path
path_rslt_private = 'S:/AG/AG-Spielsucht2/Daten/Probanden/Screening'
#path_rslt_private = 'E:/tmp'
# oldDB is the newest export (May 5th 2017), but with Milan's export script
# However, the data read in had to be replaced by the May 5th R scripts
# because Milan's versions did not work anymore; at least in VPPG;
# VPPG02 seemed to be fine; not sure if I had replaced this as well
path_oldDB = paste0(path_exch,'/Bilderrating/Results_Pretest',
                    '/Result files/questionnaires - organize in R',
                    '/Bilderrating_VPPG_2016-11-14_Questionnaires_Quest.Rda')

# TODO: functions and libraries should be moved up to higher order
# script if possible

# functions
agk.load.ifnot.install = function(package_name){
  # function to load a package and install it
  # if not yet installed
  if(require(package_name,character.only = T,quietly = T)){
    print(paste (package_name,'is loaded correctly'))
  } else {
    print(paste('trying to install', package_name))
    install.packages(pkgs = c(package_name))
    if(require(package_name,character.only = T)){
      print(paste(package_name,'installed and loaded'))
    } else {
      stop(paste('could not install',package_name))
    }
  }
}

mah.subset.preserve = function(df, TrueFalseVector){
  # function by Milan
  # function which preserves attributes
  as.data.frame.avector = as.data.frame.vector
  `[.avector` = function(x,i,...) {
    r = NextMethod('[')
    mostattributes(r) = attributes(x)
    r
  }
  # Assign each column in the data.frame the (additional)
  # class "avector"; Note that this will "lose" the data.frame's
  # attributes; Therefore we will write to a copy data frame
  df2 = data.frame(
    lapply(df, function(x) {
      structure(x, class = c('avector', class(x)))
    } )
  )
  # Finally copy the attribute for the original data.frame if necessary
  mostattributes(df2) = attributes(df)
  # Now subselects work without losing attributes :)
  df2 = df2[TrueFalseVector,]
  return(df2)
}

agk.recode <- function(x,y,z) {
  # a recode function
  # function to recode x, given a source vector y
  # and a translated vector z
  x = as.character(x)
  y = as.character(y)
  z = as.character(z)
  for (ii in 1:length(x)) {
    done <- 0
    for (jj in 1:length(y)) {
      # NA in x will be NA
      if(is.na(x[ii])) {
        x[ii] <- NA
        break
      }
      if (x[ii] == y[jj]) {
        x[ii] <- z[jj]
        done <- 1
      }
      if (done == 1) {break}
    }
  }
  return(x)
}

agk.mean.rmna.percent = function(x,percent) {
  # function to return the mean if not more than
  # percent % are missing (NA or NaN)
  cur_len = length(x)
  cur_per = mean(is.na(x) || is.nan(x))
  if (cur_per*100 <= percent) {
    return(mean(x,na.rm = T))
  } else {
    return(NA)
  }
}

agk.sum.rmna.percent = function(x,percent) {
  # function to return the sum if not more than
  # percent % are missing
  # computes the mean based on agk.mean.rmna.percent
  # then times the length of the vector to estimate the
  # would-be sum
  cur_len = length(x)
  return(agk.mean.rmna.percent(x,percent)*cur_len)
}

agk.unique.narm = function(x) {
  # function to return unique values
  # but ignoring NA's
  x = subset(x,!is.na(x))
  return(unique(x))
}

mah.sum0 = function(row){
  # specialized sum function
  # for AUDIT
  if (is.na(row[1])) {return(NA)}
  else {
    if (row[1]==0){
      return(0)
    }
    else {
      return(sum(row))
    }
  }
}

mah.dfRenameQ=function (set, name){
  # function to rename questionnaire names?
  for (i in 1:length(set)){
    names(set)[i]=paste0(name, '_', toString(i))
  }
  return (set)
}

loadRData <- function(fileName){
  #loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}


# libraries
agk.load.ifnot.install('rJava')
agk.load.ifnot.install('xlsx')
agk.load.ifnot.install('readxl')
agk.load.ifnot.install('xlsx')
agk.load.ifnot.install('psych')
agk.load.ifnot.install('car')
agk.load.ifnot.install('plyr')
agk.load.ifnot.install('readr')
agk.load.ifnot.install('stringr')
agk.load.ifnot.install('Hmisc')
agk.load.ifnot.install('pracma')

# higher order variables (should be moved to higher order
# script)
# test codes are all subject codes that may have been used
# to test the questionnaire and are useless data sets
# subjects named like this will be discarded
test_codes  = c('9999','xxxx','asdf','00','VPPG9999',
                'NA', 'milan','99999','999','PhysioVP9999',
                'PhysioVPxxxx','VPPG99999','8888','PhysioVP99999',
                'PhysioVP999','VPPG999','XXXX','PhysioVP999999',
                '6666','0','PhysioVPmilan','VPPG9999','9999',
                'PhysioVP9999999','PhysioVP9998','PhysioVP9991',
                '0351')

# higher order: subjects which are no expected to have a questionnaire
# i.e. subs where we know, they did not do the questionnaire
# and it has been dealt with, will not be reported anymore
quest_exempt_list = paste0('VPPG',str_pad(seq(500,599),4,pad='0'))
quest_exempt_list = c(quest_exempt_list,'VPPG0032','VPPG0037','VPPG0067',
                      'VPPG0071','VPPG0624','VPPG7777','VPPG8888','VPPG0671',
                      'VPPG0608')

# TODO! screen exempt list??
quest_screen_list = paste0('VPPG',str_pad(seq(500,599),4,pad='0'))

# exempt from ratings (already checked)
ratin_exempt_list = paste0('VPPG',str_pad(seq(500,599),4,pad='0'))
ratin_exempt_list = c(ratin_exempt_list,'VPPG0067','VPPG0071','VPPG0608',
                      'VPPG0899_s','VPPGXXXX_s','VPPG7777','VPPG8888','VPPG0671')

# higher_order: should a check against an old export be performed?
# see path_oldDB
# will check if our new export script here works the same
# for people that have been exported before still under Milan's
# export routine, SO FAR ONLY IMPLEMENTED FOR QUEST
check_against_oldDB = 0
# higher order: variable exempt from check against oldDB
# BIG,SOGS: because probably wrong in oldDB
# FTND: definitely wrong in Milan's script, do it anew in data_import.R
exempt_from_oldDB_check = c('TIME_SUMA','TIME_SUMB','DEG_TIMEA','DEG_TIMEB',
                            'BIG','SOGS','FTND')
exempt_from_oldDB_chksb = c('PhysioVP0068')

# higher order variable; how many NAs allowed in any questionnaire to still
# compute a mean and estimate a sum of a questionnaire?
# in percent
perc_na_allowed = 90

# check if private path is a network folder.
if (substr(path_rslt_private, 1, 1) =="C" | substr(path_rslt_private, 1, 1) =="D"){
  stop(c("The path specified under path_rslt_private: ", path_rslt_private, " is not a network path.
          Please make sure the private patient data is stored correct!") )
}

# get the Teilnehmerliste (should be in higher order script)
tnl_file     = paste0(path_exch,paste0('/BCAN/Probandenlisten/',
                                   'Teilnehmerliste_VPPG_ONLY_USE_THIS_ONE.xlsx'))
tnl          = read_excel(tnl_file,sheet = 1,col_names = T)
#tnl          = read.xlsx(tnl_file, sheetName='Teilnehmerliste_VPPG',2, header=TRUE)
tnl$VPPG     = as.character(tnl$VPPG)
tnl          = tnl[!is.na(tnl$VPPG),]
tnl$VPPG     = trimws(tnl$VPPG)
tnl$PhysioVP = paste0("PhysioVP",tnl$PhysioVP)
tnl$PhysioVP = trimws(tnl$PhysioVP)

# prelimn check that there are no duplicates in tnl
if (sum(duplicated(tnl$VPPG))) {
  mes_1 = 'You have these duplicate VPPG numbers in Teilnehmerliste. Fix first!\n'
  mes_2 = paste(tnl$VPPG[duplicated(tnl$VPPG)],collapse= ' ')
  stop(paste(mes_1,mes_2))
}

# issue warnings of todos
warning("VPPG0338's questionnaire was just an exercise, not a real subject. Yet have to implement.")

### start lower level scripts
# TODO: path script
setwd(path_data)
source('agk_quest_rating_intermediate.R')
source('jpa_import_screening_from_sosci.r')
