% /////// myaxes_properties ///////
% sets all your axes up into the default format
% original axis set up using myaxes
% call this function after the data has been plotted to the axes
% object names, to appear in legend, need to be preset using 'DisplayName'
%
% inputs ax = vector of all axis handles
% variables = names of all variables (number of rows of subplots - see myaxes)
% points_names = names of all points_names where data is extracted (number of columns of subplots - see myaxis)


function ax = myaxes_properties(ax,variables,points_names)

na = length(ax);
nr = length(variables);
nc = length(points_names);

axis(ax(:),'tight')

% use linkprop to link the Ylimits between sites, matlab will keep the ticks consistent automatically
for aa = 1:nr
    hlink(aa) = linkprop(ax(aa:nr:na),{'YLim'});
    setappdata(ax(aa),'graphics_linkprop',hlink(aa));
    set(ax(aa),'YTickMode','auto')
end

% y limits & ticks
for aa = 1:nr
    v_name = variables{aa};
    switch lower(v_name);
        case {'v_dir','w10_dir','wvdir'}
            set(ax(aa:nr:na),'YLim',[0 360])
            set(ax(aa:nr:na),'YTick',[0:45:360])
            
        % -- make sure data is displayed on all plots
        otherwise
            ylim = [inf -inf];
            for bb = aa:nr:na;
                kids = get(ax(bb),'Children');
                nk = length(kids);
                for cc = 1:nk
                    type = get(kids(cc),'Type');
                    switch lower(type)
                        case 'line'
                            y_tmp = get(kids(cc),'YData');
                            if min(y_tmp) < ylim(1)
                                ylim(1) = min(y_tmp);
                            end
                            if max(y_tmp) > ylim(2)
                                ylim(2) = max(y_tmp);
                            end
                        otherwise
                            continue
                    end
                end
            end
            set(ax(aa),'YLim',ylim)
            
            
            %         case {'h','current','q'}
            %             tmp1 = get(ax(aa:nr:na),'YLim');
            %             if ~iscell(tmp1)
            %                 tmp2 = tmp1;
            %             else
            %                 tmp2 = cell2mat(tmp1);
            %             end
            %             ylim = (max(max([abs(tmp2(:,1)) abs(tmp2(:,2))])));
            %             set(ax(aa:nr:na),'YLim',[-ylim ylim])
            %         case{'v_mag','w10_mag','wvht','tss','sed_1','sed_2','sed_3','sed_4','sed_5','sed_6'}
            %             tmp1 = get(ax(aa:nr:na),'YLim');
            %             if ~iscell(tmp1)
            %                 tmp2 = tmp1;
            %             else
            %                 tmp2 = cell2mat(tmp1);
            %             end
            %             ylim = [0 max(tmp2(:,2))];
            %             set(ax(aa:nr:na),'YLim',ylim)
            %         otherwise
            %             tmp1 = get(ax(aa:nr:na),'YLim');
            %             if ~iscell(tmp1)
            %                 tmp2 = tmp1;
            %             else
            %                 tmp2 = cell2mat(tmp1);
            %             end
            %             ylim(1) = min(tmp2(:,1));
            %             ylim(2) = max(tmp2(:,2));
            %             set(ax(aa:nr:na),'YLim',ylim)
    end
end

% if axes belong to same figure leave out the ylabels across sites
mum = get(ax, 'Parent');
if iscell(mum)
    mum = unique([mum{:}]);
end

if length(mum) == 1
    set(ax(nr+1:na),'YTickLabel','');
end

% % keep XTicklabels only for bottom row
% for aa = 1:nr-1
%     set(ax(aa:nr:na),'XTickLabel','')
% end

% x limits and ticks
tmp1 = get(ax(:),'XLim');
if ~iscell(tmp1)
    tmp2 = tmp1;
else
    tmp2 = cell2mat(tmp1);
end

% do not consider empty plots (those where no data exits)
i = false(na,1);
for aa = 1:na
    if isempty(get(ax(aa),'Children'))
        i(aa) = true;
    end
end

tmp2(i,:) = [];

xlim(1) = floor((min(tmp2(:,1))));
xlim(2) = ceil((max(tmp2(:,2))));
set(ax(:),'XLim',xlim)

% for aa = 1:na
%     myticks(ax(aa),'x')
% end

% for aa = nr:nr:na
%     datetick(ax(aa),'x','keepticks','keeplimits')
% end

