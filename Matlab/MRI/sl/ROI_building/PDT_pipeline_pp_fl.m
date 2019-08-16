% PIPELINE FOR RUNNING PREPROCESSING AND 1st LEVEL

% Author: Alexander Genauck
% Work address:
% email: alexander.genauck@charite.de
% Website:
% Feb 2016; Last revision: 01-05-2016

%------------- BEGIN CODE --------------
clear all
%% ############### Generell Settings ###############
% User-name
comp_name = getenv('USERNAME');
% Script-Libary-Path: where did you save this script?
base_dir_lib  = ['C:\Users\' comp_name '\Google Drive\Library'];
base_dir_lib2 = ['C:\Users\' comp_name '\Google Drive\Promotion\VPPG\VPPG_Exchange\Library'];
% where are the subject folders with MRI data?
base_dir_pl = 'E:\Daten\VPPG\MRT\MRT';
% Set spm Mask Threshold
sd_level.spm.spmMaskThresh = 0.8; % spm_default: 0.8 on 2nd Lvl
addpath(genpath(base_dir_lib))
addpath(genpath(base_dir_lib2))
which_spm(12,comp_name,1)
% preproc job templates
preproc_tmpl{1}  = fullfile(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\pp_subf'], 'PDT_preprocessing_1sess_tmpl.mat');
preproc_tmpl{2}  = fullfile(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\pp_subf'], 'PDT_preprocessing_2sess_tmpl.mat');


% what to run?
d2n         = 1; % dicom 2 nifti
pp          = 1; % preprocessing
ss          = 0; % ss-level
ss_addcons  = 0; % ss-level addcons
ss_newcons  = 0; % ss-level make cons
ss_rm       = 0; % ss-level review design matrices
ss_extr     = 0; % ss-level extract eigvar from ROI

%% ############### DICOM2NIFTI #####################
if d2n
    cd(base_dir_pl);
    all_subf = cellstr(ls('VPPG*'));
    which_folders = {'*epi*','*MoCoSeries', '*Fieldmap*','*MPRAGE*'}; % patterns to know which folders
    for ii = 1:length(all_subf)
        cd(base_dir_pl);
        try
            cv_feedback{ii} = agk_PDT_wrapper_dcm2nifti(all_subf{ii},which_folders);
        catch
            disp(['There was an error in d2n. ' all_subf{ii}])
        end
    end
end

%% ############### PREPROCESS #####################
if pp
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    which_folders    = {'*epi*','*MoCoSeries'}; % patterns to know which folders to pp
    pm_defaults_file = fullfile(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\pp_subf'], 'pm_defaults_AGK.m');
    
    for ii = 1:length(all_subf)
        cd(base_dir_pl);
        try
            pp_feedback{ii} = PDT_preprocess(all_subf{ii},which_folders,pm_defaults_file,preproc_tmpl);
        catch MExc
            rethrow(MExc)
            disp(['There was an error in pp. ' all_subf{ii}])
        end
    end
end

%% ############### ss-LEVEL #######################
if ss
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    preproc_job      = load(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\LA\Preprocessing\SPM12\LA_preprocessing_template_AGK_SPM12.mat']);
    expl_mask        = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\LA\2L_Analysis\ROI\gm_mask.nii'];
    cur_tmpl{1}      = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\ss_models\LA_Ss_template_without_acc_reject.mat']; % ss batch templates (1: without acc_reject 2: with accept_reject)
    cur_tmpl{2}      = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\ss_models\LA_Ss_template.mat'];
    cur_tmpl{3}      = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\ss_models\LA_Ss_template_without_acc_reject_2runs.mat'];
    LA_charpentier   = ['C:\Users\' comp_name '\Google Drive\Promotion\VPPG\VPPG_Exchange\Library\MLE+Model\LA_Charpentier\MLE_results_Charpentier.txt']; % behav model LA Charpentier results
    LA_classic       = ['C:\Users\' comp_name '\Google Drive\Promotion\VPPG\VPPG_Exchange\Library\MLE+Model\LA_cl\MLE_results_AG.txt'];          % behav model LA classical results
    run_it           = 1;
    aggr             = 3;
    acc_rec          = 0;
    ow               = 1; % overwrite exisiting ss results?
    
    % THE PDT_SS_DESIGN
        for ii = 1:length(all_subf)
        %for ii = 1:length(all_subf)
            cd(base_dir_pl);
            ss_feedback{ii} = agk_make_PDT_ss_design_01(all_subf{ii},cur_tmpl,aggr, ...
                run_it,acc_rec,expl_mask,ow);
        end
    
    %     % THE PDT_SS_DESIGN_01_200ms model (with PIC only and PICPE param regressor)
    %     % (does not seem so useful) (hardly any change in sl; rather worse)
    %     for ii = 1:2
    %         cd(base_dir_pl);
    %         ss_feedback{ii} = agk_make_PDT_ss_design_02(all_subf{ii},cur_tmpl,aggr, ...
    %             run_it,acc_rec,expl_mask,ow);
    %     end
    
    % THE PDT_SS_DESIGN_LAcl_00
    %for ii = 1:3
    %     for ii = 4:length(all_subf)
    %         cd(base_dir_pl);
    %         ss_feedback{ii} = agk_make_PDT_ss_design_LAcl_00(all_subf{ii},cur_tmpl,aggr, ...
    %             run_it,acc_rec,expl_mask,ow,LA_classic);
    %     end
    
%     % THE PDT_SS_DESIGN_LAcl_01
%     for ii = 1:5
%         %for ii = 4:length(all_subf)
%         cd(base_dir_pl);
%         ss_feedback{ii} = agk_make_PDT_ss_design_LAcl_01(all_subf{ii},cur_tmpl,aggr, ...
%             run_it,acc_rec,expl_mask,ow,LA_classic);
%     end
    
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

%% ############### ss-LEVEL add cons ##############
if ss_addcons
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    ss_name          = 'PDT_ss_design_01'; % name of ss design to add cons to
    cur_templ        = 'C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\ss_models\con_man_template.mat';
    tcon.names       = {'pic.on.gam_gr_pic.on.pos','pic.on.gam_kl_pic.on.pos','pic.on.gam_gr_pic.on.neg','pic.on.gam_kl_pic.on.neg'};
    tcon.codes       = {[0 1 0 -1], [0 -1 0 1], [0 1 -1 0], [0 -1 1 0]};
    del              = 0
    
    %FOR PDT_ss_design_00
    %tcon.names       = {'PICGAM>PIC','PICGAM.loss>PICGAMOPT.loss'};
    %tcon.codes       = {[-1 1], [0 0 0 1 0 0 0 -1]};
    
    % ADDING CONS TO THE SPM.mat of SS ANALYSIS
    for ii = 1:length(all_subf)
        cd(base_dir_pl);
        ss_addcon_feedback{ii} = agk_add_cons(base_dir_pl,all_subf{ii},ss_name, cur_templ,tcon,del);
    end
    
end

%% ############### ss-LEVEL new cons ##############
if ss_newcons
    cd(base_dir_pl);
    all_subf         = cellstr(ls('VPPG*'));
    ss_name          = 'PDT_ss_design_LAcl_01'; % name of ss design to add cons to
    cur_templ        = 'C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\ss_models\con_man_template.mat';
    del              = 1;
    
    %FOR PDT_ss_design_00
    %tcon.names       = {'PICGAM>PIC','PICGAM.loss>PICGAMOPT.loss'};
    %tcon.codes       = {[-1 1], [0 0 0 1 0 0 0 -1]};
    
    % ADDING CONS TO THE SPM.mat of SS ANALYSIS
    for ii = 2:length(all_subf)      
        cd(base_dir_pl);
        ss_addcon_feedback{ii} = agk_make_cons_ss(base_dir_pl,all_subf{ii},ss_name, cur_templ,del);
    end
end

%% ############### extract ss-eigvar ##############
if ss_extr
    % make ROIs
    names_ROIs       = {'r_precuneus','l_precuneus','post_cing', 'sup_temp'};
    coord_ROIs       = {[34 -74 36], [-12 -58 26],[23 -6 -36],[-52 10 -14]};
    cur_SPM          = 'F:\Daten\VPPG\MRT\MRT\VPPG0104\MRT\NIFTI\results\PDT_ss_design_01\SPM.mat';
    for kk = 1:length(names_ROIs)
        cur_coord        = coord_ROIs{kk};
        cur_name         = cellstr(names_ROIs{kk});
        cur_dest         = 'C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\sl\ROIs';
        cd (cur_dest)
        create_sphere_image(cur_SPM,cur_coord,cur_name,repmat(6,3,1));
    end
    
    for kk = 1:length(names_ROIs)
        % prep extr.
        cd(base_dir_pl);
        cur_ROI          = ['C:\Users\genaucka\Google Drive\Library\MATLAB\PDT\sl\ROIs\' names_ROIs{kk} '_mask.nii']; % path to ROI where to extract
        all_subf         = cellstr(ls('VPPG*'));
        ss_name          = 'PDT_ss_design_01'; % name of ss design for extr.
        
        % EXTRACTING BOLD RESPONSE PER TRIAL DURING PIC-PHASE AT ROI
        for ii = 1:length(all_subf)
            cd(base_dir_pl);
            cur_sub = all_subf{ii};
            ss_extr_feedback{ii} = agk_get_pic_mri_scores(cur_sub,ss_name,cur_ROI);
        end
    end
    
    % DONT FORGET TO MOVE EXTRACTS AFTER EXTRACTING!
    
end