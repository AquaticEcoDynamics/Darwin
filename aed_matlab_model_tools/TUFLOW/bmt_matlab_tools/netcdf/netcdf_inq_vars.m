%
% Paul Guard, BMT WBM, 2009 

function vars = netcdf_inq_vars(ncfil)

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
    [name,xtype,dimids,numatts] = netcdf.inqVar(nci,i-1);
    vars.(name).xtype = xtype;
    for j = 1 : length(dimids)
        vars.(name).dims{j} = netcdf.inqDim(nci,j-1);
    end
    for j = 1 : numatts
        attname = netcdf.inqAttName(nci,i-1,j-1);
        fieldname = strrep(attname,'_','');
        vars.(name).(fieldname) = netcdf.getAtt(nci,i-1,attname);
    end
end