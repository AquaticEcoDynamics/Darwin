% /////// cones ///////
% [faces, verts] = cones(x,y,z,x_orig,y_orig,z_orig,arargin)
%
% Outputs the faces and verticees used for creating cones from patch objects.
% Based on matlab's coneplot.m but tweaked to be used like WBM's arrow2
% function. fvsheet_vec_grid is called prior to cones.m to index into
% model results.
%
% inputs
%   x      = x vector component, length(x) = number of cones
%   y      = y vector component
%   z      = z vector conponent
%   x_orig = x coordinates of cones
%   y_orig = x coordinates of cones
%   z_orig = z coordinates of cones
%
% optional inputs
%   scale   = multiplier for cone size
%   daspect = the DataAspectRatio of the axes which the cones will be plotted into
%
% Jesper Nielsen, BMT WBM September 2014


function [faces, verts] = cones(x,y,z,x_orig,y_orig,z_orig,varargin)

% defaults
scale = 10;
daspect = [1 1 1];

% optional inputs
noi = length(varargin);
if mod(noi,2) ~= 0
    error('expecting optional inputs as property / value pairs')
end
for aa = 1:2:noi
    switch lower(varargin{aa})
        case 'scale'
            scale = varargin{aa+1};
        case 'daspect'
            daspect = varargin{aa+1};
            if length(daspect) < 3
                daspect(3) = 1;
            end
        otherwise
            error('unexpected variable argument type')
    end
end

% have values for the z component been provided
numcones = length(x);
if isempty(z)
    z = zeros(numcones,1,'single');
end
if isempty(z_orig)
    z_orig = zeros(numcones,1,'single');
elseif isscalar(z_orig)
    z_orig = repmat(z_orig,numcones,1);
end

% define the face-vertex indexing for the patches making up the cones
zscale = daspect(3) / daspect(2);
conesegments = 14;
conewidth = .333;

[faces, verts] = conegeom(conesegments);
flen = size(faces,1);
vlen = size(verts,1);
faces = repmat(faces, numcones,1);
verts = repmat(verts, numcones,1);
offset = floor((0:flen*numcones-1)/flen)';
faces = faces+repmat(vlen*offset,1,3);

for i = 1:numcones
    index = (i-1)*vlen+1:i*vlen;
    len = norm([x(i),y(i),z(i)]) * scale;
    verts(index,3) = verts(index,3) * len;
    verts(index,1:2) = verts(index,1:2) * len*conewidth;
    
    verts(index,:) = coneorient(verts(index,:),  [x(i),y(i),z(i)]);
    
    verts(index,1) = verts(index,1) + x_orig(i);
    verts(index,2) = verts(index,2) + y_orig(i);
    
    % -- maintain circularity of cones despite DataAspectRatio
    verts(index,3) = verts(index,3) * zscale;
    verts(index,3) = verts(index,3) + z_orig(i);
end

% subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f, v] = conegeom(coneRes) % cax removed from original

cr = coneRes;
[xx, yy, zz]=cylinder([.5 0], cr);
f = zeros(cr*2-2,3);
v = zeros(cr*3,3);
v(1     :cr  ,:) = [xx(2,1:end-1)' yy(2,1:end-1)' zz(2,1:end-1)'];
v(cr+1  :cr*2,:) = [xx(1,1:end-1)' yy(1,1:end-1)' zz(1,1:end-1)'];
v(cr*2+1:cr*3,:) = v(cr+1:cr*2,:);

f(1:cr,1) = (cr+2:2*cr+1)';
f(1:cr,2) = f(1:cr,1)-1;
f(1:cr,3) = (1:cr)';
f(cr,1) = cr+1;
f(cr+1:end,1) = 2*cr+1;
f(cr+1:end,2) = (2*cr+2:3*cr-1)';
f(cr+1:end,3) = f(cr+1:end,2)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=coneorient(v, orientation)
cor = [-orientation(2) orientation(1) 0];
if sum(abs(cor(1:2)))==0
    if orientation(3)<0
        vout=rotategeom(v, [1 0 0], 180);
    else
        vout=v;
    end
else
    a = 180/pi*asin(orientation(3)/norm(orientation));
    vout=rotategeom(v, cor, 90-a);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=rotategeom(v,azel,alpha)
u = azel(:)/norm(azel);
alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
    x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
    x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

x = v(:,1);
y = v(:,2);
z = v(:,3);

[m,n] = size(x);
newxyz = [x(:), y(:), z(:)];
newxyz = newxyz*rot;
newx = reshape(newxyz(:,1),m,n);
newy = reshape(newxyz(:,2),m,n);
newz = reshape(newxyz(:,3),m,n);

vout = [newx newy newz];