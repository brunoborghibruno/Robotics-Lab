%% BRUNO BORGHI - compare the FFT of different subjects using the same time window


%% Select the subjects' ID to be compared

% subjectsList  =  ["E5", "E16"];




%% Subject 5 

% visit 1
[acc_raw_E5_1, angRate_raw_E5_1, temp_raw_E5_1, press_raw_E5_1, SOC_raw_E5_1, stepCount_raw_E5_1, marker_E5_1]  =  dataStorage();

% visit 4
[acc_raw_E5_4, angRate_raw_E5_4, temp_raw_E5_4, press_raw_E5_4, SOC_raw_E5_4, stepCount_raw_E5_4, marker_E5_4]  =  dataStorage();

% visit 7
[acc_raw_E5_7, angRate_raw_E5_7, temp_raw_E5_7, press_raw_E5_7, SOC_raw_E5_7, stepCount_raw_E5_7, marker_E5_7]  =  dataStorage();




%% Subject 16

% visit 1
[acc_raw_E16_1, angRate_raw_E16_1, temp_raw_E16_1, press_raw_E16_1, SOC_raw_E16_1, stepCount_raw_E16_1, marker_E16_1]  =  dataStorage();

% visit 4
[acc_raw_E16_4, angRate_raw_E16_4, temp_raw_E16_4, press_raw_E16_4, SOC_raw_E16_4, stepCount_raw_E16_4, marker_E16_4]  =  dataStorage();

% visit 7
[acc_raw_E16_7, angRate_raw_E16_7, temp_raw_E16_7, press_raw_E16_7, SOC_raw_E16_7, stepCount_raw_E16_7, marker_E16_7]  =  dataStorage();



%% Data clipping (7 HOURS)

maxSamples = 1700000;  % is the amount of samples required to clip the first 7 hours of experiment

% E-5
acc_raw_E5_1     =   acc_raw_E5_1(1:maxSamples, :);
angRate_raw_E5_1 =   (angRate_raw_E5_1(:, 1:maxSamples))';

acc_raw_E5_4     =   acc_raw_E5_4(1:maxSamples, :);
angRate_raw_E5_4 =   (angRate_raw_E5_4(:, 1:maxSamples))';

acc_raw_E5_7     =   acc_raw_E5_7(1:maxSamples, :);
angRate_raw_E5_7 =   (angRate_raw_E5_7(:, 1:maxSamples))';

% E-16
acc_raw_E16_1     =   acc_raw_E16_1(1:maxSamples, :);
angRate_raw_E16_1 =   (angRate_raw_E16_1(:, 1:maxSamples))';

acc_raw_E16_4     =   acc_raw_E16_4(1:maxSamples, :);
angRate_raw_E16_4 =   (angRate_raw_E16_4(:, 1:maxSamples))';

acc_raw_E16_7     =   acc_raw_E16_7(1:maxSamples, :);
angRate_raw_E16_7 =   (angRate_raw_E16_7(:, 1:maxSamples))';



%% Signal conversion

LSBvalue    =  0.0001;  % LSB = 5 / 2^16, because of a 5V ADC with 16bit resolution
baseline    =  0;

realSignal_E5_1  =  signalConversion(acc_raw_E5_1, LSBvalue, baseline);

realSignal_E5_4  =  signalConversion(acc_raw_E5_4, LSBvalue, baseline);

realSignal_E5_7  =  signalConversion(acc_raw_E5_7, LSBvalue, baseline);

realSignal_E16_1  =  signalConversion(acc_raw_E16_1, LSBvalue, baseline);

realSignal_E16_4  =  signalConversion(acc_raw_E16_4, LSBvalue, baseline);

realSignal_E16_7  =  signalConversion(acc_raw_E16_7, LSBvalue, baseline);


acc_raw_E5_1 = realSignal_E5_1;
acc_raw_E5_4 = realSignal_E5_4;
acc_raw_E5_7 = realSignal_E5_7;

acc_raw_E16_1 = realSignal_E16_1;
acc_raw_E16_4 = realSignal_E16_4;
acc_raw_E16_7 = realSignal_E16_7;



%% Normalization

timeStamp           =  1/64:1/64:length(acc_raw_E5_1)/64;
timeStamp1          =  (timeStamp/60)/60; % hours

