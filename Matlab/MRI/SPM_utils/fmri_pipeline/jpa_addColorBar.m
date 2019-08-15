function jpa_addColorBar(plot)
% Function that adds a colorbar to a picture to a specified
% color-Scheme from MRIcroGL and safes the Picture under a given path
%
% Syntax:  jpa_addColorBar(plot)
%
% Inputs:
%    plot
%   *   plot.img                - contains the name of the Image to load
%       plot.savePath           - path where to save edited Picture
%   *   plot.colSchem           - Path to Color-Scheme from MRIcroGL
%       plot.bgcolor            - Backgroundcolor of MRIcroGL-Images
%       plot.colorbar           - Contains settings for additional colorbar
%       plot.colorbar.min       - Sensitivity of Colorbar Minimum Value
%       plot.colorbar.Max       - Sensitivity of Colorbar Maximum Value
%       plot.colorbar.position  - Position of Colorbar.
%                 'north'	Top of axes	Horizontal
%                 'south'	Bottom of axes	Horizontal
%                 'east'	Right side of axes	Vertical
%                 'west'	Left side of axes	Vertical
%                 'northoutside'	Top outside of axes	Horizontal
%                 'southoutside'	Bottom outside of axes	Horizontal
%                 'eastoutside'	Right outside of axes (default)	Vertical
%                 'westoutside'	Left outside of axes	Vertical
%                 'manual' -> [left, bottom, width, height], for example:
%                   [0.9 0.1 0.02 0.8] for a small colorbar at the right
%                   [0.1 0.1 0.02 0.8] for a small colorbar at the left
%                   [0.1 0.1 0.8 0.02] for a small colorbar at the botton
%                   [0.1 0.9 0.8 0.02] for a small colorbar at the top
%       plot.colorbar.FontSize  - fonSize for the colorBar Intensity-Values
%       plot.colorbar.description - description of colorBar Intensity-Values
%
%   * = necessary for jpa_addColorBar
%
%
% Outputs:
%    .png - Picture saved in directory specified under plot.savePath
%
%
% Example:
%    jpa_addColorBar(plot)
%       where:
%       plot.img = 'C:\picturesToPlot\pic1.png'
%       plot.savePath  = 'C:\picturesToPlot\PicturesWithColBar';
%       plot.colSchem = 'C:\mricrogl\lut\1hot.clut'
%       plot.colorbar.min = 0
%       plot.colorbar.Max = 5
%       plot.colorbar.position = [0.1 0.1 0.3 0.7]
%       plot.colorbar.FontSize = 14
%       plot.colorbar.description = 'f-Value';
%       plot.bgcolor = [0 0 0]
%
%
% Other m-files required: jpa_addTitel
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_plotMriCro,  jpa_addTitel

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 04-Sep-2015

%------------- BEGIN CODE --------------

%% Standards if nothing specified

nobg = false;
if ~isfield(plot,'img') || isempty(plot.img)
    error('No Image to load!');
end
if ~isfield(plot,'colScheme') || isempty(plot.colScheme)
    error('No Color-Scheme to load!');
end
% get name and path of Img
[savePath,name] = fileparts(plot.img);
if ~isfield(plot,'savePath') || isempty(plot.savePath) || strcmp('', plot.savePath)
    disp(['no savePath given... will safe Picture in current directory: ' savePath]);
    plot.savePath = savePath;    
end
if ~isfield(plot,'bgcolor') || isempty(plot.bgcolor)
    disp('no backgroundcolor given. Take Color of first Pixel...');
    nobg = true;
end
if ~isfield(plot.colorbar,'min') || isempty(plot.colorbar.min)
    disp('no Mimimun-Intensity Value given. Take 0...');
    plot.colorbar.min = 0;
end
if ~isfield(plot.colorbar,'max') || isempty(plot.colorbar.max)
    disp('no Maximum-Intensity Value given. Take 5...');
    plot.colorbar.max = 5;
end
if ~isfield(plot.colorbar,'position') || isempty(plot.colorbar.position)
    disp('no position given. Take Position top-left...');
    plot.colorbar.position = [0.1 0.1 0.02 0.8];
end
if ~isfield(plot.colorbar,'FontSize') || isempty(plot.colorbar.FontSize)
    disp('no FontSize given. Take Size 14...');
    plot.colorbar.FontSize = 14;
end
if ~isfield(plot.colorbar,'description') || isempty(plot.colorbar.description)
    disp('no description given. Assume it is T-Value...');
    plot.colorbar.description = 'T-Value';
end

%% Read Scheme & get Properties

% Read ColorScheme
if ~isfield(plot ,'colScheme') || isempty(plot.colScheme)
    disp('Folder or Color-Scheme does not exists!')
    disp(plot.colScheme);
    return;
