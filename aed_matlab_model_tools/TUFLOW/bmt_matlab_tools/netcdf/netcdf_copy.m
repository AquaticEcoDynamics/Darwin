% /////// netcdf_copy ///////
%
% netcdf_copy(oldfil,newfil,varargin)
%
% Copy selected variables &/or selected subsets &/or selected thinned subsets
% from an existing netcdf file to a new netcdf file.
% Subsetting and thinning is performed along the unlimited dimension (this is often "time").
% Selected variables without an unlimited dimension are copied unchanged from oldfil to newfil regardless of subsetting and thinning inputs.
% If more than 1 unlimited dimension exists then the user must specify
% an unlimited dimension or opt to have it selected automatically in which case subsetting is not allowed.
%
% inputs
%   oldfil = name of existing .nc file
%   newfil = name of .nc file to create
%
% optional inputs as descriptor / value pairs
%   'variables'   / {'var1';'var2';...}                                                          default: all variables in oldfil
%   'count_start' / integer, where to begin subset (1 based)                                     default: 1
%   'count_end'   / integer, where to end subset (1 based)                                       default: # steps along unlimited dimension
%   'count_thin'  / integer, copy every count_thin value along unlimited dimension               default: 1
%   'dim_unlim'   / string , name of unlimited dimension along which the subsetting is performed
%                            'auto' for automatiacally selected                                  default: not specified
%
% Jesper Nielsen, January 2014

function netcdf_copy(oldfil,newfil,varargin)

% check inputs
if ~ischar(oldfil) || ~ischar(newfil)
    error('expecting inputs of type string for oldfil & newfil')
end

if ~exist(oldfil,'file')
    error(['unable to locate ' oldfil])
end

if exist(newfil,'file')
    display([newfil ' already exists, press enter to overwrite'])
    pause
    delete(newfil)
end

[pathstr, ~, ~] = fileparts(newfil);
if ~exist(pathstr,'dir')
    error(['unable to locate directory for ' newfil])
end

% defaults
variables = netcdf_inq_varnames(oldfil);
count_start = 1;
count_end = inf;
count_thin = 1;
dim_unlim = '';

% variable arguments
nva = length(varargin);
if mod(nva,2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for aa = 1 : 2 : nva
    varargtyp{aa} = varargin{aa};
    varargval{aa} = varargin{aa+1};
    switch lower(varargtyp{aa})
        case {'variables','variable'}
            variables = varargval{aa};
        case 'count_start'
            count_start = varargval{aa};
        case 'count_end'
            count_end = varargval{aa};
        case 'count_thin'
            count_thin = varargval{aa};
        case 'dim_unlim'
            dim_unlim = varargval{aa};
        otherwise
            error('unexpected optional input')
    end
end

% preliminary check of optional inputs
if ~iscell(variables)
    error('expecting cell array for optional input variables')
end

if count_start ~= round(count_start) || count_end ~= round(count_end) || count_thin ~= round(count_thin)
    error('expecting integers for optional inputs count_start / count_end / count_thin')
end

if count_start < 0
    count_start = 1;
end

if ~ischar(dim_unlim)
    error('expecting a string for optional input dim_unlim')
end

% create newfil & store attributes
INFO = ncinfo(oldfil);
INFO.Filename = newfil;
INFO.Filename = '/';
INFO = rmfield(INFO,{'Dimensions','Variables','Groups'});
natt = length(INFO.Attributes);
INFO.Attributes(natt+1).Name = 'Parent file';
INFO.Attributes(natt+1).Value = oldfil;
ncwriteschema(newfil,INFO);

% store information on variables
nv = length(variables);
DIM = struct();
for aa = 1:nv
    v_name = variables{aa};
    INFO = ncinfo(oldfil,v_name);
    ncwriteschema(newfil,INFO);
    
    % -- store info on dimensions
    nd = length(INFO.Dimensions);
    DIM.(v_name).i_du = false(nd,1);
    for bb = 1:nd
        DIM.(v_name).name{bb} = INFO.Dimensions(bb).Name;
        DIM.(v_name).count(bb) = INFO.Dimensions(bb).Length;
        DIM.(v_name).i_du(bb) = INFO.Dimensions(bb).Unlimited;
    end
end

% write selected variables / subsets of selected variables to newfil;
nc_i1 = netcdf.open(oldfil,'NOWRITE');
nc_i2 = netcdf.open(newfil,'WRITE');
for aa = 1:nv
    display(['copying ' num2str(aa) ' of ' num2str(nv) ' variables'])
    v_name = variables{aa};
    v_i1 = netcdf.inqVarID(nc_i1,v_name);
    v_i2 = netcdf.inqVarID(nc_i2,v_name);
    
    i_du = DIM.(v_name).i_du;
    count = DIM.(v_name).count;
    nd = length(i_du);
    
    % -- does variable have an unlimited dimension
    if any(i_du)
        % -- does variable have more than 1 unlimited dimension
        if sum(i_du) > 1
            if isempty(dim_unlim)
                error(['You have more than 1 unlimited dimension. '...
                    'You must specify which unlimited dimension to use when building the newfil. '...
                    'Use the optional input "dim_unlim" for this.'...
                    'You can specify "dim_unlim" to auto and a dimension will be automatically selected for you'])
            elseif strcmpi(dim_unlim,'auto')
                % -- select dimension along which most data is stored
                tmp = count;
                tmp(~i_du) = 0;
                [~,i] = max(tmp);
                if count_start ~= 1 || count_thin ~= 1 || count_end ~= inf
                    error('subsetting is not allowed when optional input "dim_unlim" is set to auto')
                end
            else
                i = ismember(DIM.(v_name).name,dim_unlim);
                if ~any(i)
                        error(['Variable ' v_name ' does not have the unlimited dimension ' dim_unlim ...
                        '. Specify another unlimited dimension with optional input "dim_unlim" '...
                        'You can specify "dim_unlim" to auto and a dimension will be automatically selected for you'])
                end
            end
            i_du(~i) = false;
        end
        
        if count_end > count(i_du);
            finish = count(i_du);
        else
            finish = count_end;
        end
        start = zeros(nd,1); % 0 based
        count(i_du) = 1;
        k = 0;
        for bb = count_start : count_thin : finish
            start(i_du) = bb - 1;
            val = netcdf.getVar(nc_i1,v_i1,start,count);
            start(i_du) = k;
            netcdf.putVar(nc_i2,v_i2,start,count,val)
            k = k + 1;
        end
    else
        val = netcdf.getVar(nc_i1,v_i1);
        netcdf.putVar(nc_i2,v_i2,val);
    end
end
netcdf.close(nc_i1);
netcdf.close(nc_i2);