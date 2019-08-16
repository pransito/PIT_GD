% home pwd results 2nd level
cur_home = ['L:\data\results_2nd_level\twottest\groupstats__MRT_\' ...
    '_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_sm_orth_ngm_'];

% second level PDT
cur_atlas   = 'C:\Program Files\spm12\tpm\labels_Neuromorphometrics.xml';

% compname
comp_name = getenv('USERNAME');

% params
thr_p       = 0.001;
thr_k       = 0    ;

% results_ base dir
res_base_dir = 'L:\data\results_2nd_level\twottest\groupstats__MRT_';
res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_ngm','\');

% NOI (second EOI is F-Test whole group)
ROI      = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_ss_model\combined\PDT_NOI.nii'];
pSPM{1}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxAccXgam\SPM.mat');
pSPM{2}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxAccXneg\SPM.mat');
pSPM{3}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxAccXpos\SPM.mat');
pSPM{4}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.gam\SPM.mat');
pSPM{5}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.neg\SPM.mat');
pSPM{6}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.pos\SPM.mat');
pSPM{7}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxAccXgam\SPM.mat');
pSPM{8}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxAccXneg\SPM.mat');
pSPM{9}  = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxAccXpos\SPM.mat');
pSPM{10} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.gam\SPM.mat');
pSPM{11} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.neg\SPM.mat');
pSPM{12} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.pos\SPM.mat');

NOI_all_sig_results = agk_master_eval_results_v3(pSPM,ROI,ROI,cur_atlas,thr_p,thr_k);
% PUTAMEN: HC > PG AccXpos survives with covariates; including ME 
% lots of EOIs

% gPPI second level
% VS --> Amy (Charpentier)
ROI     = {};
ROI{1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Amygdala.nii'];
ROI{2}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Amygdala.nii'];
pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 
pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 

vs_amy_all_sig_res{1} = agk_master_eval_results_v3(pSPM,ROI{1},ROI{1},cur_atlas,thr_p,thr_k);
vs_amy_all_sig_res{2} = agk_master_eval_results_v3(pSPM,ROI{2},ROI{2},cur_atlas,thr_p,thr_k);
% only EOIs

% gPPI second level
% Amy --> VS
ROI     = {};
ROI{1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Accumbens Area.nii'];
ROI{2}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Accumbens Area.nii'];
pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 
pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 

amy_vs_all_sig_res{1} = agk_master_eval_results_v3(pSPM,ROI{1},ROI{1},cur_atlas,thr_p,thr_k);
amy_vs_all_sig_res{2} = agk_master_eval_results_v3(pSPM,ROI{2},ROI{2},cur_atlas,thr_p,thr_k);
% only one EOI

% % gPPI second level [NEW!!] [new extracts: new glmnet and SVM?; not in paper; not in SVM glmnet]
% % Amy --> Putamen
% ROI     = {};
% ROI{1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Putamen.nii'];
% ROI{2}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Putamen.nii'];
% pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
% pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
% pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 
% pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');  
% pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');  
% pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat'); 
% 
% amy_put_all_sig_res{1} = agk_master_eval_results_v3(pSPM,ROI{1},ROI{1},cur_atlas,thr_p,thr_k);
% amy_put_all_sig_res{2} = agk_master_eval_results_v3(pSPM,ROI{2},ROI{2},cur_atlas,thr_p,thr_k);

% Amy --> OFC
cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets'])
ROI = cellstr(ls('*OrG*'));
ROI = strcat(pwd,'\',ROI);
ROI = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
cd(fullfile(res_base_dir,res_mid_dir))
cd('_PPI_Left_Amygdala_')
pSPM = cellstr(ls('*gam.onxaccX*'));
pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
cd('..')
cd('_PPI_Right_Amygdala_')
pSPM_2 = cellstr(ls('*gam.onxaccX*'));
pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
pSPM = [pSPM;pSPM_2];

for rr = 1:length(ROI)
    amy_ofc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
end
% ONLY HC<PG, left amy to R post orbital gyrus for accXneg
% but there seems to be some caudate!

% % VS --> MPFC
% cd('C:\Users\agemons\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded')
% ROI_1 = cellstr(ls('*MFC*'));
% ROI_2 = cellstr(ls('*MSFG*'));
% ROI   = [ROI_1;ROI_2];
% ROI   = strcat(pwd,'\',ROI);
% ROI   = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
% cd(fullfile(res_base_dir,res_mid_dir))
% cd('_PPI_Left_Accumbens_')
% pSPM = cellstr(ls('*gam.onxaccX*'));
% pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
% cd('..')
% cd('_PPI_Right_Accumbens_')
% pSPM_2 = cellstr(ls('*gam.onxaccX*'));
% pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
% pSPM = [pSPM;pSPM_2];
% 
% for rr = 1:length(ROI)
%     vs_mpfc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
% end
% 
% % Amy --> MPFC
% cd('C:\Users\agemons\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded')
% ROI_1 = cellstr(ls('*MFC*'));
% ROI_2 = cellstr(ls('*MSFG*'));
% ROI   = [ROI_1;ROI_2];
% ROI   = strcat(pwd,'\',ROI);
% ROI   = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
% cd(fullfile(res_base_dir,res_mid_dir))
% cd('_PPI_Left_Amygdala_')
% pSPM = cellstr(ls('*gam.onxaccX*'));
% pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
% cd('..')
% cd('_PPI_Right_Amygdala_')
% pSPM_2 = cellstr(ls('*gam.onxaccX*'));
% pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
% pSPM = [pSPM;pSPM_2];
% 
% for rr = 1:length(ROI)
%     amy_mpfc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
% end
% 
% % Amy --> midbrain
% cd('C:\Users\agemons\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded')
% ROI = cellstr(ls('*midbrain*'));
% ROI = strcat(pwd,'\',ROI);
% ROI = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
% cd(fullfile(res_base_dir,res_mid_dir))
% cd('_PPI_Left_Amygdala_')
% pSPM = cellstr(ls('*gam.onxaccX*'));
% pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
% cd('..')
% cd('_PPI_Right_Amygdala_')
% pSPM_2 = cellstr(ls('*gam.onxaccX*'));
% pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
% pSPM = [pSPM;pSPM_2];
% 
% for rr = 1:length(ROI)
%     amy_midbrain_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
% end

% save the results
cd(cur_home)
%save('results_second_level_NGM_001_0.mat','amy_midbrain_all_sig_res', ...
%    'amy_mpfc_all_sig_res','vs_mpfc_all_sig_res', ...
%    'amy_ofc_all_sig_res','vs_amy_all_sig_res','NOI_all_sig_results')

save('results_second_level_NGM_001_0.mat', ...
    'amy_ofc_all_sig_res','vs_amy_all_sig_res','vs_amy_all_sig_res','NOI_all_sig_results')

