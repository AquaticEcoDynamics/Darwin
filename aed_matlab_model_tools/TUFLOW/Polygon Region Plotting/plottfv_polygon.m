function plottfv_polygon(conf)

addpath(genpath('configs'));
run(conf);   % read in configuration file

isConv = 0;  % unit conversion switch

allvars = tfv_infonetcdf(ncfile(1).name);  % read in model var names

shp = shaperead(polygon_file);   % read in shape file

if ~exist('plotmodel','var')
    plotmodel = 1;
end

if ~exist('depth_range','var')
    depth_range = [1 1000];
end

if exist('plotsite','var')
    shp_t = shp;
    clear shp;
    inc = 1;
    disp('Removing plotting sites');
    for bhb = 1:length(shp_t)
        
        if ismember(shp_t(bhb).Plot_Order,plotsite)
            
            shp(inc) = shp_t(bhb);
            inc = inc + 1;
        end
    end
end

% define range plot colors
col_pal = [[255 195 77]./255;[255 159 0]./255;[255 129 0]./255];
col_pal_bottom = [[0.8 0.8 0.8];[0.5 0.5 0.5];[0.3 0.3 0.3]];


% Load Field Data and Get site names
field = load(['matfiles/',fielddata,'.mat']);
fdata = field.(fielddata);
sitenames = fieldnames(fdata);

for i = 1:length(sitenames)
    vars = fieldnames(fdata.(sitenames{i}));
    X(i) = fdata.(sitenames{i}).(vars{1}).X;
    Y(i) = fdata.(sitenames{i}).(vars{1}).Y;
end

% Load Model Data
for mod = 1:length(ncfile)
    tdata = tfv_readnetcdf(ncfile(mod).name,'timestep',1);
    all_cells(mod).X = double(tdata.cell_X);
    all_cells(mod).Y = double(tdata.cell_Y);
    
    ttdata = tfv_readnetcdf(ncfile(mod).name,'names','D');
    d_data(mod).D = ttdata.D;
end

clear ttdata

