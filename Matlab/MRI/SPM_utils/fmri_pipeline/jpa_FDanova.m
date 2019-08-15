function jpa_FDanova(anova)
% Function that does a spm anova with specified settings
%
% Syntax:
%    jpa_FDanova(anova)
%
% Inputs:
%    anova              - Struct with settings
%     .sjinfo           - Struct which defines Information about Subjects
%     .sjinfo.path      - Path to Struct which contains Information about Subjects
%     .sjinfo.IDs       - Substructure to IDs-Vector, defined as String
%     .sjinfo.Grps      - Substructure to Grps-Vector, defined as String
%     .FirstLVLModel    - Model-directory where the first level results are
%                           located
%     .con              - 1.st Level Contrast to be evaluated in anova
%     .conNames         - 1.st Level Contrast Name
%     .numberOfGrp      - the groupnumber of Subjects to be evalueted in
%                           anova
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
%     .Fstandard        - Boolean to enable Stadard-F-Contrasts
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
%     .independence     - Independence-Bit of anova
%     .variance         - Variance-Bit of anova
%     .grandMeanScaling - grand Mean Scaling-Bit
%     .anCova           - ancova-bit
%     .run_batch        - Enables spm_jobman
%     .est_model        - Enables Model Estimation
%     .con_man          - Enables Contrast Manager
%     .evalResults      - Enables evaluation of Model Estimation
%     .dosavebatch      - Enables Save of Batch and Information-Struct
%     .base_dir_anova   - Base dir where to save Outputs of anova results
%     .base_dir_pl      - Base dir where to find Subject scans
%
% Outputs:
%     spm_jobman outputs. For detailed explanation look at spm
%     documentation under http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf
%
% Example:
%     jpa_FDanova(anova)
%       where anova:
%     .sjinfo.path      = 'C:\example\sjinfo.mat'
%     .sjinfo.IDs       = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .sjinfo.Grps      = 'SUBSTRUCT1.SUBSTRUCT2.Vector'
%     .FirstLVLModel    = 'exampleFirstLevelModel'
%     .con              = {'con_0001','con_0002'}
%     .conNames         = {'1stLvlContrastName1','1stLvlContrastName2'}
%     .numberOfGrp      = {'1' '2' '3'}
%     .excludeList      = {'1001','2002'}
%     .excludeListPath  = 'C:\example\exampleExclude.txt'
%     .includeList      = {'1003','2004'}
%     .includeListPath  = 'C:\example\exampleInclude.txt'
%     .covarNames       = {'Age','EducationYears'}
%     .interaction      = [1 1]
%     .contrastType     = {'t','t'}
%     .contrastNames    = {'exampleContrast1','exampleContrast2'}
%     .contrastWeights  = {[2 -1 -1 ] [2 -1 -1]}
%     .contrastRep      = {'none','none'}
%     .Fstandard        = 1
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
%     .independence     = 0
%     .variance         = 1
%     .grandMeanScaling = 0
%     .anCova           = 0
%     .run_batch        = 1
%     .est_model        = 1
%     .con_man          = 1
%     .evalResults      = 1
%     .dosavebatch      = 1
%     .base_dir_anova   = 'C:\example\scans\results_2nd_level\anova'
%     .base_dir_pl      = 'C:\example\scans\'
%
%
% Other m-files required: jpa_getInitialienOfSting, jpa_reassembleCell,
%   jpa_initialFDAnova, jpa_addCovariates, jpa_initialFmriEst,
%   jpa_initialConMan, jpa_resizeColumsOfMat, jpa_getStandardFContrast,
%   jpa_addFContrast, spm_jobman, jpa_eval_results, jpa_getAllResults,
%   jpa_addTContrast
% Subfunctions: none
% MAT-files required: sjinfo
%
% See also: jpa_initialFDAnova, jpa_addCovariates, jpa_initialFmriEst,
%       jpa_initialConMan, jpa_addFContrast, jpa_eval_results,
%       jpa_addTContrast

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
anova = jpa_getSecndLvlDefaults(anova);
% Anova specific parameters
if  ~isfield(anova, 'independence')
    disp('independence not given! set to yes');
    anova.independence = 1;
end
if  ~isfield(anova, 'variance')
    disp('variance not given! set to unequal');
    anova.variance = 1;
end
if  ~isfield(anova, 'grandMeanScaling')
    disp('grandMeanScaling not given... set to 0');
    anova.grandMeanScaling = 0;
end
if  ~isfield(anova, 'anCova')
    disp('anCova-option not given... set to 0');
    anova.anCova = 0;
end
% contrastStandard
if  ~isfield(anova,'Fstandard')
    anova.Fstandard = false;
end


