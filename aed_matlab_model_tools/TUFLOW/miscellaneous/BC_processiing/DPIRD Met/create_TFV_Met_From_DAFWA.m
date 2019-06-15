function create_TFV_Met_From_DAFWA(metfile,rainfile,imagefile,data_file)

addpath(genpath('functions'));

load swan.mat;
load(data_file);

% metfile = 'BCs/Met_PI001.csv';
% rainfile = 'BCs/Rain_PI001.csv';
% imagefile = 'BCs/PI001';

Lat = -31.991043;
Lon = 115.886068;

TZ = 8;

startdate = min(SP.mDate);
enddate = max(SP.mDate);

SP.SolRad = SP.SolRad * 1000. / (60.*60.); % Old conversion
SP.SolRad(SP.SolRad < 0) = 0;
%SP.SolRad(SP.SolRad > 1100) = 1100;

SP.Clouds(:,1) = calc_Cloud_Cover(startdate,enddate,TZ,Lat,Lon,SP);


seatemp = calc_Narrows_Temp(swan,SP);


SP.LW = blwhf(seatemp,SP.Atemp,SP.RelHum,SP.Clouds,'berliand');

SP.LW = SP.LW *1.2;

SP.Atemp(SP.Atemp < 0.1) = 0.1;

SP.RelHum(SP.RelHum < 0.1) = 0.1;
SP.RelHum(SP.RelHum > 99.98) = 99.98;


SP.Rain = SP.Rain /1e3;

SP.WS = SP.WS * (1000/(60*60));

SP.Wx = (round(-1.0.*(SP.WS).*sin((pi/180).*SP.WD)*1000000)/1000000);
SP.Wy = (round(-1.0.*(SP.WS).*cos((pi/180).*SP.WD)*1000000)/1000000);

SP.Days = unique(floor(SP.mDate));
for i = 1:length(SP.Days)
    ss = find(floor(SP.mDate) == SP.Days(i));
    SP.Rain_Daily(i) = sum(SP.Rain(ss));
end

vars = fieldnames(SP);
for i = 1:length(vars)
    ss = find(isnan(SP.(vars{i})) == 1);

    SP.(vars{i})(ss) = SP.(vars{i})(ss-10);
end
write_TFV_Metfile(SP,metfile,rainfile);

tfv_plot_met_infile(metfile,rainfile,imagefile);

%tfv_plot_met_infile('BCs/swan_met_Dardanup_dirmh.csv','BCs/swan_rain_Dardanup.csv','BCs/Dardanup_2008_2011');
