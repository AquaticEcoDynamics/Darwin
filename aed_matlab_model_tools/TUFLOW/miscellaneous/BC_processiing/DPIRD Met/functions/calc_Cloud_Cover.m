function Clouds = calc_Cloud_Cover(startdate,enddate,TZ,lat,lon,SP)


SolRad = SP.SolRad;
mDate = SP.mDate;

[GHI ZenithAngle NewDate] = genBirdSolarData(lat,lon,startdate,enddate,TZ);




GHI_Interp = interp1(NewDate,GHI,mDate);
ZenithAngle_Interp = interp1(NewDate,ZenithAngle,mDate);

nn = find(ZenithAngle_Interp <= 90);

k = floor(mDate(nn));

xx = unique(floor(mDate(nn)));



for i = 1:length(xx)
    rr = find(xx(i) == k);
    SunShineHours(i) = length(rr);
    GHI_avg(i) = mean(GHI_Interp(nn(rr)));
end

SunShineHours = interp1(xx,SunShineHours,mDate);



nn = find(isnan(SunShineHours));
SunShineHours(nn) = SunShineHours(nn-1);

GHI_avg = interp1(xx,GHI_avg,mDate);
nn = find(isnan(GHI_avg));
GHI_avg(nn) = GHI_avg(nn-1);


GHI_Interp = interp1(NewDate,GHI,mDate);


for i = 1:length(GHI_Interp)
    if SolRad(i) > GHI_Interp(i)
        SolRad(i) = GHI_Interp(i);
    end
end
plot(mDate,GHI_Interp,'r');hold on;


plot(mDate,SolRad,'k');hold on;

% Conversion of Daily Solar Data into the right units

%Radiation = ((SolRad)./(SunShineHours)).*1000;

Radiation = SolRad;

% plot(NewDate,GHI,'r');hold on
% plot(mDate,Radiation,'k');
% 
% stop


% Get corresponding average TC for each Radiation value. Solving the 
% quadratic.

Cloud_Frac = (Radiation./GHI_avg);

% figure;plot(mDate,GHI_Interp,'r');hold on
% plot(mDate,SolRad,'k');hold on
% 
% GHI_Interp(GHI_Interp < 0) = 0;
% 
% Cloud_Frac = (Radiation./GHI_Interp);

Cloud_Frac(isnan(Cloud_Frac)) = 0;
Cloud_Frac(isinf(Cloud_Frac)) = 0;


mm = find(Cloud_Frac > 0.93);
Cloud_Frac(mm) = 0.93;

mm = find(Cloud_Frac < 0.15);
Cloud_Frac(mm) = 0.15;

for i = 1:length(Cloud_Frac)

    a = 0.66182;
    b = -1.5236;
    c(i) = 0.98475 - Cloud_Frac(i);

    d(i) = sqrt(power(b,2) - 4*a*c(i));
   Daily_Cloud(i) = ( -b - d(i) ) / (2*a);

end

% Interp to get Hourly Cloud
% whos
% Clouds = interp1(mDate,Daily_Cloud,NewDate);
% nn = find(isnan(Clouds));
% Clouds(nn) = min(Clouds);


Clouds = Daily_Cloud;
% for i = 1:length(days)
%     sss = find(mDate == days(i));
%     Clouds(sss) = mean(Daily_Cloud(sss));
% end









%___________________________________________________________________________

function [GHI ZenithAngle NewDate] = genBirdSolarData(lat,lon,startdate,enddate,TZ)

% All calculations are hourly!
%_________________________________________________________________________________________________________
%Inputs
 
