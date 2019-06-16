
clear;close;

% load in DRR intake log file
filename='DRR_extraction.csv';
sheet=1;

data1=tfv_readBCfile(filename);
dates=floor(data1.Date);
outflow=data1.Extraction;

%% write data

    outfile='DRR_outflow_m3s.csv';
    
    fid=fopen(outfile,'w');
    fprintf(fid,'%s\n','time,flow');
    
        
    for i=min(dates):max(dates)
        inds=find(dates==i);
        outf=mean(outflow(inds))*24/86400;
        fprintf(fid,'%s,',datestr(i,'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid,'%4.2f,',outf);
        fprintf(fid,'%s\n','');
        
    end
        
      fclose(fid);
