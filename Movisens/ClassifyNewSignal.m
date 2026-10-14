%% BRUNO BORGHI - New Signal Feature Extraction

load(fullfile(MovisensDataFolder, 'Accelerometer_SVM_Model.mat'))

% Load new data
[acc_raw, ~, ~, ~, ~, ~, marker] = dataStorage();

% Bruno driving markers
markers = marker(2:end);

LSBvalue = 0.0001;
realSignal = signalConversion(acc_raw, LSBvalue, 0);

acc_raw_normalized  =  vecnorm(double(acc_raw'))';
timeStamp           =  1/64:1/64:length(acc_raw_normalized)/64;
timeStamp1          =  (timeStamp/60)/60; % hours



% Extract features
features = ExtractFeaturesFromSignal(realSignal, model);

% Predict labels
featureTable = array2table(features);
predictedLabels = predict(model.SVM, features);



% disp(predictedLabels)

% Wrong way
timeAxis = (0:length(predictedLabels)-1)*model.dataLength/60; % minutes

% Right way
% chunkTime_sec = model.signalLen / model.fs;
% timeAxis = (0:length(predictedLabels)-1)*chunkTime_sec/60;

% transform predictedLabes in numericals in order to be used by stairs
activityNum = double(predictedLabels == "walking");




% New plotting



%% Build sample-level prediction masks

drivingSampleIdx = [];
walkingSampleIdx = [];
otherSampleIdx   = [];

for k = 1:length(predictedLabels)

    idxStart = (k-1)*model.signalLen + 1;
    idxEnd   = min(k*model.signalLen, length(realSignal));
    idxRange = idxStart:idxEnd;

    switch string(predictedLabels(k))
        case "driving"
            drivingSampleIdx = [drivingSampleIdx idxRange];
        case "walking"
            walkingSampleIdx = [walkingSampleIdx idxRange];
        case "other"
            otherSampleIdx = [otherSampleIdx idxRange];
    end
end

% Safety cleanup
drivingSampleIdx = unique(drivingSampleIdx);
walkingSampleIdx = unique(walkingSampleIdx);
otherSampleIdx   = unique(otherSampleIdx);

%% Plot

figure(1); clf
plot(timeStamp1, acc_raw_normalized, 'k', 'LineWidth', 1.5);
hold on
grid on

% True markers
markers1  = ((markers/64)/60)/60;
xline(markers1([1 3 5]), '--', 'Start Drive', 'LabelVerticalAlignment','top', 'Color','b', 'LabelHorizontalAlignment','center', 'LineWidth', 2);
xline(markers1([2 4 6]), '--', 'Stop Drive', 'LabelVerticalAlignment','top', 'Color','b', 'LabelHorizontalAlignment','center', 'LineWidth', 2);

% Overlay colored classifications
plot(timeStamp1(drivingSampleIdx), ones(1, length(timeStamp1(drivingSampleIdx))), '.', 'Color','r', 'MarkerSize', 6, 'LineWidth', 3); % driving

plot(timeStamp1(walkingSampleIdx), 20*ones(1,length(timeStamp1(walkingSampleIdx))), '.', 'Color','g', 'MarkerSize', 6, 'LineWidth', 3); % walking

plot(timeStamp1(otherSampleIdx), 30*ones(1,length(timeStamp1(otherSampleIdx))), '.', 'Color','b', 'MarkerSize', 6, 'LineWidth', 3); % other

xlabel('Time [h]')
ylabel('Acceleration Norm')
title('Signal + Predicted Activity Segments')

legend({'Signal','True markers','Driving','Walking','Other'}, 'Location','best')

hold off




% Old plotting
% % Driving indexes
% drivingSampleIdx = [];
% 
% for k = 1:length(predictedLabels)
% 
%     if predictedLabels(k) == "driving"
% 
%         idxStart = (k-1)*model.signalLen + 1;
%         idxEnd   = min(k*model.signalLen, length(realSignal));
% 
%         drivingSampleIdx = [drivingSampleIdx, idxStart:idxEnd];
% 
%     end
% end
% 
% drivingSampleIdx = unique(drivingSampleIdx);   % safety cleanup
% 
% 
% markers1  = ((markers/64)/60)/60;
% 
% % Plot
% figure(1)
% plot(timeStamp1, acc_raw_normalized, 'k', 'LineWidth', 3);
% hold on
% xline(markers1, '--', 'Transition', 'LabelVerticalAlignment', 'top', 'Color', 'b', 'LabelHorizontalAlignment','center', 'LineWidth', 3);
% hold on
% 
% % Create a full-length y vector that is NaN except on drivingSampleIdx
% yVal = 1;                    % y position for the horizontal segments
% y = nan(size(timeStamp1));   % full-length vector of NaNs
% 
% if ~isempty(drivingSampleIdx)
%     % Guard against indices out of range
%     validIdx = drivingSampleIdx(drivingSampleIdx >= 1 & drivingSampleIdx <= numel(timeStamp1));
%     y(validIdx) = yVal;
% end
% 
% % Plot the segments as a single line with NaN gaps (fast and light)
% y1 = nan(size(y));        % initialize with NaNs
% y1(isnan(y)) = -1;         % set positions where y is NaN to 1
% plot(timeStamp1, y1, '-', 'Color', 'g', 'LineWidth', 4);
% 
% plot(timeStamp1, y, '-', 'Color', [1 0.2 0.2], 'LineWidth', 4);
% 
% 
% xlabel('Time [min]')
% ylabel('Filtered Acc Norm')
% title('Signal + Predicted Driving Segments')
% 
% hold off






