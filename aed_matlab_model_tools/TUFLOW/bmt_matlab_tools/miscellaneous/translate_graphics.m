% /////// translate_graphics ///////
% Enables the user to interactively move a graphics / group of graphics
% objects around their parent axes;
%
% This function is designed to be used as a callback, the below example
% creates a line which can be moved around an axes.
%   ax = axes;
%   hgt = hgtransform('parent',ax,'HittestArea','off','hittest','off');
%   hgg = hggroup('parent',hgt,'hittest','on','buttondownfcn',@translate_graphics);
%   line('parent',hgg,'XData',[0 1],'YData',[0 1],'hittest','off');
%
% function translate_graphics
%
% Jesper Nielsen, February 2013


function translate_graphics(h,~,trans)

% checks
parent = get(get(h,'Parent'),'Type');
if ~strcmpi(parent,'hgtransform')
    error('handle must correspond to a hgtransform object')
end

trans = lower(trans);
switch trans
    case {'x','y','xy'}
    otherwise
        error('input trans must be one of x, y or xy strings')
end

% body
tmp = get(ancestor(h,'axes'),'currentpoint');
curser_old = tmp(1,:);
trans_old = get(h,'Userdata');

if isempty(trans_old)
    trans_old = [0 0 0];
end
set(ancestor(h,'figure'),'windowbuttonmotionfcn',{@dragline,h,curser_old,trans_old,trans})

% callbacks
function dragline(~,~,h,curser_old,trans_old,trans)
tmp = get(ancestor(h,'axes'),'currentpoint');
curser_new = tmp(1,:);
switch trans
    case 'x'
        curser_new(1,2) = curser_old(1,2);
    case 'y'
        curser_new(1,1) = curser_old(1,1);
    case {'xy'}
end
trans = curser_new - curser_old + trans_old;
M = makehgtform('translate',trans);

set(ancestor(h,'hgtransform'),'matrix',M)
set(ancestor(h,'figure'),'windowbuttonupfcn',{@stopdragging,h,trans})

function stopdragging(fig,~,h,trans)
set(h,'UserData',trans)
set(fig,'windowbuttonmotionfcn','')
set(fig,'windowbuttonupfcn','')