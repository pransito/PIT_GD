
#install.packages('memisc')
#install.packages('pander')
#first run analysis_physio.R up to the ANALYSIS PDT title and then run this script

data_pdt_aff=data_pdt[!is.na(data_pdt$arousal),]
Col=colnames(data_pdt_aff)

#transforming data so that we have a  variable affRat common for ratings of arousal dominance and valence, 
# and have each row for each of the separate affective ratings
data_pdt_aff_long <- reshape(data_pdt_aff, direction='long', varying=c('arousal','dominance','valence'), 
                             times=c('arousal','dominance','valence'), v.names = "affRat", timevar='affCat')
#Sensitivity variable is the inverse measure of indifference, the absolute values of the affective rating 
data_pdt_aff_long$Sensitivity=abs(data_pdt_aff_long$affRat)

setwd(paste(path_ana, '//plot_bilderratings//', sep = ''))
save.image(file='data_pdt.Rdat')



rmarkdown::render("Bilderrating_Drift_Report.Rmd")
#rmarkdown::render("bilderratingplots_markdown.Rmd")
