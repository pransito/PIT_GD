function jpa_FDtwottest(twottest)
% function that does a two-paired-twottest with specified settings
%
% Syntax:
%    jpa_FDtwottest(twottest)
%
% Inputs:
%    twottest           - Struct with settings
%     .sjinfo           - Struct which defines Information about Subjects
%     .sjinfo.path      - Path to Struct which contains Information about Subjects
%     .sjinfo.IDs       - Substructure to IDs-Vector, defined as String
%     .sjinfo.Grps      - Substructure to Grps-Vector, defined as String
%     .FirstLVLModel    - Model-directory where the first level results are
%                           located
%     .con              - 1.st Level Contrast to be evaluated in twottest
%     .conNames         - 1.st Level Contrast Name
%     .numberOfGrp      - the groupnumber of Subjects to be evalueted in
%                           twottest
%     .excludeList      - contains IDs that are excluded from the
%                           statistical evaluation
%     .excludeListPath  - path to a exclude.txt file which contains IDs
%                           that are excluded from the statistical evaluation
%     .includeList      - contains IDs that are included from the
%                           statistical evaluation
%     .includeListPath  - path to a include.txt file which contains IDs
%                           that are included from the statistical evaluation
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
%     .base_dir_twottest- Base dir where to save Outputs of twottest results
%     .base_dir_pl      - Base dir where to find Subject scans
%
% Outputs:
%     spm_jobman outputs. For detailed explanation look at spm
%     documentation under http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%
% Example:
%     jpa_FDtwottest(twottest)
%       where mreg:
%     .sjinfo.path      = 'C:\example\sjinfo.mat'
%     .sjinfo.IDs       = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .sjinfo.Grps      = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .FirstLVLModel    = 'exampleFirstLevelModel'
%     .con              = {'con_0001','con_0002'}
%     .conNames         = {'1stLvlContrastName1','1stLvlContrastName2'}
%     .numberOfGrp      = {'1' '2'}
%     .excludeList      = {'1001','2002'}
%     .excludeListPath  = 'C:\example\exampleExclude.txt'
%     .includeList      = {'1003','2004'}
%     .includeListPath  = 'C:\example\exampleInclude.txt'
%     .covarNames       = {'Age','EducationYears'}
%     .interaction      = [1 1]
%     .contrastType     = {'t','t'}
%     .contrastNames    = {'exampleContrast1','exampleContrast2'}
%     .contrastWeights  = {[1 -1] [-1 1]}
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
%     .base_dir_twottest= 'C:\example\scans\results_2nd_level\twottest'
%     .base_dir_pl      = 'C:\example\scans\'
%
%
% Other m-files required: jpa_getInitialienOfSting, jpa_reassembleCell,
%   jpa_initialFDTtest, jpa_addCovariates, jpa_initialFmriEst,
%   jpa_initialConMan, jpa_resizeColumsOfMat, jpa_getStandardFContrast,
%   jpa_addFContrast, spm_jobman, jpa_eval_results, jpa_getAllResults,
%   jpa_addTContrast
% Subfunctions: none
% MAT-files required: sjinfo
%
% See also: jpa_initialFDTtest, jpa_addCovariates, jpa_initialFmriEst,
%       jpa_initialConMan, jpa_addFContrast, jpa_addFContrast,
%       jpa_eval_results

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

%% check input parameters
if nargin ~= 1
    error('Invlaid Number of Parameters');
end
% check Input Arguments & get Defaults
twottest = jpa_getSecndLvlDefaults(twottest);

%% Preprocessing
% initialization
covNotEmpty = false(length(twottest.covarNames),1);
if twottest.run_batch || twottest.est_model || twottest.con_man
    % load Sjinfo
    try
        load(twottest.sjinfo.path);
    catch ME
        disp(ME.identifier);
        error('Could not load sjinfo!');
    end
    % get covariates out of Sjinfo
    [ids, grp, covarsc, covNotEmpty] = jpa_getCovarsSjinfo(Sjinfo ,twottest.covarNames, twottest.sjinfo.IDs, twottest.sjinfo.Grps);
end
% get Initialien of Covariaten to name the Folder
covIn = jpa_getInitialienOfSting(twottest.covarNames(covNotEmpty));
if  isempty(covIn) || strcmp(covIn{1,1},'')
    covIn{1,1} = 'noCov';
else
    covIn{1,1} = strcat('cov',covIn{1,1});
