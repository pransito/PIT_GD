% agk_make_PDT_ss_pspmnl
% for one subject
% non-linear PSPM model

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

% THIS MODEL ('pspmnl')
% 2 events: PIC PIC+GAM+OPT
% declare events with some onset, and offset if needed
% if offset then normal non-linear estimation (stick function)
% events cell array will be created; 1 X N; N events per trial;
% a cell is an event within each trial
% each cell holds a matrix (is a matrix with one or two columns, onset
% and offset)

% DETAILS
% abs values of losses are used
% takes in an aggregation factor: e.g. 1 means no change; 2 means, the 12
% by 12 matrix will be aggregated to a 6-by-6 matrix, and so on
% missing trials are not excluded

% AUTHORSHIP
% author: Alexander Genauck
% date  : 29.09.2017
% email : alexander.genauck@charite.de

function error_message = agk_make_PDT_ss_pspmnl(cur_sub, ...
    aggr,do_center,run_it,acc_rec,fixed_dur)
% try
%% PREPARATIONS
% name of this analysis determines the results directory
results_ssdir = 'pspmnl';

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

%% adjust for amplification and trim by hand
load(wphys_name);

%     % adjust eda for amplification
%     cur_eda_factor = str2num(P.vp.vfaktoreda);
%     switch cur_eda_factor
%         case 100
%             data(:,2) = data(:,2)*10;
%         case 500
%             data(:,2) = data(:,2)*2;
%         case 1000
%         otherwise
%             error('Unexpected EDA amplification!')
%     end

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
    names       = {'Pic.on','Pic.gam.opt.on',};
    onsets      = cell(1,2);
    durations   = cell(1,2);
    picneu      = [];
    picgam      = [];
    picneg      = [];
    picpos      = [];
end

%% fill onsets
%     try
for ii = 1 : length(P.cur.choice)
    % PIC ON
    onsets(1) = {[cell2mat(onsets(1)) P.t.cur_trial.stim_on(ii) + P.t.start_exp - phys0]};
    if ~isempty (fixed_dur)
        durations(1) = {[cell2mat(durations(1)) fixed_dur]};
    else
        durations(1) = {[cell2mat(durations(1)) (P.t.cur_trial.stimLA_on(ii) - P.t.cur_trial.stim_on(ii))]};
    end
    
    % which cat currently?
    switch P.cur.cat(ii)
        case 1
            picgam = [picgam ii];
        case 2
            picneg = [picneg ii];
        case 3
            picpos = [picpos ii];
        case 6
            picneu = [picneu ii];
        otherwise
            error('Unexpected category!')
    end
    
    % PIC PLUS GAMBLE ON (WITH CHOICE OPTIONS)
    onsets(2)    = {[cell2mat(onsets(2)) P.t.cur_trial.stimLA_on(ii) + P.t.start_exp - phys0]};
    if ~isempty (fixed_dur)
        durations(2) = {[cell2mat(durations(2)) fixed_dur]};
    else
        durations(2) = {[cell2mat(durations(2)) (P.t.cur_trial.stimLA_off(ii) - P.t.cur_trial.stimLA_on(ii))]};
    end
end

%     catch MExc
%         disp([results_ssdir ' ' cur_sub.name ' Problems with specifying param mod (behav data not ok?).']);
%         error_message = {MExc,[results_ssdir ' ' cur_sub.name ' Problems with specifying param mod (behav data not ok?).']};
%         cd(root_dir)
%         return
%     end

% make the events file
events = {};
for ii = 1:length(onsets)
    cur_event = repmat(0,length(onsets{ii}),2);
    cur_onset = onsets{ii};
    cur_dur   = durations{ii};
    for jj = 1:length(cur_onset)
        cur_event(jj,1) = cur_onset(jj);
        cur_event(jj,2) = cur_event(jj,1)+cur_dur(jj);
    end
    events{ii} = cur_event;
end

% create the results dir
full_res_ssdir = fullfile(pwd,results_ssdir);
mkdir(pwd,results_ssdir)
cd(results_ssdir)

% save all the condition info
save('mult_cond.mat','names','events');

% fill the batch
clear matlabbatch
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {wphys_name};
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.chan_nr.chan_nr_spec = 2;
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.sample_rate = 1000;
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.transfer.none = true;
matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.modelfile = 'PSPMNL';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.outdir = {full_res_ssdir};
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.chan.chan_def = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.datafile = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.timing.timingfile = {fullfile(pwd,'mult_cond.mat')};
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(1).name = 'neu';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(1).index = picneu;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(2).name = 'gam';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(2).index = picgam;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(3).name = 'neg';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(3).index = picneg;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(4).name = 'pos';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(4).index = picpos;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.data_options.norm = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.data_options.filter.def = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.crfupdate = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.indrf = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.getrf = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.rf = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.depth = 2;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sfpre = 2;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sfpost = 5;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sffreq = 0.5;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sclpre = 2;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sclpost = 5;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.ascr_sigma_offset = 0.1;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.disp_options.dispwin = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.dcm.disp_options.dispsmallwin = 0;

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