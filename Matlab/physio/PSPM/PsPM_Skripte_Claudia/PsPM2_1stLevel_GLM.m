%% Batch first level stats PsPM-----------------------------------------------------------------------
% Job saved on 29-Sep-2015 17:01:53 by cfg_util (rev $Rev: 701 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear;

mainpath=('S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata_d1_allExperiments\EDA\PsPM_GLM_In')

% initialize PsPM
scr_init;
scr_jobman('initcfg');

for d=3
    
pathin=fullfile(mainpath, ['day', num2str(d)], 'first5trials_combined'); %('S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata_d1_allExperiments\EDA\PsPM_GLM_In');
pathout={fullfile(pathin, '1st_level_glm')}; %'S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata_d1_allExperiments\EDA\PsPM_GLM_In\1st_level_glm'};

   
data_files = dir(fullfile(pathin, ['scr_*','_*DATA.mat']));
con_files= dir(fullfile(pathin, ['*_' , '*REGRESSORS.mat']));

if length(data_files) ~= length(con_files)
    disp('WARNING: Number of data files does not match number of regressor files!'); 
else
end


for p= 1:length(data_files)

filename=regexprep(data_files(p).name, {'scr', '_DATA.mat'}, {'glm', ''});    
conditions=regexprep(data_files(p).name, {'scr_', 'DATA'}, {'','REGRESSORS'});

clear matlabbatch

matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.modelfile = filename;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.outdir = pathout;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.chan.chan_def = 0;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.timeunits.samples = 'samples';
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.session.datafile = {fullfile(pathin, data_files(p).name)};
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.session.missing.no_epochs = 0;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.session.data_design.condfile = {fullfile(pathin, conditions)};
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.session.nuisancefile = {''};
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.bf.scrf1 = 1;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.norm = true;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.lowpass.enable.freq = 4.9; % adapted cut of frequency low pass*
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.lowpass.enable.order = 1;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.highpass.enable.freq = 0.05;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.highpass.enable.order = 1;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.down = 10;
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.filter.edit.direction = 'uni';
matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.glm.overwrite = true;


% run batch
scr_jobman('run', matlabbatch)
end

end
% * to avoid warning: The low pass filter cutoff frequency is higher (or equal) than the nyquist frequency.
% The data won't be low pass filtered! 