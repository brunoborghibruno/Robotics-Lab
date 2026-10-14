%% BRUNO BORGHI  -  Movisens MOVE4 reading

%% Unisens Function

% unisens_utility_add_signalentry('C:\Users\bborghi\OneDrive - Shirley Ryan AbilityLab\Desktop\Bruno\Movisens\Matlab data processing\Left_Handed_6_Days', unisens);

% %% Unisens Funct
% a        =  fopen('acc.bin', 'r','ieee-be');
% count    =  [3 inf]; % 1st column = Z axis; 2nd column = X axis; 3rd column = -Y
% a        =  fread(a, count)';
% rs = unisens_utility_bin_read(a);




%% Data Storage


[acc_raw, angRate_raw, temp_raw, press_raw, SOC_raw, stepCount_raw, marker]  =  dataStorage();



%% DATA AVAILABILITY - hardcoded value of the max amount of samples available in order to compare different data of same lenght for the EF study

% maxSamples  =   1440000; % FROM MARKER IN POSITION 2


% maxSamples  = length(acc_raw); % ALL THE DATA IN THE ACCELEROMETER





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

realSignal          =  signalConversion(acc_raw, LSBvalue, baseline, 9.81);

realGyroscopeSignal =   signalConversion(angRate_raw, LSBvalue, baseline, 9.81);


% Pressure signal
baseline        =   -32768;       % int16 zero point (most negative value)
LSBvalue        =   0.0122;       % hPa/count  (800 hPa range / 65536 counts)
rangeOffset     =   300;         % hPa  (sensor minimum = 300 hPa)
real_press_raw  =   press_raw(1:2:end);

realPressureSignal      =   (real_press_raw - baseline) * LSBvalue + rangeOffset;
timeStampPressure       =   1/8:1/8:length((real_press_raw))/8;
timeStampPressureMin    =   (timeStampPressure/60); % Min
markersPressure         =   ((marker/64)/60);
subplotFunction(timeStampPressureMin, realPressureSignal, 1, 1, 1, 'Pressure Raw Data', 'Minutes', 'Pressure', markersPressure);
% Result: ~589–683 hPa

% realPressureSignal  =   signalConversion(press_raw, LSBvalue, baseline, 0.03);



%% Raw data sub-plot

% Remove marker(3) for the Car Ride signal, it was a mistake
% markers = [marker(1:8); marker(10:end)]; % bruno car ride
markers = marker;

timeStamp   =  1/64:1/64:length((realSignal))/64;
timeStamp1  =  (timeStamp/60)/60; % hours

markers1  = ((markers/64)/60)/60;

figure (1)
subplotFunction(timeStampPressureMin/60, realPressureSignal, 2, 1, 1, 'Pressure', 'Hr', 'Press', markersPressure/60, 1);
subplotFunction(timeStamp1, normalizedFilteredData, 2, 1, 2, 'AccRaw', 'Hours', 'Acc', markers1, 2);



%% Overwrite acc_raw

acc_raw  =  realSignal;



%% Raw Data single plot 

