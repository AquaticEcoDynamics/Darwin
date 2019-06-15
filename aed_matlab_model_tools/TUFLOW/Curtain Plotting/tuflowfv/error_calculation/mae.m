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
%     obsData = N x 2
%     simData = N x 2
%
%     obsData(:,1) = time observed
%     obsData(:,2) = Observed Data
%     simData(:,1) = time simulated
%     simData(:,2) = Simulated data
%
function [error_MAE] = mae(obsData, simData)

[v loc_obs loc_sim] = intersect(obsData(:,1), simData(:,1));

    % and create subset of data with elements= Time, Observed, Simulated
    MatchedData = [v obsData(loc_obs,2) simData(loc_sim,2)];
    
X = MatchedData(:,2) - MatchedData(:,3);
N = length(MatchedData(:,2));

error_MAE= sum(abs(X)) / N;