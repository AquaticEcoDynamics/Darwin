function import_wir_dataset(filename,type,varargin)
% A long winded but simple to use function to import in the wir dataset and
% convert to the AED data formats. Requires the "Wir Supporting Data.xlsx"
% spreadsheet in order to function correctly. This spreadsheet conatins all
% of the naming conventions, data conversions and GIS data in order to
% correctly create or append our existing data structures.
% Filename == Raw wir spreadsheet
% type == 'Level or WQ. Level data MUSt be export as a flat file, WQ as
% Cross-Tabulated
%
% Other arguments are Append with the matfile to be appended, or Create
% with the filename to create, Row and Column,Remove_Site, Remove_NaN,
% Summerise
%
%e.g. import_wir_dataset('59222/WaterLevelsForSiteFlatFile
%.xlsx','Level','Append','swan_all.mat','Row',99325,'Column','AJ');
% Written by Brendan Busch, badly, but still....... Lots of room for
% improvement.


% Defaults

Row = 10;
Column = 'AJ';

rmsite = 0;

append = 0;

summerise = 0;

rm_NaN = 0;

ver = 1;

for i = 1:2:length(varargin)
    
    switch varargin{i}
        
        case 'Append'
            
            matfile = varargin{i+1};
            
            fieldname = regexprep(matfile,'.mat','');
            
            append = 1;
            
            
        case 'Create'
            matfile = varargin{i+1};
            
            fieldname = regexprep(matfile,'.mat','');
            
            eval([fieldname '= [];']);
            
            save(matfile,fieldname,'-mat');
            
            append = 0;
            
            
        case 'Row'
            
            Row = varargin{i+1};
            
        case 'Column'
            
            Column = varargin{i+1};
            
        case 'Summerise'
            
            summerise = varargin{i+1};
            
        case 'Remove_Site'
            rmsite = 1;
            rm_sitename = varargin{i+1};
            
        case 'Remove_NaN'
            rm_NaN = varargin{i+1};
            
        case 'Version'
            ver = varargin{i+1};    
            
            
        otherwise
            disp('Input not allowed...');
    end
end

if rmsite
    load(matfile);
        
    eval(['if isfield(',fieldname,',','''',rm_sitename,'''','); ',fieldname,' = rmfield(',fieldname,',','''',rm_sitename,'''','); end;']);
    
    disp(['Removing site: ',rm_sitename,' from Matfile']);
    
    save(matfile,fieldname,'-mat');
    
    disp(['Updated Matfile save... Processing new data']);
end




switch type
    
    case 'Level'
        
        [data, headers] = import_xlsx_level(filename,Column,Row);
        
        swan_add = format_level_data(data,headers,ver);
        
    case 'WQ'
        
        [data,headers] = import_xlsx_wq(filename,Column,Row,ver);
        
        swan_add = format_wq_data(data,headers,ver);
        
    otherwise
        disp('Unknown File Type');
        
end


    

proc = process_data(swan_add,ver);


if append
    
    
    append_data(proc,fieldname,matfile)
    
else
    
    eval([fieldname '= proc']);
    
    save(matfile,fieldname,'-mat');
    
end

if rm_NaN
    
    remove_NAN_matfile(matfile);
    
end

if summerise
    
    summerise_sites(matfile);
end

end

function [data, headers] = import_xlsx_level(filename,Column,Row)

header_range = ['A1:',Column,'1'];
data_range = ['A2:',Column,num2str(Row)];

[~,~,raw1] = xlsread(filename,header_range);

[~,~,raw] = xlsread(filename,data_range);

headers = raw1(1,1:end);

data = raw(1:end,:);

end

function [data,headers] = import_xlsx_wq(filename,Column,Row,ver)

header_range = ['A1:',Column,'1'];
data_range = ['A2:',Column,num2str(Row)];

[~,~,raw1] = xlsread(filename,header_range);

[~,~,raw] = xlsread(filename,data_range);
if ver == 1
headers = raw(1,1:25);
headers(26:length(raw1)) = raw1(26:end);
else
    headers = raw(1,1:24);
    headers(25:length(raw1)) = raw1(25:end);
end
data = raw(2:end,:);
end

function swan_add = format_level_data(data,headers,ver)

[~,conv] = xlsread('WIR Supporting Data.xlsx','WQ_Headers','A2:C10000');

for j = 1:length(headers)
    
    ss = find(strcmp(headers{j},conv(:,1)) == 1);
    
    names = 'NewData';
    
    if ~isempty(ss)
        temp = data(:,j);
        
        if strcmpi(conv(ss,3),'Number') == 1
            disp('Number');
            for k = 1:length(temp)
                g = temp{k};
                if isnumeric(g)
                    newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss,2})(k,1) = g;
                else
                    newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss,2})(k,1) = str2double(g);
                end
            end
        else
            disp('Cell');
            newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss,2}) = temp;
        end
    end
