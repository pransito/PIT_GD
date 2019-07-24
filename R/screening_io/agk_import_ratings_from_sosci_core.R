# import the ratings data from sosci server data
# this is a subscript of the export_from_sosci_routine
# it requires the rdata files from R (Bilderrating_VPPG &
# Bilderrating_VPPG02) and the pertinent Sosci R scripts
# which read in these data into R data frames 

# Bilderrating_VPPG download
# the following is done in intermediate script!
# Download the data in the R format from sosci: 
# Variables: any data stored in the data set, includinf those 
# from deleted question and items time spent per page and other 
# variables, data quality parameters, all the data -- All records, 
# mode all unchecked,  Item-nonresponse <=  100 %
# this is old questionnaires data
# this is also the old database where all the data was stored 
# before january 2016

# requires:
# path_data: folder with all the exported data and scripts
# from sosci from the current export
# path_exch: folder where the VPPG_exchange stuff lies
# all import of data_VPPG and data_VPPG02 must have been done
# all subject cleaning must have been done (data_VPPGc and
# data_VPPG02c are ready)

# this script only does editing of data_VPPGc and data_VPPG02c
# to retrieve and print the ratings per person
# on csv sheet per subjects

# TODO: needs to be completely reprogrammed to only work with VPPG numbers

################################
## FROM HERE RATINGS SPECIFIC ##
################################

# home wd
home_wd = getwd()

# path for the results
path_resr = paste0(path_exch,'/Bilderrating/Results_Pretest',
                   '/Result files')

# subject exempt from ratings
exempt_ratings_subs = c('VPPG0608','PhysioVP2222',
                        'PhysioVP004','PhysioVP002','PhysioVP003',
                        'PhysioVP001','PhysioVP005', 'PhysioVP09',
                        '0828')

# functions
agk.pad = function(x,length.out,what) {
  # function to pad a vector with reps
  # of what until reaching length.out
  num_to_pad = length.out-length(x)
  if (num_to_pad < 0) {
    stop('length.out shorter than given vector!')
  }
  x = c(x,rep(what,num_to_pad))
  return(x)
}

agk.second = function(x) {
  # function that returns the second element
  return(x[2])
}

agk.first = function(x) {
  # function that returns the first element
  return(x[1])
}

agk.substr.first = function(x) {
  # function that returns the first element
  # of a string
  # will try to convert to string
  # NA is returned as NA
  # will do this for all elements of x
  res = c()
  for (ii in 1:length(x)) {
    cur_el = x[ii]
    if (is.na(cur_el)) {
      res[ii] = x[ii]
    } else {
      cur_el  = as.character(cur_el)
      cur_el  = substr(cur_el,1,1)
      res[ii] = cur_el
    }
  }
  return(res)
}

# the final labels to be used for writing csv files (one per sub)
vars_labels     = c('imageID','order','imageGroup','imageRating1','imageRating2',
                    'imageRating3','imageRating4','imageRating5','arousal',
                    'dominance','valence','imageRatingDur','imageManikinDur')

# ratings vars of interest (key words to find the correct rating scales)
vars_of_int     = enc2utf8(c('Verlangen','ein oder mehrere Gl','negative Folgen','positive Folgen',
                             'hinterfragen','Arousal','Dominance','Valence'))

# unit test that Glücksspiel is encoded correctly
if (isempty(grep('ein oder mehrere Gl',vars_of_int))) {
  stop('vars_of_int is empty; probably encoding error!')
}

# for finding Manikin Durations
cut_to_start_A = 3
cut_to_start_B = 7

# selecting rows only for a specific cohort
# for this we first need to check the ratings
# that have already been exported by subjects
setwd(path_resr)
exported_ratings = dir(pattern = 'data_Bilderrating_')
exported_ratings = exported_ratings[grep('_organized.csv',exported_ratings)]
exported_ratings = strsplit(exported_ratings,'Bilderrating_')
exported_ratings = as.character(unlist(lapply(exported_ratings,FUN=agk.second)))
exported_ratings = strsplit(exported_ratings,'_Ratings')
exported_ratings = as.character(unlist(lapply(exported_ratings,FUN=agk.first)))

