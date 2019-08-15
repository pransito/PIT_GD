function jpa_FDmreg(mreg)
% function that does a spm multiple regression with specified settings
%
% Syntax:
%    jpa_FDmreg(mreg)
%
% Inputs:
%    mreg               - Struct with settings
%     .sjinfo           - Struct which defines Information about Subjects
%     .sjinfo.path      - Path to Struct which contains Information about Subjects
%     .sjinfo.IDs       - Substructure to IDs-Vector, defined as String
%     .sjinfo.Grps      - Substructure to Grps-Vector, defined as String
%     .FirstLVLModel    - Model-directory where the first level results are
%                           located
%     .con              - 1.st Level Contrast to be evaluated in mreg
%     .conNames         - 1.st Level Contrast Name
%     .numberOfGrp      - the groupnumber of Subjects to be evalueted in
%                           mreg
%     .excludeList      - contains IDs that are excluded from the
%                           statistical evaluation
%     .excludeListPath  - path to a exclude.txt file which contains IDs
%                           that are excluded from the statistical evaluation
%     .includeList      - contains IDs that are included from the
%                           statistical evaluation
%     .includeListPath  - path to a include.txt file which contains IDs
%                           that are included from the statistical evaluation
%     .intercept        - Enables the use of an intercept
%     .covarNames       - Name of covariates which values are in sjinfo.KAP
%     .interaction      - Interaction between covariates
%     .contrastType     - Types of Contrasts
%     .contrastNames    - Names of Contrasts
%     .contrastWeights  - Weight-Vector of Contrasts
%     .contrastRep      - Replication-Mode of Contrasts
%     .evalResPValue    - PValue for evaluation
%     .evalResThreshold - Threshold for evaluation
%     .evalResROI       - Paths to ROI
%     .evalResAtlas     - Atlas for anatomical regions
%     .mricroGLPath     - Path to MicroGL-Program
%     .loadimage        - BackgroundImage to load first in MircoGL
%     .plotPerRow       - Numer of Pictures in one Plot per Row
%     .plotPerCol       - Numer of Pictures in one Plot per Column
%     .picPerPage       - Number of Pictures per Page
%     .colSchem         - Color Scheme to add a Colorbar for
%     .run_batch        - Enables spm_jobman
%     .est_model        - Enables Model Estimation
%     .con_man          - Enables Contrast Manager
%     .evalResults      - Enables evaluation of Model Estimation
%     .dosavebatch      - Enables Save of Batch and Information-Struct
%     .base_dir_mreg    - Base dir where to save Outputs of mreg results
%     .base_dir_pl      - Base dir where to find Subject scans
%
% Outputs:
%     spm_jobman outputs. For detailed explanation look at spm
%     documentation under http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%
% Example:
%     jpa_FDmreg(mreg)
%       where mreg:
%     .sjinfo.path      = 'C:\example\sjinfo.mat'
%     .sjinfo.IDs       = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .sjinfo.Grps      = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .FirstLVLModel    = 'exampleFirstLevelModel'
%     .con              = {'con_0001','con_0002'}
%     .conNames         = {'1stLvlContrastName1','1stLvlContrastName2'}
%     .numberOfGrp      = {'1'}
%     .excludeList      = {'1001','2002'}
%     .excludeListPath  = 'C:\example\exampleExclude.txt'
%     .includeList      = {'1003','2004'}
%     .includeListPath  = 'C:\example\exampleInclude.txt'
%     .intercept        = 1
%     .covarNames       = {'Age','EducationYears'}
%     .interaction      = [1 1]
%     .contrastType     = {'t','t'}
%     .contrastNames    = {'exampleContrast1','exampleContrast2'}
%     .contrastWeights  = {[-1 1 ] [-1 1]}
%     .contrastRep      = {'none','none'}
%     .evalResPValue    = 0.01
%     .evalResThreshold = 8
%     .evalResROI       = 'C:\example\roi.nii'
%     .evalResAtlas     = 'C:\example\atlas.xml'
%     .mricroGLPath     = 'C:\example\Programme\mricrogl'
%     .loadimage        = 'C:\example\mean_group_anatomy.nii'
%     .plotPerRow       = 2
%     .plotPerCol       = 2
%     .picPerPage       = []
%     .colScheme        = 'edge_phong'
%     .run_batch        = 1
%     .est_model        = 1
%     .con_man          = 1
%     .evalResults      = 1
%     .dosavebatch      = 1
%     .base_dir_mreg    = 'C:\example\scans\results_2nd_level\mreg'
%     .base_dir_pl      = 'C:\example\scans\'
%
%
% Other m-files required: jpa_getInitialienOfSting, jpa_reassembleCell,
%   jpa_initialFDMreg, jpa_addCovariates, jpa_initialFmriEst,
%   jpa_initialConMan, jpa_resizeColumsOfMat, jpa_getStandardFContrast,
%   jpa_addFContrast, spm_jobman, jpa_eval_results, jpa_getAllResults
% Subfunctions: none
% MAT-files required: sjinfo
%
% See also: jpa_initialFDMreg, jpa_addCovariates, jpa_initialFmriEst,
%       jpa_initialConMan, jpa_addFContrast, jpa_eval_results,
%       jpa_addTContrast

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

