% /////// fv_get_ids_2 ///////
% function i = fv_get_ids_2(points,resfil,type,varargin)
%
% Finds either
%   a: the closest node
%   b: the cell containing
% your specified points within your TUFLOW-FV mesh.
%
% Designed to handle many points, ie a SWAN input grid with (350 x 350)
% points. If you have only a few points it is more efficient to use fv_get_ids.
%
% An error is returned when a point is outside the TUFLOW-FV mesh unless variable argument 'ignore' is set to true
%
% WARNING for case 'a' above
%   The closest node returned by fv_get_ids_2 is actually the closest node
%   which also forms the cell containing the point. For the vast majority
%   of cases this is the true closest node.
%
% inputs
%   points = coordinates of points [np,2];
%   resfil = .nc file of TUFLOW-FV results 
%   type = 'node' or 'cell'
%
% optional inputs (1 or 2 in this order)
%   ignore =  logical value which determines whether an error is thrown
%             when a point is outside the TUFLOW-FV mesh: default false
%             (error is thrown)
%  progress = logical value which determines whether mytimer is called:
%               default: progress is shown
%
% outputs
%   i = [np,1], ID's of cells or nodes (depending on input "type") containing or nearest to (depending on input "type") points
%
% Jesper Nielsen July 2012

function ids = fv_get_ids_2(points,resfil,type,varargin)

% defaults
ignore = false;
progress = true;

% variable arguments
nva = length(varargin);
if nva >= 1
    ignore = varargin{1};
    if ~islogical(ignore)
        error('variable argument must a logical')
    end
end
if nva == 2
    progress = varargin{2};
    if ~islogical(progress)
        error('variable argument must a logical')
    end
end

TMP = netcdf_get_var(resfil,'names',{'node_X';'node_Y';'cell_node'});
node_coord = [TMP.node_X'; TMP.node_Y']; % [N2,NV2]
cell_vert = TMP.cell_node;   % [N4,NC3]

% 2D cells
nc2 = length(cell_vert);

% loop through 2D cells
np = size(points,1);
ids = NaN(np,1);
inc = 0;
tic
for aa = 1:nc2
    % -- index verticess
    nds_i = cell_vert(:,aa);
    nds_i = nds_i(nds_i > 0);
    
    nds_c = node_coord(:,nds_i);
    [in,on] = inpolygon(points(:,1),points(:,2),nds_c(1,:),nds_c(2,:));
    i = in | on;
    ni = sum(i);
    if ni > 0
        switch lower(type)
            case {'nodes','node'}
                nn = length(nds_c);
                x_pnt = repmat(points(i,1),1,nn);
                y_pnt = repmat(points(i,2),1,nn);
                dx = x_pnt - repmat(nds_c(1,:),ni,1);
                dy = y_pnt - repmat(nds_c(2,:),ni,1);
                dif = hypot(dx,dy);
                i_nds = bsxfun(@eq,dif,min(dif,[],2));
                [~,i_tmp] = find(i_nds);
                ids(i) = nds_i(i_tmp);
            case {'cells','cell'}
                ids(i) = aa;
            otherwise
                error('expecting string "cell" or "node" for input type')
        end
        points(i,:) = Inf; % avoid points that fall on boundary being included in multiple cells
    end
    if progress
        inc = mytimer(aa,[1 nc2],inc);
    end
end

if ~ignore
    out_i = find(isnan(ids));
    nout = length(out_i);
    if nout > 0
        for aa = 1:nout
            display(['point ' num2str(out_i(aa)) ' is outside the TUFLOW-FV mesh'])
        end
        error('use the variable argument ignore (logical) to suppress this error if needed')
    end
end