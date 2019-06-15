% /////// netcdf_splice ///////
%
% netcdf_splice(oldfils,newfil,varargin)
%
% Splice together a set of netcdf files to create a new netcdf file.
% Splicing is performed along the unlimited dimension  (usually time).
% Where there is an overlap the data/results from the preceeding file are used
% Results to be spliced can be drawn from specific variables and thinned along the unlimited dimension.
% The variables to be spliced must have only 1 unlimited dimenension.
% If more than 1 unlimited dimension exists within the netcdf files then the user must specify which to splice & thin along.
% This must be the dimension which corresponds to the unlimited dimension of the selected variables
%
% TIP: If splicing TUFLOW-FV netcdf result files and you are splicing only
%   specified variables then include the variable layerface_Z and stat as it may be
%   needed in future results processing.
%
% inputs
%   oldfils = cell array of netcdf files to splice (must be in correct order)
%   newfill = name of .nc file to create from oldfils
%
% optional inputs as descriptor / value pairs
%   'variables'   / {'var1';'var2';...}                                                          default: all variables in oldfils{1}
%   'count_thin'  / integer, copy every count_thin value along selected dimension                default: 1
%   'dim_unlim'   / string , name of unlimited dimension in which the thinning is performed
%                            'auto' for automatiacally selected                                  default: not specified
%
% Jesper Nielsen, January 2014

function netcdf_splice(oldfils,newfil,varargin)

% check inputs
if ~iscell(oldfils) || ~ischar(newfil)
    error('expecting cell input for oldfils and string input for newfil')
end

nf = length(oldfils);
for aa = 1:nf
    f_name = oldfils{aa};
    if ~exist(f_name,'file')
        error(['unable to locate ' f_name])
    end
end

[pathstr, ~, ~] = fileparts(newfil);
if ~exist(pathstr,'dir')
    error(['unable to locate directory for ' newfil])
end

% defaults
variables = netcdf_inq_varnames(oldfils{1});
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

if count_thin ~= round(count_thin)
    error('expecting integer for optional input count_thin')
end

if ~ischar(dim_unlim)
    error('expecting a string for optional input dim_unlim')
end

% initially newfil is a copy of oldfils{1}
% -- the auxillary variables (no unlimited dimension) are copied even if not specified.
display(['splicing 1 of ' num2str(nf) ' files'])
INFO = ncinfo(oldfils{1});
nv = length(INFO.Variables);
DIM = struct();
variables_aux = {};
k = 1;
for aa = 1:nv
    v_name = INFO.Variables(aa).Name;
    nd = length(INFO.Variables(aa).Dimensions);
    for bb = 1:nd
        DIM.(v_name).name{bb} = INFO.Variables(aa).Dimensions(bb).Name;
        DIM.(v_name).count(bb) = INFO.Variables(aa).Dimensions(bb).Length;
        DIM.(v_name).i_du(bb) = INFO.Variables(aa).Dimensions(bb).Unlimited;
    end
    if ~any(DIM.(v_name).i_du)
        variables_aux{k} = v_name;
        k = k+1;
    end
end

% -- no point splicing auxillary variables as they will be copied from oldfils{1}
i = ismember(variables,variables_aux);
variables_splice = variables(~i);

% -- the variable which defines the unlimited dimension with which to splice along
variables_unlim = {};
k = 1;
for aa = 1:nv
    v_name = INFO.Variables(aa).Name;
    nd = length(INFO.Variables(aa).Dimensions);
    if nd == 1
        if INFO.Variables(aa).Dimensions(1).Unlimited;
            variables_unlim{k} = v_name;
            k = k + 1;
        end
    end
end
if length(variables_unlim) > 1
    if isemtpy(dim_unlim)
        error(['You have more than 1 unlimited dimension. '...
            'You must specify which unlimited dimension to use when building the newfil. '...
            'Use the optional input "dim_unlim" for this.'])
    end
    i = ismember(variables_unlim,dim_unlim);
    if ~any(i)
        error(['Specied unlimited dimension ' dim_unlim ' does not exist'])
    end 
else
    i = 1;
end
variables_unlim = variables_unlim{i};

% -- variables to splice (always splice the variable which defines the dimension we are splicing along)
variables_splice = unique(cat(1,variables_unlim,variables_splice));
nv = length(variables_splice);

% -- variables to copy
variables_copy = unique(cat(1,variables_aux(:),variables_splice(:)));
netcdf_copy(oldfils{1},newfil,'variables',variables_copy,'count_thin',count_thin,'dim_unlim',dim_unlim)

% splice additional files together along the unlimited dimension
nc_i1 = netcdf.open(newfil,'WRITE');
for aa = 2:nf
    nc_i2 = netcdf.open(oldfils{aa},'NOWRITE');
    
    v_i1 = netcdf.inqVarID(nc_i1,variables_unlim);
    v_i2 = netcdf.inqVarID(nc_i2,variables_unlim);
    t_old = netcdf.getVar(nc_i1,v_i1);
    t_new = netcdf.getVar(nc_i2,v_i2);
    
    count_start = find(t_new > t_old(end),1,'first');
    
    % for plotting purposes t_new(count_start) needs to be sufficiently larger than t_old(end)
    if t_new(count_start) - t_old(end) < 1e-6
        count_start = count_start + 1;
    end
    
    if isempty(count_start)
        error([oldfils{aa} ' does not follow on from ' oldfils{aa-1}])
    end
    
    finish = length(t_new);
    
    for bb = 1:nv
        display(['splicing ' num2str(bb) ' of ' num2str(nv) ' variables from ' num2str(aa) ' of ' num2str(nf) ' files'])
        v_name = variables_splice{bb};
        v_i1 = netcdf.inqVarID(nc_i1,v_name);
        v_i2 = netcdf.inqVarID(nc_i2,v_name);
        
        count = DIM.(v_name).count;
        i_du = DIM.(v_name).i_du;
        if sum(i_du) > 1
            error('cannot splice variables which have more than 1 unlimited dimension')
        end
        nd = length(i_du);
        
        k = length(t_old);
        start = zeros(nd,1); % 0 based
        count(i_du) = 1;
        for cc = count_start : count_thin : finish
            start(i_du) = cc - 1;
            val = netcdf.getVar(nc_i2,v_i2,start,count);
            start(i_du) = k;
            netcdf.putVar(nc_i1,v_i1,start,count,val)
            k = k + 1;
        end
    end
    netcdf.close(nc_i2);
end
netcdf.close(nc_i1);

% update the attributes
INFO = ncinfo(newfil);
INFO = rmfield(INFO,{'Dimensions','Variables','Groups'});
INFO.Attributes(end).Name = 'Parent files';
INFO.Attributes(end).Value = char(oldfils);
ncwriteschema(newfil,INFO);