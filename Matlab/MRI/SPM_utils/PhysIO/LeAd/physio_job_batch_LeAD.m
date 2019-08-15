%-----------------------------------------------------------------------
% Job saved on 07-Sep-2017 12:18:55 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% TO DO for more general usability:
% test try/catch for dcm file input. does it work?


%% additional comments:
% creates a matlabbatch job to be run in SPM which will generate a
% design matrix with physio regressors

% input args:
% data_path: where is your data? for example 'E:\Charite\VPPG_Daten\'
% prefix: what prefix do all your subjects have? for example 'VPPG*'
% session_name: which session do you want to correct? for example 'REST' 
%%
function [] = physio_job_batch_LeAD(data_path, prefix, session_name)
% initialize spm and get subject numbers from directory
    %spm fmri %comment out for testing
    base_dir = data_path;
    cd(base_dir)
    all_subjects = cellstr(ls(prefix));
    switch_dcm = 0;
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {base_dir};
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'PhysIO_results';
    % loop over subjects
    % for i = 162:length(all_subjects) %skip the first 159 subjects (and the . and ..)
    for i = 3:length(all_subjects) % loop over all subjects
        cd(base_dir)
        cd(all_subjects{i})
        current_subject = all_subjects{i};
        disp (strcat('now running subject ', current_subject))
        subject_dir = strcat(base_dir, current_subject);
    %% check first if there even is a physio folder, if not go to next subject
        cd(subject_dir)
        physio_folder = ls('Physio*');
        if exist(physio_folder, 'dir')          
         %% where u wanna get all results and output files saved?
         % makes a PhysIO_results directory in the current subject directory
            % matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {subject_dir};
            % matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'PhysIO_results';
            matlabbatch{2}.spm.tools.physio.save_dir(1) = cfg_dep('Make Directory: Make Directory ''PhysIO_results''', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dir'));

        % what scanner did you use?
            matlabbatch{2}.spm.tools.physio.log_files.vendor = 'Siemens';

        % where is the physio file?
            try
                matlabbatch{2}.spm.tools.physio.log_files.cardiac = {strcat(subject_dir, '\Physio\', current_subject, '_', session_name, '.ecg')};
            catch
                disp (strcat('There is no .ecg file for subject', current_subject, '\nContinuing with next subject'))
                continue
            end
        % we did not do respiration so leave blank with {''}
            matlabbatch{2}.spm.tools.physio.log_files.respiration = {''};

    % get series number of right session from nifti-folder
        cd(strcat(subject_dir, '\MRT\NIFTI\')) %go to nifti directory
        
        % list MoCo or epi folders
        which_folders = {'*MoCo*', '*epi*', '*rest*.nii'};
        for jj = 1:length(which_folders)
            tmp = ls(which_folders{jj});
            if exist(tmp, 'file')       % if tmp is a file in the folder
                series = tmp;           % store it as 'series'
            end
        end
            
        cd(strcat(subject_dir, '\MRT'))
        %dcm_folder = ls('DCM'); %go to the dcm directory
        dcm_dir = strcat(subject_dir,'\MRT\DCM');

        % indidicate the path to first (or last) .dcm
        % watch out; should order "increasing" (happens automtically in ls() cmd)
            cd (dcm_dir) %go to the dcm directory

            all_dcms = cellstr(ls('*'));
            if length(all_dcms) == 2 %what if dcm folder is empty
                disp(strcat('No dicoms available for ', current_subject))
                continue
            else
                first_dcm = all_dcms{3};
                last_dcm = all_dcms{length(all_dcms)};
            end
            
       % which dicom to use for time matching?
            matlabbatch{2}.spm.tools.physio.log_files.scan_timing = {strcat(dcm_dir, '\', first_dcm)};
            % switch_dcm = 1;
            % matlabbatch{2}.spm.tools.physio.log_files.scan_timing = {strcat(dcm_dir, '\', last_dcm)};
            
            % ignore for now
            matlabbatch{2}.spm.tools.physio.log_files.sampling_interval = [];
            % ignore for now
            matlabbatch{2}.spm.tools.physio.log_files.relative_start_acquisition = 0;

        % 'first' if first dicom provided, 'last' if ...
            if switch_dcm == 1
                matlabbatch{2}.spm.tools.physio.log_files.align_scan = 'last';
            else
                matlabbatch{2}.spm.tools.physio.log_files.align_scan = 'first';
            end
        % How many slices? you will have to provide this info (check phoenix or...)
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.Nslices = 42;

        % ignore
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];

        % TR time (find in phoenix or...)
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.TR = 2.41;

        % do you have dummy scans? I think not
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;

        % how many scans? you will have to check this yourself
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.Nscans = 148;

        % interleaved descending... how did you measure what is first slice?
        % should be your reference slice from preprocessing 
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.onset_slice = 21;

        % detail: ignore
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];

        % ignore
            matlabbatch{2}.spm.tools.physio.scan_timing.sqpar.Nprep = [];

        % ignore
            matlabbatch{2}.spm.tools.physio.scan_timing.sync.nominal = struct([]);

        % options from GUI are 'OXY/PPU', 'ECG', 'PPU_WiFi', 'ECG_WiFi'
        % 'PPU' seems to work fine too
            matlabbatch{2}.spm.tools.physio.preproc.cardiac.modality = 'ECG';

        % ignore it
            matlabbatch{2}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;

        % no idea; an outputfile?
            matlabbatch{2}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';

        % turn post-hoc selection of cardiac pulses on or off (off is default)
        % can be done manually or loaded from struct file
            matlabbatch{2}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);

        % output file name
            matlabbatch{2}.spm.tools.physio.model.output_multiple_regressors = strcat(current_subject, 'multiple_regressors.txt');

        % output file name
            matlabbatch{2}.spm.tools.physio.model.output_physio = strcat(current_subject,'physio.mat');

        % orthogonalization of regressors only recommended for triggered/gated
        % acquisition sequences. 'none' is default
            matlabbatch{2}.spm.tools.physio.model.orthogonalise = 'none';

        % retroicore regressors and order of Fourier expansion for each phase
        % (cardiac and respiratory) and interaction
            matlabbatch{2}.spm.tools.physio.model.retroicor.yes.order.c = 3;
            matlabbatch{2}.spm.tools.physio.model.retroicor.yes.order.r = 4;
            matlabbatch{2}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
            matlabbatch{2}.spm.tools.physio.model.rvt.no = struct([]);
            matlabbatch{2}.spm.tools.physio.model.hrv.yes.delays = 0;
            matlabbatch{2}.spm.tools.physio.model.noise_rois.no = struct([]);

        % if pp done already you can provide the movement params here 
            cd (strcat(subject_dir, '\MRT\NIFTI\'))
            rp_file = ls('rp*.txt');
            if exist(rp_file, 'file')
                rp_file_path = strcat(subject_dir, '\MRT\NIFTI\', rp_file);
                matlabbatch{2}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {rp_file_path};
        % or leave empty if not yet    
            else
                disp(strcat('no movemement parameters available for subject ', current_subject))
                matlabbatch{2}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {};
            end

        % how many movement regressors (default 6, but higher order possible)
        % VOLTERRA movement regressors
            matlabbatch{2}.spm.tools.physio.model.movement.yes.order = 6;

        % maybe automatic censoring also; if too much movement will be excluded
        % (the volume)
            matlabbatch{2}.spm.tools.physio.model.movement.yes.outlier_translation_mm = 1;
            matlabbatch{2}.spm.tools.physio.model.movement.yes.outlier_rotation_deg = 1;
            matlabbatch{2}.spm.tools.physio.model.other.no = struct([]);
            matlabbatch{2}.spm.tools.physio.verbose.level = 2;
            matlabbatch{2}.spm.tools.physio.verbose.fig_output_file = '';
            matlabbatch{2}.spm.tools.physio.verbose.use_tabs = false;

        %% save the batch to subject directory and run it
            cd(strcat(subject_dir, '\', 'Physio')) 
            save(strcat('PhysIO_job_', current_subject, '.mat'),'matlabbatch');

            spm_jobman('run',matlabbatch);
        else %what if there is no physio folder?
            disp (strcat('no physio file directory available for subject', current_subject))
            continue
        
        end %closes physio folder check from beginning
    
    end %closes main subject loop

end %closes function