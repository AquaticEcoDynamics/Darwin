
% file paths
ncfile = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\drr_tuflow.nc';
outdir = '.\';

% var setting
var1.name = 'WQ_OXY_OXY'; % GLM Variable Name
var1.caxis = [0 10]; % Axis limits for both plots
var1.Label = 'DO (mmol/m3)';
var1.legend_location = 'northeast';

% These two slow processing down. Only set to 1 if required
create_movie = 1; % 1 to save movie, 0 to just display on screen
save_images = 0;  % save as above for images
clip_depth = 0.05; % remove the shallow NaN cells

% time setting
datearray = datenum(2012,01:01:02,01);
plot_interval = 6;

% choose layer
isTop = 1; % 1 for surface layer; 0 for bottom layer

