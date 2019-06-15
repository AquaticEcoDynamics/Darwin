clear all; close all;

old_dir = 'Old_Files/';
new_dir = 'New_Files/';
rem_var = 'N2O';


old_dir_list = dir([old_dir,'*.csv']);


for i = 1:length(old_dir_list)
    
    oD = tfv_readBCfile([old_dir,old_dir_list(i).name]);
    
    oD = rmfield(oD,rem_var);
    
    vars = fieldnames(oD);
    
    fid = fopen([new_dir,old_dir_list(i).name],'wt');
    
    for j = 1:length(vars)
        if j == length(vars)
            fprintf(fid,'%s\n',vars{j});
        else
            fprintf(fid,'%s,',vars{j});
        end
    end
    
    for k = 1:length(oD.ISOTime)
        for j = 1:length(vars)
            if j == 1
                fprintf(fid,'%s,',datestr(oD.ISOTime(k),'dd/mm/yyyy HH:MM'));
            else
                if j == length(vars)
                    fprintf(fid,'%4.4f\n',oD.(vars{j})(k));
                else
                    fprintf(fid,'%4.4f,',oD.(vars{j})(k));
                end
            end
        end
    end
    fclose(fid);
         
    
end