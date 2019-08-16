function agk_testing_pSPM_ROI(pSPM,ROI,reference)
% testing if SPMs exist
for pp = 1:length(pSPM)
    if ~exist(pSPM{pp},'file')
        error('unexisting pSPM')
    end
end

% testing if ROIs exist
for pp = 1:length(ROI)
    if ~exist(ROI{pp},'file')
        error('unexisting ROI')
    end
end

% testing if in right space
V    = spm_vol(reference);
for pp = 1:length(ROI)
    VROI = spm_vol(ROI{pp});
    if ~isequal(VROI.mat,V.mat)
        error('ROI not in space as reference.')
    end
end
end