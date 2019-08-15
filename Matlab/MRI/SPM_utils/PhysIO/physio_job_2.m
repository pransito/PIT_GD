%-----------------------------------------------------------------------
% Job saved on 10-Jan-2017 15:41:18 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% additional comments
% creates a matlabbatch job to be run in SPM which will generate a
% design matrix with physio regressors

% where u wanna get all results and output files saved?
matlabbatch{1}.spm.tools.physio.save_dir = {'E:\Daten\VPPG\MRT\MRT\VPPG0285\MRT\NIFTI\results\PhysIO'};
% what scanner did you use?
matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Siemens';
% where is the .puls file?
matlabbatch{1}.spm.tools.physio.log_files.cardiac = {'E:\Daten\VPPG\MRT\MRT\VPPG0285\Physio\VPPG0285_REST.puls'};
% we did not not do respiration so leave blank with {''}
matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
% indidicate the path to first (or last) .dcm
% watch out; should order "increasing" (happens automtically in ls() cmd)
matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {'E:\Daten\VPPG\MRT\MRT\VPPG0285\MRT\170324_0827\018_MoCoSeries\1.3.12.2.1107.5.2.32.35435.2017032411102975946797862.dcm'};
% ignore for now
matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
% ignore for now
matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
% 'first' if first dicom provided, 'last' if ...
matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'first';
% you will have to provide this info (check phoenix or...)
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 33;
% ignore
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
% TR time (find in phoenix or...)
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 2;
% do you have dummy scans? I think not
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
% you will have to check this your self
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = 300;
% interleaved descending... how did you measure what is first slice?
% should be your reference slice from preprocessing 
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 17;
% detail: ignore
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
% ignore
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
% ignore
matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
% 'PPU' or 'ECG' (I think, check that!)
matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
% ignore it
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
% no idea; an outputfile?
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
% no idea
matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
% output file name
matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
% output file name
matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
% ignorieren
matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
% retroicore only useful if you have heart rate and breathing
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.hrv.yes.delays = 0;
matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
% if pp done already you can provide the movement params here 
% or leave empty if not yet
matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {''};
% how many movement regressors (default 6, but higher order possible)
% VOLTERRA movement regressors
matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 6;
% maybe automatic censoring also; if too much movement will be excluded
% (the volume)
matlabbatch{1}.spm.tools.physio.model.movement.yes.outlier_translation_mm = 1;
matlabbatch{1}.spm.tools.physio.model.movement.yes.outlier_rotation_deg = 1;
matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
matlabbatch{1}.spm.tools.physio.verbose.level = 2;
matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
