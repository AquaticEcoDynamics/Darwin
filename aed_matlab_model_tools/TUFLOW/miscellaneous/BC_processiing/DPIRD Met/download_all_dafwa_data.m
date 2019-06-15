clear all; close all;

% [snum,sstr] = xlsread('weatherstations.csv','A2:A1000');
% 
% sites = sstr;
% 
% s_year = 1980;
% e_year = 2017;
% 
% year_array = s_year:1:e_year;
% 
% for i = 2:length(sites)
%     Site_ID = sites{i};
%     
%     outdir = ['All_DAFWA_Sites/',sites{i},'/'];
%     
%     Download_DAFWA_Met_Data_v1(Site_ID,outdir,year_array);
% end
    

% basedir = 'All_DAFWA_Sites/';
% 
% dirlist = dir(basedir);
% 
% for i = 3:length(dirlist)
%     
%     data_dir = [basedir,dirlist(i).name,'/'];
%     data_file = ['All_DAFWA_Processed/',dirlist(i).name,'.mat'];
%     
%     import_DAFWA_MET_Data(data_dir,data_file);
% end

basedir = 'All_DAFWA_Processed/';
dirlist = dir([basedir,'*.mat']);

for i = 1:length(dirlist)
    load(['All_DAFWA_Processed/',dirlist(i).name]);
    
    fid = fopen(['DAFWA_Air_Temp/',regexprep(dirlist(i).name,'.mat','.csv')],'wt');
    fprintf(fid,'Date,Air Temperature\n');
    
    for j = 1:length(SP.mDate)
        fprintf(fid,'%s,%4.4f\n',datestr(SP.mDate(j),'dd/mm/yyyy HH:MM:SS'),SP.Atemp(j));
    end
    fclose(fid);
    
end