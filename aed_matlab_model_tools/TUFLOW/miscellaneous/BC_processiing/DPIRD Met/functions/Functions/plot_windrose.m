function plot_windrose(firstdate,lastdate,site,theax,x,y,width)

load llmetdata.mat
% 
% startdate = datenum(2006,01,01,09,00,00);
% enddate = datenum(2007,01,01,09,00,00);
% site = 'metro';

met = llmetdata.(site);

tt = find(met.Date >= firstdate & met.Date <= lastdate);

met.WIND = (remove_nans(met.WindSpeed(tt),1))/3.6;
met.DIRN = (remove_nans(met.WindDir(tt),1));

WD = met.DIRN;
WS = met.WIND;
 
%wind_rose(WD,WS,'cmap',bone,'ax',[theax x y width]);
wind_rose(WD,WS,'parent',theax);
%wind_rose(WD,WS,'cmap',bone,'-parent');
    
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'centimeters');
%     xSize = 10;
%     ySize = 10;
%     xLeft = (21-xSize)/2;
%     yTop = (30-ySize)/2;
%     set(gcf,'paperposition',[xLeft yTop xSize ySize])
%     set(gcf,'position',[0.01 0.01 xSize*50 ySize*50]);
    
   % print(gcf,'-depsc2','MetImages/Windrose.eps','-opengl');

