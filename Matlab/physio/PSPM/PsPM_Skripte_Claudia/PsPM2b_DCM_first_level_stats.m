%-----------------------------------------------------------------------
% Job saved on 16-Jun-2016 17:37:36 by cfg_util (rev $Rev: 701 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear;   warning off;
errors={};
    paEDAin='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\input_2fixed_responses';  %folder: RAWDATA
    paEDAout='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\DCM_firstlevel_fixed_responses';  %folder: OUTPUT
    
    gui=1 %open GUI
    [filepath filenames]=p_getfiles2(paEDAin, 'scr_.*.', gui);
    
 %initialize PsPM
% scr_init
 
 scr_jobman('initcfg');
    
    for i=1:length(filenames)
        datafile =filepath{i}
        epochfile=regexprep(datafile,{'DATA.mat','scr_'} ,{'EPOCHS.mat', '' });
        importfile=regexprep(datafile, 'scr_', '');
        outfilename=regexprep(filenames{i},{'_DATA.mat','scr_'} ,{'.mat', 'DCM_' }) ;
        outpath=fullfile(paEDAout,outfilename );
         
load(importfile)


clear matlabbatch dcm

dcm.modelfile =outfilename;
dcm.outdir = {paEDAout};
dcm.chan.chan_def = 0;
dcm.session.datafile = {datafile};
dcm.session.timing.timingfile = {epochfile};
dcm.session.condition(1).name = 'CS+|US';
dcm.session.condition(1).index = find(infod.conds==40)';
dcm.session.condition(2).name = 'CS+|oUS';
dcm.session.condition(2).index = find(infod.conds==4)';
dcm.session.condition(3).name = 'CS-';
dcm.session.condition(3).index = find(infod.conds==8)';
dcm.data_options.norm = 0;
dcm.data_options.filter.def = 0;
dcm.resp_options.crfupdate = 0;
dcm.resp_options.indrf = 0;
dcm.resp_options.getrf = 0;
dcm.resp_options.rf = 0;
dcm.inv_options.depth = 2;
dcm.inv_options.sfpre = 2;
dcm.inv_options.sfpost = 5;
dcm.inv_options.sffreq = 0.5;
dcm.inv_options.sclpre = 2;
dcm.inv_options.sclpost = 5;
dcm.inv_options.ascr_sigma_offset = 0.1;
dcm.disp_options.dispwin = 1;
dcm.disp_options.dispsmallwin = 0;

matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm= dcm;
try
% run job
scr_jobman('run', matlabbatch);
catch
   errors(end+1)={outfilename}; 
end

  end%pbn
