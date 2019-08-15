% Pipeleine do do generalized Psychophysiological Interactions with gPPI in
% SPM 8
%
% ############################## CAUTION: ##############################
% # This script only works in spm8 with windows!!!                     #
% ######################################################################
%
% Outputs:
%    spm_jobman outputs. For detailed explanation look at spm
%     documentation under http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%
% Other m-files required: jpa_getGppiContrasts
%
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2017; Last revision: 09-Aug-2017

%------------- BEGIN CODE --------------
clear all

%% ############### Generell Settings ###############
% ________________________________NECESSARY________________________________
% User-name
comp_name = getenv('USERNAME');
% Script-Libary-Path: where did you save this script?
%base_dir_lib = 'E:\Google Drive\Library\MATLAB\SPM\fmri_pipeline\pipeline\';
base_dir_lib = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\SPM\fmri_pipeline\pipeline\'];
% 1stLvl GLM-Path: where is your firstLevel base-directory?
%base_dir_pl = 'E:\ChariteTestData\ppiExample\';
base_dir_pl = 'L:\data\';
% 
% ________________________________Optional_________________________________
% path where SPM8 is located.
% Leave empty if standard path (matlabroot\toolbox\spm8)
ss_level.gen.pathToSpm12 = 'C:\Program Files\spm12';
ss_level.gen.pathToSpm8  = 'C:\Program Files\spm8';
% path where PPPI is located
% Leave empty if standard path (matlabroot\toolbox\spm8\PPPI)
ss_level.gen.pathToSpm8PPPI = 'C:\Program Files\spm8\toolbox\PPPI\';
% Define the path to sjinfo.mat
%ss_level.gen.sjinfo.path = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten\PDT\pilot\Sjinfo.mat';
ss_level.gen.sjinfo.path  = 'C:\Users\agemons\Google Drive\VPPG_Exchange\Experimente\PDT\Daten\pilot\Sjinfo.mat';
% Define structure to ID-Vector
ss_level.gen.sjinfo.IDs = '';                 % default: ''
% Define IDs which are excluded from the statistical tests. Separate each
% ID with ','!
ss_level.gen.excludeList = {''};                      % default: {''}, i.e. no ID will be excluded from the test
% Define the path to a excludeList Textfile, leave empty if not wanted
ss_level.gen.excludeListPath = '';
% define IDs which are included in the statistical tests. Separate each
% ID with ','!
cd (base_dir_pl)
%all_subs    = cellstr(ls('VPPG*'));
%includeList = all_subs(1:33); 
ss_level.gen.includeList = {''};                                % default: {''},i.e. all IDs will be part of the test
% Define the path to a includeList Textfile, leave empty if not wanted
ss_level.gen.includeListPath = '';
% parpool workers
M = 11;
%% ############### gPPI ###############
% ________________________________NECESSARY________________________________
% A string with the subject number - just for naming reasons - leave empty
% will be filled automatically
%%%%%%% ss_level.gppi.subject='Attention_Tutorial';
% Either a string with the path to the first-level SPM.mat directory, or 
% if you are only estimating a PPI model, then path to the 
% first-level PPI directory.  Separate each model with
% a ','! Do not use a ';'!
%ss_level.gppi.directory=base_dir_pl;
ss_level.gppi.FirstLVLModel={'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc'};
% A cell array containing strings with the names of the VOI.mat file or 
% an image file of the ROI for which the analysis should be done. 
% Each ID/Subject must contain this in its firstLevelModel folder.
base_path_ROIs = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_seeds'];
VOI_folder     = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_seeds'];
cd(VOI_folder);
ss_level.gppi.VOI=cellstr(ls('*.nii'));

for kk = 1:length(ss_level.gppi.VOI)
    ss_level.gppi.VOI{kk} = fullfile(pwd,ss_level.gppi.VOI{kk});
end

% running only part of it
%to_do_now = 1:3;
%ss_level.gppi.VOI = ss_level.gppi.VOI(to_do_now);

% A cell array containing strings with the basename of output file(s) which
% will be created!!! If doing physiophysiological interaction, then two names
% separated by a space are needed.
cur_names = {};
for kk = 1:length(ss_level.gppi.VOI)
    [p f e] = fileparts(ss_level.gppi.VOI{kk});
    cur_name = strsplit(f,' ');
    cur_names{1,kk} = [cur_name{1} '_' cur_name{2}]; 
