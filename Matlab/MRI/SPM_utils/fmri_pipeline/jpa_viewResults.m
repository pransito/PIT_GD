function jpa_viewResults(mricroGLPath, overlayload, loadimage, varargin)
% jpa_start_mricro - checks if MRIcroGL Startscript-Bit in the .ini file
% is set and starts the Programm with a Startscript designed here
%
% For a detailed Discription of possible Parameters for MRIcroGL StartScript
% see Documentation under
% http://www.mccauslandcenter.sc.edu/CRNL/sw/mricrogl/manual.pdf
%
% Syntax:  jpa_viewResults
%
% Inputs:
%
%
% Outputs:
%     MRIcroGL.ini - Ini-File which sets startup-Parameters for MRIcroGL
%
% Example:
%    jpa_viewResults
%
%
% Other m-files required: jpa_buildStartupScript_mricro
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_buildStartupScript_mricro

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 04-Sep-2015

%------------- BEGIN CODE --------------

% check input-values
if nargin < 3
    error('Input Arguments not correct!');
elseif nargin == 3
    shaderName = 'edge_phong';
    colSchem = '1hot';
    sigres = 'none';
elseif nargin == 4
    shaderName = varargin{1};
    colSchem = '1hot';
    sigres = 'none';
elseif nargin == 5
    shaderName = varargin{1};
    colSchem = varargin{2};
    sigres = 'none';
else
    shaderName = varargin{1};
    colSchem = varargin{2};
    sigres = varargin{3};
end

