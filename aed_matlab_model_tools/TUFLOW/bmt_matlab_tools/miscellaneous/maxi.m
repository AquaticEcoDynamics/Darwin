% /////// maxi ///////
% Same as max but ignores NaN values.
% Calculates maximum across 1st dimension (down columns) unless dimension is specified.
%
% JN

function x = maxi(y,varargin)

if nargin > 1
    dim = varargin{1};
else
    dim = 1;
end

% turn NaN's to -Inf
i = isnan(y);
y(i) = -Inf;
x = max(y,[],dim);