end
ss_level.gppi.Region = cur_names;

% Specifies psychophysiological interaction:    ('psy')
%   or physiophysiological interaction:         ('phys')
%   or psychophysiophysiological interactions   ('psyphy')
ss_level.gppi.analysis='psy';
% Specifies traditional SPM PPI:            ('trad') 
%   or generalized condition-specific PPI   ('cond')
% It is recommend that the ‘cond’ approach is always selected 
ss_level.gppi.method='cond';  
% Option to additionally read contrasts out of SPM file. 
% File must be located inside each FirstLVLModel folder.
ss_level.gppi.readSPMContrasts = 1;
% Option to read contrasts defined in section "OPTIONAL CONTRAST". 
% Switch off if you only whish to load Contrasts from SPM struct.
ss_level.gppi.readScriptContrasts = 0;
% The minimum number of events needed to compute the contrast. 
% This is required. This is a number.
ss_level.gppi.minEvents = 5;
%
% _____________________________OPTIONAL____________________________________
% Specifies whether or not to estimate the PPI design. 1 means to esimate
% the design, 2 means to estimate the design from already created 
% regressors (must be of the OUT structure), 0 means not to estimate.
% Default is set to 1, so it will estimate the model.
ss_level.gppi.Estimate=1;
% In the generalized condition-specific PPI, you should specify the tasks 
% to include in the analyses, but put ‘0’ or ‘1’ in front of them to specify 
% if they must exist in all sessions. For the ‘trad’ approach the task must
% appear in all runs to make the proper, so the number should not be input 
% first. For the ‘cond’ approach task has to occur in at least 1 run, which 
% is why you have the option. This field should be entered as a cell array.
% TASK EQUALS CONDITION
ss_level.gppi.Tasks = {'1' 'Pic.on','Pic.gam.on','Pic.gam.opt.on'}; 
% For traditional PPI, you must specify weight vector for each task
ss_level.gppi.Weights = [-1 1];
% Specifies the ROIs must be the same size in all subjects.
% Default=1 (true) set to 0 to lift the restriction
ss_level.gppi.equalroi = 0;
% Specifies that the ROI should be restricted using the mask.img from the 
% first-level statistics. Default=0, 1 means to use the mask.img from the 
% 1st level model.
ss_level.gppi.FLmask=0;
% 0 not to estimate any contrasts
% 1 to estimate contrasts
% 2 to only use PPI txt file for 1st level 
% 3 to only use PPI txt file for 1st level and estimate contrasts
% 2&3 are not recommended as they potentially do not include all tasks 
% effects in the mode. Use at your own risk. 3 cannot weight the contrasts
% based on the number of trials. Default is 0.
ss_level.gppi.CompContrasts=1;
% Contrast to adjust for. Adjustments remove the effect of the null space
% of the contrast. Set to 0 for no adjustment. 
% Set to a number, if you know the contrast number. 
% Set to a contrast name, if you know the name.
ss_level.gppi.contrast=0; % 'Omnibus F-test for PPI Analyses'
% Specifies the method of ROI extraction
%   eigenvariate:   ('eig') (default)
%   or mean:        ('mean')
ss_level.gppi.extract= 'eig'; % ok, because it is on ss level; the time series direction of most variance
%
% ________________________OPTIONAL CONTRAST________________________________
% Contrast to adjust for. Adjustments remove the effect of the null space
% of the contrast. Set to 0 for no adjustment. 
% Set to a number, if you know the contrast number. 
% Set to a contrast name, if you know the name.
% copy as often as you like to specify more than one contrast
%
% FIELDS:
%	left        -- a cell array with tasks on left side of equation or 'none'
%	right       -- a cell array with tasks on right side of equation or 'none'
%	Weighted    -- either specified or from Weighted above. If not defined, defaults to 0.
%	STAT        -- 'T' or 'F'
%	c           -- contrast vector from createVec, automatically generated
%   name        -- name of contrast, will be defined by task list if left blank. NOTE: Windows users need to define this field as automatic names may be longer than allowed by Windows.
%	Prefix      -- prefix to the task name (optional), can be used to select each run (e.g. ‘Sn(1)’)
%	Contrail    -- suffix after task name (e.g. parametric modulators, different basis function)
%   MinEvents   -- The minimum number of events needed to compute the contrast. This is required. This is a number.
%   MinEventsPer -- The minimum number of events per task needed to compute the contrast. This is a number. Default is MinEvents/NumberOfTasks on each side of the contrast.
%
% YOU SEPARATE EACH CONTRAST WITH a ',' SYMBOL!
ss_level.gppi.Contrasts.name={'PPI.Pic.on','PPI.Pic.gam.on', ...
    'PPI.Pic.gam.opt.on'};
