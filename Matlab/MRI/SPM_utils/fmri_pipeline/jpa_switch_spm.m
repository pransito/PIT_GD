function jpa_switch_spm(pathToSpmOld, pathToSpmNew, startSpm, delAllSPM)
% Function that switches the SPM version. Valid is SPM12 and SPM8.
% If only numbers are specified then function will set default path to spm
% First given number is from what version to change. Secound number is to
% what version to change to.
%
% Syntax:  
%    jpa_switch_spm(pathToSpmOld, pathToSpmNew)
%    jpa_switch_spm(pathToSpmOld, pathToSpmNew, startSpm)
%    jpa_switch_spm(pathToSpmOld, pathToSpmNew, startSpm, delAllSPM)
%
% Inputs:
%    pathToSpmOld    - string, Path to old SPM version
%                    OR integer, if so default path will be set
%                       i.e. matlabroot\toolbox\spmX
%    pathToSpmNew    - string, path to new SPM version
%                    OR integer, if so default path will be set
%                       i.e. matlabroot\toolbox\spmX
%    startSpm        - boolean, indicates weather to start SPM afterwards
%                       i.e. 0 will not start spm, 1 will do so
%   delAllSPM        - boolean, indicates weather to delete ALL SPM-paths  
%                       from the SPM version specified in pathToSpmOld 
%      DANGEROUS - can delete also Paths you actually don't want to delete!
%
% Outputs:
%                    
% Example:
%     jpa_switch_spm(8, 12, 0)
%     jpa_switch_spm('C:\Path\To\Old\SPM', 'C:\Path\To\Old\SPM')
%     jpa_switch_spm('C:\Path\To\Old\SPM', 'C:\Path\To\Old\SPM', 1)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:   

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website: https://github.com/jpalbrecht
% Jun 2017; Last revision: 09-Jun-2017

%------------- BEGIN CODE --------------
%% Initialize
% read matlab path
currPath = path;

%% Parsing Arguments
if nargin < 2
    error('Not enough input arguments. use help for more information about inputs!');
elseif nargin == 2
   startSpm = 0; 
   delAllSPM = 0;
elseif  nargin == 3
   if  (~isnumeric(startSpm) || startSpm == 0)
       startSpm = 0;
   end
   delAllSPM = 0;
elseif nargin == 4
    if  (~isnumeric(delAllSPM) || delAllSPM == 0)
        delAllSPM = 0;
    end
else
    error('Wrong number of arguments!')
end
% backup input
pathToSpmOldBC = pathToSpmOld;
% check if path or spm-version number is given
if (isnumeric(pathToSpmOld) && isnumeric(pathToSpmNew))
    disp('No path was specified! Trying to add standard path!')
   if ( pathToSpmOld == 8 && pathToSpmNew == 12 )
       pathToSpmOld = [matlabroot filesep 'toolbox' filesep 'spm8'];
       pathToSpmNew = [matlabroot filesep 'toolbox' filesep 'spm12'];
   elseif ( pathToSpmOld == 12 && pathToSpmNew == 8 )
       pathToSpmOld = [matlabroot filesep 'toolbox' filesep 'spm12'];
       pathToSpmNew = [matlabroot filesep 'toolbox' filesep 'spm8'];
   else 
       disp('Unknown spm version number!')
       return
   end
elseif isnumeric(pathToSpmOld)
    if pathToSpmOld == 8
        pathToSpmOld = [matlabroot filesep 'toolbox' filesep 'spm8'];
    elseif pathToSpmOld == 12
        pathToSpmOld = [matlabroot filesep 'toolbox' filesep 'spm12'];
    end
elseif isnumeric(pathToSpmNew)
    if pathToSpmNew == 8
        pathToSpmNew = [matlabroot filesep 'toolbox' filesep 'spm8'];
    elseif pathToSpmNew == 12
        pathToSpmNew = [matlabroot filesep 'toolbox' filesep 'spm12'];
    end
end
%% Change SPM version
% check for correctness
if ~isempty(strfind(currPath , pathToSpmNew ))
    disp([pathToSpmNew ' already exists in matlabPath!'])
    if startSpm
        eval('spm fmri');
    end
    return
end
% read spm version
try
    version = evalc('spm version');
catch
    disp('No SPMX detected. Just added SPM_path to matlab_path!')
    addpath(pathToSpmNew);
    if startSpm
        eval('spm fmri');
    end
    return
end 
% initialize newPath
newPath = '';
% split old path that its a cell Array
currPath =  textscan(currPath,'%s', 'delimiter' , ';');
currPath = currPath{1};
[lenPath,~] = size(currPath);
% delete every path that contains pathToSpmOld
if ~delAllSPM
    for ind=1:1:lenPath 
        if isempty(strfind(currPath{ind,1}, pathToSpmOld))
            newPath = [newPath ';' currPath{ind,1}];
        end
    end
else
    % delete every single path that contains raw input... dangerous!
    for ind=1:1:lenPath 
        if isempty(strfind(currPath{ind,1}, pathToSpmOldBC))
            newPath = [newPath ';' currPath{ind,1}];
        end
    end
end
% remove leading ; from newPath
newPath = newPath(2:end);
path(newPath);
% add new spm path to path
addpath(pathToSpmNew);
clear spm_jobman
if startSpm
    eval('spm fmri');
end
end
%------------- END CODE --------------