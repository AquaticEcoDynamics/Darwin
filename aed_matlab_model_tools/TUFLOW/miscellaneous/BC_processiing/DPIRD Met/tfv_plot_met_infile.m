function tfv_plot_met_infile(metfile,rainfile,plotname)

%addpath(genpath('Functions'));

% Example of using axes to have multiple plots on the one page
% The format of the position function is [startX startY length height])
% So [0.05 0.05 0.4 0.2] will start from the bottom right corner (Y is
% measured from the bottome, X from the left) and go for 40% of the length
% in the X axis, and 30% of the height in the Y axis

metfile = metfile;
rainfile = rainfile;

savename = plotname;


data = tfv_readBCfile(metfile);
data_rain = tfv_readBCfile(rainfile);

tt = find(data_rain.ISOTime >= min(data.ISOTime) & data_rain.ISOTime <= max(data.ISOTime));

rain.Date = data_rain.ISOTime(tt);
rain.Data = data_rain.Precip(tt);

% Monthly rain calc
rainvec = datevec(rain.Date);

u_years = unique(rainvec(:,1));
u_months = unique(rainvec(:,2));
inc = 1;
for i = 1:length(u_years)
    for j = 1:length(u_months)
        ss = find(rainvec(:,1) == u_years(i) & rainvec(:,2) == u_months(j));
        if ~isempty(ss)
            monthly_rain(inc,1) = sum(rain.Data(ss));
            monthly_date(inc,1) = datenum(u_years(i),u_months(j),1);
            inc = inc + 1;
        end
    end
end


firstdate = min(data.ISOTime);
lastdate = max(data.ISOTime);

%%

figure;
text(0.6,0.3,'WD = (180 / pi) * atan2(-Wx,-Wy)','fontsize',12,'fontweight','bold');
axis off
axes('position',[0.075 0.85 0.825 0.10]);
% Plot stuff here

xdata = data.ISOTime;
ydata = data.Atemp;
opts.xlabel = 'Date';
opts.ylabel = 'Temperature (deg C)';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);


axes('position',[0.075 0.72 0.825 0.10]);
% Plot stuff here
%xdata = met.Date(tt);
ydata = data.Rel_Hum;
opts . xlabel = 'Date';
opts.ylabel = 'Relative Humidity %';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);

axes('position',[0.075 0.60 0.825 0.10]);
% Plot stuff here
ydata = data.Sol_Rad;
opts . xlabel = 'Date';
opts.ylabel = 'Solar Radiation (W)';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24),'r','LineWidth',1);

axes('position',[0.075 0.48 0.825 0.10]);
% Plot stuff here
ydata = data.Clouds;
opts . xlabel = 'Date';
opts.ylabel = 'Cloud Cover';
opts.title = [];
opts.xlim = [firstdate lastdate];

plotbb(xdata,ydata,opts);hold on
plot(xdata,smooth(ydata,24),'r','LineWidth',1);

axes('position',[0.075 0.075 0.4 0.3]);
% Plot stuff here

%xdata = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
xdata = monthly_date;
ydata = monthly_rain;
total_rain = ['Total Rainfall = ',num2str(sum(monthly_rain)),'m'];
bar(xdata,ydata,0.4);
ylabel('Rainfall(mm)');
xlabel('Date');
xlim([min(xdata)-5 max(xdata)+5]);
title(total_rain);

xtik = get(gca,'XTick');
set(gca,'XTick',xtik,'XTickLabel',datestr(xtik,'mm-yy'));

% plotbb(xdata,ydata,opts);hold on
% plot(xdata,smooth(ydata,24*7),'r','LineWidth',1);

theax = axes('position',[0.5 0 0.4 0.4]);
axis(theax,'off');
x = 0.5;
y = 0.5;
width = 60;

testax = gca;

WD = (180 / pi) * atan2(-1*data.Wx,-1*data.Wy);
WS = sqrt(power(data.Wx,2) + power(data.Wy,2));
 
%wind_rose(WD,WS,'cmap',bone,'ax',[theax x y width]);
wind_rose(WD,WS,'parent',theax);
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





%print(gcf,'-dpng',savename,'-zbuffer');
saveas(gcf,savename,'png')
% filename = [dirname,'MyFile.txt');
%
% fid = fopen(filename,'wt');

close all;

