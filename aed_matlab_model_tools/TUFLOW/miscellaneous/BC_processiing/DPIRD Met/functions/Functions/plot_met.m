clear all; close all;

addpath(genpath('Functions'));

data = tfv_readBCfile('../tfv_met_langhorne_crk_fix_2015.csv');

WS = sqrt(power(data.Wx,2) + power(data.Wy,2));
WD = (180 / pi) * atan2(data.Wy,data.Wx);

wind_rose(WD,WS)