end
clear data headers;

[sNum,sStr] = xlsread('WIR Supporting Data.xlsx','Site_Information','A2:H10000');

[~,varname] = xlsread('WIR Supporting Data.xlsx','Level_Headers');

swan_add = [];

newswan = newswan11;

clear newswan11;
if ver == 1
  ID = sNum(:,1);
else
  ID = sNum(:,2);  
end
Shortname = regexprep(sStr(:,4),'\s','');
Longname = sStr(:,3);
X = sNum(:,end-1);
Y = sNum(:,end);

names = fieldnames(newswan);

for i = 1:length(names)
    disp('***************************************************************');
    disp([num2str(i),' of ',num2str(length(names))]);
    
    vars = fieldnames(newswan.(names{i}));
    
    sites = cell2mat(newswan.(names{i}).Site_ID);
    if ver == 2
        
        sites = str2num(sites);
    end
    u_sites = unique(sites);
    
    for k = 1:length(newswan.(names{i}).Date)
        
        fff = regexp(newswan.(names{i}).Date(k),'\s','split','once');
        TDate = fff{1};
        
        nDate(k) = datenum([TDate{1},' ', newswan.(names{i}).Date{k}],'dd/mm/yyyy');
    end
    
    for j = 1:length(varname(:,1))
        
        sss = find(strcmp(varname{j,1},newswan.(names{i}).Determinand) == 1);
        
        for l = 1:length(u_sites)
            
            tt = find(u_sites(l) == ID);
            
            ww = find(sites(sss) == u_sites(l));
            disp(['Number of Samples: ',num2str(length(ww)),' from: ',Shortname{tt(1)}]);
            if ~isempty(ww)
                swan_add.(Shortname{tt(1)}).(varname{j,2}).Date = nDate(sss(ww));
                swan_add.(Shortname{tt(1)}).(varname{j,2}).Data = newswan.(names{i}).Reading_Value(sss(ww));
                swan_add.(Shortname{tt(1)}).(varname{j,2}).X = X(tt(1));
                swan_add.(Shortname{tt(1)}).(varname{j,2}).Y = Y(tt(1));
                if isfield(newswan.(names{i}),'Sample_Depths_M_1')
                    swan_add.(Shortname{tt(1)}).(varname{j,2}).Depth = newswan.(names{i}).Sample_Depths_M_1(sss(ww));
                end
                
                if isfield(newswan.(names{i}),'Sample_Depths_M')
                    swan_add.(Shortname{tt(1)}).(varname{j,2}).Depth = newswan.(names{i}).Sample_Depths_M(sss(ww));
                end
            end
        end
    end
end








end

function swan_add = format_wq_data(data,headers,ver)

[~,conv] = xlsread('WIR Supporting Data.xlsx','WQ_Headers','A2:C1000');

names = 'NewData';

