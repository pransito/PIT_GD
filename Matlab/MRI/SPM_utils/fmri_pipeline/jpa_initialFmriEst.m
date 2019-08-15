function matlabbatch = jpa_initialFmriEst(varargin)
% Function that initializes the SPM module fmri_est with default
% parameters if nothing specified
%
% Syntax:  
%    jpa_initialFmriEst()
%    jpa_initialFmriEst(matlabbatch)
%    jpa_initialFmriEst(matlabbatch, fmri_est)
%
% Inputs:
%    matlabbatch     - SPM-Struct which contains SPM-Modules
%    fmri_est        - initial values for fmri_est - if nothing
%                         specified default values will be writen
%
% Outputs:
%    matlabbatch    - SPM-Struct which contains SPM-Modules including
%                     factorial_design
%
% Example:
%    jpa_initialFmriEst()
%    jpa_initialFmriEst('matlabbatch')
%    jpa_initialFmriEst('matlabbatch','fmri_est')
%       where fmri_est:
%           .spmmat             - cfg_dep class of SPM
%           .method.Classical   - method used to run batch
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:     jpa_initialFDAnova, jpa_initialFDMreg, jpa_initialFDTtest

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 11-Sep-2015

%------------- BEGIN CODE --------------
% no iput arguments
if nargin == 0
    m = 0;
end
% one or two input arguments
if nargin == 1 || nargin == 2
    % first has to be always matlabbatch
    matlabbatch = varargin{1};
    % determine size of matlabbatch to get number of all modules in it
    [f, m] = size(matlabbatch);
    % go through all Modules of matlabbatch and determine if Module already
    % exists
    for i=1:1:m
        % check for Structure
        if  isfield(matlabbatch{1,i}, 'spm')
            % check for stats field
            if isfield(matlabbatch{1,i}.spm, 'stats')
                % check for fmri_est field
                if isfield(matlabbatch{1,i}.spm.stats, 'fmri_est')
                    error('Batch already contains Module fmri-Estimation')
                end
            end
        end
    end
end
% no or 1 input argument(s)
if nargin == 0 || nargin == 1
    % no values have been transmitted so we initialize fmri_est
    % Modul with default values
    fmri_est.spmmat(1) = cfg_dep;
    fmri_est.spmmat(1).tname = 'Select SPM.mat';
    fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
    fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
    fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    fmri_est.method.Classical = 1;
end
% only for 2 input arguments
if  nargin == 2
    % the desired values are in Argument 2, so we initialize 
    % factorial_design with these values if exist
    fmri_est = varargin{2};
    % check for field "spmmat"
    if  ~isfield(fmri_est, 'spmmat')
        fmri_est.spmmat(1) = cfg_dep;
        fmri_est.spmmat(1).tname = 'Select SPM.mat';
        fmri_est.spmmat(1).tgt_spec{1}(1).name  = 'filter';
        fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
        fmri_est.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
        fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
        fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
        fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
        fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    end
    % check for field "method"
    if  ~isfield(fmri_est, 'method')
        fmri_est.method.Classical = 1;
    else
        % check for field method.'Classical'
        if ~isfield(con.method, 'Classical')
            fmri_est.method.Classical = 1;
        end
    end
end
% write fmri_est module at next free field in matlabbatch
matlabbatch{m+1}.spm.stats.fmri_est = fmri_est;
end
%------------- END CODE --------------