function PDT_sl_analyses
% which ss model is base for this second level evaluation?
all_which_ss = {'vac','val','glc'};

% run it or just check for existance?
run_it = 1;

% reference_image for size check and correction
reference = 'L:\data\VPPG0046\MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_sm_orth_glc\beta_0001.nii';

% compname
comp_name = getenv('USERNAME');

% lib
base_dir_lib = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB'];
addpath(genpath(base_dir_lib))

parfor (ww = 1:length(all_which_ss),3)
    
    % init
    NOI_all_sig_results     = [];
    amy_ofc_all_sig_res     = [];
    vs_amy_mpfc_all_sig_res = [];
    
    NOI_done = 0;
    Amy_done = 0;
    VS_done  = 0;
    
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
    
    % NOI (second EOI is F-Test whole group) (Accumb, Putamen, Amygdala)
    ROI     = cellstr(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_ss_model\combined\PDT_NOI.nii']);
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
    
    % testing existance of pSPMs and ROIs
    agk_testing_pSPM_ROI(pSPM,ROI,reference)
    
    if run_it
        NOI_all_sig_results = agk_master_eval_results_v3(pSPM,ROI{1},reference,cur_atlas,thr_p,thr_k);
        % note down
        NOI_done = 1;
    end
    
    % gPPI second level
    % Amy --> VS, Putamen, OFC, mpfc, midbrain; PUTAMEN [NEW!!] [new extracts: new glmnet and SVM?; not in paper; not in SVM glmnet]
    % ROIs
    ROI_VS     = {};
    ROI_VS{1,1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Accumbens Area.nii'];
    ROI_VS{2,1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Accumbens Area.nii'];
    ROI_VS{3,1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded\Left Putamen.nii'];
    ROI_VS{4,1}  = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded\Right Putamen.nii'];
    
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets'])
    ROI = [];
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
    ROI_midbr = cellstr(ROI_midbr);
    
    ROI = [ROI_VS;ROI;ROI_mpfc;ROI_midbr];
    
    % SPMs
    pSPM = [];
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
    pSPM   = [pSPM;pSPM_2];
    
    % testing existance of pSPMs and ROIs
    agk_testing_pSPM_ROI(pSPM,ROI,reference)
    
    if run_it
        for rr = 1:length(ROI)
            amy_ofc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},reference,cur_atlas,thr_p,thr_k);
        end
        % note down
        Amy_done = 1;
    end
    

    
    % VS --> Amy (Charpentier)
    % VS --> MPFC
    % ROIs
    
    ROI_Amy      = {};
    ROI_Amy{1,1} = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Left Amygdala.nii'];
    ROI_Amy{2,1} = ['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\Right Amygdala.nii'];
    
    cd(['C:\Users\' comp_name '\Google Drive\Library\MATLAB\PDT\MRI\sl\ROIs\from_ext_HD\ROIs\ROIs_gPPI_targets\discarded'])
    ROI_1 = cellstr(ls('*MFC*'));
    ROI_2 = cellstr(ls('*MSFG*'));
    ROI   = [ROI_1;ROI_2];
    ROI   = strcat(pwd,'\',ROI);
    ROI   = ROI(logical(cellfun(@isempty,strfind(ROI,'_ns'))));
    ROI   = [ROI_Amy;ROI];
    
    % SPMs
    pSPM    = [];
    cd(fullfile(res_base_dir,res_mid_dir))
    cd('_PPI_Left_Accumbens_')
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
    
    % testing existance of pSPMs and ROIs
    agk_testing_pSPM_ROI(pSPM,ROI,reference)
    
    if run_it
        for rr = 1:length(ROI)
            vs_amy_mpfc_all_sig_res{rr} = agk_master_eval_results_v3(pSPM,ROI{rr},ROI{rr},cur_atlas,thr_p,thr_k);
        end
        % note down
        VS_done = 1;
    end

    
    if run_it
        % save the results
        cd(cur_home)
        cur_save_name = ['results_second_level_' which_ss '_001_0.mat'];
        varnames      = {'NOI_all_sig_results','amy_ofc_all_sig_res','vs_amy_mpfc_all_sig_res'};
        vars          = {NOI_all_sig_results,amy_ofc_all_sig_res,vs_amy_mpfc_all_sig_res};
        parsave(cur_save_name,varnames,vars)
    end
end


