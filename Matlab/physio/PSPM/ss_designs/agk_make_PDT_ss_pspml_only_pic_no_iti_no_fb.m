% agk_make_PDT_ss_pspml_design_ed_03
% for one subject
% makes the ss design of the PDT task based on the Tom et al. (2007) paper
% pictures here are put in as categorical vectors
% to allow a cue reactivity contrast (between categories modeling)

% INPUT
% cur_sub       : name of current subject
% which_folders : name of folder with niftis of task (pciks first) ???
% aggr          : aggregation level gambling matrix (we usually take 3)
% run_it        : should the job run? (will be only save if not)
% acc_rec       : should accept be included as a factor in model (def: no)
% expl_mask     : usually use a gray matter mask here
% cur_tmpl      : the ss job template to be used here, cell, first field is
%                 the one without accept reject as factor and second with
% ow            : overwrite exisiting results files? (0,1)

% OUTPUT
% error_message: success message or explanation what hasn't worked

% IMPLICIT OUTPUT
% writes the ss model into the results_ssdir in the subject folder

% THIS MODEL ('PDT_ss_design_edfix_03')
% 2 task on: PIC, PIC+GAM
% 3 param modulators in PIC: category dummy coded (gam, neg, neu)
% no param mod in PIC+GAM: gain, abs(loss), ed
% 0 param mod in all others

