function file = jpa_loadTxtToArray(pathToFile)
% function that loads a TXT-file and returns the lines in a String-Array
%
% Syntax:  file = jpa_loadTxtToArray(pathToFile)
%
% Inputs:
%    pathToFile - Full Path to a .txt file to be loaded
%
% Outputs:
%    file       - String-Array containing the loaded .txt where a row in
%                   .txt is a cell in Array
%
% Example:
%    file = jpa_loadTxtToArray('C:\example\examplefile.txt')
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
% Sep 2015; Last revision: 14-Okt-2015

%------------- BEGIN CODE --------------

% load file
try
    inFile = fopen(pathToFile, 'r+');
catch err
    error(['Could not open file in path ' pathToFile ' because of reason:' ...
        err.message])
end
% read lines
counter = 1;
while ~feof(inFile)
    file{counter} = fgetl(inFile);
    counter = counter +1;
end
end
%------------- END CODE --------------