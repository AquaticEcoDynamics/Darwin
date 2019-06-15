clear all; close all;

filename = 'Pinjarra.csv';

datearray = datenum(2016,01:06:25,01);

[fig,ax1,ax2] = plottfv_N_P_stacked_area_from_BC(filename,datearray,'group','TP','conversion',31/1000,'addflow',0,'savename','test_TP_plot.png');

[fig,ax1,ax2] = plottfv_N_P_stacked_area_from_BC(filename,datearray,'group','TN','conversion',14/1000,'addflow',1,'savename','test_TN_plot.png');

%Changing stuff...
ax1.YAxis.Label.String = 'Nitrogen (mg/L)';
