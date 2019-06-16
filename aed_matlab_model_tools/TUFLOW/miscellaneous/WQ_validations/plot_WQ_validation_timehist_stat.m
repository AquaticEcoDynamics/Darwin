clear all;close all;

reservoir = 1; % 1=DRR; 2=MRR;
years = 2;

if reservoir == 1
ncfile0 = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\drr_tuflow.nc';
ncfile='E:\database\DarwinV3\DRR_GLM_AED\output\output.nc';
outdir = '.\DRR_WQ_stat_overflow_v2\';
cell_n=140;caxis1=20; caxis2=50;
else
%ncfile0 = 'Z:\Peisheng\Darwin\MRR_TUFLOW_AED_v2\output\mrr_swan_tuflow_only.nc';
ncfile0 = 'Z:\Peisheng\Darwin\MRR_TUFLOW_v3_zones\output\mrr_swan_tuflow_vc.nc';
ncfile='E:\database\DarwinV3\MRR_GLM_AED_testing2\output\output.nc';
outdir = '.\MRR_WQ\';
cell_n=7;caxis1=25; caxis2=40;
end

    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
    
addpath(genpath('..\Functions'))

vars1={'temp','CAR_pH','OXY_oxy','NIT_amm','NIT_nit','TOT_tn','TOT_tp','PHS_frp'};

vars2={'TEMP','WQ_CAR_PH','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_DIAG_TOT_TN','WQ_DIAG_TOT_TP','WQ_PHS_FRP'};
 
vars3={'Temp','pH','DO','NH_4','NO_x','TN','TP','PO_4'};

caxis1=[15 6   0  0  0   0   0   0];
caxis2=[35 9 400 100 10  200  5   1];

infile='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\WaterQuality\Brendan Working Dir\Matfiles\TWS_F.mat';
tws=load(infile);

nit=tws.TWS.F.WQ_NIT_NIT.Data;
nit(nit<0.36)=0.01;
tws.TWS.F.WQ_NIT_NIT.Data=nit;
%% processing
for mm=4:length(vars1)
    
data = readGLMnetcdf(ncfile,vars1{mm});

mod_nd=1:0.1:28;
mod_nd2=20:0.1:47;
mod_temp=zeros(length(data.time),length(mod_nd));

for ii=1:length(data.time)
    ddtmp=data.z(ii,:);
    tttmp=data.(vars1{mm})(ii,:);
    
   % newtmp=interp1(ddtmp(1:data.NS(ii)),tttmp(1:data.NS(ii)),mod_nd);
   % mod_temp(ii,:)=newtmp;
   newtmp_top(ii)=tttmp(data.NS(ii));
   newtmp_bot(ii)=tttmp(1);
   
end

twsdate=tws.TWS.F.(vars2{mm}).Date;
twsdepth=tws.TWS.F.(vars2{mm}).Depth;
twstemp=tws.TWS.F.(vars2{mm}).Data;

tmpday=floor(twsdate);
tmpday2=unique(tmpday);
tws_temp=zeros(length(tmpday2),length(mod_nd));
count=1;
tws_temp_days=[];

%heightdata=tfv_readJBCfile2('DDR_Height.csv');

for kk=1:length(tmpday2)
    indtmp=find(tmpday==tmpday2(kk));
    if length(indtmp)<2
        continue;
        %disp(kk);
        %disp(tmpday2(kk));
    else
        varSurf(count,1)=tmpday2(kk)+0.5;
        varSurf(count,2)=twstemp(indtmp(1));
        if count>1
        if varSurf(count,2)==varSurf(count-1,2)
            varSurf(count,2)=0;
        end
        end
        varbot(count,1)=tmpday2(kk)+0.5;
        varbot(count,2)=twstemp(indtmp(2));
        if count>1
        if varbot(count,2)==varbot(count-1,2)
            varbot(count,2)=0;
        end
        end
        count=count+1;
        
    end
end

