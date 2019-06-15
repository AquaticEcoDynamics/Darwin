% /////// fv_get_profile ///////
%
% function OUT = fv_get_profile(resfil,ic2,it,varargin)
%
% Extracts TUFLOW-FV model results from specified 2D cell/s.
% If variable/s are 3D then the results throughout the water column are returned.
% Returns information on the z layering within the 2D cell/s.
%
% Unlike fv_get_dave & fv_get_layer which are designed to load and process results
%   timestep by timestep, ie the input 'it' is scalar, fv_get_profile is
%   designed to return a complete timseries on a single call, ie input "it"
%   is [it1 it2].
%
% inputs
%   resfil = .nc file containing all outputs from FV run (2D or 3D), resfil can also be a matlab .nc file identifier
%   ic2    = scalar indicees of selected 2D cells
%   it     = scalar indicees of timesteps defining time window [it1] or [it1 it2], it2 of Inf or a very large number is okay
%
% optional inputs as descriptor / value pairs
%   'variable' / {'var1';'var2';'var3'....}, variables to extract, default: all variables with second dimension of time excluding "stat" & "layerface_Z"
%   'zlayers' / true or false              , return the zlayering, default: true
%   'progress' / true or false             , show progess        , default: true
%   'fieldnames' / 'cell' or 'point'       , controls output structure fieldnames, default: 'cell'
%   'skip' / x (integer)                   , skip every x output , default: x = 0 (collect every output);
%
% outputs
%   OUT = nested structure ie DATA.CELL_3078.V_x  = matrix of size [no. layers for specified 2D cell, no. timesteps]
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function OUT = fv_get_profile(resfil,ic2,it,varargin)

% open resfil and close when finished or interrupted
if ischar(resfil)
    nci = netcdf.open(resfil,'NC_NOWRITE');
    cleanup = onCleanup(@()netcdf.close(nci));
elseif isnumeric(resfil)
    nci = resfil;
else
    error('unexpected resfil (should be nci or filename)')
end

% defaults
[variables,~] = netcdf_variables_unlimited(nci);
variables = setxor(variables,{'ResTime';'layerface_Z';'stat'});
zlay = true;
progress = true;
fieldnames = 'cell';
skip = 0;

