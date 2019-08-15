function jpa_plot
% jpa_plot - here you specify all the options needed for jpa_plotMriCro
%
% Syntax:  jpa_plot
%
% Example:
%    jpa_plot
%
%
% Other m-files required: jpa_plotMriCro
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_addColorBar,  jpa_plotMriCro,  jpa_addTitel

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 03-Sep-2015

%------------- BEGIN CODE --------------

%% ############### PicturePlot ###############
% with this option you can plot the pictures you have in a specified folder

% ________________________________NECESSARY________________________________
% whish to plot the Pictures you made from MricoGL?
plot_pic.on = 1;
% set Path to Pictures
plot_pic.path = 'F:\fMRI\Example\results_2nd_level\ttest\groupstats_1lvl_Results_grp1_covAgeEdu_con_0001\display';
% set MaxCollum per Page
plot_pic.settings.maxCols = 1;
% set MaxRows per Page
plot_pic.settings.maxRows = 1;
% _____________________________OPTIONAL____________________________________
% specify exactly the number of Pictures per Page
plot_pic.settings.picPerPage = [];

%% ............................ colorbar ..................................
% Here you specify settings for a colorbar to beadded to all Pictures under
% the specified path obove!
%
% turn on colorbar
plot_pic.colorbar.on = true;
% postition x,y,widh,height
% [0.9 0.1 0.02 0.8] for a small colorbar at the right
% [0.1 0.1 0.02 0.8] for a small colorbar at the left
% [0.1 0.1 0.8 0.02] for a small colorbar at the botton
% [0.1 0.9 0.8 0.02] for a small colorbar at the top
plot_pic.colorbar.position = [0.9 0.1 0.02 0.8];
% set description for Colorbar
plot_pic.colorbar.description = 'T-Value';
% Minimum value
plot_pic.colorbar.min = min;
% Maximum Value
plot_pic.colorbar.max = maxV;
% set FontSize for Colorbar
plot_pic.colorbar.FontSize = 10;
% bgcolor
color = textscan(mricro.backcolor{1},'%s','Delimiter',',');
plot_pic.bgcolor(1) = str2double(color{1}{1});  % red channel
plot_pic.bgcolor(2) = str2double(color{1}{2});  % green channel
plot_pic.bgcolor(3) = str2double(color{1}{3});  % blue channel
% scheme of picture is calculatet by first overlaycolorname
plot_pic.colScheme = strcat(strcat(strcat(mricroGLPath ,'lut\'),regexprep(mricro.overlaycolorname{1},'\d,','')),'.clut');

%% ............................ titel .....................................
% Here you specify settings for a titel to beadded to all Pictures under
% the specified path obove!
% turn on Titel
plot_pic.titel. on = 1;
% set text of titel
plot_pic.titel.text = 'ttest-grp1-con-0002';
% set position of Titel
% Format: [distanceFromLeftInPercent distanceFromTopInPercent]
plot_pic.titel.position = [0.1 0.1];
% set fontSize of Titel
plot_pic.titel.FontSize = 14;


%% start Script
jpa_plotMriCro(plot)
end
%------------- END OF CODE --------------