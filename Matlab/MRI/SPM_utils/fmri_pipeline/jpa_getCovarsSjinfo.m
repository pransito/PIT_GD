function [ids, grp, covarsc, covNotEmpty] = jpa_getCovarsSjinfo(sjinfo, covarNames, varargin)
% Function that loads substructures from sjinfo-Struct,
% returning the ID-Vector, the Group-Vector, all loaded covariates and a
% logical vector showing which covariate was loaded. if function is called
% with two arguments it will search for the ids and groups with the default
% values.
%
% Syntax:
%    jpa_getCovarsSjinfo(sjinfo, covarNames[, subStructToSTID, subStructToGrps])
%
% Inputs:
%    sjinfo                 - sjinfo-Struct
%    covarNames             - names of covariates to load
%    substructToIDs         - "path" to ID-vector in sjinfo
%    substructToGrps        - "path" to grp-vector in sjinfo
%
% Outputs:
%    ids                - ID-string-vector, containing the IDs of all Subjects
%    grp                - Grp-string-vector, containing the GrpName of all Subjects
%    covarsc            - NxM-string-vector, containtng all loaded covariates
%    covNotEmpty        - logical-vector, showing which Covariate could be
%                           loaded
%
% Example:
%     jpa_getCovarsSjinfo(sjinfo, {'cov1 ''cov2'})
%       subStructToSTID is default: sjinfo.KAP.STID
%       subStructToGrps is default: sjinfo.KAP.PK
%       -> output: {'1' '2' '3'}, {'Grp1' 'Grp2' 'Grp2'},
%                       {[value1cov1, value2cov1, ...],
%                       [value1cov2, value2cov2, ...]}
%
%     jpa_getCovarsSjinfo(sjinfo, {'cov1 ''cov2'}, 'A.IDs','B.Grps')
%       -> output: {'1' '2' '3'}, {'Grp1' 'Grp2' 'Grp2'},
%                       {[value1cov1, value2cov1, ...],
%                       [value1cov2, value2cov2, ...]}
%
% Other m-files required: jpa_getSubstruct
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_getSubstruct

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------



%% Check for Input Arguments
if nargin < 2
    error('Wrong number of arguments. Could not get Covariates')
elseif nargin == 2
    subStructToSTID = '';
    subStructToGrps = '';
elseif nargin == 3
    subStructToSTID = varargin{1};
    subStructToGrps = '';
elseif nargin == 4
    subStructToSTID = varargin{1};
    subStructToGrps = varargin{2};
end
if ~isstruct(sjinfo)
    error('Structure of sjinfo is wrong');
end

%% Initialize
numbOfCov = length(covarNames);
covarsc = cell(1,numbOfCov);
covNotEmpty = false(numbOfCov,1);


%% get STID and Grp
try
    % get STID
    if strcmp(subStructToSTID , '') % do recursive search
        ids = jpa_getSubstruct(sjinfo, 'STID');
        if isempty(ids); error('Could not find STID!');end
    else % try to read given subStruct
        ids = sjinfo;
        subStructToSTID = textscan(subStructToSTID,'%s','delimiter','.');
        subStructToSTID = subStructToSTID{1,1};
        for i=1:1:length(subStructToSTID)
            ids = ids.(subStructToSTID{i});
        end
    end
    % get PK
    if strcmp(subStructToGrps , '') % do recursive search
        grp = jpa_getSubstruct(sjinfo, 'PK');
        if isempty(grp); error('Could not find PK!');end
    else % try to read given subStruct
        grp = sjinfo;
        subStructToGrps = textscan(subStructToGrps,'%s','delimiter','.');
        subStructToGrps = subStructToGrps{1,1};
        for i=1:1:length(subStructToGrps)
            grp = grp.(subStructToGrps{i});
        end
    end
catch ME
    % could not get STID or PK
    disp(ME.identifier);
    error('Structure of sjinfo is wrong!');
end
% convert to Strings if necessary
if isa(ids, 'numeric')
    ids = textscan(sprintf('%i\n',ids'),'%s');
    ids = ids{1};
end
if isa(grp, 'numeric')
    grp = textscan(sprintf('%i\n',grp'),'%s');
    grp = grp{1};
end
% convert to vertical vector if necessary
[a, b] = size(ids);
if b>a
    ids = transpose(ids);
end
[a, b] = size(grp);
if b>a
    grp = transpose(grp);
end
% convert to cellstr if necessary
if ~iscell(grp)
    grp = cellstr(grp);
end

%% get Covariates
% Loop through all Covariates
for i=1:length(covarNames)
    % check if field exists
    cov = jpa_getSubstruct(sjinfo, covarNames{i});
    if  ~isempty(cov)
        covarsc{i} = cov;
        covNotEmpty(i) = true;
    else % if not -> skip
        disp(strcat('WARNING: Covariate "',covarNames{i},'" does not exist! Skipping...'));
    end
end

end
%------------- END CODE --------------