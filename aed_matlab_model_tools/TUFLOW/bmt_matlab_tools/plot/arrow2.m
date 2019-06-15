% /////// arrow2.m ///////
% [vx,vy] = arrow2(x,y,x_orig,y_orig,varargin)
%
% Outputs the verticees used for creating arrows from patch objects
% The tails of the arrows sit at (x_orig,y_orig) unless variable argument
% 'shift' is true then arrow centres around (x_orig,y_orig)
%
% inputs
%   x      = x vector component
%   y      = y vector component
%   x_orig = x coordinates of arrow origins
%   y_orig = x coordinates of arrow origins
%
% optional inputs
%   'scale'      / scale               multiplier for vector size
%   'shape_tail' / [width loj]         when loj = true, width represents a fraction of the arrow's total length
%   'shape_head' / [width length loj]  when loj = true, width and length represent fractions of the arrow's total length
%	'shift'      / shift               true | {false}
%
% outputs
%   vx = x coordinates of verticess defining patches [8, # arrows]
%   vy = y coordinates of verticess defining patches [8, # arrows]
%
% JN November 2011, May 2014

function [vx,vy] = arrow2(x,y,ox,oy,varargin)

% defaults
shape_tail = [0.05 1];
shape_head = [0.06 0.15 1];
shift = false;
scale = 1000;

% optional inputs
noi = length(varargin);
if mod(noi,2) ~= 0
    error('expecting optional inputs as property / value pairs')
end
for aa = 1:2:noi
    switch lower(varargin{aa})
        case 'scale'
            scale = varargin{aa+1};
        case 'shape_tail'
            shape_tail = varargin{aa+1};
        case 'shape_head'
            shape_head = varargin{aa+1};
        case 'shift'
            shift = varargin{aa+1};
        otherwise
            error('unexpected variable argument type')
    end
end

% yada yada
phi = atan4(y,x);
na = length(phi);
pts = zeros(na*8,2);

% convert to axes units
mag = hypot(x,y) * scale;
if ~shape_head(3)
    shape_head(1:2) = shape_head(1:2) * scale;
end
if ~shape_tail(2)
    shape_tail(1) = shape_tail(1) * scale;
end

% arrow shape
a = shape_tail(1) / 2; % width tail
b = shape_head(1) / 2; % width head
c = shape_head(2) / 2; % length head

% start at end point on arrow head and work around clockwise
% initially arrow points in +ve x
pts(1:8:end,1) = mag;
if shape_head(3)
    pts(2:8:end,1) = mag-c*mag;
    pts(3:8:end,1) = mag-c*mag;
else
    pts(2:8:end,1) = mag-c;
    pts(3:8:end,1) = mag-c;
end
if shape_head(3)
    pts(6:8:end,1) = mag-c*mag;
    pts(7:8:end,1) = mag-c*mag;
else
    pts(6:8:end,1) = mag-c;
    pts(7:8:end,1) = mag-c;
end
pts(8:8:end,1) = mag;

if shape_head(3)
    pts(2:8:end,2) = -b*mag;
else
    pts(2:8:end,2) = -b;
end
if shape_tail(2)
    pts(3:8:end,2) = -a*mag;
    pts(4:8:end,2) = -a*mag;
    pts(5:8:end,2) = a*mag;
    pts(6:8:end,2) = a*mag;
else
    pts(3:8:end,2) = -a;
    pts(4:8:end,2) = -a;
    pts(5:8:end,2) = a;
    pts(6:8:end,2) = a;
end

if shape_head(3)
    pts(7:8:end,2) = b*mag;
else
    pts(7:8:end,2) = b;
end

% a useful index
i = reshape(repmat(1:na,8,1),[],1);

% at the moment arrow tails sit at arrows origin
if shift
    pts(:,1) = pts(:,1) - mag(i)/2;
end

% rotate arrow around (0,0)
phi = phi(i);

vert(:,1) = pts(:,1) .* cos(phi) - pts(:,2) .* sin(phi);
vert(:,2) = pts(:,1) .* sin(phi) + pts(:,2) .* cos(phi);

% shape matrix ready for XData / YData inputs for patch function
vx = reshape(vert(:,1),8,[]);
vy = reshape(vert(:,2),8,[]);

% shift arrows to centre around arrow origins
vx = bsxfun(@plus,vx,ox');
vy = bsxfun(@plus,vy,oy');

