function jpa_writeThresholdTmap(pathInputMap, pathOutputMap, threshold)
% Function that reads an Input map containing t or f-values from a
% statistical contrast and writes out a thresholded version of these Input
% in subfolder
%
% Syntax:  
%    jpa_writeThresholdTmap(pathInputMap, pathOutputMap, threshold)
%
% Inputs:
%    pathInputMap   - file with complete path where the T/F-Map is located
%    pathOutputMap  - file with complete path to write output
%    threshold      - threshold for filtering data
%
% Outputs:
%    map_supathresh  - T/F-Map with filtered values
%
% Example:
%    jpa_writeThresholdTmap('C:\example\con_0001.nii',
%               'C:\example\thresholded\con_0001.nii', 1.5)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:  

% Author: Jan Albrecht, Alexander Genauck
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

% Step 1:  Load spmT*.img which is a map containing t-values from a
% statistical contrast
try
    V = spm_vol(pathInputMap);
    Map = spm_read_vols(V);
catch ME
    disp(['Failed to load ' pathInputMap ' Reason:']);
    error(ME.identifier);
end
% Step 2:  Extract all voxels in TMap that are greater than tthresh
Map_suprathresh = Map;
Map_suprathresh(Map <= threshold) = 0;
% Step 3:  Write out TMap_suprathresh as its own image.
% seperate File from Path
[outPath,outFile,ext] = fileparts(pathOutputMap);
outFile = strcat(outFile,ext);
if ~exist(outPath,'dir'); mkdir(outPath); end
% set name
V.fname = outFile;
V.private.dat.fname = outFile;
% write
cd(outPath)
spm_write_vol(V,Map_suprathresh);
cd(fileparts(pathInputMap));
end
%------------- END CODE --------------