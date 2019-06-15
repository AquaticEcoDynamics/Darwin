
function plot_glm_csv_file(conf)

addpath(genpath('configs'));
addpath(genpath('../glmFunctions'));
run(conf);   % read in configuration file

data=tfv_readGLMfile(csvfile);

figure(1);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  ;

plot(data.Date,data.(var1.name),'k');

hl=legend(var1.Label);
set(hl,'Location',var1.legend_location,'FontSize',fs-2);
title(var1.Label,'FontWeight','bold');

set(gca,'xtick',datearray,'xticklabel',datestr(datearray,'dd/mm/yy'),'fontsize',7);
ylim(var1.caxis);
xlim([datearray(1) datearray(end)]);

xlabel('');
set(gca,'FontSize',fs);

grid on;

print(gcf,'-dpng',image_name,'-opengl');