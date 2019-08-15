function list = jpa_getDirs(baseDir,searchPath)
% Function that searches in a given Folder for a Subfolder with a certain
% file in it and gives the full-path back
%
% Syntax:
%    match = jpa_getDirs(baseDir, searchPath)
%
% Inputs:
%    baseDir     - Directory from where you start to search
%    searchPath  - subfolder(s) with filename to search for
%
% Outputs:
%    matches     - all matches of searchPath in baseDir
%
% Example:
%    match = jpa_getDirs('C:\basDirToSearchIn',
%                            'subfolder1\subfolder2\filename.ext')
%       -> Output:
%            'C:\basDirToSearchIn\XXX\subfolder1\subfolder2\filename.ext'
%            'C:\basDirToSearchIn\YYY\subfolder1\subfolder2\filename.ext'
%            'C:\basDirToSearchIn\YYY\AAA\subfolder1\subfolder2\filename.ext'
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
% Sep 2015; Last revision: 11-Sep-2015

%------------- BEGIN CODE --------------

% seperate searchpath in subfolder and file
[searchSub searchFile searchExt] = fileparts(searchPath);
searchFile = [searchFile searchExt];
% generate paths of all subfolder of baseDir
[c, list] = system(['cd /d ',baseDir,' & dir /b /s ' searchFile ]);
% seperate each path. take newLine as delemiter
list = textscan(list,'%s','delimiter','\n');
list = list{1,1};
% filter List if searchSub not empty
if ~strcmp(searchSub, '')
    if searchSub(length(searchSub)) ~= filesep
        searchSub = [searchSub filesep];
    end
    res = strfind(list, searchSub);
    % get logical vector
    res = ~cellfun(@isempty,res);
    % retun only these elements in list containing searchSub
    list = list(res);
    
end
end
%------------- END CODE --------------