%% check input parameters
% sjinfo-Field
if nargin ~= 1
    error('Invlaid Number of Parameters');
end
% check Input Arguments & get Defaults
mreg = jpa_getSecndLvlDefaults(mreg);
% mreg specific parameters
if  ~isfield(mreg, 'intercept')
    mreg.intercept = 1;
end

%% Preprocessing
% initialization
covNotEmpty = false(length(mreg.covarNames),1);
if mreg.run_batch || mreg.est_model || mreg.con_man
    % load Sjinfo
    try
        load(mreg.sjinfo.path);
    catch ME
        disp(ME.identifier);
        error('Could not load sjinfo!');
    end
    % get covariates out of Sjinfo
    [ids, grp, covarsc, covNotEmpty] = jpa_getCovarsSjinfo(Sjinfo ,mreg.covarNames, mreg.sjinfo.IDs, mreg.sjinfo.Grps);
end
% get Initialien of Covariaten to name the Folder
covIn = jpa_getInitialienOfSting(mreg.covarNames(covNotEmpty));
if isempty(covIn) || strcmp(covIn{1,1},'')
    covIn{1,1} = 'noCov';
else
    covIn{1,1} = strcat('cov',covIn{1,1});
end
if mreg.run_batch || mreg.est_model || mreg.con_man
    % Load Exclude List
    if ~strcmp(mreg.excludeListPath, '')
        [excludeListFilepath,excludeListFilename] = fileparts(mreg.excludeListPath);
        mreg.excludeListFile = jpa_loadTxtToArray(mreg.excludeListPath);
        mreg.excludeList = [mreg.excludeList mreg.excludeListFile];
    else
        excludeListFilename = 'excludeList';
    end
    % Load Include List
    if ~strcmp(mreg.includeListPath, '')
        [includeListFilepath,includeListFilename] = fileparts(mreg.includeListPath);
        mreg.includeListFile = jpa_loadTxtToArray(mreg.includeListPath);
        mreg.includeList = [mreg.includeList mreg.includeListFile];
    else
        includeListFilename = 'includeList';
    end
    % empty Include-Lists are not allowed
    first = mreg.includeList{1};
    if strcmp(first, '') || isempty(mreg.includeList)
        mreg.includeList = ids;
    end
end

%% Path calculation
% what do we search
mreg.searchFor = strcat(mreg.FirstLVLModel,filesep ,mreg.con, '.nii');
% where do we save
mreg.analysis  = strcat(mreg.base_dir_mreg, 'groupstats', '_', ...
    mreg.FirstLVLModel, '_','grp', mreg.numberOfGrp{1},...
    '_',covIn{1,1},'_', mreg.conNames );
% make save-directory
if ~exist(mreg.analysis,'dir'); mkdir(mreg.analysis); end
mreg.dirName = strcat('groupstats', '_', mreg.FirstLVLModel,...
    '_','grp', mreg.numberOfGrp{1},'_',covIn{1,1},'_', mreg.conNames );

