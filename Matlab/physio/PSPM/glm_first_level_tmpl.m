%-----------------------------------------------------------------------
% Job saved on 24-Sep-2017 17:03:15 by cfg_util (rev $Rev: 701 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.datafile = {'E:\Google Drive\Library\MATLAB\PDT\physio\PSPM\kkk.mat'};
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.chan_nr.chan_nr_spec = 2;
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.sample_rate = 1000;
matlabbatch{1}.pspm{1}.prep{1}.import.datatype.mat.importtype{1}.scr.transfer.none = true;
matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = false;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.modelfile = 'some_name.mat';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.outdir = {'E:\Google Drive\Library\MATLAB\PDT\physio\PSPM\dsffd'};
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.chan.chan_def = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.timeunits.seconds = 'seconds';
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.missing.no_epochs = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.data_design.condfile = {'E:\Google Drive\Library\MATLAB\PDT\physio\PSPM\fasfsa.mat'};
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.session.nuisancefile = {''};
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.bf.scrf1 = 1;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.norm = false;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.filter.def = 0;
matlabbatch{2}.pspm{1}.first_level{1}.scr{1}.glm_scr.overwrite = false;