# now create a vector of all subs that will henceforth be ignored in export
exempt_subs = c(test_codes,exported_ratings,exempt_ratings_subs)

# PART A: Bilderrating_VPPG (only part A?!?!)
data_A         = data_VPPGc
data_A$subject = data_A$P104_01

# now correct and reorganize subs
# TODO: this is actually exactly the same work as in questionnaire,
# BUT rownames are of course not the same, so you have to find the row.names here
# this work needs to be done here to be completely documented; so far
# Milan had this subject number fixing done by hand in the exported csv
# after fixing of subs we can exclude exempt subjects
data_A         = data_A[!data_A$subject %in% exempt_subs,]

# vars denoting image IDs
# using hash 'IV' in names to find variables storing imageIDs
# this I had to find out in Milan's Matlab script, there is no comments for these variables
# explaining that they hold the imageID infos
# TODO: CAREFUL assuming that the succession of rating_var follows the 
# succession of imageID vars, i.e. first arousal var will be
# put to first imageID, and so on
id_vars  = grep('IV',data_VPPG_names)

# duration variables
dur_vars = grep(paste0('TIME'),data_VPPG_names)
cur_len  = length(dur_vars)
# cutting overall time variables
dur_vars = dur_vars[-c(cur_len-2,cur_len-1,cur_len)]
# cutting of first pages that are not ratings
dur_vars = dur_vars[-c(seq(1,cut_to_start_A))]
# after that manikin is always first then it is other ratings
# TODO: check if correct, cause Milan's script seems a bit different
# says ratings is always two pages before manikin (?!?)

# going through all rows (subjects and making a ratings data frame)
# for each subject) 
ratings_data_A = list()

# reporting
print('Exporting ratings from Bilderrating_VPPG')

# setting up progress bar
total = length(data_A$subject)
txtprogress = 0
if (total > 0) {
  pb          = txtProgressBar(min = 0, max = total, style = 3)
  txtprogress = 1
}

if (total >= 1){
  for (ii in 1:total) {
    # all data of this subject
    cur_dat = data_A[ii,]
    
    # what's the subject's given name?
    cur_sub = cur_dat$subject
    
    # what is the succession of image ID's?
    cur_ids        = cur_dat[,id_vars]
    cur_ids        = as.character(cur_ids)
    res_df         = data.frame(cur_ids)
    res_df$subject = as.character(cur_sub)
    
    # ratings
    # TODO: we have maximum values of "101" instead of 100
    for (jj in 1:length(vars_of_int)) {
      cur_rvs = grep(vars_of_int[jj],data_VPPG_comm)
      cur_rat = as.character(cur_dat[cur_rvs])
      # Ratings is two values or so short compared to IDs
      # need to pad here!
      cur_rat = agk.pad(cur_rat,length(cur_ids),NA)
      cur_ldf = length(res_df)
      res_df[[cur_ldf+1]] = cur_rat
      names(res_df)[cur_ldf+1] = vars_of_int[jj]
    }
    
    # Manikin and Ratings duration
    man_dur = c()
    rat_dur = c()
    for (jj in 1:length(res_df[,1])) {
      man_dur[jj] = as.numeric(cur_dat[dur_vars[jj]])
      rat_dur[jj] = as.numeric(cur_dat[dur_vars[jj+1]])
    }
    # attaching this information to current df
    cur_ldf                  = length(res_df)
    res_df[[cur_ldf+1]]      = rat_dur
    res_df[[cur_ldf+2]]      = man_dur
    names(res_df)[cur_ldf+1] = 'RatingsDur'
    names(res_df)[cur_ldf+2] = 'ManikinDur'
    
    # sorting by imageID and getting an order variable
    cur_order = order(res_df$cur_ids)
    res_df    = res_df[cur_order,]
    
    # getting an image group variable
    cur_group = agk.substr.first(res_df$cur_ids)
    cur_group = suppressWarnings(as.numeric(cur_group))
    
    # adding order and image group
    res_df$order       = cur_order
    res_df$image_group = cur_group
    
    # ordering the variables and packing it
    res_df          = res_df[c(1,13,14,3,4,5,6,7,8,9,10,11,12)]
    cur_res         = list()
    cur_res$subject = cur_sub
    cur_res$df      = res_df
    
    # cleaning the df
    cur_res$df = subset(cur_res$df, !is.na(cur_res$df$cur_ids))
    cur_res$df = subset(cur_res$df, cur_res$df$cur_ids != 'NA')
    id_check   = regexpr(pattern = '[0-9]{5}',text=cur_res$df$cur_ids)
    if (any(attr(id_check, 'match.length') != 5)) {
      cur_drop = which(attr(id_check, 'match.length') != 5)
      cur_res$df = cur_res$df[-cur_drop,]
    }
    if (any(duplicated(cur_res$df$cur_ids))) {
      stop('Duplicate(s) in current ratings export sub\'s image IDs. Part A. Check!')
    }
    
    # storing the current ratings df of this subject
    ratings_data_A[[ii]] = cur_res
    
    # update progress bar
    if (txtprogress) {
      setTxtProgressBar(pb, ii)
    }
  }
  
  # close progress bar
  if (txtprogress) {
    close(pb)
  }
}

