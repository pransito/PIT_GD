function con = jpa_getGppiContrasts(contrasts)
% Function that converts multiContrastInput struct to structure PPPI 
% analysis needs.
%
% Syntax:  
%    con = jpa_getGppiContrasts(contrasts)
%
% Inputs:
%    contrasts    - 1x1 struct where at least one contrast is defined. More
%                   than one contrast are defined in the same fields as the 
%                   first one, but separated with ',' or ';'.
%       with:    
%               .name           - cell array with names of each contrasts
%               .left           - cell array with 'left' definition for
%                                  each contrast
%               .right          - cell array with 'right' definition for
%                                  each contrast
%               .Weighted       - cell array with weights of each contrast
%               .MinEvents      - cell array with minimum number of events
%                                  of each contrast
%               .STAT           - cell array defining contrast type of each
%                                  contrast
%               .MinEventsPer   - cell array with MinEventsPer of each
%                                  contrast
%               .Prefix         - cell array containing prefix of each
%                                  contrast
%               .Contrail       - cell array containing contrail of each
%                                   contrast
%
% Outputs:
%    con          - Contrasts defined in input with a slightely changed
%                   structure that is needed for PPPI-function input-struct
%
% Example:
%    con = jpa_getGppiContrasts(contrasts)
%       with:
%           .name           = {'PPI_contrast1','PPI_contrast2'}
%           .left           = {{'etoh_on_onsets_r1','etoh_off_onsets_r1'}
%                               {'etoh_on_onsets_r1'}}
%           .right          = {{'none'}{'none'}}
%           .Weighted       = {0, 0}
%           .MinEvents      = {30, 30}
%           .STAT           = {'T', 'T'
%           .MinEventsPer   = { , }
%           .Prefix         = { , }
%           .Contrail       = { , }
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:   jpa_gppp_loop jpa_readContrasts

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2017; Last revision: 09-Aug-2017

%------------- BEGIN CODE --------------

% check if minimum required input is correct
if (~isfield(contrasts,'name') || ~isfield(contrasts,'left') ...
    || ~isfield(contrasts,'right') || ~isfield(contrasts,'MinEvents') ...
    || ~isfield(contrasts,'STAT'))
    error('Wrong structure of Input! Can not determine Contrasts!');
end

% get length and check for correctness
fnames = fieldnames(contrasts);
xLen = zeros(length(fnames), 1);
for fInd = 1:1:length(fnames)
     xLen(fInd) = length(contrasts.(fnames{fInd}));
end
xLen = xLen(xLen ~= 0);
fnames = fnames(logical(xLen));
if ~range(xLen) == 0
    error('Wrong structure of Input! Did you separated each contrast with a , smybol? Did you put brackets around each settings?');
end

% build PPI Contrasts
try
    for conInd=1:1:xLen(1)
       for fInd =1:1:length(fnames)
           con(conInd).(fnames{fInd}) = contrasts.(fnames{fInd}){conInd};
       end
    end
catch ME
    disp(ME.identifier)
    error('ERROR. Did you check all brackets when defining contrasts?');
end

%------------- END CODE --------------