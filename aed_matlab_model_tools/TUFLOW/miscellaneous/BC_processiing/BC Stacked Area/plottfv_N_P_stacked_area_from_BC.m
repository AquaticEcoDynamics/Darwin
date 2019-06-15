function [fig,ax1,ax2] = plottfv_N_P_stacked_area_from_BC(filename,datearray,varargin)
%  A function to plot a stacked area of specified "groups", as well as add
%  a secondary plot for flow.
% Usage:
% 'group' = 'TN' (default) or 'TP' (more can be added)
% 'conversion'
% 'addflow'

conv = 1;
doflow = 1;
group_ID = 'TN';
savename = [];
for i = 1:2:length(varargin)-1
    %varargin{i}
    switch varargin{i}
        case 'group'
            group_ID = varargin{i+1};
            
        case 'conversion'
            conv = varargin{i+1};
        case 'addflow'
            doflow = varargin{i+1};
        case 'savename'
            savename = varargin{i+1};
        otherwise
            disp('Unknown input');
            stop
    end
end

if isempty(savename)
    savename = ['Stacked_Area_',group_ID,'.png'];
end

data = tfv_readBCfile(filename);

sss = find(data.Date >= datearray(1) & data.Date < datearray(end));

mDate = data.Date(sss);
mFlow = data.Flow(sss);
inc = 1;

leg = [];

ax1 = [];
ax2 = [];

switch group_ID
    case 'TN'
        
        if isfield(data,'Nit')
            NIT = data.Nit(sss) * conv;
            AData(:,inc) = NIT; inc = inc + 1;
            leg = [leg,{'NIT'}];
        end
        if isfield(data,'Amm')
            AMM = data.Amm(sss) * conv;
            AData(:,inc) = AMM; inc = inc + 1;
            leg = [leg,{'AMM'}];
        end
        if isfield(data,'DON')
            DON = data.DON(sss) * conv;
            AData(:,inc) = DON; inc = inc + 1;
            leg = [leg,{'DON'}];
        end
        if isfield(data,'DONR')
            DONR = data.DONR(sss) * conv;
            AData(:,inc) = DONR; inc = inc + 1;
            leg = [leg,{'DONR'}];
        end
        if isfield(data,'PON')
            PON = data.PON(sss) * conv;
            AData(:,inc) = PON; inc = inc + 1;
            leg = [leg,{'PON'}];
        end
        
    case 'TP'
        if isfield(data,'FRP')
            FRP = data.FRP(sss) * conv;
            AData(:,inc) = FRP; inc = inc + 1;
            leg = [leg,{'FRP'}];
        end
        if isfield(data,'FRP_ADS')
            FRP_ADS = data.FRP_ADS(sss) * conv;
            AData(:,inc) = FRP_ADS; inc = inc + 1;
            leg = [leg,{'FRP ADS'}];
        end
        if isfield(data,'DOP')
            DOP = data.DOP(sss) * conv;
            AData(:,inc) = DOP; inc = inc + 1;
            leg = [leg,{'DOP'}];
        end
        if isfield(data,'DOPR')
            DOPR = data.DOPR(sss) * conv;
            AData(:,inc) = DOPR; inc = inc + 1;
            leg = [leg,{'DOPR'}];
        end
        if isfield(data,'POP')
            POP = data.POP(sss) * conv;
            AData(:,inc) = POP; inc = inc + 1;
            leg = [leg,{'POP'}];
        end
end

if isempty(AData)
    disp('Your header names may not match the script: Edit the headers or this script')
    stop
end

fig = figure;

if doflow
    subplot(3,3,1:6)
end
area(mDate,AData);

xlim([datearray(1) datearray(end)]);

ylabel('mg/L');

legend(leg);

set(gca,'xtick',datearray,'xticklabel',datestr(datearray,'mm-yyyy'));

grid on
ax1 = get(gca);


if doflow
    subplot(3,3,7:9)
    ax2 = get(gca);
    plot(mDate,mFlow,'color',[0.7 0.7 0.7],'linewidth',2);
    set(gca,'xtick',datearray,'xticklabel',datestr(datearray,'mm-yyyy'));
    ylabel('Flow (m^3/s)');
    xlim([datearray(1) datearray(end)]);
    
    set(gca, 'ydir', 'reverse');
    ax2 = get(gca);
    
    
end


saveas(gcf,savename);


end
function data = tfv_readBCfile(filename)
%--% a simple function to read in a TuflowFV BC file and return a
%structured type 'data', justing the headers as variable names.
%
% Created by Brendan Busch

if ~exist(filename,'file')
    disp('File Not Found');
    return
end

data = [];

fid = fopen(filename,'rt');

sLine = fgetl(fid);

headers = regexp(sLine,',','split');
headers = regexprep(headers,'\s','');
EOF = 0;
inc = 1;
while ~EOF
    
    sLine = fgetl(fid);
    
    if sLine == -1
        EOF = 1;
    else
        dataline = regexp(sLine,',','split');
        
        for ii = 1:length(headers);
            
            if strcmpi(headers{ii},'ISOTime')
                data.Date(inc,1) = datenum(dataline{ii},...
                    'dd/mm/yyyy HH:MM');
            else
                data.(headers{ii})(inc,1) = str2double(dataline{ii});
            end
        end
        inc = inc + 1;
    end
end


end


