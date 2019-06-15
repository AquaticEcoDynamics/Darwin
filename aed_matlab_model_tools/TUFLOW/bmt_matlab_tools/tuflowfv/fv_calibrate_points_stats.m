% /////// fv_calibrate_points_stats ///////
%
% function fv_calibrate_points_stats(f,varargin)
%
% Reads in the YData stored in all the line objects (timeseries) within the figure with handle
% f and returns a set of stats.
% The stats are drawn onto the figure.
% The figure need not have been generated using fv_calibrate_points
% Calls on prctle.m (NaNs are treated as missing values and rempved)
%
% inputs
%   f = handle of figure object containing line objects (timeseries)
%
% optional inputs as descriptor / value pairs
%   'ts' / 'dd/mm/yyyy HH:MM:SS', time marking start of timeseries to analyse   default: start of timeseries
%   'te' / 'dd/mm/yyyy HH:MM:SS', time marking end of timeseries to analyse     default: end of timeseries
%   'perc' / [p1, p2, ... pn], percentiles to include                           default: [10 50 90];
%
% Jesper Nielsen, February 2014

function fv_calibrate_points_stats(f,varargin)

% defaults
ts = [];
te = [];
perc = [10 50 90];

% optional inputs
nva = length(varargin);
if mod(nva,2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for aa = 1 : 2 : nva
    varargtyp{aa} = varargin{aa};
    varargval{aa} = varargin{aa+1};
    switch lower(varargtyp{aa})
        case 'ts'
            ts = varargval{aa};
        case 'te'
            te = varargval{aa};
        case {'percentiles','percentile','perc'}
            perc = varargval{aa};
    end
end

% checks
if ~isempty(ts)
    try
        ts = datenum(ts,'dd/mm/yyyy HH:MM:SS');
    catch
        error('expecting ts input in format dd/mm/yyyy HH:MM:SS')
    end
end

if ~isempty(te)
    try
        te = datenum(te,'dd/mm/yyyy HH:MM:SS');
    catch
        error('expecting te input in format dd/mm/yyyy HH:MM:SS')
    end
end
np = length(perc);

% loop through axes performing analysis on timeseries within
h_ax = findobj(f,'Type','Axes');
h_leg = findobj(f,'Tag','legend');
h_ax = setxor(h_ax,h_leg);
na = length(h_ax);
for aa = 1:na
    h_lin = findobj(h_ax(aa),'Type','line');
    h_lin = flipud(h_lin); % now should be in same order as legend
    nl = length(h_lin);
    m = zeros(nl,1);
    p = zeros(nl,np);
    names = cell(nl,1);
    for bb = 1:nl
        names{bb} = get(h_lin(bb),'DisplayName');
        name = names{bb};
        x = get(h_lin(bb),'XData');
        y = get(h_lin(bb),'YData');
        % -- subset
        if isempty(ts)
            its = 1;
        else
            its = find(x <= ts,1,'last');
            if isempty(its)
                display(['WARNING: input ts preceeds start of data set for ' name])
                its = 1;
            end
        end
        if isempty(te)
            ite = length(x);
        else
            ite = find(x >= te,1,'first');
            if isempty(ite)
                display(['WARNING: input te exceeds end of data set for ' name])
                ite = length(x);
            end
        end
        % -- get stats
        m(bb) = meani(y,2);
        p(bb,:) = prctile(y(its:ite),perc);
    end
    % -- print stats into an axes in centre of axes containing timeseries
    pos = get(h_ax(aa),'Position');
    pos(1) = pos(1) + pos(3) / 3;
    pos(2) = pos(2) + pos(4) / 3;
    pos(3) = pos(3)/3;
    pos(4) = pos(4)/3;
    
    ax = axes('parent',f,'position',pos);
    set(ax,'XLim',[-0.5 np + 2]);
    set(ax,'YLim',[-0.5 nl + 1]);
    set(ax,'XTick',[],'YTick',[]);
    set(ax,'Color',[0.9 0.9 0.9],'XColor',[0.9 0.9 0.9],'YColor',[0.9 0.9 0.9]);
    % -- -- col headers
    k = 1;
    for bb = 1:np+1
        if bb == 1
            text(bb,nl,'mean','fontsize',6,'fontweight','bold')
        else
            text(bb,nl,[num2str(perc(k),'%.1f') '%'],'fontsize',6,'fontweight','bold')
            k = k + 1;
        end
    end
    % -- -- row headers & data
    for bb = 1:nl
        y = nl - bb;
        name = names{bb};
        text(0,y,name,'fontsize',6,'fontweight','bold')
        text(1,y,num2str(m(bb),'%.1f'),'fontsize',6)
        for cc = 1:np
            x = cc + 1;
            text(x,y,num2str(p(bb,cc),'%.1f'),'fontsize',6);
        end
    end
end