if exist('maxSamples', 'var')
    figure (1)
    subplotFunction(timeStamp1, acc_raw(:,1), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', markers1, 1);
    hold on
    subplotFunction(timeStamp1, acc_raw(:,2), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', markers1, 2);
    hold on
    subplotFunction(timeStamp1, acc_raw(:,3), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', markers1, 3);
else
    figure (1)
    subplotFunction(timeStamp1, acc_raw(:,1), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', [], 1);
    hold on
    subplotFunction(timeStamp1, acc_raw(:,2), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', [], 2);
    hold on
    subplotFunction(timeStamp1, acc_raw(:,3), 1, 1, 1, 'AccRaw', 'Hours', 'Acc', [], 3);
end




%% Norm2 data plot


acc_raw_normalized  =  vecnorm(double(acc_raw'))';   % Norm 2 of the accelerations along the three directions
timeStamp           =  1/64:1/64:length(acc_raw_normalized)/64;
timeStamp1          =  (timeStamp/60)/60; % hours
marker1             =  markers1;
% timeStamp           =  0:length(acc_raw_normalized);
% fs                  =  64;
% timeStamp           =  timeStamp/fs;





% acc_raw_normalized  =  acc_raw_normalized - mean(acc_raw_normalized);
% 
% sample_stamp        =  linspace(0, length(acc_raw_normalized), length(acc_raw_normalized));
% sample_stamp_query  =  linspace(0, length(acc_raw_normalized), length(acc_raw_normalized)/8);
% interpolated_acc  =  interp1(sample_stamp, acc_raw_normalized, sample_stamp_query);

if exist('maxSamples', 'var')
figure(1)
subplotFunction(timeStamp1, acc_raw_normalized, 1, 1, 1, 'Acceleration norm2', 'Time [hours]', 'Acceleration', markers1, 1);
else
figure(1)
subplotFunction(timeStamp1, acc_raw_normalized, 1, 1, 1, 'Acceleration norm2', 'Time [hours]', 'Acceleration', [], 1);
% subplotFunction([], acc_raw_normalized, 1, 1, 1, 'Acceleration norm2', 'Time [s]', 'Acceleration', marker/64, 1);
end





% print('IntegratedData (speed)', '-dpng', '-r600')



%% IN PAUSE FOR NOW - First 24 hours of recording - give the range of X data position where the first data recording starts



% % timeInterval  =  20000;
% 
% 
% % 72hours test
% % x1            =  [58804, 78804];  % First ~5 hours of Day1 - 20.000 seconds interval
% % x2            =  [141550, 161550]; % First ~5 hours of Day2
% % x3            =  [234366, 254366]; % First ~5 hours of Day3
% 
% 
% % rest of the day + day after test
% xValues =   1:15000;
% 
% 
% % 5 days test
% % x1            =  [44754, 44754+timeInterval];  % First ~5 hours of Day1 - 20.000 seconds interval
% % x2            =  [217554, 217554+timeInterval]; % First ~5 hours of Day3
% % x3            =  [309156, 309156+timeInterval]; % First ~5 hours of Day4
% 
% 
% % Plot of the vertical line chosen
% figure(2)
% plot(acc_raw_normalized(xValues), '.-', 'MarkerSize', 6, 'Color', [0 0.4470 0.7410]);
% hold on
% % xline([x1, x2, x3], '--');
% title('End of the day plus full day')
% xlabel('Time')
% ylabel('Acceleration Magnitude')
% 
% 
% % isolate the time window where the sensor is used
% 
% 
% % acc_x_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 1);    % CHANGE THIS PART BECAUSE IS HARDCODED FOR THAT SPECIFIC DATA SAMPLE
% % acc_y_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 2);
% % acc_z_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 3);
% % effective_acc_raw  =  acc_raw_normalized([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64]);
% % timeStampEffective =  timeStamp([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64]);
% 
% acc_x_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 1);   
% acc_y_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 2);
% acc_z_direction    =  acc_raw([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64], 3);
% effective_acc_raw  =  acc_raw_normalized([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64]);
% timeStampEffective =  timeStamp([x1(1)*64:x1(2)*64, x2(1)*64:x2(2)*64, x3(1)*64:x3(2)*64]);
% 
% 
% Plot of the actual time windows chosen
% figure(1)
% plot(effective_acc_raw, '.-', 'MarkerSize', 6, 'Color', [0 0 0]);
% hold on
% yline(mean(effective_acc_raw), 'LineWidth', 2, 'Color', [0.6350 0.0780 0.1840]);
% title('Acceleration norm2')
% xlabel('Samples')
% ylabel('Acceleration')


%% Meals and Bathing activities
% 
% 
% 
% [effective_acc_raw, acc_x_direction, acc_y_direction, acc_z_direction, effective_bathing_marker]  =  bathingSignalAnalysis(acc_raw, acc_raw_normalized, marker);
% 
% % [effective_acc_raw, acc_x_direction, acc_y_direction, acc_z_direction]  =  mealsSignalAnalysis(acc_raw, acc_raw_normalized, marker);
% 
% 
% 
% figure(4)
% subplotFunction([], effective_acc_raw, 1, 1, 1, 'Meals acceleration', 'Time [s]', 'Acceleration [m/s2]', effective_bathing_marker, 1);


%% Background noise with Fast Fourier Transform (FFT)

% acc_x_direction    =  acc_x_direction - mean(acc_x_direction);
% acc_y_direction    =  acc_y_direction - mean(acc_y_direction);
% acc_z_direction    =  acc_z_direction - mean(acc_z_direction);
% effective_acc_raw  =  effective_acc_raw - mean(effective_acc_raw);

% Plot of the detrend
% figure(1)
% plot(effective_acc_raw, '.-', 'MarkerSize', 6, 'Color', [0 0 0]);
% hold on
% yline(mean(effective_acc_raw), 'LineWidth', 2, 'Color', [0.6350 0.0780 0.1840]);
% title('Acceleration norm2')
% xlabel('Samples')
% ylabel('Acceleration')


% Data denoise
acc_x_denoise          =  wdenoise(double(acc_raw(:,1)));
acc_y_denoise          =  wdenoise(double(acc_raw(:,2)));
acc_z_denoise          =  wdenoise(double(acc_raw(:,3)));
effective_acc_denoise  =  wdenoise(double(acc_raw));

% figure(1)
% subplotFunction(timeStamp1, effective_acc_denoise, 1, 1, 1, 'Acceleration denoised', 'Time [hours]', 'Acceleration', [], 1);



% Detrend to remove the DC offset
acc_x_denoise           =  detrend(acc_x_denoise);
acc_y_denoise           =  detrend(acc_y_denoise);
acc_z_denoise           =  detrend(acc_z_denoise);
effective_acc_denoise   =  detrend(effective_acc_denoise);

% figure(1)
% subplotFunction(timeStamp1, effective_acc_denoise, 1, 1, 1, 'Acceleration detrended', 'Time [hours]', 'Acceleration', [], 1);




% Data filtering - 10th order butterworth
% [filteredData,  lowPassFilteredData,  highPassFilteredData]   =  dataFiltering(effective_acc_raw, 12, 0.5, 64, 10);
[XfilteredData, XlowPassFilteredData, XhighPassFilteredData]    =  dataFiltering(acc_x_denoise, 12, 0.5, 64, 10);
[YfilteredData, YlowPassFilteredData, YhighPassFilteredData]    =  dataFiltering(acc_y_denoise, 12, 0.5, 64, 10);
[ZfilteredData, ZlowPassFilteredData, ZhighPassFilteredData]    =  dataFiltering(acc_z_denoise, 12, 0.5, 64, 10);
[filteredData, lowPassFilteredData, highPassFilteredData]       =  dataFiltering(effective_acc_denoise, 12, 0.5, 64, 10);

% figure(1)
% subplotFunction(timeStamp1, filteredData, 1, 1, 1, 'Acceleration Filtered', 'Time [hours]', 'Acceleration', [], 1);


% Eucledian Norm to get the magnitude of acceleration
% normalizedFilteredData   =   vecnorm(filteredData, 2, 2);
% normalizedXfilteredData  =   vecnorm(XfilteredData, 2, 2);
% normalizedYfilteredData  =   vecnorm(YfilteredData, 2, 2);
% normalizedZfilteredData  =   vecnorm(ZfilteredData, 2, 2);

% OPTION 2 -  mean of the magnitude of acceleration
normalizedFilteredData      =   mean(filteredData, 2);
acc_raw_normalized_detrend  =   detrend(acc_raw_normalized);



% Plot the normalizedFilteredData
figure(3)
plot(timeStamp1, acc_raw_normalized_detrend, '.-', 'MarkerSize', 6, 'LineWidth', 2);
hold on;
plot(timeStamp1, normalizedFilteredData, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', [0.6350 0.0780 0.1840]);
xline(markers1, '--', 'Transition', 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment','center', 'LineWidth', 3);
% plot(effective_acc_denoise, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
ax  =   gca;
ax.FontSize  = 25;
title('Acceleration norm2', 'FontSize', 30)
xlabel('Hours', 'FontSize', 30)
ylabel('Acceleration', 'FontSize', 30)




%% FFT


% Fast Fourier Transformation
% [freq_range, powerX, powerY, powerZ, power_tot]                                                                   =  FastFourierTransform(acc_x_direction, acc_y_direction, acc_z_direction, effective_acc_raw, 64);
[freq_range_lowFiltered, powerX_lowFiltered, powerY_lowFiltered, powerZ_lowFiltered, power_tot_lowFiltered]       =  FastFourierTransform(XlowPassFilteredData, YlowPassFilteredData, ZlowPassFilteredData, lowPassFilteredData, 64);
[freq_range_highFiltered, powerX_highFiltered, powerY_highFiltered, powerZ_highFiltered, power_tot_highFiltered]  =  FastFourierTransform(XhighPassFilteredData, YhighPassFilteredData, ZhighPassFilteredData, highPassFilteredData, 64);
% [freq_range_filtered, powerX_filtered, powerY_filtered, powerZ_filtered, power_tot_filtered]                      =  FastFourierTransform(XfilteredData, YfilteredData, ZfilteredData, filteredData, 64);

% personal trial
[freq_range_filtered, powerX_filtered, powerY_filtered, powerZ_filtered, power_tot_filtered]                      =  FastFourierTransform(XfilteredData, YfilteredData, ZfilteredData, normalizedFilteredData, 64);



%% FFT for cropped signal in the Car Ride test

x_walkingSignal                         =   timeStamp1(find(timeStamp1 == 18.45):marker(end-1));
XfilteredData_walkingSignal             =   XfilteredData(find(timeStamp1 == 18.45):marker(end-1));
YfilteredData_walkingSignal             =   YfilteredData(find(timeStamp1 == 18.45):marker(end-1));
ZfilteredData_walkingSignal             =   ZfilteredData(find(timeStamp1 == 18.45):marker(end-1));
normalizedFilteredData_walkingSignal    =   normalizedFilteredData(find(timeStamp1 == 18.45):marker(end-1));

x_drivingSignal                         =   timeStamp1(marker(end-1):marker(end));
XfilteredData_drivingSignal             =   XfilteredData(marker(end-1):marker(end));
YfilteredData_drivingSignal             =   YfilteredData(marker(end-1):marker(end));
ZfilteredData_drivingSignal             =   ZfilteredData(marker(end-1):marker(end));
normalizedFilteredData_drivingSignal    =   normalizedFilteredData(marker(end-1):marker(end));

[freq_range_filtered_walkingSignal, powerX_filtered_walkingSignal, powerY_filtered_walkingSignal, powerZ_filtered_walkingSignal, power_tot_filtered_walkingSignal]      =   FastFourierTransform(XfilteredData_walkingSignal, YfilteredData_walkingSignal, ZfilteredData_walkingSignal, normalizedFilteredData_walkingSignal, 64);

[freq_range_filtered_drivingSignal, powerX_filtered_drivingSignal, powerY_filtered_drivingSignal, powerZ_filtered_drivingSignal, power_tot_filtered_drivingSignal]      =   FastFourierTransform(XfilteredData_drivingSignal, YfilteredData_drivingSignal, ZfilteredData_drivingSignal, normalizedFilteredData_drivingSignal, 64);


subplotFunction(freq_range_filtered_walkingSignal(1:length(freq_range_filtered_walkingSignal)/2), power_tot_filtered_walkingSignal(1:length(power_tot_filtered_walkingSignal)/2), 2, 1, 1, 'Walking Signal FFT', 'Frequency [Hz]', 'Amplitude', [], 2);
hold on
subplotFunction(freq_range_filtered_drivingSignal(1:length(freq_range_filtered_drivingSignal)/2), power_tot_filtered_drivingSignal(1:length(power_tot_filtered_drivingSignal)/2), 2, 1, 2, 'Driving Signal FFT', 'Frequency [Hz]', 'Amplitude', [], 2);

%% 10th Order Filtering Results

% filteredData_10th_order   =  filteredData;
% XfilteredData_10th_order  =  XfilteredData;
% YfilteredData_10th_order  =  YfilteredData;
% ZfilteredData_10th_order  =  ZfilteredData;
% 
% freq_range_filtered_10th_order  =  freq_range_filtered;
% powerX_filtered_10th_order      =  powerX_filtered;
% powerY_filtered_10th_order      =  powerY_filtered;
% powerZ_filtered_10th_order      =  powerZ_filtered;




%% Plot of the FFT of the two signals (filtered and not filtered)
% oldPowerTot = power_tot_filtered;
% power_tot_filtered = oldPowerTot(:,3);
% power_tot_filtered = vecnorm(oldPowerTot, 2, 2);


figure(1)

% Uncomment this if you want to have constant axis limits for all the subplots
% xLimits = [(min([freq_range_lowFiltered(1:length(freq_range_lowFiltered)/2), freq_range_highFiltered(1:length(freq_range_highFiltered)/2), freq_range_filtered(1:length(freq_range_filtered)/2)])), (max([freq_range_lowFiltered(1:length(freq_range_lowFiltered)/2), freq_range_highFiltered(1:length(freq_range_highFiltered)/2), freq_range_filtered(1:length(freq_range_filtered)/2)]))];
% yLimits = [(min([power_tot_lowFiltered(1:length(power_tot_highFiltered)/2), power_tot_highFiltered(1:length(power_tot_highFiltered)/2), power_tot_filtered(1:length(power_tot_filtered)/2)])), (max([power_tot_lowFiltered(1:length(power_tot_highFiltered)/2), power_tot_highFiltered(1:length(power_tot_highFiltered)/2), power_tot_filtered(1:length(power_tot_filtered)/2)]))];

subplotFunction(freq_range_lowFiltered(1:length(freq_range_lowFiltered)/2), power_tot_lowFiltered(1:length(power_tot_lowFiltered)/2), 1, 3, 1, 'Acceleration low-pass Filtered', 'Frequency [Hz]', 'Amplitude', [], 1);
hold on
% ylim([0 16000])
subplotFunction(freq_range_highFiltered(1:length(freq_range_highFiltered)/2), power_tot_highFiltered(1:length(power_tot_highFiltered)/2), 1, 3, 2, 'Acceleration high-pass Filtered', 'Frequency [Hz]', 'Amplitude', [], 1);
hold on
% ylim([0 16000])
subplotFunction(freq_range_filtered(1:length(freq_range_filtered)/2), power_tot_filtered(1:length(power_tot_filtered)/2), 1, 3, 3, 'Acceleration band-pass Filtered', 'Frequency [Hz]', 'Amplitude', [], 1);
% ylim([0 16000])



%% Data visualization

% figure(1)
% % First row
% subplotFunction(freq_range, powerX, 4, 3, 1, 'Acceleration X', 'Frequency', 'Acceleration', [], 4);
% hold on
% subplotFunction(freq_range_lowFiltered, powerX_lowFiltered, 4, 3, 2, 'Acceleration X low-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction(freq_range_filtered, powerX_filtered, 4, 3, 3, 'Acceleration X band-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% 
% % Second row
% subplotFunction(freq_range, powerY, 4, 3, 4, 'Acceleration Y', 'Frequency', 'Acceleration', [], 4);
% hold on
% subplotFunction(freq_range_lowFiltered, powerY_lowFiltered, 4, 3, 5, 'Acceleration Y low-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction(freq_range_filtered, powerY_filtered, 4, 3, 6, 'Acceleration Y band-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% 
% % Third row
% subplotFunction(freq_range, powerZ, 4, 3, 7, 'Acceleration Z', 'Frequency', 'Acceleration', [], 4);
% hold on
% subplotFunction(freq_range_lowFiltered, powerZ_lowFiltered, 4, 3, 8, 'Acceleration Z low-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction(freq_range_filtered, powerZ_filtered, 4, 3, 9, 'Acceleration Z band-pass Filtered', 'Frequency', 'Acceleration', [], 1);
% hold on
% 
% % Fourth row
% subplotFunction([], effective_acc_raw, 4, 3, 10, 'Acceleration normalized not filtered', 'Samples', 'Acceleration', [], 1);
% hold on
% subplotFunction([], lowPassFilteredData, 4, 3, 11, 'Acceleration normalized low pass filtered only', 'Samples', 'Acceleration', [], 1);
% hold on
% subplotFunction([], filteredData, 4, 3, 12, 'Acceleration normalized band pass filtered only', 'Samples', 'Acceleration', [], 1);




%% Plot of the two signals (filtered and non filtered) on top of each other

figure(1)
% plot(acc_raw, 'Color', [0.9290 0.6940 0.1250]);
subplotFunction([], acc_raw, 1, 1, 1, 'Raw vs Filtered', 'Samples', 'Acc', [], 2);
hold on
% subplotFunction([], filteredData_10th_order, 1, 1, 1, 'Raw vs Filtered', 'Samples', 'Acc', [], 4);
% hold on
subplotFunction([], filteredData, 1, 1, 1, 'Raw vs Filtered', 'Samples', 'Acc', [], 3);
legend('raw signal', 'filtered');





%% Velocity Calculation

velocitySignal    =  filteredData;
velocitySignal    =  cumtrapz(velocitySignal);


XvelocitySignal  =  XfilteredData;
XvelocitySignal  =  cumtrapz(XvelocitySignal);

YvelocitySignal  =  YfilteredData;
YvelocitySignal  =  cumtrapz(YvelocitySignal);

ZvelocitySignal  =  ZfilteredData;
ZvelocitySignal  =  cumtrapz(ZvelocitySignal);

subplotFunction([], velocitySignal, 1, 1, 1, 'Speed', 'Samples', 'Vel [m/s]', [], 1);

figure(2)
scatter3(XvelocitySignal, YvelocitySignal, ZvelocitySignal, '.', 'LineWidth', 2);

% filteredData   =  velocitySignal;
% XfilteredData  =  XvelocitySignal;
% YfilteredData  =  YvelocitySignal;
% ZfilteredData  =  ZvelocitySignal;

% Velocity Cloud Plot
figure(3)
[Velocity_volume]  =  cloudPointsVolumeAnalysis([XvelocitySignal, YvelocitySignal, ZvelocitySignal], []);
% figure(2)
% [Velocity_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1(length(acc_Bath_1)/2:end, :), []);



% Cloud points volume analysis half-to-half
% figure(1)
% [meals_1_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1(1:length(acc_Bath_1)/2, :), []);
% figure(2)
% [meals_1_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1(length(acc_Bath_1)/2:end, :), []);
% 
% figure(3)
% [meals_2_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_2(1:length(acc_Bath_2)/2, :), []);
% figure(4)
% [meals_2_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_2(length(acc_Bath_2)/2:end, :), []);
% 
% figure(5)
% [meals_3_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_3(1:length(acc_Bath_3)/2, :), []);
% figure(6)
% [meals_3_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_3(length(acc_Bath_3)/2:end, :), []);
% 
% figure(7)
% [meals_4_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_4(1:length(acc_Bath_4)/2, :), []);
% figure(8)
% [meals_4_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_4(length(acc_Bath_4)/2:end, :), []);


%% STORING THE DATA - remember to change the visit #

E_16.Screening.Velocity              =   velocitySignal;
E_16.Screening.Acceleration           =   filteredData;
E_16.Screening.AccelerationX          =   XfilteredData;
E_16.Screening.AccelerationY          =   YfilteredData;
E_16.Screening.AccelerationZ          =   ZfilteredData;
E_16.Screening.GyroscopeData          =   realGyroscopeSignal;


%% Meals Signal Separation

% acc_Meal_1_norm  =  signalSeparation(filteredData, 1, effective_meals_marker(1));
% acc_Meal_1       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], 1, effective_meals_marker(1));
% 
% acc_Meal_2_norm  =  signalSeparation(filteredData, effective_meals_marker(1), effective_meals_marker(2));
% acc_Meal_2       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(1), effective_meals_marker(2));
% 
% acc_Meal_3_norm  =  signalSeparation(filteredData, effective_meals_marker(2), effective_meals_marker(3));
% acc_Meal_3       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(2), effective_meals_marker(3));
% accelerometerData
% acc_Meal_4_norm  =  signalSeparation(filteredData, effective_meals_marker(3), effective_meals_marker(4));
% acc_Meal_4       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(3), effective_meals_marker(4));
% 
% acc_Meal_5_norm  =  signalSeparation(filteredData, effective_meals_marker(4), effective_meals_marker(5));
% acc_Meal_5       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(4), effective_meals_marker(5));
% 
% acc_Meal_6_norm  =  signalSeparation(filteredData, effective_meals_marker(5), effective_meals_marker(6));
% acc_Meal_6       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(5), effective_meals_marker(6));
% 
% acc_Meal_7_norm  =  signalSeparation(filteredData, effective_meals_marker(6), effective_meals_marker(7));
% acc_Meal_7       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_meals_marker(6), effective_meals_marker(7));
% 
% 
% figure(1)
% % First row
% subplotFunction([], acc_Meal_1_norm, 4, 2, 1, 'Meal_1', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_2_norm, 4, 2, 2, 'Meal 2', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_3_norm, 4, 2, 3, 'Meal 3', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_4_norm, 4, 2, 4, 'Meal 4', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_5_norm, 4, 2, 5, 'Meal 5', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_6_norm, 4, 2, 6, 'Meal 6', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Meal_7_norm, 4, 2, 7, 'Meal 7', 'Frequency', 'Acceleration', [], 1);
% 
% 
% 
% % Cloud points volume analysis
% figure(1)
% [meals_1_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_1, []);
% figure(2)
% [meals_2_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_2, []);
% figure(3)
% [meals_3_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_3, []);
% figure(4)
% [meals_4_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_4, []);
% figure(5)
% [meals_5_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_5, []);
% figure(6)
% [meals_6_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_6, []);
% figure(7)
% [meals_7_volume]  =  cloudPointsVolumeAnalysis(acc_Meal_7, []);



