% /////// fv_check_dave ///////
% Simple function used to check whether the values used to depth average
% are valid - throws an error if they are not.
% Also checks whether values used to extract from certain layers are valid ie. for when using fv_get_layer
%
% function fv_check_dave(ref,range)
%
% inputs
%   ref: string or cell array specifying options for depth averaging.
%   range: numeric of cell array of values corresponding to above option
%
% outputs, if fv_check_dave is called with an output then no errors with an accompanying explanation are thrown
%   compatible: logical true when ref & range are compatible.
%
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function varargout = fv_check_dave(ref,range)

if nargout == 1
    varargout{1} = true; % the ref / range pair are compatible
elseif nargout > 1
    error('no more than 1 output permitted')
end

if isempty(ref) && isempty(range)
    return
end

if iscell(ref)
    nr = length(ref);
    if ~iscell(range)
        error('expecting cell array for input range when input ref is a cell array')
    end
    if nr ~= length(range)
        error('input range must have same length as input ref')
    end
else
    nr = 1;
end

for aa = 1:nr
    if iscell(ref)
        ref_tmp = lower(ref{aa});
        range_tmp = range{aa};
    else
        ref_tmp = lower(ref);
        range_tmp = range;
    end
    if ~ismember(ref_tmp,{'sigma','elevation','height','depth','top','bot'})
        error(['input ' ref_tmp ' is not a valid value for property Ref'])
    end
    if length(range_tmp) ~= 2
        if nargout == 1; varargout{1} = false; return; end
        error(['expecting range input of length 2 for reference ' ref_tmp])
    end
    if ismember(ref_tmp,{'sigma','height','depth'})
        if any(range_tmp < 0)
            if nargout == 1; varargout{1} = false; return; end
            error(['expecting range input of greater than or equal to 0 for reference ' ref_tmp])
        end
    end
    if ismember(ref_tmp,{'sigma','elevation','height','depth'})
        if diff(range_tmp) <= 0
            if nargout == 1; varargout{1} = false; return; end
            error(['range(1) must be smaller than range(2) for reference ' ref_tmp])
        end
    else
        if diff(range_tmp) < 0
            if nargout == 1; varargout{1} = false; return; end
            error(['range(1) must be smaller or equal to range(2) for reference ' ref_tmp])
        end
        if min(range_tmp) < 1
           if nargout == 1; varargout{1} = false; return; end
            error(['range inputs must be whole numbers greater or equal to 1 for reference ' ref_tmp])
        end
    end
    switch ref_tmp
        case 'sigma'
            if max(range_tmp) > 1 || min(range_tmp) < 0
                if nargout == 1; varargout{1} = false; return; end
                error(['expecting range inputs from 0-1 for reference ' ref_tmp])
            end
        case {'top';'bot'}
            if range_tmp(1) == 0
                if nargout == 1; varargout{1} = false; return; end
                error(['when referencing with ' ref_tmp ' range input is 1 based'])
            end
            if range_tmp(1) ~= round(range_tmp(1)) || range_tmp(2) ~= round(range_tmp(2))
                if nargout == 1; varargout{1} = false; return; end
                error(['expecting whole numbers for reference ' ref_tmp])
            end
    end
end


