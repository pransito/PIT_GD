function [minVal maxVal] = jpa_getIntensityValues(pathToNifti)
% function that loads a NIFTI-file and returns the Maximum and Minimum value

% load NIFTI to Matrix
header = spm_vol(pathToNifti);
A = spm_read_vols(header);
% get Maximum of Matrix
[maxVal,] = max(A(:));
% get Minimum of Matrix
[minVal,] = min(A(:));
end