
clear;close;

% load in water balance model inflow file
filename='DRD_SacFlow_ML.csv';

data1=tfv_readBCfile2(filename);

outfile='DRR_inflow.csv';

% load in TWS water quality data
infile='E:\CloudStor\Shared\Aquatic Ecodynamics (AED)\AED_DarwinReservoirs\3_Data\Processed\WaterQuality\Brendan Working Dir\Matfiles\TWS_F.mat';
load(infile);
vars={'TEMP','WQ_CAR_PH','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_DIAG_TOT_TN','WQ_DIAG_TOT_TP','WQ_PHS_FRP'};
%newdata=struct().

% interpolate the data
for kk=1:length(vars)
    days=TWS.F.(vars{kk}).Date;
    days2=floor(days);
    tmp=unique(days2);
    disp(vars{kk});
    
    count=1;
    
    for ll=1:length(tmp)
        indss=find(days2==tmp(ll));
        if length(indss)>1
        newd=TWS.F.(vars{kk}).Depth(indss);
        newd2=TWS.F.(vars{kk}).Data(indss);
        newind=find(newd==max(newd));
        newind2=find(newd==min(newd));
        %if (~isempty(newind) && ~isnan(newd2(newind(1))) && tmp(ll)>73000)
        newdata.(vars{kk})(count,1)=tmp(ll);
        if kk==1
            newdata.(vars{kk})(count,2)=newd2(newind2(1));
        else
            newdata.(vars{kk})(count,2)=newd2(newind(1));
        end
        count=count+1;
        else
            disp(tmp(ll));
        
        end
       % end
    end
    
    if kk>3
        newdata.(vars{kk})(15,2)=newdata.(vars{kk})(15,2)/10;
    end
    
    newdata2.(vars{kk})=interp1(newdata.(vars{kk})(:,1),newdata.(vars{kk})(:,2),data1.Date);
end

% load in air temperature data for inflow water temperature
wea=tfv_readGLMfile('E:\database\DarwinV3\DRR_GLM_AED\bcs\MRR_met_hourly.csv');
%newdata2.TEMP=interp1(wea.Date,movmean(wea.AirTemp,24),data1.Date);
newdata=wea.AirTemp;
alpha = 0.05;
           exponentialMA = filter(alpha, [1 alpha-1], newdata);

           plot(wea.Date,newdata);
           hold on;
           plot(wea.Date,exponentialMA,'r');

%% write data to bc file
 ts=datenum(2011,11,16);
 inds=find(abs(data1.Date-ts)==min(abs(data1.Date-ts)));
 tf=datenum(2017,7,1);
 indf=find(abs(data1.Date-tf)==min(abs(data1.Date-tf)));
 
 ON=newdata2.WQ_DIAG_TOT_TN-newdata2.WQ_NIT_AMM -newdata2.WQ_NIT_NIT;
 OP=newdata2.WQ_DIAG_TOT_TP-newdata2.WQ_PHS_FRP;

    fid=fopen(outfile,'w');
    fprintf(fid,'%s\n','time,flow,SAL,TEMP,TRACER_1,AGE,SS1,OXY,DIC,PH,CH4,SIL,AMM,NIT,FRP,FRP_ADS,DOC,POC,DON,PON,DOP,POP,GRN,GRN_IN,GRN_IP,DIA,DIA_IN,DIA_IP,CRY,CRY_IN,CRY_IP,ZOO');
    
    for jj=inds:indf
        fprintf(fid,'%s,',datestr(data1.Date(jj),'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid,'%4.2f,',data1.Flow_MLd(jj)*1000/86400);
        fprintf(fid,'%4.2f,',0.011);
        fprintf(fid,'%4.2f,',exponentialMA(jj));
        fprintf(fid,'%s,','0.0,0.0');
        fprintf(fid,'%4.2f,',0.0);
        fprintf(fid,'%4.2f,',newdata2.WQ_OXY_OXY(jj));
        fprintf(fid,'%4.2f,',100);
        fprintf(fid,'%4.2f,',newdata2.WQ_CAR_PH(jj));
        fprintf(fid,'%s,','0.001');
        fprintf(fid,'%4.2f,',0.02);
        fprintf(fid,'%4.2f,',newdata2.WQ_NIT_AMM(jj));
        fprintf(fid,'%4.2f,',newdata2.WQ_NIT_NIT(jj));
        fprintf(fid,'%4.2f,',newdata2.WQ_PHS_FRP(jj));
        fprintf(fid,'%4.2f,',newdata2.WQ_PHS_FRP(jj)*0.1);
        fprintf(fid,'%4.2f,',ON(jj)*0.8*8);
        fprintf(fid,'%4.2f,',ON(jj)*0.2*8);
        fprintf(fid,'%4.2f,',ON(jj)*0.8);
        fprintf(fid,'%4.2f,',ON(jj)*0.2);
        fprintf(fid,'%4.2f,',OP(jj)*0.8);
        fprintf(fid,'%4.2f,',OP(jj)*0.2);
        fprintf(fid,'%s\n','0,0,0,0,0,0,0,0,0,0');
    end
    
            
      fclose(fid);
