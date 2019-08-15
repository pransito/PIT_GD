% Skript for runing second level analysis in SPM
%
% ############################## CAUTION: ##############################
% # This script only works in spm12 under windows!!!                   #
% ######################################################################
%
% Outputs:
%    spm_jobman outputs. For detailed explanation look at spm
%     documentation under http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%
% Other m-files required: jpa_FDttest, jpa_FDtwottest, jpa_FDanova
%           jpa_FDmreg
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_FDttest, jpa_FDtwottest, jpa_FDanova, jpa_FDmreg

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 14-Sep-2015

%------------- BEGIN CODE --------------
clear all

warning('anova, multiple regression, ttest need get the covariate fix (so that it runs once with and once without)')

%% ############### Generell Settings ###############
% User-name
comp_name = getenv('USERNAME');
% adding the general library
addpath(genpath('C:\Users\agemons\Google Drive\Library\MATLAB'));
% SPM12
which_spm(12,comp_name,1)
% Script-Libary-Path: where did you save this script?
base_dir_lib = 'C:\Users\agemons\Google Drive\Library\MATLAB\SPM\fmri_pipeline\pipeline\';
%base_dir_lib = 'E:\Google Drive\Library\MATLAB\SPM\fmri_pipeline\pipeline\';
% 1stLvl data-Path: where is your firstLevel Data with Subject-directorys?
base_dir_pl = 'L:\data\';
% Set spm Mask Threshold
sd_level.spm.spmMaskThresh = 0.2;               % spm_default: 0.8 on 2nd Lvl
% Define the path to sjinfo.mat
sd_level.gen.sjinfo.path =  'C:\Users\agemons\Google Drive\VPPG_Exchange\Experimente\PDT\Daten\pilot\Sjinfo_30_30.mat';
%sd_level.gen.sjinfo.path = ['E:\Google Drive\Promotion\VPPG\VPPG_Exchange\' ...
%    'Experimente\PDT\Daten\pilot\sjinfo.mat'];
% Define structure to ID-Vector
sd_level.gen.sjinfo.IDs = 'KAP.STID';                 % default: ''
% Define structure to Grps-Vector
sd_level.gen.sjinfo.Grps = 'KAP.GROUP';                  % default: ''
% Define IDs which are excluded from the statistical tests
sd_level.gen.excludeList = {'',''};                      % default: {''}, i.e. no ID will be excluded from the test
% Define the path to a excludeList Textfile, leave empty if not wanted
sd_level.gen.excludeListPath = '';
% define IDs which are included from the statistical tests
sd_level.gen.includeList = {''};                                   % default: {''},i.e. all IDs will be part of the test
% Define the path to a includeList Textfile, leave empty if not wanted
sd_level.gen.includeListPath = '';
% Define Covariates to be included in the statistical Tests
sd_level.gen.covarNames = {'EDUYRS'};
% ss-level uses informed basis set and boosted con images in hrf_boost
% ss-level subfolder
sd_level.gen.useHrfBoost = 0;
%
%% ############### TTest ###############
% ________________________________NECESSARY________________________________
% Switch on Ttest
sd_level.ttest.on = 0;
% Define firstLVL Models to each run ttest for
sd_level.ttest.FirstLVLModel = {'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_ngm\'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_ngm\'};
% -------------------------------------------------------------------------
% Define 1st Level Contrasts to each run ttest for
sd_level.ttest.con = {'con_0002','con_0003','con_0004', ...
    'con_0006','con_0007','con_0008','con_0009'}; % 
if (sd_level.gen.useHrfBoost)
    sd_level.ttest.FirstLVLModel = fullfile(sd_level.ttest.FirstLVLModel,'hrf_boost');
    sd_level.ttest.con = strcat('boost_',sd_level.ttest.con);
end
% 1st Level Contrasts Names
sd_level.ttest.conNames = {'Pic.gam','Pic.neg','Pic.pos', ...
    'Pic.Gam.OnxAcc','Pic.Gam.OnxAccxgam','Pic.Gam.OnxAccxneg','Pic.Gam.OnxAccxpos'};
% -------------------------------------------------------------------------
% Indicate all groups that are included in the test
sd_level.ttest.numberOfGrp = {'1','0'};
%
% _____________________________OPTIONAL____________________________________
% Define the path to sjinfo.mat if different to generell settings
sd_level.ttest.sjinfo.path = sd_level.gen.sjinfo.path;
% Define the structure to IDs if different to generell settings
sd_level.ttest.sjinfo.IDs = sd_level.gen.sjinfo.IDs;                    % default: ''
sd_level.ttest.sjinfo.Grps = sd_level.gen.sjinfo.Grps;                  % default: ''
% -------------------------------------------------------------------------
% Define excludeList if different to generell settings
sd_level.ttest.excludeList = sd_level.gen.excludeList ;                 % default: {''}
sd_level.ttest.excludeListPath = sd_level.gen.excludeListPath;
% Define includeList if different to generell settings
sd_level.ttest.includeList = sd_level.gen.includeList;                  % default: {''}
sd_level.ttest.includeListPath = sd_level.gen.includeListPath;
% -------------------------------------------------------------------------
% Define Covariates if different to generell settings
sd_level.ttest.covarNames = sd_level.gen.covarNames;
sd_level.ttest.interaction = [1 1 1];                     % default: 1
% -------------------------------------------------------------------------
% 2nd Level Contrasts 
sd_level.ttest.contrastType = { 't','t','F'};
sd_level.ttest.contrastNames = {'pos','neg','F'};
sd_level.ttest.contrastWeights = {[1] [-1] [1]};
sd_level.ttest.contrastRep = {'none', 'none','none'};       % default: none
% -------------------------------------------------------------------------
% evaluate results NACH OBEN
sd_level.ttest.evalResPValue    = 0.05;                     % default: 0.05
sd_level.ttest.evalResThreshold = 10;                       % default: 10
% define a ROI for each 1stLVL Contrast. Leave empty if no ROI required.
% if one ROI is requested for every contrast only specifiy one ROI.
sd_level.ttest.evalResROI   = {''};
sd_level.ttest.evalResAtlas = 'F:\fMRI\Programme\spm12\tpm\labels_Neuromorphometrics.xml';
% -------------------------------------------------------------------------
% view results
sd_level.ttest.mricroGLPath = 'F:\fMRI\Programme\mricrogl';          %
sd_level.ttest.loadimage = 'F:\fMRI\prep\results_2nd_level\mean_anatomy_final_group\mean_group_anatomy_CT_PG_AD.nii'; % BG Image
sd_level.ttest.colScheme = '1hot';
% -------------------------------------------------------------------------
% plot results
sd_level.ttest.plotPerRow = 3;
sd_level.ttest.plotPerCol = 2;
sd_level.ttest.picPerPage = [ 8 ];

%
% _____________________________PARTS TO RUN________________________________
% Run batch
sd_level.ttest.run_batch = 1;     
% -------------------------------------------------------------------------
% Estimate Model
sd_level.ttest.est_model = 1;
% -------------------------------------------------------------------------
% Contrast Manager
sd_level.ttest.con_man   = 1;
% -------------------------------------------------------------------------
% Evaluate Results
sd_level.ttest.evalResults = 0;
% -------------------------------------------------------------------------
% save batch and Settings-Struct
sd_level.ttest.dosavebatch = 1;
% -------------------------------------------------------------------------
% view results
sd_level.ttest.viewResults = 0;
% -------------------------------------------------------------------------
% plot results
sd_level.ttest.plotResults = 0;
%
%% ############### twoTTest ###############
% ________________________________NECESSARY________________________________
% Switch on Two-sample-Ttest
sd_level.twottest.on = 1;
% Define firstLVL Models to each run Two-sample-Ttest for
sd_level.twottest.FirstLVLModel = {'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_ngm\'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_ngm\'};
% -------------------------------------------------------------------------
% Define 1st Level Contrasts to each run Two-sample-Ttests for
sd_level.twottest.con = {'con_0002','con_0003','con_0004', 'con_0005', ...
    'con_0006','con_0007','con_0008'};
if (sd_level.gen.useHrfBoost)
    sd_level.twottest.FirstLVLModel = fullfile(sd_level.twottest.FirstLVLModel,'hrf_boost');
    sd_level.twottest.con = strcat('boost_',sd_level.twottest.con);
end
% 1st Level Contrasts Names
sd_level.twottest.conNames = {'Pic.gam','Pic.neg','Pic.pos', 'Pic.Gam.OnxAcc', ...
    'Pic.Gam.OnxAccxgam','Pic.Gam.OnxAccxneg','Pic.Gam.OnxAccxpos'};
% -------------------------------------------------------------------------
% Indicate all groups that are included in the test
sd_level.twottest.numberOfGrp = {'0' ,'1'};
%
% _____________________________optional____________________________________
% Define the path to sjinfo.mat if different to generell settings
sd_level.twottest.sjinfo.path = sd_level.gen.sjinfo.path;
% Define the structure to IDs if different to generell settings
sd_level.twottest.sjinfo.IDs = sd_level.gen.sjinfo.IDs;                    % default: ''
sd_level.twottest.sjinfo.Grps = sd_level.gen.sjinfo.Grps;                  % default: ''
% -------------------------------------------------------------------------
% define excludeList if different to generell settings
sd_level.twottest.excludeList = sd_level.gen.excludeList ;                 % default: {''}
sd_level.twottest.excludeListPath = sd_level.gen.excludeListPath;
% define includeList if different to generell settings
sd_level.twottest.includeList = sd_level.gen.includeList;                  % default: {''}
sd_level.twottest.includeListPath = sd_level.gen.includeListPath;
% -------------------------------------------------------------------------
% Define Covariates if different to generell settings
sd_level.twottest.covarNames = sd_level.gen.covarNames;
sd_level.twottest.interaction = [];                  % default: 1
% -------------------------------------------------------------------------
% 2nd Level Contrasts
sd_level.twottest.contrastType    = {'t','t','t','t'};
sd_level.twottest.contrastNames   = {'HC>PG','HC<PG','EOI_Tpos'};
sd_level.twottest.contrastWeights = {[1 -1] [-1 1] [1 1]};
sd_level.twottest.contrastRep     = {'none'};
sd_level.twottest.Fstandard       = true;
% -------------------------------------------------------------------------
% evaluate results
sd_level.twottest.evalResPValue    = 0.05;                  % default: 0.05
sd_level.twottest.evalResThreshold = 10;                    % default: 10
sd_level.twottest.evalResROI       = {'F:\fMRI\prep\results_2nd_level\ROIs\ROIs\lbprob_frontal_midline_bilateral.nii'}; %%%
sd_level.twottest.evalResAtlas     = 'C:\Program Files\MATLAB\R2014a\toolbox\spm12\tpm\labels_Neuromorphometrics.xml';
% -------------------------------------------------------------------------
% view results
sd_level.twottest.mricroGLPath = 'F:\fMRI\Programme\mricrogl';          %%%%
sd_level.twottest.loadimage    = 'F:\fMRI\prep\results_2nd_level\mean_anatomy_final_group\mean_group_anatomy_CT_PG_AD.nii'; % BG Image
% -------------------------------------------------------------------------
% plot results
sd_level.twottest.plotPerRow = 2;
sd_level.twottest.plotPerCol = 2;
sd_level.twottest.picPerPage = [];
sd_level.twottest.colSchem   = 'edge_phong';
% _____________________________PARTS TO RUN________________________________
% Run batch
sd_level.twottest.run_batch   = 1;
% -------------------------------------------------------------------------
% Estimate Model
sd_level.twottest.est_model   = 1;
% -------------------------------------------------------------------------
% Contrast Manager
sd_level.twottest.con_man     = 1;
% -------------------------------------------------------------------------
% Evaluate Results
sd_level.twottest.evalResults = 0;
% -------------------------------------------------------------------------
% save batch and Settings-Struct
sd_level.twottest.dosavebatch = 1;
%
%% ############### ANOVA ###############
% ________________________________NECESSARY________________________________
% Switch on Anova
sd_level.anova.on = 0;
% Define firstLVL Models to each run anova for
sd_level.anova.FirstLVLModel = {'results_abs_loss_3_noacc'};
% -------------------------------------------------------------------------
% Define 1st Level Contrasts to each run anova for
sd_level.anova.con = {'con_0002'};
% 1st Level Contrasts Names
sd_level.anova.conNames = {'1STLVLCON2',};
% -------------------------------------------------------------------------
% Indicate all groups that are included in the test
sd_level.anova.numberOfGrp = {'CT' ,'PG', 'AD'};
%
% _____________________________optional____________________________________
% Define the path to sjinfo.mat if different to generell settings
sd_level.anova.sjinfo.path = sd_level.gen.sjinfo.path;
% Define the structure to IDs if different to generell settings
sd_level.anova.sjinfo.IDs  = sd_level.gen.sjinfo.IDs;                 % default: ''
sd_level.anova.sjinfo.Grps = sd_level.gen.sjinfo.Grps;               % default: ''
% -------------------------------------------------------------------------
% Define excludeList if different to generell settings
sd_level.anova.excludeList     = sd_level.gen.excludeList ;              % default: {''}
sd_level.anova.excludeListPath = sd_level.gen.excludeListPath;
% Define includeList if different to generell settings
sd_level.anova.includeList     = sd_level.gen.includeList;               % default: {''}
sd_level.anova.includeListPath = sd_level.gen.includeListPath;
% -------------------------------------------------------------------------
% Define Covariates if different to generell settings
sd_level.anova.covarNames  = sd_level.gen.covarNames;
sd_level.anova.interaction = [ 1 1 1 ];                    % default: 1
% -------------------------------------------------------------------------
% 2nd Level Contrasts
% Anova standard-Contrast is EOI and ME if Fstandard is set to true
sd_level.anova.contrastType = {'t','t'};
sd_level.anova.contrastNames = {'HC>PAT','HC<PAT'};
sd_level.anova.contrastWeights = {[2 -1 -1] [-2 1 1]};
sd_level.anova.contrastRep = {'none','none'};
sd_level.anova.Fstandard = true;
% -------------------------------------------------------------------------
% evaluate results
sd_level.anova.evalResPValue = 0.05;                        % default: 0.05
sd_level.anova.evalResThreshold = 10;                       % default: 10
sd_level.anova.evalResROI = {'F:\fMRI\prep\results_2nd_level\ROIs\ROIs\lbprob_VS_left.nii'};
sd_level.anova.evalResAtlas = 'F:\fMRI\Programme\spm12\tpm\labels_Neuromorphometrics.xml';
% -------------------------------------------------------------------------
% view results
sd_level.anova.mricroGLPath = 'F:\fMRI\Programme\mricrogl';          %
sd_level.anova.loadimage = 'F:\fMRI\prep\results_2nd_level\mean_anatomy_final_group\mean_group_anatomy_CT_PG_AD.nii'; % BG Image
% -------------------------------------------------------------------------
% plot results
sd_level.anova.plotPerRow = 2;
sd_level.anova.plotPerCol = 2;
sd_level.anova.picPerPage = [];
sd_level.anova.colSchem = 'edge_phong';
% -------------------------------------------------------------------------
% Anova Optional Settings
sd_level.anova.independence   = 0;      % 1 = 'no' 0 = 'yes' default: 0
sd_level.anova.variance = 1;            % 1 = 'equal' 0 = 'unequal' default: 1
sd_level.anova.grandMeanScaling   = 0;  % 0 = 'no' default: 0
sd_level.anova.anCova = 0;              % 0 = 'no' defautl: 0
%
% _____________________________PARTS TO RUN________________________________
% Run batch
sd_level.anova.run_batch = 1;
% -------------------------------------------------------------------------
% Estimate Model
sd_level.anova.est_model = 1;
% -------------------------------------------------------------------------
% Contrast Manager
sd_level.anova.con_man   = 1;
% -------------------------------------------------------------------------
% Evaluate Results
sd_level.anova.evalResults = 1;
% -------------------------------------------------------------------------
% save batch and Settings-Struct
sd_level.anova.dosavebatch = 1;

%% ############### Multiple Regression ###############
% ________________________________NECESSARY________________________________
% Switch on Multiple Regression
sd_level.mreg.on = 0;
% Define firstLVL Models to each run Multiple Regression for
sd_level.mreg.FirstLVLModel = {'results_abs_loss_3_noacc'};
% -------------------------------------------------------------------------
% Define 1st Level Contrasts to each run Multiple Regression for
sd_level.mreg.con = {'con_0002'};
% 1st Level Contrasts Names
sd_level.mreg.conNames = {'Contrast2'};
% -------------------------------------------------------------------------
% Indicate all groups that are included in the test
sd_level.mreg.numberOfGrp = {'AD'};
%
% _____________________________optional____________________________________
% Define the path to sjinfo.mat if different to generell settings
sd_level.mreg.sjinfo.path = sd_level.gen.sjinfo.path;
% Define the structure to IDs if different to generell settings
sd_level.mreg.sjinfo.IDs = sd_level.gen.sjinfo.IDs;                 % default: ''
sd_level.mreg.sjinfo.Grps = sd_level.gen.sjinfo.Grps;               % default: ''
% Define excludeList if different to generell settings
sd_level.mreg.excludeList = sd_level.gen.excludeList ;              % default: {''}
sd_level.mreg.excludeListPath = sd_level.gen.excludeListPath;
% Define includeList if different to generell settings
sd_level.mreg.includeList = sd_level.gen.includeList;               % default: {''}
sd_level.mreg.includeListPath = sd_level.gen.includeListPath;
% set Intercept
sd_level.mreg.intercept = 1; % 1: Intecept on; 0: Intercept off; default: 1
% -------------------------------------------------------------------------
% Define Covariates if different to generell settings
sd_level.mreg.covarNames = sd_level.gen.covarNames;
sd_level.mreg.interaction = [ 1 1 1 ];                       % default: 1
% -------------------------------------------------------------------------
% 2nd Level Contrasts
sd_level.mreg.contrastType = {'t','t'};
sd_level.mreg.contrastNames = {'pos','neg'};
sd_level.mreg.contrastWeights = {[0 1] [0 -1]};
sd_level.mreg.contrastRep = {'none'};
% -------------------------------------------------------------------------
% evaluate results
sd_level.mreg.evalResPValue = 0.05;                        % default: 0.05
sd_level.mreg.evalResThreshold = 10;                       % default: 10
sd_level.mreg.evalResROI = {'F:\fMRI\prep\results_2nd_level\ROIs\ROIs\lbprob_frontal_midline_bilateral.nii'};
sd_level.mreg.evalResAtlas = 'F:\fMRI\Programme\spm12\tpm\labels_Neuromorphometrics.xml';
% -------------------------------------------------------------------------
% view results
sd_level.mreg.mricroGLPath = 'F:\fMRI\Programme\mricrogl';          %
sd_level.mreg.loadimage = 'F:\fMRI\prep\results_2nd_level\mean_anatomy_final_group\mean_group_anatomy_CT_PG_AD.nii'; % BG Image
sd_level.mreg.colScheme = '1hot';
% -------------------------------------------------------------------------
% plot results
sd_level.mreg.plotPerRow = 2;
sd_level.mreg.plotPerCol = 2;
sd_level.mreg.picPerPage = [];
%
% _____________________________PARTS TO RUN________________________________
% Run batch
sd_level.mreg.run_batch = 1;
% -------------------------------------------------------------------------
% Estimate Model
sd_level.mreg.est_model = 1;
% -------------------------------------------------------------------------
% Contrast Manager
sd_level.mreg.con_man   = 1;
% -------------------------------------------------------------------------
% Evaluate Results
sd_level.mreg.evalResults = 1;
% -------------------------------------------------------------------------
% save batch and Settings-Struct
sd_level.mreg.dosavebatch = 1;
%
%
%
%  #####################################################
%% ################### Begin Analysis ##################
%  #####################################################
addpath(base_dir_lib);
if ~strcmp(base_dir_lib(end), '\');base_dir_lib = [base_dir_lib '\'];end
if ~strcmp(base_dir_pl(end), '\');base_dir_pl = [base_dir_pl '\'];end

% make folder
if ~exist([base_dir_pl,'results_2nd_level'],'dir'); mkdir([base_dir_pl,'results_2nd_level']); end

% TTest
if sd_level.ttest.on
    if ~exist([base_dir_pl,'results_2nd_level\ttest'],'dir'); mkdir([base_dir_pl,'results_2nd_level\ttest']); end
    % set generel settings
    ttest = sd_level.ttest;
    ttest.spm = sd_level.spm;
    ttest.base_dir_ttest = [base_dir_pl,'results_2nd_level\ttest\'];
    ttest.base_dir_pl = base_dir_pl;
    % for all Models do
    for model=1:1:length(sd_level.ttest.FirstLVLModel)
        ttest.FirstLVLModel = sd_level.ttest.FirstLVLModel{model};
        % for all contrasts do
        for con=1:1:length(sd_level.ttest.con)
            ttest.con = sd_level.ttest.con{con};
            ttest.conNames = sd_level.ttest.conNames{con};
            if con <= length(sd_level.ttest.evalResROI)
                ttest.evalResROI =  sd_level.ttest.evalResROI{con};
            else
                ttest.evalResROI =  sd_level.ttest.evalResROI{length(sd_level.ttest.evalResROI)};
            end
            % for all Groups do
            for grp=1:1:length(sd_level.ttest.numberOfGrp)
                cd(base_dir_lib);
                ttest.numberOfGrp = sd_level.ttest.numberOfGrp(grp);
                % run ttest with desired parameters
                jpa_FDttest(ttest); 
                % run noCov-Ttest if covarNames not empty or equals {''}
                if isempty(sd_level.ttest.covarNames) || sum(~strcmp('',sd_level.ttest.covarNames ))== 0
                    ttest.covarNames = {''};
                    jpa_FDttest(ttest);
                end
            end
        end
    end
end
% twoTTest
if sd_level.twottest.on
    if ~exist([base_dir_pl,'results_2nd_level\twottest'],'dir'); mkdir([base_dir_pl,'results_2nd_level\twottest']); end
    
    % set generel settings
    twottest = sd_level.twottest;
    twottest.base_dir_twottest = [base_dir_pl,'results_2nd_level\twottest\'];
    twottest.base_dir_pl = base_dir_pl;
    % for all Models do twottest
    for model=1:1:length(sd_level.twottest.FirstLVLModel)
        twottest.FirstLVLModel = sd_level.twottest.FirstLVLModel{model};
        % for all contrasts do
        for con=1:1:length(sd_level.twottest.con)
            twottest.con = sd_level.twottest.con{con};
            twottest.conNames = sd_level.twottest.conNames{con};
            % pick a region of interest for evaluation
            if con <= length(sd_level.twottest.evalResROI)
                twottest.evalResROI =  sd_level.twottest.evalResROI{con};
            else
                % if not enough there take last one again
                twottest.evalResROI =  sd_level.twottest.evalResROI{length(sd_level.twottest.evalResROI)};
            end
            % for all 2-permutations of Groups do
            cd(base_dir_lib);
            for per=1:1:length(jpa_buildTwoPermutation(sd_level.twottest.numberOfGrp))
                % build
                cd(base_dir_lib);
                perm = jpa_buildTwoPermutation(sd_level.twottest.numberOfGrp);
                twottest.numberOfGrp = perm{per};
                % reset covarNames
                twottest.covarNames = sd_level.twottest.covarNames;
                % start two-sample-ttest
                jpa_FDtwottest(twottest);
                % run noCov-twottest if covarNames not empty or equals {''}
                cur_cov = cell2mat(sd_level.twottest.covarNames);
                if isempty(cur_cov)
                    continue
                elseif strcmp(cur_cov(1),'')
                    continue
                else
                    twottest.covarNames = {''};
                    jpa_FDtwottest(twottest);
                end
            end
        end
    end
end
% anova
if sd_level.anova.on
    if ~exist([base_dir_pl,'results_2nd_level\anova'],'dir'); mkdir([base_dir_pl,'results_2nd_level\anova']); end
    % set generel settings
    anova = sd_level.anova;
    anova.base_dir_anova = [base_dir_pl,'results_2nd_level\anova\'];
    anova.base_dir_pl = base_dir_pl;
    % for all Models do anova
    for model=1:1:length(sd_level.anova.FirstLVLModel)
        % for all contrasts do
        for con=1:1:length(sd_level.anova.con)
            if con <= length(sd_level.anova.evalResROI)
                anova.evalResROI =  sd_level.anova.evalResROI{con};
            else
                anova.evalResROI =  sd_level.anova.evalResROI{length(sd_level.anova.evalResROI)};
            end
            cd(base_dir_lib);
            anova.FirstLVLModel = sd_level.anova.FirstLVLModel{model};
            anova.con = sd_level.anova.con{con};
            anova.conNames = sd_level.anova.conNames{con};
            % start anova
            jpa_FDanova(anova);
            % run noCov-anova if covarNames not empty or equals {''}
            if isempty(sd_level.anova.covarNames) || sum(~strcmp('',sd_level.anova.covarNames ))== 0
                anova.covarNames = {''};
                jpa_FDanova(anova);
            end
        end
    end
end
% Multiple Regression
if sd_level.mreg.on
    if ~exist([base_dir_pl,'results_2nd_level\mreg'],'dir'); mkdir([base_dir_pl,'results_2nd_level\mreg']); end
    % set generel settings
    mreg = sd_level.mreg;
    mreg.base_dir_mreg = [base_dir_pl,'results_2nd_level\mreg\'];
    mreg.base_dir_pl = base_dir_pl;
    % for all Models do mreg
    for model=1:1:length(sd_level.mreg.FirstLVLModel)
        mreg.FirstLVLModel = sd_level.mreg.FirstLVLModel{model};
        % for all contrasts do
        for con=1:1:length(sd_level.mreg.con)
            mreg.con = sd_level.mreg.con{con};
            mreg.conNames = sd_level.mreg.conNames{con};
            if con <= length(sd_level.mreg.evalResROI)
                mreg.evalResROI =  sd_level.mreg.evalResROI{con};
            else
                mreg.evalResROI =  sd_level.mreg.evalResROI{length(sd_level.mreg.evalResROI)};
            end
            % for all Groups do
            for grp=1:1:length(sd_level.mreg.numberOfGrp)
                cd(base_dir_lib);
                mreg.numberOfGrp = sd_level.mreg.numberOfGrp(grp);
                % start multiple regression
                jpa_FDmreg(mreg);
                % run noCov-mreg if covarNames not empty or equals {''}
                if isempty(sd_level.mreg.covarNames) || sum(~strcmp('',sd_level.mreg.covarNames ))== 0
                    mreg.covarNames = {''};
                    jpa_FDmreg(mreg);
                end
            end
        end
    end
end
cd(base_dir_lib);
disp('End of Pipeline!');
%------------- END CODE --------------