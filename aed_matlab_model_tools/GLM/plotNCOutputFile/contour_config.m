
% configuration file for the plot_glm_6_panel.m script

% time setting
datearray = datenum(2012,01:06:24,01);

% output figure name
image_name = 'contour_output.png';

% model output to be read
ncfile = 'E:\database\DarwinV3\DRR_GLM_AED\output\output.nc';

% depth ranges
depth_range = [0 30];

% var setting
var1.name = 'temp'; % GLM Variable Name
var1.caxis = [10 35]; % Axis limits for both plots
var1.Label = 'Temperature (C)';
var1.conversion = 1;
var1.legend_location = 'northwest';

