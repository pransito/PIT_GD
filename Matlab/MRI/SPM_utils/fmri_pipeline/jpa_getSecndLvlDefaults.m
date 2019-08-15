function defaults = jpa_getSecndLvlDefaults(secLvlStruct)
% function that checks a input-struct of a second Lvl-spm-Analysis and sets
% default parameters. This is not specific to a certain
% secoundLvl-statistical Test. These function tests all values which are
% always needed for any kind of statistical ttest. If you use the
% return-Value of theses function for a specific statistical ttest (like
% anova) it might run into errors!
%
% Syntax:
%    defaults = jpa_getSecndLvlDefaults(secLvlStruct)
%
% Inputs:
%    secLvlStruct    - Struct with specific-settings
%
% Outputs:
%    defaults        - Struct with all the settings and fields in Input
%                           with default values for fields that doesn't
%                           exist in Input
%
% Example:
%     defaults = jpa_get2ndLvlDefaults(secLvlStruct)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 23-Okt-2015

%------------- BEGIN CODE --------------

%% check parts to run
if ~isfield(secLvlStruct, 'run_batch')
    secLvlStruct.run_batch = 0;
end
if  ~isfield(secLvlStruct, 'est_model')
    secLvlStruct.est_model = 0;
end
if   ~isfield(secLvlStruct, 'con_man')
    secLvlStruct.con_man = 0;
end
if   ~isfield(secLvlStruct, 'evalResults')
    secLvlStruct.evalResults = 0;
end
if   ~isfield(secLvlStruct, 'viewResults')
    secLvlStruct.viewResults = 0;
end
if   ~isfield(secLvlStruct, 'plotResults')
    secLvlStruct.plotResults = 0;
end

%% check generell settings
% CovarNames
if  ~isfield(secLvlStruct, 'covarNames') || isempty(secLvlStruct.covarNames)
    disp('no covarNames specified!');
    secLvlStruct.covarNames = {''};
    secLvlStruct.interaction = [];
end
% First-Level-Model
if  ~isfield(secLvlStruct, 'FirstLVLModel') || isempty(secLvlStruct.FirstLVLModel)
    disp('no model specified!');
    secLvlStruct.FirstLVLModel = '';
end
% groupNumber to run secLvlStruct for
if  ~isfield(secLvlStruct, 'numberOfGrp')
    error('no numberOfGrp specified!');
end


%% only check for option run_batch est_model con_man
if secLvlStruct.run_batch || secLvlStruct.est_model || secLvlStruct.con_man
    % sjinfo
    if  ~isfield(secLvlStruct, 'sjinfo')
        error('sjinfo Structure incorrect!');
    end
    if  ~isfield(secLvlStruct.sjinfo, 'path')
        error('sjinfo path is incorrect!');
    end
    if  ~isfield(secLvlStruct.sjinfo, 'IDs')
        secLvlStruct.sjinfo.IDs = '';
    end
    if  ~isfield(secLvlStruct.sjinfo, 'Grps')
        secLvlStruct.sjinfo.Grps = '';
    end
    % Contrast.nii
    if  ~isfield(secLvlStruct, 'con')
        error('no 1stLvl Contrast specified!');
    end
    if  ~isfield(secLvlStruct, 'conNames')
        disp(['no 1stLvl Contrast Name specified!... set Name to ' secLvlStruct.con ]);
        secLvlStruct.conNames = secLvlStruct.con;
    end
    % covarNames
    if  ~isfield(secLvlStruct, 'covarNames') || isempty(secLvlStruct.covarNames)
        disp('no covarNames specified!');
        secLvlStruct.covarNames = {''};
        secLvlStruct.interaction = [];
    else
        % Intercation between covariates
        if  ~isfield(secLvlStruct, 'interaction')
            disp('no interaction specified! Set to 1 (no interaction)');
            secLvlStruct.interaction = ones(1,length(secLvlStruct.covarNames));
        else
            % set missing cells to 1
            if length(secLvlStruct.interaction) ~= length(secLvlStruct.covarNames)
                secLvlStruct.interaction = [secLvlStruct.interaction ones(1,length(secLvlStruct.covarNames)-length(secLvlStruct.interaction))];
            end
        end
    end
    % contrastType
    if  ~isfield(secLvlStruct,'contrastType') || isempty(secLvlStruct.contrastType)
        secLvlStruct.con_man = 0;
    else
        % contrastNames
        if  ~isfield(secLvlStruct, 'contrastNames') || isempty(secLvlStruct.contrastNames)
            secLvlStruct.con_man = 0;
        else
            % contrastWeights
            if  ~isfield(secLvlStruct, 'contrastWeights') || isempty(secLvlStruct.contrastWeights)
                secLvlStruct.con_man = 0;
            else
                % contrastRep
                if  ~isfield(secLvlStruct, 'contrastRep')
                    % initialise
                    secLvlStruct.contrastRep = repmat({'none'},1,length(secLvlStruct.contrastNames));
                else
                    % set missing cells to 'none'
                    if length(secLvlStruct.contrastRep) ~= length(secLvlStruct.contrastNames)
                        [a,b] = size(secLvlStruct.contrastRep);
                        for i=(b+1):1:length(secLvlStruct.contrastNames)
                            secLvlStruct.contrastRep{i} = 'none';
                        end
                    end
                end
            end
        end
    end
    % excludeList
    if  ~isfield(secLvlStruct,'excludeList')
        secLvlStruct.excludeList = {''};
    end
    if  ~isfield(secLvlStruct,'excludeListPath')
        secLvlStruct.excludeListPath = '';
    end
    % includeList
    if  ~isfield(secLvlStruct,'includeList')
        secLvlStruct.includeList = {''};
    end
    if  ~isfield(secLvlStruct,'includeListPath')
        secLvlStruct.includeListPath = '';
    end
    % spm-settings
    if  ~isfield(secLvlStruct,'spm')
        secLvlStruct.spm.spmMaskThresh = 0.8;
    else
        if  ~isfield(secLvlStruct.spm,'spmMaskThresh')
            secLvlStruct.spm.spmMaskThresh = 0.8;
        end
    end
end
%% evaluate results
if secLvlStruct.evalResults
    if ~isfield(secLvlStruct,'evalResPValue')
    end
    if ~isfield(secLvlStruct,'evalResThreshold')
    end
    if ~isfield(secLvlStruct,'evalResROI')
    end
    if ~isfield(secLvlStruct,'evalResAtlas')
    end
end
%% view results
if secLvlStruct.viewResults
    if ~isfield(secLvlStruct,'mricroGLPath')
        error('path to Mircro GL not set!')
    end
    if ~isfield(secLvlStruct,'loadimage')
        error('no BG-Image load!')
    end
end
%% plot results
if secLvlStruct.plotResults
    if ~isfield(secLvlStruct,'plotPerRow')
        secLvlStruct.plotPerRow = 2;
    end
    if ~isfield(secLvlStruct,'plotPerCol')
        secLvlStruct.plotPerCol = 2;
    end
    if ~isfield(secLvlStruct,'picPerPage')
        secLvlStruct.picPerPage = [];
    end
    if ~isfield(secLvlStruct,'colorbarOn')
        secLvlStruct.colorbarOn = 0;
    end
    if ~isfield(secLvlStruct,'colSchem')
        secLvlStruct.colSchem = '';
    end
end
%% set defaults
defaults = secLvlStruct;
end