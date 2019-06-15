% /////// getscale ///////
%   inputs
%       ax = axes handel
%   outputs
%       fx * npix = units along x axis
%       fy * npix = units along y axis
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function [fx,fy] = getscale(ax)
x_lim = get(ax,'XLim');
y_lim = get(ax,'YLim');
d_x = diff(x_lim);
d_y = diff(y_lim);
old_units = get(ax,'units');
set(ax,'Units','pixels')
pos = get(ax,'position');
dxpix = pos(3);
dypix = pos(4);
set(ax,'Units',old_units)
fx = d_x/dxpix;
fy = d_y/dypix;