for var = 1:length(varname)
    
    savedir = [outputdirectory,varname{var},'/'];
    if ~exist(savedir,'dir')
        mkdir(savedir);
        mkdir([savedir,'eps/']);
    end
    
    for mod = 1:length(ncfile)
        disp(['Loading Model ',num2str(mod)]);
        loadname = varname{var};
        disp(['    Loading variable ',loadname]);
        switch varname{var} % process vars otherthan standard model outputs
            
            case 'V'  % total velocity
                vel = tfv_readnetcdf(ncfile(mod).name,'names',{'V_x';'V_y'});
                raw(mod).data.V = sqrt(power(vel.V_x,2) + power(vel.V_y,2));
                clear tra oxy
                
            case 'ON' % organic nitrogen
                DON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DON'});
                PON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_PON'});
                raw(mod).data.ON = DON.WQ_OGM_DON + PON.WQ_OGM_PON;
                clear DON PON
                
            case 'TN' % total nitrogen
                NIT =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_NIT_NIT'});
                AMM =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_NIT_AMM'});
                DON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DON'});
                PON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_PON'});
                raw(mod).data.TN = DON.WQ_OGM_DON + PON.WQ_OGM_PON + NIT.WQ_NIT_NIT + AMM.WQ_NIT_AMM;
                clear TN AMM NIT
                
            case 'OP' % organic phosphorus
                DON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DOP'});
                PON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_POP'});
                raw(mod).data.OP = DON.WQ_OGM_DOP + PON.WQ_OGM_POP;
                clear TP FRP
                
            case 'WQ_OGM_DON' % dissolved organic nitrogen to include DONR
                DON =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DON'});
                if sum(strcmpi(allvars,'WQ_OGM_DONR')) > 0
                    DONR =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DONR'});
                    raw(mod).data.WQ_OGM_DON = DON.WQ_OGM_DON + DONR.WQ_OGM_DONR;
                else
                    raw(mod).data.WQ_OGM_DON = DON.WQ_OGM_DON;% + DONR.WQ_OGM_DONR;
                    
                end
                clear DON DONR
                
            case 'WQ_OGM_DOC' % dissolved organic carbon to include DOCR
                DOC =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DOC'});
                if sum(strcmpi(allvars,'WQ_OGM_DOCR')) > 0
                    DOCR =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DOCR'});
                    raw(mod).data.WQ_OGM_DOC = DOC.WQ_OGM_DOC + DOCR.WQ_OGM_DOCR;
                else
                    raw(mod).data.WQ_OGM_DOC = DOC.WQ_OGM_DOC;% + DOCR.WQ_OGM_DOCR;
                end
                clear DOC DOCR
                
            case 'WQ_OGM_DOP' % dissolved organic phosphorus to include DOPR
                DOP =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DOP'});
                if sum(strcmpi(allvars,'WQ_OGM_DOPR')) > 0
                    DOPR =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_DOPR'});
                    raw(mod).data.WQ_OGM_DOP = DOP.WQ_OGM_DOP + DOPR.WQ_OGM_DOPR;
                else
                    raw(mod).data.WQ_OGM_DOP = DOP.WQ_OGM_DOP;% + DOPR.WQ_OGM_DOPR;
                end
                clear DOP DOPR
                
            case 'TURB'  % turbidity
                SS1 =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_TRC_SS1'});
                POC =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_OGM_POC'});
                GRN =  tfv_readnetcdf(ncfile(mod).name,'names',{'WQ_PHY_GRN'});
                raw(mod).data.TURB = (SS1.WQ_TRC_SS1 .* 2.356)  + (GRN.WQ_PHY_GRN .* 0.1) + (POC.WQ_OGM_POC / 83.333333 .* 0.1);
                clear TP FRP
                sites = fieldnames(fdata);
                for bdb = 1:length(sites)
                    if isfield(fdata.(sites{bdb}),'WQ_DIAG_TOT_TURBIDITY')
                        fdata.(sites{bdb}).TURB = fdata.(sites{bdb}).WQ_DIAG_TOT_TURBIDITY;
                    end
                end
                
            otherwise
                raw(mod).data = tfv_readnetcdf(ncfile(mod).name,'names',{loadname});
        end
    end
    
    % set up y label
    switch varname{var}
        
        case 'WQ_OXY_OXY'
            ylab = 'Oxygen (mg/L)';
        case 'SAL'
            ylab = 'Salinity (psu)';
        case 'TEMP'
            ylab = 'Temperature (C)';
        otherwise
            ylab = '';
    end
    
    % process and plot data in each polygon
    for site = 1:length(shp)
