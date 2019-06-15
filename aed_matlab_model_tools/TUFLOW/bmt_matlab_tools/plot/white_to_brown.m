% white_to_brown
% produces a matrix to be used by colormap. Starts with white and ends with
% brown.
% Toby Devlin, 2014

function map = white_to_brown(cont,varargin)

if cont < 6
    error('for white to brown shading the number of contours must be >= 6')
end

map = 255*ones(3,cont);

if nargin>1
    wi = min(varargin{1},round(cont./4));
    wi = max(wi,1);
else
    wi = round(cont./10);
end
bi = round(cont./4)+round(cont./20);
gi = round(cont./2);
yi = round(cont*3./4);
bri = cont;

idxs = [wi,bi,gi,yi,bri];
clrsw = [255;255;255];
clrsb = [0;255;255];
clrsg = [0;255;0];
clrsy = [255;255;0];
clrsbr = [175;165;130];
clr = [clrsw,clrsb,clrsg,clrsy,clrsbr];
nrng = wi:cont;
for i=1:3
    nmp(i,:) = interp1(idxs,clr(i,:),nrng);
end

map(:,wi:cont) = nmp;
map= map'./255;
map(map>1) = 1;
map(map<0) = 0;
end