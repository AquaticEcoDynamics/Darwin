% Error calculation:
% 3) ROOT MEAN SQUARE (RMS)


% RMS =  sqrt{sum[( Xsim - Xobs ).^2]}


% Syntax:
%     [error_RMS] = mae(obsDATA, simDATA)
%
% where:
% where:
%     obsData = N x 2
%     simData = N x 2
%
%     obsData(:,1) = time observed
%     obsData(:,2) = Observed Data
%     simData(:,1) = time simulated
%     simData(:,2) = Simulated data
%
function [error_RMS] = rms(obsData, simData)

[v loc_obs loc_sim] = intersect(obsData(:,1), simData(:,1));

    % and create subset of data with elements= Time, Observed, Simulated
    MatchedData = [v obsData(loc_obs,2) simData(loc_sim,2)];

X = MatchedData(:,2) - MatchedData(:,3);

error_RMS =  sqrt(sum(X.^2)/length(X));