% DETAILS
% preproc_job is needed to get the slice timing parameters
% (to create time bins), will be looked for in the nifti folder provided
% will look for "preprocessing..." pattern
% abs values of losses are used
% nifti data need to be SPM12 preprocessed
% takes in an aggregation factor: e.g. 1 means no change; 2 means, the 12
% by 12 matrix will be aggregated to a 6-by-6 matrix, and so on
% the picture category is modeled by three dummy variables (i.e. all 0 is
% neutral)
% PIC+GAM+OPT and FEEDBACK are not parametrically modulated (leads to too
% much intercorrelation in design matrix

% AUTHORSHIP
% author: Alexander Genauck
% date  : 23.01.2017
% email : alexander.genauck@charite.de

function error_message = agk_make_PDT_ss_pspml_only_pic_no_iti_no_fb(cur_sub, ...
    aggr,do_center,run_it,acc_rec,fixed_dur)
% try
    %% PREPARATIONS
    % name of this analysis determines the results directory
    results_ssdir = 'pspml';
    
    % cur home directory
    root_dir = pwd;
    
    % messaging
    disp('Estimating subject...');
    disp(cur_sub.name);
    disp(['First level model: ' results_ssdir]);
    
    % gain and loss ranges
    gain_min = 14;
    gain_max = 36;
    loss_max = 18;
    loss_min = 7;
    
    % for euclidean distance
    vec = [2;1;0];   % slope vector [gain; loss; 0]
    sp  = [26;13;0]; % sp support point; point on the diag [gain; loss; 0]
    
    % calculate the aggregated possible values
    cur_gains = (gain_min:2:gain_max);
    cur_losss = loss_min:loss_max    ;
    [vg,osg,nsg]  = agk_downsample_steps(cur_gains,aggr);
    gain_min  = min(vg);
    gain_max  = max(vg);
    [vl,osl,nsl]  = agk_downsample_steps(cur_losss,aggr);
    loss_min  = min(vl);
    loss_max  = max(vl);
    
    %% get the physio of this sub
    % phys data discarding of previous sub
    try
        if ii > 1
            clear phys
            clear P
        end
    catch
    end
    
    % phys data reading
    cd(cur_sub.name)
    name_phys = dir('phys_moved*');
    if ~isempty(name_phys)
        disp(['Now trying to read in data of ' cur_sub.name])
        try
            name_phys = name_phys(1).name;
            tmpfid = fopen(name_phys);
            tmp = textscan(tmpfid,'%s');
            load(tmp{1}{1});
            fclose(tmpfid);
        catch
            disp(tmp{1}{1})
            disp(['Weirdly, no physio data found on S: for sub ' ...
                cur_sub.name])
            error_message = 'NO PHYSIO FOUND';
            return
        end
        name_P = dir('P_*');
        name_P = name_P(1).name;
        load(name_P)
    else
        disp(['No info on where physio data is on S: for sub ' ...
            cur_sub.name])
        error_message = 'NO PHYSIO FOUND';
        return
    end
    
    % needs to be a file which has a .data leaf
    data       = phys.daten;
    [p,f,e]    = fileparts(tmp{1}{1});
    wphys_name = [pwd filesep 'w' f e];
    save(wphys_name,'data');
    clear phys
    
    %% trim by hand
    load(wphys_name);
    % get the t(start(AI)) in seconds (GetSecs style)
    marker_start_script = find(data(:,1)>1,1,'first')/1000;
    t_start_AI          = P.t.start_script - marker_start_script;
    
    % get a new t_start_AI by cutting everything until 2s before first
    % ITI 'x' display
    % trim the beginning and get the reference time in GetSecs (phys0)
    % for the P.t recorded times; cut in the end not needed
    cut_begin  = P.t.cur_trial.iti_on(1) + P.t.start_exp - t_start_AI - 2;
    phys0      = t_start_AI + cut_begin;
    cut_begin  = cut_begin*1000 + 1;
    % actual trimming
    data = data(round(cut_begin):end,:);
    save(wphys_name,'data')
    
    %% PREPARE FILLING BATCH
    % preparing the design information variables
    if acc_rec == 0
        names       = {'Pic.on','Pic.gam.opt.on'};
        onsets      = cell(1,2);
        durations   = cell(1,2);
    end
    
    pmod            = struct('name',{},'poly',{},'param',{});
    pmod(1).name{1} = 'gam';
    pmod(1).poly{1} = 1;
    pmod(1).name{2} = 'neg';
    pmod(1).poly{2} = 1;
    pmod(1).name{3} = 'pos';
    pmod(1).poly{3} = 1;
    for ii = 2:2
        pmod(ii).name{1} = 'gain';
        pmod(ii).poly{1} = 1;
        pmod(ii).name{2} = 'loss';
        pmod(ii).poly{2} = 1;
        pmod(ii).name{3} = 'ed';
        pmod(ii).poly{3} = 1;
    end
    
    % prep the param mod regressors for each task_on regressor
    % for pic on
    p11 = []; % gam
    p12 = []; % neg
    p13 = []; % pos
    % for pic and gamble on
    p21 = []; % gain
    p22 = []; % loss
    p23 = []; % ed
    % for feedback
    % (NONE) (missings will be discarded anyways)
    
    % getting the gain mean and the loss mean
    for hh = 1:length(P.cur.choice)
        all_gains(hh) = str2double(cell2mat(P.gain.strings(P.cur.gamble{hh}(1))));
        all_losss(hh) = str2double(cell2mat(P.loss.strings(P.cur.gamble{hh}(2))));
    end
    mean_gain = mean(all_gains);
    mean_loss = mean(all_losss);
    
    % mean centering?
    if (do_center == 0)
        mean_gain = 0;
        mean_loss = 0;
    end
    
    %% fill onsets, pmod p's
%     try
        for ii = 1 : length(P.cur.choice)
            if ~(P.cur.choice(ii) > 0 && P.cur.choice(ii) < 5)
                continue
            end
            % PIC ON
            onsets(1)    = {[cell2mat(onsets(1)) P.t.cur_trial.stim_on(ii) + P.t.start_exp - phys0]};
            if ~isempty (fixed_dur)
                durations(1) = {[cell2mat(durations(1)) fixed_dur]};
            else
                durations(1) = {[cell2mat(durations(1)) (P.t.cur_trial.stimLA_on(ii) - P.t.cur_trial.stim_on(ii))]};
            end
            switch P.cur.cat(ii)
                case 1
                    cur_gam = 1;
                    cur_neg = 0;
                    cur_pos = 0;
                case 2
                    cur_gam = 0;
                    cur_neg = 1;
                    cur_pos = 0;
                case 3
                    cur_gam = 0;
                    cur_neg = 0;
                    cur_pos = 1;
                case 6
                    cur_gam = 0;
                    cur_neg = 0;
                    cur_pos = 0;
            end
            % pic dummy code
            p11          = [p11 cur_gam];
            p12          = [p12 cur_neg];
            p13          = [p13 cur_pos];
            
            % PIC PLUS GAMBLE ON (WITH CHOICE OPTIONS)
            onsets(2)    = {[cell2mat(onsets(2)) P.t.cur_trial.stimLA_on(ii) + P.t.start_exp - phys0]};
            if ~isempty (fixed_dur)
                durations(2) = {[cell2mat(durations(2)) fixed_dur]};
            else
                durations(2) = {[cell2mat(durations(2)) (P.t.cur_trial.stimLA_off(ii) - P.t.cur_trial.stimLA_on(ii))]};
            end
            % gain
            cur_gain     = agk_recode(str2double(cell2mat(P.gain.strings(P.cur.gamble{ii}(1)))),osg,nsg) - mean_gain;
            gain_orig    = cur_gain+mean_gain;
            p21          = [p21 cur_gain];
            % loss (here changed loss to abs. loss)
            cur_loss     = agk_recode(abs(str2double(cell2mat(P.loss.strings(P.cur.gamble{ii}(2))))),osl,nsl) - abs(mean_loss);
            loss_orig    = cur_loss+abs(mean_loss);
            p22          = [p22 cur_loss];
            % ed
            cur_point    = [gain_orig;loss_orig;0];
            ed           = agk_get_ed(cur_point,sp,vec);
            p23          = [p23 ed];
        end
        
        % first run/only one seesion
        pmod(1).param{1} = p11;
        pmod(1).param{2} = p12;
        pmod(1).param{3} = p13;
        
        pmod(2).param{1} = p21;
        pmod(2).param{2} = p22;
        pmod(2).param{3} = p23;

%     catch MExc
%         disp([results_ssdir ' ' cur_sub.name ' Problems with specifying param mod (behav data not ok?).']);
%         error_message = {MExc,[results_ssdir ' ' cur_sub.name ' Problems with specifying param mod (behav data not ok?).']};
%         cd(root_dir)
%         return
%     end
%     
    % create the results dir
    full_res_ssdir = fullfile(pwd,results_ssdir);
    mkdir(pwd,results_ssdir)
    cd(results_ssdir)
    
    % save all the condition info
    save('mult_cond.mat','names','onsets','durations','pmod');
    
    % fill the batch
    clear matlabbatch
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {wphys_name};
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.chan_nr.chan_nr_spec = 2;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.sample_rate = 1000;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.transfer.none = true;
    matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.modelfile = 'PSPML';
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.outdir = {full_res_ssdir};
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.chan.chan_def = 0;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.timeunits.seconds = 'seconds';
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.missing.no_epochs = 0;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.data_design.condfile = {fullfile(pwd, 'mult_cond.mat')};
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.nuisancefile = {''};
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf1 = 1;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.norm = false;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.def = 0;
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.overwrite = true;
    
    % save design
    save('design.mat','matlabbatch');
    
    if run_it       
        % run batch
        try
            % run batch
            scr_jobman('run', matlabbatch)
            error_message = [results_ssdir ' ' cur_sub.name ' Estimation successfull.'];
        catch MExc
            error_message = {MExc,[results_ssdir ' ' cur_sub.name ' Estimation not successfull.']};
            cd(root_dir)
            return
        end
    end
    cd(root_dir);
    
    % rm the work physio file
    delete(wphys_name)
% catch MExc
%     try
%         % rm the work physio file
%         delete(wphys_name)
%     catch
%     end
%     disp('Something went wrong');
%     error_message = MExc;
% end