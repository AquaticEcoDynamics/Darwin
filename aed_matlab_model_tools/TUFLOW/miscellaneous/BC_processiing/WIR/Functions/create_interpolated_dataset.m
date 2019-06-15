function var = create_interpolated_dataset(data,varname,site,depth,mtime)
% A Function to take a AED data structure, site and variable and create an
% interpolated dataset for use in creation of the input files

if isfield(data.(site),varname)
    
    t_depth = data.(site).(varname).Depth;
    tt_data = data.(site).(varname).Data;
    
    tt_date = floor(data.(site).(varname).Date);
    
    u_date = unique(tt_date);
    
    t_data(1:length(u_date)) = NaN;
    t_date(1:length(u_date)) = NaN;
    for iii = 1:length(u_date)
        sss = find(tt_date == u_date(iii));
        
        switch depth
            case 'Bottom'
                [~,ind] = min(t_depth(sss));
            case 'Surface'
                [~,ind] = max(t_depth(sss));
            otherwise
                disp('Not a valid depth name');
        end
        
        t_data(iii) = tt_data(sss(ind));
        t_date(iii) = data.(site).(varname).Date(sss(ind));
    end
    
    ss = find(~isnan(t_data) == 1);
    if length(ss) > 4
        
        if max(t_date(ss)) > mtime(1)
            
            var = interp1(t_date(ss),t_data(ss),mtime,'linear',mean(t_data(ss)));
            var(var < 0) = 0;
            
        else
            var = [];
        end
    else
        var = [];
    end
    
else
    var = [];
    
end