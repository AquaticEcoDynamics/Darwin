% /////// m_mif = mymif(ax,fnam,varargin) ///////
% Plot a .mif file onto selected axes as a graphics object
% Patch objects for regions, line objects for lines.
%
% input
%   ax = vector of axes handles to plot onto
%   fname = .mif file
%
% optional inputs as descriptor / value pairs
%   usual line and patch properties
%
% outputs
%   h_mif = handle to miff objects
%
% calls on read_mif to read the .mif file
%
% Clara Boutin June 2011

function h_mif = mymif(ax,fnam,varargin)

% defaults
linecolor ='k';
linestyle = '-';
linewidth = get(0,'defaultaxeslinewidth');

facecolor = [0.5 0.5 0.5];  % 'none' if no fill
edgecolor = 'k';

textcolor = 'k';
fontsize = get(0,'defaulttextfontsize');
fontweight = get(0,'defaulttextfontweight');

markerfacecolor = 'k';
markeredgecolor = 'k';
markerstyle = 'o';
markersize = 10;

% variable arguments
if mod(length(varargin),2)~=0, error('varargin must be in pairs'), end

for i =1 : 2: length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch lower(varargtyp{i})
        case 'linecolor'
            linecolor = varargval{i};
        case 'linestyle'
            linestyle = varargval{i};
        case 'linewidth'
            linewidth = varargval{i};
        case 'facecolor'
            facecolor = varargval{i};
        case 'edgecolor'
            edgecolor = varargval{i};
        case 'textcolor'
            textcolor = varargval{i};
        case 'fontsize'
            fontsize = varargval{i};
        case 'fontweight'
            fontweight = varargval{i};
        case 'markerfacecolor'
            markerfacecolor = varargval{i};
        case 'markeredgecolor'
            markeredgecolor = varargval{i};
        case 'markersize'
            markersize = varargval{i};
        case 'markerstyle'
            markerstyle = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

% draw the mif
MIF = read_mif(fnam);
names = fieldnames(MIF);
nn = length(names); % region &/or polyline
na = length(ax);
k = 1;

for aa = 1:na
    f = get(ax(aa),'Parent');
    set(f,'CurrentAxes',ax(aa));
    set(ax(aa),'NextPlot','add');
    
    for bb = 1:nn
        o_name = names{bb};
        no = size(MIF.(o_name),2);
        for cc= 1 : no
            TMP = MIF.(o_name)(cc);
            x = TMP.coords(:,1);
            y = TMP.coords(:,2);
            switch lower(o_name)
                case 'poly'
                    % h_mif(k) = patch('XData',x,'YData',y,'LineStyle',linestyle,'FaceColor',facecolor,'EdgeColor',edgecolor);
                    h_mif(k) = line(x,y,'color',linecolor,'Linestyle',linestyle,'linewidth',linewidth);
                    %                 case 'pline'
                    %                     h_mif(k) = line(x,y,'color',linecolor,'Linestyle',linestyle,'linewidth',linewidth);
                case 'region'
                    h_mif(k) = patch('XData',x,'YData',y,'LineStyle',linestyle,'FaceColor',facecolor,'EdgeColor',edgecolor);
                case 'point'
                    h_mif(k) = plot(ax(aa),x,y,'o','MarkerSize',markersize,'MarkerFacecolor',markerfacecolor,'MarkerEdgeColor',markeredgecolor);
                case 'text'
                    h_mif(k) = text(x,y,string,'color',textcolor,'FontSize',fontsize,'FontWeight',fontweight);
            end
            k = k + 1;
        end
    end
end