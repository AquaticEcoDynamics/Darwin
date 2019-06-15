% /////// fv_get_var ///////
% C = fv_get_sheet(C,nci,it,variables)
% Extract TUFLOW-FV results (2D &/or 3D) from TUFLOW-FV results file.
% The function netcdf_get_var.m will do a similar thing but does not store
% information used in the extraction of the results from one call to the
% next and is hence slower when called within a loop etc. Some TUFLOW-FV
% variables do not have a time dimension and are unaffected by the "it" input.
%
% inputs
%   C = Initially an empty structure. If fv_get_var has previously been called then C contains the field 'WORK'
%   nci = netcdf file identifyer
%   it = timestep from which to extract results
%   variables = variables within the results file to extract
%
% outputs
%   obj.results_cell = structure with fields for each variable created
%   obj.WORK = structure containing variables required during the
%   processing. Created when C is an empty structure, ie. on the 1st call.
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function C = fv_get_var(C,nci,it,variables)
% do the hard work once
if ~isfield(C,'WORK') || C.WORK.refresh
    
    C = struct();
    
    if ischar(variables)
        variables = {variables};
    end
    nv = length(variables);
    [~,~,~,unlimdimid] = netcdf.inq(nci);
    varid = zeros(nv,1);
    i_ud = zeros(nv,1);
    for aa = 1:nv
        v_name = variables{aa};
        varid(aa) = netcdf.inqVarID(nci,v_name);
        [~, ~, dimids, ~] = netcdf.inqVar(nci,varid(aa));
        nd = length(dimids);
        START.(v_name) = zeros(nd,1);
        for bb = 1:nd
            [~,dimlen] = netcdf.inqDim(nci,dimids(bb));
            if dimids(bb) == unlimdimid;
                COUNT.(v_name)(bb) = 1;
                i_ud(aa) = bb;
            else
                COUNT.(v_name)(bb) = dimlen;
            end
        end
    end
    
    % store small variables you will need on future calls to this function
    v = {'variables';'nv';'START';'COUNT';'varid';'i_ud'};
    for aa = 1:length(v)
        eval(['C.WORK.(v{aa}) = ' v{aa} ';'])
    end
    C.WORK.refresh = false;
else
    v = {'variables';'nv';'START';'COUNT';'varid';'i_ud'};
    for aa = 1:length(v)
        eval([v{aa} ' = C.WORK.(v{aa});'])
    end
end

% extract specified variables for given timestep
for aa = 1:nv
    v_name = variables{aa};
    if i_ud(aa) >= 1
        START.(v_name)(i_ud(aa)) = it - 1;
    end
    C.(v_name) = netcdf.getVar(nci,varid(aa),START.(v_name),COUNT.(v_name));
end