%% Bathing Signal Separation

% acc_Bath_1_norm  =  signalSeparation(filteredData, 1, effective_bathing_marker(1));
% acc_Bath_1       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], 1, effective_bathing_marker(1));
% 
% acc_Bath_2_norm  =  signalSeparation(filteredData, effective_bathing_marker(1), effective_bathing_marker(2));
% acc_Bath_2       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_bathing_marker(1), effective_bathing_marker(2));
% 
% acc_Bath_3_norm  =  signalSeparation(filteredData, effective_bathing_marker(2), effective_bathing_marker(3));
% acc_Bath_3       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_bathing_marker(2), effective_bathing_marker(3));
% 
% acc_Bath_4_norm  =  signalSeparation(filteredData, effective_bathing_marker(3), effective_bathing_marker(4));
% acc_Bath_4       =  signalSeparation([XfilteredData, YfilteredData, ZfilteredData], effective_bathing_marker(3), effective_bathing_marker(4));
% 
% 
% 
% figure(1)
% % First row
% subplotFunction([], acc_Bath_1_norm, 1, 4, 1, 'Action 1', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Bath_2_norm, 1, 4, 2, 'Action 2', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Bath_3_norm, 1, 4, 3, 'Action 3', 'Frequency', 'Acceleration', [], 1);
% hold on
% subplotFunction([], acc_Bath_4_norm, 1, 4, 4, 'Action 4', 'Frequency', 'Acceleration', [], 1);
% 
% 
% % Cloud points volume analysis
% figure(1)
% [meals_1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1, []);
% figure(2)
% [meals_2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_2, []);
% figure(3)
% [meals_3_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_3, []);
% figure(4)
% [meals_4_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_4, []);
% 
% 
% 
% % Cloud points volume analysis half-to-half
% figure(1)
% [meals_1_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1(1:length(acc_Bath_1)/2, :), []);
% figure(2)
% [meals_1_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_1(length(acc_Bath_1)/2:end, :), []);
% 
% figure(3)
% [meals_2_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_2(1:length(acc_Bath_2)/2, :), []);
% figure(4)
% [meals_2_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_2(length(acc_Bath_2)/2:end, :), []);
% 
% figure(5)
% [meals_3_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_3(1:length(acc_Bath_3)/2, :), []);
% figure(6)
% [meals_3_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_3(length(acc_Bath_3)/2:end, :), []);
% 
% figure(7)
% [meals_4_half1_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_4(1:length(acc_Bath_4)/2, :), []);
% figure(8)
% [meals_4_half2_volume]  =  cloudPointsVolumeAnalysis(acc_Bath_4(length(acc_Bath_4)/2:end, :), []);
% 
% 




