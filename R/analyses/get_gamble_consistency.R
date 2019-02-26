# checking gamble consistency

# function
agk.get.t = function(gamble,cur_dat,ii) {
  for (kk in (ii+1) : length(cur_dat[,1])) {
    if (kk > length(cur_dat[,1])) {return(cur_dat)}
    if(gamble == cur_dat$gamble[kk]) {
      # found duplicate
      # increment
      cur_dat$gamble_t[kk] = cur_dat$gamble_t[kk] + cur_dat$gamble_t[ii]
      # note that this is a duplicate gamble
      cur_dat$gamble_d[ii] = 'YES'
      cur_dat$gamble_d[kk] = 'YES'
      
      return(cur_dat)
    }
  }
  return(cur_dat)
}

# plot gamble matrix
plot.gamble.frequency = function(cur_dat) {
  # prep cur_dat
  
  
  # plot gamble freq
  gain = rep(seq(14,36,2),each=12)
  loss = rep(seq(-7,-18,-1),times=12)
  
  gmat = data.frame(gain,loss)
  
  gmat$occurence = 0
  gmat$gamble    = paste0(as.character(gmat$gain),as.character(gmat$loss))
  cur_f          = data.frame(table(cur_dat$gamble))
  gmat           = merge(gmat, cur_f,by.x = 'gamble',by.y = 'Var1',all.x = T)
  gmat$Freq[is.na(gmat$Freq)] = 0
  gmat$occurence = gmat$occurence + gmat$Freq
  
  gmat$occurence = factor(as.character(gmat$occurence),levels = c('0','1','2','3','4'))
  color_palette  = colorRampPalette(c("#3794bf", "#FFFFFF", "#df8640"))(length(levels(gmat$occurence)))
  
  gmat$gain = as.factor(gmat$gain)
  gmat$loss = as.factor(gmat$loss)
  
  base_size = 24
  p = ggplot(gmat, aes(gain, loss))
  p = p + geom_tile(aes(fill = occurence), colour = "white") + scale_fill_manual(values = color_palette)
  #p = p + scale_fill_gradient(low = "white", high = "steelblue")
  
  p = p + theme_grey(base_size = base_size) + labs(x = "", y = "") 
  p = p + scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0))
  p = p + xlab('Gain')
  p = p + ylab('Loss')
  p = p + guides(fill=guide_legend(title="Gamble\nfrequency"))
  p = p + ggtitle(paste('Gmat, gamble frequency ', cur_dat$subject[1]))
  print(p)
}

# prep data
data_pdt$gamble   = paste0(as.character(data_pdt$gain_bcp),as.character(data_pdt$loss_bcp))
data_pdt$gamble_t = 1
data_pdt$gamble_d = 'NO'

all_subs          = unique(data_pdt$subject)
all_dp            = list()
for (ss in 1:length(all_subs)) {
  cur_sub                                = all_subs[ss]
  cur_dat                                = data_pdt[data_pdt$subject == cur_sub,]
  
  for (tt in 1:(length(cur_dat[,1])-1)) {
    cur_dat = agk.get.t(cur_dat$gamble[tt],cur_dat,ii = tt)
  }
  
  # plot gamble freq
  #plot.gamble.frequency(cur_dat)
  
  # split in two times
  cur_dat   = subset(cur_dat,gamble_d == "YES")
  cur_dat   = subset(cur_dat,(gamble_t == 1 | gamble_t == 2))
  cur_dat_1 = subset(cur_dat,(gamble_t == 1))
  cur_dat_2 = subset(cur_dat,(gamble_t == 2))
  
  cur_dat_2$choice_t2 = cur_dat_2$choice
  cur_dat_2 = cur_dat_2[c('gamble','choice_t2')]
  cur_dat   = merge(cur_dat_1,cur_dat_2,by='gamble')
  
  
  all_dp[[ss]] = cur_dat
}
data_pdt_con = bind_rows(all_dp)


# stats
consist  = lmer(choice ~ choice_t2 + (choice_t2|subject),data = data_pdt_con,REML = F)
consistg = lmer(choice ~ choice_t2*HCPG + (choice_t2|subject),data = data_pdt_con,REML = F)
agk.lme.summary(consist,type = 'norm')
agk.lme.summary(consistg,type = 'norm')
anova(consist,consistg)

# get mean correlation
get.cor = function(cur_dat) {
  return(cor(cur_dat$choice,cur_dat$choice_t2))
}
all_cors = unlist(lapply(all_dp,FUN=get.cor))
print(agk.boot.ci(all_cors,cur_fun = mean,lower = 0.025,upper=0.975,R = 1000))





