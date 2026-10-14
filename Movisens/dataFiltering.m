%% BRUNO BORGHI - Data Filtering 

function [filteredData, lowPassFilteredData, highPassFilteredData]  =  dataFiltering(data, lowPassFreq, highPassFreq, sampleFreq, order)


if nargin<5  || isempty(order)
    order = 5;    % Butterworth 5th order filter design
end

if nargin<4  || isempty(sampleFreq)
    sampleFreq = 64;    % Butterworth 5th order filter design
end



% Filter Order and Frequencies

Wp      =  [highPassFreq, lowPassFreq] / (sampleFreq/2);
Ws      =  [0.25, 14] / (sampleFreq/2); % stop-band values, hardcoded
Rp      =  1; % max dB of passband ripple
Rs      =  10; % min dB of attenuation in the stopband
[n, Wn] = buttord(Wp, Ws, Rp, Rs);




% low pass filtering

% figure(1)
% [z, p, k]      =  butter(n, Wn(2));
% sos            =  zp2sos(z, p, k);
% freqz(sos, 500, sampleFreq);
% title(sprintf('n = %d Butterworth Low-Pass Filter',n));
[b_low, a_low] =  butter(n, Wn(2), 'low');

lowPassFilteredData  =  filtfilt(b_low, a_low, double(data));



% high-pass filtering

% figure(2)
% [z, p, k]      =  butter(n, Wn(1));
% sos            =  zp2sos(z, p, k);
% freqz(sos, 500, sampleFreq);
% title(sprintf('n = %d Butterworth High-Pass Filter',n))
[b_high, a_high] =  butter(n, Wn(1), 'high');

highPassFilteredData  =  filtfilt(b_high, a_high, double(data));



% band-pass filtered data

[z, p, k]      =  butter(n, Wn);
sos            =  zp2sos(z, p, k);
% freqz(sos, 500, sampleFreq);
% title(sprintf('n = %d Butterworth Band-Pass Filter',n));

[b, a] =  butter(n, Wn, 'bandpass');
filteredData  =  filtfilt(b, a, double(data));

filteredData = filteredData - mean(filteredData, 1);
lowPassFilteredData = lowPassFilteredData - mean(lowPassFilteredData, 1);
highPassFilteredData = highPassFilteredData - mean(highPassFilteredData, 1);




end