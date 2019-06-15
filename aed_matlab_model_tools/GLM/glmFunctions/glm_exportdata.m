
function [data,XX,YY,ZZ,mTime,surf,bot] = glm_exportdata(ncfile,varname,surface,bottom)

% Just an array - ignore for now
alldepths = [0:1:2500];


% Import in the data
data = readGLMnetcdf(ncfile,varname);

%Number of dates simulated output
numDates = length(data.time);

%Get time and depths
mTime = data.time;
mDepth = data.z;
mNS = data.NS;

% Routine to find the max depth and build the array for the pcolor plots
for i = 1:length(mTime) 
    mdepth(i) = mDepth(i,mNS(i));
end

max_depth = max(mdepth);

[~,ind] = min(abs(alldepths-max_depth));

if alldepths(ind) < max_depth
    ind = ind + 1;
end

nd = [0:0.1:alldepths(ind)];

[XX,YY] = meshgrid(mTime,nd);

% Now get the data for the pcolor plot

for i = 1:length(mTime)    
    z = mDepth(i,1:mNS(i))';
    x = data.(varname)(i,1:mNS(i))';
    ZZ(:,i) = interp1(z,x,nd);
    
    % Data for line plot.
    sInd = find(z >= surface(1) & z <= surface(2));
    surf(i) = mean(x(sInd));
    bInd = find(z >= bottom(1) & z <= bottom(2));
    bot(i) = mean(x(bInd));
    
end





end