end
if twottest.run_batch || twottest.est_model || twottest.con_man
    % Load Exclude List
    if ~strcmp(twottest.excludeListPath, '')
        [excludeListFilepath,excludeListFilename] = fileparts(twottest.excludeListPath);
        twottest.excludeListFile = jpa_loadTxtToArray(twottest.excludeListPath);
        twottest.excludeList = [twottest.excludeList twottest.excludeListFile];
    else
        excludeListFilename = 'excludeList';
    end
    % Load Include List
    if ~strcmp(twottest.includeListPath, '')
        [includeListFilepath,includeListFilename] = fileparts(twottest.includeListPath);
        twottest.includeListFile = jpa_loadTxtToArray(twottest.includeListPath);
        twottest.includeList = [twottest.includeList twottest.includeListFile];
    else
        includeListFilename = 'includeList';
    end
    % empty Include-Lists are not allowed
    first = twottest.includeList{1};
    if strcmp(first, '') || isempty(twottest.includeList)
        twottest.includeList = ids;
    end
end

%% Path calculation
% what do we search
%twottest.searchFor = strcat(twottest.FirstLVLModel,filesep ,twottest.con, '.nii');

twottest.searchFor = strcat(twottest.FirstLVLModel,filesep ,twottest.con, '.nii');

% where do we save
twottest.analysis  = strcat(twottest.base_dir_twottest, 'groupstats', '_', ...
    agk_privatize(twottest.FirstLVLModel, '\'), '_','grp', twottest.numberOfGrp{1},...
    twottest.numberOfGrp{2} , '_', covIn{1,1} ,...
    '_', twottest.conNames);
twottest.dirName = strcat('groupstats', '_', ...
    agk_privatize(twottest.FirstLVLModel, '\'), '_','grp', twottest.numberOfGrp{1},...
    twottest.numberOfGrp{2} , '_', covIn{1,1} ,...
    '_', twottest.conNames);
% make save-directory
if ~exist(twottest.analysis,'dir'); mkdir(twottest.analysis); end

%% getCovariates and IDs ordered by group
if twottest.run_batch || twottest.est_model || twottest.con_man
    disp(strcat('run twottest in directory: ',twottest.dirName))
    % search for con_img and get paths
    match = jpa_getDirs(twottest.base_dir_pl,twottest.searchFor);
    disp('The con images I found:')
    match
    % get Logical Vectors which IDs will be part of the Test and which match
    % will be part of the test
    [logicalIDs, indMatch, idsFound] = jpa_getLogicalID(match, ids, twottest.excludeList,  twottest.includeList);
    % initialize
    [b,l]= size(match);
    if b==0
        disp('WARNING: No Matches Found!');
        disp('WARNING: Trying to look for .img instead .nii con images');
    end
    
    % trying to look for .img
    
    if b==0
        twottest.searchFor = strcat(twottest.FirstLVLModel,filesep ,twottest.con, 'V*.img');
        % search for con_img and get paths
        match = jpa_getDirs(twottest.base_dir_pl,twottest.searchFor);
        disp('The con images I found:')
        match
        % get Logical Vectors which IDs will be part of the Test and which match
        % will be part of the test
        [logicalIDs, indMatch, idsFound] = jpa_getLogicalID(match, ids, twottest.excludeList,  twottest.includeList);
        % initialize
        [b,l]= size(match);
        if b==0
            disp('WARNING: No Matches Found!');
        end
    end
    
    covariates4EachGoup = cell(length(twottest.covarNames),2);
    twottest.match2Group =  repmat({''},b,length(twottest.numberOfGrp));
    twottest.subjectList = repmat({''},length(logicalIDs),1);
    lengthSList = 0;
    % loop though all groups
    for ind=1:1:length(twottest.numberOfGrp)
        % filter Vector where Grp is not the one we search for
        logicalGrp = strcmp(grp,twottest.numberOfGrp{ind});
        logicalIDgroup = logicalIDs & logicalGrp;
        % get the covariates of the Subject
        for k=1:length(twottest.covarNames)
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
                    twottest.match2Group{indM2G,ind} = match{i,1};
                end
            end
        end
         % fill the ttest.subjectList for the current group
        twottest.subjectList((lengthSList+1):lengthSList + length(ids(logicalIDgroup)),1) = ids(logicalIDgroup);
        lengthSList = lengthSList + length(ids(logicalIDgroup));
    end
    % order them for spm in right way
    twottest.covariates = jpa_getCovVec(covariates4EachGoup);
    % filter the covarraites which has not been found
    twottest.covariates = twottest.covariates(covNotEmpty);
    
    
    %% Build & run batch
    % Initialize
    if twottest.run_batch
        spm('defaults','fmri');
        spm_get_defaults('mask.thresh',twottest.spm.spmMaskThresh);
        spm_jobman('initcfg');
    end
    matlabbatch = struct.empty;
    % set analysis folder
    factorial_design.dir = { twottest.analysis };
    
    % set con-images
    factorial_design.des.t2.scans1 = twottest.match2Group(:,1);
    factorial_design.des.t2.scans2 = twottest.match2Group(:,2);
    % build matlabbatch Modul Factorial_Design
    matlabbatch = jpa_initialFDTtest(matlabbatch, factorial_design);
    % build covariates
    twottest.covarNames = twottest.covarNames(covNotEmpty);
    twottest.interaction = twottest.interaction(covNotEmpty);
    for i=1:sum(covNotEmpty)
        matlabbatch = jpa_addCovariates(matlabbatch,twottest.covariates{i},twottest.covarNames{i},twottest.interaction(i),1);
    end
    % model estimation
    if twottest.est_model
        matlabbatch = jpa_initialFmriEst(matlabbatch);
    end
    % initalize contrast Manager Module
    if twottest.con_man
        if twottest.est_model
            matlabbatch = jpa_initialConMan(matlabbatch);
            for i=1:1:length(twottest.contrastNames)
                [twottest.contrastWeights{i} st] = jpa_resizeColumsOfMat(twottest.contrastWeights{i},length(twottest.numberOfGrp) + sum(covNotEmpty));
                if st == -1;disp(['WARNING: ContrastWeight ' num2str(i) ' is to long! Removed last Elements: '  mat2str(twottest.contrastWeights{i})]);end
                if st == 1;disp(['WARNING: ContrastWeight ' num2str(i) ' is to short! Filled last Elements with zeros: ' mat2str(twottest.contrastWeights{i})]);end
                if strcmp(twottest.contrastType,'t')
                    matlabbatch = jpa_addTContrast(matlabbatch, twottest.contrastNames{i},twottest.contrastWeights{i},twottest.contrastRep{i});
                end
                if strcmp(twottest.contrastType,'f')
                    matlabbatch = jpa_addTContrast(matlabbatch, twottest.contrastNames{i},twottest.contrastWeights{i},twottest.contrastRep{i});
                end
            end
            if twottest.Fstandard
                % add StandardContrast
                [sName sWeight sRep] = jpa_getStandardFContrast(length(twottest.numberOfGrp));
                for j=1:1:length(sName)
                    matlabbatch = jpa_addFContrast(matlabbatch, sName{j},sWeight{j},sRep{j});
                end
            end
        else % can not run Contrast Manager without Model estimation
            disp('Model estimation-Module not activated. skipping Contrast Manager ...');
        end
    end
    % run spm_jobman
    if twottest.run_batch
        spm_jobman('run',matlabbatch);
    end
    % save matlabbatch
    if twottest.dosavebatch
        twottest.excludeList = [twottest.excludeList ids(~idsFound)'];
        twottest.includeList = unique(twottest.includeList);
        jpa_writeArrayToTxt([twottest.analysis, filesep, excludeListFilename '.txt'], twottest.excludeList, 'v' );
        jpa_writeArrayToTxt([twottest.analysis, filesep, includeListFilename '.txt'], twottest.includeList, 'v' );
        jpa_writeArrayToTxt([twottest.analysis, filesep, 'usedSubjectList.txt'], twottest.subjectList, 'v' );
        save([twottest.analysis,filesep,'matlabbatch.mat'],'matlabbatch');
        save([twottest.analysis,filesep,'twottest.mat'],'twottest');
    end
end
% eval results
if twottest.evalResults
    [current_sig_resultsWB  current_sig_resultsROI] = jpa_evalResults(twottest.analysis, twottest.evalResAtlas,twottest.evalResROI,'twottest', twottest.evalResPValue, twottest.evalResThreshold);
    % write sigResults of current twottest
    jpa_writeResults(current_sig_resultsWB, [twottest.analysis filesep 'results' filesep 'sig_resultsWB.txt']);
    jpa_writeResults(current_sig_resultsROI, [twottest.analysis filesep 'results' filesep 'sig_resultsROI.txt']);
    % get all sigResults of all twottest and fill them with sigRes of current twottest
    twottest_all_sig_resultsWB = jpa_getAllResults([twottest.base_dir_twottest 'twottest_all_sig_resultsWB.mat'],current_sig_resultsWB);
    twottest_all_sig_resultsROI = jpa_getAllResults([twottest.base_dir_twottest 'twottest_all_sig_resultsROI.mat'],current_sig_resultsROI);
    % save them as .mat
    save([twottest.base_dir_twottest 'twottest_all_sig_resultsWB.mat'],'twottest_all_sig_resultsWB')
    save([twottest.base_dir_twottest 'twottest_all_sig_resultsROI.mat'],'twottest_all_sig_resultsROI')
    % write them as .txt
    jpa_writeResults(twottest_all_sig_resultsWB, [twottest.base_dir_twottest 'twottest_all_sig_resultsWB.txt']);
    jpa_writeResults(twottest_all_sig_resultsROI, [twottest.base_dir_twottest 'twottest_all_sig_resultsROI.txt']);
end
end
%------------- END CODE --------------