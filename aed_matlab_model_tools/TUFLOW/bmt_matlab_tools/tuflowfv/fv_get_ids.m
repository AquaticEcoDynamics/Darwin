% /////// fv_get_ids ///////
% function i = fv_get_ids(points,resfil,type,varargin)
%
% Finds either
%   a: the closest node
%   b: the cell containing
% your specified points within your TUFLOW-FV mesh.
% If the number of points is large (> 10) use fv_get_ids_2.m
%
% An error is returned when point is outside FV mesh unless variable argument 'ignore' is set to true
%
% WARNING for case 'b' (see above)
%   This function is designed for speed and works by first finding the closest node to your point
%   before determining which element, from those connected to this node, contains the point. 
%   In very rare circumstances the element containing the point is not connected to the nearest node and an error is thrown.
%   fv_get_ids_2.m works on a different principle and although slower for a
%   small number of points is not susceptable to the above deficiency.
%
% inputs
%   points = coordinates of points [np,2];
%   resfil = .nc file of TUFLOW-FV results 
%   type = 'node' or 'cell'
%
% optional inputs
%   ignore =  logical value which determines wherther an error is thrown
%             when a point is outside the TUFLOW-FV mesh: default false
%             (error is thrown)
%
% outputs
%   i = ID's of cells or nodes (depending on "type") containing or nearest to (depending on "type") points [np,1]

function i = fv_get_ids(points,resfil,type,varargin)

% defaults
ignore = false;

% variable arguments
nva = length(varargin);
if nva == 1
    ignore = varargin{1};
    if ~islogical(ignore)
        error('variable argument must a logical')
    end
end

% find closest nodes
GEO = netcdf_get_var(resfil,'names',{'cell_node';'node_X';'node_Y'});
nod_x = GEO.node_X;
nod_y = GEO.node_Y;
cel_nod = GEO.cell_node;
npts = size(points,1);

% humble suggestion
if npts > 100
    display('fv_get_ids_2 is recommended when the number of points is large')
end

% closest node to points
i_node = NaN(npts,1);
for aa = 1:npts;
    d = hypot(nod_x-points(aa,1),nod_y-points(aa,2));
    i_tmp = find(d == min(d));
    if length(i_tmp) > 1;
        display(['WARNING ' num2str(length(id)) ' nodes are of equal distance to point ' num2str(aa)])
    end
    i_node(aa) = i_tmp(1);
end

switch lower(type)
    case {'cell';'cells'}
        i_cell = NaN(npts,1);
        for aa = 1:npts
            % -- cells attached to nearest node
            [~,ic2] = find(cel_nod == i_node(aa));
            ncel = length(ic2);
            % -- which cell contains the point
            for bb = 1:ncel
                inods = cel_nod(:,ic2(bb));
                inods(inods == 0) = [];
                
                [in,on] = inpolygon(points(aa,1),points(aa,2),nod_x(inods),nod_y(inods));
                if in || on
                    i_cell(aa) = ic2(bb);
                    break
                end
            end
            if isnan(i_cell(aa))
                if ~ignore
                    error(['point ' num2str(aa) ' of ' num2str(npts) ' is outside the FV mesh or the nearest node belongs to an adjacent cell'])
                end
            end
        end
        i = i_cell;
    case {'node';'nodes'}
        i = i_node;
    otherwise
        error('expecting string "cell" or "node" for input type')
end