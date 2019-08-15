% PIPELINE FOR RUNNING ANALYSIS OF EDA DATA
% Author:           Alexander Genauck
% Work address:
% email:            alexander.genauck@charite.de
% Website:
% date:             24-09-2017
% Last revision:    04-10-2017

%% ############### CLEARING ########################
clear all
close all
clear classes

%% ############### Generell Settings ###############
% User-name
comp_name = getenv('USERNAME');

% add libraries
start_up
addpath('C:\Program Files\MATLAB\R2014a\toolbox\PSPM');

% base directory and other dirs
path_data      = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten';
base_dir       = fullfile(path_data,'PDT\pilot');
base_dir_PG    = fullfile(path_data,'PDT\PG');
base_dir_pp_PG = fullfile(path_data,'PDT\POSTPILOT\PG');
base_dir_pp_HC = fullfile(path_data,'PDT\POSTPILOT\HC');

% get the data paths
cd(base_dir)
subs = dir('PhysioVP*');
for gg = 1:length(subs)
    subs(gg).name = [base_dir filesep subs(gg).name];
end
cd(base_dir_PG)
subs_PG = dir('Physio*');
for gg = 1:length(subs_PG)
    subs_PG(gg).name = [base_dir_PG filesep subs_PG(gg).name];
end
cd(base_dir_pp_PG)
subs_pp_PG = dir('Physio*');
for gg = 1:length(subs_pp_PG)
    subs_pp_PG(gg).name = [base_dir_pp_PG filesep subs_pp_PG(gg).name];
end
cd(base_dir_pp_HC)
subs_pp_HC = dir('Physio*');
for gg = 1:length(subs_pp_HC)
    subs_pp_HC(gg).name = [base_dir_pp_HC filesep subs_pp_HC(gg).name];
end
subs =  [subs_PG;subs_pp_HC;subs_pp_PG];
warning('Only running for POSTPILOT')

% channel_names; category names
chn_nms = {'mark', 'eda', 'zygo', 'corr'};
cat_nms = {'gam','neg','pos','neu','gry'};

% what to run?
pspml       = 1; % pspm linear model
pspml_run   = 0; % if 0 skip; but possibly do the export at least
pspmnl      = 0; % pspm non-linear model (takes long time!)
pspmnl_exp  = 0;
del_pspml   = 0; % delete old pspml folders? should be 0!
ledalab     = 0; % ledlab analysis

%% ############### PSPM linear #####################
if pspml
    
    if del_pspml
        for ii = 1:length(subs)
            cd(subs(ii).name)
            cur_folders = cellstr(ls('pspml*'));
            if ~isempty(cur_folders{1})
                for jj = 1:length(cur_folders)
                    try
                        rmdir(cur_folders{jj},'s')
                    catch
                        disp(['Could not del: ' subs(ii).name filesep cur_folders{jj}])
                    end
                end
            end
        end
    end
    
    % init the PSPM toolbox
    scr_init;
    % initialize PsPM
    scr_jobman('initcfg');
    
    % parameters
    aggr           = 6 ;        % level of gain and loss aggregation (edabs aggr is fixed)
    do_center      = 0 ;        % should param mod be centered; normally pspm does it
    run_it         = 1 ;        % run the analysis or just write the job and design?
    ow             = 1 ;        % should old data be kept or overwrite?
    acc_rec        = 0 ;        % accept reject modeling: not implemented; so 0 IT IS; CHANGE THIS
    fixed_dur      = 0 ;        % fixed duration (usually 0); if empty duration accor-
                                % ding to stimuli duration, for stick function
    normalize      = 1 ;        % should data be normalized within sub?
    scrf_modelings = [0,1,2,3]; % 1 SCRF1 is standard (bf and derivative),
                                % 2 is with added dispersion, 3 is uninformed FIR,
                                % 0 is no derivative
                                % finite response function with 30 bins à 1 second
    adjust_ampl    = 0 ;        % adjust for EDA amplification?
    export         = 1 ;        % 1 is recon; 2 is param scr_exp; 0 is no export
    
    if pspml_run
        for jj = 1:length(scrf_modelings)
            scrf_modeling = scrf_modelings(jj);
            for ii = 1:length(subs)
                % check if sub has been processed already
                if ow == 0
                    % ...
                    continue
                end
                
                % run the PSPM linear
                psl_feedback{ii} =  ...
                    agk_make_PDT_ss_pspml_only_pic_no_iti_no_fb_cond_by_ons_accint3(subs(ii), ...
                    aggr,do_center,run_it,fixed_dur,normalize,scrf_modeling, ...
                    adjust_ampl);
            end
        end
    end
    
    if export
        for jj = 1:length(scrf_modelings)
            % cur scrf modeling
            scrf_modeling = scrf_modelings(jj);
           
            % name of this scrf modeling determines the results directory
            switch scrf_modeling
                case 0
                    results_ssdir = ['pspml_acc' filesep 'scrf0'];
                    % set output file
                    pspml_out = fullfile(base_dir,'pspml_scrf0_out.txt');
                case 1
                    results_ssdir = ['pspml_acc' filesep 'scrf1'];
                    % set output file
                    pspml_out = fullfile(base_dir,'pspml_scrf1_out.txt');
                case 2
                    results_ssdir = ['pspml_acc' filesep 'scrf2'];
                    % set output file
                    pspml_out = fullfile(base_dir,'pspml_scrf2_out.txt');
                case 3
                    results_ssdir = ['pspml_acc' filesep 'FIR'];
                    % set output file
                    pspml_out = fullfile(base_dir,'pspml_FIR_out.txt');
            end
            
            % exporting the contrast estimates: get modmats
            modmats   = {};
            sub_codes = {};
            ct        = 0 ;
            for ii = 1:length(subs)
                cd(subs(ii).name)
                try
                    cd(results_ssdir)
                catch
                    disp('no pspml folder here:')
                    disp(pwd)
                    continue
                end
                if exist('PSPML.mat','file')
                    ct              = ct + 1;
                    modmats{ct,1}   = fullfile(pwd,'PSPML.mat');
                    [p,f,e]         = fileparts(fileparts(fileparts(pwd)));
                    sub_codes{ct,1} = f;
                else
                    disp('no PSPML.mat found! here:')
                    disp(pwd)
                    continue
                end
            end
            
            % exporting and writing
            if export == 2
                % exporting the parameters (basis functions)
                scr_exp(modmats,pspml_out,'param');
                % adding a subject code column
                cur_tab = readtable(pspml_out,'HeaderLines',1,'Delimiter','\t');
            elseif export == 1
                [p,f,e] = fileparts(pspml_out);
                f       = strrep(f,'_','\_');
                h = waitbar(0,['Please wait for: ' f]);               
                % exporting the reconstructed peaks
                [sts,glm] = scr_glm_recon(modmats{1});
                all_recon = cell2mat(glm.recon)';
                colnames  = glm.reconnames';
                colnames  = strrep(colnames,' ','_');
                colnames  = strrep(colnames,'.','_');
                colnames  = strrep(colnames,'^','_');
                waitbar(1/length(modmats))
                for ii = 2:length(modmats)
                    % for all subjects
                    [sts,glm] = scr_glm_recon(modmats{ii});
                    cur_recon = cell2mat(glm.recon)';
                    if isempty(cur_recon)
                        error(['Reconstructed responses are empty! ' modmats{ii}])
                    end
                    all_recon  = [all_recon;cur_recon];
                    waitbar(ii/length(modmats))
                end
                close(h)
                
                % make a table of it
                cur_tab = array2table(all_recon,'VariableNames',colnames);
            end
            
            % writing
            cur_tab.sub = sub_codes;
            writetable(cur_tab,pspml_out)
        end
    end
