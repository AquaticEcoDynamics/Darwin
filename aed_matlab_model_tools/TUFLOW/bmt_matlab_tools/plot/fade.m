% /////// fade ///////
% Produces an mx3 matrix or rgb values to be used in colormaps and other plotting.
% First color is always black, 2nd always white
%
% inputs
%   col = [r g b]; color you wish to fade
%   nc = number of increments to fade your color through
%
% outputs
%   map = m x 3 matrix of RGB values
%
% Jesper Nielsen, BMT WBM, July 2012

function map = fade(col,nc)

% checks
if size(col) ~= [1 3];
    error('expecting [r g b] of size [1 3] for input col')
end

if max(col) > 1 | min(col) < 0
    error('expecting [r g b] values in range [0 1]')
end

if ~isscalar(nc)
    error('expecting scalar input for input m')
end

if round(nc) ~= nc
    error('expecting integer value for input m')
end

map = zeros(nc,3);
for aa = 1:3
    nr1 = floor(nc/2) + 1;
    nr2 = nc - nr1 + 1;
    tmp1 = linspace(1,col(aa),nr1);
    tmp2 = linspace(col(aa),0,nr2);
    map(:,aa) = [tmp1 tmp2(2:end)]';
end