%% Signal to Noise Ratio
noiseStart       =  38878*64;
noiseEnd         =  55240*64;
backgroundNoise  =  acc_raw_normalized(noiseStart:noiseEnd);
backgroundNoise  =  detrend(double(backgroundNoise));
finalNoise       =  [];

for count = 1 : floor(length(effective_acc_raw) / length(backgroundNoise)) + 1

    finalNoise  =  [finalNoise, backgroundNoise'];

end

finalNoise  =  finalNoise(1:length(effective_acc_raw));

signalNoiseRatio  =  snr(filteredData, finalNoise);  % SNR = 21

signalNoiseRatio_notFiltered  =  snr(effective_acc_raw, finalNoise);  % SNR = 40



figure(6)
subplotFunction([], filteredData, 1, 1, 1, 'Raw vs Filtered', 'Samples', 'Acc', [], 4);
hold on
subplotFunction([], finalNoise, 1, 1, 1, 'Raw vs Filtered', 'Samples', 'Acc', [], 2);
legend('Filtered Signal', 'Noise')


%% Area Under the Curve
% figure(1)
% [AUC_bath1_half1, CUMTRAP]  =  areaUnderTheCurve(acc_Bath_1_norm(1:length(acc_Bath_1_norm)/2), '1st Bathing half-1');
% figure(2)
% AUC_bath1_half2  =  areaUnderTheCurve(acc_Bath_1_norm(length(acc_Bath_1_norm)/2:end), '1st Bathing half-2');
% 
% figure(3)
% AUC_bath2_half1  =  areaUnderTheCurve(acc_Bath_2_norm(1:length(acc_Bath_2_norm)/2), '2nd Bathing half-1');
% figure(4)
% AUC_bath2_half2  =  areaUnderTheCurve(acc_Bath_2_norm(length(acc_Bath_2_norm)/2:end), '2nd Bathing half-2');
% 
% figure(5)
% AUC_bath3_half1  =  areaUnderTheCurve(acc_Bath_3_norm(1:length(acc_Bath_3_norm)/2), '3rd Bathing half-1');
% figure(6)
% AUC_bath3_half2  =  areaUnderTheCurve(acc_Bath_3_norm(length(acc_Bath_3_norm)/2:end), '3rd Bathing half-2');
% 
% figure(7)
% AUC_bath4_half1  =  areaUnderTheCurve(acc_Bath_4_norm(1:length(acc_Bath_4_norm)/2), '4th Bathing half-1');
% figure(8)
% AUC_bath4_half2  =  areaUnderTheCurve(acc_Bath_4_norm(length(acc_Bath_4_norm)/2:end), '4th Bathing half-2');
% 
% 
% plot(CUMTRAP)
