% this function adds cons to an existing ss model

function error_message = agk_make_cons_ss(base_dir_pl,cur_sub,ss_name, cur_templ,del) 

% message
disp(['Making cons for ' cur_sub])

% where is the SPM mat
cd(base_dir_pl)
cd(cur_sub)
pos_dirs = jpa_getDirs(pwd,ss_name);

% run batch
try
    cd(pos_dirs{1});
    error_message = [cur_sub ' problem with finding the results directory'];
catch MExc
    error_message = {MExc,[cur_sub ' making cons not successfull.']};
    return
end


cur_spm  = cellstr([pos_dirs{1} '\SPM.mat']);
load(cur_spm{1})
if length(SPM.Sess) == 2
    tworuns = 1;
else
    tworuns = 0;
end

% fill batch
load(cur_templ)
matlabbatch{1}.spm.stats.con.delete = del;

matlabbatch{1}.spm.stats.con.spmmat = cur_spm;

% contrast manager
con.contrastNames = {'pic.on','pic.on.gam','pic.on.neg','pic.on.pos', ...
    'picgam.on','picgam.on.valueLAcl','picgam.on.gam','picgam.on.neg','picgam.on.pos', ...
    'picgamopt.on','picgamopt.on.valueLAcl','picgamopt.on.gam','picgamopt.on.neg','picgamopt.on.pos', ...
    'fb.on','fb.on.valueLAcl','fb.on.gam','fb.on.neg','fb.on.pos'};
con.contrastType = cellstr(repmat('t',length(con.contrastNames),1));
con.contrastWeights = agk_basic_t_cons(length(con.contrastType));
if tworuns
    con.contrastWeights = agk_basic_t_cons_2sess(length(con.contrastType),length(con.contrastType));
end
con.contrastRep = cellstr(repmat('none',length(con.contrastNames),1));

for jj = 1:length(con.contrastType)
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.name    = con.contrastNames{jj};
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.convec  = con.contrastWeights{jj};
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.sessrep = con.contrastRep{jj};
end

% save batch
tmp = clock;
cur_name = ['addcons_' num2str(tmp(1)) '_' num2str(tmp(2)) '_' num2str(tmp(3)) '_' num2str(tmp(4)) '_' num2str(tmp(5)) '.mat'];
save(cur_name,'matlabbatch')

% run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
    error_message = [cur_sub ' making cons successfull.'];
catch MExc
    error_message = {MExc,[cur_sub ' making cons not successfull.']};
    return
end