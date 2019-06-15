% /////// atan4 ///////
% returns the cartesion angle (anticlockwise from x)
% based on the built-in atan2

function value = atan4(y,x)

value = atan2(y,x);
value(value<0) = value(value<0) + 2*pi;