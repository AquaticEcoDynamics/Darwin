% /////// fvsheet_vec_grid ///////
% Function which creates the gridded coordinates for the vectors of a
% fvsheet_vec object, indexes into the 2D cells & generates the multi
% factor used for vector sizeing.
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function [pnts,i,multi,daspect] = fvsheet_vec_grid(obj)

% DataAspectRatio
daspect = get(obj.PeerObj,'DataAspectRatio');

% -- scaling of vectors
[fx,~] = getscale(obj.PeerObj);
multi = obj.VecScale * fx;

% -- grid points
grd = fx * obj.VecGrid;
xlim = get(obj.PeerObj,'XLim');
ylim = get(obj.PeerObj,'YLim');
x_vec = xlim(1):grd:xlim(2);
y_vec = ylim(1):grd:ylim(2);
[x_grd,y_grd] = meshgrid(x_vec,y_vec);
pnts(:,1) = x_grd(:);
pnts(:,2) = y_grd(:);
np = size(pnts,1);

% -- cells with nodes within ylimits
i1 = obj.node_ymin <= y_vec(end);
i2 = obj.node_ymax >= y_vec(1);
i_ylim = all([i1' i2'],2);

% -- cells with nodes that could encompass points in the columns
i1 = bsxfun(@lt,obj.node_xmin,x_vec');
i2 = bsxfun(@gt,obj.node_xmax,x_vec');
i_xlim = all(cat(3,i1,i2),3);
n_xlim = sum(i_xlim,2); % number of cells which could contain a point in column

% loop through columns (grid points with equal x coords)
node_x = obj.node_x;
node_y = obj.node_y;
node_n = obj.node_n;
nc2 = length(node_x);
ic2s = 1:nc2;
i = zeros(np,1);
k = 1;
for aa = 1:length(x_vec);
    kk = k + length(y_vec) - 1;
    % -- loop though cells potentially encompassing points in column
    ic2_col = ic2s(i_xlim(aa,:));
    for bb = 1:n_xlim(aa)
        ic2 = ic2_col(bb);
        nv = node_n(ic2);
        if i_ylim(ic2)
            in = inpolygon_fvsheet_vec(pnts(k:kk,1),pnts(k:kk,2),node_x(1:nv,ic2),node_y(1:nv,ic2)); % ~15% faster
            i(find(in) + k - 1) = ic2;
        end
    end
    k = kk + 1;
end

% trim points outside mesh
j = i == 0;
pnts(j,:) = [];
i(j) = [];

