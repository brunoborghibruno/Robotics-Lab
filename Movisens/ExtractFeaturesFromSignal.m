%% BRUNO BORGHI  -  Feature extraction function that uses the SVM model created to extract specific features
% This function will:
% Normalize
% Denoise
% Filter
% Chunk
% Extract features

function features = extractFeaturesFromSignal(accSignal, model)

fs          = model.fs;
signalLen  = model.signalLen;

% Norm
acc_norm = vecnorm(double(accSignal'))';

% Denoise
acc_denoise = wdenoise(double(acc_norm));
acc_denoise = detrend(acc_denoise);

% Filter
[acc_filt, ~, ~] = dataFiltering(acc_denoise, 12, 0.5, fs, 10);

% Chunk
numChunks = floor(length(acc_filt) / signalLen);

signalMatrix         = zeros(signalLen, numChunks);
signalMatrixFiltered = zeros(signalLen, numChunks);

for k = 1:numChunks
    idx = (k-1)*signalLen + 1 : k*signalLen;
    signalMatrix(:,k) = acc_norm(idx);
    signalMatrixFiltered(:,k) = acc_filt(idx);
end

% Feature extraction
meanDs = arrayDatastore(signalMatrix,"IterationDimension",2);
meanDs = transform(meanDs,@(x)model.meanFE.extract(x{:}));

timeDs = arrayDatastore(signalMatrixFiltered,"IterationDimension",2);
timeDs = transform(timeDs,@(x)model.timeFE.extract(x{:}));

freqDs = arrayDatastore(signalMatrixFiltered,"IterationDimension",2);
freqDs = transform(freqDs,@(x)model.freqFE.extract(x{:}));

meanFeatures = readall(meanDs,"UseParallel",true);
timeFeatures = readall(timeDs,"UseParallel",true);
freqFeatures = readall(freqDs,"UseParallel",true);

features = [meanFeatures timeFeatures freqFeatures];

end

