function data = tfv_process_netcdf_pt(filename,pnt,varname,rawGeo,mTime)
% Function to process a tuflow netcdf and output the data at a given point
% for all valid variables, including time in Matlab format.
%
% Written by Brendan Busch 03/12/2012

data = [];

% These variables will be xcreened out of the final output. If one of these
% is required, then remove from this list (or comment)
% invalid_vars = {...
%     'ResTime';...
%     'cell_Nvert';...
%     'cell_node';...
%     'NL';...
%     'idx2';...
%     'idx3';...
%     'cell_X';...
%     'cell_Y';...
%     'cell_Zb';...
%     'cell_A';...
%     'node_X';...
%     'node_Y';...
%     'node_Zb';...
%     'layerface_Z';...
%     'stat';...
%     'V_x';...
%     'V_y';...
%     'W';...
%     };
% 
% % Get time model time output;
% nctime = tfv_readnetcdf(filename,'time',1);
% mTime = nctime.Time;
% clear nctime;
% 
% rawGeo = tfv_readnetcdf(filename,'timestep',1);
% allvars = tfv_infonetcdf(filename);
% 

% Get valid varnames
% int = 1;
% for ii = 1:length(allvars)
%     if strcmp(allvars{ii},invalid_vars) == 0
%         validnames{int} = allvars(ii);
%         int = int + 1;
%     end
% end
% 
% for kk = 1:length(validnames)
    
    disp('Loading netcdf data - It can take awhile');
    disp('Finished loading netcdf data');
    %varname = cell2mat(validnames{kk});
    
    %__________________________________________________________________________
    rawData = tfv_readnetcdf(filename,'names',{varname});
    
    
    for pp = 1:length(pnt)
        pt_id = pnt(pp);
        %for kk = 1:length(validnames)
        
        cellname = ['Cell',num2str(pt_id)];
        
        Cell_3D_IDs = find(rawGeo.idx2==pt_id);
        
        if(length(Cell_3D_IDs) ~= rawGeo.NL(pt_id))
            disp('cell3DiDs ~=NL')
            disp(pt_id)
        end
        
        surfIndex = min(Cell_3D_IDs);
        botIndex = max(Cell_3D_IDs);
        
        
        data.(cellname).profile = zeros(length(Cell_3D_IDs)+2,size(rawData.(varname),2));
        data.(cellname).depths  = zeros(length(Cell_3D_IDs)+2,1);
        
        if strcmp(varname,'H') == 0
            
            data.(cellname).surface = rawData.(varname)(surfIndex,:);
            data.(cellname).bottom  = rawData.(varname)(botIndex,:);
            %data.profile = rawData.(varname)(Cell_3D_IDs,:);
            
            data.(cellname).profile(1,:) = rawData.(varname)(Cell_3D_IDs(1),:);
            data.(cellname).profile(2:length(Cell_3D_IDs)+1,:) = rawData.(varname)(Cell_3D_IDs,:);
            data.(cellname).profile(length(Cell_3D_IDs)+2,:) = rawData.(varname)(Cell_3D_IDs(length(Cell_3D_IDs)),:);
            
            data.(cellname).depths(1)  = rawGeo.layerface_Z(surfIndex + pt_id - 1);
            for i = 1 : rawGeo.NL(pt_id)
                % mid point of layer
                data.(cellname).depths(i+1) = (rawGeo.layerface_Z(Cell_3D_IDs(i) + pt_id-1) + rawGeo.layerface_Z(Cell_3D_IDs(i) + pt_id-1 +1))/2.;
            end
            data.(cellname).depths(length(Cell_3D_IDs)+2)  = rawGeo.layerface_Z(botIndex+pt_id-1+1);
        else
            data.(cellname).surface = rawData.(varname)(pt_id,:);
            data.(cellname).bottom  = rawData.(varname)(pt_id,:);
            data.(cellname).profile = rawData.(varname)(pt_id,:);
            data.(cellname).depths  = -99.;
        end
        
        data.(cellname).Time = mTime;
        %end
    end
    
% end