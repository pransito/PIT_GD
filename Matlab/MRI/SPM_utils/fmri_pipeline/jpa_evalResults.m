function [all_sig_resultsWB, all_sig_resultsROI] = jpa_evalResults(pathSPM, atlas, ROI, varargin)
% Function that evaluates the results of the statistical tests in SPM
%
% Syntax:
%    res = jpa_eval_results(pathSPM, atlas, ROI)
%    res = jpa_eval_results(pathSPM, atlas, ROI [, type])
%    res = jpa_eval_results(pathSPM, atlas, ROI [, type, pValue])
%    res = jpa_eval_results(pathSPM, atlas, ROI [, type, pValue,threshold])
%
% Inputs:
%    pathSPM        - Path to SPM
%    atlas          - atlas-file which is used to label PeakCorrds of
%                       siginificant results
%    ROI            - Region of interest-file
%    pValue         - Pvalue
%    threshold      - Threshold
%    type           - type of analysis to be evaluated
%
% Outputs:
%    spm[...].nii    - thresholded .nii of Contrasts in SPM for FWE
%                      (Family-wise false positive rate ) and Uncorrected
%                      threshold
%           -> output will be in subfolder threshold of pathSPM
%
%    spm[...]TabDatWB.mat  - Struct which contains TabDat-Struct which is
%                            returned from SPM during calculation for whole
%                            brain analysis
%           -> output will be in subfolder results of pathSPM
%
%    spm[...]sigResWB.mat  - Struct which contains significant data of
%                            whole brain analysis for Cluster FWE, Cluster
%                            FDR, Peak FWE, Peak FDR. If no significant
%                            data is found theses structures will be empty.
%           -> output will be in subfolder results of pathSPM
%
%    spm[...]sigResRoi.mat - Struct which contains significant data of
%                            region of interest analysis for Cluster FWE,
%                            Cluster FDR, Peak FWE, Peak FDR.
%                            if no significant data is found theses
%                            structures will be empty.
%           -> output will be in subfolder results of pathSPM
%
%    spm[...]TabDatRoi.mat - Struct which contains TabDat-Struct which is
%                            returned from SPM during calculation for
%                            Region of Interest analysis
%           -> output will be in subfolder results of pathSPM
% Example:
%    res = jpa_eval_results('C:\example\','C:\example\atlas.xml','C:\example\roi.nii')
%    res = jpa_eval_results('C:\example\','C:\example\atlas.xml','C:\example\roi.nii','ttest')
%    res = jpa_eval_results('C:\example\','C:\example\atlas.xml','C:\example\roi.nii','ttest', 0.05)
%    res = jpa_eval_results('C:\example\','C:\example\atlas.xml','C:\example\roi.nii','ttest', 0.05,10)
%
% Other m-files required: jpa_getSigResults
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_getSigResults

% Author: Jan Albrecht, Alexander Genauck
% Work address: alexander.genauck@charite.de
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 21-Sep-2015

%------------- BEGIN CODE --------------

%% check for input parameters
if nargin == 3
    type = 'not specified';
    evalResPValue = 0.05;
    evalResThreshold = 10;
elseif nargin == 4
    type = 'not specified';
    evalResPValue = varargin{1};
    evalResThreshold = 10;
    
elseif nargin == 5
    type = 'not specified';
    evalResPValue = varargin{1};
    evalResThreshold = varargin{2};
    
else
    type = varargin{1};
    evalResPValue = varargin{2};
    evalResThreshold = varargin{3};
end

%% Load SPM && test settings
try
    SPM = struct.empty;
    load(fullfile(pathSPM,'SPM.mat'));
catch ME %catch me one more time!...
    disp(ME.identifier);
    error('Could not load SPM.mat!');
end

% Test for Estimation
if  ~isfield(SPM , 'xCon')
    disp('No Contrasts exists! Is Modell estimatet?');
    return;
end
% get length of Contrasts
length_numcon = length(SPM.xCon);
% Initalize all_sig_results
all_sig_resultsWB = struct.empty;
all_sig_resultsROI = struct.empty;
% define index for WB
indWB = 0;
% define index for ROI
indROI = 0;

%%  Loop through all Contrasts
for curNumcon=1:1:length_numcon
    %% ################## Initialisation ##################
    % xSPM      - structure containing SPM, distribution & filtering details
    xSPM.swd   = SPM.swd;
    xSPM.title = SPM.xCon(curNumcon).name;
    % .Z        - minimum of Statistics {filtered on u and k}
    xSPM.n     = 1;
    xSPM.STAT  = SPM.xCon(curNumcon).STAT;
    % .df       - degrees of freedom [df{interest}, df{residual}]
    % .STATstr  - description string
    xSPM.Ic    = curNumcon;
    % indices of masking contrasts (in xCon)
    xSPM.Im    = [];
    % .pm       - p-value for masking (uncorrected)
    % .Ex       - flag for exclusive or inclusive masking
    % p value uncorrected/whole brain
    xSPM.u     = evalResPValue;
    %extent threshold in voxels (cluster size minimum)
    xSPM.k     = evalResThreshold;
    % description
    xSPM.thresDesc = 'none';
    
    %% ################## whole brain analysis ##################
    % Extracting all voxels whose value is above a specified t-threshold
    % and safe in .nii
    % get xSPM
    [SPM, xSPM] = spm_getSPM(xSPM);
    % Add leading zeros to Number of Contrast
    try
        numconstr = strcat(num2str(zeros(1,4-length(num2str(curNumcon))),'%g'),num2str(curNumcon));
    catch US
        disp(['WARNING: Ivalid Contrast Number!',US.message, '... skipping contrast']);
        break;
    end
    % set path to current T or F-map
    cur_map = ['spm' SPM.xCon(curNumcon).STAT '_' numconstr];
    %%% get extension of T or F-map
    files = dir(xSPM.swd);
    % dont use direcotrys
    files = files(~[files.isdir]);
    % find filename & get index
    ind = strfind({files.name},cur_map);
    ind = find(not(cellfun('isempty',ind)));
    % take first File which was found
    if ~isempty(ind)
        cur_map_in = [xSPM.swd filesep files(ind(1,1)).name];
    else
        disp('WARNING: Ivalid T or F-map! ... skipping contrast');
        break;
    end
    % get output filename
    if strcmp(xSPM.thresDesc,['p<' num2str(evalResPValue) ' (unc.)'])
        cur_thr = [num2str(evalResPValue) 'unc'];
    else
        cur_thr = [num2str(xSPM.u) 'unc'];
    end
    % set output-file
    cur_map_out = [xSPM.swd filesep 'thresholded' filesep ...
        'spm' SPM.xCon(curNumcon).STAT '_' numconstr '_wb_' strrep(cur_thr,'.','')...
        '_' num2str(xSPM.k) '.nii'];
    % write file, remember: xSPM.u has been modified after initalisation
    % due to call of spm_getSPM(xSPM)! so don't use evalResPValue as
    % parameter!
    jpa_writeThresholdTmap(cur_map_in,cur_map_out,xSPM.u);
    % get TabDat (whole brain)
    TabDatWB = spm_list('Table',xSPM);
    % display results
    spm_list('txtlist',TabDatWB);
    % make results dir
    if ~exist([xSPM.swd filesep 'results'],'dir'); mkdir([xSPM.swd filesep 'results']); end
    if ~exist([xSPM.swd filesep 'results' filesep 'tabdat'],'dir'); mkdir([xSPM.swd filesep 'results' filesep 'tabdat']); end
    % set savePaths
    savePathTabdat = [ xSPM.swd filesep 'results' filesep 'tabdat' filesep SPM.xCon(curNumcon).STAT ...
        '_' numconstr '_wb_' strrep(cur_thr,'.','') '_' num2str(xSPM.k)];
    savePath = [ xSPM.swd filesep 'results' filesep SPM.xCon(curNumcon).STAT ...
        '_' numconstr '_wb_' strrep(cur_thr,'.','') '_' num2str(xSPM.k)];
    % save TabDat of Whole Brain
    save([ savePathTabdat 'TabDatWB.mat'] ,'TabDatWB');
    % get significant data of Whole Brain
    sigResWB = jpa_getSigResults(TabDatWB,atlas,evalResPValue,1,1,1,1);
    % save Significant Data
    save([ savePath 'sigResWB.mat'] ,'sigResWB');
    
    %% ################## ROI analysis ##################
    % prepare the ROI
    [a,b,c]=fileparts(ROI);
    if strcmp(c,'.img')
        ROIo = fullfile(a,[b '.nii']);
        agk_img_to_nifti(ROI,ROIo);
    else
        ROIo = ROI;
    end
    % make sure ROI is in right space
    try
        agk_nii_in_new_space(cur_map_out,cellstr(ROIo),cellstr(ROIo));
    catch UP
        disp(['Could not transform ROI! Reason:',UP.message ,' trying to proceed anyway...']);
    end
    % some parameters to be set up
    CustomParams.xyzmm    = [0 0 0];
    CustomParams.SPACE    = 'I';
    CustomParams.D        = ROIo;
    % get TabDat with ROI
    try
        [TabDatRoi, k] = agk_spm_VOI(SPM,xSPM,CustomParams);
        % display results
        spm_list('txtlist',TabDatRoi);
    catch WHAT%???
        disp(['Could not get Data from ROI! Reason:'  WHAT.message]);
        disp('Proceed with Whole Brain Analysis...');
        break;
    end
    % set savePaths
    savePathTabdat = [ xSPM.swd filesep 'results' filesep 'tabdat' filesep SPM.xCon(curNumcon).STAT ...
        '_' numconstr '_roi_' strrep(cur_thr,'.','') '_' num2str(xSPM.k)];
    savePath = [ xSPM.swd filesep 'results' filesep SPM.xCon(curNumcon).STAT ...
        '_' numconstr '_roi_' strrep(cur_thr,'.','') '_' num2str(xSPM.k)];
    % save TabDat
    save([ savePathTabdat 'TabDatRoi.mat'] ,'TabDatRoi');
    % get Data of ROI and save
    sigResRoi = jpa_getSigResults(TabDatRoi,atlas,evalResPValue,1,1,1,1);
    save([savePath 'sigResRoi.mat'] ,'sigResRoi');
    
    
    %% ################## set all_sig_results ##################
    % check for emptyness. if one is not empty we copy the results
    if ~isempty(sigResWB.cFWE.dat) || ~isempty(sigResWB.cFDR.dat) || ...
            ~isempty(sigResWB.pFWE.dat) || ~isempty(sigResWB.pFDR.dat)
        indWB = indWB +1;
        % get parent folder of pathSPM
        [k,parentfolder] = fileparts(pathSPM);
        all_sig_resultsWB(indWB).type = type;
        all_sig_resultsWB(indWB).name = parentfolder;
        all_sig_resultsWB(indWB).con = xSPM.title;
        all_sig_resultsWB(indWB).ClusterFWE = sigResWB.cFWE;
        all_sig_resultsWB(indWB).ClusterFDR = sigResWB.cFDR;
        all_sig_resultsWB(indWB).PeakFWE = sigResWB.pFWE;
        all_sig_resultsWB(indWB).PeakFDR = sigResWB.pFDR;
    end
    % check for emptyness. if one is not empty we safe the results
    if ~isempty(sigResRoi.cFWE.dat) || ~isempty(sigResRoi.cFDR.dat) || ...
            ~isempty(sigResRoi.pFWE.dat) || ~isempty(sigResRoi.pFDR.dat)
        indROI = indROI +1;
        % get parent folder of pathSPM
        [k,parentfolder] = fileparts(pathSPM);
        all_sig_resultsROI(indROI).type = type;
        all_sig_resultsROI(indROI).name = parentfolder;
        all_sig_resultsROI(indROI).con = xSPM.title;
        all_sig_resultsROI(indROI).ClusterFWE = sigResRoi.cFWE;
        all_sig_resultsROI(indROI).ClusterFDR = sigResRoi.cFDR;
        all_sig_resultsROI(indROI).PeakFWE = sigResRoi.pFWE;
        all_sig_resultsROI(indROI).PeakFDR = sigResRoi.pFDR;
    end
end
% save used ROI
jpa_writeArrayToTxt([xSPM.swd, filesep,'results', filesep, 'usedROI.txt'], {ROIo}, 'v' )
end
%------------- END CODE --------------
