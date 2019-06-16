clear;close;

%DRR met data;
file_drr='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\Meteorology\DRR_Met_10min.mat';
%file_mrr='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\Meteorology\MRR_Met_10min.mat';

% Darwin airport station data
file_da='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\Meteorology\Darwin_AP met output\tfv_met_Darwin_AP.csv';

data_da=tfv_readBCfile(file_da);
data_drr=load(file_drr);
%data_mrr=load(file_mrr);

        dtmp1=data_drr.mDate;
        dtmp2=data_drr.SOLRAD;
        
        inds=~isnan(dtmp2);
        newt=dtmp1(inds);
        newd=dtmp2(inds);
        newt2=unique(newt);
        newd2=zeros(size(newt2));
       
       for nn=1:length(newt2)
           indtt=find(newt==newt2(nn));
           newd2(nn)=newd(indtt(1));
       end

%% plotting

hfig = figure('visible','on','position',[304         166        1271         812]);
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 19 20]);
        
        pos1=[0.08 0.85 0.85 0.10];
        pos2=[0.08 0.70 0.85 0.10];
        pos3=[0.08 0.55 0.85 0.10];
        pos4=[0.08 0.40 0.85 0.10];
        pos5=[0.08 0.05 0.35 0.27];
        pos6=[0.58 0.05 0.35 0.27];
       % pos7=[0.08 0.06 0.8 0.12];
        color1=[0.3 0.3 0.3];
        fs=9;
        ts=datenum(2012,1,1);tf=datenum(2017,1,1);newdate=ts:1/24:tf;
        datestrs={'20120101','20130101','20140101','20150101','20160101','20170101'};
        datenums=datenum(datestrs,'yyyymmdd');
        
        
        axes('Position',pos4);
        
        newdata=interp1(newt2,newd2,newdate);newdata_drr=newdata;
        plot(newdate,newdata,'Color',color1); hold on;
        plot(newdate, movmean(newdata,24*30), 'r','LineWidth',1); hold on;
        hl=legend('Wind Speed','monthly-averaged');
        set(hl,'FontSize',fs-2,'Location','Northeast');
        
        grid on;box on;
        set(gca,'XLim',[ts tf],'YLim',[0 2000]);
       
        set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'yyyy'),'YTick',0:500:2000);
        ylabel('(W/m^2)','FontSize',fs);
        title('(b) Solar irradiance record at Darwin Reservoir','FontSize',fs);

        axes('Position',pos3);
               
        dtmp1=data_da.Date;
        dtmp2=data_da.Sol_Rad;
        inds=~isnan(dtmp2);
        newdata=interp1(dtmp1(inds),dtmp2(inds),newdate); newdata_da=newdata;
        plot(newdate,newdata,'Color',color1); hold on;
        plot(newdate, movmean(newdata,24*30), 'r','LineWidth',1); hold on;
        
        grid on;box on;
        set(gca,'XLim',[ts tf],'YLim',[0 2000]);
       
        set(gca,'XTick',datenums,'XTickLabel',datestr(datenums,'yyyy'),'YTick',0:500:2000);
        ylabel('(W/m^2)','FontSize',fs);
        title('(a) Solar irradiance record at Darwin Airport','FontSize',fs);
        
       axes('Position',pos5);
       
       newdata_da2=newdata_da';
%        d1noo=datenum(2013,6,21,11,30,0);
%        indtmp=find(abs(newdate-d1noo)==min(abs(newdate-d1noo)));
%        newdata_noo2=newdata_noo(indtmp:end)';
        dtmp1=datenum(2013,10,18);dtmp2=datenum(2014,8,15);
        dtmp3=datenum(2016,7,1);dtmp4=datenum(2016,10,20);
        indtmp1=find(newdate<dtmp1);
        indtmp2=find(newdate>dtmp2 & newdate<dtmp3);
        indtmp3=find(newdate>dtmp4);
        indtmpt=[indtmp1 indtmp2 indtmp3];
        newdata_drr2=newdata_drr(indtmpt)';
%        newdata_mrr2=newdata_mrr';
%        newdata_drr2=newdata_drr';
       
       newdata_da3=sort(newdata_da2);
       count=1;
       for ii=1:5:length(newdata_da3)
           p_da(count,1)=ii/length(newdata_da3);
           p_da(count,2)=newdata_da3(ii);
           count=count+1;
       end
       
       newdata_drr3=sort(newdata_drr2);
       count=1;
       for ii=1:5:length(newdata_drr3)
           p_drr(count,1)=ii/length(newdata_drr3);
           p_drr(count,2)=newdata_drr3(ii);
           count=count+1;
       end
       
       
       plot(p_da(:,1),p_da(:,2),'Color','k'); hold on;
       plot(p_drr(:,1),p_drr(:,2),'Color','r'); hold on;
       disp(mean(newdata_da2));
       disp(mean(newdata_drr2));
              
        grid on;box on;
        set(gca,'XLim',[0 1],'YLim',[0 2000]);
        hl=legend('Darwin Airport','Darwin Reservoir');
        set(hl,'FontSize',fs-2,'Location','Northwest');
       
        set(gca,'XTick',0:0.1:1,'YTick',0:500:2000);
        xlabel('quantile','FontSize',fs);
        ylabel('(W/m^2)','FontSize',fs);
        title('(c) Quantile distribution of solar irradiance','FontSize',fs);
       
       
       axes('Position',pos6);
       
       tdata={newdata_da2(1:end), newdata_drr2};
       disp(mean(newdata_da2(1:end)));
       disp(mean(newdata_drr2));
       %violin(tdata);hold on;
       aboxplot(tdata,'labels',{''});hold on;
       ylabel('(W/m^2)','FontSize',fs);
       title('(d) Box plots of solar irradiance','FontSize',fs);
       hl=legend('Darwin Airport','Darwin Reservoir');
        set(hl,'FontSize',fs-2,'Location','Northeast');
       
       img_name =['compare_solar_v2.png'];
      saveas(gcf,img_name);