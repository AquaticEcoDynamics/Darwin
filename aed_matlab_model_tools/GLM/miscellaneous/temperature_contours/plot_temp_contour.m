clear;close;
% a script to compare the temperature profiles from model, thermistor-chain, and TWS weekly profiles

% load in the thermo-chain data
load('temp_contour\thermo_info.mat');

% load in model output
ncfile='E:\database\DarwinV3\DRR_GLM_AED\output\output.nc';

addpath(genpath('..\Functions'))

data = readGLMnetcdf(ncfile,'temp');

mod_nd=1:0.1:28;
mod_nd2=20:0.1:47;
mod_temp=zeros(length(data.time),length(mod_nd));

for ii=1:length(data.time)
    ddtmp=data.z(ii,:);
    tttmp=data.temp(ii,:);
    
    newtmp=interp1(ddtmp(1:data.NS(ii)),tttmp(1:data.NS(ii)),mod_nd);
    mod_temp(ii,:)=newtmp;
end

% load in and process the TWS weekly profiles
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
       
        ts=datenum(2012,1,1);tf=datenum(2017,1,1);
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
       datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'yyyy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(b) Water temperature record from thermistor chain', 'FontSize',10); 

        subplot(3,1,1);
        
        pcolor(data.time,mod_nd+19.35,mod_temp');shading flat;
        colormap(jet);caxis([15 35]);
       
        ts=datenum(2012,1,1);tf=datenum(2017,1,1);
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
       datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'yyyy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(a) Modelled water temperature', 'FontSize',10);

        subplot(3,1,2);
        newinds=[1:123,125:279];
        twsTempData=tws_temp(newinds,:);
        pcolor(tws_temp_days(newinds),mod_nd2,twsTempData');shading flat;
        colormap(jet);caxis([15 35]);
       
        ts=datenum(2012,1,1);tf=datenum(2017,1,1);
       set(gca,'XLim',[ts tf],'YLim',[20 50]);
       datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'yyyy'));
       colorbar;
       
       ylabel('Depth (mAHD)','FontSize',10);
       title('(c) Water temperature record from TWS routine samples', 'FontSize',10);
       
img_name =['thermo_contour.png'];
saveas(gcf,img_name);
