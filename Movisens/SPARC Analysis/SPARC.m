%% BRUNO BORGHI - SPARC (spectral arc length) smoothness of one movement
%
% S = SPARC(speed, fs)
%   speed : speed profile of ONE movement (vector). Here the wrist angular speed from the Move 4 gyroscope (deg/s),
%           but any speed works: SPARC does not depend on units or amplitude.
%   fs    : sample rate (Hz), 64 for the Move 4.
%   S     : smoothness, always negative. Closer to 0 = smoother. One minimum-jerk movement at 64 Hz gives -1.40,
%           two overlapping submovements -1.75, three -1.99 (checked against the reference code below).
%
% Idea: a smooth movement has a speed profile with few, low frequencies, so its spectrum is short and simple.
% A movement broken into submovements has a longer, bumpier spectrum. SPARC is minus the length of that spectrum curve.
%
% Method (same steps as Balasubramanian et al. 2015 and their reference code):
%   1. Zero-pad the speed to 2^(nextpow2(N) + 4) samples, for a finely sampled spectrum.
%   2. FFT magnitude, divided by its peak (the DC value for a speed), so the curve starts at 1.
%   3. Keep frequencies up to 10 Hz (human movement is below this).
%   4. Adaptive cut-off: keep only up to the last frequency where the magnitude is >= 5% of the peak, so the
%      noise floor does not add length.
%   5. Arc length of the curve, with frequency normalised by the cut-off: sum of sqrt(df^2 + dM^2). S = minus that.
%
% Why the gyroscope: SPARC needs a speed profile. Integrating accelerometer data to velocity drifts, and gravity
% has to be removed first; the gyroscope gives angular speed directly. SPARC on IMU rotational data is
% recommended by Melendez-Calderon et al. 2021.
%
% Sources:
%   - Balasubramanian S, Melendez-Calderon A, Burdet E. A robust and sensitive metric for quantifying movement
%     smoothness. IEEE Trans Biomed Eng 2012;59(8):2126-2136.
%   - Balasubramanian S, Melendez-Calderon A, Roby-Brami A, Burdet E. On the analysis of movement smoothness.
%     J NeuroEng Rehabil 2015;12:112. Reference code: https://github.com/siva82kb/smoothness
%   - Melendez-Calderon A, Shirota C, Balasubramanian S. Estimating movement smoothness from inertial measurement
%     units. Front Bioeng Biotechnol 2021;8:558771.
%   - Saes M et al. Smoothness metric during reach-to-grasp after stroke: part 2. Longitudinal association with
%     motor impairment. J NeuroEng Rehabil 2021 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8461930/).
%     SPARC improved together with Fugl-Meyer in the first weeks after stroke.
%   - Movisens Move 4 datasheet (gyroscope +/-2000 deg/s, 70 mdps per count, 64 Hz):
%     https://www.movisens.com/en/products/move-4/

function S = SPARC(speed, fs)

padLevel     =  4;       % zero padding: FFT length = 2^(nextpow2(N) + 4)
fcMax        =  10;      % Hz, highest frequency considered
ampThreshold =  0.05;    % spectrum below 5% of its peak is treated as noise

nfft    =  2^(ceil(log2(length(speed))) + padLevel);
f       =  (0:nfft-1)' * fs / nfft;
M       =  abs(fft(speed(:), nfft));
M       =  M / max(M);                 % normalised magnitude spectrum

keep    =  f <= fcMax;
f       =  f(keep);
M       =  M(keep);

aboveTh =  find(M >= ampThreshold);    % adaptive cut-off: last frequency above the threshold
f       =  f(aboveTh(1):aboveTh(end));
M       =  M(aboveTh(1):aboveTh(end));

S       =  -sum(sqrt((diff(f) / (f(end) - f(1))).^2 + diff(M).^2));

end
