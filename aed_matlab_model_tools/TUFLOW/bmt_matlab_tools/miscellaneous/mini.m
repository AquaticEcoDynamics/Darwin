% /////// mini ///////
% Same as min but ignores NaN values.
% Calculates mimimum across 1st dimension (down columns) unless dimension is specified.
%
% JN

function x = mini(y,varargin)

if nargin > 1
    dim = varargin{1};
else
    dim = 1;
end

% turn NaN's to Inf
i = isnan(y);
y(i) = Inf;
x = min(y,[],dim);