%
% Paul Guard, BMT WBM, 2009

function dims = netcdf_inq_dims(ncfil)

if ischar(ncfil)
    nci = netcdf.open(ncfil,'NOWRITE');
    cleanup = onCleanup(@()netcdf.close(nci));
elseif isnumeric(ncfil)
    nci = ncfil;
else
     error('unexpected ncfil (should be nci or filename)')
end
ndims = netcdf.inq(nci);
for i = 1 : ndims
    [name length] = netcdf.inqDim(nci,i-1);
    dims.(name) = length;
end
