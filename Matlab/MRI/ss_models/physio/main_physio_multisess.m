% Script main_physio_multisess
% Runs multiple session of PhysIO correction
%
%  main_physio_multisess
%
%
%   See also
%
% Author:   Lars Kasper
% Created:  2017-01-10
% Copyright (C) 2017 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_script2.m 354 2013-12-02 22:21:41Z kasperla $
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load template matlabbatch & subject-specific files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear matlabbatch;
run('physio_job.m');

pathStudy  = '/Users/kasperla/Dropbox/Conferences/PhysioBerlin17/Demo/';
dirSubject = 'VPPG0207';

pathSubject = fullfile(pathStudy, dirSubject);

nameSessions = {
    'PDT_1'
    'PDT_2'
    };

nScans = [822, 838];

scan_timing_dicoms = {
    fullfile(pathSubject, '/MRT/160321_1540/006_MoCoSeries/1.3.12.2.1107.5.2.32.35435.2016032115500665935992039.dcm')
    fullfile(pathSubject, '/MRT/160321_1540/008_MoCoSeries/1.3.12.2.1107.5.2.32.35435.2016032116182549593858151.dcm')
    };

rp_files = {fullfile(pathSubject, 'MRT/NIFTI/006_MoCoSeries/rp_aepi_run1_MoCoAP_MoCo_00001.txt') , ...
    fullfile(pathSubject, 'MRT/NIFTI/008_MoCoSeries/rp_aepi_run2_MoCoAP_MoCo_00001.txt')
    };


nSessions = numel(nameSessions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fill up batch with session/specific files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iSession = 1:nSessions
    
    save_dir = fullfile(pathSubject, 'Physio', 'results', nameSessions{iSession});
    
    mkdir(save_dir);
    
    log_file = fullfile(pathSubject, 'Physio', [dirSubject '_' nameSessions{iSession} '.puls']);
    
    
    matlabbatch{iSession} = matlabbatch{1};
    matlabbatch{iSession}.spm.tools.physio.save_dir = cellstr(save_dir);
    matlabbatch{iSession}.spm.tools.physio.log_files.cardiac = cellstr(log_file);
    matlabbatch{iSession}.spm.tools.physio.log_files.scan_timing = cellstr(scan_timing_dicoms{iSession});
    matlabbatch{iSession}.spm.tools.physio.scan_timing.sqpar.Nscans = nScans(iSession);
    matlabbatch{iSession}.spm.tools.physio.model.movement.yes.file_realignment_parameters = cellstr(rp_files{iSession});
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run physio regressor creation matlabbatch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm_jobman('run', matlabbatch);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run GLM setup/estimation matlabbatch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear matlabbatch;

% TODO@User: adapt subject specific image/regressor files
run('glm_job.m'); 

% TODO@User: Check via interactive instead of run
spm_jobman('run', matlabbatch);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create physio contrasts automatically from physio model and design and 
% report
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO@User: adapt subject specific physio/SPM/overlay
tapas_physio_report_contrasts(...
    'filePhysIO', 'PhysIO/results/PDT_1/physio.mat', ...
    'fileSpm', 'Glm/SPM.mat');