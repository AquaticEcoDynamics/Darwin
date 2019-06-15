% /////// mybathy ///////
% Plots the bathymetry as at the model's initialisation onto the specified
% axes. This is useful as you do not have to worry about dry cells.
% The way the interpolated shading is performed for fvg_sheet objects is
% not ideal for advanced lighting options (the bathy does not appear nice
% and smooth) so again use this function. When visualising the 2D it is
% difficult to revolve and rotate the entire mesh. Use the bounds input to
% trim out the areas you are not concerned with.
%
% h = mybathy(ax,resfil,geofil)
%
% inputs
%   ax = handle of axes to plot into
%   resfil = .nc TUFLOW-FV results file
% 
% optional inputs
%   edgecolor = color of cell edges, default = none
%   bounds = [x1 y1 ; ... ; xn yn] points defining the bounds of the bathy
%            to visualise, default = []
%
% Jesper Nielsen, September 2014

function h = mybathy(ax,resfil,varargin)

% defaults
edgecolor = 'none';
bounds = [];

% -- property / value pairs (optional inputs)
            noi = length(varargin);
            if mod(noi,2) ~= 0
                error('expecting optional inputs as property / value pairs')
            end
            for aa = 1:2:noi
                switch lower(varargin{aa})
                    case 'bounds'
                        bounds = varargin{aa+1};
                    case 'edgecolor'
                        edgecolor = varargin{aa+1};
                    otherwise
                        error('unexpected optional input')
                end
            end

% define the face-vertex indexing
TMP = netcdf_get_var(resfil,'names',{'cell_node','node_X','node_Y','node_Zb'});
face = TMP.cell_node;
i = find(face(:) == 0);
face(i) = face(i-3);
nn = max(face(:));
vert = zeros(nn,3,'single');
vert(:,1) = TMP.node_X;
vert(:,2) = TMP.node_Y;
vert(:,3) = TMP.node_Zb;

% blank out verticees which are beyond the bounds
if ~isempty(bounds)
    [row,col] = size(bounds);
    if row == 2
        bounds = bounds';
        if col < 3
            error('3 or more points are required to define the bounds')
        end
    elseif col == 2
        if row < 3
            error('3 or more points are required to define the bounds')
        end
    end
    i = inpolygon(vert(:,1),vert(:,2),bounds(:,1),bounds(:,2));
    vert(~i,3) = NaN;
end

% draw the patch
h = patch('Faces',face','Vertices',vert,'Parent',ax,'FaceVertexCData',TMP.node_Zb,'FaceColor','interp','EdgeColor',edgecolor);



