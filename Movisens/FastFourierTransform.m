%% BRUNO BORGHI - Fast Fourirer Transform

function [freq_range, power1, power2, power3, power_tot] = FastFourierTransform(acc_x_direction, acc_y_direction, acc_z_direction, effective_acc_raw, fs)


if nargin<5  || isempty(fs)
    fs = 64;    % 64Hz
end

fn  =  fs/2; % Since only half of the fft is useful, the other half is just the mirrored part
n           =  length(effective_acc_raw);

% create the Fast Fourirer Transform 

fft_1 = fft(acc_x_direction); 
fft_2 = fft(acc_y_direction); 
fft_3 = fft(acc_z_direction); 
fft_effective  =  fft(effective_acc_raw);


freq_range  =  (0:n-1)*(fs/n);  % fs = sampling frequency
power1      =  abs(fft_1).^2/n;
power2      =  abs(fft_2).^2/n;
power3      =  abs(fft_3).^2/n;
power_tot   =  abs(fft_effective).^2/n;



% figure(4)
% 
% subplot(4, 1, 1)
% plot(freq_range, power_tot, '.-', 'MarkerSize', 6, 'Color', [0 0 0]) 
% title('FFT directions module')
% xlabel('Frequency')
% ylabel('Power')
% 
% subplot(4,1,2)
% plot(freq_range, power1, '.-', 'MarkerSize', 6, 'Color', [0 0.4470 0.7410])  % Color Blue = [0 0.4470 0.7410]
% title('FFT X direction')
% xlabel('Frequency')
% ylabel('Power')
% 
% 
% subplot(4,1,3)
% plot(freq_range, power2, '.-', 'MarkerSize', 6, 'Color', [0.6350 0.0780 0.1840]) % Color Red = [0.6350 0.0780 0.1840]
% title('FFT Y direction')
% xlabel('Frequency')
% ylabel('Power')
% 
% 
% subplot(4,1,4)
% plot(freq_range, power3, '.-', 'MarkerSize', 6, 'Color', [0.9290 0.6940 0.1250]) % Color Yellow = [0.9290 0.6940 0.1250]
% title('FFT Z direction')
% xlabel('Frequency')
% ylabel('Power')

end