headers
for j = 1:length(headers)
    
    ss = find(strcmpi(headers{j},conv(:,1)) == 1);
    
    if ~isempty(ss)
        temp = data(:,j);
        
        if strcmpi(conv(ss,3),'Number') == 1
            disp('Number');
            for k = 1:length(temp)
                g = temp{k};
                if isnumeric(g)
                    newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss(1),2})(k,1) = g;
                else
                    newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss(1),2})(k,1) = str2double(g);
                end
            end
        else
            disp('Cell');
            newswan11.(['p',regexprep(names,'.mat','')]).(conv{ss(1),2}) = temp;
        end
    else
        disp([headers{j},' not required']);
    end
end


clear data headers;

[sNum,sStr] = xlsread('WIR Supporting Data.xlsx','Site_Information','A2:H10000');

[~,varname] = xlsread('WIR Supporting Data.xlsx','Level_Headers');

swan_add = [];

newswan = newswan11;

clear newswan11;

if ver == 1
    ID = sNum(:,1);
else
    ID = sNum(:,2);
end
Shortname = regexprep(sStr(:,4),'\s','');
Longname = sStr(:,3);
X = sNum(:,end-1);
Y = sNum(:,end);

names = fieldnames(newswan);



for i = 1:length(names)
    disp('***************************************************************');
    disp([num2str(i),' of ',num2str(length(names))]);
    
    vars = fieldnames(newswan.(names{i}));
    
    sites = cell2mat(newswan.(names{i}).Site_ID);
    
    if ver == 2
        
        sites = str2num(sites);
    end
    
    u_sites = unique(sites);
    

    for k = 1:length(newswan.(names{i}).Date)
        
        fff = regexp(newswan.(names{i}).Date(k),'\s','split','once');
        TDate = fff{1};
        
        nDate(k) = datenum([TDate{1},' ', newswan.(names{i}).Time{k}],'dd/mm/yyyy HH:MM:SS');
    end
    
    for j = 1:length(vars)
        
        if isnumeric(newswan.(names{i}).(vars{j}))
            
            for l = 1:length(u_sites)
                
                tt = find(u_sites(l) == ID);

                ww = find(sites == u_sites(l));
                
                disp(['Number of Samples: ',num2str(length(ww)),' from: ',Shortname{tt(1)}]);
                if ~isempty(ww)
                    swan_add.(Shortname{tt(1)}).(vars{j}).Date = nDate(ww);
                    swan_add.(Shortname{tt(1)}).(vars{j}).Data = newswan.(names{i}).(vars{j})(ww);
                    swan_add.(Shortname{tt(1)}).(vars{j}).X = X(tt(1));
                    swan_add.(Shortname{tt(1)}).(vars{j}).Y = Y(tt(1));
                    if isfield(newswan.(names{i}),'Sample_Depths_M_1')
                        swan_add.(Shortname{tt(1)}).(vars{j}).Depth = newswan.(names{i}).Sample_Depths_M_1(ww);
                    end
                end
            end
        end
    end
end


end

function swan = process_data(swan_add,ver)

swan2 = swan_add;
clear swan_add;

[snum,sstr] = xlsread('WIR Supporting Data.xlsx','Variable_Conversion','A2:E10000');

conv = snum(:,1);
old_name = sstr(:,2);
new_name = sstr(:,3);
units = sstr(:,5);

clear sstr snum;

[sNum,sStr] = xlsread('WIR Supporting Data.xlsx','Site_Information','A2:H10000');

if ver == 1
    ID = sNum(:,1);
else
    ID = sNum(:,2);
end
Shortname = regexprep(sStr(:,4),'\s','');
Longname = sStr(:,3);
X = sNum(:,end-1);
Y = sNum(:,end);



swan = [];



sites = fieldnames(swan2);

