% fvg_graphics
% simple script for visualising model results

close all
clear 

% /////// user input ///////

 pat_mod{1} = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\';
 fil_mod{1} = 'drr_tuflow.nc';
% 
 pat_geo = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\input\';


TFV_var = 'WQ_OXY_OXY';
clims = [0 400];

% ////// rock & roll ///////

% tedious formalities
nm = length(fil_mod);
for aa = 1:nm
    modfil{aa} = [pat_mod{aa} fil_mod{aa}];
end
fil_geo = strrep(fil_mod{1},'.nc','_geo.nc');
geofil = [pat_geo fil_geo];

% go for it
fvcobj = fvgraphics(1,'a3','landscape');
set(fvcobj.figureObj,'renderer','zbuffer')

% fvg
ax = myaxes(fvcobj.FigureObj,1,1);
axis(ax(:),'equal')
axis(ax(:),'fill')
set(ax(:),'XTick',[],'YTick',[])
set(ax(:),'XColor','w','YColor','w')
set(ax(:),'Color',[0.5 0.5 0.5])
set(ax(:),'Alimmode','manual')

% colorbar
h_cbar = mycolor(ax(:),[clims 20],'static',false);

% sheet
fvgObj(1) = fvg_sheet(fvcobj,modfil{1},...
    'PeerObj',ax(1),...
    'variables',TFV_var,'TitleTime','on');

% vectors
fvgvObj = fvg_sheetvec(fvcobj,modfil{1},...
    'Variables','V',...
    'PeerObj',ax(1),...
    'VecScale',100,...
    'EdgeColor','k',...
    'FaceColor','k',...
    'VecGrid',20);

set(ax(:),'XLimMode','manual')
% linkaxes(ax(:),'xy')
fvgObj.EdgeColor = 'k';
