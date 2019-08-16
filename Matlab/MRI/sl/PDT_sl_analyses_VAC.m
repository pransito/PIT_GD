% which ss model is base for this second level evaluation?
all_which_ss = 'vac';

% reference_image for size check and correction
reference = 'L:\data\VPPG0046\MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_glc\beta_0001.nii';

% compname
comp_name = getenv('USERNAME');

for ww = 1:length(all_which_ss)
    
    which_ss = all_which_ss{ww};
    % home pwd results 2nd level
    if strcmp(which_ss,'vac')
        cur_home = ['L:\data\results_2nd_level\twottest\groupstats__MRT_\' ...
            '_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_sm_orth_vac_'];
    elseif strcmp(which_ss,'val')
        cur_home = ['L:\data\results_2nd_level\twottest\groupstats__MRT_\' ...
            '_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_sm_orth_val_'];
    elseif strcmp(which_ss,'glc')
        cur_home = ['L:\data\results_2nd_level\twottest\groupstats__MRT_\' ...
            '_NIFTI_\_PDT_\_results_\_PDT_ss_design_DEZ_sm_orth_glc_'];
    else
        error('unknown which_ss')
    end
    
    % second level PDT
    cur_atlas   = 'C:\Program Files\spm12\tpm\labels_Neuromorphometrics.xml';
    
    % params
    thr_p       = 0.001;
    thr_k       = 0    ;
    
    % results_ base dir
    res_base_dir = 'L:\data\results_2nd_level\twottest\groupstats__MRT_';
    
    
    if strcmp(which_ss,'vac')
        res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_vac','\');
    elseif strcmp(which_ss,'val')
        res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_val','\');
    elseif strcmp(which_ss,'glc')
        res_mid_dir  = agk_privatize('NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_glc','\');
    else
        error('unknown which_ss')
    end
    
    % NOI (second EOI is F-Test whole group)
    ROI     = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_ss_model\combined\PDT_NOI.nii'];
    pSPM    = [];
    
    if strcmp(which_ss,'vac')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxVal\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxValXCra\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.gam\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.neg\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.pos\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxVal\SPM.mat');
        pSPM{7} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxValXCra\SPM.mat');
        pSPM{8} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.gam\SPM.mat');
        pSPM{9} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.neg\SPM.mat');
        pSPM{10} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.pos\SPM.mat');
    elseif strcmp(which_ss,'val')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.Onxval\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.Gam.OnxvalXpos\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.gam\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.neg\SPM.mat');
        pSPM{7} = fullfile(res_base_dir,res_mid_dir,'\_grp01_noCov_Pic.pos\SPM.mat');
        pSPM{8} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.Onxval\SPM.mat');
        pSPM{9} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{10} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{11} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.Gam.OnxvalXpos\SPM.mat');
        pSPM{12} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.gam\SPM.mat');
        pSPM{13} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.neg\SPM.mat');
        pSPM{14} = fullfile(res_base_dir,res_mid_dir,'\_grp01_covSmo_Pic.pos\SPM.mat');
    elseif strcmp(which_ss,'glc')
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
    else
        error('unknown which_ss')
    end
    
    % testing if SPMs exist
    for ll = 1:length(pSPM)
        load(pSPM{ll})
    end
    NOI_all_sig_results = agk_master_eval_results_v3(pSPM,ROI,reference,cur_atlas,thr_p,thr_k);
    
    % gPPI second level
    % VS --> Amy (Charpentier)
    pSPM    = [];
    ROI     = {};
    ROI{1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Amygdala.nii'];
    ROI{2}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Amygdala.nii'];
    
    if strcmp(which_ss,'vac')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxValXCra\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxValXCra\SPM.mat');
    elseif strcmp(which_ss,'val')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXpos\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.Gam.OnxvalXpos\SPM.mat');
        
    elseif strcmp(which_ss,'glc')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Accumbens_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat');
    else
        error('unknown which_ss')
    end
    
    vs_amy_all_sig_res{1} = agk_master_eval_results_v3(pSPM,ROI{1},reference,cur_atlas,thr_p,thr_k);
    vs_amy_all_sig_res{2} = agk_master_eval_results_v3(pSPM,ROI{2},reference,cur_atlas,thr_p,thr_k);
    
    % gPPI second level [NEW!!] [new extracts: new glmnet and SVM?; not in paper; not in SVM glmnet]
    % Amy --> VS
    % Amy --> PUTAMEN [NEW!!] [new extracts: new glmnet and SVM?; not in paper; not in SVM glmnet]
    pSPM    = [];
    ROI     = {};
    ROI{1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Accumbens Area.nii'];
    ROI{2}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Accumbens Area.nii'];
    ROI{3}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Putamen.nii'];
    ROI{4}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Putamen.nii'];
    
    if strcmp(which_ss,'vac')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxValXCra\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxValXCra\SPM.mat');
    elseif strcmp(which_ss,'val')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXpos\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXgam\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXneg\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.Gam.OnxvalXpos\SPM.mat');
    elseif strcmp(which_ss,'glc')
        pSPM{1} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');
        pSPM{2} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');
        pSPM{3} = fullfile(res_base_dir,res_mid_dir,'_PPI_Left_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat');
        pSPM{4} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXgam\SPM.mat');
        pSPM{5} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXneg\SPM.mat');
        pSPM{6} = fullfile(res_base_dir,res_mid_dir,'_PPI_Right_Amygdala_\_grp01_noCov_PPI_Pic.gam.onxaccXpos\SPM.mat');
    else
        error('unknown which_ss')
    end
    
    % run it
    amy_vs_all_sig_res{1} = agk_master_eval_results_v3(pSPM,ROI{1},reference,cur_atlas,thr_p,thr_k);
    amy_vs_all_sig_res{2} = agk_master_eval_results_v3(pSPM,ROI{2},reference,cur_atlas,thr_p,thr_k);
    amy_vs_all_sig_res{3} = agk_master_eval_results_v3(pSPM,ROI{3},reference,cur_atlas,thr_p,thr_k);
    amy_vs_all_sig_res{4} = agk_master_eval_results_v3(pSPM,ROI{4},reference,cur_atlas,thr_p,thr_k);
    
    % Amy --> OFC, mpfc, midbrain
    % ROIs
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets'])
    ROI = cellstr(ls('*OrG*'));
    ROI = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
    ROI = strcat(pwd,'\',ROI);
    
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded'])
    ROI_1 = cellstr(ls('*MFC*'));
    ROI_2 = cellstr(ls('*MSFG*'));
    ROI_mpfc = [ROI_1;ROI_2];
    ROI_mpfc   = strcat(pwd,'\',ROI_mpfc);
    ROI_mpfc   = ROI_mpfc(logical(cellfun(@isempty,strfind(ROI_mpfc,'_ns'))));
    
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded'])
    ROI_midbr = cellstr(ls('*midbrain*'));
    ROI_midbr = strcat(pwd,'\',ROI_midbr);
    ROI_midbr = ROI_midbr(logical(cellfun(@isempty,strfind(ROI_midbr,'_ns'))));
    
    ROI = [ROI;ROI_mpfc,ROI_midbr];
    
    % SPMs
    cd(fullfile(res_base_dir,res_mid_dir))
    cd('_PPI_Left_Amygdala_')
    
    if strcmp(which_ss,'vac')
        pSPM = [cellstr(ls('*Gam.OnxValX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'val')
        pSPM = [cellstr(ls('*Gam.OnxvalX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'glc')
        pSPM = cellstr(ls('*gam.onxaccX*'));
    else
        error('unknown which_ss')
    end
    
    pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
    cd('..')
    cd('_PPI_Right_Amygdala_')
    
    if strcmp(which_ss,'vac')
        pSPM_2 = [cellstr(ls('*Gam.OnxValX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'val')
        pSPM_2 = [cellstr(ls('*Gam.OnxvalX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'glc')
        pSPM_2 = cellstr(ls('*gam.onxaccX*'));
    else
        error('unknown which_ss')
    end
    
    pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
    pSPM = [pSPM;pSPM_2];
    
    for rr = 1:length(ROI)
        amy_ofc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},reference,cur_atlas,thr_p,thr_k);
    end
    
    % VS --> MPFC
    % ROIs
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded'])
    ROI_1 = cellstr(ls('*MFC*'));
    ROI_2 = cellstr(ls('*MSFG*'));
    ROI   = [ROI_1;ROI_2];
    ROI   = strcat(pwd,'\',ROI);
    ROI   = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
    cd(fullfile(res_base_dir,res_mid_dir))
    cd('_PPI_Left_Accumbens_')
    
    % SPMs
    if strcmp(which_ss,'vac')
        pSPM = [cellstr(ls('*Gam.OnxValX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'val')
        pSPM = [cellstr(ls('*Gam.OnxvalX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'glc')
        pSPM = cellstr(ls('*gam.onxaccX*'));
    else
        error('unknown which_ss')
    end
    
    pSPM = strcat(pwd,'\',pSPM,'\SPM.mat');
    cd('..')
    cd('_PPI_Right_Accumbens_')
    
    if strcmp(which_ss,'vac')
        pSPM_2 = [cellstr(ls('*Gam.OnxValX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'val')
        pSPM_2 = [cellstr(ls('*Gam.OnxvalX*'));cellstr(ls('*Pic.gam'));cellstr(ls('*Pic.neg'));cellstr(ls('*Pic.pos'))];
    elseif strcmp(which_ss,'glc')
        pSPM_2 = cellstr(ls('*gam.onxaccX*'));
    else
        error('unknown which_ss')
    end
    
    pSPM_2 = strcat(pwd,'\',pSPM_2,'\SPM.mat');
    pSPM = [pSPM;pSPM_2];
    
    for rr = 1:length(ROI)
        vs_mpfc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
    end
    
    % save the results
    cd(cur_home)
    cur_save_name = ['results_second_level_' which_ss '_001_0.mat'];
end


