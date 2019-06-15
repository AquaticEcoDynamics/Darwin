% /////// netcdf_variables_unlimited ///////
% Looks into a netcdf file and returns a cell array of the variables which
% have an unlimited dimension and a cell array of the variables which have
% no unlimited dimension. Individual groups within the the netcdf file 
% (if the netdcf file contains groups) may
% not contain all the variables which are found within other groups.
%
% inputs
%   ncfil, netcdf file or netcdf file identifier
%
% outputs
%   var_unlim, cell array of variables which have an unlimited dimension
%   var_aux, cell array of variables which have no unlimited dimension
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function [var_unlim, var_aux] = netcdf_variables_unlimited(ncfil)

if ischar(ncfil)
    if ~exist(ncfil,'file')
        error(['unable to locate ' ncfil])
    end
    ncid = netcdf.open(ncfil,'NOWRITE');
else
    ncid = ncfil;
end

% unlimited dimension ids
[~,~,~,unlimdimid] = netcdf.inq(ncid);

% groups
grpids = netcdf.inqGrps(ncid);
if isempty(grpids)
    grpids = ncid;
end
ng = length(grpids);

var_unlim = {};
var_aux = {};
% loop through groups
for aa = 1:ng
    [~,nv,~,~] = netcdf.inq(grpids(aa));
    % loop through variables
    for bb = 0:nv-1
        [v_name, ~, dimids, ~] = netcdf.inqVar(grpids(aa),bb);
        i = ismember(dimids,unlimdimid);
        if any(i)
            var_unlim = cat(1,var_unlim,v_name);
        else
            var_aux = cat(1,var_aux,v_name);
        end
    end
end

var_unlim = unique(var_unlim);
var_aux = unique(var_aux);

if ~ismember('ResTime',var_unlim)
    var_unlim = cat(1,var_unlim,'ResTime');
end

% clean up after oneself
if ischar(ncfil)
    netcdf.close(ncid);
end