%% Preprocessing
% initialization
covNotEmpty = false(length(anova.covarNames),1);
if anova.run_batch || anova.est_model || anova.con_man
    % load Sjinfo
    try
        load(anova.sjinfo.path);
    catch ME
        disp(ME.identifier);
        error('Could not load sjinfo!');
    end
    % get covariates out of Sjinfo
    [ids, grp, covarsc, covNotEmpty] = jpa_getCovarsSjinfo(Sjinfo ,anova.covarNames, anova.sjinfo.IDs, anova.sjinfo.Grps);
end
% get Initialien of Covariaten to name the Folder
covIn = jpa_getInitialienOfSting(anova.covarNames(covNotEmpty));
if isempty(covIn) || strcmp(covIn{1,1},'')
    covIn{1,1} = 'noCov';
else
    covIn{1,1} = strcat('cov',covIn{1,1});
end
% make all numbers to one string
grpStr = '';
for i=1:1:length(anova.numberOfGrp)
    grpStr =  strcat(grpStr,anova.numberOfGrp{i});
end
if anova.run_batch || anova.est_model || anova.con_man
    % Load Exclude List
    if ~strcmp(anova.excludeListPath, '')
        [excludeListFilepath,excludeListFilename] = fileparts(anova.excludeListPath);
        anova.excludeListFile = jpa_loadTxtToArray(anova.excludeListPath);
        anova.excludeList = [anova.excludeList anova.excludeListFile];
    else
        excludeListFilename = 'excludeList';
    end
    % Load Include List
    if ~strcmp(anova.includeListPath, '')
        [includeListFilepath,includeListFilename] = fileparts(anova.includeListPath);
        anova.includeListFile = jpa_loadTxtToArray(anova.includeListPath);
        anova.includeList = [anova.includeList anova.includeListFile];
    else
        includeListFilename = 'includeList';
    end
    % empty Include-Lists are not allowed
    first = anova.includeList{1};
    if strcmp(first, '') || isempty(anova.includeList)
        anova.includeList = ids;
    end
end

%% Path calculation
% what do we search
anova.searchFor = strcat(anova.FirstLVLModel,filesep ,anova.con, '.nii');
% where do we save
anova.analysis  = strcat(anova.base_dir_anova, 'groupstats', '_', ...
    anova.FirstLVLModel, '_','grp', grpStr,...
    '_',covIn{1,1},'_', anova.conNames );
% make save-directory
if ~exist(anova.analysis,'dir'); mkdir(anova.analysis); end
anova.dirName = strcat('groupstats', '_', anova.FirstLVLModel,...
    '_','grp', grpStr,'_',covIn{1,1},'_', anova.conNames);

