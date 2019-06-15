% white_to_red
% create the map matrix for use in colormap(map) which starts in pure white
% ending in pure red.

function map = white_to_red(nc)

m = floor(nc/4) + 1;
mm = nc - (3 * m - 2) + 1;

% white to cyan
r1 = linspace(1,0,mm);
g1 = ones(1,mm);
b1 = g1;

% cyan to green
r2 = zeros(1,m);
g2 = ones(1,m);
b2 = linspace(1,0,m);

% green to yellow
r3 = linspace(0,1,m);
g3 = g2;
b3 = r2;

% yellow to red
r4 = g3;
g4 = b2;
b4 = r2;

r = [r1 r2(2:end) r3(2:end) r4(2:end)]';
g = [g1 g2(2:end) g3(2:end) g4(2:end)]';
b = [b1 b2(2:end) b3(2:end) b4(2:end)]';

map = [r g b];