# PART A has in it old subs with PDT and SLM ratings
subs_A   = as.character(unlist(lapply(ratings_data_A,FUN=agk.first)))
dup_A    = subs_A[duplicated(subs_A)]
repl_rat = list()
repl_ind = c()

# merging the data of subs that are duplicate
# thinking 1st and 2nd data.frame
if (length(dup_A) != 0) {
  for (ii in 1:length(dup_A)) {
    cur_res  = list()
    cur_sub  = dup_A[ii]
    cur_ind  = which(subs_A == cur_sub)
    repl_ind = c(repl_ind,cur_ind)
    if (length(cur_ind) > 2) {
      stop('More than 1 duplicate of a subject in data_A. No rule for this.')
    } else {
      # getting and cleaning
      df_1 = ratings_data_A[[cur_ind[1]]]$df
      df_2 = ratings_data_A[[cur_ind[2]]]$df
      df_1 = df_1[!is.na(df_1$Verlangen),]
      df_2 = df_2[!is.na(df_2$Verlangen),]
      df_1 = df_1[!df_1$Verlangen == 'NA',]
      df_2 = df_2[!df_2$Verlangen == 'NA',]
      df_1 = df_1[!df_1$Verlangen == '<NA>',]
      df_2 = df_2[!df_2$Verlangen == '<NA>',]
      # combining
      cur_df  = rbind(df_1,df_2)
      # storing
      cur_res$subject = cur_sub
      cur_res$df      = cur_df
      repl_rat[[ii]]   = cur_res
    }
  }
  
  # deleting old duplicates and replacing
  ratings_data_A[repl_ind] = NULL
  for (ii in 1:length(repl_rat)) {
    ratings_data_A[[length(ratings_data_A) + 1]] = repl_rat[[ii]]
  }
}

# PART B: Bilderrating_VPPG02 (SLM)

# This is for the SLM ratings
data_B         = data_VPPG02c
data_B$subject = data_B$P104_01

# now correct and reorganize subs
# TODO: this is actually exactly the same work as in questionnaire,
# BUT rownames are of course not the same, so you have to find the row.names here
# this work needs to be done here to be completely documented; so far
# Milan had this subject number fixing done by hand in the exported csv
# after fixing of subs we can exclude exempt subjects
data_B         = data_B[!data_B$subject %in% exempt_subs,]

# vars denoting image IDs
# using hash 'IV' in names to find variables storing imageIDs
# this I had to find out in Milan's Matlab script, there is no comments for these variables
# explaining that they hold the imageID infos
# TODO: CAREFUL assuming that the succession of rating_var follows the 
# succession of imageID vars, i.e. first arousal var will be
# put to first imageID, and so on
id_vars = grep('IV',data_VPPG02_names)

# duration variables
dur_vars = grep(paste0('TIME'),data_VPPG02_names)
cur_len  = length(dur_vars)
# cutting overall time variables
dur_vars = dur_vars[-c(cur_len-2,cur_len-1,cur_len)]
# cutting of first pages that are not ratings
dur_vars = dur_vars[-c(seq(1,cut_to_start_B))]
# after that manikin is always first then it is other ratings
# TODO: check if correct, cause Milan's script seems a bit different
# says ratings is always two pages before manikin (?!?)

