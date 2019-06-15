% /////// fv_check_bedref ///////
% Checks if the specified sediment fraction/s in bedref exists within the specified TUFLOW-FV
% simulation. An empty bedref value is interpreted as the user
% wants to sum all the sediment fractions together, in effect retrieving
% the _TOTAL variable which can also be outputted by TUFLOW-FV.
%
% JN, August 2014

function fv_check_bedref(resfil,bedref)
if isempty(bedref)
    return
elseif ~isnumeric(bedref)
    error('expecting numeric inputs for bedref')
elseif ~all(bedref == round(bedref))
    error('expecting whole number inputs for bedref')
elseif min(bedref) <= 0
    error('expecting bedref inputs of >=1')
else
    if ~exist(resfil,'file')
        error(['cannot locate ' resfil])
    end
    INFO = ncinfo(resfil);
    nd = length(INFO.Dimensions);
    d_length = NaN;
    for aa = 1:nd
        d_name = INFO.Dimensions(aa).Name;
        if strcmp(d_name,'NumSedFrac')
            d_length = INFO.Dimensions(aa).Length;
        end
    end
    if isnan(d_length)
        error(['no bed variables exist within ' resfil ' which contain info on individual sediment fractions'])
    elseif max(bedref) > d_length
        error(['max(bedref) exceeds the number of sediment fractions in ' resfil])
    end
end

