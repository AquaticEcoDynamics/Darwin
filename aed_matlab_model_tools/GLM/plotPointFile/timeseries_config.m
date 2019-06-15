
% configuration file for the plot_glm_6_panel.m script

% time setting
datearray = datenum(2012,01:12:60,01);

% output figure name
image_name = 'timeseries_output.png';

% model output to be read
csvfile = 'E:\database\DarwinV3\DRR_GLM_AED\output\WQ_5.csv';

% var setting
var1.name = 'OXY_oxy'; % GLM Variable Name
var1.caxis = [0 400]; % Axis limits for both plots
var1.Label = 'DO (mmol/m3)';
var1.legend_location = 'northeast';

% plot size
def.dimensions = [25 18]; % Width & Height in cm
fs=10; % fontsize