% variables arguments
if mod(length(varargin),2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for aa = 1 : 2 : length(varargin)
    varargtyp{aa} = varargin{aa};
    varargval{aa} = varargin{aa+1};
    switch lower(varargtyp{aa})
        case {'variable','variables','var','vars','name','names'}
            variables = varargval{aa};
        case 'zlayers'
            zlay = varargval{aa};
        case 'progress'
            progress = varargval{aa};
        case {'fieldnames','fieldname'}
            fieldnames = varargval{aa};
        case 'skip'
            skip = varargval{aa};
        otherwise
            error('unexpected variable argument type')
    end
end

% checks
if ~iscell(variables)
    error('expecting cell array for optional input variables')
end
if ~islogical(zlay)
    error('expecting logical input for zlayers')
end
if ~islogical(progress)
    error('expecting logical input for progress')
end
if ~ismember(lower(fieldnames),{'cell';'point'})
    error('expecting cell or point for optional input fieldnames')
end
if round(skip) ~= skip;
    error('expecting integer input for skip')
end


% standard TUFLOW-FV variables
variables = fv_variables(variables);

% timesteps
TMP = netcdf_get_var(nci,'names',{'ResTime'});
t = TMP.ResTime;
nt = length(t);

it1 = it(1);
if it1 < 1
    it1 = 1;
end
if isscalar(it)
    it2 = it1;
else it2 = it(2);
    if it2 > nt;
        it2 = nt;
    end
end

OUT.time = t(it1:skip+1:it2);
nt = length(OUT.time);

% occassionly to boost speed info on z layering is not wanted
if zlay
    variables = cat(1,{'layerface_Z'},variables);
end
nv = length(variables);

% info on variables
[~,~,~,unlimdimid] = netcdf.inq(nci);
varid = zeros(nv,1);
i_ud = zeros(nv,1);
is_2d = false(nv,1);
is_3d = false(nv,1);
is_zl = false(nv,1);
is_bed = false(nv,1);
for aa = 1:nv
    v_name = variables{aa};
    varid(aa) = netcdf.inqVarID(nci,v_name);
    [~, ~, dimids, ~] = netcdf.inqVar(nci,varid(aa));
    nd = length(dimids);
    START.(v_name) = zeros(nd,1);
    for bb = 1:nd
        [dimname,dimlen] = netcdf.inqDim(nci,dimids(bb));
        if dimids(bb) == unlimdimid;
            COUNT.(v_name)(bb) = 1;
            i_ud(aa) = bb;
        else
            COUNT.(v_name)(bb) = dimlen;
        end
        switch dimname
            case 'NumCells2D'
                is_2d(aa) = true;
            case 'NumCells3D'
                is_3d(aa) = true;
            case 'NumLayerFaces3D'
                is_zl(aa) = true;
            case 'NumSedFrac'
                is_bed(aa) = true;
                nb = dimlen;
        end
    end
end
is_2d(is_bed) = false;

% get some indexing info and preallocate
TMP = netcdf_get_var(nci,'names',{'NL';'idx3'});
nic2 = length(ic2);
i3 = zeros(nic2,1);
i3z = zeros(nic2,1);
nl = zeros(nic2,1);
c_names = cell(nic2,1);
for aa = 1 : nic2
    switch lower(fieldnames)
        case 'cell'
            c_names{aa} = ['CELL_',num2str(ic2(aa))];
        case 'point'
            c_names{aa} = ['PT',num2str(aa)];
    end
    c_name = c_names{aa};
    i3(aa) = TMP.idx3(ic2(aa));
    i3z(aa) = i3(aa) + ic2(aa) - 1;
    nl(aa) = TMP.NL(ic2(aa));
    for bb = 1 : nv
        v_name = variables{bb};
        if is_2d(bb)
            block = zeros(1,nt,'single');
        elseif is_3d(bb)
            block = zeros(nl(aa),nt,'single');
        elseif is_zl(bb)
            block = zeros(nl(aa)+1,nt,'single');
        elseif is_bed(bb)
            block = zeros(1,nt,nb,'single');
        end
        OUT.(c_name).(v_name) = block;
    end
end


% extract model results
% inc = [];
% k = 1;
% for aa = it1:skip+1:it2
%     for bb = 1:nv
%         v_name = variables{bb};
%         START.(v_name)(i_ud(bb)) = aa - 1;
%         if is_2d(bb)
%             tmp_2d = netcdf.getVar(nci,varid(bb),START.(v_name),COUNT.(v_name));
%         elseif is_3d(bb)
%             tmp_3d = netcdf.getVar(nci,varid(bb),START.(v_name),COUNT.(v_name));
%         elseif is_zl(bb)
%             tmp_zl = netcdf.getVar(nci,varid(bb),START.(v_name),COUNT.(v_name));
%         elseif is_bed(bb)
%             tmp_bed = netcdf.getVar(nci,varid(bb),START.(v_name),COUNT.(v_name));
%         end
%         for cc = 1:nic2
%             c_name = c_names{cc};
%             if is_2d(bb)
%                 OUT.(c_name).(v_name)(:,k) = tmp_2d(ic2(cc));
%             elseif is_3d(bb)
%                 OUT.(c_name).(v_name)(:,k) = tmp_3d(i3(cc):i3(cc)+nl(cc)-1);
%             elseif is_zl(bb)
%                 OUT.(c_name).(v_name)(:,k) = tmp_zl(i3z(cc):i3z(cc)+nl(cc));
%             elseif is_bed(bb)
%                 OUT.(c_name).(v_name)(:,k,:) = tmp_bed(:,ic2(cc));
%             end
%         end
%     end
%     if progress
%         inc = mytimer(k,[1 nt],inc);
%     end
%     k = k+1;
% end

% this way is 10% faster than above
for aa = 1:nv
    k = 1;
    display(['loading ' num2str(aa) ' of ' num2str(nv) ' variables'])
    v_name = variables{aa};
    for bb = it1:skip+1:it2
        START.(v_name)(i_ud(aa)) = bb - 1;
        tmp = netcdf.getVar(nci,varid(aa),START.(v_name),COUNT.(v_name));
        for cc = 1:nic2
            c_name = c_names{cc};
            if is_2d(aa)
                OUT.(c_name).(v_name)(:,k) = tmp(ic2(cc));
            elseif is_3d(aa)
                OUT.(c_name).(v_name)(:,k) = tmp(i3(cc):i3(cc)+nl(cc)-1);
            elseif is_zl(aa)
                OUT.(c_name).(v_name)(:,k) = tmp(i3z(cc):i3z(cc)+nl(cc));
            elseif is_bed(aa)
                OUT.(c_name).(v_name)(:,k,:) = tmp(:,ic2(cc));
            end
        end
        k = k+1;
    end
end