%% getCovariates and IDs ordered by group
if anova.run_batch || anova.est_model || anova.con_man
    disp(strcat('run anova in directory: ',anova.dirName))
    % search for con_img and get paths
    match = jpa_getDirs(anova.base_dir_pl,anova.searchFor);
    % get Logical Vectors which IDs will be part of the Test and which match
    % will be part of the test
    [logicalIDs, indMatch, idsFound] = jpa_getLogicalID(match, ids, anova.excludeList, anova.includeList);
    % initialize
    [b,l]= size(match);
    if b==0
        disp('WARNING: No Matches Found!');
    end
    covariates4EachGoup = cell(length(anova.covarNames),length(anova.numberOfGrp));
    anova.match2Group =  repmat({''},b,length(anova.numberOfGrp));
    anova.subjectList = repmat({''},length(logicalIDs),1);
    lengthSList = 0;
    % loop though all groups
    for ind=1:1:length(anova.numberOfGrp)
        % filter Vector where Grp is not the one we search for
        logicalGrp = strcmp(grp,anova.numberOfGrp{ind});
        logicalIDgroup = logicalIDs & logicalGrp;
        % get the covariates of the Subject
        for k=1:length(anova.covarNames)
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
                    anova.match2Group{indM2G,ind} = match{i,1};
                end
            end
        end
        % fill the ttest.subjectList for the current group
        anova.subjectList((lengthSList+1):lengthSList + length(ids(logicalIDgroup)),1) = ids(logicalIDgroup);
        lengthSList = lengthSList + length(ids(logicalIDgroup));
    end
    % order them for spm in right way
    anova.covariates = jpa_getCovVec(covariates4EachGoup);
    % filter the covarraites which has not been found
    anova.covariates = anova.covariates(covNotEmpty);
    
    %% Build & run batch
    % Initialize
    if anova.run_batch
        spm('defaults','fmri');
        spm_get_defaults('mask.thresh',anova.spm.spmMaskThresh);
        spm_jobman('initcfg');
    end
    matlabbatch = struct.empty;
    % set analysis folder
    factorial_design.dir = { anova.analysis };
    % set con-images in cells for each group
    factorial_design.des.anova.icell = struct.empty;
    % add Scans to factorial_design
    for i=1:1:length(anova.numberOfGrp)
        if ~isempty(anova.match2Group(:,i))
            factorial_design.des.anova.icell(i,1).scans = anova.match2Group(:,i);
        end
        
    end
    factorial_design.des.anova.dept = anova.independence;
    factorial_design.des.anova.variance = anova.variance;
    factorial_design.des.anova.gmsca = anova.grandMeanScaling;
    factorial_design.des.anova.ancova = anova.anCova;
    % build matlabbatch
    matlabbatch = jpa_initialFDAnova(matlabbatch, factorial_design);
    % build covariates
    anova.covarNames = anova.covarNames(covNotEmpty);
    anova.interaction = anova.interaction(covNotEmpty);
    for i=1:sum(covNotEmpty)
        matlabbatch = jpa_addCovariates(matlabbatch,anova.covariates{i},anova.covarNames{i},anova.interaction(i),1);
    end
    % model estimation
    if anova.est_model
        matlabbatch = jpa_initialFmriEst(matlabbatch);
    end
    % initalize contrast Manager Module
    if anova.con_man
        if anova.est_model
            matlabbatch = jpa_initialConMan(matlabbatch);
            for i=1:1:length(anova.contrastNames)
                [anova.contrastWeights{i} st] = jpa_resizeColumsOfMat(anova.contrastWeights{i},length(anova.numberOfGrp)+sum(covNotEmpty));
                if st == -1;disp(['WARNING: ContrastWeight '  num2str(i) ' is to long! Removed last Elements: ' mat2str(anova.contrastWeights{i})]);end
                if st == 1;disp(['WARNING: ContrastWeight ' num2str(i) ' is to short! Filled last Elements with zeros: ' mat2str(anova.contrastWeights{i})]);end
                if strcmp(anova.contrastType,'t')
                    matlabbatch = jpa_addTContrast(matlabbatch, anova.contrastNames{i},anova.contrastWeights{i},anova.contrastRep{i});
                end
                if strcmp(anova.contrastType,'f')
                    matlabbatch = jpa_addTContrast(matlabbatch, anova.contrastNames{i},anova.contrastWeights{i},anova.contrastRep{i});
                end
            end
            if anova.Fstandard
                % add StandardContrast
                [sName sWeight sRep] = jpa_getStandardFContrast(length(anova.numberOfGrp));
                for j=1:1:length(sName)
                    matlabbatch = jpa_addFContrast(matlabbatch, sName{j},sWeight{j},sRep{j});
                end
            end
        else % can not run Contrast Manager without Model estimation
            disp('Model estimation-Module not activated. skipping Contrast Manager ...');
        end
    end
    % run spm_jobman
    if anova.run_batch
        spm_jobman('run',matlabbatch);
    end
    % save matlabbatch
    if anova.dosavebatch
        anova.excludeList = [anova.excludeList ids(~idsFound)];
        anova.includeList = unique(anova.includeList);
        jpa_writeArrayToTxt([anova.analysis, filesep, excludeListFilename '.txt'], anova.excludeList, 'v' );
        jpa_writeArrayToTxt([anova.analysis, filesep, includeListFilename '.txt'], anova.includeList, 'v' );
        jpa_writeArrayToTxt([anova.analysis, filesep, 'usedSubjectList.txt'], anova.subjectList, 'v' );
        save([anova.analysis,filesep,'matlabbatch.mat'],'matlabbatch');
        save([anova.analysis,filesep,'anova.mat'],'anova');
    end
end
% eval results
if anova.evalResults
    [current_sig_resultsWB  current_sig_resultsROI] = jpa_evalResults(anova.analysis, anova.evalResAtlas,anova.evalResROI,'anova', anova.evalResPValue, anova.evalResThreshold);
    % write sigResults of current anova
    jpa_writeResults(current_sig_resultsWB, [anova.analysis filesep 'results' filesep 'sig_resultsWB.txt']);
    jpa_writeResults(current_sig_resultsROI, [anova.analysis filesep 'results' filesep 'sig_resultsROI.txt']);
    % get all sigResults of all anova and fill them with sigRes of current anova
    anova_all_sig_resultsWB = jpa_getAllResults([anova.base_dir_anova 'anova_all_sig_resultsWB.mat'],current_sig_resultsWB);
    anova_all_sig_resultsROI = jpa_getAllResults([anova.base_dir_anova 'anova_all_sig_resultsROI.mat'],current_sig_resultsROI);
    % save them as .mat
    save([anova.base_dir_anova 'anova_all_sig_resultsWB.mat'],'anova_all_sig_resultsWB')
    save([anova.base_dir_anova 'anova_all_sig_resultsROI.mat'],'anova_all_sig_resultsROI')
    % write them as .txt
    jpa_writeResults(anova_all_sig_resultsWB, [anova.base_dir_anova 'anova_all_sig_resultsWB.txt']);
    jpa_writeResults(anova_all_sig_resultsROI, [anova.base_dir_anova 'anova_all_sig_resultsROI.txt']);
end
end
%------------- END CODE --------------