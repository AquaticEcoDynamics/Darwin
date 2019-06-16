clear all;close all;

reservoir = 1; % 1=DRR; 2=MRR;
years = 2;

if reservoir == 1
ncfile0 = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v5_benthos\output\drr_tuflow.nc'; 
outdir = '.\all_DRR_surface7\';
cell_n=100;caxis1=20; caxis2=50;
else

ncfile0 = 'Z:\Peisheng\Darwin\MRR_TUFLOW_v3\output\mrr_swan_tuflow_vc_copy.nc';
outdir = '.\all_MRR_surface23\';
cell_n=7;caxis1=25; caxis2=40;
end



    if ~exist(outdir,'dir')
        mkdir(outdir);
    end

dat = tfv_readnetcdf(ncfile0,'time',1);
timesteps = dat.Time;
t0=datenum('20161223 12:00','yyyymmdd HH:MM');
tt = find(abs(timesteps-t0)==min(abs(timesteps-t0)));
dat = tfv_readnetcdf(ncfile0,'timestep',tt);

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';
indsb=dat.idx3(dat.idx3 > 0);

ts=datenum(2012,1,1);tf=datenum(2014,1,1);
datestrs={'20120101','20120401','20120701','20121001','20130101'};
if years==2
        ts=datenum(2012,1,1);tf=datenum(2014,1,1);
        datestrs={'20120101','20120701','20130101','20130701','20140101'};
end

datenums=datenum(datestrs,'yyyymmdd');

%% read layers
layers=ncread(ncfile0,'layerface_Z');
cells_idx2=dat.idx2;
i2 = cell_n; %cells_idx2(cell_n);
NL = dat.NL(i2);
i3 = dat.idx3(i2);
i3z = i3 + i2 -1;

zv = zeros(NL,length(timesteps));
        for i = 1 : length(timesteps)
            zv(:,i) = layers(i3z:i3z+NL-1,i); 
            
        end
        
        time2=zeros(NL,length(timesteps));
        for j=1:NL
            time2(j,:)=timesteps;
        end
%z=cell2mat(zv);

% load in thermistor-chain data
load('temp_contour\thermo_info.mat');

 mod_nd=1:0.1:28;
 mod_nd2=20:0.1:47;

% load in TWS profiles
infile='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\WaterQuality\Brendan Working Dir\Matfiles\TWS_F.mat';
tws=load(infile);

twsdate=tws.TWS.F.TEMP.Date;
twsdepth=tws.TWS.F.TEMP.Depth;
twstemp=tws.TWS.F.TEMP.Data;

tmpday=floor(twsdate);
tmpday2=unique(tmpday);
tws_temp=zeros(length(tmpday2),length(mod_nd));
count=1;

heightdata=tfv_readGLMfile('DDR_Height.csv');

for kk=1:length(tmpday2)
    indtmp=find(tmpday==tmpday2(kk));
    if length(indtmp)<3
        disp(kk);
        disp(tmpday2(kk));
    else
        newdepth=-twsdepth(indtmp);
        newdata=twstemp(indtmp);
        [newdepth2 inds2]=sort(newdepth);
       newtemp2=newdata(inds2);
       
       for ll=1:length(newdepth2)-1
           if newdepth2(ll)>=newdepth2(ll+1)
               newdepth2(ll+1)=newdepth2(ll)+0.001;
           end
       end
        
       indtheight=find(abs(heightdata.Date-tmpday2(kk))==min(abs(heightdata.Date-tmpday2(kk))));
       tmpheight=heightdata.DailyLevels(indtheight);
        newdata2=interp1(tmpheight-newdepth2,newtemp2,mod_nd2);
        tws_temp(count,:)=newdata2;
        tws_temp_days(count)=tmpday2(kk);
        count=count+1;
        
    end
end



%% plotting
hfig = figure('visible','on','position',[304         166        1271         812]);
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 20.32 16])
        
        subplot(3,1,3);
        
        pcolor(newdates,newRL,interpdata');shading flat;
        colormap(jet);caxis([15 35]);
       
      %  ts=datenum(2012,1,1);tf=datenum(2013,1,1);
      % datestrs={'20120101','20120401','20120701','20121001','20130101'};
       
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
       
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'mmm/yy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(b) Water temperature record from thermistor chain', 'FontSize',10); 

        subplot(3,1,1);
        
        tmp=ncread(ncfile0,'TEMP');

t2=tmp(i3:i3+NL-1,:);

pcolor(time2,zv,t2);shading interp; colorbar;colormap('jet');%caxis([lim1(1) lim2(1)]);
%set(gca,'XLim',[ts tf],'YLim',[20 50]);
%set(gca,'YLim',[15 35]);

%set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'dd/mm'));
%box on;
        
  %      pcolor(data.time,mod_nd+19.35,mod_temp');shading flat;
        colormap(jet);caxis([15 35]);
       
  %      ts=datenum(2012,1,1);tf=datenum(2017,1,1);
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
    %   datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'mmm/yy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(a) Modelled water temperature', 'FontSize',10);

        subplot(3,1,2);
        newinds=[1:123,125:279];
        twsTempData=tws_temp(newinds,:);
        pcolor(tws_temp_days(newinds),mod_nd2,twsTempData');shading flat;
        colormap(jet);caxis([15 35]);
       
     %   ts=datenum(2012,1,1);tf=datenum(2017,1,1);
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
     %  datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'mmm/yy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(c) Water temperature record from TWS routine samples', 'FontSize',10);
       
img_name =['thermo_contour_2years_benthos.png'];
saveas(gcf,img_name);
