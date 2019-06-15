% /////// myline ///////
% Interactively draw a line on specified axes
% The start of the line is marked with an 'o' marker
% To start drawing left click, to end drawing the line right click
% JN August 2014

function [h1,h2] = myline

display('left click to define myline, right click to end it')
inloop = true;
set(gcf,'WindowButtonDownFcn',@wbdcb)
linObj = line('XData',[],'YData',[]);
mrkObj = line('XData',[],'YData',[]);
drawnow
    function wbdcb(src,~)
        if strcmp(get(src,'SelectionType'),'normal')
            set(src,'pointer','circle')
            cp = get(gca,'CurrentPoint');
            xinit = cp(1,1);
            yinit = cp(1,2);
            xdata = get(linObj,'XData');
            ydata = get(linObj,'YData');
            if isempty(xdata)
                mrkObj = line('XData',xinit,'YData',yinit,'Marker','o','color','w','MarkerEdgeColor','k','LineStyle','none');
                linObj = line('XData',xinit,'YData',yinit,'Color','k');
            end
            xdata = [xdata xinit];
            ydata = [ydata yinit];
            set(linObj,'XData',xdata,'YData',ydata)
            set(src,'WindowButtonMotionFcn',@wbmcb)
            set(src,'WindowButtonUpFcn',@wbucb)
        end
        
        function wbmcb(~,~)
            cp = get(gca,'CurrentPoint');
            xtmp = [xdata,cp(1,1)];
            ytmp = [ydata,cp(1,2)];
            set(linObj,'XData',xtmp,'YData',ytmp)
            drawnow
        end
        
        function wbucb(src,~)
            if strcmp(get(src,'SelectionType'),'alt')
                set(src,'Pointer','arrow')
                set(src,'WindowButtonMotionFcn','')
                set(src,'WindowButtonUpFcn','')
                set(src,'WindowButtonDownFcn','')
                inloop = false;
            else
                return
            end
        end
    end

while inloop
    drawnow
    % cycle around
end
h1 = linObj;
h2 = mrkObj;
end



