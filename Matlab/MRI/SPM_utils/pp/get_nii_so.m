function slice_order = get_nii_so(fMRIname)

slice_order = 0; % Set 0 to autodetect

%these are the possible slice_orders http://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h
kNIFTI_SLICE_UNKNOWN  = 0; %AUTO DETECT
kNIFTI_SLICE_SEQ_INC  = 1; %1,2,3,4
kNIFTI_SLICE_SEQ_DEC  = 2; %4,3,2,1
kNIFTI_SLICE_ALT_INC  = 3; %1,3,2,4 Siemens: interleaved with odd number of slices, interleaved for other vendors
kNIFTI_SLICE_ALT_DEC  = 4; %4,2,3,1 descending interleaved
kNIFTI_SLICE_ALT_INC2 = 5; %2,4,1,3 Siemens interleaved with even number of slices
kNIFTI_SLICE_ALT_DEC2 = 6; %3,1,4,2 Siemens interleaved descending with even number of slices

[pth,nam,ext,vol] = spm_fileparts(deblank(fMRIname(1,:)));
fMRIname1 = fullfile(pth,[ nam, ext]); %'img.nii,1' -> 'img.nii'
if slice_order == 0 %attempt to autodetect slice order
    fid = fopen(fMRIname1);
    fseek(fid,122,'bof');
    slice_order = fread(fid,1,'uint8');
    fclose(fid);
    if (slice_order > kNIFTI_SLICE_UNKNOWN) && (slice_order <= kNIFTI_SLICE_ALT_DEC2)
        fprintf('Auto-detected slice order as %d\n',slice_order);
    else
        fprintf('%s error: unable to auto-detect slice order. Please manually specify slice order or use recent versions of dcm2nii.\n');
        return;
    end;
end