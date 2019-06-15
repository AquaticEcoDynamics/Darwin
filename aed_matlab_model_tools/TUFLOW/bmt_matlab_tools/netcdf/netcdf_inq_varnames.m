%
% Paul Guard, BMT WBM, 2009

function names = netcdf_inq_varnames(ncfil)

if ischar(ncfil)
    nci = netcdf.open(ncfil,'NOWRITE');
    cleanup = onCleanup(@()netcdf.close(nci));
elseif isnumeric(ncfil)
    nci = ncfil;
else
    error('unexpected ncfil (should be nci or filename)')
end
[ndims,nvars] = netcdf.inq(nci);
names = cell(nvars,1);
for i = 1 : nvars
    names{i} = netcdf.inqVar(nci,i-1);
end