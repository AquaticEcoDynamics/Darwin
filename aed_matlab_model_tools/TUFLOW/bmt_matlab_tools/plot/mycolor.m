% /////// mycolor ///////
% sets contours just the way you want them
% no dark blues or dark reds
%
% mycolor(h,contours,varargin)
%
% inputs
% h = axis handle
% contours = [min max ncontours];
%
% optional input (input type / input)
% 'blanks' / nblanks = white contours included for lowest nblanks intervals (useful for background concentrations)
% 'type' / 'normal', 'magnitude', 'intensity','w2r','w2b' = determines colour scale, default: 'normal'
% 'shade' / 'red', 'green', 'blue'
% 'bar' / 'on' or 'off' = to include the colorbar or not, default: 'on'
% 'location' / South, North etc etc
% 'static' / true | {false}  = remove the LegendColorbarListeners which can really slow you down when looping through timesteps
% 'mini' / true | {false} = make a mini colorbar. To have it overlapping your axes set the location to eg. South and not SouthOutside
%
% hint: to modify your colorbar later ie. the font size or position
%       h_cbar = findobj(figure_handle,'tag','Colorbar');
%       set(h_cbar,'FontSize',5);
%       set(h_cbar,'Location','Southoutside')
%       set(h_cbar,'XTick',[contours(1):(contours(2)-contours(1))/contours(3):contours(2)]);
%
% JN May 2011

function  h_cbar = mycolor(ax,contours,varargin)

% checks
if mod(length(varargin),2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

if length(contours) ~= 3
    error('expecting [min,max,ncontours] for input')
end

% defaults
static = false;
blanks = 0;
type = 'normal';
bar = 'on';
location = 'EastOutside';
shade = 'blue';
mini = false;

% variable arguments
for i = 1 : 2 : length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch lower(varargtyp{i})
        case 'blanks'
            blanks = varargval{i};
        case 'type'
            type = varargval{i};
        case 'shade'
            shade = varargval{i};
        case 'bar'
            bar = varargval{i};
        case 'location'
            location = varargval{i};
        case 'static'
            static = varargval{i};
        case 'mini'
            mini = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

min = contours(1);
max = contours(2);
nc = contours(3);
if nc ~= round(nc)
    error('expecting an integer number of contours')
end

% generate rgb matrix
switch type
    case 'normal'
        dc = 3/(nc-1-blanks);
        
        r = -1:dc:2;
        r(r < 0) = 0;
        r(r > 1) = 1;
        r = r';
        
        b = r(end:-1:1);
        
        g = NaN(length(r),1);
        tmp = 0:dc:1;
        g(r == 0) = tmp;
        g(r == 1) = tmp(end:-1:1);
        g(isnan(g)) = 1;
        
        map = [r g b];
        
        if blanks > 0
            map = vertcat(ones(blanks,3),map);
        end
        
    case 'magnitude'
        if blanks > 0;
            error('blank intervals invalid for magnitude contouring')
        end
        dc = 4/(nc-1);
        
        r = -1:dc:3;
        r(r < 0) = 0;
        r(r > 1) = 1;
        r = r';
        
        b = r(end:-1:1);
        
        g = NaN(length(r),1);
        tmp = 0:dc:1;
        g(r == 0) = tmp;
        g(b == 0) = tmp(end:-1:1);
        g(isnan(g)) = 1;
        
        map = [r g b];
        if mod(nc,2) == 0
            map(nc/2:nc/2+1,:) = repmat([1 1 1],2,1);
        end
    case 'intensity'
        map = zeros(nc,3);
        c = [ones(floor(nc/2),1) ; linspace(1,0,ceil(nc/2))'];
        o = [linspace(1,0,floor(nc/2)+1)' ; zeros(ceil(nc/2)-1,1)];
        switch shade
            case 'red'
                map(:,1) = c;
                map(:,2) = o;
                map(:,3) = o;
            case 'green'
                map(:,1) = o;
                map(:,2) = c;
                map(:,3) = o;
            case 'blue'
                map(:,1) = o;
                map(:,2) = o;
                map(:,3) = c;
                % UPDATE WITH USING FADE
        end
    case 'w2r'
        map = white_to_red(nc);
    case 'w2b'
        map = white_to_brown(nc);
end

% set the colormap for the specified figure
na = length(ax);
h_cbar = zeros(na,1);
for aa = 1:na
    h = ax(aa);
    colormap(h,map)
    set(h,'CLim',[min max])
    switch bar
        case 'on'
            h_cbar(aa) = colorbar('peer',h);
            set(h_cbar(aa),'Location',location);
            switch lower(location)
                case {'north','south','northoutside','southoutside'}
                    set(h_cbar(aa),'XTick',[min:(max-min)/nc:max])
                otherwise
                    set(h_cbar(aa),'YTick',[min:(max-min)/nc:max])
            end
            if mini
                pos = get(h_cbar(aa),'position');
                switch lower(location)
                    case {'north','south','northoutside','southoutside'}
                        set(h_cbar(aa),'XTickMode','auto')
                        pos = [pos(1) pos(2)+pos(4)/6 pos(3)/3 pos(4)/3];
                    otherwise
                        set(h_cbar(aa),'YTickMode','auto')
                        pos = [pos(1)+pos(3)/6 pos(2) pos(3)/3 pos(4)/3];
                end
                set(h_cbar(aa),'Position',pos)
            end
            % Static legend - avoid updating when within a loop
            if static
                set(h,'LegendColorbarListeners',[]);
                setappdata(h,'LegendColorbarManualSpace',1);
                setappdata(h,'LegendColorbarReclaimSpace',1);
            end
        otherwise
            h_cbar = [];
    end
end