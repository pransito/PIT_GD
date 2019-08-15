%-----------------------------------------------------------------------
% Job saved on 10-Jan-2017 15:41:18 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.physio.save_dir = {'/Users/kasperla/Dropbox/Conferences/PhysioBerlin17/Demo/VPPG0207/PhysIO/results'};
matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Siemens';
matlabbatch{1}.spm.tools.physio.log_files.cardiac = {'/Users/kasperla/Dropbox/Conferences/PhysioBerlin17/Demo/VPPG0207/PhysIO/VPPG0207_PDT_1.puls'};
matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {'/Users/kasperla/Dropbox/Conferences/PhysioBerlin17/Demo/VPPG0207/MRT/160321_1540/006_MoCoSeries/1.3.12.2.1107.5.2.32.35435.2016032115500665935992039.dcm'};
matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'first';
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 33;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 2;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = 822;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 17; % in PP I say "1"; is because of interleaved ascending?! 
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.hrv.yes.delays = 0;
matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {'/Users/kasperla/Dropbox/Conferences/PhysioBerlin17/Demo/VPPG0207/MRT/NIFTI/006_MoCoSeries/rp_aepi_run1_MoCoAP_MoCo_00001.txt'};
matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 6;
matlabbatch{1}.spm.tools.physio.model.movement.yes.outlier_translation_mm = 1;
matlabbatch{1}.spm.tools.physio.model.movement.yes.outlier_rotation_deg = 1;
matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
matlabbatch{1}.spm.tools.physio.verbose.level = 2;
matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
