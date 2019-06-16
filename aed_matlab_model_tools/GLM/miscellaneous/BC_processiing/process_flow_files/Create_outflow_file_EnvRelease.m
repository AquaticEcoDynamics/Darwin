
clear;close;

filename='DRR_extraction.csv';
sheet=1;

data1=tfv_readBCfile(filename);
dates=floor(data1.Date);
outflow=data1.Extraction;

%% write data

    outfile='DRR_envRelease_m3s.csv';
    
    fid=fopen(outfile,'w');
    fprintf(fid,'%s\n','time,flow');
    
        
    for i=min(dates):max(dates)
        outf=0.03;
        fprintf(fid,'%s,',datestr(i,'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid,'%4.2f,',outf);
        fprintf(fid,'%s\n','');
        
    end
        
      fclose(fid);
