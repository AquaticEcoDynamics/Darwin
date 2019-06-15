% /////// fv_get_sheet_points ///////
%
% function OUT = fv_get_sheet_points(resfil,ic2,it,varargin)
%
% fv_get_sheet_points is designed to extract TUFLOW-FV results from specified cells.
% 3D results are processed into 2D results.
% 3D variables can be processed in different ways with a single call to
% this function.
% 2D variables undergo no processing.
%
% WARNING:
%   If you want information on 'stat' (whether your selected 2D cell is wet or dry) include it as one of your variables.
%   If the cell/s in ic2 are wet the values returned will be that assigned by TUFLOW-FV not NaN
%
% options for depth averaging:
%   sigma:     [s1 s2]     - average from s1*depth above the bed up to s2*depth above the bed
%   elevation: [e1 e2]     - average from e1 metres up to e2 metres (refereced to model datum)
%   height:    [h1 h2]     - average from h1 metres above the bed up to h2 metres above the bed
%   depth:     [d1 d2]     - average from d1 metres below the surface down to d2 metres below the surface
%   top:       [t1 t2]     - average from t1 layer down to t2 layer. 1 = top layer
%   bot:       [b1 b2]     - average from b1 layer up to b2 layer. 1 = bottom layer
%
% inputs
%   resfil = .nc file containing all OUTputs from FV run (2D or 3D)
%   ic2    = scalar indicees of selected 2D cells
%   it     = scalar indicees of timesteps defining time window [it1] or [it1 it2], it2 of Inf or a very large number is okay
%
% optional inputs as descriptor / value pairs
%   'ref'      / {'ref1';'ref2';'ref3'....}, one or a combination of 'sigma','elevation','height','depth'         default: 'sigma'
%   'range'    / {range1;range2;range3....}, corresponding to above ie [s1 s2], [e1 e2], or any combination  default: [0 1] (corresponding to above default)
%   'variable' / {'var1';'var2';'var3'....}, variable/s to extract                                                default: all variables with 2nd dimension of time excluding "stat" & "layerface_Z"
%   'progress' / true or false             , show progess                                                         default: true
%   'skip'     / x (integer)               , skip every x output , default: x = 0 (collect every output);
%
% outputs (as example)
%   OUT.CELL_406.depth_5.V_x = variable V_x depth averaged from the
%       surface to a depth of 5 metres at the 2D cell 406 corresponding to the
%       time vector OUT.time
%
% NOTE:
% fv_get_sheet_points is designed to depth average the 3D results from an idividual cell for all timesteps in one hit.
% fv_get_sheet is designed to simultaneously depth average 3D results for all cells in the model mesh timestep by timestep.
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

function OUT = fv_get_sheet_points(resfil,ic2,it,varargin)

% defaults
ref_all = {'sigma'};                                   % default to depth average entire water column
range_all = {[0 1]};
progress = true;
[variables,~] = netcdf_variables_unlimited(resfil);
variables = setxor(variables,{'ResTime';'layerface_Z';'stat'});
skip = 0;

% variables arguments
if mod(length(varargin),2) > 0
    error('Expecting variable arguments as descriptor/value pairs')
end

for aa = 1 : 2 : length(varargin)
    varargtyp{aa} = varargin{aa};
    varargval{aa} = varargin{aa+1};
    switch lower(varargtyp{aa})
        case 'ref'
            ref_all = varargval{aa};
        case 'range'
            range_all = varargval{aa};
        case {'variable','variables','var','vars'}
            variables = varargval{aa};
        case 'progress'
            progress = varargval{aa};
        case 'skip'
            skip = varargval{aa};
        otherwise
            error('unexpected variable argument type')
    end
end

% basic checks
if ~iscell(variables)
    variables = {variables};
end
if ~iscell(ref_all)
    error('expecting cell array for input ref')
end
if ~iscell(range_all)
    error('expecting cell array for input range')
end
if ~islogical(progress)
    error('expecting logical input for progress')
end
if round(skip) ~= skip;
    error('expecting integer input for skip')
end

% check for standard TUFLOW-FV variables
variables = fv_variables(variables);

