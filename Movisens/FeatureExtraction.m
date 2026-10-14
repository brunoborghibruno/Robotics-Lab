%% BRUNO BORGHI - MACHINE LEARNING SVM TRAINING FOR FEATURES EXTRACTION ON ACCELEROMETER SIGNAL 


dataLength      =   60; % chunks of 10 seconds

%% Load the data


[acc_raw, angRate_raw, temp_raw, press_raw, SOC_raw, stepCount_raw, marker]  =  dataStorage();




%% Data clipping - based on MAX LENGTH DATA AVAILABLE

if (length(marker) < 3)    % which means the subject didn't trigger any marker, so there is no way to know what the subject did and when..

    maxSamples      =   length(acc_raw); % ALL THE DATA IN THE ACCELEROMETER

    originalMarker  =   marker;

    marker          =   [1, 1];

else

% maxSamples  =   marker; % FROM MARKER IN POSITION 2
maxSamples =    marker(end);

acc_raw     =   acc_raw(marker(1):maxSamples+marker(1), :);

angRate_raw =   angRate_raw(:, marker(1):maxSamples+marker(1));

angRate_raw =   angRate_raw';

end




%% Signal Conversion

LSBvalue    =  0.0001;  % LSB = 5 / 2^16, because of a 5V ADC with 16bit resolution
% LSBvalue    =  0.00048828;  % LSB = 5 / 2^12, because of a 5V ADC with 12bit resolution
% baseline    =  mean(acc_raw(100:10000, :));  % this is valid for 'Acceleration Test' [13.8655, 11.7853, 2062.3]
baseline    =  0;

realSignal  =  signalConversion(acc_raw, LSBvalue, baseline);

realGyroscopeSignal =   signalConversion(angRate_raw, LSBvalue, baseline);



%% Raw data sub-plot

% Remove marker(3) for the Car Ride signal, it was a mistake

% Arturo Drive Data
% markers = [marker(2); marker(4:end)];

% Bruno Drive Data 1
markers = [marker(1:8); marker(10:end)];

% Bruno Drive Data 2
% markers = marker(2:end);


timeStamp   =  1/64:1/64:length((realSignal))/64;
timeStamp1  =  (timeStamp/60)/60; % hours

markers1  = ((markers/64)/60)/60;

figure (1)
subplotFunction(timeStamp1, realSignal, 3, 1, 3, 'AccRaw', 'Hours', 'Acc', markers1);



%% Overwrite acc_raw


acc_raw  =  realSignal;



%% Norm2 data plot


