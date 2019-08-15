% go through tutorial

% set paths to toolbox
addpath('C:\Program Files\MATLAB\R2014a\toolbox\PsPM');

% prep data
dat_path = ['C:\Users\genaucka\Downloads\Tutorial_data_GLM'];
cd(dat_path)


% nonlinear
% make timing info files
% set the correct PsPM file path here!
data_path = 'C:\Users\genaucka\Downloads\Tutorial_dataset_DCM\scr'; 
p         = 1; % the first participant
SOA       = 3.5; % delay between CS and US onset in seconds
% load events of CS onsets from trimmed scr data
pname = fullfile(data_path,sprintf('tscr_s%i.mat',p));
[sts, infos, data, filestruct] = scr_load_data(pname,'events');
CS_onset = data{1, 1}.data; % recorded triggers of CS onset in seconds
US_onset = data{1, 1}.data + SOA; % US starts 3.5 seconds after CS
% variable latency for CS response between CS onset and US onset/omission
% define an interval of 3.5 seconds for each trial
events{1} = [CS_onset US_onset]; 
% constant onset for US response
events{2} = US_onset;
save(fullfile(data_path,sprintf('event_timings_s%i.mat',p)),'events')
