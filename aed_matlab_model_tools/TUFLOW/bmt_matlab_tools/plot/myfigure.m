% /////// myfigure ///////
% produces figues of appropriate sizes for reporting and printing purposes
% sets up a figure ready to be brought into Microsoft Word or to be printed directly with no loss of clarity
% WYSIWYG: what you see (on screen) is what you get (in word or printed)
%
% orientation = 'Portrait' nf figures are of equal width and stacked one on top of the next.
% orientation =  'Landscape' nf figures are of equal heights and stacked side by side.
%
% inputs
%   nf = number of figures per page (integer)
%
% variable arguments as descripter / value pairs
%   (usual figure properties)
%   PaperOrientation / portrait (default), ladscape
%   PaperType / A3 A4 (default)
%
% outputs
%   f = handle to figure
%
% JN November 2011

function f = myfigure(nf,varargin)

% WBM template
head = 4.0; % (cm)
foot = 2.2;
ref = 1.6;

% defaults
papertype = 'a4';
paperorientation = 'portrait';
size = 1; % fills one page

% variable arguments
if mod(length(varargin),2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for i = 1 : 2 : length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch lower(varargtyp{i})
        case 'paperorientation'
            paperorientation = lower(varargval{i});
        case 'papertype'
            papertype = lower(varargval{i});
        otherwise
            error('unexpected variable argument type')
    end
end


% all the fuss in displaying what you want to print on the screen
set(0,'Units','centimeters')
pos_cm = get(0,'ScreenSize');
set(0,'Units','pixels')
pos_px = get(0,'ScreenSize');
pix_x = pos_px(3) / pos_cm(3);
pix_y = pos_px(4) / pos_cm(4);

f = figure;
set(f,'color',[1 1 1])
set(f,'InvertHardCopy','off')

switch papertype
    case 'a4'
        p_width = 21.0;
        p_height = 29.7;
        
        set(0,'defaultaxesfontsize',6);
        set(0,'defaulttextfontsize',6);
        set(0,'defaultaxeslinewidth',0.5);
        
    case 'a3'
        p_width = 29.7;
        p_height = 42.0;
        
        set(0,'defaultaxesfontsize',10);
        set(0,'defaulttextfontsize',10);
        set(0,'defaultaxeslinewidth',1);
    otherwise
        error('unexpected input for papertype')
end

switch paperorientation
    case 'portrait'
        x_frac = 0.817; % to match width of WBM template
%         y_frac = 1 / nf - 3 / p_height;
        y_frac = (1 - (head + foot + nf * ref) / p_height) / nf;
        
    case 'landscape'
        tmp = p_width;
        p_width = p_height;
        p_height = tmp;
%         
%         x_frac = 1 / nf - 1 / p_width;
%         y_frac = 0.80;
x_frac = 0.8148;
y_frac = (1 - (2.7 + foot + nf * ref) / p_height) / nf;

        
    otherwise
        error('unexpected input for paperorientation')
end

f_width = x_frac * p_width;
f_height = y_frac * p_height;

xp = (p_width - f_width) / 2;
yp = (p_height - f_height) / 2;

% set(f,'PaperType',papertype)
% set(f,'PaperOrientation',paperorientation)


set(f,'PaperUnits','centimeters')
switch paperorientation
    case 'landscape'
        set(f,'PaperSize',[p_width p_height])  % matlab cannot print landscapes!
end
set(f,'PaperPositionMode','manual')
set(f,'PaperPosition',[xp yp f_width f_height])
set(f,'Position',[1 1 f_width*pix_x f_height*pix_y])
