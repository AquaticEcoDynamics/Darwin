% This script sets up the DAFWA download and file creation. See
% weatherstations.csv for Site information.
% This script requires Matlab 2014a to run.

Site_ID = 'SP';

data_dir = 'SG_Met_2018/';

data_file = 'SG_Met_2018.mat';

year_array = [2017:01:2018];

metfile = 'SG_Met_2018/SG_Met_2018.csv';
rainfile = 'SG_Met_2018/SG_Rain_2018.csv';
imagefile = 'SG_Met_2018/SG_Met_2018';



% End of Configuration______________________________________

Download_DAFWA_Met_Data_v1(Site_ID,data_dir,year_array);

import_DAFWA_MET_Data(data_dir,data_file);

create_TFV_Met_From_DAFWA(metfile,rainfile,imagefile,data_file)