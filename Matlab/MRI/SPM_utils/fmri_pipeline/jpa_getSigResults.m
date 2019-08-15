function sigRes = jpa_getSigResults(TabDat, atlas, pValue, varargin)
% Function that filters significant results from a SPM-Matlab
% TabDat-Structure.
%
% Syntax:  
%    jpa_getSigResults(TabDat, atlas, pValue [, cFWE, cFDR, pFWE, pFDR])
%
% Inputs:
%    TabDat  - SPM-Matlab Structure containing the T/F-Values of a 
%               statistical Test               
%    atlas   - Path to a file containing a anatomical region-name to every
%               Voxel-Coordinate
%    pValue  - p-Value
%    cFWE    - Boolean, enables the Cluster-Family-Wise-Error-Correction
%               evaluation
%    cFDR    - Boolean, enables the Cluster-False Detection Rate evaluation
%    pFWE    - Boolean, enables the Peak-Family-Wise-Error-Correction
%               evaluation
%    pFDR    - Boolean, enables the Peak-False Detection Rate evaluation
%
% Outputs:
%    sigRes    - Struct containing all Values of TabDat wich are over a
%                   certain pValue, labeled with anatomical region
%
% Example:
%           jpa_getSigResults(TabDat, 'C:/atlas1',0.05, 1, 1, 1, 1)
%
% Other m-files required: none
% Subfunctions: getSigRes
% MAT-files required: none
%
% See also:  

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

%% Input Parameters check
if nargin < 3
    error('Wrong number of Arguments');
elseif nargin == 3
    cFWE  = 1;
    cFDR = 1;
    pFWE = 1;
    pFDR = 1;
elseif nargin == 4
    cFWE  = varargin{1};
    cFDR = 1;
    pFWE = 1;
    pFDR = 1;
elseif nargin == 5
    cFWE  = varargin{1};
    cFDR = varargin{2};
    pFWE = 1;
    pFDR = 1;
elseif nargin == 6
    cFWE  = varargin{1};
    cFDR = varargin{2};
    pFWE = varargin{3};
    pFDR = 1;
else
    cFWE  = varargin{1};
    cFDR = varargin{2};
    pFWE = varargin{3};
    pFDR = varargin{4};
end

%% Initialization
% Initialisation Cluster FWE
sigRes.cFWE.dat = [];
sigRes.cFWE.peakCoord = [];
sigRes.cFWE.label = [];
% Initialisation Cluster FDR
sigRes.cFDR.dat = [];
sigRes.cFDR.peakCoord = [];
sigRes.cFDR.label = [];
% Initialisation Peak FWE
sigRes.pFWE.dat = [];
sigRes.pFWE.peakCoord = [];
sigRes.pFWE.label = [];
% Initialisation Peak FDR
sigRes.pFDR.dat = [];
sigRes.pFDR.peakCoord = [];
sigRes.pFDR.label = [];

%% run
% check for emptyness
if ~isfield(TabDat,'dat') || isempty(TabDat.dat)
    return;
end
try
    % try to load atlas
    xA = spm_atlas('load',atlas);
catch THEM
    disp('Could not load Atlas! because of reason:');
    disp(THEM.message);
    disp('set label to "NONE"');
    xA = 'NONE';
end

% get peakCoords
peakCoords = TabDat.dat(:,end);
% check sig Results for Cluster FWE
if cFWE
    % get FWE out of Table
    [sigRes.cFWE.dat, sigRes.cFWE.peakCoord, sigRes.cFWE.label] = getSigRes(TabDat,pValue,peakCoords,xA,3);
end
% check sig Results for Cluster FDR
if cFDR
    % get FDR out of Table
    [sigRes.cFDR.dat, sigRes.cFDR.peakCoord, sigRes.cFDR.label] = getSigRes(TabDat,pValue,peakCoords,xA,4);
end


% check sig Results for peak FWE
if pFWE
    [sigRes.pFWE.dat, sigRes.pFWE.peakCoord, sigRes.pFWE.label] = getSigRes(TabDat,pValue,peakCoords,xA,7);
end
% check sig Results for peak FDR
if pFDR
    [sigRes.pFDR.dat, sigRes.pFDR.peakCoord, sigRes.pFDR.label] = getSigRes(TabDat,pValue,peakCoords,xA,8);
end

end

% Function that filters the data to a certain threshold and gets the
% anatomical region of Coords
function [filter, peak, label] = getSigRes(TabDat,pValue,peakCoords,xA,TableNR)
raw = cell2mat(TabDat.dat(:,TableNR));
% filter
filter = raw(raw < pValue);
peak = peakCoords(raw < pValue);
% label
label = cell.empty;
for i=1:1:length(peak)
    if ~ischar(xA)
        label{i,1} = spm_atlas('query',xA,peak{i});
    else
        label{i,1} = 'NONE';
    end
end
end
%------------- END CODE --------------