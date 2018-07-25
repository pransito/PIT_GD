# getting data
# getting dat_match and fm list from MRI study
setwd('C:/Users/genaucka/Google Drive/Library/01_Projects/PIT_GD/R/analyses/01_classification')
mri_e = new.env()
load('dat_MRI.RData',envir = mri_e)

# dat_match to one
dat_match$study       = 'PP'
mri_e$dat_match$study = 'MRI'
dat_match_cmpl        = rbind(mri_e$dat_match,dat_match)

# get the exp params
lac_mri        = mri_e$fm$lac
larc_mri       = mri_e$fm$larc
lac_mri$study  = 'MRI'
larc_mri$study = 'MRI'

lac_pp        = fm$lac
larc_pp       = fm$larc
lac_pp$study  = 'PP'
larc_pp$study = 'PP'

lac_cmp      = rbind(lac_mri,lac_pp)
larc_cmp     = rbind(larc_mri,larc_pp)

# hypothesis that education has an influence (in the current study (should be MRI))
# on la / lar paramters
summary(lm(fm$larc$ratio ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$lac$gain ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$lac$loss ~ dat_match$HCPG + dat_match$edu_hollingshead))

# but not on cue reactivity PIT parameters
summary(lm(fm$ac$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$ac$catpositive ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$ac$catnegative ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$larc$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$lac$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))

# on la / lar paramters
summary(lm(mri_e$fm$larc$ratio ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$lac$gain ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$lac$loss ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))

# but not on cue reactivity / PIT parameters
summary(lm(mri_e$fm$ac$catgambling ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$ac$catpositive ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$ac$catnegative ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$larc$catgambling ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))
summary(lm(mri_e$fm$lac$catgambling ~ mri_e$dat_match$HCPG + mri_e$dat_match$edu_hollingshead))

# hypothesis that task structure make a difference
# model the effect of study (i.e. task structure; regardless of group)
# effect on la models
summary(lm(lac_cmp$loss ~ dat_match_cmpl$HCPG + lac_cmp$study))
summary(lm(lac_cmp$gain ~ dat_match_cmpl$HCPG + lac_cmp$study))
summary(lm(larc_cmp$ratio ~ dat_match_cmpl$HCPG + larc_cmp$study))

# effect on cue reactivity / PIT params
summary(lm(lac_cmp$catgambling ~ dat_match_cmpl$HCPG + lac_cmp$study))
summary(lm(lac_cmp$catnegative ~ dat_match_cmpl$HCPG + lac_cmp$study))
summary(lm(larc_cmp$catgambling ~ dat_match_cmpl$HCPG + larc_cmp$study))

# so then we can also check for effect of education overall
# on la / lar paramters
summary(lm(larc_cmp$ratio ~ dat_match_cmpl$HCPG + dat_match_cmpl$edu_hollingshead))
summary(lm(lac_cmp$gain ~ dat_match_cmpl$HCPG + dat_match_cmpl$edu_hollingshead))
summary(lm(lac_cmp$loss ~ dat_match_cmpl$HCPG + dat_match_cmpl$edu_hollingshead))

# but not on cue reactivity PIT parameters
summary(lm(fm$ac$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$ac$catpositive ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$ac$catnegative ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$larc$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))
summary(lm(fm$lac$catgambling ~ dat_match$HCPG + dat_match$edu_hollingshead))

# education differences between groups/studies
summary(lm(edu_hollingshead ~ HCPG*study, data = dat_match_cmpl))
aggregate(edu_hollingshead ~ HCPG + study,data = dat_match_cmpl,FUN = mean)
aggregate(edu_hollingshead ~ HCPG + study,data = dat_match_cmpl,FUN = median)
t.test(dat_match_cmpl$edu_hollingshead[dat_match_cmpl$HCPG == 'HC' & dat_match_cmpl$study == 'PP'],
       dat_match_cmpl$edu_hollingshead[dat_match_cmpl$HCPG == 'HC' & dat_match_cmpl$study == 'MRI'])

# do cue reactivity / PIT and la correlate?
# current study [should be in PP]
cor.test(fm$larc$ratio,fm$larc$catgambling)
cor.test(fm$lac$gain,fm$lac$catgambling)
cor.test(fm$lac$loss,fm$lac$catgambling)
cor.test(fm$lac$loss,fm$lac$catnegative)
cor.test(fm$lac$loss,fm$lac$catpositive)

# MRI study
cor.test(mri_e$fm$larc$ratio,mri_e$fm$larc$catgambling)
cor.test(mri_e$fm$lac$gain,mri_e$fm$lac$catgambling)
cor.test(mri_e$fm$lac$loss,mri_e$fm$lac$catgambling)
cor.test(mri_e$fm$lac$gain,mri_e$fm$lac$catnegative)
cor.test(mri_e$fm$lac$loss,mri_e$fm$lac$catnegative)
cor.test(mri_e$fm$lac$loss,mri_e$fm$lac$catpositive)

# overall
cor.test(larc_cmp$ratio,larc_cmp$catgambling)
cor.test(lac_cmp$gain,lac_cmp$catgambling)
cor.test(lac_cmp$loss,lac_cmp$catgambling)
cor.test(lac_cmp$loss,lac_cmp$catnegative)
cor.test(lac_cmp$loss,lac_cmp$catpositive)
