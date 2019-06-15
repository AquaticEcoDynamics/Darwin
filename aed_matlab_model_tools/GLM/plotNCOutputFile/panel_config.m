
% configuration file for the plot_glm_6_panel.m script

% time setting
datearray = datenum(2012,01:06:24,01);

% output figure name
image_name = 'panel_output.png';

% model output to be read
ncfile = 'E:\database\DarwinV3\DRR_GLM_AED\output\output.nc';

% depth ranges
surface_range = [15 20];
bottom_range = [0 5];

% Top Plot
var1.name = 'temp'; % GLM Variable Name
var1.caxis = [10 35]; % Axis limits for both plots
var1.Label = 'Temperature (C)';
var1.conversion = 1;
var1.legend_location = 'northwest';

% Middle Plot
var2.name = 'salt';% GLM Variable Name
var2.caxis = [0 2];
var2.Label = 'Salinity (psu)';
var2.conversion = 1;
var2.legend_location = 'southwest';

% Bottom Plot
var3.name = 'OXY_oxy';% GLM Variable Name
var3.caxis = [0 400];
var3.Label = 'Oxygen (mmol/m^3)';
var3.conversion = 1;
var3.legend_location = 'northeast';

