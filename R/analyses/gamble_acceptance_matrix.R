# probability of accceptance map
agk.print.poa = function(gmat,by_group,by_category) {
  
  base_size = 24
  p = ggplot(gmat, aes(gain, loss))
  p = p + geom_tile(aes(fill = poa), colour = "white")
  p = p + scale_fill_gradient(low = "white", high = "steelblue")
  
  p = p + theme_grey(base_size = base_size) + labs(x = "", y = "") 
  p = p + scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0))
  p = p + xlab('Gain')
  p = p + ylab('Loss')
  p = p + guides(fill=guide_legend(title="Gamble\n acceptance (poa)"))
  p = p + ggtitle('Gamble matrix with mean acceptance per gamble')
  
  if (by_group == T & by_category == F) {
    p = p + facet_grid(~group)
  }
}

agk.get.poa =  function(data_pdt,by_group,by_category) {
  # function to print a probability of acceptance map
  # no aggregation of gain and loss
  # poa first per subject
  # then mean per group/per category or overall
  if (by_group == F & by_category == F) {
    aggr_dat = aggregate(as.numeric(as.character(data_pdt$accept_reject)),
                         by=list(data_pdt$subject,data_pdt$gain_bcp,data_pdt$loss_bcp),FUN=mean.rmna)
    names(aggr_dat) = c('subject','gain','loss','poa')
    aggr_dat = aggregate(aggr_dat$poa,
                         by=list(aggr_dat$gain,aggr_dat$loss),FUN=mean.rmna)
    
    names(aggr_dat) = c('gain','loss','poa')
    
    base_size = 24

  } else if (by_group == T & by_category == F) {
    aggr_dat = aggregate(as.numeric(as.character(data_pdt$accept_reject)),
                         by=list(data_pdt$subject,data_pdt$HCPG,data_pdt$gain_bcp,data_pdt$loss_bcp),
                         FUN=mean.rmna)
    names(aggr_dat) = c('subject','HCPG','gain','loss','poa')
    aggr_dat = aggregate(aggr_dat$poa,
                         by=list(aggr_dat$HCPG,aggr_dat$gain,aggr_dat$loss),FUN=mean.rmna)
    
    names(aggr_dat) = c('group','gain','loss','poa')
    

   
  }
  
  
}


