function jpa_addTitel(plot)
% jpa_addTitel - adds a colorbar to a picture to a specified
% color-Scheme from MRIcroGL
%
% Syntax:  jpa_addTitel(plot)
%
% Inputs:
%    plot
%   *   plot.img                - contains the path of the Image to load
%       plot.bgcolor            - Backgroundcolor of MRIcroGL-Images
%       plot.titel.text         - contains the Titel to be added
%       plot.titel.position     - 2x1, [left, bottom]
%       plot.titel.FontSize     - Font Size of text
%
%   * = necessary for jpa_addTitel
%
%
% Outputs:
%    .png - Picture saved in directory specified under plot.savePath
%
%
% Example:
%    jpa_addTitel(plot)
%       where:
%       plot.img = 'C:\picturesToPlot\pic1.png'
%       plot.savePath  = 'C:\picturesToPlot\PicturesWithTitel';
%       plot.bgcolor = [0 0 0]
%       plot.titel.text = 'titel1'
%       plot.titel.position = [0.1 0.1] -> top left site of Pic
%       plot.titel.FontSize = 14
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_plotMriCro

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
[savePath,name] = fileparts(plot.img);
if ~isfield(plot,'savePath') || isempty(plot.savePath)|| strcmp('', plot.savePath)
    disp(['no savePath given... will safe Picture in current directory: ' savePath]);
    plot.savePath = savePath;
end
if ~isfield(plot,'bgcolor') || isempty(plot.bgcolor)
    disp('no backgroundcolor given. Take Color of first Pixel...');
    nobg = true;
end
if ~isfield(plot.titel,'text') || isempty(plot.titel.text)
    plot.titel.text = 'titel1';
end
if ~isfield(plot.titel,'position') || isempty(plot.titel.position)
    disp('no position given. Take Position top-left...');
    plot.titel.position = [0.1 0.1];
end
if ~isfield(plot.titel,'FontSize') || isempty(plot.titel.FontSize)
    disp('no FontSize given. Take Size 14...');
    plot.titel.FontSize = 14;
end

%% Load Picture
try
    pic = imread(plot.img);
    [h w c] = size(pic);
    % determine Backgroundcolor of pic
    if nobg
        plot.bgcolor(1) = pic(1,1,1);
        plot.bgcolor(2) = pic(1,1,2);
        plot.bgcolor(3) = pic(1,1,3);
    end
catch ME
    %Display
    disp('Loading Image went wrong');
    disp(strcat('Is this correct?: ',plot.img));
    disp(ME.identifier)
end
figure(1)
g = image(pic);
%% Set Titel
set(g,'CDataMapping','scaled');
% remove Labels
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
% Modify axes size
set(gca,'Units','normalized','Position',[0 0 1 1]);
% Modify figure size
set(gcf,'Units','pixels','Position',[0 0 (w+1) (h+1)]);
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
% calculate Position
y = w * plot.titel.position(1);
x = h *  plot.titel.position(2);
t = text(y,x,plot.titel.text);
set(t,'Color',cont);
set(t,'FontSize', plot.titel.FontSize);

%% save Image with colorbar
f = getframe(gca);
im = frame2im(f);
if ~exist(plot.savePath, 'dir')
    mkdir(plot.savePath);
end
imwrite(im,fullfile(plot.savePath ,strcat(name,'.png')));
end
%------------- END OF CODE --------------