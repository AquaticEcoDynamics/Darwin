% FVGRAPHICS    initialise TUFLOW-FV model visualisation
%
%   controlObj = fvgraphics() creates a matlab figure where objects used in the
%   visualiation of model results (fvg_sheet, fvg_curtain etc.) can be
%   added. The timestep at which to visualise model results is controlled
%   through the controlObj.
%
%   controlObj = fvgraphics(NumberFiguresPerPage,PaperType,PaperOrientation)
%   creats a figure as per the 3 inputs. The figure created is ready for insertion into word
%   documents producing report quality images. Use print.m to create plots
%   in .png format.
%   
%   The user can scroll through time using the slider bar or by setting the
%   TimeCurrent property with code (See examples)
%
%
%   /-/-/-/-/-/-/-/-/ EXAMPLES /-/-/-/-/-/-/-/-/
%
%   (1): Create a controlObj then create a sheetObj and visualise results at a specific time
%   controlObj = fvgraphics;
%   sheetObj = fvg_sheet(controlObj,'mymodel.nc','variables','H')
%   t = datnum('01/01/2014','dd/mm/yyyy');
%   set(controlObj,'TimeCurrent',t)
%
%   (2): Create a controlObj then a sheetObj and scroll through time
%        using the sliderbar. Display the time corresponding to the results
%        in the axes title.
%   controlObj = fvgraphics;
%   sheetObj = fvg_sheet(controlObj,'mymodel.nc','variables','H','TitleTime','on')
%
%
%   /-/-/-/-/-/-/-/-/ PROPERTIES /-/-/-/-/-/-/-/-/
%
%   Type           ==> fvgraphics
%
%   TimeCurrent    ==> time for which to view model results
%
%   FigureObj      ==> object created by figure.m within which all fvg objects (fvg_sheet, fvg_curtain etc.) are displayed
%
%   SliderObj      ==> object created by uicontrol.m with which the user can interactively set the TimeCurrent property
%
%
% See also FVG_SHEET, FVG_SHEETVEC & FVG_CURTAIN
%
% http://tuflow.com/fvforum/index.php?/forum/16-matlab/
% http://fvwiki.tuflow.com/index.php?title=MATLAB_TUTORIAL
%
% Jesper Nielsen, Copyright (C) BMTWBM 2014

classdef (CaseInsensitiveProperties = true) fvgraphics < hgsetget
    properties (Constant)
        Type = 'fvgcontrol'
    end
    properties
        TimeCurrent
    end
    properties (SetAccess = protected)
        FigureObj
        SliderObj
    end
    properties (Dependent, Hidden)
        TimeSlider
    end
    properties (Hidden = true)
        axes_update
        fvgObj
    end
    events (ListenAccess = 'public')
        update_vectors
        update_timestep
    end
    
    methods
        % // constructor method //
        function obj = fvgraphics(varg1,varg2,varg3)
            if nargin == 0
                obj.FigureObj = figure;
            elseif nargin == 3
                obj.FigureObj = myfigure(varg1,'PaperType',varg2,'PaperOrientation',varg3);
            else
                error('expecting 0 or 3 inputs')
            end
            set(obj.FigureObj,'toolbar','figure')
            obj.SliderObj = uicontrol('Style','slider','Min',-2,'Max',-1,'Value',-1,'parent',obj.FigureObj,'callback',{@notify_timestep,obj});
            set(obj.SliderObj,'Units','centimeters','position',[0.25 0.25 4.5 0.45])
            set(obj.FigureObj,'ResizeFcn',{@notify_vectors,obj})
            %             else
            %                 obj.FigureObj = f; % recreating a saved version
            %             end
            h_pan = pan(obj.FigureObj);
            h_zom = zoom(obj.FigureObj);
            set(h_pan,'ActionPostCallback',{@notify_vectors,obj})
            set(h_zom,'ActionPostCallback',{@notify_vectors,obj})
            % create the gcfvo
            evalin('base','global gcfvo; gcfvo = [];')
        end
        
        % // set methods //
        function set.TimeCurrent(obj,val)
            notify(obj,'update_timestep',EventData_timestep(val))
            obj.TimeCurrent = val;
        end
        function set.axes_update(obj,val)
            obj.axes_update = val;
            obj.notify('update_vectors')
        end
        function set.fvgObj(obj,val)
            obj.fvgObj{end+1} = val;
        end
        function set.TimeSlider(obj,val)
            m_names = fieldnames(val);
            nm = length(m_names);
            for aa = 1:nm
                m_name = m_names{aa};
                t_tmp = val.(m_name);
                if length(t_tmp) == 1 % model crahed on first timestep
                    t_tmp(2) = t_tmp(1) + 1;
                end
                t_min = get(obj.SliderObj,'min');
                t_max = get(obj.SliderObj,'max');
                t_now = get(obj.SliderObj,'value');
                tmp = get(obj.SliderObj,'SliderStep');
                dt = tmp(1)*(t_max-t_min);
                dt_new = mean(diff(t_tmp));
                if t_min == -2
                    t_min = min(t_tmp);
                    t_max = max(t_tmp);
                    dt = dt_new;
                else
                    t_min = min(min(t_tmp),t_min);
                    t_max = max(max(t_tmp),t_max);
                    dt = min(dt_new,dt);
                end
                st = dt/(t_max-t_min);
                t_new = t_min:dt:t_max;
                if isempty(t_now)
                    t_now = t_min;
                else
                    dt = abs(t_new-t_now);
                    i = find(dt == min(dt),1,'first');
                    t_now = t_new(i);
                end
                set(obj.SliderObj,'min',t_min,'max',t_max,'value',t_now,'SliderStep',[st 10*st])
            end
            if isempty(obj.TimeCurrent) % TimeCurrent has not yet been set, ie. the slider has not been moved
                set(obj,'TimeCurrent',t_min)
            end
        end
        
        % // get methods //
        function val = get.TimeSlider(obj)
            t1 = get(obj.SliderObj,'min');
            t2 = get(obj.SliderObj,'max');
            st = get(obj.SliderObj,'SliderStep');
            val = t1:st(1)*(t2-t1):t2;
        end
        
        %         function b = saveobj(obj)
        %         end
    end
    %     methods (Static)
    %         end
    %     end
end

% // callbacks & subfunctions //
function notify_timestep(h_slider,~,fvgobj)
set(fvgobj,'TimeCurrent',get(h_slider,'Value'))
end

function notify_vectors(~,evnt,fvgobj)
if isempty(evnt)
    h = findobj(fvgobj.FigureObj,'Type','Axes','-not','Tag','Colorbar','-not','Tag','Colorbar'); % notify_vectors called after figureRsz
else
    try
    h = evnt.Axes; % notify_vectors called after pan or zoom
    catch
        h = findobj(evnt.Source,'Type','Axes','-not','Tag','Colorbar','-not','Tag','Colorbar');
    end
end
set(fvgobj,'axes_update',h)
% -- jump in here to ensure the relative position of the slider is maintained

end



