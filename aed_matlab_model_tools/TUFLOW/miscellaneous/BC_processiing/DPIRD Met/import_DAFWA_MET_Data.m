function import_DAFWA_MET_Data(data_dir,data_file)

[~,sstr] = xlsread('Headers.xlsx');

DAFWA_Header = sstr(:,1);
AED_Header = sstr(:,2);



dirlist = dir([data_dir,'*.csv']);

SP = [];


for i = 1:length(dirlist)
    
    
    filename = [data_dir,dirlist(i).name];
    
    disp(filename);
    
    if dirlist(i).bytes > 5
        
        fid = fopen(filename,'rt');
        
        header_line = fgetl(fid);
        
        Headers = strsplit(header_line,',');
        Headers
        textformat = [repmat('%s ',1,length(Headers))];
        fclose(fid);
        fid = fopen(filename,'rt');
        
        datacell = textscan(fid,textformat,'Headerlines',1,'Delimiter',',');
        datacell{2}
        fclose(fid);
        for j = 1:length(Headers)
            
            ss = find(strcmpi(DAFWA_Header,Headers{j}) == 1);
            
            if strcmpi(AED_Header{ss},'Ignore') == 0
                
                if strcmpi(AED_Header{ss},'mDate') == 1
                    temp = datenum(regexprep(datacell{j},'"',''),'yyyy-mm-dd HH:MM:SS');
                else
                    temp = str2double(datacell{j});
                end
                
                if ~isfield(SP,AED_Header{ss})
                    
                    SP.(AED_Header{ss})(:,1) = temp;
                else
                    SP.(AED_Header{ss}) = [SP.(AED_Header{ss});temp];
                end
            end
        end
        
    end
end


save(data_file,'SP','-mat');





