% PIPELINE FOR RUNNING PREPROCESSING AND 1st LEVEL

% Author: Alexander Genauck
% Work address:
% email: alexander.genauck@charite.de
% Website:
% Feb 2016; Last revision: 03-05-2018

%------------- BEGIN CODE --------------
clear all
clear classes
%% ############### Generell Settings ###############
% User-name
comp_name = getenv('USERNAME');
% add my lib
% start_up
%base_dir_lib = 'E:\Google Drive\Library\MATLAB';
base_dir_lib = ['C:\Users\' comp_name '\Google Drive\02_Library\MATLAB'];
addpath(genpath(base_dir_lib))
% where are the subject folders with MRI data?
base_dir_pl = 'L:\data';
% a path that can disturb
rmpath('C:\Program Files\MATLAB\R2014a\toolbox\PSPM');
% get spm 12
which_spm(12,comp_name,1)
% what atlas to use for extraction
cur_atlas   = fullfile(fileparts(which('spm')),'tpm','labels_Neuromorphometrics.xml');

% which_spm(12,comp_name,1)
% preproc job templates
preproc_tmpl{1}  = fullfile(base_dir_lib, 'PDT','MRI', 'pp_subf', 'PDT_preprocessing_1sess_tmpl_2018.mat');
preproc_tmpl{2}  = fullfile(base_dir_lib, 'PDT','MRI', 'pp_subf', 'PDT_preprocessing_2sess_tmpl_2018.mat');

% what to run?
msji        = 0; % make sjinfo
d2n         = 0; % dicom 2 nifti
pp          = 0; % preprocessing
ph          = 0; % make physio regressors
ss          = 0; % ss-level
ssm         = 0; % check microtime onset and whether ss models are there
dategppi    = 0; % check the date of the gppi files
hrf_boost   = 0; % after ss with hrf informed set, boost hrf using inf set
ss_chkcons  = 0; % ss-level addcons
ss_newcons  = 0; % ss-level make cons
ss_rm       = 0; % ss-level review design matrices
ss_extr     = 0; % ss-level extract eigvar from ROI % LEGACY!!!
sl_extr     = 1; % sl-level extract eigvar from ROI
sl_extr_ppi = 1; % sl-level gPPI extract eigvar from ROI
del_ppi     = 0; % delete all ppi from ss folder
del_ss      = 0; % delete all ss folders of some kind

% overall params
tr          = 2; % repetition time

% numbers of workers for parallel computing
M = 10;

warning('MASK Threshold at 0.2?')

%% ############### MAKE SJ INFO ####################
if msji
    %source  = ['E:\Google Drive\Promotion\VPPG\VPPG_Exchange\' ...
    %    'Experimente\PDT\Daten\pilot\info_mri_selection.csv'];
    cur_home   = ['C:\Users\agemons\Google Drive\VPPG_Exchange' ...
        '\Experimente\PDT\Daten\pilot'];
    cd(cur_home)
    T                      = readtable('info_mri_selection_30_30.csv', ...
        'Delimiter','\t');
    Sjinfo.KAP.STID        = T.subject;
    Sjinfo.KAP.GROUP       = T.group;
    %Sjinfo.KAP.SMOKE       = T.smoking_ftdt;
    Sjinfo.KAP.EDUYRS      = T.edu_years;
    
    % save it
    save('Sjinfo_30_30.mat','Sjinfo')
end


%% ############### DICOM2NIFTI #####################
% for loop for getting into folders
if d2n
    cd(base_dir_pl);
    all_subf = cellstr(ls('VPPG*'));  %list folders starting w vppg
    which_folders = {'*epi*','*MoCoSeries', '*Fieldmap*','*MPRAGE*'}; % patterns to know which folders
    for ii = 1:length(all_subf)
        %         cd([base_dir_pl,all_subf{ii}]);
        %         cd('MRT');
        %         %delete all existing nifti files first
        %         system('rmdir /s /q "NIFTI"')
        
        %go back home
        % cd([base_dir_pl,all_subf{ii}])
        try
            ii
            cv_feedback{ii} = agk_PDT_wrapper_dcm2nifti(all_subf{ii},which_folders);
        catch ME
            disp(ME.identifier);
            disp(['There was an error in d2n. ' all_subf{ii}])
            rethrow(ME);
        end
    end
end

%% ############### PREPROCESS #####################
if pp
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    which_folders    = {'*epi*','*MoCoSeries'}; % patterns to know which folders to pp
    pm_defaults_file = fullfile(base_dir_lib,'PDT','MRI','pp_subf','pm_defaults_AGK.m');
    ow_pp            = 1; % overwrite existing preprocessing?
    run_pp           = 1; % run the PP or just save batch?
    cdim_resl        = 0; % somehow reslicing the images to get into right dimensions (fieldmaps?)
    
    % add warning message if ow_pp = 1 -> press key to continue
    
    for ii = 11
        pp_feedback{ii} = PDT_preprocess(all_subf{ii},which_folders,pm_defaults_file,preproc_tmpl,ow_pp,run_pp,cdim_resl);
        cd(base_dir_pl);
    end
end


%% ############### PHYSIO #########################
if ph
    % only creates physio regressors and saves all the peak detection
    % output; does not run any analysis
    % this must be done in an ss model
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    cur_tmpl         = 'C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\ss_models\physio\physio_job.m';
    ow_ph            = 1; % overwrite existing physio regressors?
    run_it           = 1; % run it or just save matlabbatch?
    
    % TODO: update with KD's scripts and check if working correctly
    for ii = [11,34]
        cd(base_dir_pl);
        try
            ph_feedback{ii} = agk_make_PDT_physio_design_00(cur_sub,cur_tmpl,run_it,ow_ph);
        catch MExc
            rethrow(MExc)
            disp(['There was an error in ph. ' all_subf{ii}])
        end
    end
end


%% ############### ss-LEVEL #######################
if ss
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    %expl_mask        = fullfile(base_dir_lib,'\LA\2L_Analysis\ROI\gm_mask.nii');
    expl_mask        = fullfile(base_dir_lib, 'SPM' ,'ROI','TPM_PDT.nii');
    cur_tmpl{1}      = fullfile(base_dir_lib,'\PDT\MRI\ss_models\LA_Ss_template_without_acc_reject.mat'); % ss batch templates (1: without acc_reject 2: with accept_reject)
    cur_tmpl{2}      = fullfile(base_dir_lib,'\PDT\MRI\ss_models\LA_Ss_template.mat');
    cur_tmpl{3}      = fullfile(base_dir_lib,'\PDT\MRI\ss_models\LA_Ss_template_without_acc_reject_2runs.mat');
    % behav model LA Charpentier results
    LA_charpentier   = ['C:\Users\' comp_name '\Google Drive\Promotion\VPPG\VPPG_Exchange\Library\MLE+Model\LA_Charpentier\MLE_results_Charpentier.txt'];
    % behav model LA classical results
    LA_classic       = ['C:\Users\' comp_name '\Google Drive\Promotion\VPPG\VPPG_Exchange\Library\MLE+Model\LA_cl\MLE_results_AG.txt'];
    run_it           = 1;
    aggr             = 3;
    ow               = 1; % overwrite existing ss results?
    physio_inc       = 0;
    sm               = 0; % smoothed epis?
    val              = 0; % value modeling: 0: none(gain, loss, ed, cat); 1: value (val, cat); 2: vac (val, craving for pictures)
    gam_mod          = 0; % set to 0 is gamble features play no role (cat + acceptance*cat model)
    
    % THE PDT_SS_DESIGN
    for sm = [1 0]
        for val = 0 % val = [0 1 2]
            cd(base_dir_pl);
            %parfor_progress(length(all_subf))
            %parfor (ii = 1:length(all_subf),M)
            for ii = 61
                cd(base_dir_pl);
                agk_make_PDT_ss_design_DEZ_sm_orth_val(all_subf{ii}, ...
                    cur_tmpl,aggr,run_it,expl_mask,ow,physio_inc,tr,sm,val,base_dir_lib,gam_mod);
                cd(base_dir_pl);
                %parfor_progress
            end
            %parfor_progress(0);
        end
    end
end

%% ############### ss-LEVEL microtime_onset #######
if ssm
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    probl_sub        = {};
    no_ss            = {};
    all_ss_b = 'PDT_ss_design_DEZ_';
    all_ss   = {'sm_orth_ngm';'us_orth_ngm'};
    all_ss   = strcat(all_ss_b,all_ss);
    for ss = 1:length(all_subf)
        ss
        cd(base_dir_pl)
        cd(all_subf{ss})
        if ~exist(fullfile('MRT','NIFTI','PDT','results'))
            no_ss = [no_ss all_subf{ss}];
            continue
        else
            cd(fullfile('MRT','NIFTI','PDT','results'))
        end
        cur_home = pwd;        
        ct = 0;
        for mm = 1:length(all_ss)
            cd(cur_home)
            cd(all_ss{mm})
            load('design.mat')
            if matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  ~= 33
                ct = ct + 1;
                probl_sub{ct,mm} = all_subf{ss};
            end
            if matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0  ~= 33
                ct = ct + 1;
                probl_sub{ct,mm} = all_subf{ss};
            end
        end
    end
end

%% ############### date gppi ######################
% use the hrf_boost if ss level was done with informed hrf basis set
if dategppi
    % prep
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    
    % ss models
    ss_models = {'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_val';...
        'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_vac'; ...
        'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_glc'; ...
        'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_val'; ...
        'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_vac'; ...
        'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc'};
    
    % check date
    report_fails = {};
    for ii = 1:length(all_subf)
        cd(base_dir_pl);
        cd(all_subf{ii})
        for ss = 1:length(ss_models)
            cd(base_dir_pl);
            cd(all_subf{ii});
            try
                cd(ss_models{ss})
            catch
                report_fails{ii,ss} = ['no ' ss_models{ss} ' model'];
                continue
            end
            
            % scan folder
            cur_dir   = dir();
            foldnames = {cur_dir.name}; 
            
            % get the PPI folders
            cur_ppi_folders = ~cellfun(@isempty,regexp(foldnames,'^PPI_'));
            cur_ppi_folders = cur_dir(logical(cur_ppi_folders));
            assert(numel(cur_ppi_folders) == 4)
            % check date
            date_check = {};
            for pp = 1:length(cur_ppi_folders)
                cur_date = cur_ppi_folders(pp).date;
                if isempty(strfind(cur_date,'03-Mai-2018')) && isempty(strfind(cur_date,'04-Mai-2018'))
                    date_check = [date_check cur_ppi_folders(pp).name];
                end
            end
            report_fails{ii,ss} = date_check;
        end
    end
end

%% ############### ss-LEVEL hrf boost #############
% use the hrf_boost if ss level was done with informed hrf basis set
if hrf_boost
    % prep
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    
    % boost
    for ii = 1:length(all_subf)
        cd(base_dir_pl);
        cd(all_subf{ii})
        try
            cd('MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_hrf2_sm_orth')
        catch
            boost_feedback{ii} = ['no ss hrf2 us orth folder for ' ...
                all_subf{ii}];
        end
        boost_feedback{ii} = spmup_hrf_boost(fullfile(pwd,'SPM.mat'));
    end
end

%% ############### Review design matrices #########
if ss_rm
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    
    ssdir = 'PDT_ss_design_LAcl_01';
    
    for ii = 1:length(all_subf)
        try
            %for ii = 4:length(all_subf)
            cd(base_dir_pl);
            cd(all_subf{ii})
            cd('MRT\NIFTI\results')
            agk_review_design_matrices(cd,ssdir)
        catch
            disp(['Failed to display ' ssdir ' of ' all_subf{ii}])
        end
    end
    
end

%% ############### ss-LEVEL check/add cons #########
if ss_chkcons
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    ss_name          = 'PDT_ss_design_NOV'; % name of ss design to add cons to
    cur_templ        = fullfile(base_dir_lib, '\PDT\pp_subf', 'con_man_template.mat');
    %tcon.names       = {'pic.on.gam_gr_pic.on.pos','pic.on.gam_kl_pic.on.pos','pic.on.gam_gr_pic.on.neg','pic.on.gam_kl_pic.on.neg'};
    %tcon.codes       = {[0 1 0 -1], [0 -1 0 1], [0 1 -1 0], [0 -1 1 0]};
    %del              = 0;
    des_num_cons = 13; % how many exp cons should be there?
    
    % ADDING CONS TO THE SPM.mat of SS ANALYSIS
    for ii = 40%1:length(all_subf)
        cd(base_dir_pl);
        ss_chkcon_feedback{ii} = agk_PDT_chkcons(all_subf{ii},ss_name, ...
            des_num_cons);
    end
end

%% ############### delete PPI from ss ##########
if del_ppi
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    ss_name          = 'MRT\NIFTI\PDT\results\PDT_ss_design_NOV'; % name of ss design to add cons to
    % delete old gPPIss?
    for kk = 32
        cd(base_dir_pl);
        kk
        cd(all_subf{kk})
        cd(ss_name)
        cur_PPI_folders = cellstr(ls('PPI*'));
        cur_logs = cellstr(ls([all_subf{kk} '*']));
        try
            for ff = 1:length(cur_PPI_folders)
                cmd_rmdir(cur_PPI_folders{ff});
            end
        catch
        end
        try
            for pp = 1:length(cur_logs)
                delete(cur_logs{pp});
            end
        catch
        end
    end
end

%% ############### delete PPI from ss ##########
if del_ss
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    ss_name          = 'PDT_ss_design_NOV*'; % name of ss design to add cons to
    % delete old gPPIss?
    for kk = 1:length(all_subf)
        kk
        cd(base_dir_pl);
        cd(all_subf{kk})
        cd('MRT\NIFTI\PDT\results')
        cur_ss_folders = cellstr(ls(ss_name));
        if ~isempty(cur_ss_folders{1})
            for ff = 1:length(cur_ss_folders)
                cmd_rmdir(cur_ss_folders{ff});
            end
        end
    end
end

%% ############### extract scnd level eigvar ########
if sl_extr
    
    % paths to second level
    res_base_dir = 'L:\data\results_2nd_level\twottest\groupstats__MRT_';
    res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_ngm','\');
    cd(fullfile(res_base_dir,res_mid_dir))
    all_sl_res = cellstr(ls('*grp01_noCov*'));
    
    for kk = 1:length(all_sl_res)
        all_sl_res{kk} = fullfile(pwd,all_sl_res{kk},'SPM.mat');
    end
    
    % path to ROIs
    path_ROIs = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\' ...
        'PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_ss_model'];
    cd(path_ROIs)
    
    ROI_masks   = cellstr(ls('*.nii'));
    ROIs_path_c = {};
    for kk = 1:length(ROI_masks)
        ROIs_path_c{kk,1} = fullfile(pwd,ROI_masks{kk});
    end
    
    % extraction
    ss_extr_feedback     = {};
    h                    = waitbar(0,'Please wait for ss extraction.');
    steps                = length(all_sl_res);
    subs_vectors         = {};
    ct                   = 0;
    for ii = 1:steps
        % current second level model to access desired first level betas
        path_scnd_level_SPM = all_sl_res{ii};
        for jj = 1:length(ROIs_path_c)
            % current ROI
            path_ROI             = ROIs_path_c{jj};
            con                  = 3; % T con: [1 1]
            % extract
            [Y,all_subs] =  ...
                agk_get_secondlevel_ROI_mean( ...
                path_scnd_level_SPM,path_ROI,con);
            
            % check if okay
            if isempty(Y)
                warning('empty extract')
                cur_size = size(ss_extr_feedback);
                if jj ~= cur_size(2)
                    Y = NaN(length(ss_extr_feedback{ii,(jj-1)}),1);
                elseif ii ~= cur_size(1)
                    Y = NaN(length(ss_extr_feedback{(ii-1),jj}),1);
                else
                    warning('Cannot determine length of NaN vector for empty extract. Will take 64.')
                    Y = NaN(64,1);
                end
            end

            % save
            ss_extr_feedback{ii,jj}     = Y;
            ct                          = ct + 1;
            subs_vectors{ct}            = all_subs;
        end
        waitbar(ii / steps)
    end
    close(h)
    
    % check if subject vectors are always aligned
    subs_check = [];
    for ii = 1:length(subs_vectors)
        for jj = 1:length(subs_vectors)
            cur_check = all(strcmp(subs_vectors{ii},subs_vectors{jj}));
            if cur_check == 0
                error('subjects do not align!')
            end
        end
    end
    
    % saving
    cd(path_ROIs)
    save('ss_extr_feedback.mat','ss_extr_feedback','subs_vectors')
    
    % make it ready for R
    names_vars_extr = {};
    values_extr     = repmat(NaN,length(ss_extr_feedback{1,1}),1);
    ct = 0;
    for ii = 1:length(all_sl_res)
        path_scnd_level_SPM = all_sl_res{ii};
        splits  = strsplit(fileparts(path_scnd_level_SPM),'\');
        name_ss = splits{end};
        name_ss = strrep(name_ss,'.','');
        for jj = 1:length(ROIs_path_c)
            cur_ROI  = ROIs_path_c{jj};
            [p f e]  = fileparts(cur_ROI);
            name_roi = f;
            name_roi = strrep(name_roi,' ','_');
            % shorten name
            name_roi = strsplit(name_roi,'_');
            % check name
            if any(~cellfun(@isempty,strfind(name_roi,'BA')))
                % is it L or R?
                if any(~cellfun(@isempty,strfind(name_roi,'L')))
                    name_roi    = name_roi([1,2]);
                    name_roi{3} = 'L';
                elseif any(~cellfun(@isempty,strfind(name_roi,'R')))
                    name_roi    = name_roi([1,2]);
                    name_roi{3} = 'R';
                else
                    error('Do not know this ROI type, No L or R!')
                end
            else
                name_roi = name_roi([1,2]);
            end
            name_roi = strjoin(name_roi,'_');
            % transfer into matrix
            ct = ct + 1;
            full_name = ['SS_' name_ss '_ROI_' name_roi];
            names_vars_extr{ct} = full_name;
            if isempty(ss_extr_feedback{ii,jj})
                error('Empty extract')
            end
            values_extr = [values_extr,ss_extr_feedback{ii,jj}];
        end
    end
    values_extr     = values_extr(:,2:end);
    names_vars_extr = strrep(names_vars_extr,'.','_');
    T               = array2table(values_extr, ...
        'VariableNames',names_vars_extr);
    T.subject       = subs_vectors{1,1};
    writetable(T,'ss_extr_ngm.csv','Delimiter','\t')
    
    % copy the file where R will use it
    source = 'ss_extr_ngm.csv';
    target = ['C:\Users\' comp_name '\Google Drive\VPPG_Exchange\Experimente\PDT\Daten\pilot'];
    target = fullfile(target,source);
    copyfile(source,target,'f')
end

%% extraction of gPPI second level eigvar ################################
if sl_extr_ppi
%     % path to save the interim ssgPPI_extr_feedback
%     path_tmp_extr = 'L:\data\results_2nd_level\twottest\groupstats__MRT_\_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_us_orth_glc_\tmp_gppi_extr';
%     
%     % delelete the interim extracts
%     cd(path_tmp_extr)
%     all_files = cellstr(ls());
%     all_files = all_files(3,:);
%     for kk = 1:length(all_files)
%         delete(all_files{kk})
%     end
    
    % paths to second level
    res_base_dir = 'L:\data\results_2nd_level\twottest\groupstats__MRT_';
    res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_ngm','\');
    cd(fullfile(res_base_dir,res_mid_dir))
    all_sl_res = cellstr(ls('*PPI*'));
    nall_sl_res = {};
    for aa = 1:length(all_sl_res)
        cd(all_sl_res{aa})
        nall_sl_res = [nall_sl_res;strcat(all_sl_res{aa},'\',cellstr(ls('*noCov_PPI_*')))];
        cd ..
    end
    all_sl_res = nall_sl_res;
    
    for kk = 1:length(all_sl_res)
        all_sl_res{kk} = fullfile(pwd,all_sl_res{kk},'SPM.mat');
    end
    
    % path to ROIs
    path_ROIs = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\' ...
        'MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets'];
    cd(path_ROIs)
    
    ROI_masks   = cellstr(ls('*.nii'));
    ROIs_path_c = {};
    for kk = 1:length(ROI_masks)
        ROIs_path_c{kk,1} = fullfile(pwd,ROI_masks{kk});
    end
    
    ssgPPI_extr_feedback = {};
    h                    = waitbar(0,'Please wait for gppi extraction.');
    steps                = length(all_sl_res);
    subs_vectors         = {};
    ct                   = 0;
    for ii = 1:steps
        % current second level model to access desired first level betas
        path_scnd_level_SPM  = all_sl_res{ii};
        for jj = 1:length(ROIs_path_c)
            % current ROI
            path_ROI             = ROIs_path_c{jj};
            con                  = 3; % T con: [1 1]
            % extract
            [Y,all_subs] =  ...
                agk_get_secondlevel_ROI_mean( ...
                path_scnd_level_SPM,path_ROI,con);
            % check if okay
            if isempty(Y)
                warning('empty extract')
                cur_size = size(ssgPPI_extr_feedback);
                if jj ~= cur_size(2)
                    Y = NaN(length(ssgPPI_extr_feedback{ii,(jj-1)}),1);
                elseif ii ~= cur_size(1)
                    Y = NaN(length(ssgPPI_extr_feedback{(ii-1),jj}),1);
                else
                    warning('Cannot determine length of NaN vector for empty extract. Will take 65.')
                    Y = NaN(65,1);
                end
            end
            % save
            ssgPPI_extr_feedback{ii,jj} = Y;
            ct                          = ct + 1;
            subs_vectors{ct}            = all_subs;
        end
        waitbar(ii / steps)
    end
    close(h)
    
    % check if subject vectors are always aligned
    subs_check = [];
    for ii = 1:length(subs_vectors)
        for jj = 1:length(subs_vectors)
            cur_check = all(strcmp(subs_vectors{ii},subs_vectors{jj}));
            if cur_check == 0
                error('subjects do not align!')
            end
        end
    end
    
    % save it
    cd(path_ROIs)
    save('ssgPPI_extr_feedback.mat','ssgPPI_extr_feedback','subs_vectors')
    
    % make it ready for R
    values_extr     = [];
    names_vars_extr = {};
    values_extr     = repmat(NaN,length(ssgPPI_extr_feedback{1,1}),1);
    ct = 0;
    for ii = 1:length(all_sl_res)
        path_scnd_level_SPM = all_sl_res{ii};
        splits  = strsplit(fileparts(path_scnd_level_SPM),'\');
        name_ss = splits([(length(splits)-1),length(splits)]);
        name_ss = strrep(name_ss,'.','');
        name_ss = strjoin(name_ss,'');
        for jj = 1:length(ROIs_path_c)
            cur_ROI  = ROIs_path_c{jj};
            [p f e]  = fileparts(cur_ROI);
            name_roi = f;
            name_roi = strrep(name_roi,' ','_');
            % shorten name
            name_roi = strsplit(name_roi,'_');
            name_roi = name_roi([1,2]);
            name_roi = strjoin(name_roi,'_');
            % transfer into matrix
            ct = ct + 1;
            full_name = ['SS_' name_ss '_ROI_' name_roi];
            
            % some replacements
            full_name = strrep(full_name,'Right','R');
            full_name = strrep(full_name,'Left','L');
            full_name = strrep(full_name,'Amygdala','Amy');
            full_name = strrep(full_name,'Accumbens','Acc');
            full_name = strrep(full_name,'_grp01_','');
            
            names_vars_extr{ct} = full_name;
            values_extr = [values_extr,ssgPPI_extr_feedback{ii,jj}];
        end
    end
    values_extr     = values_extr(:,2:end);
    names_vars_extr = strrep(names_vars_extr,'.','_');
    names_vars_extr = strrep(names_vars_extr,'StrAso','StrAs');
    T               = array2table(values_extr, ...
        'VariableNames',names_vars_extr);
    T.subject       = subs_vectors{1};
    writetable(T,'ssgPPI_extr_ngm.csv','Delimiter','\t')
    
    % copy the file where R will use it
    source = 'ssgPPI_extr_ngm.csv';
    target = ['C:\Users\' comp_name '\Google Drive\VPPG_Exchange\Experimente\PDT\Daten\pilot'];
    target = fullfile(target,source);
    copyfile(source,target,'f')
    
end


% %% ############### extract ss-eigvar ##############
% if ss_extr
%     % THIS IS CUTTING OUT TRIAL BY TRIAL ACTIVITY!!! PER SUBJECT
%     % make ROIs
%     keyboard
%     names_ROIs       = {'Amygdala','Caudate'};
%     %coord_ROIs       = {[8 4 -2], [-2 52 6],[-4 -50 18],[-4 -38 30]};
%     coord_ROIs       = {};
%
%     cur_SPM          = 'E:\Daten\VPPG\MRT\MRT\VPPG0104\MRT\NIFTI\results\PDT_ss_design_01\SPM.mat';
%     for kk = 1:length(names_ROIs)
%         cur_coord        = coord_ROIs{kk};
%         cur_name         = cellstr(names_ROIs{kk});
%         cur_dest         = 'C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\sl\ROIs';
%         cd (cur_dest)
%         create_sphere_image(cur_SPM,cur_coord,cur_name,repmat(20,3,1));
%     end
%
%     % calculate a combined cue reactivity map
%     name_out = 'table2.nii';
%     names_in = {};
%     for gg = 1:length(coord_ROIs)
%         names_in{gg} = [names_ROIs{gg} '_mask.nii'];
%     end
%     f = 'sum(X)';
%     spm_imcalc(names_in,name_out,f,{1})
%
%
%     for kk = 1:1
%         % prep extr.
%         cd(base_dir_pl);
%         %cur_ROI          = 'C:\Users\genaucka\Google Drive\Library\MATLAB\LA\2L_Analysis\ROI\accumbens\accumbens.nii';
%         cur_ROI          = ['C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\sl\ROIs\table3.nii']; % path to ROI where to extract
%         all_subf         = cellstr(ls('VPPG*'));
%         ss_name          = 'PDT_ss_design_01'; % name of ss design for extr.
%
%         % EXTRACTING BOLD RESPONSE PER TRIAL DURING PIC-PHASE AT ROI
%         for ii = 1:1
%             cd(base_dir_pl);
%             cur_sub = all_subf{ii};
%             %ss_extr_feedback{ii} = agk_get_pic_mri_scores(cur_sub,ss_name,cur_ROI);
%             ss_extr_feedback{ii} = agk_get_pic_mri_timeseries(cur_sub,ss_name,cur_ROI);
%         end
%     end
%
%     % deconvolving
%     cur_ts  = cell2mat(ss_extr_feedback{ii}{5});
%     cur_mn_tsg = mean(cur_ts(ss_extr_feedback{1}{4} == 1,:));
%     plot(cur_mn_tsg)
%     cur_hrf = spm_hrf(1);
%
%     v          = cur_hrf;
%     x          = (1:1:length(v)); % original coordinates of sampling
%     xq         = linspace(x(1), x(end), (length(x))*1000); % TR of 2s to 1000Hz, interpolated sampling points;
%     Y_1        = interp1(x,v,xq);
%     cur_hrf    = zscore(Y_1(1:16000));
%
%     [q,r] = deconv(zscore(cur_mn_tsg(2:16000)),cur_hrf(2:16000));
%
%
%     % DONT FORGET TO MOVE EXTRACTS AFTER EXTRACTING! (USING BEHAV MOVE)
%
% end