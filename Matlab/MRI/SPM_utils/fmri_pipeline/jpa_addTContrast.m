function matlabbatch = jpa_addTContrast(batch, nameOfTcon, weights, varargin)
% Function that adds a TContrast to a SPM Contrast Manager-Module
%
% Syntax:  
%    batch = jpa_addTContrast(batch, nameOfTcon, weights)
%    batch = jpa_addTContrast(batch, nameOfTcon, weights, sessrep)
%
% Inputs:
%    batch        - SPM-Struct which contains Module Contrast Manager
%    nameOfTcon   - Name of new TContrast
%    weights      - Weights of new TContrast
%    sessrep      - String containing Information about Session Replication
%
% Outputs:
%    matlabbatch    - SPM-Struct with all Modules it had before and
%                       the new TContrast in SPM Contrast Manager Module
%
% Example:
%    batch = jpa_addTContrast(matlabbatch, 'name1', [1 1], 'none')
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:   jpa_initialConMan

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

%% test for mistakes
if nargin < 3
    error('Number of Input-Arguments not correct!');
end
if ~ischar(nameOfTcon)
    error('Input Argument "nameOfTcon" not correct!');
end
if ~isvector(weights)
    error('Input Argument "weight" not correct!');
end
if nargin == 3
    sessrep = 'none';
else 
    sessrep = varargin{1};
end

%% Initialisierung
matlabbatch = batch;
% determine size
[l, m] = size(matlabbatch);
% check wich level is con-manager
conmanNum = 0;
for i=1:1:m
    % check for Structure
    if  isfield(matlabbatch{1,i}, 'spm')
        % check for stats field
        if isfield(matlabbatch{1,i}.spm, 'stats')
            % check for con field
            if isfield(matlabbatch{1,i}.spm.stats, 'con')
                % load structures in conman
                conman = matlabbatch{1,i}.spm.stats.con;
                conmanNum = i;
            end
        end
    end
end
% end of loop, conman not found
if i == m && conmanNum == 0
    error('Batch does not contain Module Contrast-Manager')
end

%% add Contrast
% check for contrasts
[l, j] = size(conman.consess);
% design new tcon
c.tcon.name = nameOfTcon;
c.tcon.weights = weights;
c.tcon.sessrep = sessrep;

% add a contrast at position j+1 to not delete anything
conman.consess{1,(j+1)} = c;

% include in batch
matlabbatch{1,conmanNum}.spm.stats.con = conman;
end
%------------- END CODE --------------