% Put netcdf variable data into an already defined netcdf file
%
% netcdf_put_var(ncfil,varname,values)
% netcdf_put_var(ncfil,varname,values,tstep,tnum)
%
% Product(Size(values)) must be equal to Product(dimlengths)
% Optional arguments:
% tstep   - starting timestep (must be a scalar integer)
% tnum    - number of timesteps (default = 1)
% 
% If the attributes 'scale_factor', 'add_offset' or 'fill_value' exist in
% the target nc file, they will be applied in reverse before storing data
%
% Paul Guard, BMT WBM, 2009

function netcdf_put_var(ncfil,varname,values,varargin)

try
    tstep = varargin{1};
catch
    tstep = [];
end
try
    tnum = varargin{2};
catch
    tnum = 1;
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
            dimlen(aa) = tnum;
            sizeval = size(values);
            if sizeval(end) ~= tnum && tnum > 1
                error('Values array does not contain tnum timesteps')
            end
        end
    end
end
if numel(values) ~= prod(dimlen)
    error('Size of values array does not match product of dimension lengths')
end
% check for add_offset
try
    add_offset = netcdf.getAtt(nci,varid,'add_offset');
catch
    add_offset = 0;
end
values = values - add_offset;
% check for scale_factor
try
    scale_factor = netcdf.getAtt(nci,varid,'scale_factor');
catch
    scale_factor = 1;
end
values = values / scale_factor;
% check for fill_value
try
    fill_value = netcdf.getAtt(nci,varid,'_FillValue','double');
catch
    fill_value = NaN;
end

values(isnan(values)) = fill_value;

if isempty(tstep)
    netcdf.putVar(nci,varid,values);
else
    start = zeros(Ndim,1);
    start(end) = tstep - 1;
    count=dimlen;
    netcdf.putVar(nci,varid,start,count,values);
end
end


