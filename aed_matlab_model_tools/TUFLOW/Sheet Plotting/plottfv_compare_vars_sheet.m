
%% a quick simple plot to compare two bottom sheet

clear;close;

f1='Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\drr_tuflow.nc';
f2='Z:\Peisheng\Darwin\MRR_TUFLOW_v5_benthos_overflow\output\mrr_swan_tuflow_vc.nc';

vx1=ncread(f1,'TEMP');
vx2=ncread(f2,'TEMP');


dat1 = tfv_readnetcdf(f1,'time',1);
timesteps1 = dat1.Time;
t0=datenum('20120201 12:00','yyyymmdd HH:MM');
tt1 = find(abs(timesteps1-t0)==min(abs(timesteps1-t0)));
clear dat;

dat1 = tfv_readnetcdf(f1,'timestep',1);
vert1(:,1) = dat1.node_X;
vert1(:,2) = dat1.node_Y;
faces1 = dat1.cell_node';
faces1(faces1(:,4)== 0,4) = faces1(faces1(:,4)== 0,1);
%cells=dat.idx3(dat.idx3 > 0);
cells1(1:length(dat1.idx3)-1) = dat1.idx3(2:end) - 1;
cells1(length(dat1.idx3)) = length(dat1.idx2);

dat2 = tfv_readnetcdf(f2,'time',1);
timesteps2 = dat2.Time;
t0=datenum('20120201 12:00','yyyymmdd HH:MM');
tt2 = find(abs(timesteps2-t0)==min(abs(timesteps2-t0)));
clear dat;

dat2 = tfv_readnetcdf(f2,'timestep',1);
vert2(:,1) = dat2.node_X;
vert2(:,2) = dat2.node_Y;
faces2 = dat2.cell_node';
faces2(faces2(:,4)== 0,4) = faces2(faces2(:,4)== 0,1);
%cells=dat.idx3(dat.idx3 > 0);
cells2(1:length(dat2.idx3)-1) = dat2.idx3(2:end) - 1;
cells2(length(dat2.idx3)) = length(dat2.idx2);

fig=figure(1);
clf;
def.dimensions = [30 12]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])
maxsal=50;
clf;

pos1=[0.05 0.1 0.45 0.8];
pos2=[0.55 0.1 0.45 0.8];


axes('Position',pos1);

cdata1=squeeze(vx1(cells1,tt1));
patFig = patch('faces',faces1,'vertices',vert1,'FaceVertexCData',cdata1);shading flat
set(gca,'box','on');

set(findobj(gca,'type','surface'),...
    'FaceLighting','phong',...
    'AmbientStrength',.3,'DiffuseStrength',.8,...
    'SpecularStrength',.9,'SpecularExponent',25,...
    'BackFaceLighting','unlit');
% set(gca,'xlim',[370000 385000],'ylim',[6370000 6398000]);
caxis([0 maxsal]);

cb = colorbar;
axis off;
axis equal;
titles='(a) DRR';
text(0.1,0.90,titles,...
    'Units','Normalized',...
    'Fontname','Times New Roman',...
    'Fontsize',12,...
    'fontweight','Bold',...
    'color','k');

axes('Position',pos2);

cdata2=vx2(cells2,tt2);
patFig = patch('faces',faces2,'vertices',vert2,'FaceVertexCData',cdata2);shading flat
set(gca,'box','on');

set(findobj(gca,'type','surface'),...
    'FaceLighting','phong',...
    'AmbientStrength',.3,'DiffuseStrength',.8,...
    'SpecularStrength',.9,'SpecularExponent',25,...
    'BackFaceLighting','unlit');
%  set(gca,'xlim',[370000 385000],'ylim',[6370000 6398000]);
caxis([0 maxsal]);

cb = colorbar;
axis off
axis equal ;
titles='(b) MRR';
text(0.1,0.90,titles,...
    'Units','Normalized',...
    'Fontname','Times New Roman',...
    'Fontsize',12,...
    'fontweight','Bold',...
    'color','k');

img_name =['compare.png'];

saveas(gcf,img_name);