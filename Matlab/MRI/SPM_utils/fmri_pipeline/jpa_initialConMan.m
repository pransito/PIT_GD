function matlabbatch = jpa_initialConMan(varargin)
% Function that initializes the SPM module Contrast Manager with default
% parameters if nothing specified
%
% Syntax:  
%    jpa_initialConMan()
%    jpa_initialConMan(matlabbatch)
%    jpa_initialConMan(matlabbatch, con)
%
% Inputs:
%    matlabbatch    - SPM-Struct which contains SPM-Modules
%    con            - initial values for contrast-manager - if nothing
%                     specified default values will be writen
%
% Outputs:
%    matlabbatch    - SPM-Struct which contains SPM-Modules including
%                     Contrast-Manager
%                    
% Example:
%    jpa_depthSearch()
%    jpa_depthSearch('matlabbatch')
%    jpa_depthSearch('matlabbatch','con')
%       where con:
%           .spmmat      - cfg_dep class of SPM
%           .consess     - contains T,F- Contraste
%           .delete      - Bool to decide weather to delete old contrasts
%                               if new ones are written or not
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_initialFactorialDesign,  jpa_initialFmriEst

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 11-Sep-2015

%------------- BEGIN CODE --------------

% no iput arguments
if nargin == 0
    % length of matlabbatch is 0
    m = 0;
end
% one or two input arguments
if nargin == 1 || nargin == 2
    % first has to be always matlabbatch
    matlabbatch = varargin{1};
    % determine size of matlabbatch to get number of all modules in it
    [l, m] = size(matlabbatch);
    % go through all Modules of matlabbatch and determine if Module already
    % exists
    for i=1:1:m
        % check for Structure
        if  isfield(matlabbatch{1,i}, 'spm')
            % check for stats field
            if isfield(matlabbatch{1,i}.spm, 'stats')
                % check for con field
                if isfield(matlabbatch{1,i}.spm.stats, 'con')
                    error('Batch already contains Module Contrast-Manager')
                end
            end
        end
    end
end
% no or 1 input argument(s)
if nargin == 0 || nargin == 1
    % no values have been transmitted so we initialize contrast Manager
    % Modul with default values
    con.spmmat(1) = cfg_dep;
    con.spmmat(1).tname = 'Select SPM.mat';
    con.spmmat(1).tgt_spec{1}(1).name  = 'filter';
    con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    con.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
    con.spmmat(1).tgt_spec{1}(2).value = 'e';
    con.spmmat(1).sname = 'Model estimation: SPM.mat File';
    con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    con.spmmat(1).src_output = substruct('.','spmmat');
    con.consess = cell.empty;
    con.delete = 0;
end
% only for 2 input arguments
if  nargin == 2
    % the desired values are in Argument 2, so we initialize Contrast
    % Manager with these values if exist
    con = varargin{2};
    if  ~isfield(con, 'spmmat')
        con.spmmat(1) = cfg_dep;
        con.spmmat(1).tname = 'Select SPM.mat';
        con.spmmat(1).tgt_spec{1}(1).name  = 'filter';
        con.spmmat(1).tgt_spec{1}(1).value = 'mat';
        con.spmmat(1).tgt_spec{1}(2).name  = 'strtype';
        con.spmmat(1).tgt_spec{1}(2).value = 'e';
        con.spmmat(1).sname = 'Model estimation: SPM.mat File';
        con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
        con.spmmat(1).src_output = substruct('.','spmmat');
    end
    % chek for field consess
    if  ~isfield(con, 'consess')
        con.consess = cell.empty;
    end
    % check for field delete
    if  ~isfield(con, 'delete')
        con.delete = 0;
    end
end
% write con module at next free field in matlabbatch
matlabbatch{m+1}.spm.stats.con = con;
end
%------------- END CODE --------------