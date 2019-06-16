% Error calculation:
% 1) ABSOLUTE ERROR (MAE)
% The MAE measures the average magnitude of the errors in a set of 
% forecasts, without considering their direction. It measures accuracy 
% for continuous variables. The equation is given in the library references. 
% Expressed in words, the MAE is the average over the verification 
% sample of the absolute values of the differences between forecast
% and the corresponding observation. The MAE is a linear score which
% means that all the individual differences are weighted equally in 
% the average.

%        sum | Xsim - Xobs |
%  MAE = ------------------
%                N

% Syntax:
%     [error_MAE] = mae(obsDATA, simDATA)
%
% where:
%     obsData = N x 1
%     simData = N x 1
%
%     obsData(:,1) = Observed Data
%     simData(:,1) = Simulated data
%
function [error_MAE] = mae(obsData, simData)

% % find matching time values
%     [v loc_obs loc_sim] = intersect(obsDatas(:,1), simDatas(:,1));
% 
%     % and create subset of data with elements= Time, Observed, Simulated
%     MatchedDatas = [v obsDatas(loc_obs,2) simDatas(loc_sim,2)];
% 
%      [v loc_obs loc_sim] = intersect(obsDatab(:,1), simDatab(:,1));
% 
%     % and create subset of data with elements= Time, Observed, Simulated
%     MatchedDatab = [v obsDatab(loc_obs,2) simDatab(loc_sim,2)];
%     
%     MatchedData=MatchedDatas;
%     MatchedData((size(MatchedDatas,1)+1):(size(MatchedDatas,1)+size(MatchedDatab,1)),:)=MatchedDatab;
% 
% % I'm not familiar with how MATLAB is optimized to clear it's memory,
% % this next call may or may not speed things up.
% clear v loc_obs loc_sim

MatchedData=[obsData, obsData, simData];
X = MatchedData(:,2) - MatchedData(:,3);
N = length(MatchedData(:,2));

error_MAE= sum(abs(X)) / N;