data3D=ncread(ncfile0,(vars2{mm}));
time3D=ncread(ncfile0,'ResTime')/24+datenum(2001,1,1);
dat = tfv_readnetcdf(ncfile0,'timestep',1);

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';
indss=dat.idx3(dat.idx3 > 0);
indsb(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
indsb(length(dat.idx3)) = length(dat.idx3);

data3D2s=data3D(indss,:);
data2D3s=sort(data3D2s,1);
data3Dtms=data3D2s(cell_n,:); %mean(data3D2s,1);
data3Dt1s=data2D3s(floor(length(indsb)*0.1),:);
data3Dt2s=data2D3s(floor(length(indsb)*0.9),:);

data3D2b=data3D(indsb,:);
data2D3b=sort(data3D2b,1);
data3Dtmb=data3D2b(cell_n,:); %mean(data3D2b,1);
data3Dt1b=data2D3b(floor(length(indsb)*0.1),:);
data3Dt2b=data2D3b(floor(length(indsb)*0.9),:);

%% plotting
hfig = figure('visible','on','position',[304         166        1271         812]);
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 20 10]);
        clf;
        
        pos1=[0.1 0.55 0.4 0.3];
        pos2=[0.1 0.1 0.4 0.3];
        pos3=[0.65 0.2 0.3 0.55];
        
        
        axes('Position',pos1);
        
        plot(varSurf(:,1),varSurf(:,2),'*k');hold on;
      %  plot(data.time, newtmp_top,'k'); hold on;
        plot(time3D,data3Dtms,'r'); hold on;
        xf=[time3D',fliplr(time3D')];
        yf=[data3Dt1s,fliplr(data3Dt2s)];
        h=fill(xf,yf,'k','LineStyle','none');
        set(h,'facealpha',0.2);
       
       ts=datenum(2012,1,1);tf=datenum(2013,1,1);
       datestrs={'20120101','20120401','20120701','20121001','20130101'};
       if years==2
        ts=datenum(2012,1,1);tf=datenum(2014,1,1);
        datestrs={'20120101','20120701','20130101','20130701','20140101'};
       end

       set(gca,'XLim',[ts tf],'YLim',[caxis1(mm) caxis2(mm)]);
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'mmm/yy'));
       hl=legend('Measured','TUFLOW-AED','10%-90% band');
       set(hl, 'FontSize',8);
       
       ylabel([vars3{mm},' (\muM)'],'FontSize',10);
       title('(a) surface time history', 'FontSize',10);
       
        axes('Position',pos2);
        
        plot(varbot(:,1),varbot(:,2),'*b');hold on;
     %   plot(data.time, newtmp_bot,'b'); hold on;
        plot(time3D,data3Dtmb,'r'); hold on;
        xf=[time3D',fliplr(time3D')];
        yf=[data3Dt1b,fliplr(data3Dt2b)];
        h=fill(xf,yf,'k','LineStyle','none');
        set(h,'facealpha',0.2);
        
       set(gca,'XLim',[ts tf],'YLim',[caxis1(mm) caxis2(mm)]);
       %datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
       datenums=datenum(datestrs,'yyyymmdd');
       set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'mmm/yy'));
       hl=legend('Measured','TUFLOW-AED','10%-90% band');
       set(hl, 'FontSize',6);
       
       ylabel([vars3{mm},' (\muM)'],'FontSize',10);
       title('(b) bottom time history', 'FontSize',10);
       
       axes('Position',pos3);
        
       newtop=interp1(time3D,data3Dtms,varSurf(:,1));
       newbot=interp1(time3D,data3Dtmb,varbot(:,1));
         scatter(newtop,varSurf(:,2),'*k');hold on;      
        scatter(newbot,varbot(:,2),'*b');hold on;
        
        ss1=newtop;ss1(length(newtop)+1:length(newtop)+length(newbot))=newbot;
        ss2=varSurf(:,2);ss2(length(varSurf(:,2))+1:length(varSurf(:,2))+length(varbot(:,2)))=varbot(:,2);
        
        inds0=~isnan(ss1);
        
        ss1n=ss1(inds0);ss2n=ss2(inds0);

       [r,p] = corrcoef(ss2n, ss1n)
       nashsutcliffe_v3(ss2n, ss1n)
       mae(ss2n, ss1n)
       rms(ss2n, ss1n)
       
      hl=legend('Epilimnion','Hypolimnion');
      set(hl, 'FontSize',8);

       axis([caxis1(mm) caxis2(mm) caxis1(mm) caxis2(mm)]);
       xlabel('Modelled (\muM)','FontSize',10);
       ylabel('Measured (\muM)','FontSize',10);
       title('(c) scatter comparison', 'FontSize',10);
       

       
%img_name =[vars2{mm},'_compare.png'];
print(gcf,'-dpng',[outdir, vars2{mm},'_compare.png']);

end
