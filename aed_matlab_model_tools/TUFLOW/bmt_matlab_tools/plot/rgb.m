% /////// rgb ///////
% creates a mx3 matrix used for colormaps and other plotting
% first color always pure blue [0 0 1] and last color always pure red [1 0 0]
% to set colormap, colormap(h,map)
%
% inputs
%   m = number of colors
%
% outputs
%   map = m x 3 matrix of RGB values
%
% Jesper Nielsen, BMT WBM, January 2012

function map = rgb(m)

if m == 1
    map = [0 0 1];
    return
end

dc = 3/(m-1);

r = -1:dc:2;
r(r < 0) = 0;
r(r > 1) = 1;
r = r';

b = r(end:-1:1);

g = NaN(length(r),1);
tmp = 0:dc:1;
g(r == 0) = tmp;
g(r == 1) = tmp(end:-1:1);
g(isnan(g)) = 1;

map = [r g b];