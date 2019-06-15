
function do_error_calculation(obsData,simData,shp,savedir,def,site)

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
    
    title([regexprep(shp(site).Name,'_',' '),' bottom'],...
            'FontSize',def.titlesize-2,...
            'FontWeight','bold');

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