% define for each contrast the settings in  {} brackets!
ss_level.gppi.Contrasts.left={ 
    
    {'Pic.on'}, ...         % contrast 1
    {'Pic.gam.on'}, ...     % contrast 2
    {'Pic.gam.opt.on'} ...  % contrast 3
    
    };
ss_level.gppi.Contrasts.right={ 
    
    {'none'}, ... % contrast 1
    {'none'}, ... % contrast 2
    {'none'} ... % contrast 3
    
};
ss_level.gppi.Contrasts.Weighted={0, 0, 0};
ss_level.gppi.Contrasts.MinEvents={5, 5, 5};
ss_level.gppi.Contrasts.STAT={'T','T','T'};
ss_level.gppi.Contrasts.MinEventsPer = {[],[],[]};
ss_level.gppi.Contrasts.c = {[],[],[]};
ss_level.gppi.Contrasts.Prefix = {[],[],[]};
ss_level.gppi.Contrasts.Contrail =  {[],[],[]};
% ss_level.gppi.Contrasts.Contrail = {
%     
%     {'xgam^1','xneg^1','xpos^1'}, ...
%     {'gain^1','loss^1','ed^1','xacc^1','xaccXgam^1', ...
%     'xaccXneg^1','xaccXpos^1'}, ...
%     []};

