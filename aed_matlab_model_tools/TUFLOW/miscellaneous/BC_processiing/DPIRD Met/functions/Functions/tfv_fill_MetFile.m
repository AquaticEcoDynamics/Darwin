clear all; close all;
addpath(genpath('Functions'));


filetype = 'main';%main or rain

mainfile = '../Import Met Data/narrung met output/tfv_ll_met_narrung.csv';
fillfile = '../Import Met Data/currency_crk met output/tfv_ll_met_currency_crk.csv';

newfile = '../Import Met Data/narrung met output/tfv_ll_met_narrung_Filled.csv';

main = tfv_readBCfile(mainfile);
fill = tfv_readBCfile(fillfile);

new = main;

daterange = [datenum(2014,09,01) datenum(2014,11,01)];

ss = find(main.ISOTime >= daterange(1) & main.ISOTime <= daterange(2));
tt = find(fill.ISOTime >= daterange(1) & fill.ISOTime <= daterange(2));

vars = fieldnames(main);

if length(ss) == length(tt)
    
    for i = 1:length(vars)
        if strcmpi(vars{i},'ISOTime') == 0  & strcmpi(vars{i},'Wx') == 0 & strcmpi(vars{i},'Wy') == 0
            disp(['Filling ',vars{i}]);
            new.(vars{i})(ss) = fill.(vars{i})(tt);
        end
    end
    
    if strcmpi(filetype,'main') == 1
        
        fid = fopen(newfile,'wt');
        fprintf(fid,'ISOTime,Wx,Wy,Atemp,Rel_Hum,Sol_Rad,Clouds \n');
        
        for ii = 1:length(new.ISOTime)
            fprintf(fid,'%s,%f,%f,%f,%f,%f,%f \n',...
                datestr(new.ISOTime(ii),'dd/mm/yyyy HH:MM:SS'),...
                new.Wx(ii),...
                new.Wy(ii),...
                new.Atemp(ii),...
                new.Rel_Hum(ii),...
                new.Sol_Rad(ii),...
                new.Clouds(ii));
        end
        fclose(fid);
        
        
    else
        
        fid = fopen(newfile,'wt');
        fprintf(fid,'ISOTime,Precip \n');
        
        for ii = 1:length(new.ISOTime)
            fprintf(fid,'%s,%f \n',...
                datestr(new.ISOTime(ii),'dd/mm/yyyy HH:MM:SS'),...
                new.Precip(ii));
        end
        fclose(fid);
        
    end
    
else
    stop
end