end

%% ############### LEDA-LAB CDA ####################
if ledalab
    % install leda
    cd('C:\Program Files\MATLAB\R2014a\toolbox\ledalab')
    Ledalab
    close all

    % parameters
    run_it      = 1 ; % run the analysis or just write the job and design?
    ow          = 1 ; % should old data be kept or overwrite?
    fixed_dur   = []; % fixed duration (usually 0); if empty duration accor-
                    % ding to stimuli duration
    wdir        = 'C:\tmp\ledalab';
    ds_factor   = 20; % downsampling factor (20 makes from 1000Hz to 50Hz)
    adjust_ampl = 1 ; % adjust for amplification used in exp?
    
    % create the directory to interim save the bulk of data
    mkdir(wdir);
    
    % this loop is just prepping the folder with to-be analyzed data
    for ii = 1:length(subs)
        % check if sub has been processed already
        if ow == 0
            % ...
            continue
        end
        
        % run the PSPM linear
        pleda_feedback{ii} =  ...
            agk_make_PDT_ss_ledalab(subs(ii),adjust_ampl,wdir);
    end
    
    % run the Ledalab
    if run_it
        Ledalab([wdir filesep], 'open', 'mat', 'downsample',ds_factor, ...
            'smooth', {'adapt'}, 'analyze','CDA', 'optimize',2, ...
            'export_era', [1 4 .01 1], 'overview',1)
    end
        
    % export the results
    agk_ledalab_export
    
    % delete the working directory

end
%% ############### PSPM non-linear #################
if pspmnl
    % init the PSPM toolbox
    scr_init;
    % initialize PsPM
    scr_jobman('initcfg');
    
    % parameters
    aggr      = 3 ; % level of gain and loss aggregation (should be 3)
    do_center = 0 ; % should param mod be centered; normally pspm does it
    run_it    = 1 ; % run the analysis or just write the job and design?
    ow        = 1 ; % should old data be kept or overwrite?
    acc_rec   = 0 ; % accept reject modeling: not implementes; so 0
    fixed_dur = []; % fixed duration (usually 0); if empty duration accor-
                    % ding to stimuli duration
    
    for ii = 1:length(subs)
        % check if sub has been processed already
        if ow == 0
            % ...
            continue
        end
        
        % run the PSPM linear
        psl_feedback{ii} =  ... 
            agk_make_PDT_ss_pspmnl(subs(ii),aggr, ...
            do_center,run_it,acc_rec,fixed_dur);
    end
end

%% ############### PSPM non-linear export ##########
if pspmnl_exp
    % prep
    pspmnl_out = fullfile(base_dir,'pspmnl_out.csv');
    % exporting the contrast estimates
    modmats   = {};
    sub_codes = {};
    ct        = 0 ;
    for ii = 1:length(subs)
        cd(subs(ii).name)
        try
            cd('pspmnl')
        catch
            disp('no pspmnl folder here:')
            disp(pwd)
            continue
        end
        if exist('PSPMNL.mat','file')
            ct              = ct + 1;
            modmats{ct,1}   = fullfile(pwd,'PSPMNL.mat');
            [p,f,e]         = fileparts(fileparts(pwd));
            sub_codes{ct,1} = f;
        else
            disp('no PSPMNL.mat found! here:')
            disp(pwd)
            continue
        end
    end
    scr_exp(modmats,pspmnl_out,'param');
    
    % adding a subject code column
    cur_tab        = readtable(pspmnl_out,'HeaderLines',1,'Delimiter','\t');
    cur_tab.sub    = sub_codes;
    pspmnl_out_tab = fullfile(base_dir,'pspmnl_out_tab.csv');
    writetable(cur_tab,pspmnl_out_tab)
end
    
