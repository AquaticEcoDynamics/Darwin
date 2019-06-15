% -- dave_ref_names
% has two uses
% 1: create a legal field name for a structure
%  nargin = 2
%   inputs = ref & range
%   outputs = o_name, a name which can be used as a field inside a structure
%
% 2: creates a legend entry from the o_name generated from a previous call to this function
%  nargin = 1
%   inputs = o_name
%   outputs = string which tacks onto to model simulation reference in the legend
%             providing information on how the results were depth averaged
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function str = dave_ref_names(varargin)
if nargin == 2
    ref = varargin{1};
    range = varargin{2};
    range_str = [num2str(range(1)) '_' num2str(range(2))];
    range_str = strrep(range_str,'.','pnt');
    range_str = strrep(range_str,'-','min');
    
    str = [lower(ref) '_' range_str];
elseif nargin == 1
    o_name = varargin{1};
    switch o_name
        case 'twod'
            str = '2D';
        otherwise
            o_name = strrep(o_name,'pnt','.');
            o_name = strrep(o_name,'min','-');
            o_name = strrep(o_name,'_',' ');
            i = strfind(o_name,' ');
            i = i(1);
            ref = o_name(1:i-1);
            range_str = o_name(i+1:end);
            range = str2num(range_str);
            switch ref
                case 'sigma'
                    range = range * 100;
                    str = ['from ' num2str(range(1)) ' up to ' num2str(range(2)) ' % of water column'];
                case 'elevation'
                    str = ['from ' num2str(range(1)) ' up to ' num2str(range(2)) ' metres'];
                case 'height'
                    str = ['from ' num2str(range(1)) ' up to ' num2str(range(2)) ' above the bed'];
                case 'depth'
                    str = ['from ' num2str(range(1)) ' down to ' num2str(range(2)) ' below the surface'];
                case 'top'
                    str = ['between ' num2str(range(1)) ' & ' num2str(range(2)) ' layers down from surface'];
                case 'bot'
                    str = ['between ' num2str(range(1)) ' & ' num2str(range(2)) ' layers up from bed'];
            end
    end
else
    error('expecting either 1 or 2 inputs')
end