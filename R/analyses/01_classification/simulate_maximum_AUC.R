# create a variable that correlates with another variable as you would like
# and the compute the AUC based on a given cut off in the original variable
sim_aucs = c()

for (ii in 1:1000) {
  # create the initial x variable
  x1 <- dat_match$KFG
  
  # x2, x3, and x4 in a matrix, these will be modified to meet the criteria
  x234 <- scale(matrix(rnorm(length(dat_match$KFG)*2), ncol=2))
  
  # put all into 1 matrix for simplicity
  x1234 <- cbind(scale(x1),x234)
  
  # find the current correlation matrix
  c1 <- var(x1234)
  
  # cholesky decomposition to get independence
  chol1 <- solve(chol(c1))
  
  newx <-  x1234 %*% chol1 
  
  # check that we have independence and x1 unchanged
  zapsmall(cor(newx))
  all.equal( x1234[,1], newx[,1] )
  
  # create new correlation structure (zeros can be replaced with other rvals)
  newc <- matrix( 
    c(1  , 0.4, 0.8, 
      0.4, 1  , 0  ,
      0.8, 0  , 1), ncol=3 )
  
  
  # check that it is positive definite
  eigen(newc)
  
  chol2 <- chol(newc)
  
  finalx <- newx %*% chol2 * sd(x1) + mean(x1)
  finalx = finalx[,c(1,3)]
  
  # now compute the ROC_AUC
  finalxdf = data.frame(finalx)
  names(finalxdf) = c('ORIG','SIM')
  finalxdf$ORIG = ifelse(finalxdf$ORIG>=16,'HC','PG')
  cur_roc = roc(response = finalxdf$ORIG,finalxdf$SIM)
  sim_aucs[ii] = auc(cur_roc)
}

print(agk.mean.quantile(sim_aucs,lower = 0.025,upper = 0.975))

# # verify success
# mean(x1)
# colMeans(finalx)
# 
# sd(x1)
# apply(finalx, 2, sd)
# 
# zapsmall(cor(finalx))
# pairs(finalx)
# 
# all.equal(x1, finalx[,1])
