% FVCUSTOM Define the TUFLOW-FV customized results class.
%   FVCUSTOM objects are used by FVRES objects and are manipulated through
%   the Expression property of the FVRES objects. There should be no reason to
%   access and manipulate a fvcustomObj directly.
%   Where more than one results file is specified the operations are
%   performed on the output timestep closest to the "time_current" property in the FVRES object.
%   No interpolation is performed. For this reason it is important that the
%   simulations specified in "Resids" property have near identical output timesteps.
%
%   The '$' symbol can be used to reference a constant defined in the base workspace.
%   The constant which is either a vector of length 1 | NumCells2D | NumCells3D
%   is stored within the fvcustomObj once the Expression property is set
%   and hence any changes to the constant within the base workspace will have no effect on the fvcustomObj.
%
%   If the customized results are later passed through FV_GET_SHEET ie. when
%   FVRES_SHEET is used, the customized results will be assigned NaN in the dry cells.
%   This has implications when customizing bed variables which are independant of the stat variable.
%   To control the stat (which cells are assigned NaN's) use the stamp property in the fvres_sheetObj.
%   If more than 1 results file is used to generate the
%   customized results then the stat from the 1st results file specified is
%   used
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

classdef fvcustom < hgsetget
    
    properties (SetAccess = immutable)
        Resids          % cell array of netcdf file identifyers to TUFLOW-FV cell centred results files
        Expression      % cell array of Expressions, length(Expression) <= 2 (ie. create a customized scalar or vector variable)
    end
    properties (SetAccess = private)
        ResultsCustom  % stucture containing customized results
    end
    properties
        TimeStep
    end
    properties (Hidden)
        fh               % function handle/s (2 handles when creating a customized vector variable)
        VARS = struct()  % structure containing the variables required from each simulation
        TIME = struct()  % structure containing the time vectors from each simulation
        C = struct()     % structure storing raw model results prior to executing the Expression
        nm
        ne
    end
    
    methods
        % // constructor method //
        function obj = fvcustom(Resids,Expression)
            if nargin ~= 0
                % -- check the experession/s
                if iscell(Expression)
                    if length(Expression) > 2
                        error('expecting a cell array of length 1 or 2 (creating a scalar or vector variable) for "Expression" property')
                    end
                else
                    Expression = {Expression};
                end
                obj.ne = length(Expression);
                obj.nm = length(Resids); % NEED A CHECK TO ENSURE CONSISTENCY WITH M1 & M2 etc etc
                obj.Resids = Resids;
                
                k = 0;
                CONST = struct(); % stucture which may end up containing the constants fed into the Expressions
                for aa = 1:obj.ne
                    % -- -- variables referenced in Expression
                    vars = regexp(Expression{aa},'\w*[A-Za-z.$]\w*','match'); % variables always contain letters
                    % -- -- remove functions
                    vars = vars(~ismember(vars,{'sum';'mean';'max';'min';'sin';'sind';'cos';'cosd'}));
                    % -- -- remove constants
                    i = strfind(vars,'$');
                    j = false(length(i),1);
                    for bb = 1:length(i)
                        if ~isempty(i{bb})
                            j(bb) = true;
                        end
                    end
                    constants = strrep(vars(j),'$','');
                    vars = vars(~j);
                    nv = length(vars);
                    % -- -- ensure simulation reference is applied
                    for bb = 1:nv
                        v_name = vars{bb};
                        if isempty(regexp(v_name,'^[M+0-9+.]','once')) % eg M5.
                            if obj.nm == 1
                                vars{bb} = ['M1.' v_name];
                                Expression{aa} = strrep(Expression{aa},v_name,vars{bb});
                            else
                                error('you must use upper case simulation suffixes infront of your variables, refer help doc')
                            end
                        end
                    end
                    % -- -- fuss about the variables
                    for bb = 1:obj.nm
                        [var_unlim, var_aux] = netcdf_variables_unlimited(Resids(bb));
                        vars_all = cat(1,var_unlim,var_aux);
                        m_name = ['M' num2str(bb)];
                        ref = ['M' num2str(bb) '.'];
                        if aa == 1
                            obj.VARS.(m_name) = {};
                        end
                        for cc = 1:nv
                            if ~isempty(strfind(vars{cc},ref)) % is this variable within the Expression applicable for this model
                                v_name = strrep(vars{cc},ref,'');
                                %                                 if strfind(Expression{aa},vars{cc})
                                % -- -- ensure variables exist within respective results files
                                i = strcmpi(v_name,vars_all);
                                if ~any(i)
                                    error(['variable ' v_name ' not found in results file']) % identify which results file
                                else
                                    % -- -- ensure variable names are case consistent between the Expressions and TUFLOW-FV
                                    vars{cc} = [ref vars_all{i}]; % if there is a case insensitive match then there is a match
                                end
                                % -- -- note which variables are needed for the respective simulations
                                obj.VARS.(m_name) = cat(1,obj.VARS.(m_name),v_name); % scalars in this list will be overidden but the vectors won't
                                %                                 end
                            end
                        end
                    end
                    obj.VARS.(m_name) = unique(obj.VARS.(m_name));
                    % -- -- insert the good stuff back into the Expression/s with the mother stucture
                    vars_old = regexp(Expression{aa},'\w*[A-Za-z.$]\w*','match');
                    vars_old = vars_old(~ismember(vars_old,{'sum';'mean';'max';'min'}));
                    i = strfind(vars_old,'$');
                    j = false(length(i),1);
                    for bb = 1:length(i)
                        if ~isempty(i{bb})
                            j(bb) = true;
                        end
                    end
                    vars_old = vars_old(~j);
                    for bb = 1:nv
                        Expression{aa} = strrep(Expression{aa},vars_old{bb},['C.' vars{bb}]);
                    end
                    % -- bring the constants in from the base workspace so they can be stored within the function handle
                    nc = length(constants);
                    for bb = 1:nc
                        k = k+1;
                        c_name = ['c_' num2str(k)];
                        CONST.(c_name) = evalin('base',constants{bb});
                        Expression{aa} = strrep(Expression{aa},['$' constants{bb}],['CONST.' c_name]);
                    end
                end
                % -- When two Expressions, ensure the 1st is for "x" component and 2nd for "y" component.
                % -- ensure only difference between 2 Expressions should be "_x" & "_y"
                if obj.ne == 2
                    i = strfind(Expression,'_x');
                    j = strfind(Expression,'_y');
                    if isempty(i{1})
                        error('when specifiying 2 Expressions the 1st should reflect the "x" component')
                    end
                    if isempty(j{2})
                        error('when specifiying 2 Expressions the 2nd should reflect the "y" component')
                    end
                    if ~isequal(i{1},j{2}) || ~isequal(i{2},j{1})
                        error('the only difference bewteen the 2 Expressions should be the "x" and "y" vector components')
                    end
                end
                % -- create the function handle/s
                for aa = 1:obj.ne
                    %  obj.fh{aa} = str2func(['@(C)',Expression{aa}]);
                    eval(['obj.fh{aa} = @(C)' Expression{aa} ';'])
                end
                % -- initialise the structures for fv_get_var
                for aa = 1:obj.nm
                    m_name = ['M' num2str(aa)];
                    obj.C.(m_name) = struct();
                end
            end
        end
        % // set methods //
        function set.TimeStep(obj,val)
            % -- index into time vectors
            for aa = 1:obj.nm
                % -- load the results
                m_name = ['M' num2str(aa)];
                if ~isempty(obj.VARS.(m_name))
                    obj.C.(m_name) = fv_get_var(obj.C.(m_name),obj.Resids(aa),val(aa),obj.VARS.(m_name));
                end
            end
            % -- call the wonder function built from your Expression to produce the customized results
            if obj.ne == 1
                obj.ResultsCustom.custom = obj.fh{1}(obj.C);
            else
                obj.ResultsCustom.custom_x = obj.fh{1}(obj.C);
                obj.ResultsCustom.custom_y = obj.fh{2}(obj.C);
            end
        end
        % // get methods //
        function val = get.Expression(obj)
            if isempty(obj.ne)
                val = {};
            else
                for aa = 1:obj.ne
                    tmp{aa} = func2str(obj.fh{aa});
                end
                tmp = strrep(tmp,'C.','');
                val = strrep(tmp,'@(C)','');
            end
        end
    end
end
% // sub functions //
