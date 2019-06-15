% /////// mysquare ///////
% x = x coordinates making up square
% y = y coordinates making up square
% Jesper Nielsen
function [x y] = mysquare(xp,yp,dx,dy,phi)

x = [xp, xp+dx, xp+dx, xp];
y = [yp yp yp+dy yp+dy];

x = x - xp;
y = y - yp;

trans = [cos(phi) -sin(phi); sin(phi) cos(phi)];

if size(x,2) > 1
    x = x';
end

if size(y,2) > 1
    y = y';
end


vec = [x y];
vec = vec * trans;

x = vec(:,1);
y = vec(:,2);

% x = x .* cos(phi) - y .* sin(phi);
% y = x .* sin(phi) + y .* cos(phi);

x = x + xp;
y = y + yp;
end