%% Initialisierung
user_name = getenv('USERNAME');
%root_path = ['C:\Users\',user_name,filesep] ;
% path to ini
%ini_path = [root_path, 'AppData\Roaming' filesep ];
ini_path = mricroGLPath;
% add path to search-Enviroment
addpath(pwd);


%% ###############  MRIcroGL Script ###############
% get MRIcroGLDefaults
mricro = jpa_getMRIcroGlDefaults();
% ________________________________NECESSARY________________________________
% Fill the necessary Parts
mricro.loadimage{1} = loadimage;
% Select layer(s) to overlay
mricro.overlayload{1} = overlayload;
% _____________________________OPTIONAL____________________________________
% Fill the optional Parts
mricro.shadername{1} = shaderName;

mricro.overlaycolorname{1} = ['1,' colSchem];
% get the Maximum Intensity-value for each overlay & set Color Intensity
for index=1:1:length(mricro.overlayload)
    if ~strcmp(mricro.overlayload(index),'')
        [minV, maxV] = jpa_getIntensityValues(mricro.overlayload{index});
        % calculate Minimum (2 Percent of Maximum) for Color-Schema
        min = maxV/100 * 2;
        % set Maximum for colorbar
        mricro.overlayminmax{index} = [ num2str(index) , ',', num2str(min),',', num2str(maxV)];
    end
end

% .......................... Build Sphere Image............................
% Builds an Image with a 3D-dot at peak coords out of sigres
if ~strcmp(sigres,'none')
    % THIS PART IS NOT READY ... :(
    % get peak_coord out of sigres
    cur_coord = [ -50 14 -6 ];
    % path to SPM
    cur_SPM = 'F:\fMRI\Example\results_2nd_level\ttest\groupstats_1lvl_Results_grp1_covAgeEdu_con_0001\SPM.mat';
    [folder file ext] = fileparts(cur_SPM);
    % set Name for .nii
    %cur_name  = cellstr(all_sig_results(2).labels{2});
    cur_name  = cellstr('con_0002');
    
    % build .nii
    if ~exist(['F:\fMRI\Example\results_2nd_level\ttest\groupstats_1lvl_Results_grp1_covAgeEdu_con_0001\' 'display'],'dir'); mkdir('F:\fMRI\Example\results_2nd_level\ttest\groupstats_1lvl_Results_grp1_covAgeEdu_con_0001\display'); end
    cd ('F:\fMRI\Example\results_2nd_level\ttest\groupstats_1lvl_Results_grp1_covAgeEdu_con_0001\display\');
    create_sphere_image(cur_SPM,cur_coord,cur_name,repmat(8,3,1));
else
    cur_coord = [0 0 0];
end

% ..........................Rotation.......................................
% starting position for Rotation, do not change
mricro.azimuthelevation{1} = '90,0';
% set Rotation elevation
mricro.elevation{1} = num2str(jpa_calcYAxesRotation(cur_coord));
% set Rotation azimuth
mricro.azimuth{1} = num2str(jpa_calcZAxesRotation(cur_coord));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Calculating               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check for .ini & aktivate Startup-Script
% Check for 32 / 64-bit version & set path
if strcmp(computer('arch'),'win64')
    % set Path to file
    file_path = fullfile(ini_path, 'MRIcroGL64.ini');
else
    % set Path to file
    file_path = fullfile(ini_path, 'MRIcroGL.ini');
end
% Initialisation
lineRow = cell(100);
% check for Startup-Script
if exist(file_path, 'file')
    counter = 1;
    try
        % open file
        iniFile = fopen(file_path, 'r+');
        % read file line-by-line
        while ~feof(iniFile)
            lineRow{counter} = fgetl(iniFile);
            counter = counter +1;
            if counter == 101
                disp('Could not read .ini file! File too long.');
                fclose(iniFile);
                return;
            end
        end
        % close File
        fclose(iniFile);
        % delete file
        delete(file_path);
        % open file as new
        iniFile = fopen(file_path, 'a+');
        % write line-by-line
        for i=1:1:counter-1
            % search for StartupScript-Bit & activate
            if strcmp(lineRow{i} ,'StartupScript=0')
                lineRow{i} = strrep(lineRow{i},'StartupScript=0','StartupScript=1');
            end
            % search for GridAndBorder and replace Color with
            % backgroundColor
            if regexp(lineRow{i},'GridAndBorder=(\d+|)+')
                color = [strrep(mricro.backcolor{1},',','|') '|0'];
                lineRow{i} = regexprep(lineRow{i},'GridAndBorder=(\d+|)+',['GridAndBorder=' color]);
            end
            % write line in file
            fprintf(iniFile,'%s\n', lineRow{i});
        end
        % close file
        fclose(iniFile);
        disp('.ini file successfully written');
    catch ME %if you can...
        % display Error-Message
        fclose(iniFile);
        disp(ME.identifier)
    end
    % create startup-Script
    jpa_buildStartupScript_mricro(mricro,[mricroGLPath, filesep])
else
    disp('MRIcroGL.ini does not exist! Please start MRIcroGL once!')
    return;
end
% show message box
[pathstr,name] = fileparts(overlayload);
h = msgbox(['You are looking at ' name '. Click OK when finished.']);
% start Program
% launches the program for 64-bit or 32-bit architecture
if strcmp(computer('arch'),'win64')
    % change path to start
    cd(mricroGLPath);
    %!MRIcroGL64.exe &
else
    % change path to start
    cd(mricroGLPath);
    !MRIcroGL.exe &
end
% wait for message-Box to be klicked then plot Images if desired
waitfor(h)

%% Add Colorbar and Titel to saved Pictures
% get Images
images = jpa_getDirs(fullfile(pathstr, [name 'Pictures']), '*.png');

% get plot_defaults
plot = jpa_getPlotDefaults();
% Routine that adds a ColorBar and Titel for each Picture
for i=1:1:length(images)
    [savePath,namePicture] = fileparts(images{i});
    % set Path where to save picture
    plot.savePath = fullfile(savePath,'edited');
    %% add colorbar to Pictures
    plot.img = images{i};
    % set path to ColScheme
    plot.colScheme = fullfile(mricroGLPath, 'lut' , [colSchem '.clut'] );
    % set description
    if length(name) < 4 || strcmp(name(4), 'T')
        plot.colorbar.description = 'T-Value';
    else plot.colorbar.description = 'F-Value';
    end
    jpa_addColorBar(plot);
    %% add Titel to Pictures
    % set titel of picture
    plot.titel.text = strrep(name, '_', '-');
    jpa_addTitel(plot);
end
% Display Message
disp('End of Presentation!');
end
%------------- END OF CODE --------------