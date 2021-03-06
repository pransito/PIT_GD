## PREAMBLE ====================================================================
# Calculates Beta_0, Beta_Gain and Beta_Loss parameters 
# see Charpentier et al. 2015 or Charp. et al. 2012
# but no mu!

## PARAMS ======================================================================
# starting values for model params
beta_ints   = randn(1,2)
beta_gains  = randn(1,2)
beta_losss  = randn(1,2)
beta_eds    = randn(1,2)
all_subs    = unique(data_pdt$subject)

## FUNCTIONS ===================================================================
# function to compute log-likelihood given certain model params
fn<- function(theta,x){
  beta_int  = theta[1]
  beta_gain = theta[2]
  beta_loss = theta[3]
  beta_ed   = theta[4]
  res1      = 0
  for (k in 1:nrow(x)){ #go through all trials
    if (is.na(x$accnum[k])){
      #skip trials without reaction
    } 
    else{ 
      # garding against high/low values
      # term_1
      term_1 = x$gain_bcp[k]^beta_gain
      if (term_1 == Inf) {
        term_1 = .Machine$double.xmax
      } else if (term_1 == -Inf) {
        term_1 = -.Machine$double.xmax
      }
      # term_2
      term_2 = abs(x$loss_bcp[k])^beta_loss
      if (term_2 == Inf) {
        term_2 = .Machine$double.xmax
      } else if (term_1 == -Inf) {
        term_2 = -.Machine$double.xmax
      }
      value    = beta_int + term_1 - term_2 + x$ed_abs[k]*beta_ed;
      prob_acc = (1+exp(-value))^-1;
      # bound on high prob
      if(prob_acc > 0.9999999999999999) {
        prob_acc = 1-.Machine$double.neg.eps
      }
      # bound on low prob
      if(prob_acc == 0) {
        prob_acc = .Machine$double.neg.eps
      }
      # get current log likelihood 
      res = x$accnum[k]*log(prob_acc) + (1-x$accnum[k])*log(1-prob_acc);
      
      # avoiding -Inf and +Inf
      if (res == -Inf) {
        res =  -.Machine$double.xmax
      } else if (res == Inf) {
        res = .Machine$double.xmax
      }
      res1 = res1-res;
    }
  }
  return(res1)
}
fn.c = cmpfun(fn)

# maximization function
do_maxim = function(cur_sub,beta_ints,beta_gains,beta_losss,beta_eds,x,fn.c) {
  y3       = as.character(cur_sub)
  x$acc    = x$accept_reject
  x$accnum = as.numeric(as.character(x$acc))
  
  x1_list  = list()
  x1_value = c()
  for (kk in 1:length(beta_ints)) {
    cur_theta = c(beta_ints[kk],beta_gains[kk],beta_losss[kk],beta_eds[kk])
    # maximize likelihood of parameters 
    x1_list[[kk]] = optim(cur_theta,fn.c,x=x)
    x1_value[kk]  = x1_list[[kk]]$value
  }
  # get global minimums of ML-estimates
  cur_winner = which(min(x1_value) == x1_value)
  # if more than one have same min, take highest mu
  cur_winner = cur_winner[length(cur_winner)]   
  x1 = x1_list[[cur_winner]]
  x2 = list()
  x2$name   = y3
  x2$params = c(beta_int  = as.numeric(x1$par[1]),
                beta_gain = as.numeric(x1$par[2]),
                beta_loss = as.numeric(x1$par[3]),
                beta_ed   = as.numeric(x1$par[4]))
  return(x2)
}
do_maxim.c = cmpfun(do_maxim)

## PARALLEL PROCESSING ========================================================
all_cat       = levels(data_pdt$cat)
all_params    = list()
data_pdt_cbcp = data_pdt 
for (ii in 1:length(all_cat)) {
  # get the data_pdt of current cat
  data_pdt = data_pdt_cbcp
  data_pdt = subset(data_pdt, cat == all_cat[ii])
  
  # run on parallel
  cl<-makeCluster(7)  
  registerDoSNOW(cl)
  maxim_results <- foreach(ff=1:length(all_subs),.verbose=T) %dopar% {
    x = subset(data_pdt, subject == all_subs[ff])
    do_maxim.c(all_subs[ff],beta_ints,beta_gains,beta_losss,beta_eds,x,fn.c)
  }
  stopCluster(cl)
  
  # bind all params after all subs have been fit
  all_params[[ii]] = t(as.matrix(maxim_results[[1]]$params))
  VPNR             = c()
  VPNR[1]          = maxim_results[[1]]$name
  for (jj in 2:length(maxim_results)) {
    VPNR[jj]         = maxim_results[[jj]]$name
    all_params[[ii]] = rbind(all_params[[ii]],maxim_results[[jj]]$params)
  }
  all_params[[ii]] = as.data.frame(all_params[[ii]])
  all_params[[ii]] = cbind(VPNR,all_params[[ii]])
}

## PACKING INTO DF ============================================================
## now into one data frame with cat specific params (neutral is baseline)
all_params_combined = all_params[[1]]
for (ii in 2:length(all_params)) {
  # extract
  cur_params = all_params[[ii]]
  # names
  cur_names  = (names(cur_params))
  diff_names = paste0(cur_names[grep('VPNR',cur_names,invert = T)],
                      ':cat',all_cat[ii])
  cur_names[grep('VPNR',cur_names,invert = T)] = diff_names
  names(cur_params) = cur_names
  # baseline subtraction
  cur_pdiff = cur_params[-1] - all_params[[grep('neutral',all_cat)]][-1]
  cur_params[-1] = cur_pdiff
  # merging
  all_params_combined = merge(all_params_combined,cur_params,by = 'VPNR')
}

all_params = all_params_combined

## SAVING =====================================================================
save(file=paste0("lanlec",which_study,".RData"),list = c("all_params","fn.c"))

