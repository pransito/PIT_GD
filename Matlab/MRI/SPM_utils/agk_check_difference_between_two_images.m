% check the difference between image
% as fraction of mean signal within each voxel
V      = spm_vol_nifti('rsm0wrp1sBGG_1070-203519-00001-00176-1_res.nii');
V_no_r = spm_vol_nifti('spm12realism0wrp1sBGG_1070-203519-00001-00176-1_res.nii');
mean_signal_matrix_both = (spm_read_vols(V)+spm_read_vols(V_no_r))/2;
dist_signal_matrix = (spm_read_vols(V)-spm_read_vols(V_no_r));
dist_signal_matrix = abs(dist_signal_matrix)./mean_signal_matrix_both;
dist_signal_matrix(isnan(dist_signal_matrix)) = 0; 
mean_signal_diff = mean(mean(mean(dist_signal_matrix)));