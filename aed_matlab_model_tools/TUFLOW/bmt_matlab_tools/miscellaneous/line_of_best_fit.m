% /////// line_of_best_fit ///////
% Generate the line of best fit for a line object (AT THE MOMENT IT IS INTECEPT OF 0 ONLY).
% The polynomial (line & equation) together with coefficient of determination (R^2) are displayed
% on the axes.
%
% inputs
%   h = handle to line object for which to generate the line of best fit.
%   n = degree of polynomial (1 for linear)
%
% optional inputs
%   intercept = set the intercept to this value (NOT YET SUPPORTED)
%
% Jesper Nielsen, February 2014

function line_of_best_fit(h,n,varargin)

% checks
type = get(h,'Type');
switch lower(type)
    case 'line'
    otherwise
        error('1st input must be handle to a line object')
end

% parent axes
ax = get(h,'Parent');

% get the values
x = get(h,'XData');
y = get(h,'YData');

% polynomial curve fitting
p = polyfit(x,y,n);

% fitted values
y_fit = polyval(p,x);

% plot the line
% -- select a color preferably there are markers
marker = get(h,'Marker');
switch lower(marker)
    case 'none'
        col = get(h,'Color');
    otherwise
        col = get(h,'MarkerFaceColor');
end

line(x,y_fit,'Color',col,'parent',ax)

% plot the equation (NOT YET SUPPORTED)

% plot the coefficient of determination
sq1 = sum((y - mean(y)).^2); % total sum of squares
sq2 = sum((y - y_fit).^2); % residual sun of sqaures
r2 = 1 - sq2/sq1;
text(max(x),max(y_fit),['R^2 = ' num2str(r2,'%.2f')],'Color',col,'FontSize',10,'FontWeight','Bold')
