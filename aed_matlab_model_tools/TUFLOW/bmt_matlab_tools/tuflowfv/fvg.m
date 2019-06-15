% FVG     Define the TUFLOW-FV graphics class
%
%   FVG is the supperclass for the following subclasses:
%   FVG_SHEET, FVG_SHEETVEC & FVG_CURTAIN
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

classdef fvg < hgsetget
    
    properties (SetAccess = immutable)
        Resfil
        ControlObj
        PatchObj
    end
    properties
        Geofil
        ResObj
        TitleTime = 'off'
        ListObj_up
        ListObj_ut
    end
    properties (Dependent)
        PeerObj
        Variables
        Expression
        FaceColor
        EdgeColor
    end
    properties (Dependent, Hidden)
        tag_axes
        titleObj
    end
    
    methods
        % // constructor method //
        function obj = fvg(controlObj,resfil,fvresObj)
            % -- inputs to properties
            obj.ControlObj = controlObj;
            obj.Resfil = resfil;
            obj.ResObj = fvresObj; % this fires the set method
            % -- create the patches
            obj.PatchObj = patch('XData',[],'YData',[]);
            set(obj.PatchObj,'ButtonDownFcn',@(src,evnt)set_gcfvo(obj,src,evnt))
            set(obj.PatchObj,'DeleteFcn',@(src,evnt)cleanup(obj,src,evnt)) % this will also be fired when figure window ar axes is cleared or closed
            set(obj.PatchObj,'SelectionHighlight','off')
            % -- inform controlObj about new fvg object
            set(obj.ControlObj,'fvgObj',obj)
            % -- ear to the keyhole
            obj.ListObj_ut = addlistener(obj.ControlObj,'update_timestep',@(src,evnt)respond_timestep(obj,src,evnt));
        end
        % // set methods //
        function set.Geofil(obj,val)
            if ~exist(val,'file')
                error(['cannot find ' val ])
            end
            obj.Geofil = val;
            obj.ResObj.Geofil = val;
        end
        function set.ResObj(obj,val)
            delete(obj.ResObj) % this will delete obj.listObj_up
            obj.ResObj = val;
            obj.ListObj_up = addlistener(val,'update_patches',@(src,evnt)respond_patches(obj,src,evnt)); % now listening to a new res2Dobj
            set(obj.ControlObj,'TimeSlider',get(val,'TimeVector')) % tell fvgobj about the potentially new time vector for the time slider
            %             updatepatchdata(obj)
        end
        function set.Variables(obj,val)
            var = fv_variables(val);
            switch obj.Type
                case {'fvg_sheet'} % fvg_curtain will belong here too soon
                    switch obj.Vectors
                        case 'on'
                            var = union(var,{'V_x';'V_y'});
                    end
            end
            set(obj.ResObj,'Variables',var) % setting this will trigger the update_patches event
        end
        function set.PeerObj(obj,val)
            switch obj.TitleTime
                case 'on'
                    set(get(obj.PeerObj,'title'),'string','')
            end
            set(obj.PatchObj,'parent',val)
            tag = get(obj.PeerObj,'Tag');
            if isempty(tag)
                tag = num2str(rand*1E6,'%.0f');
                set(obj.PeerObj,'Tag',tag);
            end
            switch obj.Type
                case {'fvg_sheet'} % fvg_curtain will belong here too soon
                    if strcmpi(obj.Vectors,'on')
                        set(obj.VectorObj,'PeerObj',val)
                    end
            end
            switch obj.Type
                case {'fvg_sheetvec','fvg_curtainvec'}
                    % obj.listObj_uva.Source = val;
            end
        end
        function set.TitleTime(obj,val)
            switch val
                case 'on'
                    obj.TitleTime = val;
                    updatepatchdata(obj)
                case 'off'
                    obj.TitleTime = val;
                    set(get(obj.PeerObj,'title'),'string','')
                otherwise
                    error('expecting "on" or "off" for property "title_time"')
            end
        end
        function set.Expression(obj,val)
            switch obj.Type
                case 'fvg_sheet' % fvg_curtain will soon be here too
                    if strcmpi(obj.Vectors,'on')
                        display('cannot set Expression property when vectors property is on')
                        return
                    end
                case 'fvg_curtain'
                    display('Expression property not yet supported for curtains')
                    return
            end
            set(obj.ResObj,'Expression',val)
        end
        function set.FaceColor(obj,val)
            if ischar(val)
                switch lower(val)
                    case 'interp'
                        switch obj.Type
                            case 'fvg_sheet'
                                if isempty(obj.Geofil)
                                    error('the property Geofil must 1st be specified when FaceColor is interp')
                                else
                                    set(obj.PatchObj,'FaceColor','interp')
                                    set(obj.ResObj,'OutputType','node') % this will fire updatepatchdata once results have been processed
                                end
                            otherwise
                                error(['interp is not supported for the FaceColor property of ' obj.Type])
                        end
                    case 'flat'
                        set(obj.PatchObj,'FaceColor','flat')
                        switch obj.Type
                            case 'fvg_sheet'
                                set(obj.ResObj,'OutputType','cell') % this will fire updatepatchdata once results have been processed
                            otherwise
                                updatepatchdata(obj)
                        end
                    otherwise
                        set(obj.PatchObj,'FaceColor',val) % when FaceColor is 'none' for fvg_sheet or fvg_curtain you are just looking at the cells. If a color then you may be scaling on transparency (ie. visualising a plume)
                end
            else
                set(obj.PatchObj,'FaceColor',val)
            end
        end
        function set.EdgeColor(obj,val)
            set(obj.PatchObj,'EdgeColor',val)
        end
        % // get methods //
        function val = get.PeerObj(obj)
            val = get(obj.PatchObj,'Parent');
        end
        function val = get.Variables(obj)
            tmp = get(obj.ResObj,'Variables');
            if length(tmp) > 2
                switch obj.Type
                    case {'fvg_sheet','fvg_curtain'}
                        tmp = setxor(tmp,{'V_x';'V_y'});
                    case {'fvg_sheetvec','fvg_curtainvec'}
                        tmp = {'V_x';'V_y'};
                end
            end
            val = tmp;
        end
        function val = get.tag_axes(obj)
            tag = get(obj.PeerObj,'Tag');
            if isempty(tag) % patch object has been moved independently ie set(gco,'parent',h_tmp)
                tag = num2str(rand*1E6,'%.0f');
                set(obj.PeerObj,'Tag',tag);
            end
            val = tag;
        end
        function val = get.Expression(obj)
            val = get(obj.ResObj,'Expression');
        end
        function val = get.FaceColor(obj)
            val = get(obj.PatchObj,'FaceColor');
        end
        function val = get.EdgeColor(obj)
            val = get(obj.PatchObj,'EdgeColor');
        end
        % // respond to notifications //
        function respond_timestep(obj,~,evnt)
            set(obj.ResObj,'TimeCurrent',evnt.TimeCurrent)     % send through to resObj which will trigger an event which the fvg is listening out for
        end
        function respond_patches(obj,~,~)
            if isvalid(obj)
                updatepatchdata(obj)
                %  display('deleted object is still trying to respond to notifications') % this if statement should not be necessary
            end
        end
        % // class destrcuctor //
        function delete(obj)
            delfig = get(obj.ControlObj.FigureObj,'BeingDeleted');
            switch delfig
                case 'on'
                    set(obj.PatchObj,'DeleteFcn',{}) % avoid calling cleanup
                    if isvalid(obj.ResObj)
                        delete(obj.ResObj)  % closes the nci if it has not already been closed
                    end
                otherwise
                    delpat = get(obj.PatchObj,'BeingDeleted'); % are you deleting obj by deleting the patchObj
                    switch delpat
                        case 'off'
                            set(obj.PatchObj,'DeleteFcn',{})
                            delete(obj.PatchObj); % when you close an fvg you also want to close the patches
                    end
                    display('do you want to keep the resObj? - hit "y" for yes')
                    waitforbuttonpress
                    switch get(obj.ControlObj.FigureObj,'CurrentCharacter')
                        case 'y'
                            display('resObj remains open')
                        otherwise
                            delete(obj.ResObj)
                            display('resObj closed')
                    end
            end
            delete(obj.ListObj_ut) % listener objects are tide to the lifecycle of the source
            delete(obj.ListObj_up)
            if isprop(obj,'ListObj_uvf')
                delete(obj.ListObj_uvf)
            end
        end
        function updatepatchdata(obj) % method is overwritten in the subclasses
        end
    end
end
% // subfunctions //
function set_gcfvo(obj,~,~)
global gcfvo
gcfvo = obj;
end
function cleanup(obj,~,~)
delete(obj)
end