function [contrastNames, contrastWeights, contrastRep] = jpa_getStandardFContrast(lengthOfCon)
% Function that gives the here designed stadard F Contrasts for a specified
% length back.
%
% Syntax:  
%    [a,b,c] = jpa_getStandardFContrast(lengthOfCon)
%
% Inputs:
%    lengthOfCon    - the length of Contrasts to be designed here
%
% Outputs:
%    contrastNames    - Names for the standard F-Contrasts
%    contrastWeights  - calculated weights for the standard F-Contrasts
%    contrastRep      - initialized contrastReplication for F-Contrasts
%                           (set to 'none')
%
% Example:
%    [a,b,c] = jpa_getStandardFContrast(5)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address: alexander.genauck@charite.de
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 21-Sep-2015

%------------- BEGIN CODE --------------

%% check for mistakes
if nargin~=1
    error('No Number of Groups specified!')
end
if lengthOfCon < 1 
   error(['Number of Group = ' ,lengthOfCon, '. Not able to build Contrasts' ]);
end

%% Effect Of Interest contrast
contrastNames{1} = 'EOI';
contrastWeights{1} = eye(lengthOfCon);
contrastRep{1} = 'none';

%% Main Effect of groups
contrastNames{2} = 'ME';
% Initialisation
contrastWeights{2} = eye(lengthOfCon-1,lengthOfCon);
% hier nochmal nachfragen...
for i=2:1:lengthOfCon % run through cols
    % set negative contrast
   contrastWeights{2}(i-1,i) = -1;
end
contrastRep{2} = 'none';

end
%------------- END CODE --------------