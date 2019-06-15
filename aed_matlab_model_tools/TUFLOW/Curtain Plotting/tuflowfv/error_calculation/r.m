function rf=r(obsDATA, simDATA)

% Syntax:
%     [error_RMS] = r(obsDATA, simDATA)
%
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
% find matching time values
[v loc_obs loc_sim] = intersect(obsDATA(:,1), simDATA(:,1));
% and create subset of data with elements= Time, Observed, Simulated

MatchedData(:,1) = obsDATA(loc_obs,2);
MatchedData(:,2) = simDATA(loc_sim,2);

% I'm not familiar with how MATLAB is optimized to clear it's memory,
% this next call may or may not speed things up.
clear v loc_obs loc_sim

ss = find(~isnan(MatchedData(:,1)) == 1);

R = corrcoef(MatchedData(ss,1), MatchedData(ss,2));hold on;
rf=R(1,2);