for i = 1:length(sites)
    
    disp(sites{i});
    
    vars = fieldnames(swan2.(sites{i}));
    
    swan.(sites{i}) = [];
    
    
    bb = find(strcmp(Shortname,sites{i}) == 1);
    
    for j = 1:length(vars)
        
        ss = find(strcmp(old_name,vars{j}) == 1);
        if ~isempty(ss)
            if strcmp(new_name{ss(1)},'Ignore') == 0
                
                tdate(:,1) = swan2.(sites{i}).(vars{j}).Date;
                tdata(:,1) = swan2.(sites{i}).(vars{j}).Data;
                tdepth(:,1) = swan2.(sites{i}).(vars{j}).Depth;
                
                
                if conv(ss(1)) == 0
                    
                    disp('Conversion via script');
                    
                    tdata_1 = conductivity2salinity(tdata);
                    
                else
                    tdata_1 = tdata .* conv(ss(1));
                    
                end
                
                if ~isfield(swan.(sites{i}),new_name{ss(1)})
                    swan.(sites{i}).(new_name{ss(1)}).X  = swan2.(sites{i}).(vars{j}).X;
                    swan.(sites{i}).(new_name{ss(1)}).Units = units(ss(1));
                    swan.(sites{i}).(new_name{ss(1)}).Y  = swan2.(sites{i}).(vars{j}).Y;
                    if ~isempty(bb)
                        swan.(sites{i}).(new_name{ss(1)}).Title = Longname(bb(1));
                    else
                        swan.(sites{i}).(new_name{ss(1)}).Title = sites(i);
                    end
                    swan.(sites{i}).(new_name{ss(1)}).Variable_Name = vars{j};
                    
                    swan.(sites{i}).(new_name{ss(1)}).Data = tdata_1;
                    swan.(sites{i}).(new_name{ss(1)}).Date = tdate;
                    swan.(sites{i}).(new_name{ss(1)}).Depth = tdepth;
                    
                else
                    swan.(sites{i}).(new_name{ss(1)}).Data = [swan.(sites{i}).(new_name{ss(1)}).Data;tdata_1];
                    swan.(sites{i}).(new_name{ss(1)}).Date = [swan.(sites{i}).(new_name{ss(1)}).Date; tdate ];
                    swan.(sites{i}).(new_name{ss(1)}).Depth = [swan.(sites{i}).(new_name{ss(1)}).Depth;tdepth];
                    
                end
                
                clear tdata tdata_1 tdate tdepth
            end
            
        end
    end
    clear bb;
end

% Need to deal with the depth data

sites = fieldnames(swan);
for i = 1:length(sites)
    vars = fieldnames(swan.(sites{i}));
    for j = 1:length(vars)
        
        disp([sites{i},': ',vars{j}]);
        
        tdepth = swan.(sites{i}).(vars{j}).Depth;
        swan.(sites{i}).(vars{j}).Depth_Chx = tdepth;
        
        swan.(sites{i}).(vars{j}) = rmfield(swan.(sites{i}).(vars{j}),'Depth');
        
        swan.(sites{i}).(vars{j}).Depth(1:length(tdepth),1) = 0;
        
        
        
        for k = 1:length(tdepth)
            
            mm = cell2mat(tdepth(k));
            
            if ~isnumeric(mm)
                
                
                mmm = str2num(mm);
                
            else
                mmm = mm;
            end
            
            if ~isempty(mmm)
                
                if mmm > 0
                    mmm = mmm * -1;
                end
                
                if ~isnan(mmm)
                    swan.(sites{i}).(vars{j}).Depth(k,1) = mmm;
                else
                    disp(['NaN For Depth: ', vars{j}]);
                    swan.(sites{i}).(vars{j}).Depth(k,1) = 0;
                end
            else
                swan.(sites{i}).(vars{j}).Depth(k,1) = 0;
                disp(mm);
            end
            clear mm mmm;
        end
        
        
    end
end

% Secondary Variables.....................

sites = fieldnames(swan);

