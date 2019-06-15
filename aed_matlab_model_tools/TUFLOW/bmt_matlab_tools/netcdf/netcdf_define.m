% Create a netcdf file and define dimensions, variables and attributes
%
% nc = netcdf_define(ncfil,dimensions,variables,attributes)
% nc = netcdf_define(ncfil,dimensions,variables,attributes,'cmode',cmode)
%
% dimensions - structure array:
% e.g. dim.dimname1 = dimlength1; (dimlength1 is a scalar integer)
%      dim.dimname2 = dimlength2;
%
% variables - structure array:
% e.g. var.varname1.nctype = 'NC_FLOAT';
%      var.varname1.dimensions = {'dimname1','dimname2'};
%      var.varname1.attname1 = 'metres'; (attname1 might be "units" in this instance)
%      var.varname1.attname2 = 1000; (attname2 might be "scale_factor" in this instance)
%
% attributes = structure array of global attributes:
% e.g. att.attname1 = attval1; (e.g. attname1="Origin" and attval1='Netcdf file produced by BMT WBM');
%      att.attname2 = attval2;
%
% cmode = 'NC_CLOBBER' (default) or 'NC_NOCLOBBER' or 'NC_64BIT_OFFSET' or 'NC_SHARED'        
%
% Paul Guard, BMT WBM, 2009

function nc = netcdf_define(ncfil,dimensions,variables,attributes,varargin)

nc = struct();

%Deal with variable arguments if any
cmode = 'NC_CLOBBER';
if mod(nargin-4,2)>0
    error('Expecting variable arguments as descriptor/value pairs')
end
for i = 1 : 2 : nargin-4
    varargtyp{i} = varargin{i};
    varargval{i} = varargin{i+1};
    switch varargtyp{i}
        case 'cmode'
            cmode = varargval{i};
        otherwise
            error('unexpected variable argument type')
    end
end

%Create netcdf file
nc.nci=netcdf.create(ncfil,cmode);

%Define dimensions - dimensions.(dimname)=(length)
dimnames=fieldnames(dimensions);
nc.dimids=zeros(length(dimnames),1);
for aa=1:length(dimnames)
    if isnumeric(dimensions.(dimnames{aa}))==1 & dimensions.(dimnames{aa})>0
        nc.dimids(aa) = netcdf.defDim(nc.nci,dimnames{aa},dimensions.(dimnames{aa}));
    else
        nc.dimids(aa) = netcdf.defDim(nc.nci,dimnames{aa},netcdf.getConstant('NC_UNLIMITED'));
    end
end    
m1 = containers.Map(dimnames, num2cell(nc.dimids));

%Define variables - variables.(varname).(attribute)=(value)
%The two attributes 'dimensions' and 'nctype' are compulsory
varnames=fieldnames(variables);
nc.varids=zeros(length(varnames),1);
for ba=1:length(varnames)
    if ~isfield(variables.(varnames{ba}),'dimensions')
        error(['Need to specify dimensions for variable ' varnames{ba}])
    end
    if ~isfield(variables.(varnames{ba}),'nctype')
        error(['Need to specify nctype for variable ' varnames{ba}])
    end
    if ischar(variables.(varnames{ba}).dimensions)
        variables.(varnames{ba}).dimensions=cellstr(variables.(varnames{ba}).dimensions);
    end
    dims = zeros(length(variables.(varnames{ba}).dimensions),1);
    for bb=1:length(variables.(varnames{ba}).dimensions)
        dims(bb)=m1(variables.(varnames{ba}).dimensions{bb});
    end
    nc.varids(ba) = netcdf.defVar(nc.nci,varnames{ba},netcdf.getConstant(variables.(varnames{ba}).nctype),dims);
    var_atts=fieldnames(variables.(varnames{ba}));
    if length(var_atts)>2
        for bc=3:length(var_atts)
            netcdf.putAtt(nc.nci,nc.varids(ba),var_atts{bc},variables.(varnames{ba}).(var_atts{bc}));
        end
    end
end

%Define global attributes - attributes.(attrname)=(value)
if ~isempty(attributes)
    glob_atts=fieldnames(attributes);
    if ~isempty(glob_atts)
        for ca=1:length(glob_atts)
            netcdf.putAtt(nc.nci,netcdf.getConstant('NC_GLOBAL'),glob_atts{ca},attributes.(glob_atts{ca}));
        end
    end
end

netcdf.endDef(nc.nci);
netcdf.close(nc.nci);

end

