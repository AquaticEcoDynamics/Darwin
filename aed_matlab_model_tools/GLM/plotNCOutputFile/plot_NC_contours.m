function plot_NC_contours(conf)
% A very simple plot to veiw 3 variables, across 6 axis. Doesn't require
% any other functions.

% User input required below.....

addpath(genpath('configs'));
addpath(genpath('../glmFunctions'));
run(conf);   % read in configuration file

% End of User Input_______________________________________________________


% Loading the external data;



% Shouldn't need to change anything under here...

fig = figure('DefaultAxesFontSize',7);

% Load Variable 1 (Top plot).

%[data,XX,YY,ZZ,mTime,surf,bot] = glm_exportdata(ncfile,var1.name,surface_range,bottom_range);

data = readGLMnetcdf(ncfile,var1.name);
mod_nd=depth_range(1):0.1:depth_range(2);
mod_temp=zeros(length(data.time),length(mod_nd));

for ii=1:length(data.time)
    ddtmp=data.z(ii,:);
    tttmp=data.temp(ii,:);
    
    newtmp=interp1(ddtmp(1:data.NS(ii)),tttmp(1:data.NS(ii)),mod_nd);
    mod_temp(ii,:)=newtmp;
end

%axes('position',[0.05 0.65 0.4 0.25]); % Top Left

pcolor(data.time,mod_nd,mod_temp');shading flat;
caxis(var1.caxis);
title(var1.Label,'fontsize',7,'fontweight','bold');
cb = colorbar;
%set(cb,'position',[0.46 0.65 0.01 0.25]);
set(gca,'xtick',datearray,'xticklabel',datestr(datearray,'dd/mm/yy'),'fontsize',7);
xlim([datearray(1) datearray(end)]);
ylabel('depth (m)','fontsize',7);

print(gcf,'-dpng',image_name,'-opengl');
end