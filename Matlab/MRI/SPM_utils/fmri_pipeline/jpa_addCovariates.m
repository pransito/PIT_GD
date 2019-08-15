function matlabbatch = jpa_addCovariates(batch, c, cname, varargin)
% Function that adds a Covaraite to a SPM Fractorial Design Module 
%
% Syntax:  
%    batch = jpa_addCovariates(matlabbatch, batch, c ,cmame)
%    batch = jpa_addCovariates(matlabbatch, batch, c ,cmame, iCFI, iCC)
%
% Inputs:
%    batch        - SPM-Struct which contains Module Fractorial Design
%    c            - values of the new Covariate
%    cname        - Name of new Covariate
%    iCFI         - Boolean
%    iCC          - Boolean
%
% Outputs:
%    matlabbatch    - SPM-Struct with all Modules it had before and
%                       the new Covariate in Factorial Design Modul
%                    
% Example:
%     batch = jpa_addCovariates(matlabbatch, batch, [23 24] ,'name1', 1, 1)
%     batch = jpa_addCovariates(matlabbatch, batch, [23 24 32 43] ,'name1')
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:   jpa_initialFDAnova, jpa_initialFDTtest, jpa_initialFDMreg

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 17-Sep-2015

%------------- BEGIN CODE --------------

%% test for mistakes
if nargin < 3
    error('Input Arguments not correct!');
elseif nargin == 3
    iCFI = 1;
    iCC = 1;
elseif nargin == 4
    iCFI = varargin{1};
    iCC = 1;
else
    iCFI = varargin{1};
    iCC = varargin{2};
end
if ~isvector(c)
    error('Input Arguments not correct!');
end

%% Initialisierung
matlabbatch = batch;
% determine size
[p, m] = size(matlabbatch);
% check wich level is con-manager
factorial_designNum = 0;
for i=1:1:m
    % check for Structure
    if  isfield(matlabbatch{1,i}, 'spm')
        % check for stats field
        if isfield(matlabbatch{1,i}.spm, 'stats')
            % check for factorial_design field
            if isfield(matlabbatch{1,i}.spm.stats, 'factorial_design')
                % load structures in conman
                covman = matlabbatch{1,i}.spm.stats.factorial_design.cov;
                factorial_designNum = i;
            end
        end
    end
    % end of loop, conman not found
    if i == m && factorial_designNum == 0
        error('Batch does not contain Module factorial_design')
    end
end

%% Add Covariate
% check for covariates
if isfield(covman,'c')
    [p, j] = size(covman);
    covman(j+1).c = c;
    covman(j+1).cname = cname;
    covman(j+1).iCFI = iCFI;
    covman(j+1).iCC = iCC;
else
    covman(1).c = c;
    covman(1).cname = cname;
    covman(1).iCFI = iCFI;
    covman(1).iCC = iCC;
end
% include in batch
matlabbatch{1,factorial_designNum}.spm.stats.factorial_design.cov = covman;
end
%------------- END CODE --------------