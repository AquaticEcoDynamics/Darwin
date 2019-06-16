

clear;close;

% load in model lake output
desFile='E:\database\DarwinV3\DRR_GLM_AED_pCO2_testing\output\lake.csv';

data=tfv_readGLMfile(desFile);

% load in observed data
heightdata=tfv_readGLMfile('DDR_Height.csv');


figure(1);
def.dimensions = [25 18]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  ;
fs=10;

pos1=[0.08 0.7 0.35 0.25];
pos2=[0.58 0.7 0.35 0.25];
pos3=[0.08 0.1 0.35 0.45];
pos4=[0.58 0.1 0.35 0.45];

axes('position',pos1);
plot(data.Date,data.LakeLevel+19.35,'k');
hold on;
plot(heightdata.Date,heightdata.DailyLevels,'b');
hold on;
plot(heightdata.Date,heightdata.SpillwayHeight,'r');
hold on;

hl=legend('Modelled','Measured','Spillway Height');
set(hl,'Location','Southeast','FontSize',fs-2);
title('(a) DRR Water Level');

t1=datenum(2012,1,1);t2=datenum(2017,01,01);
set(gca,'xlim',[t1 t2],'ylim',[35 50]);
datess={'20120101','20130101','20140101','20150101','20160101'};
datesv=datenum(datess,'yyyymmdd');
set(gca,'XTick',datesv,'XTickLabel',datestr(datesv,'yyyy'));
xlabel('');ylabel('Water Level (m AHD)');
set(gca,'FontSize',9);

grid on;


axes('position',pos2);

inflowF='.\thermo.csv';
inflowD=tfv_readGLMfile(inflowF);

inflowD.d2(inflowD.d2>36)=NaN;
inflowD.d2(inflowD.d2<20)=NaN;

plot(data.Date,data.SurfaceTemp,'k');
hold on;
plot(inflowD.Date,inflowD.d2,'b');
hold on;

hl=legend('Modelled','thermo-chain-Th19');
set(hl,'Location','Southeast','FontSize',fs-2);
title('(b) Surface Temperature');

%t1=datenum(2012,1,1);t2=datenum(2013,1,1);
set(gca,'xlim',[t1 t2],'ylim',[10 50]);
%datess={'20120101','20120401','20120701','20121001'};
datesv=datenum(datess,'yyyymmdd');
set(gca,'XTick',datesv,'XTickLabel',datestr(datesv,'yyyy'));
xlabel('');ylabel('Temperature (^oC)');
set(gca,'FontSize',9);

grid on;


axes('position',pos3);

data2=interp1(heightdata.Date,heightdata.DailyLevels,data.Date);
scatter(data2,data.LakeLevel+19.35,'ok');hold on;

ss2n=data2;ss1n=data.LakeLevel+19.35;
[r,p] = corrcoef(ss2n, ss1n)
       nashsutcliffe_v3(ss2n, ss1n)
       mae(ss2n, ss1n)
       rms(ss2n, ss1n)

title('(c) elevation scatter comparison');

%t1=datenum(2012,1,1);t2=datenum(2017,01,01);
set(gca,'xlim',[42 48],'ylim',[42 48]);
% datess={'20120101','20130101','20140101','20150101','20160101'};
% datesv=datenum(datess,'yyyymmdd');
%set(gca,'XTick',datesv,'XTickLabel',datestr(datesv,'yyyy'));
       xlabel('Modelled (m AHD)','FontSize',10);
       ylabel('Measured (m AHD)','FontSize',10);
       
set(gca,'FontSize',10);

grid on;box on;

axes('position',pos4);

% load in thermochain data
inflowF='.\thermo.csv';
inflowD=tfv_readGLMfile(inflowF);


alpha = 0.05;
           exponentialMA = filter(alpha, [1 alpha-1], inflowD.d2);
         %plot(days,tempC, ...
           
         %plot(newdates, exponentialMA,'Color',[1-0.05*jj,0.05*jj,0.05*jj]); hold on;
         %plot(datatc.Date, datatc.(thname),'Color',[1-0.05*jj,0.05*jj,0.05*jj]); hold on;
         %exponentialMA(inds1t)=NaN;
         %plot(newdates, exponentialMA,'Color',[1-0.05*jj,0.05*jj,0.05*jj]); hold on;
         
         data2=interp1(inflowD.Date,exponentialMA,data.Date);
         inds0=~isnan(data2);

         data.SurfaceTemp(18)=23.8;
                  
         ss2n=data2(inds0);ss1n=data.SurfaceTemp;ss1n=ss1n(inds0);
                [r,p] = corrcoef(ss2n, ss1n)
       nashsutcliffe_v3(ss2n, ss1n)
       mae(ss2n, ss1n)
       rms(ss2n, ss1n)
         
scatter(data2,data.SurfaceTemp,'ok');hold on;

title('(d) temperature scatter comparison');

%t1=datenum(2012,1,1);t2=datenum(2017,01,01);
set(gca,'xlim',[20 40],'ylim',[20 40]);
% datess={'20120101','20130101','20140101','20150101','20160101'};
% datesv=datenum(datess,'yyyymmdd');
%set(gca,'XTick',datesv,'XTickLabel',datestr(datesv,'yyyy'));
       xlabel('Modelled (degrees)','FontSize',10);
       ylabel('Measured (degrees)','FontSize',10);
       
set(gca,'FontSize',10);

grid on;box on;

outputName=['DDR_water_level_comparev4_seepageNeg.png'];
print(gcf,'-dpng',outputName);