else % Read ColorScheme
    try
        % Node & Color- Counter
        nodecounter = 1;
        rgbcounter = 1;
        % open file
        iniFile = fopen(plot.colScheme, 'r');
        if iniFile == (-1)
            throw(baseException)
        end
        % read file line-by-line
        while ~feof(iniFile)
            lineRow = fgetl(iniFile);
            % check Line for desired Parameters
            % get NumberOfNodes
            if regexp(lineRow,'numnodes=\d+')
                numnodes = str2double(strrep(lineRow,'numnodes=',''));
                continue;
            end
            % get Intensitivity of Nodes
            if regexp(lineRow,'nodeintensity\d=\d+')
                nodeintensity{nodecounter} = str2double(regexprep(lineRow,'nodeintensity\d=',''));
                nodecounter = nodecounter + 1;
                continue;
            end
            % get Color of Nodes
            if regexp(lineRow,'nodergba\d=(\d+|)+')
                % remove Text from line so value is left
                nodergb = regexprep(lineRow,'nodergba\d=','');
                % cut text in Array
                nodergb = textscan(nodergb,'%s','Delimiter','|');
                % go through array and convert String-Numbers to double
                for i=1:1:length(nodergb{1,1})
                    rgb{rgbcounter}{i} = str2double(nodergb{1,1}{i});
                end
                % Increase Counter
                rgbcounter = rgbcounter +1;
                continue;
            end
            % next line
        end
        % close File
        fclose(iniFile);
    catch ME %if you can...
        % display Error-Message & close File
        disp(ME.identifier)
    end
end

%% Load Image

try
    pic = imread(plot.img);
    [x y c] = size(pic);
    if nobg
        % determine Backgroundcolor of pic
        plot.bgcolor(1) = pic(1,1,1);
        plot.bgcolor(2) = pic(1,1,2);
        plot.bgcolor(3) = pic(1,1,3);
    end
catch ME
    %Display
    disp('Loading Image went wrong');
    disp(strcat('Is this correct?: ',strcat(plot.path,plot.img)));
    disp(ME.identifier)
end
figure(1)
% Display Image
g = image(pic);

%% Build map for colorbar

% Initalisation
line = [];
map = [];
% Loop for building Color-Ranges for every Node in Colorbar
for k=1:1:numnodes-1
    % Build Color-Range from node to next node for red-canal, green-canal,
    % blue-canal
    m1 = linspace(rgb{k}{1}/255,rgb{k+1}{1}/255,(nodeintensity{k+1} - nodeintensity{k}));
    m2 = linspace(rgb{k}{2}/255,rgb{k+1}{2}/255,(nodeintensity{k+1} - nodeintensity{k}));
    m3 = linspace(rgb{k}{3}/255,rgb{k+1}{3}/255,(nodeintensity{k+1} - nodeintensity{k}));
    % rearrange disposal to match map specification
    for n=1:1:(nodeintensity{k+1} - nodeintensity{k})
        line = [m1(n),m2(n),m3(n)];
        map = [map ; line];
    end
end

%% set Parameters for Plot and Colorbar

% set colormap with built map
colormap(map);
% set colorbar which needs colormap to set Intensity
h = colorbar(plot.colorbar.position);
if ~ischar(plot.colorbar.position)
    if plot.colorbar.position(3) > 0.5                 % horizontal
        % first set to north, than change Position as desired
        set(h,'location','north');
        set(h,'position',plot.colorbar.position);
    end
end

% calculate Contrast to Backgroundcolor
cont = [0 0 0];
if plot.bgcolor(1) > 127/255
    cont(1) = 0;
else
    cont(1) = 255/255;
end
if plot.bgcolor(2) > 127/255
    cont(2) = 0;
else
    cont(2) = 255/255;
end
if plot.bgcolor(3) > 127/255
    cont(3) = 0;
else
    cont(3) = 255/255;
end
% set Colorbar-Font Color
set(h,'YColor',cont);
set(h,'XColor',cont);
% set FontSitze of Colorbar
set(h,'FontSize',plot.colorbar.FontSize);
% set Scale of Image
set(g,'CDataMapping','scaled');
% set Colorbar Min and Max
set(gca,'clim',[plot.colorbar.min plot.colorbar.max]);
% remove Labels
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
% Modify axes size
set(gca,'Units','normalized','Position',[0 0 1 1]);
% Modify figure size
set(gcf,'Units','pixels','Position',[0 0 (y+1) (x+1)]);

%% save Image with colorbar
% other ways to save images. but they dont save the settings of the
% colorbar so one can not use them
% print(1, 'test1','-dpng', '-r0');
% saveas(g,'test2','png');
% imwrite(pic,'test3.png','png');

f = getframe(gca);
im = frame2im(f);
if ~exist(plot.savePath, 'dir')
    mkdir(plot.savePath);
end
imwrite(im,fullfile(plot.savePath ,strcat(name,'.png')));

%% set inscription of colorbar
% [left, bottom, width, height]
pos = get(h,'position');
bottonToEnd = pos(4) + pos(2);
leftToEnd = pos(3) + pos(1);
a.img = fullfile(plot.savePath ,strcat(name,'.png'));
a.bgcolor = plot.bgcolor;
a.titel.text =  plot.colorbar.description;
a.titel.position = [pos(1)-0.02 (1-bottonToEnd-0.02)];
a.savePath = plot.savePath;
a.titel.FontSize = 10;
jpa_addTitel(a)
end
%------------- END OF CODE --------------