% agk_make_PDT_ss_ledalab
% for one subject
% makes the ss design of the PDT task based on the Tom et al. (2007) paper
% ledalab CDA analysis

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

function error_message = agk_make_PDT_ss_ledalab(cur_sub,adjust_ampl,wdir)
%% PREPARATIONS
results_ssdir = 'ledalabCDA';

% messaging
disp('Estimating subject...');
disp(cur_sub.name);
disp(['First level model: ' results_ssdir]);

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
conductance                  = phys.daten(:,2);
[source_p,source_f,source_e] = fileparts(tmp{1}{1});
wphys_name                   = [source_p filesep 'w' source_f source_e];
phys_sr                      = phys.samplerate;

%% adjust for amplification and trim by hand
if adjust_ampl
    % adjust eda for amplification
    cur_eda_factor = str2num(P.vp.vfaktoreda);
    switch cur_eda_factor
        case 100
            conductance = conductance*10;
        case 500
            conductance = conductance*2;
        case 1000
        otherwise
            error('Unexpected EDA amplification!')
    end
end

% get the t(start(AI)) in seconds (GetSecs style)
marker_start_script = find(phys.daten(:,1)>1,1,'first')/1000;
t_start_AI          = P.t.start_script - marker_start_script;

% unit tests
if all(conductance < 0)
    warning('EDA conductance is always negative!')
end
if isempty(marker_start_script)
    error('No start marker found!')
end

% get a new t_start_AI by cutting everything until 2s before first
% ITI 'x' display
% trim the beginning and get the reference time in GetSecs (phys0)
% for the P.t recorded times; cut in the end not needed
cut_begin  = P.t.cur_trial.iti_on(1) + P.t.start_exp - t_start_AI - 2;
phys0      = t_start_AI + cut_begin;
cut_begin  = cut_begin*1000 + 1;
% actual trimming
conductance = conductance(round(cut_begin):end,:);

% make a needed data struct
data.conductance = conductance;
data.time        = 0.001:0.001:length(data.conductance)/phys_sr;
data.timeoff     = 0;

% do not need phys data anymore
clear phys

%% fill onsets (events within trial)
% data.event is a struct by itself where each event along the time
% continuum is defined with the following variables:
% Event.time    specifies the timepoint of the particular event's occurence
% Event.nr      Sequence number of event/marker - not necessary
% Event.nid     Numerical ID of event (usually trial number)
% event.name	Optional name or decription of event (within a trial)
% Event.ud      Optional userdata associated with event
names       = {'Pic.on','Pic.gam.opt.on',};
onsets      = cell(1,1);
durations   = cell(1,1);
picneu      = [];
picgam      = [];
picneg      = [];
picpos      = [];
ct          = 0;
nid         = [];
name        = cell(1,1);

for ii = 1 : length(P.cur.choice)
    % PIC ON
    ct  = ct + 1;
    nid = [nid ii];
    onsets(1) = {[cell2mat(onsets(1)) P.t.cur_trial.stim_on(ii) + P.t.start_exp - phys0]};
    
    % which cat currently?
    switch P.cur.cat(ii)
        case 1
            name{ct} = 'picgam';
        case 2
            name{ct} = 'picneg';
        case 3
            name{ct} = 'picpos';
        case 6
            name{ct} = 'picneu';
        otherwise
            error('Unexpected category!')
    end
    
    % PIC PLUS GAMBLE ON (WITH CHOICE OPTIONS)
    ct       = ct + 1;
    nid      = [nid ii];
    name{ct} = 'gamble';
    onsets(1)    = {[cell2mat(onsets(1)) P.t.cur_trial.stimLA_on(ii) + P.t.start_exp - phys0]};
end

% make a struct array
if exist('event','var')
    clear event
end
gg = 1;
event(gg).time     = onsets{1}(gg);
event(gg).nid      = nid(gg);
event(gg).name     = name{gg};
event(gg).userdata = [];
for gg = 2:length(onsets{1})
    event(gg).time     = onsets{1}(gg);
    event(gg).nid      = nid(gg);
    event(gg).name     = name{gg};
    event(gg).userdata = [];
end
data.event = event;

% polishing
new_data.conductance = data.conductance';
new_data.event       = data.event;
new_data.time        = data.time;
new_data.timeoff     = 0;
data                 = new_data;



% create the results dir
cd(wdir)
[p,f,e] = fileparts(cur_sub.name);
save(['EDA' f '.mat'] , 'data');

% feedback
error_message = 'Preparation of phys data for leda successful.';
if all(conductance < 0)
    error_message = 'Conductance always negative!';
end