%shp(site).Name='F';shp(site).Plot_Order='001';
        disp(['      Working on shape file ',shp(site).Name,', ', num2str(site),'/',num2str(length(shp))]);
        % isepa = 0;
        % isdewnr = 0;
        
        dimc = [0.9 0.9 0.9]; % dimmest (lightest) color
        pred_lims = [0.05,0.25,0.5,0.75,0.95];
        num_lims = length(pred_lims);
        nn = (num_lims+1)/2;
        
        % leg_inc = 1;
        
        inpol = inpolygon(X,Y,shp(site).X,shp(site).Y);
        
        sss = find(inpol == 1);
        
        % epa_leg = 0;
        % dewnr_leg = 0;
        
        
        for mod = 1:length(ncfile)
            [data(mod),c_units,isConv] = tfv_getmodeldatapolygon(raw(mod).data,ncfile(mod).name,all_cells(mod).X,all_cells(mod).Y,shp(site).X,shp(site).Y,{loadname},d_data(mod).D,depth_range);
            
            for lev = 1:length(plotdepth)
                
                if strcmpi(plotdepth{lev},'surface') == 1
                    if plotmodel
                        if isfield(data,'date')
                            if mod == 1
                                
                                if isRange
                                    %
                                    fig = fillyy(data(mod).date,data(mod).pred_lim_ts(1,:),data(mod).pred_lim_ts(2*nn-1,:),dimc,col_pal(1,:));hold on
                                    set(fig,'DisplayName',[ncfile(mod).legend,' Surface (Range)']);
                                    hold on
                                    
                                    for plim_i=2:(nn-1)
                                        fig2 = fillyy(data(mod).date,data(mod).pred_lim_ts(plim_i,:),data(mod).pred_lim_ts(2*nn-plim_i,:),dimc.*0.9.^(plim_i-1),col_pal(plim_i,:));
                                        set(fig2,'HandleVisibility','off');
                                    end
                                end
                            end
                        end
                    end
                    if mod == 1
                        if ~isempty(sss)
                            fplotw = 0;
                            fplotm = 0;
                            fplots = 0;
                            fplotmu = 0;
                            for j = 1:length(sss)
                                if isfield(fdata.(sitenames{sss(j)}),varname{var})
                                    xdata_t = [];
                                    ydata_t = [];
                                    [xdata_t,ydata_t] = get_field_at_depth(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                    
                                    if ~isempty(xdata_t)
                                        
                                        [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                                        
                                        [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,varname{var});
                                        
                                        if isfield(fdata.(sitenames{sss(j)}).(varname{var}),'Agency')
                                            agency = fdata.(sitenames{sss(j)}).(varname{var}).Agency;
                                        else
                                            agency = 'WIR';
                                        end
                                        
                                        switch agency
                                            case 'WIR'
                                                if fplotw
                                                    fp = plot(xdata_d,ydata_d,'ok','markerfacecolor',[255/255 61/255 9/255] ,'markersize',3,'HandleVisibility','off');hold on
                                                else
                                                    fp = plot(xdata_d,ydata_d,'ok','markerfacecolor',[255/255 61/255 9/255],'markersize',3,'displayname','WIR Surface');hold on
                                                    fplotw = 1;
                                                end
                                                
                                                if plotvalidation
                                                    clear obsData;
                                                    obsData(:,1)=xdata_d;
                                                    obsData(:,2)=ydata_d;
                                                end
                                                
                                            case 'MAFRL'
                                                if fplotm
                                                    fp = plot(xdata_d,ydata_d,'pk','markerfacecolor',[232/255 90/255 24/255],'markersize',2,'HandleVisibility','off');hold on
                                                else
                                                    fp = plot(xdata_d,ydata_d,'pk','markerfacecolor',[232/255 90/255 24/255],'markersize',2,'displayname','MAFRL Surface');hold on
                                                    fplotm = 1;
                                                end
                                            case 'SCU'
                                                if fplots
                                                    fp = plot(xdata_d,ydata_d,'dk','markerfacecolor',[255/255 111/255 4/255],'markersize',4,'HandleVisibility','off');hold on
                                                else
                                                    fp = plot(xdata_d,ydata_d,'dk','markerfacecolor',[255/255 111/255 4/255],'markersize',4,'displayname','SCU Surface');hold on
                                                    fplots = 1;
                                                end
                                            case 'MU'
                                                if fplotmu
                                                    fp = plot(xdata_d,ydata_d,'sk','markerfacecolor',[232/255 90/255 24/255],'markersize',4,'HandleVisibility','off');hold on
                                                else
                                                    fp = plot(xdata_d,ydata_d,'sk','markerfacecolor',[232/255 90/255 24/255],'markersize',4,'displayname','MU Surface');hold on
                                                    fplotmu = 1;
                                                end
                                            otherwise
                                        end
                                        
                                    end
                                end
                                
                            end
                        end
                    end
                    
                    [xdata,ydata] = tfv_averaging(data(mod).date,data(mod).pred_lim_ts(3,:),def);
                    
                    if plotmodel
                        plot(xdata,ydata,'color',ncfile(mod).colour{1},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' Surface (Median)']);hold on
                    end
                    
                    if (plotvalidation && exist('obsData','var'))
                        clear simData MatchedData
                        simData(:,1)=xdata;
                        simData(:,2)=ydata;
                        
                        [~, loc_obs, loc_sim] = intersect(obsData(:,1), simData(:,1));
                        
                        if length(loc_obs)>3
                            MatchedData(:,1) = obsData(loc_obs,2);
                            MatchedData(:,2) = simData(loc_sim,2);
                            
                            stat_mae=mae(obsData,simData);
                            stat_r  =r(obsData,simData);
                            stat_rms=rms(obsData,simData);
                            stat_nash=nashsutcliffe(obsData,simData);
                            
                            save('tmp.mat','obsData', 'simData','stat_mae','stat_r','stat_rms','stat_nash','-mat','-v7.3');
                            
                            hfig=figure(2);
                            set(hfig, 'PaperPositionMode', 'manual');
                            set(hfig, 'PaperUnits', 'centimeters');
                            xSize = def.dimensions(1);
                            ySize = def.dimensions(2);
                            set(gcf,'paperposition',[0 0 xSize ySize]);
                            axes('Position',[0.1 0.1 0.6 0.8]);
                            scatter(obsData(loc_obs,2),simData(loc_sim,2),5,'filled');
                            grid on;box on;
                            axis equal;
                            xlabel('observed');ylabel('modelled');
                            set(gca,'FontSize',5);
                            
                            if istitled
                                title([regexprep(shp(site).Name,'_',' '),' surface'],...
                                    'FontSize',def.titlesize-2,...
                                    'FontWeight','bold');
                            end
                            
                            str{1}=['r = ',num2str(stat_r,'%1.4f')];
                            str{2}=['mae = ',num2str(stat_mae,'%1.4f')];
                            str{3}=['rms = ',num2str(stat_rms,'%1.4f')];
                            str{4}=['nash = ',num2str(stat_nash,'%1.4f')];
                            dim=[0.7 0.1 0.25 0.6];
                            ha=annotation('textbox',dim,'String',str,'FitBoxToText','on');
                            set(ha,'FontSize',5);
                            final_sitename = [sprintf('%04d',shp(site).Plot_Order),'_',shp(site).Name,'_stat_surface.eps'];
                            finalname_p = [savedir,final_sitename];
                            
                            if exist('filetype','var')
                                if strcmpi(filetype,'png')
                                    print(hfig,'-dpng',regexprep(finalname_p,'.eps','.png'),'-opengl');
                                else
                                    saveas(hfig,regexprep(finalname_p,'.eps','.png'));
                                end
                            end
                            clear final_sitename finalname_p obsData simData MatchedData
                            close(hfig);
                        else
                            disp('too few data to do statistics');
                            clear final_sitename finalname_p obsData simData MatchedData
                        end
                        
                    end
                    
                else
                    if isfield(data,'date')
                        if mod == 1
                            %
                            if isRange_Bottom
                                fig = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(1,:),data(mod).pred_lim_ts_b(2*nn-1,:),dimc,col_pal_bottom(1,:));hold on
                                set(fig,'DisplayName',[ncfile(mod).legend,' Bottom (Range)']);
                                hold on
                                
                                for plim_i=2:(nn-1)
                                    fig2 = fillyy(data(mod).date_b,data(mod).pred_lim_ts_b(plim_i,:),data(mod).pred_lim_ts_b(2*nn-plim_i,:),dimc.*0.9.^(plim_i-1),col_pal_bottom(plim_i,:));
                                    set(fig2,'HandleVisibility','off');
                                end
                            end
                        end
                        if mod == 1
                            if ~isempty(sss)
                                fplotw = 0;
                                fplotm = 0;
                                fplots = 0;
                                fplotmu = 0;
                                for j = 1:length(sss)
                                    if isfield(fdata.(sitenames{sss(j)}),varname{var})
                                        xdata_t = [];
                                        ydata_t = [];
                                        
                                        [xdata_t,ydata_t] = get_field_at_depth(fdata.(sitenames{sss(j)}).(varname{var}).Date,fdata.(sitenames{sss(j)}).(varname{var}).Data,fdata.(sitenames{sss(j)}).(varname{var}).Depth,plotdepth{lev});
                                        
                                        if ~isempty(xdata_t)
                                            
                                            [xdata_d,ydata_d] = process_daily(xdata_t,ydata_t);
                                            
                                            [ydata_d,c_units,isConv] = tfv_Unit_Conversion(ydata_d,varname{var});
                                            
                                            if isfield(fdata.(sitenames{sss(j)}).(varname{var}),'Agency')
                                                agency = fdata.(sitenames{sss(j)}).(varname{var}).Agency;
                                            else
                                                agency = 'WIR';
                                            end
                                            
                                            switch agency
                                                case 'WIR'
                                                    if fplotw
                                                        fp = plot(xdata_d,ydata_d,'ok','markerfacecolor','none' ,'markersize',3,'HandleVisibility','off');hold on
                                                    else
                                                        fp = plot(xdata_d,ydata_d,'ok','markerfacecolor','none','markersize',3,'displayname','WIR Bottom');hold on
                                                        fplotw = 1;
                                                    end
                                                    
                                                    if plotvalidation
                                                        clear obsData;
                                                        obsData(:,1)=xdata_d;
                                                        obsData(:,2)=ydata_d;
                                                    end
                                                    
                                                case 'MAFRL'
                                                    if fplotm
                                                        fp = plot(xdata_d,ydata_d,'pk','markerfacecolor','none','markersize',2,'HandleVisibility','off');hold on
                                                    else
                                                        fp = plot(xdata_d,ydata_d,'pk','markerfacecolor','none','markersize',2,'displayname','MAFRL Bottom');hold on
                                                        fplotm = 1;
                                                    end
                                                case 'SCU'
                                                    if fplots
                                                        fp = plot(xdata_d,ydata_d,'dk','markerfacecolor','none','markersize',4,'HandleVisibility','off');hold on
                                                    else
                                                        fp = plot(xdata_d,ydata_d,'dk','markerfacecolor','none','markersize',4,'displayname','SCU Bottom');hold on
                                                        fplots = 1;
                                                    end
                                                case 'MU'
                                                    if fplotmu
                                                        fp = plot(xdata_d,ydata_d,'sk','markerfacecolor','none','markersize',4,'HandleVisibility','off');hold on
                                                    else
                                                        fp = plot(xdata_d,ydata_d,'sk','markerfacecolor','none','markersize',4,'displayname','MU Bottom');hold on
                                                        fplotmu = 1;
                                                    end
                                                otherwise
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        [xdata,ydata] = tfv_averaging(data(mod).date_b,data(mod).pred_lim_ts_b(3,:),def);
                        
                        if plotmodel
                            plot(xdata,ydata,'color',ncfile(mod).colour{lev},'linewidth',0.5,'DisplayName',[ncfile(mod).legend,' Bottom (Median)']);hold on
                        end
                        if (plotvalidation && exist('obsData','var'))
                            clear simData MatchedData
                            simData(:,1)=xdata;
                            simData(:,2)=ydata;
                            
                            [~, loc_obs, loc_sim] = intersect(obsData(:,1), simData(:,1));
                            
                            if length(loc_obs)>3
                                MatchedData(:,1) = obsData(loc_obs,2);
                                MatchedData(:,2) = simData(loc_sim,2);
                                
                                stat_mae=mae(obsData,simData);
                                stat_r  =r(obsData,simData);
                                stat_rms=rms(obsData,simData);
                                stat_nash=nashsutcliffe(obsData,simData);
                                
                                hfig=figure(2);
                                set(hfig, 'PaperPositionMode', 'manual');
                                set(hfig, 'PaperUnits', 'centimeters');
                                xSize = def.dimensions(1);
                                ySize = def.dimensions(2);
                                set(gcf,'paperposition',[0 0 xSize ySize]);
                                axes('Position',[0.1 0.1 0.6 0.8]);
                                scatter(obsData(loc_obs,2),simData(loc_sim,2),5,'filled');
                                grid on;box on;
                                axis equal;
                                xlabel('observed');ylabel('modelled');
                                set(gca,'FontSize',5);
                                
                                if istitled
                                    title([regexprep(shp(site).Name,'_',' '),' bottom'],...
                                        'FontSize',def.titlesize-2,...
                                        'FontWeight','bold');
                                end
                                
                                str{1}=['r = ',num2str(stat_r,'%1.4f')];
                                str{2}=['mae = ',num2str(stat_mae,'%1.4f')];
                                str{3}=['rms = ',num2str(stat_rms,'%1.4f')];
                                str{4}=['nash = ',num2str(stat_nash,'%1.4f')];
                                dim=[0.7 0.1 0.25 0.6];
                                ha=annotation('textbox',dim,'String',str,'FitBoxToText','on');
                                set(ha,'FontSize',5);
                                final_sitename = [sprintf('%04d',shp(site).Plot_Order),'_',shp(site).Name,'_stat_bottom.eps'];
                                finalname_p = [savedir,final_sitename];
                                
                                if exist('filetype','var')
                                    if strcmpi(filetype,'png')
                                        print(hfig,'-dpng',regexprep(finalname_p,'.eps','.png'),'-opengl');
                                    else
                                        saveas(hfig,regexprep(finalname_p,'.eps','.png'));
                                    end
                                end
                                clear final_sitename finalname_p obsData simData MatchedData
                                close(hfig);
                            else
                                disp('too few data to do statistics');
                                clear final_sitename finalname_p obsData simData MatchedData
                            end
                            
                        end
                        
                    end
                end
            end
        end
        
        if isConv
            text(1.02,0.5,[regexprep(loadname,'_',' '),' (',c_units,')'],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'rotation',90,'horizontalalignment','center');
        else
            text(1.02,0.5,[regexprep(loadname,'_',' '),' (model units)'],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'rotation',90,'horizontalalignment','center');
        end
        
        text(0.15,1.02,[num2str(depth_range(1)),'m : ',num2str(depth_range(2)),'m'],'units','normalized','fontsize',5,'color',[0.4 0.4 0.4],'horizontalalignment','center');
        
        xlim([def.datearray(1) def.datearray(end)]);
        if isYlim
            ylim([def.cAxis(var).value]);
        else
            def.cAxis(var).value = get(gca,'ylim');
            def.cAxis(var).value(1) = 0;
            ylim([def.cAxis(var).value]);
        end
        
        if ~custom_datestamp
            set(gca,'Xtick',def.datearray,...
                'XTickLabel',datestr(def.datearray,def.dateformat),...
                'FontSize',def.xlabelsize);
        else
            new_dates = def.datearray  - zero_day;
            new_dates = new_dates - 1;
            
            ttt = find(new_dates >= 0);
            
            
            set(gca,'Xtick',def.datearray(ttt),...
                'XTickLabel',num2str(new_dates(ttt)'),...
                'FontSize',def.xlabelsize);
        end
        
        if isylabel
            ylabel(ylab,'FontSize',def.ylabelsize);
        end
        
        if istitled
            title(regexprep(shp(site).Name,'_',' '),...
                'FontSize',def.titlesize,...
                'FontWeight','bold');
        end
        if exist('islegend','var')
            if islegend
                leg = legend('show');
                set(leg,'location',def.legendlocation,'fontsize',def.legendsize);
            end
        else
            leg = legend('location',def.legendlocation);
            set(leg,'fontsize',def.legendsize);
        end
        
        %--% Paper Size
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        xSize = def.dimensions(1);
        ySize = def.dimensions(2);
        xLeft = (21-xSize)/2;
        yTop = (30-ySize)/2;
        set(gcf,'paperposition',[0 0 xSize ySize])
        
        final_sitename = [sprintf('%04d',shp(site).Plot_Order),'_',shp(site).Name,'.eps'];
        finalname_p = [savedir,final_sitename];
        
        if exist('filetype','var')
            if strcmpi(filetype,'png')
                print(gcf,'-dpng',regexprep(finalname_p,'.eps','.png'),'-opengl');
            else
                saveas(gcf,regexprep(finalname_p,'.eps','.png'));
            end
        else
            saveas(gcf,regexprep(finalname_p,'.eps','.png'));
        end
        
        %tfv_export_conc(regexprep(finalname,'.eps','.csv'),plotdate,plotdata,ncfile);
        
        close all force
        
        clear data
        
    end
end

create_html_for_directory(outputdirectory);
