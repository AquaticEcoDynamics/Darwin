% Error calculation:
% 3) ROOT MEAN SQUARE (RMS)


% RMS =  sqrt{sum[( Xsim - Xobs ).^2]}


% Syntax:
%     [error_RMS] = mae(obsDATA, simDATA)
%
% where:
%     obsData = N x 1
%     simData = N x 1
%
%     obsData(:,1) = Observed Data
%     simData(:,1) = Simulated data
%
function [error_RMS] = rms(obsData, simData)

% find matching time values
% v=zeros(size(obsDatas));
%     MatchedDatas = [v obsDatas simDatas];
%     MatchedDatab = [v obsDatab simDatab];
% 
%     MatchedData=MatchedDatas;
%     MatchedData((size(MatchedDatas,1)+1):(size(MatchedDatas,1)+size(MatchedDatab,1)),:)=MatchedDatab;

% I'm not familiar with how MATLAB is optimized to clear it's memory,
% this next call may or may not speed things up.
clear v loc_obs loc_sim
MatchedData=[obsData, obsData, simData];
X = MatchedData(:,2) - MatchedData(:,3);

error_RMS =  sqrt(sum(X.^2)/length(X));