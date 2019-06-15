function data = getGLMvardepth(simfile,varname,depths)

% function data = getGLMvardepth(simfile,varname,depths)
%
% Read a netcdf GLM sim output file and extract varname data at depths
% Creates a .csv file with data
% Useful to compare against field data files

% Inputs:
%		GLMfile     : filename of GLM output file to read from
%       varname     : varaible name
%       depths      : specified depths to extract data from
%
% Outputs
%		data : a MATLAB structure that contains dates, depths and data
%
% Uses:
%
% Written by L. Bruce 6 January 2014
% 

%Create structure of GLM variable


sim_data = readGLMnetcdf(simfile,varname);

%Number of dates simulated output
numDates = length(sim_data.time);

%Get time and depths
data.time = sim_data.time;
data.depths = depths;

%Convert simulated z (height from bottom) to depths (mid point for each
%layer)
sim_data.depth = 0.0*sim_data.z - 999;
for time_i = 1:length(sim_data.time)
    max_depth = sim_data.z(time_i,sim_data.NS(time_i));
    sim_data.depth(time_i,1) = max_depth - (sim_data.z(time_i,1))/2;
    for depth_i = 2:sim_data.NS(time_i)
        sim_data.depth(time_i,depth_i) = max_depth - ...
                        (sim_data.z(time_i,depth_i) + sim_data.z(time_i,depth_i-1))/2;
    end
end

%Extract data at discrete depths for each date
for time_i = 1:numDates
    %time_i
    datestr(sim_data.time(time_i))
    
    for depth_i = 1:length(depths)
        % Finds the closest matching depth
        %[~, sim_i_depth] = min(abs(sim_data.depth(time_i,:) - depths(depth_i)));
        
         % gets the data for that depth
        %data.var(time_i,depth_i) = sim_data.(varname)(time_i,sim_i_depth);
        
        % Now that we are using a range...
        
        sss = find(sim_data.depth(time_i,:) >= depths(depth_i).depth(1) & sim_data.depth(time_i,:) <= depths(depth_i).depth(2));
        
        data.var(time_i,depth_i) = mean(sim_data.(varname)(time_i,sss));
        
        
        
       
        %If the difference between required and simulated depths is <2m
        %then keep data else discard
        %if abs(sim_data.depth(time_i,sim_i_depth) - depths(depth_i)) < 2
        %    data.var(time_i,depth_i) = NaN;
        %end
    end
end