%lat = -31.77; % -ve for S & +ve for N
%lon = 116.03; % +ve for E & -ve for W
%TZ = 7.5; %Time Zone +ve for East & -ve for W
% startdate = datenum(2010,06,01,00,00,00); %Specify Start Date
% enddate   = datenum(2011,06,01,00,00,00); %Specify End Date
E = 200; %Station Elevation in m
AP = 973; %Atmospheric Pressure in milibars
Oz = 0.279; %Ozone concentration in atm-cm
WatVap = 1.1; %Total Precipitable water vapor in atm-cm
AOD500 = 0.033; %Dimensionless Aerosol Optical Depth at wavelength 500 nm
AOD380 = 0.038; %Dimensionless Aerosol Optical Depth at wavelength 500 nm
Albedo = 0.2; %Albedo value kept at default
deg2rad = pi/180;

%----------------------------------------------------------------------------------------------------------
%Date Processing

NewDate = [startdate:0.041666666666666666666666667:enddate];
Date_Vec = datevec(NewDate);


%__________________________________________________________________________________________________________
%Calculate Day of Year

n = datenum(Date_Vec(1,1),Date_Vec(1,2),Date_Vec(1,3)) - datenum(Date_Vec(1,1),01,01);
m = datenum(Date_Vec(end,1),Date_Vec(end,2),Date_Vec(end,3)) - datenum(Date_Vec(1,1),Date_Vec(1,2),Date_Vec(1,3));

% non loop method
ni = NewDate' - (datenum(Date_Vec(:,1),01,01)-1);
Day = floor(ni);
mHour = ni - Day;
Hour = mHour*24;


%_____________________________________________________________________________________________________________
%Extra Terrestrial Beam Intensity
%Correction of Earth Sun Distance based on elliptical path of the sun

ETR = 1367*(1.00011+0.034221*cos(2*pi*(Day-1)/365)+0.00128*sin(2*pi*(Day-1)/365)+0.000719*cos(2*(2*pi*(Day-1)/365))+0.000077*sin(2*(2*pi*(Day-1)/365)) );
ETR = transpose(ETR);

%_______________________________________________________________________________________________________________
%Day Angle
%Position of the earth in sun's orbit

Dangle = (6.283185*(Day-1)/365);

%_______________________________________________________________________________________________________________
%Solar Declination
%Function of Day Angle

Dec = (0.006918-0.399912*cos(Dangle)+0.070257*sin(Dangle)-0.006758*cos(2*Dangle) +0.000907*sin(2*Dangle)-0.002697*cos(3*Dangle)+0.00148*sin(3*Dangle))*(180/3.14159);

%________________________________________________________________________________________________________________
%Equation of Time
%Function of Day Angle

EQT = (0.0000075+0.001868*cos(Dangle)-0.032077*sin(Dangle)-0.014615*cos(2*Dangle)-0.040849*sin(2*Dangle))*(229.18);

%_________________________________________________________________________________________________________________
%Hour Angle
%Function of Hour, lon, TZ and EQT

HourAngle = 15.*(Hour-12.5)+(lon)-(TZ).*15+(EQT/4);

%_________________________________________________________________________________________________________________
%Zenith Angle

ZenithAngle = acos(cos(Dec/(180/pi)).*cos(lat/(180/pi)).*cos(HourAngle/(180/pi))+sin(Dec/(180/pi)).*sin(lat/(180/pi))).*(180/pi);

%_________________________________________________________________________________________________________________
%Air Mass

for i = 1:length(ZenithAngle)
    if ZenithAngle(i) < 89

        AirMass(i) = 1/(cos(ZenithAngle(i)/(180/pi))+0.15/(power((93.885-ZenithAngle(i)),1.25)));
    else
        AirMass(i) = 0;
    end
end

%AirMass = transpose(AirMass);

%__________________________________________________________________________________________________________________
%Rayleigh Scattering

for i = 1:length(AirMass)
    
    AMp(i) = (AirMass(i)*AP)/1013;
    if AirMass(i) > 0
        TRayleigh(i) = exp(-0.0903*power(AMp(i),0.84)*(1+AMp(i)-power(AMp(i),1.01)));
    else
        TRayleigh(i) = 0;
    end
end

%TRayleigh = transpose(TRayleigh);

%__________________________________________________________________________________________________________________
%Ozone Scattering

