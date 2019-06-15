main_dir = 'SP/';

dirlist = dir([main_dir,'*.csv']);

fid1 = fopen('Headers.txt','wt');

for i = 1:length(dirlist)
    
    filename = [main_dir,dirlist(i).name];
    disp(filename);
    fid = fopen(filename,'rt');
    
    sL = fgetl(fid);
    
    fprintf(fid1,'%s\n',sL);
    
    fclose(fid);
end
fclose all;