for i = 1:length(sites)
    
    
    % POC calculation from TOC / Doc ratio
    
    if isfield(swan.(sites{i}),'WQ_OGM_TOC') & isfield(swan.(sites{i}),'WQ_OGM_DOC')
        
        TOC_Temp = swan.(sites{i}).WQ_OGM_TOC.Data;
        TOC_Date = swan.(sites{i}).WQ_OGM_TOC.Date;
        
        DOC_Temp = swan.(sites{i}).WQ_OGM_DOC.Data;
        DOC_Date = swan.(sites{i}).WQ_OGM_DOC.Date;
        
        inc = 1;
        
        u_dates = unique(floor(TOC_Date));
        
        for ii = 1:length(u_dates)
            ss = find(floor(DOC_Date) == u_dates(ii));
            if ~isempty(ss)
                tt = find(floor(TOC_Date) == u_dates(ii));
                
                for k = 1:length(ss)
                    
                    DOC_subset(inc) = DOC_Temp(ss(k));
                    TOC_subset(inc) = TOC_Temp(tt(k));
                    
                    
                    inc = inc + 1;
                    
                end
            end
        end
        
        clear TOC_Temp TOC_Date
        
        if inc > 1
            
            calc = mean(TOC_subset / DOC_subset);
            
            TOC_Calc = DOC_Temp .* calc;
            
            
            swan.(sites{i}).WQ_OGM_POC = swan.(sites{i}).WQ_OGM_DOC;
            
            swan.(sites{i}).WQ_OGM_POC.Data = [];
            
            
            swan.(sites{i}).WQ_OGM_POC.Data = TOC_Calc - DOC_Temp;
            
            swan.(sites{i}).WQ_OGM_POC.Variable_Name = 'POC';
            
            disp(['POC Calculated for: ',sites{i}, ' ',num2str(calc)]);
            
            clear TOC_Calc calc TOC_subset DOC_subset
        end
    end
    
    
    if ~isfield(swan.(sites{i}),'WQ_OGM_TOC') & isfield(swan.(sites{i}),'WQ_OGM_DOC')
        
        
        DOC_Temp = swan.(sites{i}).WQ_OGM_DOC.Data;
        
        
        swan.(sites{i}).WQ_OGM_POC = swan.(sites{i}).WQ_OGM_DOC;
        
        swan.(sites{i}).WQ_OGM_POC.Data = [];
        
        TOC_Calc = (DOC_Temp .* 1.1) + 46;
        
        
        swan.(sites{i}).WQ_OGM_POC.Data = TOC_Calc - DOC_Temp;
        
        swan.(sites{i}).WQ_OGM_POC.Variable_Name = 'POC';
        disp(['POC Calculated for: ',sites{i}]);
        
    end
    
    
    
end

end

function append_data(proc,fieldname,matfile)

load(matfile);

eval(['swan = ', fieldname,';']);

sites = fieldnames(swan);

for i = 1:length(sites)
    if isfield(proc,sites{i})
        vars = fieldnames(swan.(sites{i}));
        for j = 1:length(vars)
            if isfield(swan.(sites{i}),vars{j}) & isfield(proc.(sites{i}),vars{j})
                disp('Append')
                proc.(sites{i}).(vars{j}).Data = [proc.(sites{i}).(vars{j}).Data;swan.(sites{i}).(vars{j}).Data];
                proc.(sites{i}).(vars{j}).Date = [proc.(sites{i}).(vars{j}).Date;swan.(sites{i}).(vars{j}).Date];
                proc.(sites{i}).(vars{j}).Depth = [proc.(sites{i}).(vars{j}).Depth;swan.(sites{i}).(vars{j}).Depth];
                
            end
            if ~isfield(proc.(sites{i}),vars{j}) & isfield(swan.(sites{i}),vars{j})
                disp('New Site')
                proc.(sites{i}).(vars{j}) = swan.(sites{i}).(vars{j});
            end
            
        end
    else
        proc.(sites{i}) = swan.(sites{i});
    end
end

eval([fieldname,' = proc;']);
save(matfile,fieldname,'-mat');
end

function remove_NAN_matfile(matfile)
% A Simple function to remove the NaN's from a AED matfile

