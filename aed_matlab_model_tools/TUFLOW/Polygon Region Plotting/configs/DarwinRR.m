
%% Configuration____________________________________________________________

%----------- add TUFLOW matlab library ------------%
addpath(genpath('tuflowfv')); 

%----------- add field data file in matfiles folder ------------%
fielddata = 'drr'; 

%----------- define variable names to plot ------------%
varname = {... 
% 'H',...
'TEMP',...
'WQ_OXY_OXY',...
'WQ_NIT_AMM',...
'WQ_NIT_NIT',...
'WQ_PHS_FRP',...
'WQ_DIAG_PHY_TCHLA',....
'WQ_DIAG_TOT_TN',...
'WQ_DIAG_TOT_TP',...
% 'WQ_OGM_DOC',...
% 'WQ_OGM_POC',...
% 'WQ_OGM_DON',...
% 'WQ_OGM_PON',...
% 'WQ_OGM_DOP',...
% 'WQ_OGM_POP',...
% 'WQ_OGM_DOCR',...
% 'WQ_OGM_DONR',...
% 'WQ_OGM_DOPR',...
% 'WQ_OGM_CPOM',...
% 'WQ_PHY_GRN',...
% 'WQ_PHY_CRYPT',...
% 'WQ_PHY_DIATOM',...
% 'WQ_PHY_DINO',...
% 'WQ_PHY_DINO_IN',...
% 'WQ_PHY_BGA',...
% 'WQ_PHY_BGA_RHO',...
% 'WQ_MAG_CHAETOMORPHA',...
% 'WQ_MAG_CHAETOMORPHA_IN',...
% 'WQ_MAG_CHAETOMORPHA_IP',...
% 'WQ_BIV_FILTFRAC',...
% 'WQ_NCS_SS1',...
% 'WQ_NCS_SS2',...
% 'WQ_DIAG_MAC_MAC_AG',...
% 'WQ_DIAG_MAG_TMALG',...

};

%----------- define plot y-axis limit ------------%
%def.cAxis(1).value = [-1 2];	%'H',...
def.cAxis(1).value = [5 35];    %'TEMP',...
def.cAxis(2).value = [0 20];    %'WQ_OXY_OXY',...
 def.cAxis(3).value = [0 2];     %'WQ_NIT_AMM',...
 def.cAxis(4).value = [0 1];     %'WQ_NIT_NIT',...
 def.cAxis(5).value = [0 1];     %'WQ_PHS_FRP',...
 def.cAxis(6).value = [0 40]; 	%'WQ_DIAG_PHY_TCHLA',...
 def.cAxis(7).value = [0 4]; 	%'WQ_DIAG_TOT_TN',...
 def.cAxis(8).value = [0 1]; 	%'WQ_DIAG_TOT_TP',...