% _____________________________PARTS TO RUN________________________________
% Run batch
ss_level.gppi.run_batch = 1;     
%
%
%
%  #####################################################
%% ################### Begin Analysis ##################
%  #####################################################
if ss_level.gppi.run_batch
%     % check if correct SPM version running.
%     if isempty(ss_level.gen.pathToSpm8)
%         jpa_switch_spm(12,8,0,1);
%     else
%         jpa_switch_spm(12,ss_level.gen.pathToSpm8,0,1);
%     end
    
    % make sure that SPM8 is running
    which_spm(8,comp_name,1)
    spm('Quit')
    rmpath(genpath(ss_level.gen.pathToSpm12))
    save('backup.mat');
    clear classes
    load('backup.mat')
    addpath(ss_level.gen.pathToSpm8)
    spm defaults fmri
    spm_jobman initcfg
    spm_get_defaults('cmdline',true)
    disp ('Changed to SPM8')
    
    % check if Path contains PPPI function
    if exist('PPPI','file') == 0
        % try to add standard PPPI path to Path
        if isempty(ss_level.gen.pathToSpm8PPPI)
            ss_level.gen.pathToSpm8PPPI = [matlabroot filesep 'toolbox' filesep 'spm8' filesep 'PPPI'];
        end
        if exist(ss_level.gen.pathToSpm8PPPI, 'dir') ~= 0
            addpath(ss_level.gen.pathToSpm8PPPI);
        else
            error('Can not find PPPI functions!')
        end
    end
    
    % get ID names out of sjinfo
    try 
        sjinfo = load(ss_level.gen.sjinfo.path);
        if strcmp(ss_level.gen.sjinfo.IDs , '') % do recursive search
            ids = jpa_getSubstruct(sjinfo, 'STID');
            if isempty(ids); error('Could not find STID!');end
        else % try to read given subStruct
            ids = sjinfo;
            subStructToSTID = textscan(ss_level.gen.sjinfo.IDs,'%s','delimiter','.');
            subStructToSTID = subStructToSTID{1,1};
            for i=1:1:length(subStructToSTID)
                ids = ids.(subStructToSTID{i});
            end
        end
    catch ME
        disp('Can not load sjinfo or structure is wrong!');
        disp(ME.identifier);
        rethrow(ME);
    end
    
    % Load Exclude List
    if ~strcmp(ss_level.gen.excludeListPath, '')
        [excludeListFilepath,excludeListFilename] = fileparts(ss_level.gen.excludeListPath);
        ss_level.gen.excludeListFile = jpa_loadTxtToArray(ss_level.gen.excludeListPath);
        % combine IDs loaded from File and specified in script
        ss_level.gen.excludeList = [ss_level.gen.excludeList ss_level.gen.excludeListFile];
    else
        excludeListFilename = 'excludeList';
    end
    % Load Include List
    if ~strcmp(ss_level.gen.includeListPath, '')
        [includeListFilepath,includeListFilename] = fileparts(ss_level.gen.includeListPath);
        ss_level.gen.includeListFile = jpa_loadTxtToArray(ss_level.gen.includeListPath);
        % combine IDs loaded from File and specified in script
        ss_level.gen.includeList = [ss_level.gen.includeList ss_level.gen.includeListFile];
    else
        includeListFilename = 'includeList';
    end
    % empty Include-Lists are not allowed
    first = ss_level.gen.includeList{1};
    if strcmp(first, '') || isempty(ss_level.gen.includeList)
        ss_level.gen.includeList = ids;
    end
    
    P = ss_level.gppi;
    % loop over 1.st level Models (GLMs)
    for modelIt=1:1:length(ss_level.gppi.FirstLVLModel)
        % loop over ROI/VOI and Region
        for roiIt=1:1:length(ss_level.gppi.VOI)
            P.VOI = ss_level.gppi.VOI{roiIt};
            P.Region = ss_level.gppi.Region{roiIt};
            % get subject list
            ss_level.gppi.searchFor = ss_level.gppi.FirstLVLModel{modelIt};
            match = jpa_getDirs(base_dir_pl,ss_level.gppi.searchFor);
            [logID, indSearchIn, idsFound] = jpa_getLogicalID(match, ids, ss_level.gen.excludeList, ss_level.gen.includeList);
            % lop over match (e.g. subjects)
            %ind_sequence = 1:1:length(indSearchIn);
            ind_sequence = 34:65;
            parfor (indIt=ind_sequence,M)
            %for indIt=ind_sequence
                if (indSearchIn(indIt) ~= 0) % then do test
                    indP           = P;
                    indP.subject   = ids{indSearchIn(indIt)};
                    indP.directory = match{indIt};
                     % read Contrasts from SPM
                    if ss_level.gppi.readSPMContrasts
                        try
                            SPM = load([match{indIt} filesep 'SPM.mat']);
                            SPM = SPM.SPM;
                            indP.SPMContrasts = jpa_readContrasts(SPM ,ss_level.gppi.minEvents);
                        catch ME
                            disp(ME.identifier);
                            cd(base_dir_lib)
                            rethrow(ME); 
                        end
                    end
                    % read Contrasts from Script
                    if ss_level.gppi.readScriptContrasts
                        indP.ScriptContrasts = jpa_getGppiContrasts(ss_level.gppi.Contrasts);
                    end
                    % combine Contrasts
                    if ss_level.gppi.readSPMContrasts && ss_level.gppi.readScriptContrasts
                        indP.Contrasts = [indP.SPMContrasts indP.ScriptContrasts];
                    elseif ~ss_level.gppi.readSPMContrasts && ss_level.gppi.readScriptContrasts
                        indP.Contrasts = indP.ScriptContrasts;
                    elseif ss_level.gppi.readSPMContrasts && ~ss_level.gppi.readScriptContrasts
                        indP.Contrasts = indP.SPMContrasts;
                    else
                        error('No contrasts defined!')
                    end
                    cd(indP.directory)
                    warning('DELETING gPPI folder is turned off; somehow deletes other gppi folders then')
%                     % deleting old gPPI
%                     curPPIpaths = cellstr(ls(['*' indP.Region '*']));
%                     if ~isempty(curPPIpaths{1})
%                         for pp = 1:length(curPPIpaths)
%                             id = exist(curPPIpaths{pp});
%                             if id == 2 % file
%                                 delete(fullfile(pwd,curPPIpaths{pp}))
%                             elseif id == 7 % folder
%                                 cmd_rmdir(fullfile(pwd,curPPIpaths{pp}));
%                             else
%                                 error('unexpected file type')
%                             end
%                         end
%                     end
                    % run PPPI
                    tmp = PPPI_checkstruct(indP);
                    if isfield(tmp,'correct')
                        try
                            PPPI(indP);
                            cd(base_dir_lib);
                        catch ME
                            disp(ME.identifier);
                            cd(base_dir_lib)
                            rethrow(ME); 
                        end
                    else
                        errTerm = tmp;
                        disp('ERROR: See ErrTerm struct for more information!');
                    end
                end
            end
        end
    end
    cd(base_dir_lib)
end
