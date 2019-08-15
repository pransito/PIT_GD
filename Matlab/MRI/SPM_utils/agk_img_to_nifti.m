function [] = agk_img_to_nifti(file_img, file_nii)

V=spm_vol(file_img);
ima=spm_read_vols(V);
V.fname=file_nii;
spm_write_vol(V,ima);

end