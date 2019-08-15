function defaults = jpa_getPlotDefaults()
% function that returns default Plot-settings


%% ############### Settings ###############
plot.savePath = 'C:\picturesToSavePlot\';
plot.settings.maxCols = 2;
plot.settings.maxRows = 2;
plot.settings.picPerPage = [];

%% ############### Colorbar ###############
plot.colorbar.min = 0;
plot.colorbar.max = 5;
plot.colorbar.fontSize = 14;
plot.colorbar.description = 'f-Value';
plot.bgcolor = [0 0 0];
plot.colScheme = 'C:\mricrogl\lut\1hot.clut';

%% ############### Titel ###############
plot.titel.text = 'Titel';
plot.titel.position = [0.1 0.1];
plot.titel.FontSize = 14;

defaults = plot;
end