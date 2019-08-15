%-----------------------------------------------------------------------
% Job saved on 04-Oct-2017 12:04:10 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% for now:
% specific for LeAd resting state scan (number of scans, TR, slice timing)

base_dir = 'E:\Charite\LeAD_Daten\' %take this as input in loop
cd(base_dir)
all_subjects = cellstr(ls());
for i = 8:length(all_subjects)
% for i = 3:length(all_subjects)
    % cd(all_subjects{i})
    current_subject = all_subjects{i};
    disp ('********now running')
    disp (current_subject)
    
    % get relevant directories
    subject_dir = (strcat(base_dir, current_subject, '\'))
    nifti_dir = strcat(subject_dir, 'MRT\NIFTI\')
    results_dir = (strcat(subject_dir, 'MRT\NIFTI\results\REST_withPhysIO'))
    
    % make the results directory if it doesn't exist already
    cd(nifti_dir)
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    matlabbatch{1}.spm.stats.fmri_spec.dir = {results_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.41;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 42;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 21;
    %%
    % read in niftis as cell array?
    cd(nifti_dir)
    subject_nifti = cellstr(ls('*.nii'))

    % create empty cell array
    all_scans = repmat({''},148,1)
    % fill
    for i = 1:148
        scan = strcat(nifti_dir, subject_nifti,',', num2str(i))
        all_scans(i) = scan
        i = i+1
    end

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = all_scans

    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {strcat(base_dir, '\PhysIO_results\', current_subject, 'multiple_regressors.txt')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'cardiac_cos';
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.name = 'cardiac_sin';
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'cardiac_cos2';
    matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = [0 0 1];
    matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.fcon.name = 'cardiac_sin2';
    matlabbatch{3}.spm.stats.con.consess{4}.fcon.weights = [0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.name = 'cardiac_cos3';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.weights = [0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.fcon.name = 'cardiac_sin3';
    matlabbatch{3}.spm.stats.con.consess{6}.fcon.weights = [0 0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{6}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{7}.fcon.name = 'cardiac_HRV';
    matlabbatch{3}.spm.stats.con.consess{7}.fcon.weights = [0 0 0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{7}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    %% save the batch to subject directory and run it
    cd(results_dir) 
    save(strcat('glm_job_', current_subject, '.mat'),'matlabbatch');
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