% check means of depth averaging
fv_check_dave(ref_all,range_all)
no = length(ref_all);

% my 3D variables
TMP = ncinfo(resfil,'cell_Zb');
nc2 = TMP.Dimensions(1).Length;

nv = length(variables);
is3D = false(nv,1);
for aa = 1:nv
    v_name = variables{aa};
    TMP = ncinfo(resfil,v_name);
    dim = TMP.Dimensions(1).Name;
    len = TMP.Dimensions(1).Length;
    switch dim
        case 'NumCells3D'
            if len ~= nc2
                is3D(aa) = true;
            end
    end
end
variables_3D = variables(is3D);
nv3 = length(variables_3D);

% get model results through fv_get_profile
if any(is3D)
    zlay = true;
else
    zlay = false;
end
C = fv_get_profile(resfil,ic2,it,'variables',variables,'progress',progress,'zlayers',zlay,'skip',skip);

% process 3D variables
nc = length(ic2);
if nv3 > 0;
    for aa = 1:nc
        c_name = ['CELL_' num2str(ic2(aa))];
        
        % -- faces of 3D cells
        lfz = C.(c_name).layerface_Z;
        [nlf,nt] = size(lfz);
        nl = nlf - 1;
        
        for bb = 1:no
            ref = lower(ref_all{bb});
            range = range_all{bb};
            nores = false;
            if ismember(ref,{'top';'bot'})
                if range(2) > nl
                    range(2) = nl;
                end
                if range(1) > nl;
                    nores = true;
                    range(1) = 1; % dummy assignment
                end
            end
            
            % -- depths defining limits to average between d1 is below d2
            top = lfz(1:end-1,:);
            bot = lfz(2:end,:);
            
            switch ref
                case 'sigma'
                    depth = top(1,:) - bot(end,:);
                    d1 = bot(end,:) + range(1) * depth;
                    d2 = bot(end,:) + range(2) * depth;
                case 'elevation'
                    d1 = max(bot(end,:),range(1));
                    d2 = min(top(1,:),range(2));
                case 'height'
                    d1 = bot(end,:) + range(1);
                    d2 = min(bot(end,:) + range(2),top(1,:));
                case 'depth'
                    d1 = max(top(1,:)-range(2),bot(end,:));
                    d2 = top(1,:) - range(1);
                case 'top'
                    d1 = lfz(range(2)+1,:);
                    d2 = lfz(range(1),:);
                case 'bot'
                    d1 = lfz(nl-range(1) + 2,:);
                    d2 = lfz(nl-range(2) + 1,:);
            end
            
            if ismember(ref,{'elevation';'height';'depth'})
                if any(d1 > top(1,:)) || any(d2 < bot(end,:))
                    nores = true;
                end
            end
            
            if ~nores
                % -- engine room
                bot = bsxfun(@max,bot,d1);
                top = bsxfun(@min,top,d2);
                frc = bsxfun(@rdivide,(top-bot),(d2-d1));
                frc = max(frc,0);
                
                % -- process 3D results into 2D results
                res = zeros(nl,nt,nv3);
                for cc = 1:nv3
                    v_name = variables_3D{cc};
                    res(:,:,cc) = C.(c_name).(v_name);
                end
                out = bsxfun(@times,res,frc);
                res_2D = sum(out,1);
                
            else
                display(['no 3D results exist in ' c_name ' for ref of ' ref ', range of ' num2str(range)])
                res_2D = NaN(1,nt,nv3);
            end
            
            % -- store the processed results with a tag detailing how it was processed
            o_name = dave_ref_names(ref,range);
            for cc = 1:nv3
                v_name = variables_3D{cc};
                OUT.(c_name).(v_name).(o_name) = res_2D(:,:,cc);
            end
        end
    end
end

% add in your 2D variables
for aa = 1:nv
    v_name = variables{aa};
    if ~is3D(aa)
        o_name = 'twod';
        for bb = 1:nc
            c_name = ['CELL_' num2str(ic2(bb))];
            OUT.(c_name).(v_name).(o_name) = C.(c_name).(v_name);
        end
    end
end

% keep in time
OUT.time = C.time;













