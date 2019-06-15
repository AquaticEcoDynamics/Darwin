% Put netcdf variable data into an already defined netcdf file
%
% netcdf_set_var(ncfil,varname,values,varargin)
%
% Product(Size(values)) must be equal to Product(dimlengths)
%
% Variable arguments as descriptor/value pairs:
%     'timestep',tstep - where timestep is a scalar integer
%
% Paul Guard, BMT WBM, 2009

function netcdf_set_var(ncfil,varname,values,varargin)

tstep = [];

if mod(nargin-3,2)>0
    error('Expecting variable arguments as descriptor/value pairs')
end
for i = 1 : 2 : nargin-3
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch varargtyp{i}
        case 'timestep'
            tstep = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

if ischar(ncfil)
    nci = netcdf.open(ncfil,'WRITE');
    cleanup = onCleanup(@()netcdf.close(nci));
elseif isnumeric(ncfil)
    nci = ncfil;
else
    error('unexpected ncfil (should be nci or filename)')
end
[ta,tb,tc,unlimdimid] = netcdf.inq(nci);
varid = netcdf.inqVarID(nci,varname);
[td,te,dimids,tf] = netcdf.inqVar(nci,varid);
Ndim = length(dimids);
dimlen = zeros(Ndim,1);
for aa=1:Ndim
    [dimname{aa}, dimlen(aa)] = netcdf.inqDim(nci,dimids(aa));
    if dimids(aa)==unlimdimid
        if ~isempty(tstep)
            dimlen(aa)=1;
        end
    end
end
if numel(values) ~= prod(dimlen)
    error('Size of values array does not match product of dimension lengths')
end
if isempty(tstep)
    netcdf.putVar(nci,varid,values);
else
    start = zeros(Ndim,1);
    start(end) = tstep - 1;
    count=dimlen;
    netcdf.putVar(nci,varid,start,count,values);
end
end



