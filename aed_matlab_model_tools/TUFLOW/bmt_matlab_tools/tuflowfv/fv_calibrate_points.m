% /////// fv_calibrate_points ///////
% High level script used in comparing TUFLOW-FV runs (2D or 3D) with each other, with data and with themselves (depth averaging between different limits within the water column).
% Can be used purely for data visualisation.
% Plots are ready for direct insertion into report
% To write the information presented in the plots to a .csv file call fv_calibrate_points_print(c)
% Can plot into pre-existing axes
%
% data
%   .mat files where variable names are consistent with TUFLOW-FV, time variables are matlab convention
%   data is separated into fields within the parent structure 'DATA'
%   eg. velocity data for KIRRA (site-name where data logger deployed) DATA.KIRRA.V_mag
%   coordinates must be stored with data eg. DATA.KIRRA.coordinates
%   In your .mat file, store the wind and current components (ie V_x,V_y),
%   for waves store WVDIR in nautical convention. TUFLOW-FV outputs WVDIR
%   in cartesian but this is converted with fv_calibrate_points.
%
% input structure
%   c.points      : (#points,2)      - coordinates of additional points (additional to those any data corresponds to)
%   c.points_names: {#points}        - names given to above specified points (default: {'point_1';'point_2':...'point_3'} features in titles
%   c.points_order: {#points to plot}- names of the points in the order you wish to plot them (only data with its name specified in the list will be plotted)
%   c.res_fils    : {#fv_runs}       - .nc files with results
%   c.dat_fils    : {#data sources}  - data compiled as described above
%   c.ts          : (string)         - start time 'dd/mm/yyyy HH:MM:SS' or 'start'
%   c.te          : (string)         - end time 'dd/mm/yyyy HH:MM:SS' or 'end'
%   c.t_dif       : (numeric)        - time (hours) to add to model to align with data
%   c.view        : '2D' / '3D' / 'rose' / 'drift' / 'scatter'
%   c.variables   : 'hydro'(v_mag,v_dir,h) or 'wave'(H_sig,Pdir,Tp) or any variables specified separately. when "view" is '3D' then only V_x, V_y, W10_x & W10_y
%   c.tide_split  : (numeric)        - a required field when plotting the current (c.variables = {'current'} see isflood.m,
%   c.print       : 'true' / 'false' - prints a .csv of results NOT SUPPORTED YET
%
%   c.ref         : {# depth ave. options} - 'sigma','elevation','height' or 'depth' when comparing different simulations.
%                                          - a combination of the above when comparing 3D variables, from the same simulation, depth averaged by different means / between different limits
%   c.range       : {# depth ave. options} - corresponds to above cell array, see help in fv_get_sheet_points
%
%   c.nf          : integer - # figures to fit on page (nf = 2 results in a figure ~1/2 the size of nf = 1)
%   c.orientation : (string) - 'portrait','landscape' (default)
%   c.papertype   : (string) - 'A4','A3' (default)
%
%   c.ROSE        : (structure) required when c.view = 'rose'
%                               fields of ROSE = rose types
%                               (WIND,WAVE,CURRENT), which intern are structures with
%                               fields mag_bin,theta_bin,rmax & rticks
%   c.DRIFT       : (structure) required when c.view = 'drift'
%                               fields: rmax & rticks
%
%   c.axes_exist  : list of axes handels to plot into intead of creating new ones axes
%
% JN 2011

function c = fv_calibrate_points(c)

if nargin == 0
    help fv_calibrate_points
end

% inputs
if ~isfield(c,'points') & ~isfield(c,'dat_fils'), error('expecting field "points"'); end

% checks
if isfield(c,'res_fils'), if ~iscell(c.res_fils), error('expecting cell input for res_fils'); end; end
if isfield(c,'dat_fils'), if ~iscell(c.dat_fils), error('expecting cell input for dat_fils'); end; end

% defaults
if ~isfield(c,'nf'),c.nf = 1; end
if ~isfield(c,'orientation'),c.orientation = 'landscape'; end
if ~isfield(c,'papertype'),c.papertype = 'A3'; end


if ~isfield(c,'t_dif'), c.t_dif = 0; end
if ~isfield(c,'view'), c.view = '2D'; end

switch lower(c.view)
    case '2d'
        if ~isfield(c,'ts'), c.ts = 'start'; end
        if ~isfield(c,'te'), c.te = 'end'; end
        if ~isfield(c,'variables'), c.variables = {'hydro'}; end
        switch char(c.variables)
            case 'hydro'
                c.variables = {'V_mag';'V_dir';'H'};
            case 'wave'
                c.variables = {'WVHT';'WVDIR';'WVPER'};
            case 'wind'
                c.variables = {'W10_mag';'W10_dir'};
        end
        if ismember(lower(c.variables),'current')
            if ~isfield(c,'tide_split')
                error('specifiy angles encompassing flooding tide with input c.tide_split')
            end
        end
    case 'rose'
        if ~isfield(c,'ROSE')
            error('expecting structure ROSE')
        end
        if sum(isfield(c,{'ts';'te'})) ~= 2
            error('expecting time-limit inputs')
        end
        if isfield(c,'variables')
            display('specified variables are redundant')
        end
        c.variables = {};
        r_name = fieldnames(c.ROSE);
        if length(r_name) > 1;
            error('only one type of rose plot at a time')
        else
            r_name = char(r_name);
        end
        switch lower(r_name)
            case 'wind'
                c.variables = {'W10_mag';'W10_dir'};
            case 'wave'
                c.variables = {'WVHT';'WVDIR'};
            case 'current'
                c.variables = {'V_mag';'V_dir'};
            otherwise
                error('expecting field name "wind", "wave" or "current" in ROSE')
        end
        if sum(isfield(c.ROSE.(r_name),{'mag_bin';'theta_bin';'rmax';'rticks'})) ~= 4
            error(['expecting fields "mag_bin","theta_bin","rmax","rticks" in c.ROSE.' r_name])
        end
        
    case 'drift'
        if ~isfield(c,'DRIFT')
            error('expecting structure DRIFT')
        end
        if sum(isfield(c,{'ts';'te'})) ~= 2
            error('expecting time-limit inputs')
        end
        if isfield(c,'variables')
            display('specified variables are redundant')
            c.variables = {'V_x';'V_y'};
        end
        if sum(isfield(c.DRIFT,{'rmax';'rticks'})) ~= 2
            error('expecting fields "rmax" & "rticks" in c.DRIFT')
        end
        
    case 'scatter'
        if ~isfield(c,'SCATTER')
            error('expecting structure SCATTER')
        end
        if sum(isfield(c,{'ts';'te'})) ~= 2
            error('expecting time-limit inputs')
        end
        if isfield(c,'variables')
            display('specified variables are redundant')
            c.variables = {'V_x';'V_y'};
        end
        if sum(isfield(c.SCATTER,{'rmax';'rticks'})) ~= 2
            error('expecting fields "rmax" & "rticks" in c.SCATTER')
        end
        
    case '3d'
        if ~isfield(c,'CYLINDER')
            error('expecting structure CYLINDER')
        end
        if sum(isfield(c,{'ts';'te'})) ~= 2
            error('expecting time-limit inputs')
        end
        if sum(isfield(c.CYLINDER,{'top';'inc';'rmax';'rticks'})) ~= 4
            error('expecting fields "top","inc","rmax" & "rticks" in c.CYLINDER')
            % CYLINDER can be populated with many other fields, if not they
            % will go to default as can be seen in fvcylinder
        end
        if ~isfield(c.CYLINDER,'ref_l')
            c.CYLINDER.ref_l = 0;
        end
        if isfield(c,'variables')
            display('specified variables are redundant')
        end
        %                 c.variables = {'V_x';'V_y';'W'};
        c.variables = {'V_x';'V_y'};
        display('Vertical component of velocity not included')
        if isfield(c.CYLINDER,'windme')
            if c.CYLINDER.windme
                c.variables = cat(1,c.variables,{'W10_x';'W10_y'});
            end
        end
        if isfield(c.CYLINDER,'scalar')
            c.variables = cat(1,c.variables,c.CYLINDER.scalar);
        end
end

if isfield(c,'points')
    np = size(c.points,1);
    if ~isfield(c,'points_names')
        c.points_names = cell(np,1);
        for aa = 1:np
            c.points_names{aa} = ['point_' num2str(aa)]; % default names for points
        end
    else
        if length(c.points_names) ~= np
            error('length of c.points_names must equal length of c.points')
        end
    end
    % compliance with c.points_order
    if isfield(c,'points_order')
        if length(intersect(c.points_names,c.points_order)) ~= length(c.points_names)
            error('the names assigned to your c.points (c.points_names) do not feature in c.points_order')
        end
    end
else
    c.points = [];
    c.points_names = {}; % these will be populated when sorting through data
end

% input files
if isfield(c,'res_fils')
    nm = length(c.res_fils);
else
    nm = 0;
end
if isfield(c,'dat_fils')
    nd = length(c.dat_fils);
else
    nd = 0;
end

% names assigned to input files
if isfield(c,'res_fils')
    if ~isfield(c,'res_fils_names')
        for aa = 1:nm
            c.res_fils_names{aa} = ['run_' num2str(aa)];  % default names for FV simulations
        end
    end
end

if isfield(c,'dat_fils')
    if ~isfield(c,'dat_fils_names')
        for aa = 1:nd
            c.dat_fils_names{aa} = ['dat_' num2str(aa)]; % default names for data sources
        end
    end
end

% depth averaging
if ~isfield(c,'ref')
    c.ref = 'sigma';
    if isfield(c.range)
        error('when specifying c.range you must specify c.ref')
    end
    c.range = [0 1];
end
fv_check_dave(c.ref,c.range)
no = length(c.ref);
for aa = 1:no
    options{aa} = dave_ref_names(c.ref{aa},c.range{aa});
end

% colors
if isfield(c,'color_mod')
    if ischar(c.color_mod)
        error('expecting [r g b] vector for field color_mod')
    end
    if size(c.color_mod,1) ~= nm
        error('field color_mod inconsistant with field res_fils')
    end
else
    c.color_mod = rgb(nm + 1);  % avoid pure red for models
end

if isfield(c,'color_dat')
    if ischar(c.color_dat)
        error('expecting [r g b] vector for field color_dat')
    end
    if size(c.color_dat,1) ~= nd
        error('field color_dat inconsistant with field dat_fils')
    end
else
    c.color_dat = flipud(rgb(nd + 1));  % avoid pure blue for data
end

% shades
ns = 2*no+1;
for aa = 1:nm
    m_name = c.res_fils_names{aa};
    shades = fade(c.color_mod(aa,:),ns);
    k = 2;
    for bb = 1:no
        o_name = options{bb};
        color_mod.(m_name).(o_name) = shades(k,:);
        k = k+2;
    end
    color_mod.(m_name).twod = shades(ceil(ns/2),:);   % if variable is 2D or a model is 2D then no fading
end

for aa = 1:nd
    d_name = c.dat_fils_names{aa};
    shades = fade(c.color_dat(aa,:),ns);
    k = 2;
    for bb = 1:no
        o_name = options{bb};
        color_dat.(d_name).(o_name) = shades(k,:);
        k = k+2;
    end
    color_dat.(d_name).twod = shades(ceil(ns/2),:);
end

if ~isfield(c,'print'), c.print = false; end

% counts
if isfield(c,'points')
    np = size(c.points,1);  % will be updated if data exists
end
nv = length(c.variables);

% time (FV referencing)
if ~ischar(c.ts) || ~ischar(c.te)
    error('expecting character inputs for ts & te, either, start/end or dd/mm/yyyy HH:MM:SS')
end

switch c.ts
    case 'start'
        c.ts = -Inf;
    otherwise
        c.ts = datenum(c.ts,'dd/mm/yyyy HH:MM:SS');
end

switch c.te
    case 'end'
        c.te = Inf;
    otherwise
        c.te = datenum(c.te,'dd/mm/yyyy HH:MM:SS');
end

% plotting into existing axes
if isfield(c,'axes_exist')
    ne = length(c.axes_exist);
    for aa = 1:ne
        axe_tmp = c.axes_exist(aa);
        if ishandle(axe_tmp)
            type = get(axe_tmp,'Type');
            switch type
                case 'axes'
                otherwise
                    error('input field axes_exist must contain handels to existing axes')
            end
        else
            error('input field axes_exist must contain handels to existing axes')
        end
    end
end

% load data
if isfield(c,'dat_fils')
    if ~isfield(c,'res_fils')
        if isfield(c,'points') && ~isempty(c.points)
            display('specified points in c.points are redundant')
            c.points = [];
            c.points_names = {};
        end
    end
    nd = length(c.dat_fils);
    for aa = 1:nd
        display(['loading data for ' num2str(aa) ' of ' num2str(nd) ' data files']);
        d_name = c.dat_fils_names{aa};
        load(c.dat_fils{aa},'DATA')
        p_names = fieldnames(DATA);
        if isfield(c,'points_order') % only extract data specified in points_order
            if strcmpi(c.points_order{1},'all')
                c.points_order = p_names;
            else
                npt = length(c.points_order);
                for bb = 1:npt % send a msg to user
                    p_name_tmp = c.points_order{bb};
                    if ~ismember(p_name_tmp,p_names)
                        display(['no data for ' p_name_tmp ' in data file ' num2str(aa)])
                    end
                end
                p_names = intersect(p_names,c.points_order);
            end
        end
        np = length(p_names);
        for bb = 1:np
            p_name = p_names{bb};
            display(['loading data for ' num2str(bb) ' of ' num2str(np) ' points'])
            % depth average 3D variables
            switch lower(c.view)
                case {'2d','rose','drift','scatter'}
                    variables_tmp = {};
                    for cc = 1:nv
                        v_names = fv_variables(c.variables{cc});
                        if isfield(DATA.(p_name),v_names{1})
                            variables_tmp = cat(1,variables_tmp,v_names);
                        else
                            display(['variable ' v_names{1} ' not found in data file ' num2str(aa)])
                        end
                    end
                    DAT.(p_name).(d_name) = adcp_get_dave(DATA.(p_name),variables_tmp,'ref',c.ref,'range',c.range);
                    for cc = 1:nv
                        v_name = c.variables{cc};
                        tmp = fv_variables(v_name);
                        v_name_real = tmp{1};
                        if isfield(DAT.(p_name).(d_name),v_name_real)
                            for dd = 1:no
                                o_name = options{dd};
                                if ~isfield(DAT.(p_name).(d_name).(v_name_real),o_name)  % variable is 2D
                                    o_name = 'twod';
                                end
                                % create new variables if required
                                switch lower(v_name)
                                    case {'v','v_mag','vmag','v_dir','vdir','current'}
                                        if isfield(DAT.(p_name).(d_name),'V_x') & isfield(DAT.(p_name).(d_name),'V_y')
                                            x = DAT.(p_name).(d_name).V_x.(o_name);
                                            y = DAT.(p_name).(d_name).V_y.(o_name);
                                            switch lower(v_name)
                                                case 'current'
                                                    tmp = sqrt(x.^2 + y.^2);
                                                    tmp2 = convdir((atan4(y,x).*(180/pi)),'current');
                                                    i = isflood(tmp2,c.tide_split);
                                                    tmp(~i) = -1 * tmp(~i);
                                                case {'v','v_mag','vmag'}
                                                    tmp = sqrt(x.^2 + y.^2);
                                                case {'v_dir','vdir'}
                                                    tmp = convdir((atan4(y,x).*(180/pi)),'current');
                                            end
                                            DAT.(p_name).(d_name).(v_name).(o_name) = tmp;
                                        else
                                            display(['variables V_x and V_y not found in data file ' num2str(aa)])
                                        end
                                    case {'w10','w10_mag','w10mag','w10_dir','w10dir'}
                                        if isfield(DAT.(p_name).(d_name),'W10_x') & isfield(DAT.(p_name).(d_name),'W10_y')
                                            x = DAT.(p_name).(d_name).W10_x.(o_name);
                                            y = DAT.(p_name).(d_name).W10_y.(o_name);
                                            switch lower(v_name)
                                                case {'w10','w10_mag','w10mag'}
                                                    tmp = sqrt(x.^2 + y.^2);
                                                case {'w10_dir','w10dir'}
                                                    tmp = convdir((atan4(y,x).*(180/pi)),'wind');
                                            end
                                            DAT.(p_name).(d_name).(v_name).(o_name) = tmp;
                                        else
                                            display(['variables W10_x and W10_y not found in data file ' num2str(aa)])
                                        end
                                    otherwise
                                end
                            end
                        end
                    end
                case {'3d'}
                    DAT.(p_name).(d_name) = DATA.(p_name);
            end
        end
    end
    % add to c.points & c.points_names
    sites = fieldnames(DAT);
    ns = length(sites);
    for aa = 1:ns
        s_name = sites{aa};
        dat_names = fieldnames(DAT.(s_name));
        ndt = length(dat_names);
        points_tmp = zeros(ndt,2);
        for bb = 1:ndt
            d_name = dat_names{bb};
            points_tmp(bb,:) = DAT.(s_name).(d_name).coordinates;
        end
        points_add = unique(points_tmp,'rows');
        if size(points_add,1) > 1
            dp = diff(points_add,1);
            dist = hypot(dp(:,1),dp(:,2));
            if max(dist) > 0.00001
                error(['coordinates for ' s_name ' are inconsistent between data files'])
            else
                points_add = points_add(1,:);
            end
        end
        c.points = cat(1,c.points,points_add);
        c.points_names = cat(1,c.points_names,s_name);
    end
end

% rearange order of c.points & c.points_names to match c.points_order
np = size(c.points,1);
if isfield(c,'points_order')
    if np ~= length(c.points_names) || np ~= length(c.points_order)
        p_out = setxor(c.points_names,c.points_order);
        if ~isempty(p_out)
            error([p_out{:} ' specified in points_order does not feature in data files or c.points_names'])
        end
        %         error('something is not right') % this error should never be thrown
    end
    i = zeros(np,1);
    for aa = 1:np
        [~,i(aa)] = ismember(c.points_order{aa},c.points_names);
    end
    c.points = c.points(i,:);
    c.points_names = c.points_names(i);
end


if isfield(c,'res_fils')
    display('loading model results')
    % which netcdf files have been pre-profiled
    prof = false(nm,1);
    for aa = 1:nm
        type = ncreadatt(c.res_fils{aa},'/','Type');
        switch type
            case 'TUFLOWFV Profile Output'
                prof(aa) = true;
        end
    end
    
    % idicess marking start and end times
    it = zeros(nm,2);
    nt = zeros(nm,1);
    dt = zeros(nm,1);
    for aa = 1:nm
        resfil = c.res_fils{aa};
        if prof(aa)
            t_tmp = ncread(resfil,'ResTime');
        else
            TMP = netcdf_get_var(resfil,'names',{'ResTime'});
            t_tmp = TMP.ResTime;
        end
        t_tmp = convtime(t_tmp);
        nt_tmp = length(t_tmp);
        it_tmp1 = find(t_tmp >= c.ts,1,'first');
        it_tmp2 = find(t_tmp <= c.te,1,'last');
        if isempty(it_tmp1)
            switch lower(c.view)
                case '2d'
                    it(aa,1) = 1;
                case {'3d','rose','drift','scatter'}
                    error(['model results for ' resfil ' do not span the specified time limits'])
            end
        else
            it(aa,1) = it_tmp1;
        end
        if isempty(it_tmp2)
            switch lower(c.view)
                case '2d'
                    it(aa,2) = nt_tmp;
                case {'3d','rose','drift','scatter'}
                    error(['model results for ' resfil ' do not span the specified time limits'])
            end
        else
            it(aa,2) = it_tmp2;
        end
        nt(aa) = it(aa,2) - it(aa,1) + 1;
        dt(aa) = mean(diff(t_tmp)); % hours
    end
    
    % indicees marking cells containing points
    ic2 = zeros(np,nm);
    for aa = 1:nm
        if ~prof(aa)
            ic2(:,aa) = fv_get_ids(c.points,c.res_fils{aa},'cell')';
        end
    end
    
    % load model results
    % -- check if variables exist in model results
    tmp = fv_variables(c.variables);
    for aa = 1:nm
        [var_unlim,~] = netcdf_variables_unlimited(c.res_fils{aa});
        i = find(~ismember(tmp,var_unlim));
        if ~isempty(i)
            error(['variable ' tmp{i(1)} ' and maybe others are not found in ' c.res_fils{aa}])
        end
    end
    switch lower(c.view)
        case {'2d','rose','drift','scatter'}
            for aa = 1:nm
                display(['loading ' num2str(aa) ' of ' num2str(nm) ' model results'])
                m_name = c.res_fils_names{aa};
                if prof(aa)
                    TMP = fv_dave_profile(c.res_fils{aa},'locations',c.points_names,'variables',c.variables,'ref',c.ref,'range',c.range);
                else
                    TMP = fv_get_sheet_points(c.res_fils{aa},ic2(:,aa),it(aa,:),'variables',c.variables,'ref',c.ref,'range',c.range);
                end
                for bb = 1:np
                    p_name = c.points_names{bb};
                    if prof(aa)
                        c_name = p_name;
                    else
                        c_name = ['CELL_' num2str(ic2(bb,aa))];
                    end
                    MOD.(p_name).(m_name).ResTime = convtime(TMP.time');
                    for cc = 1:nv
                        v_name = c.variables{cc};
                        tmp = fv_variables({v_name});
                        v_name_real = tmp{1};
                        for dd = 1:no
                            o_name = options{dd};
                            if ~isfield(TMP.(c_name).(v_name_real),o_name)  % variable is 2D
                                o_name = 'twod';
                            end
                            switch lower(v_name)     % split variables into vector components
                                case {'v','v_mag','vmag','v_dir','vdir','current'}
                                    tmp1 = TMP.(c_name).V_x.(o_name);
                                    tmp2 = TMP.(c_name).V_y.(o_name);
                                    switch lower(v_name)
                                        case {'v','v_mag','vmag'}
                                            tmp3 = sqrt(tmp1.^2 + tmp2.^2);
                                        case {'v_dir','vdir'}
                                            tmp3 = convdir((atan4(tmp2,tmp1) .* 180/pi),'current');
                                        case {'current'}
                                            tmp3 = sqrt(tmp1.^2 + tmp2.^2);
                                            tmp4 = convdir((atan4(tmp2,tmp1) .* 180/pi),'current');
                                            i = isflood(tmp4,c.tide_split);
                                            tmp3(~i) = -1 * tmp3(~i);
                                    end
                                case {'w10','w10_mag','w10mag','w10_dir','w10dir'}
                                    tmp1 = TMP.(c_name).W10_x.(o_name);
                                    tmp2 = TMP.(c_name).W10_y.(o_name);
                                    switch lower(v_name)
                                        case {'w10','w10_mag','w10mag'}
                                            tmp3 = sqrt(tmp1.^2 + tmp2.^2);
                                        case {'w10_dir','w10dir'}
                                            tmp3 = convdir((atan4(tmp2,tmp1) .* 180/pi),'wind');
                                    end
                                case 'wvdir'
                                    tmp1 = TMP.(c_name).WVDIR.(o_name);
                                    tmp3 = convdir(tmp1,'wave'); % all directions are in nautical
                                otherwise
                                    tmp3 = TMP.(c_name).(v_name).(o_name);
                            end
                            %                             if ~isfield(TMP.(c_name),v_name)
                            %                                 error('variable names must be in correct case - type "fv_variables" for full list')
                            %                             end
                            MOD.(p_name).(m_name).(v_name).(o_name) = tmp3;
                            switch o_name
                                case 'twod'
                                    break   % no point continuing to overwrite your 2D variable
                            end
                        end
                    end
                end
            end
        case '3d'
            for aa = 1:nm
                display(['loading ' num2str(aa) ' of ' num2str(nm) ' model results'])
                m_name = c.res_fils_names{aa};
                TMP = fv_get_profile(c.res_fils{aa},ic2(:,aa),it(aa,:),'variables',c.variables);
                for bb = 1:np
                    p_name = c.points_names{bb};
                    c_name = ['CELL_' num2str(ic2(bb,aa))];
                    MOD.(p_name).(m_name) = TMP.(c_name);
                    MOD.(p_name).(m_name).ResTime = convtime(TMP.time');
                end
            end
    end
    % take some of the hardwork outside
    c.it = it;
    c.ic2 = ic2;
end

% align timesteps
switch lower(c.view)
    case {'3d','scatter'}
        % -- align models with model with coursest timestep (thin high res model to match course)
        if isfield(c,'res_fils')
            i = find(dt == max(dt));
            m_name = c.res_fils_names{i};
            p_name = c.points_names{1};
            t_vec = MOD.(p_name).(m_name).ResTime;
            var_interp = cat(1,c.variables,{'zface';'zcell';'layerface_Z'});
            for aa = 1:nm
                if aa ~= i
                    m_name = c.res_fils_names{aa};
                    for bb = 1:np
                        p_name = c.points_names{bb};
                        switch lower(c.view)
                            case 'scatter'
                                MOD.(p_name).(m_name) = interp_struc(MOD.(p_name).(m_name),t_vec,var_interp,'ResTime');
                            case '3d'
                                MOD.(p_name).(m_name) = interp_struc_cyl(MOD.(p_name).(m_name),t_vec,var_interp,'ResTime');
                        end
                    end
                end
            end
            % -- align data with model timesteps
            if isfield(c,'dat_fils')
                for aa = 1:np
                    p_name = c.points_names{aa};
                    if isfield(DAT,p_name)
                        for bb = 1:nd % interpolate even if the data for particular file has no V_x or V_y (should never hapen)
                            d_name = c.dat_fils_names{bb};
                            TMP = DAT.(p_name).(d_name);
                            switch lower(c.view)
                                case 'scatter'
                                    DAT.(p_name).(d_name) = interp_struc(TMP,t_vec,var_interp,'TIME_hydro');
                                case '3d'
                                    DAT.(p_name).(d_name) = interp_struc_cyl(TMP,t_vec,var_interp,'TIME_hydro');
                            end
                            if isfield(DAT.(p_name).(d_name),'W')
                                DAT.(p_name).(d_name) = rmfield(DAT.(p_name).(d_name),'W'); % CYCLINDERS NO LONGER SUPORT W in fv_calibrate_points
                            end
                        end
                    end
                end
            end
        else
            % align timesteps between different instruments and different data sets to match the first p_name & d_name
            var_interp = c.variables;
            for aa = 1:np
                p_name = c.points_names{aa};
                for bb = 1:nd
                    d_name = c.dat_fils_names{bb};
                    if aa == 1 && bb == 1
                        t_vec = DAT.(p_name).(d_name).TIME_hydro;
                        nt = length(t_vec);
                        continue
                    else
                        switch lower(c.view)
                            case 'scatter'
                                DAT.(p_name).(d_name) = interp_struc(DAT.(p_name).(d_name),t_vec,var_interp,'TIME_hydro');
                            case '3d'
                                DAT.(p_name).(d_name) = interp_struc_cyl(DAT.(p_name).(d_name),t_vec,var_interp,'TIME_hydro');
                        end
                    end
                end
                
                %             for aa = 1:np
                %                 if np > 1 || nd > 1
                %                     error('aligning of timesteps between data not yet implemented - must use model or look at one data set at one point')
                %                 end
                %                 d_name = c.dat_fils_names{1};
                %                 % NOT YET IMPLEMENTED - recommend looking at data
                %                 % individually if not looking at model at same time
                %                 t_vec = DAT.(p_name).(d_name).TIME_hydro;
                %                 nt = length(t_vec);
                %             end
            end
            
            
        end
end

% plot
if ~isfield(c,'axes_exist')
    f = myfigure(c.nf,'PaperType',c.papertype,'PaperOrientation',c.orientation);
end

switch lower(c.view)
    case '2d'
        if isfield(c,'axes_exist')
            if ne ~= nv * np
                error([num2str(nv*np) ' pre-existing axes required for the variables and points specified'])
            end
            ax = c.axes_exist;
        else
            %             ax = myaxes(f,nv,np,'left_buff',0.04,'right_buff',0.04,'bot_buff',0.09);
            ax = myaxes(f,nv,np,'left_buff',0.06,'right_buff',0.06,'bot_buff',0.09);
        end
        set(ax(:),'NextPLot','add');
        na = length(ax);
        % data
        if isfield(c,'dat_fils')
            for aa = 1:na
                p = ceil(aa/nv);
                v = nv - (p * nv - aa);
                p_name = c.points_names{p};
                v_name = c.variables{v};
                for bb = 1:nd
                    d_name = c.dat_fils_names{bb};
                    if isfield(DAT.(p_name),d_name);
                        if isfield(DAT.(p_name).(d_name),v_name)
                            switch v_name
                                case {'WVHT','WVPER','WVDIR'}
                                    t_name = 'TIME_wave';
                                case {'W10_mag','W10_dir','W10_x','W10_y'}
                                    t_name = 'TIME_wind';
                                case {'TSS','NTU'}
                                    t_name = 'TIME_sedi';
                                otherwise
                                    t_name = 'TIME_hydro';
                            end
                            %                         [i,t_name,~] = inlim(DAT.(p_name).(d_name),v_name,[c.ts c.te]);
                            for cc = 1:no
                                o_name = options{cc};
                                if ~isfield(DAT.(p_name).(d_name).(v_name),o_name)
                                    o_name = 'twod';
                                end
                                color_tmp = color_dat.(d_name).(o_name);
                                tmp = plot(ax(aa),DAT.(p_name).(d_name).(t_name) + c.t_dif/24,DAT.(p_name).(d_name).(v_name).(o_name),'o','MarkerFaceColor',color_tmp,'MarkerEdgeColor',color_tmp,'MarkerSize',4);
                                str = dave_ref_names(o_name);
                                set(tmp,'DisplayName',[strrep(d_name,'_',' ') ', ' str]);
                                set(tmp,'Tag','data');
                                switch o_name
                                    case 'twod'
                                        break
                                end
                            end
                        end
                    end
                end
            end
        end
        % models
        if isfield(c,'res_fils')
            for aa = 1:na
                p = ceil(aa/nv);
                v = nv - (p * nv - aa);
                p_name = c.points_names{p};
                v_name = c.variables{v};
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    if isfield(MOD.(p_name).(m_name),v_name)
                        for cc = 1:no
                            o_name = options{cc};
                            if ~isfield(MOD.(p_name).(m_name).(v_name),o_name)
                                o_name = 'twod';
                            end
                            color_tmp = color_mod.(m_name).(o_name);
                            tmp = plot(ax(aa),MOD.(p_name).(m_name).ResTime + c.t_dif/24,MOD.(p_name).(m_name).(v_name).(o_name),'color',color_tmp);
                            str = dave_ref_names(o_name);
                            set(tmp,'DisplayName',[strrep(m_name,'_',' ') ', ' str]);
                            set(tmp,'Tag','model');
                            switch o_name
                                case 'twod'
                                    break
                            end
                        end
                    end
                end
            end
        end
        ax = myaxes_properties(ax,c.variables,c.points_names);
    case 'rose'
        if no > 1
            error('when creating roses specify only 1 depth averaging option')
        end
        nr = 0;
        if isfield(c,'dat_fils')
            if nd > 1
                error('cannot have more than 1 data file when looking at roses')
            end
            nr = nr + 1;
        end
        if isfield(c,'res_fils')
            nr = nr + nm;
        end
        if isfield(c,'axes_exist')
            if ne ~= nr * np
                error([num2str(nr*np) ' pre-existing axes required for the variables and points specified'])
            end
            ax = c.axes_exist;
        else
            ax = myaxes(f,nr,np,'left_buff',0.05,'bot_buff',0.05,'top_buff',0.075,'side_gap',0.05,'top_gap',0.07);
        end
        switch lower(r_name)
            case 'wind'
                x_name = 'W10_mag';
                y_name = 'W10_dir';
            case 'wave'
                x_name = 'WVHT';
                y_name = 'WVDIR';
            case 'current'
                x_name = 'V_mag';
                y_name = 'V_dir';
        end
        
        k = 1;
        for aa = 1:np
            p_name = c.points_names{aa};
            if isfield(c,'res_fils')
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    o_name = options{bb};
                    if ~isfield(MOD.(p_name).(m_name).(x_name),o_name)  % variable is 2D
                        o_name = 'twod';
                    end
                    x = MOD.(p_name).(m_name).(x_name).(o_name);
                    y = MOD.(p_name).(m_name).(y_name).(o_name);
                    roseplot(ax(k),x,y,c.ROSE.(r_name).mag_bin, c.ROSE.(r_name).theta_bin, c.ROSE.(r_name).rmax,c.ROSE.(r_name).rticks, r_name)
                    ts_str = datestr(MOD.(p_name).(m_name).ResTime(1));
                    te_str = datestr(MOD.(p_name).(m_name).ResTime(end));
                    str = dave_ref_names(o_name);
                    title(ax(k),{['{\bf MODEL }' r_name ' at ' strrep(p_name,'_',' ')];[ts_str ' to ' te_str];str})
                    k = k+1;
                end
            end
            if isfield(c,'dat_fils');
                if isfield(DAT,p_name)
                    d_name = c.dat_fils_names{1};
                    % data within time limits
                    [i,~,tlim] = inlim(DAT.(p_name).(d_name),x_name,[c.ts c.te]); % only need to use x_name as y_name created from same original variables
                    o_name = options{1};
                    if ~isfield(DAT.(p_name).(d_name).(x_name),o_name)
                        o_name = 'twod';
                    end
                    x = DAT.(p_name).(d_name).(x_name).(o_name)(i);
                    y = DAT.(p_name).(d_name).(y_name).(o_name)(i);
                    roseplot(ax(k),x,y,c.ROSE.(r_name).mag_bin, c.ROSE.(r_name).theta_bin, c.ROSE.(r_name).rmax,c.ROSE.(r_name).rticks, r_name)
                    ts_str = datestr(tlim(1));
                    te_str = datestr(tlim(2));
                    str = dave_ref_names(o_name);
                    title(ax(k),{['{\bf DATA }' r_name ' at ' strrep(p_name,'_',' ')];[ts_str ' to ' te_str];str})
                    k = k+1;
                else
                    k = k+1;
                end
            end
        end
    case 'drift'
        if no > 1
            error('when creating drift plots specify only 1 depth averaging option')
        end
        if nd > 1
            error('cannot have more than 1 data file when looking at drift plots')
        end
        if isfield(c,'axes_exist')
            if ne ~= np
                error([num2str(np) ' pre-existing axes required for the variables and points specified'])
            end
            ax = c.axes_exist;
        else
            ax = myaxes(f,1,np,'left_buff',0.05,'bot_buff',0.05,'top_buff',0.075,'side_gap',0.05,'top_gap',0.07);
        end
        for aa = 1:np
            driftplot(ax(aa),[],[],[],'rmax',c.DRIFT.rmax,'rticks',c.DRIFT.rticks)
            p_name = c.points_names{aa};
            if isfield(c,'res_fils')
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    o_name = options{1};
                    if ~isfield(MOD.(p_name).(m_name).V_x.(o_name))
                        o_name = 'twod';
                    end
                    color_tmp = color_mod.(m_name).(o_name);
                    str = dave_ref_names(o_name);
                    str = [strrep(m_name,'_',' '),' ',str];
                    t = MOD.(p_name).(m_name).ResTime;
                    x = MOD.(p_name).(m_name).V_x.(o_name);
                    y = MOD.(p_name).(m_name).V_y.(o_name);
                    driftplot(ax(aa),t,x,y,'color',color_tmp,'name',str,'draw',false)
                end
            end
            if isfield(c,'dat_fils')
                if isfield(DAT,p_name)
                    d_name = c.dat_fils_names{1};
                    o_name = options{1};
                    if ~isfield(DAT.(p_name).(d_name).V_x.(o_name))
                        o_name = 'twod';
                    end
                    color_tmp = color_dat.(d_name).(o_name);
                    str = dave_ref_names(o_name);
                    str = [strrep(d_name,'_',' '),' ',str];
                    [i,t_name,tlim] = inlim(DAT.(p_name).(d_name),'V_x',[c.ts c.te]);
                    t = DAT.(p_name).(d_name).(t_name)(i);
                    x = DAT.(p_name).(d_name).V_x.(o_name)(i);
                    y = DAT.(p_name).(d_name).V_y.(o_name)(i);
                    driftplot(ax(aa),t,x,y,'color',[1 0 0],'name',str,'draw',false)
                end
            end
            if isfield(c,'res_fils')
                ts_str = datestr(MOD.(p_name).(m_name).ResTime(1));
                te_str = datestr(MOD.(p_name).(m_name).ResTime(end));
            else
                ts_str = datestr(tlim(1));
                te_str = datestr(tlim(2));
            end
            h_tit = title(ax(aa),{['Integrated Currents at ' strrep(p_name,'_',' ')];[ts_str ' to ' te_str]});
            set(h_tit,'Visible','On')
            h_leg = legend(ax(aa),'Show');
            pos = get(ax(aa),'position');
            frac = 0.3;
            % xp = pos(1) + (pos(3)/2+frac*pos(4))/2;
            xp = pos(1) + pos(3)/2+ (pos(3)/2 - frac*pos(4))/2;
            yp = pos(2);
            width = frac * pos(4);
            height = frac * pos(4);
            
            set(h_leg,'Position',[xp yp width height]);
            set(h_leg,'Box','off')
        end
    case 'scatter'
        if no > 1
            error('when creating drift plots specify only 1 depth averaging option')
        end
        nr = 0;
        if isfield(c,'dat_fils')
            if nd > 1
                error('cannot have more than 1 data file when looking at scatter plots')
            end
            nr = nr + 1;
        end
        if isfield(c,'res_fils')
            nr = nr + nm;
        end
        na = nr * np;
        if isfield(c,'axes_exist')
            if ne ~= na
                error([num2str(na) ' pre-existing axes required for the variables and points specified'])
            end
            ax = c.axes_exist;
        else
            ax = myaxes(f,nr,np,'left_buff',0.05,'bot_buff',0.05,'top_buff',0.075,'side_gap',0.05,'top_gap',0.07);
        end
        
        for aa = 1:na;
            scatterplot(ax(aa),[],[],'rmax',c.SCATTER.rmax,'rticks',c.SCATTER.rticks)
        end
        k = 1;
        for aa = 1:np
            p_name = c.points_names{aa};
            if isfield(c,'res_fils')
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    o_name = options{1};
                    if ~isfield(MOD.(p_name).(m_name).(v_name),o_name)
                        o_name = 'twod';
                    end
                    color_tmp = color_mod.(m_name).(o_name);
                    x = MOD.(p_name).(m_name).V_x.(o_name);
                    y = MOD.(p_name).(m_name).V_y.(o_name);
                    scatterplot(ax(k),x,y,'color',color_tmp,'name',strrep(c.res_fils_names{bb},'_',' '),'draw',false)
                    
                    ts_str = datestr(MOD.(p_name).(m_name).ResTime(1));
                    te_str = datestr(MOD.(p_name).(m_name).ResTime(end));
                    str = dave_ref_names(o_name);
                    h_tit = title(ax(k),{['{\bf MODEL }Scatter of Currents at ' strrep(p_name,'_',' ')];[ts_str ' to ' te_str];str});
                    set(h_tit,'Visible','On')
                    k = k+1;
                end
            end
            if isfield(c,'dat_fils');
                o_name = dave_ref_names(c.ref{1},c.range{1});
                if ~isfield(DAT.(p_name).(d_name).V_x,o_name)  % variable is 2D
                    o_name = 'twod';
                end
                color_tmp = color_dat.(d_name).(o_name); % should always be [1 0 0]
                if isfield(DAT,p_name)
                    d_name = c.dat_fils_names{1};
                    % data within time limits
                    [i,~,tlim] = inlim(DAT.(p_name).(d_name),'V_x',[c.ts c.te]); % only need to use x_name as y_name created from same original variables
                    x = DAT.(p_name).(d_name).V_x.(o_name)(i);
                    y = DAT.(p_name).(d_name).V_y.(o_name)(i);
                    scatterplot(ax(k),x,y,'color',color_tmp,'name','DATA','draw',false)
                    
                    ts_str = datestr(tlim(1));
                    te_str = datestr(tlim(2));
                    str = dave_ref_names(o_name);
                    h_tit(k) = title(ax(k),{['{\bf DATA }Scatter of Currents at ' strrep(c.points_names{aa},'_',' ')];[ts_str ' to ' te_str];str});
                    k = k+1;
                else
                    k = k+1; % if no data at this point then axes left blank
                end
            end
        end
        set(h_tit,'Visible','On')
    case '3d'
        if isfield(c,'axes_exist')
            if ne ~= np
                error([num2str(np) ' pre-existing axes required for the variables and points specified'])
            end
            ax = c.axes_exist;
            f = get(ax(1),'Parent');
        else
            ax = myaxes(f,1,np);
        end
        %         set(ax(:),'Visible','off') % Looks good but then cannot select the axes to move them
        set(ax(:),'color','none');
        set(ax(:),'XColor',[1 1 1]);
        set(ax(:),'YColor',[1 1 1]);
        set(ax(:),'ZColor',[1 1 1]);
        set(ax(:),'CameraPosition',[-10 -10 180]) % if view is 2D the matlabs 'stretch to fill' mucks things up
        
        % colorbar fuss
        if isfield(c.CYLINDER,'scalar')
            if isfield(c.CYLINDER,'contours')
                ax_dummy = myaxes(f,1,np,'merge',[1:np],'bot_buff',0);
                set(ax_dummy,'Visible','off','HandleVisibility','off')
                mycolor(ax_dummy,c.CYLINDER.contours,'Location','SouthOutside')
                set(ax(:),'CLim',c.CYLINDER.contours(1:2))
            end
        end
        % create cylinder objects
        for aa = 1:np
            p_name = c.points_names{aa};
            if isfield(c,'res_fils')
                % cylinder base preferentially set to model bathy
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    tmp = MOD.(p_name).(m_name).zface(end,1);
                    if bb == 1
                        bot = tmp;
                    else
                        db = abs(tmp - bot);
                        bot = min([tmp,bot]);
                        if db / tmp > 0.01
                            display(['inconsitency between model bathymetry for point ' p_name ' exceeds 1%'])
                        end
                    end
                end
            else
                % cylinder base preferentially set to 1st data set bathy if no model
                d_name = c.dat_fils_names{1};
                tmp = DAT.(p_name).(d_name).zface(end,:);
                bot = mode(tmp); % avoid the NaN's at start and end
            end
            %             h_cyl.(p_name) = mycylinder(ax(aa),bot,c.CYLINDER.top,c.CYLINDER.inc,c.CYLINDER.rmax,c.CYLINDER.rticks,'ref_l',c.CYLINDER.ref_l);
            mycylinder(ax(aa),bot,c.CYLINDER.top,c.CYLINDER.inc,c.CYLINDER.rmax,c.CYLINDER.rticks,'ref_l',c.CYLINDER.ref_l);
        end
        % scale cylinders
        for aa = 1:np
            tmp = get(ax(aa),'ZLim');
            if aa == 1
                zlim = tmp;
            else
                dy  = diff(tmp);
                if dy > diff(zlim)
                    zlim = tmp;
                end
            end
        end
        set(ax(:),'ZLim',zlim);
        linkprop(ax(:),{'CameraPosition','CameraUpVector'});
        
        % populate input structures for fvcylinder with necessary fields
        c.CYLINDER.f = f;
        for aa = 1:np
            p_name = c.points_names{aa};
            c.CYLINDER.h = ax(aa);
            %             c.CYLINDER.cylinder = h_cyl.(p_name);
            c.CYLINDER.cylinder = 'blah';
            if isfield(c,'dat_fils')
                if isfield(DAT,p_name)
                    for bb = 1:nd
                        d_name = c.dat_fils_names{bb};
                        if isfield(DAT.(p_name),d_name)
                            DAT.(p_name).(d_name).CYLINDER = populate_specs(c.CYLINDER);
                            DAT.(p_name).(d_name).CYLINDER.v_facecolor = c.color_dat(bb,:);
                            if ~isfield(DAT.(p_name).(d_name),'W10_x')
                                DAT.(p_name).(d_name).CYLINDER.windme = false;
                            end
                        end
                    end
                end
            end
            if isfield(c,'res_fils')
                for bb = 1:nm
                    m_name = c.res_fils_names{bb};
                    MOD.(p_name).(m_name).CYLINDER = populate_specs(c.CYLINDER);
                    MOD.(p_name).(m_name).CYLINDER.v_facecolor = c.color_mod(bb,:);
                    if ~isfield(MOD.(p_name).(m_name),'W10_x') % not all models will have wind
                        MOD.(p_name).(m_name).windme = false;
                    end
                end
            end
        end
        
        % proceed through times updating cylinder plots as you go
        var_tmp = cat(1,c.variables,'zcell');  % 'zcell' comes out of fv_get_profile
        k = 1;
        skip = 1;
        display('last chance to move axes aroung')
        display('hit enter when ready')
        pause
        while k < Inf
            if k >= nt
                display('you have reached the end, hit the "b" key to backup')
                k = nt;
                pause
            end
            for aa = 1:np
                p_name = c.points_names{aa};
                if isfield(c,'dat_fils')
                    if isfield(DAT,p_name)
                        for bb = 1:nd
                            d_name = c.dat_fils_names{bb};
                            if isfield(DAT.(p_name),d_name)
                                DAT.(p_name).(d_name).CYLINDER = populate_data(DAT.(p_name).(d_name),DAT.(p_name).(d_name).CYLINDER,var_tmp,k);
                                if isfield(DAT.(p_name).(d_name).CYLINDER,'scalar') % data would very rarely contain scalar
                                    DAT.(p_name).(d_name).CYLINDER = rmfield(DAT.(p_name).(d_name).CYLINDER,'scalar');
                                end
                                DAT.(p_name).(d_name).CYLINDER = fvcylinder(DAT.(p_name).(d_name).CYLINDER);
                            end
                        end
                    end
                end
                
                if isfield(c,'res_fils')
                    for bb = 1:nm
                        m_name = c.res_fils_names{bb};
                        MOD.(p_name).(m_name).CYLINDER = populate_data(MOD.(p_name).(m_name),MOD.(p_name).(m_name).CYLINDER,var_tmp,k);
                        MOD.(p_name).(m_name).CYLINDER = fvcylinder(MOD.(p_name).(m_name).CYLINDER);
                    end
                end
                title(ax(aa),[strrep(p_name,'_',' ') ' at ' datestr((t_vec(k)))])
            end
            [k,skip] = myscroll(f,k,skip);
        end
end

% some outputs
c.ax = ax;

if isfield(c,'res_fils')
    c.MOD = MOD;
end

if isfield(c,'dat_fils')
    c.DAT = DAT;
end


% /////// nested functions ///////
%
%
%
% -- inlim
% used to find values within specified time limits
% inputs
%   S = structure containing data, DAT.(p_name)
%   v_name = variable name
%   tlim = [ts te] where ts & te are in matlab convention
% outputs
%   i = logical vector of data within tlim
%   t_name = name of time variable corresponding to v_name, ie TIME_wind

function [i,t_name,tlim] = inlim(S,v_name,tlim_in)

switch v_name
    case {'WVHT','WVPER','WVDIR'}
        t_name = 'TIME_wave';
    case {'W10_mag','W10_dir'}
        t_name = 'TIME_wind';
    case {'TSS'}
        t_name = 'TIME_sedi';
    otherwise
        t_name = 'TIME_hydro';
end

i = S.(t_name) >= tlim_in(1) & S.(t_name) <= tlim_in(2);
is = find(i,1,'first');
ie = find(i,1,'last');
tlim(1) = S.(t_name)(is);
tlim(2) = S.(t_name)(ie);

% -- interp_struc
% interpolates values within a structure onto the specified time vector
% inputs
%   s = structure to interpolate fields onto specified timesteps
%   t_vec = time vector to interpolate onto
%   t_name = 'ResTime' or TIME_hydro, dermines name of time variable in structure
%   outputs
%   s = structure with updated values

function s = interp_struc(s,t_vec,variables,t_name)
nv = length(variables);
for aa = 1:nv
    v_name = variables{aa};
    %     if ~isfield(s,v_name)  % structures containing data usually would not have wind variables ?????
    %         continue
    %     else
    switch v_name
        case {'zface','zcell','layerface_Z'} % won't be further looked at in fv_calibrate_points
            continue
        otherwise
            o_names = fieldnames(s.(v_name));
            no = length(o_names);
            for bb = 1:no
                o_name = o_names{bb};
                
                % remove the repeated timesteps
                if length(s.(t_name)) ~= length(unique(s.(t_name)));
                    [time_tmp,i,~] = unique(s.(t_name));
                    s.(v_name).(o_name) = s.(v_name).(o_name)(i);
                else
                    time_tmp = s.(t_name);
                end
                
                s.(v_name).(o_name) = interp1(time_tmp,s.(v_name).(o_name)',t_vec,'nearest')';
            end
    end
    %     end
end

s.(t_name) = t_vec;

% -- interp_struc_cyl
% like previous excep designed to work for the cylinder part of
% fv_calibrate_points IT IS EXPECTED THAT THIS WILL GET OVERHAULED WITH
% FVCYLINDER2

function s = interp_struc_cyl(s,t_vec,variables,t_name)
nv = length(variables);
for aa = 1:nv
    v_name = variables{aa};
    % remove the repeated timesteps
    if length(s.(t_name)) ~= length(unique(s.(t_name)));
        [time_tmp,i,~] = unique(s.(t_name));
        s.(v_name) = s.(v_name)(:,i);
    else
        time_tmp = s.(t_name);
    end
    
    s.(v_name) = interp1(time_tmp,s.(v_name)',t_vec,'nearest')';
end
s.(t_name) = t_vec;

% -- populate_data
% used when fvcylinder is called with no variable inputs, ie when all the
% data to be plotted features as fields in the input stucture
% inputs
%   IN  = input structure
%   OUT = output structure
%   var = cell array of variables
%   i = index into 2nd dimension (time)
% outputs
%   OUT = output structure ready for fvcylinder
function OUT = populate_data(IN,OUT,var,i)
if size(IN.zcell,2) > 1
    OUT.z_dat = IN.zcell(:,i);
else
    OUT.z_dat = IN.zcell(:);
end
OUT.x_dat = IN.V_x(:,i);
OUT.y_dat = IN.V_y(:,i);
if isfield(IN,'W')
    OUT.w_dat = IN.W(:,i);
else
    var = cat(1,'W',var);
    OUT.w_dat = zeros(size(OUT.x_dat));
end
windme = false;  % SORT THIS OUT

if ismember('W10_x',var) & ismember('W10_y',var)
    if isfield(IN,{'W10_x';'W10_y'}) % data structure usually would not have wind fields
        windme = true;
        OUT.wx_dat = IN.W10_x(i);
        OUT.wy_dat = IN.W10_y(i);
    else
        windme = false;
    end
end

if windme
    v_name = setxor(var,{'zcell';'V_x';'V_y';'W';'W10_x';'W10_y'});
else
    %     v_name = setxor(var,{'zcell';'V_x';'V_y';'W'});
    v_name = setxor(var,{'zcell';'V_x';'V_y'}); % INCLUSION OF W IN CYCLINDERS HAS BEEN DROPPED
end
if ~isempty(v_name)
    if isfield(IN,v_name) % DAT not likely to have the scalar variable
        OUT.s_dat = IN.(char(v_name))(:,i);
    end
end

% -- populate_specs
% used to populate the structure inputted into fvcylinder with the fields
% used to determine how the cylinder plot is to appear
% transfers fields from IN to OUT
% inputs
%   IN  = input structure
% outputs
%   OUT = output structure ready for fvcylinder
function OUT = populate_specs(IN)
names = fieldnames(IN);
nn = length(names);
for aa = 1:nn
    f_name = names{aa};
    OUT.(f_name) = IN.(f_name);
end






