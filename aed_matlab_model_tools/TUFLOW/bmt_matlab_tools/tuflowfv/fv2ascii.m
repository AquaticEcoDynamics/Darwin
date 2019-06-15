% /////// fv2ascii ///////
% fv2ascii(infil,it,varargin)
%
% Creates an ascii grid file (.asc) which can be read by GIS software
% packages such as MapInfo. The model results are not interpolated on the
% grid points but the cell center values are assigned to the grid points
% ecompassed by the nodes making up the cell.
%
% To create a grid of the V_mag variable, which is not an output of
% TUFLOW-FV, you will either need to post process in your GIS software using the V_x & V_y components or
% feed in a pre-processed vector (use the optional input 'data').
%
% inputs
%   C = structure
%   resfil = .nc file containing all outputs from TUFLOW-FV run (2D or 3D)
%   grd    = grid spacing, metres or degrees when TUFLOW-FV run in spherical
%   it     = scalar indicee of timestep, it of Inf or a very large number is okay (replaced with last timestep)
%
% optional inputs as descriptor / value pairs
%   'ref'      / one of 'sigma','elevation','height','depth'                                     default: 'sigma'
%   'range'    / corresponding to above ie [s1 s2], [e1 e2], h, d                                default: [0 1] (corresponding to above default)
%   'variable' / {'var1';'var2';'var3'....}                                                      default: all variables with 2nd dimension of time excluding "stat" & "layerface_Z"
%   'data' / [nc2/nc3,1,1] modified model results ie, V_x .* TSS                                 default: not included
%       when inputing data optional input 'varaibles' must remain empty
%       and input 'it' must be scalar (would normally coorespond to the timestep
%       which the data was derived from
%   'stat' / logical(nc2,1) a replacement for the 'stat' variable stored by
%       TUFLOW-FV. Useful when inputting data which has relied on multiple
%       timesteps or if you want dry cells to retain their 'dry' value rather than NaN
%   'bounds' / [x_bl y_bl; x_tr y_tr] output grid limits ie. create a subset of the model results default: no subsetting
%
% Jesper Nielsen, December 2013

function fv2ascii(resfil,grd,it,varargin)

% defaults
ref = 'sigma';
range = [0 1];
feed = false;
data = [];
% data_name = 'data';
stat = [];
bounds = [];
[variables,~] = netcdf_variables_unlimited(resfil);
variables = setxor(variables,{'ResTime';'layerface_Z';'stat'});

% variable arguments
nva = length(varargin);
if mod(nva,2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for aa = 1 : 2 : nva
    varargtyp{aa} = varargin{aa};
    varargval{aa} = varargin{aa+1};
    switch lower(varargtyp{aa})
        case 'ref'
            ref = lower(varargval{aa});
        case 'range'
            range = varargval{aa};
        case {'variable','variables','var','vars'}
            variables = varargval{aa};
        case 'data'
            feed = true;
            data = varargval{aa};
            %         case 'data_name'
            %             data_name = varargval{aa};
        case 'stat'
            stat = varargval{aa};
        case {'bound','bounds'}
            bounds = varargval{aa};
        otherwise
            error('unexpected variable argument type')
    end
end

% fv_get_dave / fv_get_layer will perform most of the checks
if ~isempty(bounds) && size(bounds,1) ~= 2 && size(bounds,2) ~= 2
    error('input bounds must be of size [2,2]')
end

% retrieve and process into 2D results if needed
C = struct();
switch lower(ref)
    case {'top','bot'}
        C = fv_get_layer(C,resfil,it,'variable',variables,'ref',ref,'range',range,'data',data,'stat',stat);
    case {'sigma','elevation','depth','height'}
        C = fv_get_dave(C,resfil,it,'variable',variables,'ref',ref,'range',range,'data',data,'stat',stat);
end

% are the TUFLOW-FV results in spherical coordinates
tmp = ncreadatt(resfil,'/','spherical');
switch tmp
    case 'true'
        spherical = true;
    case 'false'
        spherical = false;
end

% generate the grid
% -- extents
if isempty(bounds)
    TMP = netcdf_get_var(resfil,'names',{'node_X';'node_Y'});
    x1 = min(TMP.node_X);
    y1 = min(TMP.node_Y);
    x2 = max(TMP.node_X);
    y2 = max(TMP.node_Y);
else
    x1 = bounds(1,1);
    y1 = bounds(1,2);
    x2 = bounds(2,1);
    y2 = bounds(2,2);
end
xvec = x1:grd:x2+grd;
yvec = y1:grd:y2+grd;
yvec = fliplr(yvec);
nx = length(xvec);
ny = length(yvec);
[xgrd,ygrd] = meshgrid(xvec,yvec);

% index grid points into TUFLOW-FV 2D results
tmp = fv_get_ids_2([xgrd(:) ygrd(:)],resfil,'cell',true);
i_in = ~isnan(tmp);
i_fv = tmp(i_in);

% assign values to grid and write the .asc file
variables = fieldnames(C);
variables = setxor(variables,{'fv_get_dave';'stat';'ResTime'});
nv = length(variables);
for aa = 1:nv
    v_name = variables{aa};
    
    % asign variables to grid
    res = -9999 * ones(nx*ny,1);
    res(i_in) = C.(v_name)(i_fv);
    
    % -- reshape back onto a grid
    res_grd = reshape(res,ny,[]);
    
    % -- set NaNs to -9999
    res_grd(isnan(res_grd)) = -9999;
    
    display(['writing ' num2str(aa) ' of ' num2str(nv) ' .asc files'])
    % -- name of outfil
    if spherical
        ext = ['_' v_name '_' num2str(grd,'%.4f') 'deg'];
    else
        ext = ['_' v_name '_' num2str(grd,'%.0f') 'm'];
    end
    ext = strrep(ext,'.','pnt');
    outfil = strrep(resfil,'.nc',[ext '.asc']);
    
    % -- write the headers
    fid = fopen(outfil,'w');
    fprintf(fid,'%s %d\n','ncols',nx);
    fprintf(fid,'%s %d\n','nrows',ny);
    fprintf(fid,'%s %f\n','xllcorner',x1);
    fprintf(fid,'%s %f\n','yllcorner',y1);
    fprintf(fid,'%s %f\n','cellsize',grd);
    fprintf(fid,'%s %d\n','NODATA_value',-9999);
    
    % -- write the body
    fmat = ['%f' repmat(' %f',1,nx-1) '\n'];
    inc = 0;
    tic
    for bb = 1:ny
        fprintf(fid,fmat,res_grd(bb,:));
        inc = mytimer(bb,[1 ny],inc);
    end
    fclose(fid);
end

display('done & done :o)')
