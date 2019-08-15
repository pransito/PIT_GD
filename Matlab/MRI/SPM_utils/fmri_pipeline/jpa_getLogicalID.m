function [logID, indSearchIn, idsFound] = jpa_getLogicalID(searchIn, searchFor, varargin)
% Function that searches searchFor-Array in String-Array(searchIn).
% the function gives the a logical vector back which searchFor was found
% an the position in searchIn where searchFor was first found. IF SearchFor
% was not found Index will be set to 0
%
% Syntax:
%    jpa_getLogicalID(searchIn, searchFor[, excludeList, includeList])
%
% Inputs:
%     searchIn          - String-Array to search in
%     searchFor         - String-Array to searcFor
%     excludeList       - String-Array containing exclude-SearchFor
%     includeList       - String-Array containing include-SearchFor
%
% Outputs:
%     logID             - logical Array which SearchFor was found
%     indSearchIn       - Index where SearchFor was found in SearchIn
%     idsNotFound       - logical Array which shows the IDs which could not
%                           be found
%
% Example:
%     jpa_getLogicalID({'A' 'AB' 'C'}, {'A' 'C'})
%       -> output: [1 1 1] [1 3] [0 0]
%
%     jpa_getLogicalID({'A' 'AB' 'C'}, {'A' 'C'}, {'A'})
%       -> output: [0 0 1] [0 3] [0 0]
%
%     jpa_getLogicalID({'A' 'AB' 'C'}, {'A' 'D'}, {''}, {'A'})
%       -> output: [1 1 0] [1 0] [0 1]
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
% Sep 2015; Last revision: 13-Okt-2015

%------------- BEGIN CODE --------------

%% test input arguments
if nargin < 2
    error('Wrong number of Input-Arguments!');
elseif nargin ==2
    excludeList = {''};
    includeList = searchFor;
elseif nargin ==3
    excludeList = varargin{1};
    includeList = searchFor;
else
    excludeList = varargin{1};
    includeList = varargin{2};
end

%% Initialize
logID = false(length(searchFor),1);
idsFound = false(length(searchFor),1);
indSearchIn = zeros(length(searchIn),1);

%% Loop through searchFor
for indID=1:1:length(searchFor)
    %% search ID in searchIn
    cur_searchFor = ['\' searchFor{indID} '\'];
    res = strfind(searchIn,cur_searchFor);
    emptyCells = ~cellfun(@isempty,res);
    if sum(emptyCells) == 0
        continue;
    end
    % set the logical bit to true because we found the ID
    idsFound(indID) = true;
    
    %% search ID in exludeList
    if ~isempty(cell2mat(strfind(excludeList,searchFor{indID})))
        continue;
    end
    
    %% search ID in includeList
    if isempty(cell2mat(strfind(includeList,searchFor{indID})))
        continue;
    end
    
    %% case we found ID in searchIn
    % get index where we found ID in searchIn
    ind = find(not(cellfun('isempty',res)));
    if length(ind) > 1
        
        error('ID was found more than once!... Will not just take first occurence but stop! Make your indication of con image unique!')
    end
    % write at searchIn-found-position the Index of the ID
    indSearchIn(ind(1,1)) = indID;
    % set logical to true
    logID(indID) = true;
end
end
%------------- END CODE --------------