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
inc = 1;
for i = 1:length(data.(first_var).Raw.Date)
    
    isfound = 1;
    
    ind = [];
    ind(1) = NaN;
    for j = 2:length(vars)
        
        ss = find(data.(vars{j}).Raw.Date == data.(first_var).Raw.Date(i) & ...
            data.(vars{j}).Raw.Depth == data.(first_var).Raw.Depth(i));
        
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