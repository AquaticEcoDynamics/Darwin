
clear;close;

f1='great_2015_2017_2_3D_waves.nc';
f2='great_2015_2017_2_3D_nowaves.nc';

vx1=ncread(f1,'V_x');
vx2=ncread(f2,'V_x');

dat = tfv_readnetcdf(f1,'time',1);
timesteps = dat.Time;
t0=datenum('20150103 00:00','yyyymmdd HH:MM');
tt = find(abs(timesteps-t0)==min(abs(timesteps-t0)));
clear dat;

dat = tfv_readnetcdf(f1,'timestep',1);
vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;
faces = dat.cell_node';
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);
cells=dat.idx3(dat.idx3 > 0);

fig=figure(1);
clf;
def.dimensions = [26 14]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  
maxsal=0.1;
        clf;
        
        pos1=[0.05 0.1 0.25 0.8];
        pos2=[0.35 0.1 0.25 0.8];
        pos3=[0.65 0.1 0.25 0.8];

        axes('Position',pos1);
       
        cdata1=squeeze(vx1(cells,tt));
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
        set(gca,'box','on');
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
       % set(gca,'xlim',[370000 385000],'ylim',[6370000 6398000]);
        caxis([0 maxsal]);
        
        cb = colorbar;
                set(cb,'position',[0.9 0.20 0.01 0.4],...
            'units','normalized','ycolor','k');
        axis off;
        axis equal;
        titles='(a) no wave';
                text(0.1,0.90,titles,...
            'Units','Normalized',...
            'Fontname','Times New Roman',...
            'Fontsize',12,...
            'fontweight','Bold',...
            'color','k');
        
axes('Position',pos2);

cdata2=vx2(cells,tt);
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata2);shading flat
        set(gca,'box','on');
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
      %  set(gca,'xlim',[370000 385000],'ylim',[6370000 6398000]);
        caxis([0 maxsal]);
        
       cb = colorbar;
               set(cb,'position',[0.9 0.20 0.01 0.4],...
            'units','normalized','ycolor','k');
        axis off
        axis equal ;
        titles='(b) wave';
                text(0.1,0.90,titles,...
            'Units','Normalized',...
            'Fontname','Times New Roman',...
            'Fontsize',12,...
            'fontweight','Bold',...
            'color','k');

        
axes('Position',pos3);

       cdata=cdata1-cdata2;
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat
        set(gca,'box','on');
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
    %    set(gca,'xlim',[370000 385000],'ylim',[6370000 6398000]);
        caxis([0 maxsal]);
        
        cb = colorbar;
                set(cb,'position',[0.9 0.20 0.01 0.4],...
            'units','normalized','ycolor','k');
        axis off
        axis equal;
        titles='(c) difference';
                text(0.1,0.90,titles,...
            'Units','Normalized',...
            'Fontname','Times New Roman',...
            'Fontsize',12,...
            'fontweight','Bold',...
            'color','k');
        
        
        
        
        img_name =['comparison_',datestr(timesteps(tt),'yyyymmddHHMM'),'.png'];
        
        saveas(gcf,img_name);