acc_raw_normalized  =  vecnorm(double(acc_raw'))';   % Norm 2 of the accelerations along the three directions
timeStamp           =  1/64:1/64:length(acc_raw_normalized)/64;
timeStamp1          =  (timeStamp/60)/60; % hours





%% Divide the signal in chuncks and change nomenclature



% Walking Sessions

% Arturo Data
% find nearest indices for the two target values
% [~, i1] = min(abs(timeStamp1 - 1.3988));
% [~, i2] = min(abs(timeStamp1 - 18.4783));

% build inclusive index ranges (works regardless of order)
% range1 = min(i1, markers(1)) : max(i1, markers(1));
% range2 = min(i2, markers(5)) : max(i2, markers(5));

% Bruno Test Drive Data 1
range1  =   markers(1):markers(2);
range2  =   markers(3):markers(4);



walkSignal = acc_raw_normalized([range1, range2]);


% Driving Sessions

% Arturo Data
% build inclusive index ranges (works regardless of order)
% range1 = markers(1) : markers(2);
% range2 = markers(3) : markers(4);
% range3 = markers(5) : markers(6);

% Bruno Test Drive Data 1
% build inclusive index ranges (works regardless of order)
range1 = markers(2) : markers(3);
range2 = markers(5) : markers(6);
range3 = markers(9) : markers(10);

driveSignal = acc_raw_normalized([range1, range2, range3]);


% Other stuff sessions

% Bruno Test Drive Data 2
range1 = 1:markers(1);
range2 = ((markers(5)-markers(4))/2)+markers(4):markers(5);

otherSignal = acc_raw_normalized([range1, range2]);



figure(1);
plot(walkSignal, '.-', 'Color', [0 0 0], 'LineWidth', 3);
hold on;
plot(driveSignal, '.-', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3);
hold on;
plot(otherSignal, '.-', 'Color', 'g', 'LineWidth', 3);



fs              =   64;
signalLength    =   dataLength*64; % 30 seconds for example x frequency 64Hz
maxColumns      =   floor((min([length(walkSignal), length(driveSignal), length(otherSignal)]))/signalLength);
v               =   repmat([1 2 3], 1, ceil(maxColumns/2));
actid           =   v(1:maxColumns);   % activity indexes

pattern         =   ["driving" "walking" "other"];
v               =   repmat(pattern, 1, ceil(maxColumns/2));
actnames        =   v(1:maxColumns);


%% Filter the signals with a highpass filter


walkSignal_denoise      =   wdenoise(double(walkSignal));
driveSignal_denoise     =   wdenoise(double(driveSignal));
otherSignal_denoise     =   wdenoise(double(otherSignal));



% Detrend to remove the DC offset
walkSignal_denoise      =  detrend(walkSignal_denoise);
driveSignal_denoise     =  detrend(driveSignal_denoise);
otherSignal_denoise     =  detrend(otherSignal_denoise);




% Data filtering - 10th order butterworth
[walkSignal_filtered, ~, ~]       =  dataFiltering(walkSignal_denoise, 12, 0.5, 64, 10);
[driveSignal_filtered, ~, ~]       =  dataFiltering(driveSignal_denoise, 12, 0.5, 64, 10);
[otherSignal_filtered, ~, ~]       =  dataFiltering(otherSignal_denoise, 12, 0.5, 64, 10);

figure(1);
plot(walkSignal_filtered, '.-', 'Color', [0 0 0], 'LineWidth', 3);
hold on;
plot(driveSignal_filtered, '.-', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3);
hold on;
plot(otherSignal_filtered, '.-', 'Color', 'g', 'LineWidth', 3);



%% Create the matrix for the analysis - chunks of dataLength seconds recordings

signalMatrix            =   zeros(signalLength, maxColumns);
signalMatrixFiltered    =   zeros(signalLength, maxColumns);
walkSignalIndex         =   0;
driveSignalIndex        =   0;
otherSignalIndex        =   0;

for count = 1 : maxColumns
    switch mod(count-1, 3)
        case 0  % 1st, 4th, 7th, ... -> walk
            idx = walkSignalIndex*signalLength + 1 : (walkSignalIndex+1)*signalLength;
            signalMatrixFiltered(:, count) = walkSignal_filtered(idx);
            signalMatrix(:, count)         = walkSignal(idx);
            walkSignalIndex = walkSignalIndex + 1;
        case 1  % 2nd, 5th, 8th, ... -> drive
            idx = driveSignalIndex*signalLength + 1 : (driveSignalIndex+1)*signalLength;
            signalMatrixFiltered(:, count) = driveSignal_filtered(idx);
            signalMatrix(:, count)         = driveSignal(idx);
            driveSignalIndex = driveSignalIndex + 1;
        case 2  % 3rd, 6th, 9th, ... -> other
            idx = otherSignalIndex*signalLength + 1 : (otherSignalIndex+1)*signalLength;
            signalMatrixFiltered(:, count) = otherSignal_filtered(idx);
            signalMatrix(:, count)         = otherSignal(idx);
            otherSignalIndex = otherSignalIndex + 1;
    end
end




%% Estract mean of the unfilitered signal and root mean square, shape factor, peak value, crest factor, clearance factor and impulse factor of the filtered signal


meanFE = signalTimeFeatureExtractor("Mean", true, "SampleRate", fs);
timeFE = signalTimeFeatureExtractor("RMS", true, "ShapeFactor", true, "PeakValue", true, "CrestFactor", true, "ClearanceFactor", true, "ImpulseFactor", true, "SampleRate", fs);


% Frequency features to extract the mean frequency, band power, half-power bandwidth, peak amplitude and peak location of the filtered signals

freqFE = signalFrequencyFeatureExtractor("PeakAmplitude", true, "PeakLocation", true, "MeanFrequency", true, "BandPower", true, "PowerBandwidth", true, "SampleRate",fs);




%% Computation of the spectral peaks


fftLength = 256;
window = rectwin(size(signalMatrix,1));
setExtractorParameters(freqFE,"WelchPSD","FFTLength",fftLength,"Window",window);
mindist_xunits = 0.25;
minpkdist = floor(mindist_xunits/(fs/fftLength));
setExtractorParameters(freqFE,"PeakAmplitude","MaxNumExtrema",6,"MinSeparation",minpkdist);
setExtractorParameters(freqFE,"PeakLocation","MaxNumExtrema",6,"MinSeparation",minpkdist);




%% Parallelized computation of the features

meanFeatureDs = arrayDatastore(signalMatrix,"IterationDimension",2);
meanFeatureDs = transform(meanFeatureDs,@(x)meanFE.extract(x{:}));
timeFeatureDs = arrayDatastore(signalMatrixFiltered,"IterationDimension",2);
timeFeatureDs = transform(timeFeatureDs,@(x)timeFE.extract(x{:}));
freqFeatureDs = arrayDatastore(signalMatrixFiltered,"IterationDimension",2);
freqFeatureDs = transform(freqFeatureDs,@(x)freqFE.extract(x{:}));



%% Distribute the computation across a pool workers if parallel computing toolbox is installed

meanFeatures = readall(meanFeatureDs,"UseParallel",true);
timeFeatures = readall(timeFeatureDs,"UseParallel",true);
freqFeatures = readall(freqFeatureDs,"UseParallel",true);

features = [meanFeatures timeFeatures freqFeatures];




%% Train an SVM classifier using extracted features


featureTable = array2table(features);
actioncats = categorical(actnames)';
featureTable.ActivityID = actioncats(actid);
head(featureTable)




%% Divide Training 75% and test 25% using cvpartition function to ensure activity labels balanced groups

% Extract predictors and response
predictors = featureTable(:, 1:end-1);
response = featureTable.ActivityID;

% For reproducible results
rng default

% Partition the data and extract training predictors and response data
cvp = cvpartition(response,'Holdout',0.25);
trainingPredictors = predictors(cvp.training, :);
trainingResponse = response(cvp.training, :);

% Train the classifier
template = templateSVM('KernelFunction', 'polynomial', 'PolynomialOrder', 2, 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', true);

classificationSVM = fitcecoc(trainingPredictors, trainingResponse, 'Learners', template, 'Coding', 'onevsone');

% Simpler classifier if you only have 2 classes

% classificationSVM = fitcsvm(trainingPredictors, trainingResponse, 'KernelFunction','polynomial', 'PolynomialOrder',2, 'KernelScale','auto', 'Standardize',true);


%% Test the classifier


% Extract test predictors and response data
testPredictors = predictors(cvp.test, :);
testResponse = response(cvp.test, :);

% Predict activity on the test data
testPredictions = predict(classificationSVM,testPredictors);

% Plot the confusion matrix to analyze performance of the classifier
figure
cm = confusionchart(testResponse, testPredictions, ColumnSummary="column-normalized", RowSummary="row-normalized");

% display accuracy values
accuracy = trace(cm.NormalizedValues)/sum(cm.NormalizedValues, "all");
fprintf("The classification accuracy on the test partition is %2.1f%%", accuracy*100)



%% Save the SVM model

model.SVM           =   classificationSVM;
model.meanFE        =   meanFE;
model.timeFE        =   timeFE;
model.freqFE        =   freqFE;
model.fs            =   fs;
model.signalLen     =   signalLength;
model.dataLength    =   dataLength;  

save(fullfile(MovisensDataFolder, 'Accelerometer_SVM_Model.mat'), 'model');