% acc_raw_normalized_E5_1  =  vecnorm(double(acc_raw_E5_1'))';   % Norm 2 of the accelerations along the three directions
% acc_raw_normalized_E5_4  =  vecnorm(double(acc_raw_E5_4'))';
% acc_raw_normalized_E5_7  =  vecnorm(double(acc_raw_E5_7'))';
% 
% acc_raw_normalized_E16_1  =  vecnorm(double(acc_raw_E16_1'))';   % Norm 2 of the accelerations along the three directions
% acc_raw_normalized_E16_4  =  vecnorm(double(acc_raw_E16_4'))';
% acc_raw_normalized_E16_7  =  vecnorm(double(acc_raw_E16_7'))';





%% Background noise with Fast Fourier Transform (FFT)

[freq_E5_1, power_E5_1]  =  FilterAndFFT(acc_raw_E5_1);
[freq_E5_4, power_E5_4]  =  FilterAndFFT(acc_raw_E5_4);
[freq_E5_7, power_E5_7]  =  FilterAndFFT(acc_raw_E5_7);

[freq_E16_1, power_E16_1]  =  FilterAndFFT(acc_raw_E16_1);
[freq_E16_4, power_E16_4]  =  FilterAndFFT(acc_raw_E16_4);
[freq_E16_7, power_E16_7]  =  FilterAndFFT(acc_raw_E16_7);


% temporary dimension fix
power_E5_1 = power_E5_1';
power_E5_4 = power_E5_4';
power_E5_7 = power_E5_7';

power_E16_1 = power_E16_1';
power_E16_4 = power_E16_4';
power_E16_7 = power_E16_7';


%% Plot of the 6 FFT

figure(1)


% Uncomment this if you want to have constant axis limits for all the subplots
xLimits = [(min([freq_E5_1(1:length(freq_E5_1)/2),   freq_E5_4(1:length(freq_E5_4)/2),   freq_E5_7(1:length(freq_E5_7)/2),   freq_E16_1(1:length(freq_E16_1)/2),   freq_E16_4(1:length(freq_E16_4)/2),   freq_E16_7(1:length(freq_E16_7)/2)])),   (max([freq_E5_1(1:length(freq_E5_1)/2),   freq_E5_4(1:length(freq_E5_4)/2),   freq_E5_7(1:length(freq_E5_7)/2),   freq_E16_1(1:length(freq_E16_1)/2),   freq_E16_4(1:length(freq_E16_4)/2),   freq_E16_7(1:length(freq_E16_7)/2)]))];
yLimits = [(min([power_E5_1(1:length(power_E5_1)/2), power_E5_4(1:length(power_E5_4)/2), power_E5_7(1:length(power_E5_7)/2), power_E16_1(1:length(power_E16_1)/2), power_E16_4(1:length(power_E16_4)/2), power_E16_7(1:length(power_E16_7)/2)])), (max([power_E5_1(1:length(power_E5_1)/2), power_E5_4(1:length(power_E5_4)/2), power_E5_7(1:length(power_E5_7)/2), power_E16_1(1:length(power_E16_1)/2), power_E16_4(1:length(power_E16_4)/2), power_E16_7(1:length(power_E16_7)/2)]))];
% Subject E5
subplotFunction(freq_E5_1(1:length(freq_E5_1)/2), power_E5_1(1:length(power_E5_1)/2), 2, 3, 1, 'E-5 Visit 1', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on
subplotFunction(freq_E5_4(1:length(freq_E5_4)/2), power_E5_4(1:length(power_E5_4)/2), 2, 3, 2, 'E-5 Visit 4', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on
subplotFunction(freq_E5_7(1:length(freq_E5_7)/2), power_E5_7(1:length(power_E5_7)/2), 2, 3, 3, 'E-5 Visit 7', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on

% Subjet E16
subplotFunction(freq_E16_1(1:length(freq_E16_1)/2), power_E16_1(1:length(power_E16_1)/2), 2, 3, 4, 'E-16 Visit 1', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on
subplotFunction(freq_E16_4(1:length(freq_E16_4)/2), power_E16_4(1:length(power_E16_4)/2), 2, 3, 5, 'E-16 Visit 4', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on
subplotFunction(freq_E16_7(1:length(freq_E16_7)/2), power_E16_7(1:length(power_E16_7)/2), 2, 3, 6, 'E-16 Visit 7', 'Frequency [Hz]', 'Amplitude', [], 1, xLimits, yLimits);
box off;
hold on


%% end









function [freq_range_filtered, power_tot_filtered] = FilterAndFFT(acceleration)

% Denoise and Detrend each axis
acc_x = detrend(wdenoise(double(acceleration(:,1))));
acc_y = detrend(wdenoise(double(acceleration(:,2))));
acc_z = detrend(wdenoise(double(acceleration(:,3))));

% Reconstruct denoised and detrended signal
effective_acc_cleaned = [acc_x, acc_y, acc_z];

% Filter the cleaned signal
[filteredData, ~, ~] = dataFiltering(effective_acc_cleaned, 12, 0.5, 64, 10);

% Get magnitude
normalizedFilteredData = detrend(vecnorm(filteredData, 2, 2));
% normalizedFilteredData = mean(filteredData, 2);


% Apply FFT
[freq_range_filtered, power_tot_filtered] = FastFourierTransf(normalizedFilteredData, 64);
% power_tot_filtered(1) = 0;  % Set DC component to zero for better visualization


end



function [freq_range, power_tot] = FastFourierTransf(effective_acc_raw, fs)



fn  =  fs/2; % Since only half of the fft is useful, the other half is just the mirrored part
n           =  length(effective_acc_raw);

% create the Fast Fourirer Transform 

% fft_1 = fft(acc_x_direction); 
% fft_2 = fft(acc_y_direction); 
% fft_3 = fft(acc_z_direction); 
fft_effective  =  fft(effective_acc_raw);


freq_range  =  (0:n-1)*(fs/n);  % fs = sampling frequency
% power1      =  abs(fft_1).^2/n;
% power2      =  abs(fft_2).^2/n;
% power3      =  abs(fft_3).^2/n;
power_tot   =  abs(fft_effective).^2/n;




end