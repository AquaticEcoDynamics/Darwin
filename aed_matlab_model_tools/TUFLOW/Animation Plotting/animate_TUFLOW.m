function animate_TUFLOW(conf)

% import conf file
run(conf);

if ~exist(outdir,'dir')
    mkdir(outdir);
end

varname=var1.name;

if create_movie
    sim_name = [outdir,varname,'.mp4'];
    
    hvid = VideoWriter(sim_name,'MPEG-4');
    set(hvid,'Quality',100);
    set(hvid,'FrameRate',12);
    framepar.resolution = [1024,768];
    
    open(hvid);
end
%__________________

% read in data
dat = tfv_readnetcdf(ncfile,'time',1);
timesteps = dat.Time;

dat = tfv_readnetcdf(ncfile,'timestep',1);

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

% define time
first_plot = 1;

ts=find(abs(timesteps-datearray(1))==min(abs(timesteps-datearray(1))));
tf=find(abs(timesteps-datearray(end))==min(abs(timesteps-datearray(end))));

for i = ts:plot_interval:tf
    tdat = tfv_readnetcdf(ncfile,'timestep',i);
    
    if isTop
        if strcmpi(varname,'H') == 0
            cdata = tdat.(varname)(tdat.idx3(tdat.idx3 > 0));
        else
            cdata = tdat.(varname);
        end
    else
        bottom_cells(1:length(tdat.idx3)-1) = tdat.idx3(2:end) - 1;
        bottom_cells(length(tdat.idx3)) = length(tdat.idx3);
        cdata = tdat.(varname)(bottom_cells);
    end
    
    Depth = tdat.D;
    
    if clip_depth < 900
        Depth(Depth < clip_depth) = 0;
        cdata(Depth == 0) = NaN;
    end
    
    if strcmpi(varname,'WQ_TRC_RET') == 1
        cdata = cdata ./ 86400;
    end
    if strcmpi(varname,'WQ_OXY_OXY') == 1
        cdata = cdata .* 32/1000;
    end
    if first_plot
        
        hfig = figure('visible','on','position',[304         166        1271         812]);
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 20.32 15.24])
        
        axes('position',[0 0 1 1]);
        
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat
        set(gca,'box','on');
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
        
        caxis(var1.caxis);
        colormap(flipud(jet));
        cb = colorbar;
        
        set(cb,'position',[0.9 0.1 0.01 0.25],...
            'units','normalized','ycolor','k');
        
        colorTitleHandle = get(cb,'Title');
        
        axis off
        axis equal
        
        text(0.1,0.9,regexprep(varname,'_',' '),...
            'Units','Normalized',...
            'Fontname','Candara',...
            'Fontsize',16,...
            'fontweight','Bold',...
            'color','k');
        
        txtDate = text(0.1,0.1,datestr(timesteps(i),'dd mmm yyyy HH:MM'),...
            'Units','Normalized',...
            'Fontname','Candara',...
            'Fontsize',21,...
            'color','k');
        
        first_plot = 0;
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635                      6.35                     20.32                     15.24])
    else
        
        set(patFig,'Cdata',cdata);
        drawnow;
        set(txtDate,'String',datestr(timesteps(i),'dd mmm yyyy HH:MM'));
        caxis(var1.caxis);
        
    end
    
    if create_movie
        writeVideo(hvid,getframe(hfig));
    end
    
    if save_images
        
        img_dir = [outdir,varname,'/'];
        if ~exist(img_dir,'dir')
            mkdir(img_dir);
        end
        img_name =[img_dir,datestr(timesteps(i),'yyyymmddHHMM'),'.png'];
        saveas(gcf,img_name);
    end
    clear data cdata
end

if create_movie
    % Close the video object. This is important! The file may not play properly if you don't close it.
    close(hvid);
end

end