function peel_u = sort_WIR_data(peel)

%load peel.mat;

sites = fieldnames(peel);

for i = 1:length(sites)
    
    vars = fieldnames(peel.(sites{i}));
    
    for j = 1:length(vars)
        
        xdata = peel.(sites{i}).(vars{j}).Date;
        ydata = peel.(sites{i}).(vars{j}).Data;
        zdata = peel.(sites{i}).(vars{j}).Depth;
        
        xdata1 = [];
        ydata1 = [];
        zdata1 = [];
        
        inc = 1;
        u_array = [];
        
        u_array(1:length(xdata),1) = 0;
        
        for k = 1:length(xdata)
            
            if u_array(k) == 0
                
                ss = find(xdata == xdata(k) & ydata == ydata(k) & zdata == zdata(k));
                
                if length(ss) > 1
                    
                    tt = find(~isnan(ydata(ss))==1);
                    if ~isempty(tt)
                        xdata1(inc,1) = xdata(ss(tt(1)));
                        ydata1(inc,1) = ydata(ss(tt(1)));
                        zdata1(inc,1) = zdata(ss(tt(1)));
                        inc = inc + 1;
                    else
                        xdata1(inc,1) = xdata(ss(1));
                        ydata1(inc,1) = ydata(ss(1));
                        zdata1(inc,1) = zdata(ss(1));
                        inc = inc + 1;
                    end
                    
                else
                    xdata1(inc,1) = xdata(ss(1));
                    ydata1(inc,1) = ydata(ss(1));
                    zdata1(inc,1) = zdata(ss(1));
                    inc = inc + 1;
                end
                
                u_array(ss,1) = 1;
            end
        end
        
        peel_u.(sites{i}).(vars{j}) = peel.(sites{i}).(vars{j});
        
        [peel_u.(sites{i}).(vars{j}).Date,ind] = sort(xdata1);
        
        peel_u.(sites{i}).(vars{j}).Data = ydata1(ind);
        
        peel_u.(sites{i}).(vars{j}).Depth = zdata1(ind);
        
    end
    
    %peel_u.TestSite = find_matching('AMM',peel_u.p019.WQ_NIT_AMM,'NIT',peel.p019.WQ_NIT_NIT);
    
end

function data = find_matching(varargin)
% Function to find the matching samples at the right date and depth for a
% given number of variable inputs

for i = 1:2:length(varargin)-1
    
    data.(varargin{i}).Raw = varargin{i+1};
    
end

vars = fieldnames(data);

first_var = varargin{1};

%for this calc, all dates will be daily....

for i = 1:length(vars)
    data.(vars{i}).Raw.Date = floor(data.(vars{i}).Raw.Date);
end

for i = 1:length(data.(first_var).Raw.Date)
    
    isfound = 1;
    inc = 1;
    ind = [];
    ind(1) = NaN;
    for j = 2:length(vars)
        
        ss = find(data.(vars{j}).Raw.Date == data.(first_var).Raw.Date(1) & ...
            data.(vars{j}).Raw.Depth == data.(first_var).Raw.Depth(1));
        
        if ~isempty(ss)
            isfound = isfound + 1;
            ind(isfound) = ss(1);
            
        end
        
    end
    
    if isfound == length(vars)
        
        data.(first_var).Matched.Date(inc,1) = data.(first_var).Raw.Date(i);
        data.(first_var).Matched.Data(inc,1) = data.(first_var).Raw.Data(i);
        data.(first_var).Matched.Depth(inc,1) = data.(first_var).Raw.Depth(i);
        
        for j = 2:length(vars)
            
            data.(vars{j}).Matched.Date(inc,1) = data.(vars{j}).Raw.Date(ind(j));
            data.(vars{j}).Matched.Data(inc,1) = data.(vars{j}).Raw.Data(ind(j));
            data.(vars{j}).Matched.Depth(inc,1) = data.(vars{j}).Raw.Depth(ind(j));
            
        end
       inc = inc + 1; 
    end
    
end
















