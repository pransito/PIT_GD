% agk_make_PDT_physio_design_00
% for one subject
% makes the physio design of the PDT mri data based on Kasper (2016) paper
% creates the physio regressors

% INPUT
% cur_sub       : name of current subject
% which_folders : name of folder with niftis of task (pciks first) ???
% cur_tmpl      : the physio job with basic setting to be used here
%                 needs, to be m-file that can be run, to create a
%                 matlabbatch
% ow            : overwrite exisiting results files? (0,1)

% OUTPUT
% error_message: success message or explanation what hasn't worked

% IMPLICIT OUTPUT
% writes the physio regressor output file with realignment params
% into the results_ssdir in the subject folder
% use this file in the ss model of choice instead of normal rp-file

% THIS MODEL ('PDT_ss_design_01')
% depends on physio_job used as template
% (we would use RETROICOR and HRV based on pulsoxy data)

% DETAILS
% preproc_job is needed to get the slice timing parameters
% (to create time bins), will be looked for in the nifti folder provided
% will look for "preprocessing..." pattern
% need the first and last dcm image
% will look for it

% AUTHORSHIP
% author: Alexander Genauck
% date  : 27.01.2017
% email : alexander.genauck@charite.de

function error_message = agk_make_PDT_physio_design_00(cur_sub,cur_tmpl, ...
    run_it,ow)
