% Retrieve variable data from a netcdf file
%
% data = netcdf_get_var(ncfil)
% data = netcdf_get_var(ncfil,'names',names)
% data = netcdf_get_var(ncfil,'timestep',tstep)
% data = netcdf_get_var(ncfil,'names',names,'timestep',tstep)
% data = netcdf_get_var(ncfil,'timeseries',PointIds)
% data = netcdf_get_var(ncfil,'names',names,'timeseries',PointIds)
%
% Ian Teakle, Copyright (C) BMTWBM 2014

function data = netcdf_get_var(ncfil,varargin)

data = struct();

% Deal with variable arguments
names = {};
tstep = [];
timeseries = false;
pointids = [];
if mod(nargin-1,2)>0
    error('Expecting variable arguments as descriptor/value pairs')
end
for i = 1 : 2 : nargin-1
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch varargtyp{i}
        case 'names'
            names = varargval{i};
            if ischar(names)
                names = {names};
            end
        case 'timestep'
            if timeseries, error('Specifying timeseries and timestep are mutually exclusive'), end
            tstep = varargval{i};
        case 'timeseries'
            if ~isempty(tstep), error('Specifying timeseries and timestep are mutually exclusive'), end
            timeseries = true;
            pointids = varargval{i};
            Npts = size(pointids,1);
        otherwise
            error('unexpected variable argument type')
    end
end
% Gather netcdf file info
if ischar(ncfil)
    % an easily understood warning for those who need it
    if ~exist(ncfil,'file')
        error(['unable to locate file ' ncfil])
    end
    try  %%% some times it falls over if computer for unknow reason
        cmode = bitor(netcdf.getConstant('NC_NOWRITE'),netcdf.getConstant('NC_SHARE'));
        nci = netcdf.open(ncfil,cmode);
        cleanup = onCleanup(@()netcdf.close(nci));
    catch ME
       % Get last segment of the error message identifier.
       idSegLast = regexp(ME.identifier, '(?<=:)\w+$', 'match');

       % Did the read fail because the library failed and the file exists? 
       if strcmp(idSegLast,  'libraryFailure') && exist(ncfil, 'file');
           try 
               cmode = bitor(netcdf.getConstant('NC_NOWRITE'),netcdf.getConstant('NC_SHARE'));
               nci = netcdf.open(ncfil,cmode);
               cleanup = onCleanup(@()netcdf.close(nci));
           end
       end
    end
elseif isnumeric(ncfil)
    nci = ncfil;
else
    error('unexpected ncfil (should be nci or filename)')
end
% Root level
data = netcdf_get_var_engine(nci,ncfil,names,tstep,timeseries,pointids);
% Load first group level (change to unlimited recursion)
ncGrpIDs = netcdf.inqGrps(nci);
Ngrps = length(ncGrpIDs);
for n = 1 : Ngrps
    grpname = netcdf.inqGrpName(ncGrpIDs(n));
    data.(grpname) = netcdf_get_var_engine(ncGrpIDs(n),ncfil,names,tstep,timeseries,pointids);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = netcdf_get_var_engine(nci,ncfil,names,tstep,timeseries,pointids)

data = struct();

% ncfil
% netcdf.sync(nci)
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(nci);
dimids = netcdf.inqDimIDs(nci,true)';
dimnames = cell(ndims,1);
dimlen = zeros(1,ndims);
for i = 1 : ndims
    [dimnames{i},dimlen(i)] = netcdf.inqDim(nci,dimids(i));
end
varid = netcdf.inqVarIDs(nci)';
varnames = cell(nvars,1);
xtype = zeros(nvars,1);
vardimids = cell(nvars,1);
varunlimdim = cell(nvars,1);
natts = zeros(nvars,1);
for i = 1 : nvars
    [varnames{i},xtype(i),vardimids{i},natts(i)] = netcdf.inqVar(nci,varid(i));
    varunlimdim{i} = find(vardimids{i}==unlimdimid,1,'first');
end
% Check timestep is appropriate (if specified)
if ~isempty(tstep) && unlimdimid>=0
    if tstep > dimlen(unlimdimid+1)
        error('specified timestep is greater than unlimited dimension length')
    end
