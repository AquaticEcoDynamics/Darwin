% FVRES     Define the TUFLOW-FV results class
%
%   FVRES is the supperclass for the following subclasses:
%   FVRES_SHEET & FVRES_CURTAIN
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014


classdef (CaseInsensitiveProperties = true) fvres < hgsetget
    
    properties (SetAccess = immutable)
        Resfil
        TimeVector
    end
    properties (SetAccess = private)
        TimeStep
    end
    properties
        Geofil
        Variables
    end
    properties (Dependent = true)
        TimeCurrent    % not necessarily exactly the same as the control object
        Expression
    end
    properties (Dependent = true, Hidden)
        ResultsCustom = struct();
    end
    properties (Hidden)
        Feed = false % true | {false} whether customized results, processed outside of the fvres object, have been fed back in
        Nci
        CustomObj    % fvcustom object created by fvcustom.m
        WORK
        WORK_C2N      % at the moment just for fv_cell2node but could be also be used for other things
    end
    events (ListenAccess = 'public')
        update_patches
    end
    methods
        % // constructor method //
        function obj = fvres(resfil)
            % -- netcdf file identifyer/s
            if ~iscell(resfil)
                resfil = {resfil};
            end
            nm = length(resfil);
            for aa = 1:nm
                if exist(resfil{aa},'file')
                    obj.Resfil{aa} = resfil{aa};
                    obj.Nci(aa) = netcdf.open(resfil{aa});
                else
                    error(['unable to locate ' resfil{aa}])
                end
            end
            % -- time vector/s
            obj.TimeVector = struct();
            for aa = 1:nm
                m_name = ['M' num2str(aa)];
                TMP = netcdf_get_var(obj.Nci(aa),'names',{'ResTime'});
                obj.TimeVector.(m_name) = convtime(TMP.ResTime);
                obj.TimeStep(aa) = 1;
            end
            % -- structure for workhorse function
            obj.WORK = struct();
            obj.WORK.refresh = true;
            obj.WORK_C2N = obj.WORK;
            % -- empty customized results object
            obj.CustomObj = fvcustom;
        end
        % // set methods //
        function set.TimeCurrent(obj,val)
            for aa = 1:length(obj.Resfil)
                m_name = ['M' num2str(aa)];
                if val > obj.TimeVector.(m_name)(end)
                    display(['current time extends beyond results in ' obj.Resfil{aa}]) % perhaps trigger an event so patch object disapears / fades
                    obj.TimeStep(aa) = length(obj.TimeVector.(m_name));
                elseif val < obj.TimeVector.(m_name)(1)
                    display(['current time extends beyond results in ' obj.Resfil{aa}])
                    obj.TimeStep(aa) = 1;
                else
                    dt = abs(obj.TimeVector.(m_name) - val);
                    i = find(dt == min(dt),1,'first');
                    obj.TimeStep(aa) = i;
                end
            end
            %                 if ~isempty(obj.variables) % fvres_sheet objects are sometimes only used to plot the bathy and responding to time updates is not necessary.
            %                     workhorse(obj);
            %                 end
            if obj.Feed
                set(obj.CustomObj,'TimeStep',obj.TimeStep)
            end
            workhorse(obj)
        end
        function set.Variables(obj,val)
            tmp = fv_variables(val);
            [var_unlim,~] = netcdf_variables_unlimited(obj.Nci);
            i = find(~ismember(tmp,var_unlim));
            if ~isempty(i)
                error(['variable ' tmp{i(1)} ' not found in TUFLOW-FV results file'])
            end
            obj.Variables = tmp;
            obj.Feed = false;
            obj.WORK.refresh = true;
            obj.WORK_C2N.refresh = true;
            workhorse(obj);
        end
        function set.Expression(obj,val)
            delete(obj.CustomObj)
            obj.CustomObj = fvcustom(obj.Nci,val);
            set(obj.CustomObj,'TimeStep',obj.TimeStep);
            obj.Feed = true;
            obj.WORK.refresh = true;
            obj.WORK_C2N.refresh = true;
            workhorse(obj);
        end
        % // get methods //
        function val = get.TimeCurrent(obj)
            for aa = 1:length(obj.Resfil)
                m_name = ['M' num2str(aa)];
                val(aa) = obj.TimeVector.(m_name)(obj.TimeStep(aa));
            end
        end
        function val = get.Variables(obj)
            if obj.Feed
                val = {};
            else
                val = obj.Variables;
            end
        end
        function val = get.Expression(obj)
            if obj.Feed
                val = get(obj.CustomObj,'Expression');
            else
                val = {};
            end
        end
        function val = get.ResultsCustom(obj)
            val = get(obj.CustomObj,'ResultsCustom');
        end
        % // retrieve & process the model results //
        function workhorse(obj)
            % obj.notify('update_patches') is called from workhorse functions (overridden)
        end
        % // class destructor //
        function delete(obj)
            for aa = 1:length(obj.Nci)
                try
                    netcdf.close(obj.Nci(aa))
                catch
                end
            end
        end
    end
end