try
    %% PREPARATIONS
    root_dir = pwd;
    
    % name of this analysis determines the results directory
    results_ssdir = 'PDT_physio_design_00';
    
    % messaging
    disp(['Estimating subject ' cur_sub ' using ' results_ssdir])
    
    % getting the matlabbatch
    clear matlabbatch;
    run(cur_tmpl);
    
    %% FILLING BATCH
    % preparing the design information variables
    
    
    % get the EPIs of this subject
    cd(root_dir)
    cd(cur_sub)
    
    % how many sessions?
    cd Behav\PDT
    load(ls('P*'))
    if isfield(P.t,'triggerscannertpostpause')
        tworuns = 1;
        nameSessions = {
            'PDT_1'
            'PDT_2'
            };
    else
        tworuns = 0;
        nameSessions = {
            'PDT_1'
            };
    end
    nSessions = numel(nameSessions);
    
    % get back
    cd ..\..
    
    % find NIFTI folders
    try
        cd('MRT\NIFTI');
    catch
        disp([results_ssdir ' ' cur_sub ' no NIFTI dir. Skipping.'])
        error_message =  [results_ssdir ' ' cur_sub '  no NIFTI dir. Skipped.']; % ??? !!!
        return
    end
    found_epi = 0;
    cur_epi_dirs  = cellstr(ls('*_epi*'));
    cur_MoCo_dirs = cellstr(ls('*_MoCo*'));
    
    % get nscans and rp files
    if ~tworuns
        if length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{1})        % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_MoCo_dirs{1}) > 0 % check if we're working with MoCo
            cd(cur_MoCo_dirs{1})            % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            load(ls('Preprocessing*')); % for microtime resolution
            preproc_job = matlabbatch;
            cur_nslices   = preproc_job{1}.spm.temporal.st.nslices;
            cur_refslice  = preproc_job{1}.spm.temporal.st.refslice;
            
            n_scans_1 = length(cellstr(spm_select('FPList',pwd,'swuaepi')));
            rp_file_1 = spm_select('FPList',pwd,'^rp');
        else
            disp([results_ssdir ' ' cur_sub ' no preprocessed epis or mocos for session 1/1 found. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  no preprocessed epis or mocos for session 1/1 found. Skipped.'];
            return
        end
        
        nScans = n_scans_1;
        rp_files = {rp_file_1};
        
    else % for two PDT runs
        
        % FIRST RUN
        found_epi = 0;
        if length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{1})     % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_MoCo_dirs{1}) > 0 % check if we're working with MoCo
            cd(cur_MoCo_dirs{1})    % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            load(ls('Preprocessing*')); % for microtime resolution
            preproc_job = matlabbatch;
            cur_nslices   = preproc_job{1}.spm.temporal.st.nslices;
            cur_refslice  = preproc_job{1}.spm.temporal.st.refslice;
            
            n_scans_1 = length(cellstr(spm_select('FPList',pwd,'swuaepi')));
            rp_file_1 = spm_select('FPList',pwd,'^rp');
        else
            disp([results_ssdir ' ' cur_sub ' no preprocessed epis or mocos for session 1 found. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  no preprocessed epis or mocos for session 1 found. Skipped.'];
            return
        end
        
        % SECOND RUN
        cd ..
        found_epi = 0;
        if length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{2})     % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_MoCo_dirs{1}) > 0 % check if we're working with MoCo
            cd(cur_MoCo_dirs{2})    % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            n_scans_2 = length(cellstr(spm_select('FPList',pwd,'swuaepi')));
            rp_file_2 = spm_select('FPList',pwd,'^rp');
        else
            disp([results_ssdir ' ' cur_sub ' no preprocessed epis or mocos for session 2 found. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  no preprocessed epis or mocos for session 2 found. Skipped.'];
            return
        end
        nScans = [n_scans_1, n_scans_2];
        rp_files = {rp_file_1,rp_file_2};
        
    end
    
    % get Physio files
    cd .. % go back to NIFTI folder
    cd ../..
    
    try
        cd ('Physio')
        cur_files = cellstr(ls('*.puls'));
        
        if tworuns
            % those should be the files
            file_1 = [cur_sub '_' 'PDT_1.puls'];
            file_2 = [cur_sub '_' 'PDT_2.puls'];
            file_1_there = sum(cell2mat(strfind(cur_files,file_1)));
            file_2_there = sum(cell2mat(strfind(cur_files,file_2)));
            if ~file_1_there && file_2_there % only physio_file_2
                disp([results_ssdir ' ' cur_sub ' no physio data for session 1 but for session 2 seems to be there.'])
                nScans = nScans(2);
                rp_files = rp_files(2);
                nameSessions = nameSessions(2);
                nSessions = 1;
                physio_files{1} = fullfile(root_dir,cur_sub,'Physio',file_2);
                
            elseif ~file_2_there && file_1_there % only physio_file_1
                disp([results_ssdir ' ' cur_sub ' no physio data for session 1 but for session 2 seems to be there.'])
                nScans = nScans(1);
                rp_files = rp_files(1);
                nameSessions = nameSessions(1);
                nSessions = 1;
                physio_files{1} = fullfile(root_dir,cur_sub,'Physio',file_1);
                
            elseif file_2_there && file_1_there % both physio_files
                physio_files{1} = fullfile(root_dir,cur_sub,'Physio',file_1);
                physio_files{2} = fullfile(root_dir,cur_sub,'Physio',file_2);
                
            elseif ~file_2_there && ~file_1_there
                disp([results_ssdir ' ' cur_sub ' no physio files seem to be in folder. Skipping.'])
                error_message =  [results_ssdir ' ' cur_sub '  no physio files seem to be in folder. Skipped.'];
                return
            end
            
        else
            % this should be the file
            file_1 = [cur_sub '_' 'PDT.puls'];
            file_1_there = sum(cell2mat(strfind(cur_files,file_1)));
            if ~file_1_there
                disp([results_ssdir ' ' cur_sub ' no physio files seem to be in folder. Skipping.'])
                error_message =  [results_ssdir ' ' cur_sub '  no physio files seem to be in folder. Skipped.'];
                return
            else
                physio_files{1} = fullfile(root_dir,cur_sub,'Physio',file_1);
            end
            
        end
    catch
        disp([results_ssdir ' ' cur_sub ' no physio data seems to be there. Skipping.'])
        error_message =  [results_ssdir ' ' cur_sub '  no physio data seems to be there. Skipped.'];
        return
    end
    
    % create the results dir
    cd ..
    cd MRT\NIFTI
    mkdir(pwd,'results')
    cd('results')
    
    if exist([pwd filesep results_ssdir])
        if ow == 1
            cmd_rmdir([pwd filesep results_ssdir])
        elseif ow == 0
            disp('Results dir already present. Overwrite not allowed, I will skip this subject.')
            error_message =  [results_ssdir ' ' cur_sub ' results dir already present. Skipped.'];
            return
        end
    end
    
    agk_mkdir_ex(pwd,results_ssdir)
    cd(results_ssdir)
    
    physio_res_folder = cellstr(pwd);
    
    if tworuns
        agk_mkdir_ex(pwd,'run_1')
        agk_mkdir_ex(pwd,'run_2')
        physio_res_folder = {};
        physio_res_folder{1} = fullfile(pwd,'run_1');
        physio_res_folder{2} = fullfile(pwd,'run_2');
    else
        agk_mkdir_ex(pwd,'run_1')
        physio_res_folder = {};
        physio_res_folder{1} = fullfile(pwd,'run_1');
    end
    
    % get the first dicoms
    cd(root_dir)
    cd(cur_sub)
    cd('MRT')
    
    try
        tmp = cellstr(ls('1*'));
        cd(tmp{1})
    catch
        disp([results_ssdir ' ' cur_sub ' trouble getting into dicoms folder. Skipping.'])
        error_message =  [results_ssdir ' ' cur_sub '  trouble getting into dicoms folder. Skipped.']; % ??? !!!
        return 
    end
    
    found_epi = 0;
    cur_epi_dirs  = cellstr(ls('*_epi*'));
    cur_MoCo_dirs = cellstr(ls('*_MoCoSeries*'));
    
    % get nscans and rp files
    if ~tworuns
        if length(cur_MoCo_dirs{1}) > 0 % check if we're working with MoCo
            cd(cur_MoCo_dirs{1})            % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{1})        % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            tmp = cellstr(ls('*.dcm'));
            scan_timing_dicoms{1} = tmp{1};
        else
            disp([results_ssdir ' ' cur_sub ' trouble finding 1st dicoms. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  trouble finding 1st dicom. Skipped.'];
            return
        end
                
    else % for two PDT runs
        
        % FIRST RUN
        found_epi = 0;
        if length(cur_MoCo_dirs{1}) > 0    % check if we're working with MoCo
            cd(cur_MoCo_dirs{1})           % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{1})            % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            tmp = cellstr(ls('*.dcm'));
            scan_timing_dicoms{1} = tmp{1};
        else
            disp([results_ssdir ' ' cur_sub ' trouble finding 1st dicom in first session. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  trouble finding 1st dicom in first session. Skipped.'];
            return
        end
        
        % SECOND RUN
        cd ..
        found_epi = 0;
        if length(cur_MoCo_dirs{1}) > 0    % check if we're working with MoCo
            cd(cur_MoCo_dirs{2})           % PDT task is first EPI run
            found_epi = 1;
        elseif length(cur_epi_dirs{1}) > 0 % check if we're working with epis
            cd(cur_epi_dirs{2})            % PDT task is first EPI run
            found_epi = 1;
        end
        
        if found_epi == 1
            tmp = cellstr(ls('*.dcm'));
            scan_timing_dicoms{2} = tmp{1};
        else
            disp([results_ssdir ' ' cur_sub ' trouble finding 1st dicom in first session. Skipping.'])
            error_message =  [results_ssdir ' ' cur_sub '  trouble finding 1st dicom in first session. Skipped.'];
            return
        end
        
    end
    
    %% FILL BATCH
    
    for iSession = 1:nSessions
        
        matlabbatch{iSession} = matlabbatch{1};
        matlabbatch{iSession}.spm.tools.physio.save_dir = cellstr(physio_res_folder{iSession});
        matlabbatch{iSession}.spm.tools.physio.log_files.cardiac = physio_files{iSession};
        matlabbatch{iSession}.spm.tools.physio.log_files.scan_timing = cellstr(scan_timing_dicoms{iSession});
        matlabbatch{iSession}.spm.tools.physio.scan_timing.sqpar.Nscans = nScans(iSession);
        matlabbatch{iSession}.spm.tools.physio.model.movement.yes.file_realignment_parameters = cellstr(rp_files{iSession});
        
        % saving design
        cd(physio_res_folder{nSessions})
        save('design.mat','matlabbatch');
        
        % running
        try
            if run_it == 1
                spm_jobman('run',matlabbatch{iSession});
            end
            error_message = [results_ssdir ' ' cur_sub 'run ' num2str(iSession) ' :' ' Estimation successfull.'];
        catch MExc
            error_message = {MExc,[results_ssdir ' ' cur_sub 'run ' num2str(iSession) ' :' ' Estimation not successfull.']};
            if iSession == nSessions
                return
            else
                continue
            end
        end
    end
    cd(root_dir);
catch MExc
    disp('Something went wrong');
    error_message = MExc;
end
end