# going through all rows (subjects and making a ratings data frame)
# for each subject) 
ratings_data_B = list()

# reporting
print('Exporting ratings from Bilderrating_VPPG02')

# setting up progress bar
total = length(data_B$subject)
if (total > 0) {
  txtprogress = 1
  pb          = txtProgressBar(min = 0, max = total, style = 3)
} else {
  txtprogress = 0
}

if (total > 0) {
  for (ii in 1:total) {
    # all data of this subject
    cur_dat = data_B[ii,]
    
    # what's the subject's given name?
    cur_sub = cur_dat$subject
    
    # what is the succession of image ID's?
    cur_ids        = cur_dat[,id_vars]
    cur_ids        = as.character(cur_ids)
    res_df         = data.frame(cur_ids)
    res_df$subject = as.character(cur_sub)
    
    # ratings
    # TODO: Ratings is two values or so short compared to IDs
    # need to pad here!
    # TODO: we have maximum values of "101" instead of 100
    for (jj in 1:length(vars_of_int)) {
      cur_rvs = grep(vars_of_int[jj],data_VPPG02_comm)
      cur_rat = as.character(cur_dat[cur_rvs])
      cur_rat = agk.pad(cur_rat,length(cur_ids),NA)
      cur_ldf = length(res_df)
      res_df[[cur_ldf+1]] = cur_rat
      names(res_df)[cur_ldf+1] = vars_of_int[jj]
    }
    
    # Manikin and Ratings duration
    man_dur = c()
    rat_dur = c()
    for (jj in 1:length(res_df[,1])) {
      man_dur[jj] = as.numeric(cur_dat[dur_vars[jj]])
      rat_dur[jj] = as.numeric(cur_dat[dur_vars[jj+1]])
    }
    # attaching this information to current df
    cur_ldf                  = length(res_df)
    res_df[[cur_ldf+1]]      = rat_dur
    res_df[[cur_ldf+2]]      = man_dur
    names(res_df)[cur_ldf+1] = 'RatingsDur'
    names(res_df)[cur_ldf+2] = 'ManikinDur'
    
    # sorting by imageID and getting an order variable
    cur_order = order(res_df$cur_ids)
    res_df    = res_df[cur_order,]
    
    # getting an image group variable
    cur_group = agk.substr.first(res_df$cur_ids)
    cur_group = suppressWarnings(as.numeric(cur_group))
    
    # adding order and image group
    res_df$order       = cur_order
    res_df$image_group = cur_group
    
    # ordering the variables and packing it
    res_df          = res_df[c(1,13,14,3,4,5,6,7,8,9,10,11,12)]
    cur_res         = list()
    cur_res$subject = cur_sub
    cur_res$df      = res_df
    
    # cleaning the df
    cur_res$df = subset(cur_res$df, !is.na(cur_res$df$cur_ids))
    cur_res$df = subset(cur_res$df, cur_res$df$cur_ids != 'NA')
    id_check   = regexpr(pattern = '[0-9]{5}',text=cur_res$df$cur_ids)
    if (any(attr(id_check, 'match.length') != 5)) {
      cur_drop = which(attr(id_check, 'match.length') != 5)
      cur_res$df = cur_res$df[-cur_drop,]
    }
    if (any(duplicated(cur_res$df$cur_ids))) {
      stop('Duplicate(s) in current ratings export sub\'s image IDs. Part B. Check!')
    }
    
    # storing the current ratings df of this subject
    ratings_data_B[[ii]] = cur_res
    
    # update progress bar
    setTxtProgressBar(pb, ii)
  }
  
  # close progress bar
  close(pb)
}

# ADDING THE RATINGS_B to RATINGS_A where appropriate

# prep a final ratings data list
ratings_data = list()

# prep the available subjects from data_B
subs_B = as.character(unlist(lapply(ratings_data_B,FUN=agk.first)))
subs_A = as.character(unlist(lapply(ratings_data_A,FUN=agk.first)))

