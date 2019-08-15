%-----------------------------------------------------------------------
% Job saved on 09-Oct-2017 10:26:38 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
base_dir = 'E:\Charite\LeAD_Daten\' %take this as input in loop
cd(base_dir)
all_subjects = cellstr(ls());
for i = 3:length(all_subjects)
    % cd(all_subjects{i})
    current_subject = all_subjects{i};
    disp ('********now running')
    disp (current_subject)
    
    % get relevant directories
    subject_dir = (strcat(base_dir, current_subject, '\'))
    nifti_dir = strcat(subject_dir, 'MRT\NIFTI\')
    results_dir = (strcat(subject_dir, 'MRT\NIFTI\results\REST_withPhysIO'))
    spm_mat_file = strcat(results_dir, '\SPM.mat')
    %cd(results_dir)
    %cellstr(ls('SPM.mat'))
 
    
    matlabbatch{1}.spm.stats.con.spmmat = {spm_mat_file};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'HRV_pos';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 0 0 0 1];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'HRV_neg';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 0 -1];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 0;

    cd(results_dir) 
    save(strcat('glm_morecontrasts', current_subject, '.mat'),'matlabbatch');
    try
        spm_jobman('run',matlabbatch);
        %disp(strcat('last .fig of subject', current_subject))
        %disp(gcf)
    catch ME
        msgText = getReport(ME)
        %exception = MException.last
        %msg_text = getReport(exception)
        %disp(msg_text)
        continue
    end
end
