function lowerlakes = add_offset(lowerlakes)

sites = fieldnames(lowerlakes);

for i = 1:length(sites)
    vars = fieldnames(lowerlakes.(sites{i}));
    for j = 1:length(vars)
        for k = 1:length(lowerlakes.(sites{i}).(vars{j}).Date)
            lowerlakes.(sites{i}).(vars{j}).Date(k) = lowerlakes.(sites{i}).(vars{j}).Date(k) + (rand/1000);
        end
        [lowerlakes.(sites{i}).(vars{j}).Date,ind] = sort(lowerlakes.(sites{i}).(vars{j}).Date);
        lowerlakes.(sites{i}).(vars{j}).Data = lowerlakes.(sites{i}).(vars{j}).Data(ind);
    end
end