% /////// mycell ///////
% Locate the cell you are interesed in on a fvg_sheet object.
%
% inputs:
%   obj = object created by fvg_sheet
%   ic2 = 2D cell id
%
% Jesper Nielsen, July 2014

function mycell(obj,ic2)
fObj = obj.controlObj.figureObj;
axObj = obj.peerObj;
set(fObj,'CurrentAxes',axObj)

% verticess which make up the nodel mesh
vx_all = get(obj.patchObj,'XData');
vy_all = get(obj.patchObj,'YData');
vx_min = min(vx_all(:));
vx_max = max(vx_all(:));
vy_min = min(vy_all(:));
vy_max = max(vy_all(:));
vx = vx_all(:,ic2);
vy = vy_all(:,ic2);

% patch the cell edges in pink
h(1) = patch('XData',vx,'YData',vy,'parent',axObj,'FaceColor','none','EdgeColor','m');

% plot a marker which will remain the same size when you zoom out and will hence help you locate the potentially very small cell
cc = polycentre(vx,vy);
h(2) = line(cc(1),cc(2),'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','y','parent',axObj);

% zoom out until the entire model domain is in view
% -- how much to zoom out by
xlim = get(axObj,'XLim');
ylim = get(axObj,'YLim');
fx = diff(xlim) / (vx_max-vx_min);
fy = diff(ylim) / (vy_max-vy_min);
f = min(fx,fy);
% -- initially move fast and then slow down as entire model comes into view
a = 1:20;
b  = 2.^a;
c = 1./b;
i = find(cumprod(c) <= f,1,'first');
for aa = 1:i
    zoom(c(aa))
    drawnow
end

% remove the markers
display('hit enter to remove mycell')
pause
delete(h)