for i = 1:length(AirMass)
    
    Ozm(i) = Oz*AirMass(i);
    if AirMass(i) > 0
        Toz(i) = 1-0.1611*Ozm(i)*power(1.+139.48*Ozm(i),-0.3035)-0.002715*Ozm(i)/(1.+0.044*Ozm(i)+0.0003*power(Ozm(i),2));
    else
        Toz(i) = 0;
    end
end

%Toz = transpose(Toz);

%__________________________________________________________________________________________________________________
%Scattering due to mixed gases
for i = 1:length(AirMass)
    
    if AirMass(i) > 0
        Tm(i) = exp(-0.0127*power(AMp(i),0.26));
    else
        Tm(i) = 0;
    end
end

%Tm = transpose(Tm);

%___________________________________________________________________________________________________________________
%Scattering due to Water Vapor

for i = 1:length(AirMass)
    
    Wm(i) = AirMass(i)*WatVap;
    if AirMass(i) > 0
        Twater(i) = 1-2.4959*Wm(i)/((1.+power(79.034*Wm(i),0.6828))+6.385*Wm(i));
    else
        Twater(i) = 0;
    end
end

%Twater = transpose(Twater);

%___________________________________________________________________________________________________________________
%Scattering due to Aerosols

for i = 1:length(AirMass)
    
    TauA = 0.2758*AOD380 + 0.35*AOD500;
    if AirMass(i) > 0
        Ta(i) = exp((-power(TauA,0.873))*(1.+TauA-(power(TauA,0.7088)))*power(AirMass(i),0.9108));
    else
        Ta(i) = 0;
    end
end

%Ta = transpose(Ta);

%___________________________________________________________________________________________________________________
%TAA

for i = 1:length(AirMass)
    
    if AirMass(i) > 0
        Taa(i) = 1-0.1*(1-AirMass(i)+power(AirMass(i),1.06))*(1-Ta(i));
    else
        Taa(i) = 0;
    end
end

%Taa = transpose(Taa);

%___________________________________________________________________________________________________________________
%rs

for i = 1:length(AirMass)
    
    TAs(i) = Ta(i)/Taa(i);
    if AirMass(i) > 0
        sr(i) = 0.0685+(1-0.84)*(1-TAs(i));
    else
        sr(i) = 0;
    end
end

%rs = transpose(rs);

%____________________________________________________________________________________________________________________
%Direct Beam Radiation (Extra-Terrestrial)

DirectBeam = ETR.*0.9662.*TRayleigh.*Toz.*Tm.*Twater.*Ta;

%_____________________________________________________________________________________________________________________
%Direct Beam Horizontal Radiation

for i = 1:length(ZenithAngle)
    if ZenithAngle(i) < 90
        DirectBeamHz(i) = DirectBeam(i)*cos(ZenithAngle(i)*deg2rad);
    else
        DirectBeamHz(i) = 0;
    end
end

DirectBeamHz = transpose(DirectBeamHz);

%_____________________________________________________________________________________________________________________
% Ias

for i = 1:length(AirMass)
    
    if AirMass(i) > 0
        Ias(i) = (0.79)*ETR(i)*cos(ZenithAngle(i)*deg2rad)*Toz(i)*Tm(i)*Twater(i)*Taa(i)*(0.5*(1-TRayleigh(i))+0.84*(1.-TAs(i)))/(1-AirMass(i)+power(AirMass(i),1.02));
    else
        Ias(i) = 0;
    end
end

Ias = transpose(Ias);

%_____________________________________________________________________________________________________________________
%Global Horizontal Irradiation 

for i = 1:length(AirMass)

    if AirMass(i) > 0
        GHI(i) = (DirectBeamHz(i)+Ias(i))/(1-Albedo*sr(i));
    else
        GHI(i) = 0;
    end
end

GHI = transpose(GHI);

%_____________________________________________________________________________________________________________________
%Diffused Radiation

DiffuseRad = GHI - DirectBeamHz;

%plot(Date,GHI);datetick('x','dd/mm/yy');