function jpa_buildStartupScript_mricro(mricro, mricroGL_path)
% jpa_buildStartupScript_mricro - builds the Startupscript under a given
% path with the Parameters specified in mricro
%
% For a detailed Discription of possible Parameters for MRIcroGL StartScript
% see Documentation under 
% http://www.mccauslandcenter.sc.edu/CRNL/sw/mricrogl/manual.pdf
%
% Syntax:  jpa_buildStartupScript_mricro(mricro,'C:\path')
%
% Inputs:
%    mricro                   - contains the orders for the startupscript
%    COUTION: EVERYTHING HAS TO BE A STRING!
%    ###########the following parameters are optional ##########
%      mricro.loadimage{1}    - Path to .nii to load 
%      mricro.overlayloadsmooth{1}  - trilinear (true) or nearest neighbor 
%                                        (false) Interpolation
%      mricro.overlayload{1}  - first overlay.nii to load
%      mricro.overlayload{2}  - second overlay.nii to load
%      mricro.shadername{1}   - shader to user for .nii
%      mricro.framevisible{1} - orientation cube on(true) or off(false)
%      mricro.elevation{1}    - set z-axis rotation
%      mricro.azimuth{1}      - set x-axis rotation
%      mricro.backcolor{1}    - Backgroundcolor of .nii
%           RGB:    255,255,255 = white; 0,0,0 = black; 255,0,0 = red;
%                   0,255,0 = green ; 0,0,255 = blue ;
%      mricro.colorname{1}    - color-scheme for loadimage
%      mricro.overlaycolorname{1} - color-scheme for first overlay
%      mricro.overlaycolorname{2} - color-scheme for second overlay
%      mricro.colorbarcoord{1}    - Coords for MRICROGL Color-Bar
%           DO NOT USE WHEN YOU USE sphere_image OPTION!
            % (left, top , right, botton): 0.93,0.1,0.95,0.9
%      mricro.colorbarvisible{1}  - disable MRICROGL Color-Bar
%    mricroGL_path            - Path to Installation-Folder of MRIcroGL
%                               has to end with microgl\
%
%
% Outputs:
%     startup.gls - Script which sets startup-Parameters for MRIcroGL
%
%
% Example:
%    jpa_buildStartupScript_mricro(mricro, 'C:\Program Files\mricrogl\')
%       where:
%       mricro.loadimage{1} = 'C:\Program Files\mricrogl\mni152_2009bet.nii.gz'
%       mricro.overlayloadsmooth{1} = 'true'
%       mricro.overlayload{1} = 'C:\Program Files\mricrogl\motor.nii.gz'
%       mricro.overlayload{2} = ''
%       mricro.shadername{1} = 'edge_phong'
%       mricro.framevisible{1} = 'false'
%       mricro.elevation{1} = '90'
%       mricro.azimuth{1} = '45'
%       mricro.backcolor{1} = '0,0,0'
%       mricro.colorname{1} = 'Grayscale' 
%       mricro.overlaycolorname{1} = '1,1hot'
%       mricro.overlaycolorname{2} = '2,1hot'
%       mricro.colorbarcoord{1} = '0.93,0.1,0.95,0.9'
%       mricro.colorbarvisible{1} = 'false'
%
%
% Other m-files required: jpa_addColorBar, jpa_addTitel
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_start_mricro

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 03-Sep-2015

%------------- BEGIN CODE --------------

%% Initialisation
% declaire necessary Variables
startScript{1} = 'BEGIN';
startScript{2} = 'RESETDEFAULTS;';
scriptIndex = 3;
mricroGLScript_file = [mricroGL_path, 'script' filesep 'startup.gls'];
% get the names of the variables of mricro
namesMricro = cellstr(fieldnames(mricro));

%% Routine
% routine that runs through the fields and build the script
for mriIndex=1:1:length(fieldnames(mricro))
    for mriValueIndex=1:1:length(mricro.(namesMricro{mriIndex}))
        % empty fields will be ignored
        if  strcmp(mricro.(namesMricro{mriIndex}){mriValueIndex}, '')
            continue;
        else
            % open line
            startScriptLine = [namesMricro{mriIndex},'('];
            % get values from the mricro."namesMricro"-field
            values =textscan(mricro.(namesMricro{mriIndex}){mriValueIndex},'%s','Delimiter',',');
            % test if empty
            if ~strcmp(values{1}{1},'')
                % building Scriptline with name of variables in mricro and their content
                % connected with necessary brackets
                % decide weather its numeric value or string
                [x,status] = str2num(values{1}{1});
                if ~status
                    % build script line for non numeric values
                    startScriptLineValue = [ char(39)  ,values{1}{1}, char(39)];
                else
                    % build script line for numeric values
                    startScriptLineValue = [values{1}{1}];
                end
            end
            % do same with the rest of the values
            for valuesIndex=2:(length(values{1}))
                % test weather value is empty
                if ~strcmp(values{1}{valuesIndex},'')
                    % building Script with name of variables in mricro and their content
                    % connected with necessary brackets
                    % decide weather its numeric value or string
                    [x,status] = str2num(values{1}{valuesIndex});
                    if ~status
                        % build script line for non numeric values
                        startScriptLineValue = [ startScriptLineValue,',', char(39)  ,values{1}{valuesIndex}, char(39)];
                    else
                        % build script line for numeric values
                        startScriptLineValue = [ startScriptLineValue,',',values{1}{valuesIndex}];
                    end
                end
            end
            %close line
            startScriptLine = [startScriptLine ,startScriptLineValue,');'];
            startScript{scriptIndex} = startScriptLine;
            scriptIndex = scriptIndex +1;
        end
    end
end
% set last entry of Script
startScript{scriptIndex} = 'END.';

%% Display
% uncomment to not see Script in console
for i=1:length(startScript)
    disp(startScript{i});
end

%% write Script to file
% writes the Script to the file under mricroGLScript_file-path
% check for existence
if exist(mricroGLScript_file, 'file')
    delete(mricroGLScript_file);
end
% write in file
try
    % open file
    [startupFile,error] = fopen(mricroGLScript_file, 'wt');
    % print every line
    for index=1:length(startScript)
        fprintf(startupFile,'%s\n', startScript{index});
    end
    % close file
    fclose(startupFile);
    disp('startupfile file successfully written');
catch ME
    % display Error-Message
    disp('could not write file because of reason:');
    error(ME.identifier);
end
end