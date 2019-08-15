% Skript that searches all Files with a certain regular expression
% in subfolders of baseDir.
% All found matches will be filtered with a IncludeList
% Include List could be a .txt file containing all names to be filtered for
%
pathToIncludeList = '';
% where would you like to start to search:
% Example: 'C:\'
baseDir = 'C:\';
% what would you like to find? regular Expressions are allowed!
% Example: '[0-9]*.txt' --> searches for every .txt whose name contains
% only numbers
searchPath = '[0-9]*.txt';
% get all matches
match = jpa_getDirs(baseDir, searchPath);
% load inlcudeList
includeList = jpa_loadTxtToArray(pathToIncludeList);
% filter matches 
res = strfind(match, includeList);
% display results
res


