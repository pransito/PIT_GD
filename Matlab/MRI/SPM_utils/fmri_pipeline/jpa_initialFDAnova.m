function matlabbatch = jpa_initialFDAnova(varargin)
% Function that initializes the SPM module FactorialDesign with default
% parameters if nothing specified
%
% Syntax:  
%    jpa_initialFDAnova()
%    jpa_initialFDAnova(matlabbatch)
%    jpa_initialFDAnova(matlabbatch, factorial_design)
%
% Inputs:
%    matlabbatch      - SPM-Struct which contains SPM-Modules
%    factorial_design - initial values for factorial_design Anova
%                       if nothing specified default values will be writen
%
% Outputs:
%    matlabbatch    - SPM-Struct which contains SPM-Modules including
%                     factorial_design
%
% Example:
%    jpa_initialFactorialDesign()
%    jpa_initialFactorialDesign('matlabbatch')
%    jpa_initialFactorialDesign('matlabbatch','factorial_design')
%       where factorial_design can be:
%        .dir                     - direction where results are written
%        .des.anova.icell         - Struct with path to scans
%                                           for every group for example
%        .des.anova.dept          - independence 1: yes 0: no
%        .des.anova.variance      - Variance 1: unequal, 0: equal
%        .des.anova.gmsca         - grand mean scaling 1: yes  0: no
%        .des.anova.ancova        - Analysis of Covariance 1: yes, 0: no
%        .cov                     - SPM-Struct which contains covariates
%        .multi_cov               - Path to multi-Covariates-file(TXT/MAT)
%        .masking.tm.tm_none      - constant value for threshold
%        .masking.im              - Implicit Mask
%        .masking.em              - Explicit Mask
%        .globalc.g_omit          - constant value for omit
%        .globalm.gmsca.gmsca_no  - grand mean scaling
%        .globalm.glonorm         - Normalisation, can be 'None'
%                                                 'Proportional', 'ANCOVA'
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:    jpa_initialFDMreg, jpa_initialFDTtest, jpa_initialFmriEst

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 16-Sep-2015

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
                if isfield(matlabbatch{1,i}.spm.stats, 'factorial_design')
                    error('Batch already contains Module factorial_design')
                end
            end
        end
    end
end
% no or 1 input argument(s)
if nargin == 0 || nargin == 1
    % no values have been transmitted so we initialize factorial_design
    % Modul with default values
    factorial_design.dir = {''};
    factorial_design.des.anova.icell = struct.empty;
    factorial_design.cov = struct.empty;
    factorial_design.multi_cov = struct.empty;
    factorial_design.masking.tm.tm_none = 1;
    factorial_design.masking.im = 1;
    factorial_design.masking.em = {''};
    factorial_design.globalc.g_omit = 1;
    factorial_design.globalm.gmsca.gmsca_no = 1;
    factorial_design.globalm.glonorm = 1;
end
% only for 2 input arguments
if  nargin == 2
    % the desired values are in Argument 2, so we initialize
    % factorial_design with these values if exist
    factorial_design = varargin{2};
    % check for field "dir"
    if  ~isfield(factorial_design, 'dir')
        factorial_design.dir = {''};
    end
    % check for field "des"
    if  ~isfield(factorial_design, 'des')
        factorial_design.des.anova.icell = struct.empty;
        factorial_design.des.anova.dept = 0;
        factorial_design.des.anova.variance = 1;
        factorial_design.des.anova.gmsca = 0;
        factorial_design.des.anova.ancova = 0;
    else
        % check for field des."anova"
        if  ~isfield(factorial_design.des, 'anova')
            factorial_design.des.anova.icell = struct.empty;
            factorial_design.des.anova.dept = 0;
            factorial_design.des.anova.variance = 1;
            factorial_design.des.anova.gmsca = 0;
            factorial_design.des.anova.ancova = 0;
        else
            % check for field des."icell"
            if  ~isfield(factorial_design.des.anova, 'icell')
                factorial_design.des.anova.icell = struct.empty;
            end
            % check for field des."dept"
            if  ~isfield(factorial_design.des.anova, 'dept')
                factorial_design.des.anova.dept = 0;
            end
            % check for field des."variance"
            if  ~isfield(factorial_design.des.anova, 'variance')
                factorial_design.des.anova.variance = 1;
            end
            % check for field des."gmsca"
            if  ~isfield(factorial_design.des.anova, 'gmsca')
                factorial_design.des.anova.gmsca = 0;
            end
            % check for field des."ancova"
            if  ~isfield(factorial_design.des.anova, 'ancova')
                factorial_design.des.anova.ancova = 0;
            end
        end
    end
    % check for field cov
    if ~isfield(factorial_design, 'cov')
        factorial_design.cov = struct.empty;
    end
    % check for field multi_cov
    if ~isfield(factorial_design, 'multi_cov')
        factorial_design.multi_cov = struct.empty;
    end
    % check for field masking
    if  ~isfield(factorial_design, 'masking')
        factorial_design.masking.tm.tm_none = 1;
        factorial_design.masking.im = 1;
        factorial_design.masking.em = {''};
    else
        % check for field masking.'tm'
        if  ~isfield(factorial_design.masking, 'tm')
            factorial_design.masking.tm.tm_none = 1;
        else
            % check for field masking.tm.'tm_none'
            if  ~isfield(factorial_design.masking.tm, 'tm_none')
                factorial_design.masking.tm.tm_none = 1;
            end
        end
        % check for field masking.'im'
        if  ~isfield(factorial_design.masking, 'im')
            factorial_design.masking.im = 1;
        end
        % check for field masking.'em'
        if  ~isfield(factorial_design.masking, 'em')
            factorial_design.masking.em = {''};
        end
    end
    % check for field globalc
    if  ~isfield(factorial_design, 'globalc')
        factorial_design.globalc.g_omit = 1;
    else
        % check for field globalc.'g_omit'
        if  ~isfield(factorial_design.globalc, 'g_omit')
            factorial_design.globalc.g_omit = 1;
        end
    end
    % check for field globalm
    if  ~isfield(factorial_design, 'globalm')
        factorial_design.globalm.gmsca.gmsca_no = 1;
        factorial_design.globalm.glonorm = 1;
    else
        % check for field globalm.'gmsca'
        if  ~isfield(factorial_design.globalm, 'gmsca')
            factorial_design.globalm.gmsca.gmsca_no = 1;
        else
            % check for field globalm.gmsca.'gmsca_no'
            if  ~isfield(factorial_design.globalm.gmsca, 'gmsca_no')
                factorial_design.globalm.gmsca.gmsca_no = 1;
            end
        end
        % check for field globalm.'glonorm'
        if  ~isfield(factorial_design.globalm, 'glonorm')
            factorial_design.globalm.glonorm = 1;
        end
    end
    % write factorial_design module at next free field in matlabbatch
    matlabbatch{m+1}.spm.stats.factorial_design = factorial_design;
end
end
%------------- END CODE --------------