load(matfile);

fname = regexprep(matfile,'.mat','');

eval(['fdata = ',fname,';']);
eval(['clear ',fname,';']);


sites = fieldnames(fdata);

for i = 1:length(sites)
    vars = fieldnames(fdata.(sites{i}));
    for j = 1:length(vars)
        
        mdata = fdata.(sites{i}).(vars{j}).Data;
        mdate = fdata.(sites{i}).(vars{j}).Date;
        mdepth = fdata.(sites{i}).(vars{j}).Depth;
        
        ss = find(~isnan(mdata));
        disp([sites{i},': ',vars{j}]);
        if ~isempty(ss)
            eval([fname,'.',sites{i},'.',vars{j},' = fdata.',sites{i},'.',vars{j},';']);
            eval([fname,'.',sites{i},'.',vars{j},'.Data = [];']);
            eval([fname,'.',sites{i},'.',vars{j},'.Date = [];']);
            eval([fname,'.',sites{i},'.',vars{j},'.Depth = [];']);
            eval([fname,'.',sites{i},'.',vars{j},'.Data = fdata.',sites{i},'.',vars{j},'.Data(ss);']);
            eval([fname,'.',sites{i},'.',vars{j},'.Depth = fdata.',sites{i},'.',vars{j},'.Depth(ss);']);
            eval([fname,'.',sites{i},'.',vars{j},'.Date = fdata.',sites{i},'.',vars{j},'.Date(ss);']);
        end
    end
end

save(matfile,fname,'-mat');
end

function summerise_sites(matfile)

outdir = 'Site_Summary\';

load(matfile);

eval(['swan = ',regexprep(matfile,'.mat',''),';']);

sites = fieldnames(swan);

for k = 1:length(sites)
    
    
    
    
    sitename = sites{k};
    
    
    vars = fieldnames(swan.(sitename));
    
    findir = [outdir,sitename,'\'];
    
    
    if ~exist(findir,'dir');
        mkdir(findir);
    end
    
    
    
    fid = fopen([findir,'1. Summary.csv'],'wt');
    fprintf(fid,'Variable Name,Min Date,Max Date,Number of Samples\n');
    
    for i = 1:length(vars)
        
        mindate = min(swan.(sitename).(vars{i}).Date);
        maxdate = max(swan.(sitename).(vars{i}).Date);
        num_samples = length(swan.(sitename).(vars{i}).Date);
        
        fprintf(fid,'%s,%s,%s,%5.3f\n',vars{i},datestr(mindate,'dd/mm/yyyy HH:MM:SS'),datestr(maxdate,'dd/mm/yyyy HH:MM:SS'),num_samples);
        
        xdata = swan.(sitename).(vars{i}).Date;
        ydata = swan.(sitename).(vars{i}).Data;
        
        plot(xdata,ydata,'.r');
        
        set(gca,'XGrid','on','YGrid','on');
        
        
        if max(xdata) - min(xdata) > 10
            xarray = min(xdata):(max(xdata) - min(xdata))/5:max(xdata);
            xlim([min(xdata) max(xdata)]);
            set(gca,'XTick',xarray,'xticklabel',datestr(xarray,'dd/mm/yyyy'));
        else
            datetick('x','dd/mm/yyyy');
        end
        
        title(regexprep([sitename,': ',vars{i}],'_','-'),'fontsize',10,'fontweight','bold');
        
        savename = [findir,vars{i},'.png'];
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        xSize = 18;
        ySize = 7;
        xLeft = (21-xSize)/2;
        yTop = (30-ySize)/2;
        set(gcf,'paperposition',[0 0 xSize ySize]);
        
        print(gcf,savename,'-dpng');
        
        close
        
        
        
        
    end
    
    fclose(fid);
    
end

sites =fieldnames(swan);


for i = 1:length(sites)
    vars = fieldnames(swan.(sites{i}));
    
    S(i).X = swan.(sites{i}).(vars{1}).X;
    S(i).Y = swan.(sites{i}).(vars{1}).Y;
    S(i).Name = sites{i};
    S(i).FullName = swan.(sites{i}).(vars{1}).Title{1};
    S(i).Geometry = 'Point';
end

shapename = [outdir,regexprep(matfile,'mat','shp')];

shapewrite(S,shapename);

end

% Conversions for salinity (CSIRO)
function salinity = conductivity2salinity(conductivity)
% Converts conductivity to salinity using sw_c3515

CondRatio = conductivity./(sw_c3515.*1000);
press = zeros(size(CondRatio));
press = zeros(size(CondRatio));
sal = real(sw_salt(CondRatio(:),25,press(:)));
salinity = sal;


end
function c3515 = sw_c3515()

% SW_C3515   Conductivity at (35,15,0)
%=========================================================================
% SW_c3515  $Revision: 1.1 $   $Date: 2007/02/14 04:50:07 $
%       %   Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  c3515 = sw_c3515
%
% DESCRIPTION:
%   Returns conductivity at S=35 psu , T=15 C [ITPS 68] and P=0 db).
%
% INPUT: (none)
%
% OUTPUT:
%   c3515  = Conductivity   [mmho/cm == mS/cm]
%
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    R.C. Millard and K. Yang 1992.
%    "CTD Calibration and Processing Methods used by Woods Hole
%     Oceanographic Institution"  Draft April 14, 1992
%    (Personal communication)
%=========================================================================

