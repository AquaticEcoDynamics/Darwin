%function axes_plot(firstdate,lastdate)

% Example of using axes to have multiple plots on the one page
% The format of the position function is [startX startY length height])
% So [0.05 0.05 0.4 0.2] will start from the bottom right corner (Y is
% measured from the bottome, X from the left) and go for 40% of the length
% in the X axis, and 30% of the height in the Y axis

%load metdata.mat;
figure;
% firstdate = datenum(2008,01,01,09,00,00);
% lastdate = datenum(2009,01,01,09,00,00);

% site = 'liawenee';
% met = metdata.(site);

tt = find(met.Date >= firstdate & met.Date <= lastdate);
nn = find(met.NewDate >= firstdate & met.NewDate <= lastdate);
kk = find(met.Date_daily >= firstdate & met.Date_daily <= lastdate);


axes('position',[0.075 0.85 0.825 0.10]);
% Plot stuff here

xdata = met.Date(tt);
ydata = met.AirTemperature(tt);
opts.xlabel = 'Date';
opts.ylabel = 'Temperature (deg C)';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);


axes('position',[0.075 0.72 0.825 0.10]);
% Plot stuff here
xdata = met.Date(tt);
ydata = met.RelativeHumidity(tt);
opts . xlabel = 'Date';
opts.ylabel = 'Relative Humidity %';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);

axes('position',[0.075 0.60 0.825 0.10]);
% Plot stuff here
xdata = met.NewDate(nn);
ydata = met.Rad_Model(nn);
opts . xlabel = 'Date';
opts.ylabel = 'Solar Radiation (W)';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24),'r','LineWidth',1);

axes('position',[0.075 0.48 0.825 0.10]);
% Plot stuff here
xdata = met.NewDate(nn);
ydata = met.TC_interp(nn);
opts . xlabel = 'Date';
opts.ylabel = 'Cloud Cover';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24),'r','LineWidth',1);

axes('position',[0.075 0.075 0.4 0.3]);
% Plot stuff here

%xdata = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ydata = met.Rain_monthly';
total_rain = ['Annual Rainfall = ',num2str(sum(met.Rain_monthly)),'mm'];
bar(ydata,0.4);
ylabel('Rainfall(mm)');
xlabel('Month');
xlim([0.5 12.5]);
title(total_rain);
% plotbb(xdata,ydata,opts);hold on
% plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);

theax = axes('position',[0.5 0 0.4 0.4]);
axis(theax,'off');
x = 0.5;
y = 0.5;
width = 60;

testax = gca;

plot_windrose(firstdate,lastdate,site,testax,x,y,width);
%axis off

% 
% axes('position',[0.55 0.55 0.4 0.3]);
% % Plot stuff here

% Fix for the black background problem with the wind_rose.m function
set(gcf,'color','w');
set(gca,'color','w');


set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'centimeters');
    xSize = 20;
    ySize = 29;
    xLeft = (21-xSize)/2;
    yTop = (30-ySize)/2;
    set(gcf,'paperposition',[xLeft yTop xSize ySize])
    %set(gcf,'position',[0.01 0.01 xSize ySize])

   
dirname = [site,' met output/'];

if ~exist(dirname,'dir')
    mkdir(dirname);
end

fname = strcat(datestr(firstdate,'yyyy'),'.png')

savename = [dirname,fname];

%print(gcf,'-dpng',savename,'-zbuffer');
saveas(gcf,savename,'png')
% filename = [dirname,'MyFile.txt');
% 
% fid = fopen(filename,'wt');



