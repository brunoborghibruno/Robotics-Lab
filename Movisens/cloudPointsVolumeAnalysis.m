%% BRUNO BORGHI - Volume Calculation
% 72 hours test is = 1286 m^3; Accelerazione volume 72hrs = 1.10 x 10^13 % 5days is 8.9 e13
% left-handed all meals volume 5.2057e^11
% 72 hours test is = 1286 m^3      % 5days is = 3.3571e^11


function   [cloudVolume]  =  cloudPointsVolumeAnalysis(volumeData, raw_data)


if ~isempty(raw_data)
% Plot the points in the 3d space
scatter3(raw_data(:,1), raw_data(:,2), raw_data(:,3), 'filled');
end


% Create the shape
shp  =  alphaShape(volumeData);
h    =  plot(shp);

cloudVolume  =  volume(shp); % 72 hours test is = 1286 m^3; Accelerazione volume 72hrs = 1.10 x 10^13 % 5days is 8.9 e13

title('Volume:', cloudVolume);



% %% K-Nearest Neighbor
% ptCloud  =  pointCloud(accelerazione);  % create the point cloud object to better handle the data
% 
% queryPoint  =  [x_mean, y_mean, z_mean];    % mean along the three axis
% KNN         =  single(length(accelerazione) * percent/100);        % 90% of the points
% 
% [indices, dists]  =  findNearestNeighbors(ptCloud, queryPoint, KNN);
% 


end
