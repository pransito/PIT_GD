function jpa_writeArrayToTxt(pathToFile, stringArr, direction)
% function that writes a NxM-String-Array in a file under a specified
% direction. You can write out the NxM-String-Array vertical or horizontal.
%
% Syntax:  jpa_writeArrayToTxt(pathToFile, stringArr, direction)
%
% Inputs:
%    pathToFile - Full Path to a .txt wo be written to
%    stringArr  - String-Array to be written in file
%    direction  - direction where to read the String-Array,
%                   v = vertical, h = horizontal
%
% Outputs:
%    .txt       - .txt-file containing the fields of stringArr in a certain
%                   direcotion
%
% Example:
%    jpa_writeArrayToTxt('C:\example\examplefile.txt', 
%               {'line1', 'line2' ; 'line3', 'line4'}, 'v')
%       -> Output:  line1
%                   line3
%                   line2
%                   line4
%
%    jpa_writeArrayToTxt('C:\example\examplefile.txt', 
%               {'line1', 'line2' ; 'line3', 'line4'}, 'h')
%       -> Output:  line1
%                   line2
%                   line3
%                   line4
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address: alexander.genauck@charite.de
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 14-Okt-2015

%------------- BEGIN CODE --------------

% delete file if exist
if exist(pathToFile, 'file')
    delete(pathToFile)
end

% open file in txt-Mode
try
    outFile = fopen(pathToFile, 'wt');
catch err
    error(['Could not open file in path ' pathToFile ' because of reason:' ...
        err.message])
end

% get size of Input
[a,b] = size(stringArr);

% print out data
if strcmp(direction, 'h')
    for i=1:1:a
        for j=1:1:b
            fprintf(outFile, '%s\n', stringArr{i,j});
        end
    end
end
if strcmp(direction, 'v')
    for i=1:1:b
        for j=1:1:a
            fprintf(outFile,'%s\n', stringArr{j,i});
        end
    end
end
% close file
fclose(outFile);
end
%------------- END CODE --------------