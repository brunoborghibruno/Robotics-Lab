%% BRUNO BORGHI - Power Spectrum results
% Given the FFT values of the signals you want to compare, calculate the PSD and normalize it to see the percentage change


%% Calculate the PSD for all the input signal

powerSpectrum_E5_1  =   abs(power_E5_1/length(freq_E5_1)).^2;                   % Two-sided power spectrum
powerSpectrum_E5_1  =   powerSpectrum_E5_1(1:floor(length(freq_E5_1)/2)+1);     % Keep only the positive frequencies
powerFreq_E5_1      =   freq_E5_1(1:floor(length(freq_E5_1)/2)+1);              % Corresponding frequency vector



%% Frequency Bands:     0>freq>1 = rest/slow movements      1>freq>5 = active/functional upper-limb movements

% E-5
freq_rest_E5_1    =  find(freq_E5_1 >= 0 & freq_E5_1 <= 1);
freq_active_E5_1  =  find(freq_E5_1 > 1  & freq_E5_1 <= 5);

freq_rest_E5_4    =  find(freq_E5_4 >= 0 & freq_E5_4 <= 1);
freq_active_E5_4  =  find(freq_E5_4 > 1  & freq_E5_4 <= 5);

freq_rest_E5_7    =  find(freq_E5_7 >= 0 & freq_E5_7 <= 1);
freq_active_E5_7  =  find(freq_E5_7 > 1  & freq_E5_7 <= 5);


% E-16
freq_rest_E16_1    =  find(freq_E16_1 >= 0 & freq_E16_1 <= 1);
freq_active_E16_1  =  find(freq_E16_1 > 1  & freq_E16_1 <= 5);

freq_rest_E16_4    =  find(freq_E16_4 >= 0 & freq_E16_4 <= 1);
freq_active_E16_4  =  find(freq_E16_4 > 1  & freq_E16_4 <= 5);

freq_rest_E16_7    =  find(freq_E16_7 >= 0 & freq_E16_7 <= 1);
freq_active_E16_7  =  find(freq_E16_7 > 1  & freq_E16_7 <= 5);




%% Compute power in each band

% E-5
power_total_E5_1    =   sum(power_E5_1); 
power_rest_E5_1     =   sum(power_E5_1(freq_rest_E5_1));
power_active_E5_1   =   sum(power_E5_1(freq_active_E5_1));

power_total_E5_4    =   sum(power_E5_4); 
power_rest_E5_4     =   sum(power_E5_1(freq_rest_E5_4));
power_active_E5_4   =   sum(power_E5_1(freq_active_E5_4));

power_total_E5_7    =   sum(power_E5_7); 
power_rest_E5_7     =   sum(power_E5_1(freq_rest_E5_7));
power_active_E5_7   =   sum(power_E5_1(freq_active_E5_7));

% E-16
power_total_E16_1    =   sum(power_E16_1); 
power_rest_E16_1     =   sum(power_E16_1(freq_rest_E16_1));
power_active_E16_1   =   sum(power_E16_1(freq_active_E16_1));

power_total_E16_4    =   sum(power_E16_4); 
power_rest_E16_4     =   sum(power_E16_1(freq_rest_E16_4));
power_active_E16_4   =   sum(power_E16_1(freq_active_E16_4));

power_total_E16_7    =   sum(power_E16_7); 
power_rest_E16_7     =   sum(power_E16_1(freq_rest_E16_7));
power_active_E16_7   =   sum(power_E16_1(freq_active_E16_7));



%% Relative Power

% E-5
relativePower_rest_E5_1      =  power_rest_E5_1 / power_total_E5_1;
relativePower_active_E5_1    =  power_active_E5_1 / power_total_E5_1;

relativePower_rest_E5_4      =  power_rest_E5_4 / power_total_E5_4;
relativePower_active_E5_4    =  power_active_E5_4 / power_total_E5_4;

relativePower_rest_E5_7      =  power_rest_E5_7 / power_total_E5_7;
relativePower_active_E5_7    =  power_active_E5_7 / power_total_E5_7;


% E-16
relativePower_rest_E16_1      =  power_rest_E16_1 / power_total_E16_1;
relativePower_active_E16_1    =  power_active_E16_1 / power_total_E16_1;

relativePower_rest_E16_4      =  power_rest_E16_4 / power_total_E16_4;
relativePower_active_E16_4    =  power_active_E16_4 / power_total_E16_4;

relativePower_rest_E16_7      =  power_rest_E16_7 / power_total_E16_7;
relativePower_active_E16_7    =  power_active_E16_7 / power_total_E16_7;