% def.cAxis(8).value = [0 100];   %'WQ_OGM_DOC',...
% def.cAxis(9).value = [0 10];    %'WQ_OGM_POC',...
% def.cAxis(10).value = [0 5];    %'WQ_OGM_DON',...
% def.cAxis(11).value = [0 3];    %'WQ_OGM_PON',...
% def.cAxis(12).value = [0 0.3];  %'WQ_OGM_DOP',...
% def.cAxis(13).value = [0 0.2];  %'WQ_OGM_POP',...
% def.cAxis(14).value = [0 100];  %'WQ_OGM_DOCR',...
% def.cAxis(15).value = [0 3];    %'WQ_OGM_DONR',...
% def.cAxis(16).value = [0 0.1];  %'WQ_OGM_DOPR',...
% def.cAxis(17).value = [0 100];  %'WQ_OGM_CPOM',...
% def.cAxis(18).value = [0 15];   %'WQ_PHY_GRN',...
% def.cAxis(19).value = [0 50];   %'WQ_PHY_CRYPT',...
% def.cAxis(20).value = [0 25];   %'WQ_PHY_DIATOM',...
% def.cAxis(21).value = [0 50];   %'WQ_PHY_DINO',...
% def.cAxis(22).value = [0 10];   %'WQ_PHY_DINO_IN',...
% def.cAxis(23).value = [0 10];   %'WQ_PHY_BGA',...
% def.cAxis(24).value = [0 1100]; %'WQ_PHY_BGA_RHO',...
% def.cAxis(25).value = [0 3];    %'WQ_MAG_CHAETOMORPHA',...
% def.cAxis(26).value = [0 0.05]; %'WQ_MAG_CHAETOMORPHA_IN',...
% def.cAxis(27).value = [0 0.01]; %'WQ_MAG_CHAETOMORPHA_IP',...
% def.cAxis(28).value = [0 1];    %'WQ_BIV_FILTFRAC',...
% def.cAxis(29).value = [0 50]; 	%'WQ_NCS_SS1',...
% def.cAxis(30).value = [0 50]; 	%'WQ_NCS_SS1',...
% def.cAxis(31).value = [0 12000];    %'WQ_DIAG_MAC_MAC_AG',...
% def.cAxis(32).value = [0 500]; 	%'WQ_DIAG_MALG_TMALG',...
% def.cAxis(33).value = [0 35]; 	%'WQ_DIAG_PHY_TCHLA',...
% def.cAxis(34).value = [0 8]; 	%'WQ_DIAG_TOT_TN',...
% def.cAxis(35).value = [0 1.5]; 	%'WQ_DIAG_TOT_TP',...

%----------- define the polygon shape file ------------%
polygon_file = 'GIS/DRR/SMS/DRR_regions.shp';
depth_range = [1 100];

%----------- add error calculation to a separate figure ------------%
plotvalidation = 0; % true or false

%----------- define plot options ------------%
plotdepth = {'surface','bottom'};%{'surface','bottom'}; % Cell with either one or both
istitled = 1;
isylabel = 1;
islegend = 0;
isYlim = 1;
isRange = 1;
isRange_Bottom = 0;
custom_datestamp = 0;

filetype = 'eps';
def.expected = 1; % plot expected WL

%----------- define plot output directory ------------%
outputdirectory = '.\plotting_DRR\';
% ____________________________________________________________Configuration

%% Models___________________________________________________________________

%----------- define model file(s) and style(s) to plot ------------%
 ncfile(1).name = 'Z:\Peisheng\Darwin\DRR_TUFLOW_v6_overflow\output\drr_tuflow.nc';
 ncfile(1).symbol = {'-';'--'};
 ncfile(1).colour = {'m','b'}; % Surface and Bottom
 ncfile(1).legend = 'TUFLOW';
 ncfile(1).translate = 1;

%  ncfile(2).name = 'D:\Studysites\Lowerlakes\035_obs_LL_Only_TFV_AED2_Inf\Output\lower_lakes.nc';
%  ncfile(2).symbol = {'-';'--'};
%  ncfile(2).colour = {'r','r'}; % Surface and Bottom
%  ncfile(2).legend = 'v35 LL';
%  ncfile(2).translate = 1;

%----------- define plot time and format ------------%
yr = 2012;
def.datearray = datenum(yr,1:06:24,01);

def.dateformat = 'mm-yy'; % Must have same number as variable to plot & in same order

def.dimensions = [10 6]; % Width & Height in cm

def.dailyave = 1; % 1 for daily average, 0 for off. Daily average turns off smoothing.
def.smoothfactor = 3; % Must be odd number (set to 3 if none)

def.fieldsymbol = {'.','.'}; % Cell with same number of levels
def.fieldcolour = {'m',[0.6 0.6 0.6]}; % Cell with same number of levels

def.font = 'Arial';

def.xlabelsize = 7;
def.ylabelsize = 7;
def.titlesize = 12;
def.legendsize = 6;
def.legendlocation = 'northeast';

def.visible = 'off'; % on or off