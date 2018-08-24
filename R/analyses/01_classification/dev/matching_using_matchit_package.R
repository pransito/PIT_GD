# propensity score matching
# see wikipedia: https://en.wikipedia.org/wiki/Propensity_score_matching 

# matching
dat_match         = dat_match_mbcp
cur_dm            = dat_match[c('HCPG','edu_years','Age')]
row.names(cur_dm) = row.names(dat_match)
cur_dm$HCPG       = ifelse(cur_dm$HCPG=='PG',1,0)
cur_dm$handedness = as.numeric(cur_dm$handedness)
#m.out             = matchit(HCPG ~ edu_years + Age, data = cur_dm, method = "full", ratio = 1,discard = 'both') # second best; but not balanced;
m.out             = matchit(HCPG ~ edu_years + Age , data = cur_dm, method = "nearest", discard = "both")        # GOOD!
#m.out             = matchit(HCPG ~ edu_years + Age, data = cur_dm, method = "cem", discard = "both")
#m.out             = matchit(HCPG ~ edu_years + Age, data = cur_dm, method = "subclass", discard = "both")
#m.out             = matchit(HCPG ~ edu_years + Age, data = cur_dm, method = "genetic", discard = "both")
match.data(m.out)
dim(match.data(m.out))
plot(m.out)

# applying it to dat_match
cur_dmm   = match.data(m.out)
dat_match = subset(dat_match,row.names(dat_match) %in% row.names(cur_dmm))

# printing the matching table
dfs[[1]]  = dat_match
dfs       = agk.interpolating.dat_match(dfs,cur_groups,cur_names,cur_gr_levs)

disp('Checking matching and printing tables.')
match_result_tables = agk.perform.matching.tests(dfs,cur_groups,cur_matching,path_mtc,
                                                 write_match_tables = 1,cur_names)


# propensity score matching
cur_formula = as.formula(paste0('HCPG ~ ', paste(cur_names_dom,collapse = ' + ')))
# cur_psdf    = dfs[[1]]
# for (nn in 1:length(cur_names_dom)) {
#   cur_psdf[[cur_names_dom[nn]]] = as.numeric(cur_psdf[[cur_names_dom[nn]]])
# }
ps_mod      = glm(cur_formula,dfs[[1]],family='binomial')
#ps_mod      = glmRob(cur_formula,dfs[[1]],family='binomial')
predict(ps_mod)
cur_dm      = dfs[[1]]
cur_dm$ps   = predict(ps_mod)
plot(cur_dm$ps ~ cur_dm$HCPG)
cur_mod = lmPerm::lmp(cur_dm$ps~cur_dm$HCPG,family = 'binomial')
summary(cur_mod)
