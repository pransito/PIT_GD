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

% THIS MODEL ('pspml')
% 4 onsets pic: PIC_NEU, PIC_GAM, PIC_NEG, PIC_POS
% 1 onset gamble with 3 modulators: gain, abs(loss), ed

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
% date  : 02.10.2017
% email : alexander.genauck@charite.de

function error_message = agk_make_PDT_ss_pspml_only_pic_no_iti_no_fb_cond_by_ons(cur_sub, ...
    aggr,do_center,run_it,fixed_dur,normalize,scrf_modeling, ...
    adjust_ampl)
% try
    %% PREPARATIONS
    % name of this analysis determines the results directory
    switch scrf_modeling
        case 0
            results_ssdir = ['pspml' filesep 'scrf0'];
        case 1
            results_ssdir = ['pspml' filesep 'scrf1'];
        case 2
            results_ssdir = ['pspml' filesep 'scrf2'];
        case 3
            results_ssdir = ['pspml' filesep 'FIR'];
    end
    
    
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
    
    % needs to be a file which has a variable called data
    data       = phys.daten;
    [p,f,e]    = fileparts(tmp{1}{1});
    wphys_name = [pwd filesep 'w' f e];
    save(wphys_name,'data');
    clear phys
    
    %% adjust for amplification and trim by hand
    load(wphys_name);
    
    if adjust_ampl
        % adjust eda for amplification
        cur_eda_factor = str2num(P.vp.vfaktoreda);
        switch cur_eda_factor
            case 100
                data(:,2) = data(:,2)*10;
            case 500
                data(:,2) = data(:,2)*2;
            case 1000
            otherwise
                error('Unexpected EDA amplification!')
        end
    end
    
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
    names       = {'Pic.neu','Pic.gam','Pic.neg','Pic.pos', ...
        'Pic.gam.opt.on'};
    onsets      = cell(1,5);
    durations   = cell(1,5);
    
    pmod            = struct('name',{},'poly',{},'param',{});
    for ii = 5:5
        pmod(ii).name{1} = 'gain';
        pmod(ii).poly{1} = 1;
        pmod(ii).name{2} = 'loss';
        pmod(ii).poly{2} = 1;
        pmod(ii).name{3} = 'ed';
        pmod(ii).poly{3} = 1;
    end
    
    % for pic and gamble on
    p51 = []; % gain
    p52 = []; % loss
    p53 = []; % ed
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
            switch P.cur.cat(ii)
                case 1
                    ons_code = 2;
                case 2
                    ons_code = 3;
                case 3
                    ons_code = 4;
                case 6
                    ons_code = 1;
            end
            onsets(ons_code) = {[cell2mat(onsets(ons_code)) P.t.cur_trial.stim_on(ii) + P.t.start_exp - phys0]};
            if ~isempty (fixed_dur)
                durations(ons_code) = {[cell2mat(durations(ons_code)) fixed_dur]};
            else
                durations(ons_code) = {[cell2mat(durations(ons_code)) (P.t.cur_trial.stimLA_on(ii) - P.t.cur_trial.stim_on(ii))]};
            end
            
            % PIC PLUS GAMBLE ON (WITH CHOICE OPTIONS)
            onsets(5)    = {[cell2mat(onsets(5)) P.t.cur_trial.stimLA_on(ii) + P.t.start_exp - phys0]};
            if ~isempty (fixed_dur)
                durations(5) = {[cell2mat(durations(5)) fixed_dur]};
            else
                durations(5) = {[cell2mat(durations(5)) (P.t.cur_trial.stimLA_off(ii) - P.t.cur_trial.stimLA_on(ii))]};
            end
            % gain
            cur_gain     = agk_recode(str2double(cell2mat(P.gain.strings(P.cur.gamble{ii}(1)))),osg,nsg) - mean_gain;
            gain_orig    = cur_gain+mean_gain;
            p51          = [p51 cur_gain];
            % loss (here changed loss to abs. loss)
            cur_loss     = agk_recode(abs(str2double(cell2mat(P.loss.strings(P.cur.gamble{ii}(2))))),osl,nsl) - abs(mean_loss);
            loss_orig    = cur_loss+abs(mean_loss);
            p52          = [p52 cur_loss];
            % ed
            cur_point    = [gain_orig;loss_orig;0];
            ed           = agk_get_ed(cur_point,sp,vec);
            p53          = [p53 ed];
        end
        
        % first run/only one seesion        
        pmod(5).param{1} = p51;
        pmod(5).param{2} = p52;
        pmod(5).param{3} = p53;

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
    if scrf_modeling == 1 
        matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf1 = scrf_modeling;
    elseif scrf_modeling == 2
        matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf2 = scrf_modeling;
    elseif scrf_modeling == 3
        matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.fir.arg.n = 30;
        matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.fir.arg.d = 1;
    elseif scrf_modeling == 0
        matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf0 = 0;
    else
        error('Unknown scrf_modeling code indicated by user.')
    end
    matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.norm = normalize;
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