% labels
for aa = 1:nr
    v_name = strrep(variables{aa},'_','');
    switch lower(variables{aa})
        case {'v','v_mag','w10_mag','current','v_x','v_y'}
            units = '[m/s]';
        case {'q'}
            units = '[m^3/s]';
        case {'v_dir','w10_dir','wvdir'}
            units = '[degrees (nautical convention)]';
        case {'h','wvht'}
            units = '[m]';
        case {'wvper'}
            units = '[s]';
        case {'tss'}
            units = '[mg/L]';
        case {'turb'}
            units = '[NTU]';
        case {'temp','air_temp'}
            units = '[degrees celsius]';
        case {'tauc','tauw','taucw','taub','wvstr_x','wvstr_y'}
            units = '[Pa]';
        case {'sal'}
            units = '[PSU]';
        case {'precip'}
            units = '[m/day]';
        case {'mslp'}
            units = '[hPa]';
        case {'rel_hum'}
            units = '[%]';
        case {'sw_rad','lw_rad'}
            units = 'W/m^2';
        otherwise
            if ~isempty(strfind(lower(variables{aa}),'bed_mass'))
                units = '[Kg/m^2]';
            elseif ~isempty(strfind(lower(variables{aa}),'pickup'))
                units = '[g/s/m^2]';
            elseif ~isempty(strfind(lower(variables{aa}),'sed'))
                units ='[mg/L]';
            elseif ~isempty(strfind(lower(variables{aa}),'trace'))
                units = '[units/m^3]';
            else
                %                 error(['unrecognised variable ' variables{aa}])
                units = '[~]';
            end
    end
    if length(mum) == 1
        ylabel(ax(aa),[v_name char(32) units])
    else
        k = 0;
        for bb = 1:length(mum)
            kk = aa * k + nr;
            ylabel(ax(kk),[v_name char(32) units])
            k = k+1;
        end
    end
end

for aa = nr:nr:na
    xlabel(ax(aa),'DATE')
end

% titles
k = 1;
for aa = 1:nc
    p_name = strrep(points_names{aa},'_',' ');
    for bb = 1:nr
        v_name = strrep(variables{bb},'_','');
        title(ax(k),[v_name ' at ' p_name])
        k = k+1;
    end
end

% grid
set(ax(:),'XGrid','on')
set(ax(:),'YGrid','on')

% legend
kids = get(ax,'Children');  % handles to the objects on every axis
if ~iscell(kids)
    kids = {kids};
end

i = 1:nr:na;
for aa = 1:na
    if ismember(aa,i)
        legend(ax(aa),'show')
        c_top = get(kids{aa},'color');
    else
        c_tmp = get(kids{aa},'color');
        if ~isequal(c_top,c_tmp)
            legend(ax(aa),'show')
        end
    end
end


% callbacks maintian the XLimits
h_zoom = zoom(mum);
h_pan = pan(mum);
set(h_zoom,'ActionPostCallback',{@updateX,ax(:),ax(nr:nr:na)});
set(h_pan,'ActionPostCallback',{@updateX,ax(:),ax(nr:nr:na)});

% let the callbacks do the work before any panning or zooming
zoom(mum,1);

% callbacks
function updateX(obj,ev,ax,ax_labels)
% updateX creates Xticks and Xlabels like dynamicDateTicks but applys the
% labels only to the specified axes (the bottom row)

% On which axes has the zoom/pan occurred
ax1 = ev.Axes;

% Re-apply date ticks, but keep limits
datetick(ax1, 'x', 'keeplimits');

% Get the current axes ticks & labels
ticks  = get(ax1, 'XTick');
labels = get(ax1, 'XTickLabel');

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
if all(ticks(1) < get(ax1,'xlim'))
    ticks(1) = [];
    labels(1,:) = [];
end

[yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information

if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
    
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
    
    % Change mm/dd to dd/mm if necessary
    %     labels = datestr(ticks, axesInfo.mdformat);
    labels = datestr(ticks,'dd-mmm');
    
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif any(labels(1,:) == ':') % Tick format is HH:MM
    
    % Add month/day/year information to the first tick and month/day to other ticks where the day changes
    ind = find(diff(da))+1;
    %     newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '/yy-']); % Add month/day/year to first tick
    newlabels{1}   = datestr(ticks(1), ['dd-mmm' '/yy-']); % Add month/day/year to first tick
    %     newlabels(ind) = cellstr(datestr(ticks(ind), [axesInfo.mdformat '-'])); % Add month/day to ticks where day changes
    newlabels(ind) = cellstr(datestr(ticks(ind), ['dd-mmm' '-'])); % Add month/day to ticks where day changes
    labels = strcat(newlabels, labels);
    
end

xlim = get(ax1,'XLim');
set(ax,'XLim',xlim,'XTick',ticks,'XTicklabel','')
set(ax_labels,'XTicklabel',labels)



% % dateticks, this function has been modified so xlims & ticks update when panning or zooming
% set(ax(:),'Tag','myaxes') % used in callbacks
% % dynamicDateTicks_myaxes(ax(nr:nr:na),'linked','dd-mmm')
% dynamicDateTicks_myaxes(ax(nr:nr:na),[],'dd-mmm')





