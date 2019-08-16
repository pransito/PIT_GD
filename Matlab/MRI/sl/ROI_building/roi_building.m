cur_atlas   = 'C:\Program Files\spm12\tpm\labels_Neuromorphometrics.xml';
regions     = {'Putamen','Accumbens','Amygdala'};

generate_masks_from_atlas(cur_atlas, regions,pwd,'put.nii',0)
reference = 'L:\data\results_2nd_level\twottest\groupstats__MRT_\_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_sm_orth_ngm_\_grp01_noCov_Pic.pos\con_0002.nii';
all_nii   = cellstr(ls('*.nii'));
agk_nii_in_new_space(reference,all_nii,all_nii)

% make NOI
all_ROIs = cellstr(ls('*.nii'));
f        = 'sum(X)';
spm_imcalc(all_ROIs,'PDT_NOI.nii',f,{1})