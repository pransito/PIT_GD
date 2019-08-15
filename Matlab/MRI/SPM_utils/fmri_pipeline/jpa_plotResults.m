function jpa_plotResults(plot)
% jpa_plotMriCro - plots the Pictures taken from MRIcroGL in a specifyed
% directory and adds a colorbar (if desired) to a specified colorScheme
% from MRIcroGL
%
% Syntax:  jpa_plotResults(plot)
%
% Inputs:
%    plot
%       plot.path               - Path to Directory with Images
%       plot.settings           - Contains settings how to Plot Images
%       plot.settings.maxCols   - Cols per Figure
%       plot.settings.maxRows   - Rows per Figure
%       plot.settings.picPerPage- specify the exact Numer of Pictures per
%                                 figure
%
% Outputs:
%    figure - Figure with plottet Pictures in specified disposal
%
% Example:
%    jpa_plotResults(plot)
%       where:
%       plot.path = 'C:\picturesToPlot\'
%       plot.settings.maxCols = 3
%       plot.settings.maxRows = 2
%       plot.settings.picPerPage = [ 4 3 7]
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 18-Sep-2015

%------------- BEGIN CODE --------------

%% Standards if nothing specified
if isempty(plot.path)
    disp(['no Path given, Try to load Pictures from current directory: ' pwd]);
    plot.path = pwd;
end

% check for \ at the end
if ~strcmp(plot.path(length(plot.path)), filesep )
    plot.path = strcat(plot.path ,filesep );
end

%% Check Pictures
% need to calculate exakt?
cal = false;
% check for Folder
if ~exist(plot.path,'dir') || isempty(plot.path)
    error('Folder does not exists!')
else % get the Pictures
    images = jpa_getDirs(plot.path, '*.png');
    numOfPic = length(images);
end
disp(['I found ', num2str(numOfPic), ' Pictures.'])
if numOfPic == 0
    display('Exit... nothing to plot!');
    return;
end

%% check for Settings
if ~isfield(plot , 'settings')
    plot.settings.picPerPage = [];
end
if ~isfield(plot.settings,'picPerPage') || isempty(plot.settings.picPerPage)
    % set calculated bit
    cal = true;
    % set values if empty
    if ~isfield(plot.settings,'maxCols') || isempty(plot.settings.maxCols) || plot.settings.maxCols == 0
        plot.settings.maxCols = 2;
        % so there is no need to calculate later
        cal = false;
    end
    if ~isfield(plot.settings,'maxRows') || isempty(plot.settings.maxRows) || plot.settings.maxRows == 0
        plot.settings.maxRows = 2;
        % so there is no need to calculate later
        cal = false;
    end
    % determine exakt numer of Pictures per page
    if plot.settings.maxCols * plot.settings.maxRows >= length(images)
        % only one Page is needed
        plot.settings.picPerPage = repmat(plot.settings.maxCols * plot.settings.maxRows,1,1);
    else
        % set how often i need to replicate
        wdh = floor(length(images)/(plot.settings.maxCols * plot.settings.maxRows));
        plot.settings.picPerPage = repmat(plot.settings.maxCols * plot.settings.maxRows,1,wdh);
        % take the rest of the Pictures on the last Page
        if ~rem(length(images), plot.settings.maxCols * plot.settings.maxRows)== 0
            plot.settings.picPerPage = [plot.settings.picPerPage,rem(length(images), plot.settings.maxCols * plot.settings.maxRows)];
        end
    end
end
% Index of Image
indexImage = 1;
% index of Plot
plotIndex = 1;

%% routine that plots the Pictures in the specified way:
% loop that runs through each Page (figure)
for index=1:1:length(plot.settings.picPerPage)
    % maxCols & maxRows not given, calculate them
    if cal ~= true
        % calculate maxCols maxRows for each page
        plot.settings.maxCols = ceil(sqrt(plot.settings.picPerPage(index)));
        if plot.settings.maxCols*floor(sqrt(plot.settings.picPerPage(index))) >= (plot.settings.picPerPage(index))
            plot.settings.maxRows = floor(sqrt(plot.settings.picPerPage(index)));
        else
            plot.settings.maxRows = plot.settings.maxCols;
        end
    end
    % calculate positions for Pictures. Matlab uses Percentage to position
    % the Pictures. So we do the same
    left = 0:(1/plot.settings.maxCols):1-(1/plot.settings.maxCols);
    bottom = 1-1/plot.settings.maxRows:-(1/plot.settings.maxRows):0;
    width = (1/plot.settings.maxCols);
    height = (1/plot.settings.maxRows);
    % set plot Figure
    figure(index)
    % plot the Images
    for indexPage=1:1:plot.settings.picPerPage(index)
        % are there pictures left?
        if indexImage <= length(images)
            % subplot with desired Rows and Cols
            S{indexImage} = subplot(plot.settings.maxRows,plot.settings.maxCols,indexPage);
            % read Image
            A = imread(images{indexImage});
            % Image Picture
            image(A);
            % remove Axis text
            set(gca,'XTickLabel',[])
            set(gca,'YTickLabel',[])
            % increase Counter
            indexImage = indexImage +1;
        else
            continue;
        end
    end
    % set counter
    row = 1;
    col = 1;
    
    %% change position. necessary to do at the end!
    for actPlot=plotIndex:1:indexImage-1
        p = get(S{actPlot}, 'pos');
        % change position
        p(1) = left(col);
        p(2) = bottom(row);
        p(3) = width;
        p(4) = height;
        % set new position
        set(S{actPlot}, 'pos', p);
        % increase Counter
        col = col + 1;
        % if col full increase row, reset col
        if col > plot.settings.maxCols
            row = row + 1;
            col = 1;
        end
    end
    plotIndex = indexImage;
end
end
%------------- END OF CODE --------------