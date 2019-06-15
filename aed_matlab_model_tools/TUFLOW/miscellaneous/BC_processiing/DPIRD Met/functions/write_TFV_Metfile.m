function write_TFV_Metfile(SP,mainfile,rainfile)


fid = fopen(mainfile,'wt');

fprintf(fid,'ISOTime,Wx,Wy,Atemp,Rel_Hum,Sol_Rad,LW_Net,Clouds\n');

for i = 1:length(SP.mDate)
    fprintf(fid,'%s,',datestr(SP.mDate(i),'dd/mm/yyyy HH:MM:SS'));
    fprintf(fid,'%4.4f,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f\n',...
        SP.Wx(i),SP.Wy(i),SP.Atemp(i),SP.RelHum(i),SP.SolRad(i),SP.LW(i),SP.Clouds(i));
end
fclose(fid);

fid = fopen(rainfile,'wt');

fprintf(fid,'ISOTime,Precip\n');
for i = 1:length(SP.Days)
    fprintf(fid,'%s,%4.4f\n',datestr(SP.Days(i),'dd/mm/yyyy HH:MM:SS'),SP.Rain_Daily(i));
end
fclose(fid);




