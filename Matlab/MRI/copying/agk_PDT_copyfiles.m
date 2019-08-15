% PIPELINE FOR RUNNING PREPROCESSING AND 1st LEVEL

% Author: Alexander Genauck
% Work address:
% email: alexander.genauck@charite.de
% Website:
% Feb 2016; Last revision: 28-09-2017

%------------- BEGIN CODE --------------
clear all
clear classes
%% ############### Generell Settings ###############
% User-name
comp_name = getenv('USERNAME');
% add my lib
% start_up
addpath(genpath('C:\Users\agemons\Google Drive\Library\MATLAB'))
% where are the subject folders with MRI data?
base_dir_pl = 'I:\data';
%base_dir_lib = 'E:\Google Drive\Library\MATLAB';
base_dir_lib = 'C:\Users\agemons\Google Drive\Library\MATLAB';
% load SPM
which_spm(12,comp_name,1)
% what atlas to use for extraction
cur_atlas   = 'C:\Program Files\spm12\tpm\labels_Neuromorphometrics.xml';

% what to run?
cpe        = 1; % copy epis to hard disk


%% ############### copy epis #####################
% for loop for getting into folders
if cpe
    cd(base_dir_pl);
    all_subf = cellstr(ls('VPPG*'));  %list folders starting w vppg
    target_dir = 'L:\data';
    which_folders = {'*epi*','*MoCoSeries', '*Fieldmap*','*MPRAGE*'}; % patterns to know which folders
    for ii = 10:length(all_subf)
        % report
        disp(['I am at subject ' all_subf{ii}])
        
        cd(base_dir_pl);
        cur_sub     = fullfile(base_dir_pl,all_subf{ii});
        cur_sub_tar = fullfile(target_dir,all_subf{ii}); 
        cd(cur_sub);
        
        % copy non-MRI first
        try
            copyfile(fullfile(cur_sub,'Behav'),fullfile(cur_sub_tar,'Behav'))
        catch
        end
        try
            copyfile(fullfile(cur_sub,'Moco'),fullfile(cur_sub_tar,'Moco'))
        catch
        end
        try
            copyfile(fullfile(cur_sub,'Physio'),fullfile(cur_sub_tar,'Physio'))
        catch
        end
        
        % copy Versuchsprotokoll
        cur_V_files = cellstr(ls('Versuchsp*'));
        for vv = 1:length(cur_V_files)
           cur_src = fullfile(cur_sub,cur_V_files{vv});
           cur_trg = fullfile(cur_sub_tar,cur_V_files{vv});
           copyfile(cur_src,cur_trg)
        end
        
        % MRI start
        cd(cur_sub);
        cd(fullfile('MRT','NIFTI','PDT'));
        cur_sub_MRI = pwd;
        mkdir(fullfile(cur_sub_tar,fullfile('MRT','NIFTI','PDT')));
        
        % MRI Fieldmaps
        cur_fm = cellstr(ls('*Fieldmap*'));
        for ff = 1:length(cur_fm)
            cur_src = fullfile(pwd,cur_fm{ff});
            cur_trg = fullfile(cur_sub_tar,fullfile('MRT','NIFTI','PDT'),cur_fm{ff});
            copyfile(cur_src,cur_trg)
        end
        
        % MRI MPRAGE
        cd(cur_sub_MRI)
        cd('..')
        cur_src = fullfile(pwd,'MPRAGE');
        cur_trg = fullfile(cur_sub_tar,fullfile('MRT','NIFTI'),'MPRAGE');
        copyfile(cur_src,cur_trg)
        
        % MRI epis
        cd(cur_sub_MRI)
        cur_epi_dirs = [cellstr(ls('*epi*'));cellstr(ls('*MoCoSeries'))];
        
        disp('copying epis...')
        for ee = 1:numel(cur_epi_dirs)
            cd(cur_sub_MRI)
            if ~isempty(cur_epi_dirs{ee})
                cur_tar_epi_dir = fullfile(cur_sub_tar,fullfile('MRT','NIFTI','PDT'),cur_epi_dirs{ee});
                mkdir(cur_tar_epi_dir)
                cd(cur_epi_dirs{ee})
                epis_to_cp = [cellstr(ls('epi*.nii'));cellstr(ls('dcmHeader*'))];
                
                for pp = 1:numel(epis_to_cp)
                    disp(['I am at subject ' all_subf{ii}])
                    cur_src = fullfile(pwd,epis_to_cp{pp});
                    cur_trg = fullfile(cur_tar_epi_dir,epis_to_cp{pp});
                    
                    cur_cmd = ['copy ' '/Y ' cur_src ' ' cur_trg];
                    system(cur_cmd);
                    %copyfile(cur_src,cur_trg,'f')
                end 
            end
        end
    end
end