% CALLER: none
% CALLEE: none
%

c3515 = 42.914;

return
%-------------------------------------------------------------------------
end
function S = sw_salt(cndr,T,P)

% SW_SALT    Salinity from cndr, T, P
%=========================================================================
% SW_SALT  $Revision: 1.1 $  $Date: 2007/02/14 04:50:07 $
%          Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE: S = sw_salt(cndr,T,P)
%
% DESCRIPTION:
%   Calculates Salinity from conductivity ratio. UNESCO 1983 polynomial.
%
% INPUT:
%   cndr = Conductivity ratio     R =  C(S,T,P)/C(35,15,0) [no units]
%   T    = temperature [degree C (IPTS-68)]
%   P    = pressure    [db]
%
% OUTPUT:
%   S    = salinity    [psu      (PSS-78)]
%
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER: general purpose
% CALLEE: sw_sals.m sw_salrt.m sw_salrp.m


%----------------------------------
% CHECK INPUTS ARE SAME DIMENSIONS
%----------------------------------
[mc,nc] = size(cndr);
[mt,nt] = size(T);
[mp,np] = size(P);

if ~(mc==mt | mc==mp | nc==nt | nc==np)
    error('sw_salt.m: cndr,T,P must all have the same dimensions')
end %if

%-------
% BEGIN
%-------
R  = cndr;
rt = sw_salrt(T);
Rp = sw_salrp(R,T,P);
Rt = R./(Rp.*rt);
S  = sw_sals(Rt,T);

return
%--------------------------------------------------------------------

end
function rt = sw_salrt(T)

% SW_SALRT   Conductivity ratio   rt(T)     = C(35,T,0)/C(35,15,0)
%=========================================================================
% SW_SALRT  $Revision: 1.1 $  $Date: 2007/02/14 04:50:07 $
%           Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  rt = sw_salrt(T)
%
% DESCRIPTION:
%    Equation rt(T) = C(35,T,0)/C(35,15,0) used in calculating salinity.
%    UNESCO 1983 polynomial.
%
% INPUT:
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   rt = conductivity ratio  [no units]
%
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER: sw_salt
% CALLEE: none

% rt = rt(T) = C(35,T,0)/C(35,15,0)
% Eqn (3) p.7 Unesco.

c0 =  0.6766097;
c1 =  2.00564e-2;
c2 =  1.104259e-4;
c3 = -6.9698e-7;
c4 =  1.0031e-9;