%% getCovariates and IDs ordered by group
if mreg.run_batch || mreg.est_model || mreg.con_man
    disp(strcat('run mreg in directory: ',mreg.dirName))
    % search for con_img and get paths
    match = jpa_getDirs(mreg.base_dir_pl,mreg.searchFor);
    % get Logical Vectors which IDs will be part of the Test and which match
    % will be part of the test
    [logicalIDs, indMatch, idsFound] = jpa_getLogicalID(match, ids, mreg.excludeList, mreg.includeList);
    % initialize
    [b,l]= size(match);
    if b==0
        disp('WARNING: No Matches Found!');
    end
    covariates4EachGoup = cell(length(mreg.covarNames),1);
    mreg.match2Group =  repmat({''},b,length(mreg.numberOfGrp));
    mreg.subjectList = repmat({''},length(logicalIDs),1);
    lengthSList = 0;
    % loop though all groups
    for ind=1:1:length(mreg.numberOfGrp)
        % filter Vector where Grp is not the one we search for
        logicalGrp = strcmp(grp,mreg.numberOfGrp{ind});
        logicalIDgroup = logicalIDs & logicalGrp;
        % get the covariates of the Subject
        for k=1:length(mreg.covarNames)
            % if Covariate could be found
            if covNotEmpty(k)
                covariates4EachGoup{k,ind} = covarsc{k}(logicalIDgroup);
            end
        end
        % get the scans of each group
        indM2G = 0;
        for i=1:1:length(indMatch)
            if indMatch(i) > 0 % test if Match was found
                if logicalIDgroup(indMatch(i)); % test if match is part of test
                    indM2G = indM2G + 1;
                    mreg.match2Group{indM2G,ind} = match{i,1};
                end
            end
        end
        % fill the ttest.subjectList for the current group
        mreg.subjectList((lengthSList+1):lengthSList + length(ids(logicalIDgroup)),1) = ids(logicalIDgroup);
        lengthSList = lengthSList + length(ids(logicalIDgroup));
    end
    % order them for spm in right way
    mreg.covariates = jpa_getCovVec(covariates4EachGoup);
    % filter the covarraites which has not been found
    mreg.covariates = mreg.covariates(covNotEmpty);
    
    %% Build & run batch
    % Initialize
    if mreg.run_batch
        spm('defaults','fmri');
        spm_get_defaults('mask.thresh',mreg.spm.spmMaskThresh);
        spm_jobman('initcfg');
    end
    matlabbatch = struct.empty;
    % set analysis folder
    factorial_design.dir = { mreg.analysis };
    % set con-images
    factorial_design.des.mreg.scans = mreg.match2Group;
    factorial_design.des.mreg.incint = mreg.intercept;
    matlabbatch = jpa_initialFDMreg(matlabbatch, factorial_design);
    % build covariates
    mreg.covarNames = mreg.covarNames(covNotEmpty);
    mreg.interaction = mreg.interaction(covNotEmpty);
    if mreg.intercept;numberOfCovars = sum(covNotEmpty) +1;else numberOfCovars = covNotEmpty ;end
    for i=1:sum(covNotEmpty)
        matlabbatch = jpa_addCovariates(matlabbatch,mreg.covariates{i},mreg.covarNames{i},mreg.interaction(i),1);
    end
    % model estimation
    if mreg.est_model
        matlabbatch = jpa_initialFmriEst(matlabbatch);
    end
    % initalize contrast Manager Module
    if mreg.con_man
        if mreg.est_model
            matlabbatch = jpa_initialConMan(matlabbatch);
            for i=1:1:length(mreg.contrastNames)
                [mreg.contrastWeights{i} st] = jpa_resizeColumsOfMat(mreg.contrastWeights{i},numberOfCovars);
                if st == -1;disp(['WARNING: ContrastWeight '  num2str(i) ' is to long! Removed last Elements: '  mat2str(mreg.contrastWeights{i})]);end
                if st == 1;disp(['WARNING: ContrastWeight ' num2str(i) ' is to short! Filled last Elements with zeros: ' mat2str(mreg.contrastWeights{i})]);end
                if strcmp(mreg.contrastType,'t')
                    matlabbatch = jpa_addTContrast(matlabbatch, mreg.contrastNames{i},mreg.contrastWeights{i},mreg.contrastRep{i});
                end
                if strcmp(mreg.contrastType,'f')
                    matlabbatch = jpa_addTContrast(matlabbatch, mreg.contrastNames{i},mreg.contrastWeights{i},mreg.contrastRep{i});
                end
            end
        else % can not run Contrast Manager without Model estimation
            disp('Model estimation-Module not activated. skipping Contrast Manager ...');
        end
    end
    % run spm_jobman
    if mreg.run_batch
        spm_jobman('run',matlabbatch);
    end
    % save matlabbatch
    if mreg.dosavebatch
        mreg.excludeList = [mreg.excludeList ids(~idsFound)];
        mreg.includeList = unique(mreg.includeList);
        jpa_writeArrayToTxt([mreg.analysis, filesep, excludeListFilename '.txt'], mreg.excludeList, 'v' );
        jpa_writeArrayToTxt([mreg.analysis, filesep, includeListFilename '.txt'], mreg.includeList, 'v' );
        jpa_writeArrayToTxt([mreg.analysis, filesep, 'usedSubjectList.txt'], mreg.subjectList, 'v' );
        save([mreg.analysis,filesep,'matlabbatch.mat'],'matlabbatch');
        save([mreg.analysis,filesep,'mreg.mat'],'mreg');
    end
end

% eval results
if mreg.evalResults
    [current_sig_resultsWB  current_sig_resultsROI] = jpa_evalResults(mreg.analysis, mreg.evalResAtlas,mreg.evalResROI,'mreg', mreg.evalResPValue, mreg.evalResThreshold);
    % write sigResults of current mreg
    jpa_writeResults(current_sig_resultsWB, [mreg.analysis filesep 'results' filesep 'sig_resultsWB.txt']);
    jpa_writeResults(current_sig_resultsROI, [mreg.analysis filesep 'results' filesep 'sig_resultsROI.txt']);
    % get all sigResults of all mreg and fill them with sigRes of current mreg
    mreg_all_sig_resultsWB = jpa_getAllResults([mreg.base_dir_mreg 'mreg_all_sig_resultsWB.mat'],current_sig_resultsWB);
    mreg_all_sig_resultsROI = jpa_getAllResults([mreg.base_dir_mreg 'mreg_all_sig_resultsROI.mat'],current_sig_resultsROI);
    % save them as .mat
    save([mreg.base_dir_mreg 'mreg_all_sig_resultsWB.mat'],'mreg_all_sig_resultsWB')
    save([mreg.base_dir_mreg 'mreg_all_sig_resultsROI.mat'],'mreg_all_sig_resultsROI')
    % write them as .txt
    jpa_writeResults(mreg_all_sig_resultsWB, [mreg.base_dir_mreg 'mreg_all_sig_resultsWB.txt']);
    jpa_writeResults(mreg_all_sig_resultsROI, [mreg.base_dir_mreg 'mreg_all_sig_resultsROI.txt']);
end
end
%------------- END CODE --------------