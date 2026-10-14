%% Signal to Noise Ratio for Movisens Move4



%% Signal with noise 

% Acceleration
acc_raw  =  fopen('acc.bin', 'rb');
count    =  [3 inf]; % 1st column = Z axis; 2nd column = X axis; 3rd column = -Y
acc_raw  =  fread(acc_raw, count, '*int16')';



%% 5 min noise extended for the length of the signal (72 hours)

acc_raw_noise  =  fopen('acc.bin', 'rb');
count          =  [3 inf]; % 1st column = Z axis; 2nd column = X axis; 3rd column = -Y
acc_raw_noise  =  fread(acc_raw_noise, count, '*int16')';


acc_raw_noise  =  acc_raw_noise(20000:end,:);


lengthRatio  =  floor(length(acc_raw)/length(acc_raw_noise));

noise  =  [];

for count = 1 : lengthRatio
    noise  =  [noise; acc_raw_noise];
end

% Make the acc_raw same length as noise
acc_raw  =  acc_raw(1:length(noise), :);

% trasform from int to double for the snr analysis
acc_raw  =  double(acc_raw);
noise    =  double(noise);

% Signal to Noise Ratio individually for each direction
signalNoiseRatio_x  =  snr(acc_raw(:,1), noise(:,1));
signalNoiseRatio_y  =  snr(acc_raw(:,2), noise(:,2));
signalNoiseRatio_z  =  snr(acc_raw(:,3), noise(:,3));




%% Butterworth filter on the data, 5th order filter with cut-off frequency at 25Hz

cutOffFrequency  =  25;
filterOrder      =  5;

[b, a]  =  butter(filterOrder, cutOffFrequency/(64/2));

acc_raw_filtered  =  filter(b, a, acc_raw);

% Signal to Noise Ratio
signalNoiseRatio_Filtered_x  =  snr(acc_raw_filtered(:,1), noise(:,1));
signalNoiseRatio_Filtered_y  =  snr(acc_raw_filtered(:,2), noise(:,2));
signalNoiseRatio_Filtered_z  =  snr(acc_raw_filtered(:,3), noise(:,3));

