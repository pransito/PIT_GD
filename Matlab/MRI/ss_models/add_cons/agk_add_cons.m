% this function adds cons to an existing ss model

function error_message = agk_add_cons(base_dir_pl,cur_sub,ss_name, cur_templ,tcon,del) 

% message
disp(['Adding cons for ' cur_sub])

% where is the SPM mat
cd(base_dir_pl)
cd(cur_sub)
pos_dirs = jpa_getDirs(pwd,ss_name);

% run batch
try
    cd(pos_dirs{1});
    error_message = [cur_sub ' problem with finding the results directory'];
catch MExc
    error_message = {MExc,[cur_sub ' adding cons not successfull.']};
    return
end


cur_spm  = cellstr([pos_dirs{1} '\SPM.mat']);

% fill batch
load(cur_templ)
matlabbatch{1}.spm.stats.con.delete = del;

matlabbatch{1}.spm.stats.con.spmmat = cur_spm;
for jj = 1:length(tcon.codes)
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.name = tcon.names{jj};
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.consess{jj}.tcon.weights = tcon.codes{jj}; 
end

% save batch
tmp = clock;
cur_name = ['addcons_' num2str(tmp(1)) '_' num2str(tmp(2)) '_' num2str(tmp(3)) '_' num2str(tmp(4)) '_' num2str(tmp(5)) '.mat'];
save(cur_name,'matlabbatch')

% run batch
try
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
    error_message = [cur_sub ' adding cons successfull.'];
catch MExc
    error_message = {MExc,[cur_sub ' adding cons not successfull.']};
    return
end