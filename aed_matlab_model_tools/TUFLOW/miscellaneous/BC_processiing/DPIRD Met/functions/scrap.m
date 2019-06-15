
outdir = 'SP/';

if ~exist(outdir,'dir')
    mkdir(outdir);
end

address_part_A   = 'https://api.agric.wa.gov.au/v1/weatherstations/hourrecordings.csv?stationId=SP&fromDate=';
address_part_B   = '&api_key=0CEFB4534E1C6B6716418A0F.apikey';

year_array = [2008:01:2016];

month_array = [1:1:12];

for i = 1:length(year_array)
    for j = 1:length(month_array)
        
       sdate = datenum(year_array(i),month_array(j),01);
       
       disp(datestr(sdate));
       edate = datenum(year_array(i),month_array(j),eomday(year_array(i),month_array(j)));

       
       mid_string = [datestr(sdate,'yyyy-mm-dd'),'&toDate=',datestr(edate,'yyyy-mm-dd')];
       
       address = [address_part_A,mid_string,address_part_B];
       
       filename = [outdir,datestr(sdate,'yyyymmdd'),'.csv'];
       

        urlwrite(address,filename);
        
    end
end