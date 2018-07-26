# cur cost function
cur_cost_fun = function()


# call
cvTools::cvFit(ac$VPPG0017,y=ac$VPPG0005$model$accept_reject,data=ac$VPPG0005$model,cost=auc)


cur_glm_fun = function(x,y) {
  cur_mod = glm(y ~ x,family='binomial')
  return(cur_mod)
}
  
  = parse(text="glm(ac$VPPG0005$model$accept_reject ~ ac$VPPG0005$model$cat,family='binomial')")

cvTools::cvFit(object=cur_glm_fun,y=ac$VPPG0005$model$accept_reject,x = ac$VPPG0005$model$cat,cost=auc)

# using call
cur_call <- call("glm", formula = accept_reject ~ .,family='binomial')
cvTools::cvFit(object=cur_call,y=cur_dat$accept_reject,data = cur_dat,cost=auc)

# using cv.glm (won't work)
cur_dat = la$VPPG0005$model
cur_glm = glm(accept_reject ~ .,family='binomial',data = cur_dat)
#cv.glm(cur_dat,cur_glm,roc,5)
cvTools::cvFit(object=cur_glm,y=cur_glm$model$accept_reject,data=cur_glm$model,cost=auc,K=10)

cvTools::cvFit()


# using BIC or AIC
pref_FUN      = AIC
cur_name      = names(fm_bcp)[1]
cur_res       = unlist(lapply(fm_bcp[[1]],FUN = AIC))
evl_df        = as.data.frame(cur_res)
names(evl_df) = cur_name
for (bb in 2:length(fm_bcp)) {
  cur_res = unlist(lapply(fm_bcp[[bb]],FUN = AIC))
  evl_df[names(fm_bcp)[bb]] = cur_res
}

cur_tab        = table(apply(evl_df,MARGIN = 1,FUN = which.min))
names(cur_tab) = names(evl_df)[as.numeric(names(cur_tab))]
print(cur_tab)
