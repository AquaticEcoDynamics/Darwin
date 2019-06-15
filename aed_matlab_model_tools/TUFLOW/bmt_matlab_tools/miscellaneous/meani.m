% /////// meani ///////
% Same as mean but ignores NaN values.
% Averages non NaN numbers across 1st dimension (down columns) unless dimension is specified
%
% JN

function x = meani(y,varargin)

if nargin > 1
    dim = varargin{1};
else
    dim = 1;
end

% turn NaN's to zero
i = isnan(y);
ng = sum(~i,dim);  % number of good values
y(i) = 0;

% sum across dimension dim
tot = sum(y,dim);

% determine the average
x = tot ./ ng;