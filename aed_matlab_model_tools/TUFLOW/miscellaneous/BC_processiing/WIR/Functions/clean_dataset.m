function swan = clean_dataset(swan);

swan_all = swan;

clear swan;

sites = fieldnames(swan_all);

for i = 1:length(sites)
    vars = fieldnames(swan_all.(sites{i}));
    
    for j = 1:length(vars)
        swan.(sites{i}).(vars{j}) = swan_all.(sites{i}).(vars{j});
        swan.(sites{i}).(vars{j}).Date = [];
        swan.(sites{i}).(vars{j}).Data = [];
        swan.(sites{i}).(vars{j}).Depth = [];
        
        all_date = swan_all.(sites{i}).(vars{j}).Date;
        all_data = swan_all.(sites{i}).(vars{j}).Data;
        all_depth = swan_all.(sites{i}).(vars{j}).Depth;
        
        
        swan.(sites{i}).(vars{j}).Date(1,1) = all_date(1);
        swan.(sites{i}).(vars{j}).Data(1,1) = all_data(1);
        swan.(sites{i}).(vars{j}).Depth(1,1) = all_depth(1);
        
        inc = 2;
        
        for k = 2:length(all_date)
            sss = find(swan.(sites{i}).(vars{j}).Date == all_date(k) & ...
                swan.(sites{i}).(vars{j}).Data == all_data(k) & ...
                swan.(sites{i}).(vars{j}).Depth == all_depth(k));
            
            if isempty(sss)
                swan.(sites{i}).(vars{j}).Date(inc,1) = all_date(k);
                swan.(sites{i}).(vars{j}).Data(inc,1) = all_data(k);
                swan.(sites{i}).(vars{j}).Depth(inc,1) = all_depth(k);
                inc = inc + 1;
            end
        end
        
        [swan.(sites{i}).(vars{j}).Date,ind] = sort(swan.(sites{i}).(vars{j}).Date);
        
        swan.(sites{i}).(vars{j}).Data = swan.(sites{i}).(vars{j}).Data(ind);
        swan.(sites{i}).(vars{j}).Depth = swan.(sites{i}).(vars{j}).Depth(ind);
    end
end
    
% save swan_original.mat swan_all -mat;
% save swan.mat swan -mat;


%         
%         mDate = swan.(sites{i}).(vars{j}).Date;
%         
%         u_dates = unique(floor(mDate));
% 
%         
%         for k = 1:length(u_dates)
%             
%             sss = find(floor(swan.(sites{i}).(vars{j}).Date) == u_dates(k));
%             
%             all_data = swan.(sites{i}).(vars{j}).Data(sss);
%             all_depth = swan.(sites{i}).(vars{j}).Depth(sss);
%             
%             
%             min_depth = min(all_depth);
%             max_depth = max(all_depth);
%             
%             tS = find(all_depth == max_depth);
%             tB = find(all_depth == min_depth);
%             
%             
%             swan1.(sites{i}).(vars{j}).Surface.Date(k,1) = u_dates(k);
%             swan1.(sites{i}).(vars{j}).Surface.Data(k,1) = all_data(tS(1));
%             
%             swan1.(sites{i}).(vars{j}).Bottom.Date(k,1) = u_dates(k);
%             swan1.(sites{i}).(vars{j}).Bottom.Data(k,1) = all_data(tB(1));
%             
%         end
%     end
% end
            
            
