clear all; close all;

addpath(genpath('Functions'));
% This uses the latest version of the code, which requries

% Watch for the Version flag for files downloaded after Nov. 2017.

% Haven't checked if level flat file is also affected

%______________________________________________________________________________



filename = 'Flow/112108/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Create','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'Flow/113885/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);


filename = 'Flow/113895/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'Flow/113896/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'Flow/113897/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'Flow/113898/WaterLevelsContinuousForSiteCrossTab.xlsx';
type = 'Level';
[rows,cols] = calculate_xls_size_l(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

%_______________________________________________


filename = 'WQ/112913/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/112035/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/112918/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/112920/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/112921/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/112922/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/113886/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/113253/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',0,'Version',2);

filename = 'WQ/113936/WaterQualityDiscreteForSiteCrossTab.xlsx';disp(filename);
type = 'WQ';
[rows,cols] = calculate_xls_size(filename);
import_wir_dataset_v2(filename,type,'Append','WIR.mat','Row',rows,'Column',cols,...
    'Remove_NaN',1,'Summerise',1,'Version',2);


load WIR.mat;

WIR = sort_WIR_data(WIR);

save WIR.mat WIR -mat;

save ../'Join All Datasources'/WIR.mat WIR -mat;
% merge_mafra_dow;
% 
% plot_data_polygon_regions;

% datearray(:,1) = datenum(1970:01:2018,07,01);
% 
% inflows_chx_3 = add_secondary_data(inflows,datearray);
% 
% inflows_chx_4 = sort_WIR_data(inflows_chx_3);
% 
% inflows = inflows_chx_4;
% inflows_main = inflows_chx_4;
% 
% 
% save inflows.mat inflows -mat;
% save inflows_main.mat inflows_main -mat;
% 
% 
% load inflows.mat;
% 
% inflows = sort_WIR_data(inflows);
% 
% 
% datearray(:,1) = datenum(1970:01:2018,07,01);
% 
% inflows = add_secondary_data(inflows,datearray);
% 
% inflows = sort_WIR_data(inflows);
% 
% 
% save inflows_main.mat inflows -mat;
% 
% %save ../../BCs/peel.mat peel -mat;
% 
% plot_data_polygon_regions;
% 
% inflows = rmfield(inflows,'n33');
% inflows = rmfield(inflows,'p432');
% inflows = rmfield(inflows,'p433');
% inflows = rmfield(inflows,'p489');
% 
% save inflows_main.mat inflows -mat;



















%______________________________________________________________






% filename = 'Level/108332/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','peel.mat','Row',403137,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);



% 
% filename = 'WQ/100151/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100152/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100153/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100154/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100155/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100156/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100157/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100158/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100159/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100160/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100161/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100162/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% % has not data
% % filename = 'WQ/100163/WaterQualityForSite.xlsx';disp(filename);
% % type = 'WQ';
% % [rows,cols] = calculate_xls_size(filename);
% % import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
% %     'Remove_NaN',1,'Summerise',0);
% 
% % filename = 'WQ/100164/WaterQualityForSite.xlsx';disp(filename);
% % type = 'WQ';
% % [rows,cols] = calculate_xls_size(filename);
% % import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
% %     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100165/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100166/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% % filename = 'WQ/100167/WaterQualityForSite.xlsx';disp(filename);
% % type = 'WQ';
% % [rows,cols] = calculate_xls_size(filename);
% % import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
% %     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100168/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% 
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100169/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100170/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100171/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% % filename = 'WQ/100172/WaterQualityForSite.xlsx';disp(filename);
% % type = 'WQ';
% % [rows,cols] = calculate_xls_size(filename);
% % import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
% %     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100173/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100174/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'WQ/100175/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);
% %__________________________________________________________________________
% % Missed Sites
% 	
% filename = 'WQ/100382/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);	
% 
% filename = 'WQ/100391/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);	
% 
% filename = 'WQ/100392/WaterQualityForSite.xlsx';disp(filename);
% type = 'WQ';
% [rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',rows,'Column',cols,...
%     'Remove_NaN',1,'Summerise',0);	
% 
% %______________________________________________________________________________
% 
% 
% filename = 'Flow/100246/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',68710,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);
% 
% 
% filename = 'Flow/100247/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',80191,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'Flow/100248/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',101907,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);
% 
% 	%______________________________________________________________________________
% 
% filename = 'Flow/100386/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',68592,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);
% 
% filename = 'Flow/100395/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',178141,'Column','AO',...
%     'Remove_NaN',1,'Summerise',0);
% 
% 
% 
% filename = 'Flow/100249/WaterLevelsForSiteFlatFile.xlsx';
% type = 'Level';
% %[rows,cols] = calculate_xls_size(filename);
% import_wir_dataset(filename,type,'Append','swan.mat','Row',79835,'Column','AO',...
%     'Remove_NaN',1,'Summerise',1);



%______________________________________________________________________________




% load swan.mat;
% save ../Inflows/swan.mat swan -mat
% save ../Initial' Conditions'/Matfiles/swan.mat swan -mat
% limit_swan_sites