if (length(ratings_data_A)) {
  for (ii in 1:length(ratings_data_A)) {
    
    # prep the current result
    cur_res = list()
    
    # get current data frame and subject
    cur_sub = ratings_data_A[[ii]]$subject
    cur_df  = ratings_data_A[[ii]]$df
    
    # find the data_B for this subject
    cur_ind_B = NULL
    cur_ind_B = grep(paste0('\\b',cur_sub,'\\b'),subs_B)
    
    if (length(cur_ind_B) != 0) {
      # we combine A and B
      cur_df = rbind(cur_df,ratings_data_B[[cur_ind_B]]$df)
      
      # crossing ind_B from list
      subs_B = subs_B[-cur_ind_B]
    }
    
    # packing
    cur_res$subject = cur_sub
    cur_res$df      = cur_df
    
    # storing
    ratings_data[[ii]] = cur_res
  }
}

# allow export of remaining data_B data sets
all_subs_B    = as.character(unlist(lapply(ratings_data_B,FUN=agk.first)))
cur_ind_B     = unlist(lapply(subs_B,FUN=grep,x=all_subs_B))
if (!is.null(cur_ind_B)) {
  for (ii in 1:length(cur_ind_B)) {
    ratings_data[[length(ratings_data)+1]]  = ratings_data_B[[cur_ind_B[ii]]]
  }
}



# exempt subjects
ind_exempt = c()
if (length(ratings_data)) {
  for (ii in 1:length(ratings_data)) {
    if (ratings_data[[ii]]$subject %in% exempt_ratings_subs) {
      ind_exempt = c(ind_exempt,ii)
    }
  }
  if (!is.null(ind_exempt)) {
    ratings_data = ratings_data[-ind_exempt]
  }
}



# writing output
if (length(ratings_data) != 0) {
  # cleaning of NAs and names
  for (ii in 1:length(ratings_data)) {
    
    # cleaning
    df_1 = ratings_data[[ii]]$df
    df_1 = df_1[!is.na(df_1$Verlangen),]
    df_1 = df_1[!df_1$Verlangen == 'NA',]
    df_1 = df_1[!df_1$Verlangen == '<NA>',]
    
    # names
    names(df_1) = vars_labels
    
    # storing
    ratings_data[[ii]]$df = df_1
  }
  
  all_subs = as.character(unlist(lapply(ratings_data,FUN=agk.first)))
  
  # TODO: check against TN-Liste to really just write subs needed
  # ...
  
  # write
  setwd(path_resr)
  for (ii in 1:length(ratings_data)) {
    cur_sub = ratings_data[[ii]]$subject
    cur_df  = ratings_data[[ii]]$df
    cur_file = paste0('data_Bilderrating_', cur_sub ,'_Ratings_organized.csv')
    write.table(cur_df,cur_file,sep = ',',row.names = F,quote = F)
  }
  
} else {
  print('Writing ratings data not necessary. Everything already written.')
}

# TODO check against TN-List again if all subs have ratings
setwd(path_resr)
exported_ratings = dir(pattern = 'data_Bilderrating_')
exported_ratings = exported_ratings[grep('_organized.csv',exported_ratings)]
exported_ratings = strsplit(exported_ratings,'Bilderrating_')
exported_ratings = as.character(unlist(lapply(exported_ratings,FUN=agk.second)))
exported_ratings = strsplit(exported_ratings,'_Ratings')
exported_ratings = as.character(unlist(lapply(exported_ratings,FUN=agk.first)))

# what is in tnl
expected_ratings = trimws(tnl$VPPG)

# check against exported ratings (minus exempt)
ngot_ratings = expected_ratings[which(!expected_ratings %in% exported_ratings)]
ngot_ratings = ngot_ratings[which(!ngot_ratings %in% ratin_exempt_list)]

if (length(ngot_ratings) != 0) {
  stop(paste('Not all expected ratings according to tnl and ratin_exmpt are there.',
             paste(ngot_ratings,collapse = ' ')))
} else {
  print('All expected ratings are exported.')
}

# go home
setwd(home_wd)