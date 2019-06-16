

clear all; close all;
reservoir = 1; % 1=DRR; 2=MRR;
years = 2;

if reservoir == 1
%ncfile0 = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v4_v2\output\drr_swan2.nc';
ncfile0 = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\drr_tuflow.nc';
ncfile='E:\database\DarwinV3\DRR_GLM_AED\output\output.nc';
outdir = '.\DRR_WQ_overflow\';
cell_n=140;caxis1=20; caxis2=50;
else
%ncfile0 = 'Z:\Peisheng\Darwin\MRR_TUFLOW_AED_v2\output\mrr_swan_tuflow_only.nc';
ncfile0 = 'Z:\Peisheng\Darwin\MRR_TUFLOW_AED_v2\output\mrr_swan.nc';
ncfile='E:\database\DarwinV3\MRR_GLM_AED_testing2\output\output.nc';
outdir = '.\MRR_WQ\';
cell_n=7;caxis1=25; caxis2=40;
end

    if ~exist(outdir,'dir')
        mkdir(outdir);
    end


data3D=ncread(ncfile0,'H');
time3D=ncread(ncfile0,'ResTime')/24+datenum(2001,1,1);
dat = tfv_readnetcdf(ncfile0,'timestep',1);

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';
indss=dat.idx3(dat.idx3 > 0);
indsb(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
indsb(length(dat.idx3)) = length(dat.idx3);

data3D2s=data3D; %(indss,:);
data2D3s=sort(data3D2s,1);
data3Dtms_H=data3D2s(cell_n,:); %data2D3s(floor(length(indsb)*0.5),:); %mean(data3D2s,1);
data3Dt1s=data2D3s(floor(length(indsb)*0.1),:);
data3Dt2s=data2D3s(floor(length(indsb)*0.9),:);

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
%plot(data.Date,data.LakeLevel+19.35,'k');
plot(time3D,data3Dtms_H,'k');hold on;

plot(heightdata.Date,heightdata.DailyLevels,'b');
hold on;
plot(heightdata.Date,heightdata.SpillwayHeight,'r');
hold on;

hl=legend('Modelled','Measured','Spillway Height');
set(hl,'Location','Southeast','FontSize',fs-2);
title('(a) DRR Water Level');

t1=datenum(2012,1,1);t2=datenum(2014,01,01);
set(gca,'xlim',[t1 t2],'ylim',[35 50]);
datess={'20120101','20120701','20130101','20130701','20140101'};
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

data3D=ncread(ncfile0,'TEMP');
data3D2s=data3D(indss,:);
data2D3s=sort(data3D2s,1);
data3Dtms=data3D2s(cell_n,:); %data2D3s(floor(length(indsb)*0.5),:); %mean(data3D2s,1);
data3Dt1s=data2D3s(floor(length(indsb)*0.1),:);
data3Dt2s=data2D3s(floor(length(indsb)*0.9),:);

%plot(data.Date,data.SurfaceTemp,'k');
plot(time3D,data3Dtms,'r');hold on;

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

%data2=interp1(heightdata.Date,heightdata.DailyLevels,data.Date);
data2=interp1(heightdata.Date,heightdata.DailyLevels,time3D);
%scatter(data2,data.LakeLevel+19.35,'ok');hold on;
scatter(data2,data3Dtms_H,'ok');hold on;

ss2n=data2;ss1n=data3Dtms_H;
[r,p] = corrcoef(ss2n, ss1n)
       nashsutcliffe_v3(ss2n, ss1n')
       mae(ss2n, ss1n')
       rms(ss2n, ss1n')

title('(c) elevation scatter comparison');

%t1=datenum(2012,1,1);t2=datenum(2017,01,01);
set(gca,'xlim',[42 48],'ylim',[42 48]);

       xlabel('Modelled (m AHD)','FontSize',10);
       ylabel('Measured (m AHD)','FontSize',10);
       
set(gca,'FontSize',10);

grid on;box on;

axes('position',pos4);

inflowF='.\thermo.csv';
inflowD=tfv_readGLMfile(inflowF);


alpha = 0.05;
           exponentialMA = filter(alpha, [1 alpha-1], inflowD.d2);

         data2=interp1(inflowD.Date,exponentialMA,time3D);
         
         inds0=~isnan(data2);

         %data.SurfaceTemp(18)=23.8;
                  
         ss2n=data2(inds0);ss1n=data3Dtms;ss1n=ss1n(inds0);
                [r,p] = corrcoef(ss2n, ss1n')
       nashsutcliffe_v3(ss2n, ss1n')
       mae(ss2n, ss1n')
       rms(ss2n, ss1n')
         
scatter(data2,data3Dtms,'ok');hold on;

title('(d) temperature scatter comparison');

%t1=datenum(2012,1,1);t2=datenum(2017,01,01);
set(gca,'xlim',[20 40],'ylim',[20 40]);

       xlabel('Modelled (degrees)','FontSize',10);
       ylabel('Measured (degrees)','FontSize',10);
       
set(gca,'FontSize',10);

grid on;box on;

outputName=['DDR_water_level_comparev3.png'];
print(gcf,'-dpng',[outdir,outputName]);