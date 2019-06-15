% /////// myformat ///////
% function fmat = myformat(infil,varargin)
% reads the next line in the file and outputs the string of format codes
% used by functions such as 'textscan'. An infil instead of fid is used so
% texscan does not scip a line.
%
% inputs
%   infil = file name
%
% vargin = 'delimiter' / delimiter, 'headerlines' / headerlines,
% 'MultipleDelimAsOne'
%
% outputs
%    fmat = string of formats used by matlab functions such a textscan
%
% JN October 2011

function fmat = myformat(infil,varargin)

% defaults
delimiter = ',';
headerlines = 0;
multidilims = false;

% variable arguments
if mod(length(varargin),2)~=0, error('varargin must be in pairs'), end
for i = 1 : 2 : length(varargin)
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch lower(varargtyp{i})
        case 'delimiter'
            delimiter = varargval{i};
        case 'headerlines'
            headerlines = varargval{i};
        case 'multipledelimsasone'
            multidilims = varargval{i};
            if ~islogical(multidilims)
                error('expecting logical input for MultipleDelimAsOne')
            end
        otherwise
            error('unexpected variable argument type')
    end
end

fid = fopen(infil);

% skip through the headerlines
if headerlines ~= 0
    for aa = 1:headerlines
        fgetl(fid);
    end
end

% get line with representative format
line = fgetl(fid);
line = strtrim(line);

% split the line at the delimiters
i = strfind(line,delimiter);
if multidilims
   j = diff(i);
   k = i(j == 1);
%    k = find(filter([1 1],2,V==' ') == 1)  Alternative to above two lines
   line(k) = [];
   i = strfind(line,delimiter); 
end

nd = length(i);
fmat = char();
k = 1;
for aa = 1:nd+1
    if aa > nd
        str_tmp = line(k:end);
    else
        str_tmp = line(k:i(aa)-1);
        k = i(aa) + 1;
    end
    if isempty(str_tmp) % eg two spaces used to padd columns
        continue
    else
        num_tmp = str2double(str_tmp);
        if isnan(num_tmp);
            fmat = strcat(fmat, '%s');
        else
            fmat = strcat(fmat, '%f');
        end
    end
end

fclose(fid);