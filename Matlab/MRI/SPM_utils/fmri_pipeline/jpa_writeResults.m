function jpa_writeResults(sig_res, pathToFile)
% Function that saves a sig_res Structure to a formatted Text-File under 
% pathToFile
%
% Syntax:
%    jpa_writeResults(sig_res, pathToFile)
%
% Inputs:
%     sig_res          - Matlab-Struct with a certain format
%     pathToFile       - path to a file to write output in
%
% Outputs:
%     .txt     - file under pathToFile with formatted output of sig_res-
%                   Structure
%
% Example:
%     jpa_writeResults(sig_res, 'C:\example\filename')
%       where sig_res:
%           .CFWE.dat           = []
%                .peakCoord     = {}
%                .label         = {}         
%           .CFDR.dat           = []
%                .peakCoord     = {}
%                .label         = {}
%           .PFWE.dat           = []
%                .peakCoord     = {}
%                .label         = {}
%           .pFDR.dat           = []
%                .peakCoord     = {}
%                .label         = {}
%
% Other m-files required: none
% Subfunctions: corrLength, dipsRes
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 13-Nov-2015

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

resIndex = 1;
% determine size of sig_res
[l,b] = size(sig_res);

% print out header
fprintf(outFile,'%s\t %s\t\t\t %s\t\t\t %s\t\t\t %s\n',' ', 'Cluster FWE results:',...
    'Cluster FDR results:', 'Peak FWE results:', 'Peak FDR results:') ;

% print out sub-Header
fprintf(outFile,'%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', 'Results for:', ...
    'Label:', 'PeakCoords:',  'p-Value:', ...
    'Label:', 'PeakCoords:',  'p-Value:', ...
    'Label:', 'PeakCoords:',  'p-Value:', ...
    'Label:', 'PeakCoords:',  'p-Value:');

% loop through sig_res
for i=1:1:b
    % get length of all results
    [lCFWE, b] = size(sig_res(i).ClusterFWE.dat);
    [lCFDR, d] = size(sig_res(i).ClusterFDR.dat);
    [lPFWE, b] = size(sig_res(i).PeakFWE.dat);
    [lPFDR, h] = size(sig_res(i).PeakFDR.dat);
    % get max-rows
    maxl = max([lCFWE lCFDR lPFWE lPFDR]);
    % print out which results
    fprintf(outFile,'%s', [sig_res(i).type ': in ' sig_res(i).name ...
        ' for ' sig_res(i).con ':']);
    % print out data
    for j = 1:1:maxl
        [label, peak, dat] = dipsRes(sig_res(i).ClusterFWE, resIndex, lCFWE);
        fprintf(outFile,'%s\t %s\t %s\t %s\t ', ' ',label, peak, dat);
        [label, peak, dat] = dipsRes(sig_res(i).ClusterFDR, resIndex, lCFDR);
        fprintf(outFile,'%s\t %s\t %s\t ', label, peak, dat);
        [label, peak, dat] = dipsRes(sig_res(i).PeakFWE, resIndex, lPFWE);
        fprintf(outFile,'%s\t %s\t %s\t ', label, peak, dat);
        [label, peak, dat] = dipsRes(sig_res(i).PeakFDR, resIndex, lPFDR);
        fprintf(outFile,'%s\t %s\t %s\t\n', label, peak, dat);
        resIndex = resIndex +1;
    end
    % print out newline
    fprintf(outFile,'%s\n','');
    resIndex = 1;
end
fclose(outFile);
end

function [label, peak, dat] = dipsRes(sigResSubStruct, resIndex, len)
% Function that writes a SigRes Substruct to a given Index in a String

if isempty(sigResSubStruct)
    return;
end
% read data from index resIndex if resIndex < len
if resIndex <= len
    label = [sigResSubStruct.label{resIndex,1}];
    peak = '';
    for x=1:1:length(sigResSubStruct.peakCoord{resIndex,1})
        peak = [peak num2str(sigResSubStruct.peakCoord{resIndex,1}(x,1)) ' '];
    end
    dat = [num2str(sigResSubStruct.dat(resIndex,1))];
else
    label = '';
    peak = '';
    dat = '';
end
end

function [str, rest] = corrLength(str, leng)
% Function that corrects length of string to given a number. If str to
% short ' ' will be written at the end. Otherwise the string will be
% splittet in two parts

% Initialization
rest = '';
if length(str) > leng
    rest = str(leng+1: end);
    str = str(1:leng);
else
    str = [str repmat(' ',1,leng -length(str))];
end
end

%------------- END CODE --------------
