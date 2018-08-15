# what is the best fitting model per subject with regards to predicting choice?

# using BIC or AIC, devided by group
pref_FUN      = AIC
cur_name      = names(fm_bcp)[1]
cur_res       = unlist(lapply(fm_bcp[[1]],FUN = AIC))
evl_df        = as.data.frame(cur_res)
names(evl_df) = cur_name
for (bb in 2:length(fm_bcp)) {
  cur_res = unlist(lapply(fm_bcp[[bb]],FUN = AIC))
  evl_df[names(fm_bcp)[bb]] = cur_res
}

cur_HCPG     = agk.recode(row.names(evl_df),dat_match$VPPG,as.character(dat_match$HCPG))
#cur_fun     = function(cur_df) {return(apply(cur_df,MARGIN = 1,FUN = which.min))}
#aggregate(.~HCPG,FUN=cur_fun,data=evl_df)

cur_tab_HC        = table(apply(evl_df[cur_HCPG == 'HC',],MARGIN = 1,FUN = which.min))
names(cur_tab_HC) = names(evl_df)[as.numeric(names(cur_tab_HC))]
cur_tab_PG        = table(apply(evl_df[cur_HCPG == 'PG',],MARGIN = 1,FUN = which.min))
names(cur_tab_PG) = names(evl_df)[as.numeric(names(cur_tab_PG))]

print(cur_tab_HC)
print(cur_tab_PG)


# CV does not seem to work; dropping contrast levels; shaky 
# # cur cost function
# cur_cost_fun = function()
#   
#   
#   # call
#   cvTools::cvFit(ac$VPPG0017,y=ac$VPPG0005$model$accept_reject,data=ac$VPPG0005$model,cost=auc)
# 
# 
# cur_glm_fun = function(x,y) {
#   cur_mod = glm(y ~ x,family='binomial')
#   return(cur_mod)
# }
# 
# = parse(text="glm(ac$VPPG0005$model$accept_reject ~ ac$VPPG0005$model$cat,family='binomial')")
# 
# cvTools::cvFit(object=cur_glm_fun,y=ac$VPPG0005$model$accept_reject,x = ac$VPPG0005$model$cat,cost=auc)
# 
# # using call
# cur_call <- call("glm", formula = accept_reject ~ .,family='binomial')
# cvTools::cvFit(object=cur_call,y=cur_dat$accept_reject,data = cur_dat,cost=auc)
# 
# # using cv.glm (won't work)
# cur_dat = la$VPPG0005$model
# cur_glm = glm(accept_reject ~ .,family='binomial',data = cur_dat)
# #cv.glm(cur_dat,cur_glm,roc,5)
# cvTools::cvFit(object=cur_glm,y=cur_glm$model$accept_reject,data=cur_glm$model,cost=auc,K=10)
# 
# cvTools::cvFit()

# CV using glmnet? no, not with just one param
# cur_dat     = la$VPPG0005$model
# cv.glmnet(accept_reject ~ .,data = cur_dat, family='binomial')
