% /////// myaxes ///////
% function used to split up a figure equally into various axes as specified by
% the number of rows and columns. These axes can then be merged with the
% variable argument 'merge'
%
% inputs = f - figure handle
%          nr - number of axes going down figure
%          nc - number of axes going across figure
% varargin = left_buff
%          = right_buff
%          = bot_buff
%          = top_buff
%          = side_gap
%          = top_gap
%          = merge - vector of axes to merge
%
% outputs = ax : [# axes]
%
% JN September 2011

function ax = myaxes(f,nr,nc,varargin)

% defaults
left_buff = 0.025;
right_buff = left_buff;
bot_buff = 0.05;
top_buff = bot_buff;
side_gap = left_buff;
top_gap = bot_buff;
asymetrical = false;

% variable arguments
if mod(length(varargin),2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for i = 1 : 2 : length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch lower(varargtyp{i})
        case 'left_buff'
            left_buff = varargval{i};
        case 'right_buff'
            right_buff = varargval{i};
        case 'bot_buff'
            bot_buff = varargval{i};
        case 'top_buff'
            top_buff = varargval{i};
        case 'side_gap'
            side_gap = varargval{i};
        case 'top_gap'
            top_gap = varargval{i};
        case 'merge'
            asymetrical = true;
            merge = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

% position matrix [left bottom width height]
na = nr * nc;
ax = zeros(na,1);
position = zeros(na,4);
h = (1 - (nr-1)*top_gap - bot_buff - top_buff) / nr;
w = (1-(nc-1)*side_gap - left_buff - right_buff) / nc;

% left
i = 1;
x = left_buff;
for aa = 1:nc
    j = i + nr - 1;
    position(i:j,1) = x;
    x = x + w + side_gap;
    i = j + 1;
end

% bottom
tmp = zeros(nr,1);
tmp(1) = 1 - top_buff - h;
for aa = 2:nr
    tmp(aa) = tmp(aa-1) - top_gap - h;
end
position(:,2) = repmat(tmp,nc,1);

% width
position(:,3) = w;

% height
position(:,4) = h;

% merge axes if required
if asymetrical
    pos_old = position(merge,:);
    pos_new(1) = min(pos_old(:,1));
    pos_new(2) = min(pos_old(:,2));
    if min(pos_old(:,1)) == max(pos_old(:,1))
        pos_new(3) = pos_old(1,3);
    else
        ng = length(unique(pos_old(:,1))) - 1;
        pos_new(3) = ng * side_gap + (ng + 1) * w;
    end
    if min(pos_old(:,2)) == max(pos_old(:,2))
        pos_new(4) = pos_old(1,4);
    else
        ng = length(unique(pos_old(:,2))) - 1;
        pos_new(4) = ng * top_gap + (ng + 1) * h;
    end
    
    % remove merged axes and place merged axes at top of que
    position(merge,:) = [];
    position = vertcat(pos_new,position);
    
    % recreate the axes'
    na = size(position,1);
    ax = zeros(na,1);
end

% set up axis
for aa = 1:na
    ax(aa) = axes('parent',f);
    set(ax(aa),'position',position(aa,:));
end

% the shape of the handle array is equivalent to the axes display
% ax = reshape(ax,nr,nc); THIS IS NOT DONE AS YOU MAY BE MERGING