rt = c0 + (c1 + (c2 + (c3 + c4.*T).*T).*T).*T;

return
%--------------------------------------------------------------------
end
function Rp = sw_salrp(R,T,P)

% SW_SALRP   Conductivity ratio   Rp(S,T,P) = C(S,T,P)/C(S,T,0)
%=========================================================================
% SW_SALRP   $Revision: 1.1 $  $Date: 2007/02/14 04:50:07 $
%            Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  Rp = sw_salrp(R,T,P)
%
% DESCRIPTION:
%    Equation Rp(S,T,P) = C(S,T,P)/C(S,T,0) used in calculating salinity.
%    UNESCO 1983 polynomial.
%
% INPUT: (All must have same shape)
%   R = Conductivity ratio  R =  C(S,T,P)/C(35,15,0) [no units]
%   T = temperature [degree C (IPTS-68)]
%   P = pressure    [db]
%
% OUTPUT:
%   Rp = conductivity ratio  Rp(S,T,P) = C(S,T,P)/C(S,T,0)  [no units]
%
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER: sw_salt
% CALLEE: none

%-------------------
% CHECK INPUTS
%-------------------
if nargin~=3
    error('sw_salrp.m: requires 3 input arguments')
end %if

[mr,nr] = size(R);
[mp,np] = size(P);
[mt,nt] = size(T);
if ~(mr==mp | mr==mt | nr==np | nr==nt)
    error('sw_salrp.m: R,T,P must all have the same shape')
end %if

%-------------------
% eqn (4) p.8 unesco.
%-------------------
d1 =  3.426e-2;
d2 =  4.464e-4;
d3 =  4.215e-1;
d4 = -3.107e-3;

e1 =  2.070e-5;
e2 = -6.370e-10;
e3 =  3.989e-15;

Rp = 1 + ( P.*(e1 + e2.*P + e3.*P.^2) ) ...
    ./ (1 + d1.*T + d2.*T.^2 +(d3 + d4.*T).*R);

return
%-----------------------------------------------------------------------
end
function S = sw_sals(Rt,T)

% SW_SALS    Salinity of sea water
%=========================================================================
% SW_SALS  $Revision: 1.1 $  $Date: 2007/02/14 04:50:07 $
%          Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  S = sw_sals(Rt,T)
%
% DESCRIPTION:
%    Salinity of sea water as a function of Rt and T.
%    UNESCO 1983 polynomial.
%
% INPUT:
%   Rt = Rt(S,T) = C(S,T,0)/C(35,T,0)
%   T  = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   S  = salinity    [psu      (PSS-78)]
%
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER: sw_salt
% CALLEE: none

%--------------------------
% CHECK INPUTS
%--------------------------
if nargin~=2
    error('sw_sals.m: requires 2 input arguments')
end %if

[mrt,nrt] = size(Rt);
[mT,nT]   = size(T);
if ~(mrt==mT | nrt==nT)
    error('sw_sals.m: Rt and T must have the same shape')
end %if

%--------------------------
% eqn (1) & (2) p6,7 unesco
%--------------------------
a0 =  0.0080;
a1 = -0.1692;
a2 = 25.3851;
a3 = 14.0941;
a4 = -7.0261;
a5 =  2.7081;

b0 =  0.0005;
b1 = -0.0056;
b2 = -0.0066;
b3 = -0.0375;
b4 =  0.0636;
b5 = -0.0144;

k  =  0.0162;

Rtx   = sqrt(Rt);
del_T = T - 15;
del_S = (del_T ./ (1+k*del_T) ) .* ...
    ( b0 + (b1 + (b2+ (b3 + (b4 + b5.*Rtx).*Rtx).*Rtx).*Rtx).*Rtx);

S = a0 + (a1 + (a2 + (a3 + (a4 + a5.*Rtx).*Rtx).*Rtx).*Rtx).*Rtx;

S = S + del_S;

return
%----------------------------------------------------------------------
end