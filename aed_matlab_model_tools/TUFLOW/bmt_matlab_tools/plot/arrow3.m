% /////// arrow3.m ///////
% [vx vy vz] = arrow(x,y,z,x_orig,y_orig,z_orig,varargin)
%
% outputs the verticees used for patching arrows
% arrows' tails sit at (x_orig,y_orig,z_orig) unless
% 'shift' is true then arrow centres around (x_orig,y_orig)
%
% inputs
%   x = x component
%   y = y component
%   z = z component
%   x_orig = vector of length(x) - x coords of arrows / vectors
%   y_orig = vector of length(y) - y coords of arrows / vectors
%   z_orig = vector of length(z) - z coords of arrows / vectors
% varargin
%   'scale' / scale = multiplier for vector size
%   'shape' / shape = [a b c], fraction of total arrow length (stem + head)
%       a = width of arrow stem: default = 0.1
%       b = width of arrow head: default = 0.25
%       c = length of arrow head: default = 0.4
%	'shift' / shift (logical): default = false
%   'view' / 'side' or 'top' (default), determins if arrows visible from side or top
%   'dasp' ratio of zlim / xlim on axes: default = 1;
%
% outputs
%   vx = [8,#arrows] x-coords making up verticees
%   vy = [8,#arrows] y-coords making up verticees
%   vz = [8,#arrows] z-coords making up verticees
%
% JN November 2011

function [vx,vy,vz] = arrow3(x,y,z,ox,oy,oz,varargin)

if mod(length(varargin),2)~=0, error('varargin must be in pairs'), end

% defaults
shape = [0.1 0.25 0.4];
shift = false;
scale = 1;
view = 'top';
dasp = 1;

% variable arguments
for i =1 : 2: length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch varargtyp{i}
        case 'scale'
            scale = varargval{i};
        case 'shape'
            shape = varargval{i};
        case 'shift'
            shift = varargval{i};
        case 'view'
            view = varargval{i};
        case 'dasp';
            dasp = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

% arrow shape
a = shape(1);
b = shape(2);
c = shape(3);

% check dimensions (important for all the reshaping later)
if size(x,2) == 1;
    x = x';
end

if size(y,2) == 1;
    y = y';
end

if size(z,2) == 1;
    z = z';
end

if size(ox,2) == 1;
    ox = ox';
end

if size(oy,2) == 1;
    oy = oy';
end

if size(oz,2) == 1;
    oz = oz';
end

% yada yada
mag = sqrt(x.^2+y.^2+z.^2) * scale;
phi = atan4(y,x);
na = length(phi);
pts = zeros(na*8,3);

% start at end point on arrow head and work around clockwise
% initially arrow points in +ve x

pts(1:8:end,1) = mag;
pts(2:8:end,1) = mag-c*mag;
pts(3:8:end,1) = mag-c*mag;
% pts(4:8:end,1) = 0;
% pts(5:8:end,1) = 0;
pts(6:8:end,1) = mag-c*mag;
pts(7:8:end,1) = mag-c*mag;
pts(8:8:end,1) = mag;

switch lower(view)
    case 'top'
        i = 2;
    case 'side'
        i = 3;
end
% pts(1:8:end,i) = 0;
pts(2:8:end,i) = -b*mag;
pts(3:8:end,i) = -a*mag;
pts(4:8:end,i) = -a*mag;
pts(5:8:end,i) = a*mag;
pts(6:8:end,i) = a*mag;
pts(7:8:end,i) = b*mag;
% pts(8:8:end,2) = 0;


% pull arrows back to centre around 'centre' of arrow
if shift
    pts(:,1) = pts(:,1) - reshape(repmat(mag/2,8,1),[],1);
end

% rotate arrows
pts_rot = zeros(na*8,3);
i = 1;
for aa = 1:na
    j = i + 7;
    tmp = pts(i:j,:);
    pts_rot(i:j,:) = rotatePoints([x(aa) y(aa) z(aa)], tmp);
    i = i + 8;
end

% ready for export
vx = reshape(pts_rot(:,1),8,[]);
vy = reshape(pts_rot(:,2),8,[]);
vz = reshape(pts_rot(:,3),8,[]);

% coorect arrow heads for DataAspectRatio
if dasp ~= 1
    vz = vz * dasp;
end

% translate arrows to their origins
vx = vx + repmat(ox,8,1);
vy = vy + repmat(oy,8,1);
vz = vz + repmat(oz,8,1);

