% /////// fv_nc2dat ///////
% function fv_nc2dat(resfil,geofil,varargin)
%
% Produces .DAT (2D) files from TUFLOW-FV .nc output (2D or 3D)
% Calls on 'fv_get_sheet', fv_cell2node & WRTDAT
% See fv_get_sheet for depth averaging options
% Manually inputting data and stat is not supported in fv_nc2dat
% inputs
%   resfil = .nc file containing all outputs from FV run
%   geofil = _geo.nc file corresponding to resfil
%
% optional inputs as descriptor / value pairs
%   'ref'      / {'sigma'} | 'elevation' | 'height' | 'depth'
%   'range'    / corresponding to above ie [s1 s2], [e1 e2], h, d          default: [0 1] (corresponding to above default)
%   'variable' / {'var1';'var2';'var3'....}                                default: all variables with time dimension excluding "stat" & "layerface_Z"
%   'it' / [it1 it2]                                                       default: all tsteps [1 length(ResTime)]
%
% Jesper Nielsen, May 2011, October 2012, July 2014

function fv_nc2dat(resfil,geofil,varargin)

% defaults
ref = 'sigma';
range = [0 1];
[variables,~] = netcdf_variables_unlimited(resfil);
variables = setxor(variables,{'ResTime';'layerface_Z';'stat'});

TMP = netcdf_get_var(resfil,'names',{'ResTime'});
t_fv = TMP.ResTime;
t_mtlb = convtime(t_fv);
it1 = 1;
it2 = length(t_fv);
it = [];

% -- property / value pairs (optional inputs)
noi = length(varargin);
if mod(noi,2) ~= 0
    error('expecting optional inputs as property / value pairs')
end
for aa = 1:2:noi
    switch lower(varargin{aa})
        case 'it'
            it = varargin{aa+1};
        case 'ref'
            ref = varargin{aa+1};
        case 'range'
            range = varargin{aa+1};
        case {'variable','variables','var','vars'}
            variables = varargin{aa+1};
        otherwise
            error('unexpected optional input')
    end
end

% basic checks
if ~iscell(variables)
    error('expecting cell array for optional input variables')
end
if ~ischar(ref)
    error('expecting character array for input ref')
end
if ~isnumeric(range)
    error('expecting numeric array for input range')
end
if ~isempty(it)
    it1 = it(1);
    if length(it) == 1
        it2 = it1;
    elseif length(it) == 2
        it2 = it(2);
    else
        error('optional input "it" must be scalar or vector of length two')
    end
end

% check for standard TUFLOW-FV variables
variables = fv_variables(variables);
nv = length(variables);

% tag the means of depth averaging - first pass
ref_str = dave_ref_names(ref,range);

% info info info
TMP = netcdf_get_var(resfil,'names',{'idx3'});
nc2 = length(TMP.idx3);

% 2D and/or 3D
% 3D variables from a 2D simulation are tagged as 2D
TMP = netcdf_get_var(resfil,'names',variables,'timestep',1);
is2D = false(nv,1);
for aa = 1 : nv
    v_name = variables{aa};
    if size(TMP.(v_name),1) == nc2
        is2D(aa) = true;
    end
end

% tag for 2D variables
o_name = cell(nv,1);
for aa = 1:nv
    if is2D(aa)
        o_name{aa} = 'twod';
    else
        o_name{aa} = ref_str;
    end
end

% .DAT files
datfil = cell(nv,1);
datnam = cell(nv,1); % if variables are vector components then some will be left empty

[path, name, ~] = fileparts(resfil);
for aa = 1:nv
    if strfind(variables{aa},'_x')
        continue
    elseif strfind(variables{aa},'_y')
        variables_tmp = strrep(variables{aa},'_y','');
    else
        variables_tmp = variables{aa};
    end
    name_tmp = [name '_' variables_tmp '_' o_name{aa} '.DAT'];
    datfil{aa} = fullfile(path,name_tmp);
    datnam{aa} = [variables_tmp '_' o_name{aa}];
end

% can results be beyond depth averaging limits. If so stat in in the WRTDAT
% is not necessarily obj.results_cell.stat which indicates whether a cell is wet or dry;
if strcmpi(ref,'sigma')
    express = true;
else
    express = false;
end

% process and write all variables to .DAT file timestep by timestep
tic
inc = 0;
tag = 'overwrite';
obj = fvres_sheet(resfil,'variables',variables,'geofil',geofil,'ref',ref,'range',range);
set(obj,'output_type','node')
for aa = it1:it2
    if aa > it1
        tag = 'append';
    end
    
    % -- process 3D results into 2D results for single timestep
    % -- NaNs are switched to 0 in fv_cell2node.m
    set(obj,'time_current',t_mtlb(aa));
    
    % -- write to .DAT file
    for bb = 1:nv
        v_name = variables{bb};
        if strfind(v_name,'_x')
            continue
        elseif strfind(v_name,'_y')
            x_name = strrep(v_name,'_y','_x');
            tmp_v(:,1) = obj.results_node.(x_name);
            tmp_v(:,2) = obj.results_node.(v_name);
            tmp_v(isnan(tmp_v)) = 0; % set nodes isolated by dry cells to 0 from NaN
            if is2D(bb) || express
                WRTDAT(datfil{bb},datnam{bb},tmp_v,t_fv(aa),nc2,tag,obj.results_cell.stat)
            else
                stat = ~isnan(obj.results_cell.(v_name));
                WRTDAT(datfil{bb},datnam{bb},tmp_v,t_fv(aa),nc2,tag,stat)
            end
        else
            tmp_s = obj.results_node.(v_name);
            tmp_s(isnan(tmp_s)) = 0; % set nodes isolated by dry cells to 0 from NaN
            if is2D(bb) || express
                WRTDAT(datfil{bb},datnam{bb},tmp_s,t_fv(aa),nc2,tag,obj.results_cell.stat)
            else
                stat = ~isnan(obj.results_cell.(v_name));
                WRTDAT(datfil{bb},datnam{bb},tmp_s,t_fv(aa),nc2,tag,stat)
            end
        end
    end
    inc = mytimer(aa,[it1 it2],inc);
end
delete(obj) % ensure nci is closed
display('your .DAT files are ready :-)')
