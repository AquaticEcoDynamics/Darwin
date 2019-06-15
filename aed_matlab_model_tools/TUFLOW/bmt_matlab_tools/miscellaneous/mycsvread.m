% dat = mycsvread(csvfil,colnames)
% Ian Teakle 04/12/2013
function dat = mycsvread(csvfil,colnames)

% Open file
fid = fopen(csvfil,'rt');
if fid==0
    error('Unable to open csvfil')
end
% Read header line
line = fgetl(fid);
remain = line;
i = 0;
while ~isempty(remain)
    [token,remain] = strtok(remain,',');
    i = i + 1;
    header{i} = token;
end
header = lower(header);
% Find colnames in header line
Ncol = length(colnames);
col = zeros(1,Ncol);
for i = 1 : Ncol
    col(i) = find(strncmp(colnames{i},header,1),1,'first');
end
format = '';
for i = 1 : length(header)
    if (any(col==i))
        format = [format,'%f'];
    else
        format = [format,'%*s'];
    end
end
% Read data lines
i = 0;
while ~feof(fid)
    i = i + 1;
    line = fgetl(fid);
    tmp{i,:} = textscan(line,format,'delimiter',',');
end
% Close file
fclose(fid);
% Sort dat
[~,ind] = sort(col);
tmp = cat(1,tmp{:});
tmp = cell2mat(tmp);
dat = tmp(:,ind);