end
% Get variables
if ~timeseries % We are chasing entire variables at one or all timesteps
    if isempty(names) % Get all variables
        for i = 1 : nvars
            varnam = strrep(varnames{i},'-','_');
            varnam = strrep(varnames{i},' ','_');
            if isempty(tstep) || isempty(varunlimdim{i}) % get all timesteps (if applicable)
                data.(varnam) = netcdf_getVar(nci,varid(i));
            else  % get specified timestep (if applicable)
                start = zeros(size(vardimids{i}));
                start(varunlimdim{i}) = tstep - 1;
                count = dimlen(vardimids{i}+1);
                count(varunlimdim{i}) = 1;
                data.(varnam) = netcdf_getVar(nci,varid(i),start,count);
            end
        end
    else % Get dimension variables and specified variables only
        for i = 1 : length(dimnames)
            j = strcmp(dimnames{i},varnames);
            if sum(j) > 0;
                data.(varnames{j}) = netcdf_getVar(nci,varid(j));
            end
        end
        for i = 1 : length(names)
            if isfield(data,names{i}), continue, end
            j = strcmp(names{i},varnames);
            if sum(j) > 0;
                if isempty(tstep)
                    data.(varnames{j}) = netcdf_getVar(nci,varid(j));
                else
                    if isempty(varunlimdim{j})
                        data.(varnames{j}) = netcdf_getVar(nci,varid(j));
                    else
                        start = zeros(size(vardimids{j}));
                        start(varunlimdim{j}) = tstep - 1;
                        count = dimlen(vardimids{j}+1);
                        count(varunlimdim{j}) = 1;
                        data.(varnames{j}) = netcdf_getVar(nci,varid(j),start,count);
                    end
                end
            else
                disp([names{i},' variable not found in ',num2str(ncfil)]);
            end
        end
    end
else % We are chasing timeseries output for specified points within variables
    if isempty(names) % Get all variables
        data.point_ids = pointids;
        for i = 1 : nvars
            if isempty(varunlimdim{i}), continue, end
            if length(vardimids{i})==1 % Get unlimited dimension variable
                data.(varnames{i}) = netcdf_getVar(nci,varid(i));
                continue
            end
            if length(dimlen(vardimids{i}+1))~=size(pointids,2)+1
                error(['Variable, ',varnames{i},', rank is not compatible with specified pointids'])
            end
            data.(varnames{i}) = zeros(dimlen(unlimdimid+1),Npts);
            for n = 1 : Npts
                start = [pointids(n,:)-1 0];
                count = ones(size(start));
                count(end) = dimlen(unlimdimid+1);
                stride = dimlen(vardimids{i}+1);
                stride(varunlimdim{i}) = 1;
                if any(start)<0 || length(start)~=length(vardimids{i}) || any(start+1>dimlen(vardimids{i}+1))
                    error(['Pointid [',num2str(pointids(n,:)),'] is not compatible with variable, ',varnames{i}])
                else
                    data.(varnames{i})(:,n) = netcdf_getVar(nci,varid(i),start,count,stride);
                end
            end
        end
    else % Get specified variables only
        data.point_ids = pointids;
        for i = 1 : length(names)
            if isfield(data,names{i}), continue, end
            j = strcmp(names{i},varnames);
            if sum(j) > 0;
                if isempty(varunlimdim{j}), continue, end
                if length(vardimids{j})==1 % Get unlimited dimension variable
                    data.(varnames{j}) = netcdf_getVar(nci,varid(j));
                    continue
                end
                if length(dimlen(vardimids{j}+1))~=size(pointids,2)+1
                    error(['Variable, ',varnames{j},', rank is not compatible with specified pointids'])
                end
                data.(varnames{j}) = zeros(dimlen(unlimdimid+1),Npts);
                for n = 1 : Npts
                    start = [pointids(n,:)-1 0];
                    count = ones(size(start));
                    count(end) = dimlen(unlimdimid+1);
                    stride = dimlen(vardimids{j}+1);
                    stride(varunlimdim{j}) = 1;
                    if any(start)<0 || length(start)~=length(vardimids{j}) || any(start+1>dimlen(vardimids{j}+1))
                        error(['Pointid [',num2str(pointids(n,:)),'] is not compatible with variable, ',varnames{j}])
                    else
                        data.(varnames{j})(:,n) = netcdf_getVar(nci,varid(j),start,count,stride);
                    end
                end
            else
                disp([names{i},' variable not found in ',ncfil]);
            end
        end
    end
end
%netcdf.close(nci)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nested netcdf_getVar function
function vardata = netcdf_getVar(nci,varid,varargin)
start = [];
count = [];
stride = [];
for i = 1 : nargin-2
    if i==1
        start = varargin{i};
    elseif i==2
        count = varargin{i};
    elseif i==3
        stride = varargin{i};
    end
end
% get raw data
if isempty(start)
    vardata = netcdf.getVar(nci,varid);
elseif isempty(count)
    vardata = netcdf.getVar(nci,varid,start);
elseif isempty(stride)
    vardata = netcdf.getVar(nci,varid,start,count);
else
    vardata = netcdf.getVar(nci,varid,start,count,stride);
end
% convert to double
vardata = double(vardata);
% check for fill_value
try
    fill_value = netcdf.getAtt(nci,varid,'_FillValue','double');
catch
    fill_value = NaN;
end
vardata(vardata==fill_value) = NaN;
% check for scale_factor
try
    scale_factor = double(netcdf.getAtt(nci,varid,'scale_factor','double'));
catch
    scale_factor = 1.;
end
vardata = double(vardata) * scale_factor;
% check for add_offset
try
    add_offset = netcdf.getAtt(nci,varid,'add_offset','double');
catch
    add_offset = 0.;
end
vardata = double(vardata) + add_offset;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%