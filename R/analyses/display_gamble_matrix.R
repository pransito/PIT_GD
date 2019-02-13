# plot gamble matrix
gain = rep(seq(14,36,2),each=12)
loss = rep(seq(-7,-18,-1),times=12)

gmat = data.frame(gain,loss)

gmat$ed = NA
for (ll in 1:length(gmat[,1])) {
  gmat$ed[ll] = agk_get_ed(c(gmat$gain[ll],abs(gmat$loss[ll]),0),sp = c(26,13,0),vec = c(2,1,0))
}

gmat$gain = as.factor(gmat$gain)
gmat$loss = as.factor(gmat$loss)

base_size = 24
p = ggplot(gmat, aes(gain, loss))
p = p + geom_tile(aes(fill = ed), colour = "white")
p = p + scale_fill_gradient(low = "white", high = "steelblue")

p = p + theme_grey(base_size = base_size) + labs(x = "", y = "") 
p = p + scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0))
p = p + xlab('Gain')
p = p + ylab('Loss')
p = p + guides(fill=guide_legend(title="Gamble\nsimplicity (ed)"))
p = p + ggtitle('Gamble matrix with gamble simplicity per gamble')
p

