function [onsetTime, onsetIdx, Um, info] = maccOnset(pos, t, varargin)
%MACCONSET  Movement-onset detection using the MACC model (Botzer & Karniel, 2009).
%
%   Reimplementation of the "minimum acceleration with constraints" (MACC)
%   based onset detector described in:
%       Botzer L. & Karniel A. (2009), "A simple and accurate onset
%       detection method for a measured bell-shaped speed profile",
%       Front. Neurosci. 3:61. doi:10.3389/neuro.20.002.2009
%
%   The idea: a recorded 1-D position signal is modelled as a static phase
%   (constant position x0) followed, after an unknown change-point t0, by a
%   constant-jerk movement phase. During the very start of the movement the
%   position follows a pure cubic in time:
%
%           x(t) = x0 + (Um/6)*(t - t0)^3 ,   t > t0
%
%   (constant jerk Um; zero initial velocity & acceleration). For every
%   candidate change-point the static part is fit by the segment mean and
%   the movement part is fit for Um by linear least squares. The onset is
%   the change-point that minimises the combined RMS error. Um at that point
%   is the estimate of the initial feed-forward jerk command.
%
%   [onsetTime, onsetIdx, Um, info] = maccOnset(pos, t, ...)
%
%   INPUTS
%     pos : position signal.
%             - N-by-1 vector for a 1-D signal, OR
%             - N-by-D matrix (D = 2 or 3). Multi-dimensional input is
%               reduced to the cumulative path length (a monotone,
%               bell-shaped-speed 1-D signal) before detection.
%     t   : time base. Either
%             - an N-by-1 time vector (seconds), OR
%             - a scalar sampling interval Ts (seconds), OR
%             - [] to assume Ts = 1 (onset returned in samples).
%
%   NAME-VALUE OPTIONS
%     'm'            Segment length in samples for both the static and the
%                    initial-movement windows. Default 15 (the value used in
%                    the paper; ~150 ms at 100 Hz). Larger m = less noise but
%                    more model-misfit / feedback contamination.
%     'VelThreshFrac'Fraction of peak speed used only to bound the search
%                    (onset must precede this point). Default 0.20.
%     'FilterCutoff' Low-pass cutoff (Hz) applied to the position ONLY for
%                    the velocity/peak estimate used to bound the search.
%                    The MACC fit always uses the raw position. Default []
%                    (no Butterworth; a light moving-average is used
%                    instead). Butterworth requires the Signal Processing
%                    Toolbox; if unavailable the code falls back gracefully.
%                    Ignored when SpeedSignal is supplied.
%     'SpeedSignal'  N-by-1 externally measured speed signal (e.g.
%                    vecnorm of encoder-measured GlobalVelocity). When
%                    provided this signal is used instead of differentiating
%                    the position to bound the search. Only a light
%                    moving-average is applied for smoothing. The MACC cubic
%                    fit on position is unaffected. Default [] (disabled).
%     'Plot'         true/false. Draw position, speed and the model-error
%                    curve with the detected onset. Default false.
%
%   OUTPUTS
%     onsetTime : detected onset time (seconds, or samples if t is []).
%     onsetIdx  : index into pos/t of the detected onset (t0 = t(onsetIdx)).
%     Um        : estimated initial mean jerk at onset (feed-forward command).
%     info      : struct with fields
%                   .errCurve      combined RMS error vs candidate index (NaN
%                                  outside the searched range)
%                   .searchIdx     candidate change-point indices evaluated
%                   .searchMax     upper-bound index used (20% peak-speed rule)
%                   .signal        the 1-D signal actually analysed
%                   .m, .Ts        parameters used
%                   .externalSpeed true when SpeedSignal was used for bounding
%
%   EXAMPLE
%     Ts = 0.01;  t = (0:Ts:3)';
%     x  = zeros(size(t));  t0 = 0.5;  Tf = 1.5;  xf = 0.3;   % min-jerk move
%     mv = t>t0 & t<t0+Tf;  tau = (t(mv)-t0)/Tf;
%     x(mv) = xf*(10*tau.^3 - 15*tau.^4 + 6*tau.^5);  x(t>=t0+Tf) = xf;
%     x = x + 5e-4*randn(size(x));
%     [ons, idx, Um] = maccOnset(x, t, 'Plot', true);
%     fprintf('Onset = %.3f s (true 0.500), Um = %.4g\n', ons, Um);
%
%   Notes on faithfulness to the paper:
%     * Static model per segment  -> segment mean (Eq. 5).
%     * Movement model per segment -> constant-jerk cubic, x0 = mean of the
%       preceding static segment, t0 = end of that segment, Um by RMS/least-
%       squares fit on the following segment (Eq. 6).
%     * Cost = sum of the two RMS errors (Eq. 7); onset = its minimiser
%       (Eq. 8), searched only up to the 20%-peak-speed point.
%     * If several local minima exist, the LATEST is chosen, as in the paper.

% ---------------------------------------------------------------------------
% Parse inputs
% ---------------------------------------------------------------------------
p = inputParser;
p.addParameter('m', 15, @(v)isnumeric(v)&&isscalar(v)&&v>=2);
p.addParameter('VelThreshFrac', 0.20, @(v)isnumeric(v)&&isscalar(v)&&v>0&&v<1);
p.addParameter('FilterCutoff', [], @(v)isempty(v)||(isnumeric(v)&&isscalar(v)&&v>0));
p.addParameter('SpeedSignal', [], @(v)isempty(v)||(isnumeric(v)&&isvector(v)));
p.addParameter('Plot', false, @(v)islogical(v)||ismember(v,[0 1]));
p.parse(varargin{:});
m        = round(p.Results.m);
vfr      = p.Results.VelThreshFrac;
fc       = p.Results.FilterCutoff;
extSpeed = p.Results.SpeedSignal(:);   % force column (empty stays empty)
doPlot   = logical(p.Results.Plot);

% ----- position: reduce to a 1-D signal (path length for multi-D) ----------
pos = double(pos);
if isrow(pos), pos = pos(:); end
if size(pos,2) > 1
    d = sqrt(sum(diff(pos,1,1).^2, 2));   % step distances
    x = [0; cumsum(d)];                   % cumulative path length
else
    x = pos(:);
end
N = numel(x);

% ----- time base -----------------------------------------------------------
if nargin < 2 || isempty(t)
    Ts = 1;  t = (0:N-1)'.*Ts;            % onset reported in samples
elseif isscalar(t)
    Ts = double(t);  t = (0:N-1)'.*Ts;
else
    t  = double(t(:));
    if numel(t) ~= N
        error('maccOnset:timeSize','t must match the number of position samples.');
    end
    Ts = median(diff(t));
end

if N < 2*m + 1
    error('maccOnset:tooShort', ...
        'Signal has %d samples but needs at least 2*m+1 = %d.', N, 2*m+1);
end

% ----- validate external speed signal length --------------------------------
if ~isempty(extSpeed) && numel(extSpeed) ~= N
    error('maccOnset:speedSize', ...
        'SpeedSignal has %d samples but pos has %d.', numel(extSpeed), N);
end

% ---------------------------------------------------------------------------
% Bound the search: onset must lie before the rising flank crosses the
% velocity threshold.
%
% When SpeedSignal is supplied it is used directly (encoder-measured speed
% is cleaner than differentiating position). Otherwise speed is derived from
% the position, optionally low-pass filtered first.
% ---------------------------------------------------------------------------
sw = max(3, round(m/2));   % moving-average window for smoothing

if ~isempty(extSpeed)
    % External speed: apply only a light moving-average for smoothing.
    % FilterCutoff is intentionally ignored here.
    av = movmean(extSpeed, sw);
else
    xForVel = x;
    if ~isempty(fc) && exist('butter','file')==2 && exist('filtfilt','file')==2
        Wn = fc / (0.5/Ts);
        if Wn > 0 && Wn < 1
            [b,a]   = butter(2, Wn);
            xForVel = filtfilt(b, a, x);
        end
    end
    v  = gradient(xForVel, t);
    av = movmean(abs(v), sw);
end

[vpk, pk] = max(av);
thr = vfr * vpk;

% walk back from the speed peak to the first sample of the rising flank
i = pk;
while i > 1 && av(i-1) >= thr
    i = i - 1;
end
searchMax = i;                            % onset assumed before this index

% valid candidate change-points q: static seg = q-m+1..q, move seg = q+1..q+m
qLo = m;
qHi = min(searchMax, N - m);
if qHi < qLo                              % pathological / very noisy: open up
    qHi = N - m;
end

% ---------------------------------------------------------------------------
% Evaluate the joint model at every candidate change-point
% ---------------------------------------------------------------------------
errCurve = nan(N,1);
UmCurve  = nan(N,1);
for q = qLo:qHi
    % static phase: mean of the preceding segment
    stat = x(q-m+1:q);
    x0   = mean(stat);
    eStat = sqrt(mean((stat - x0).^2));

    % movement phase: constant-jerk cubic on the following segment
    t0  = t(q);
    mi  = (q+1):(q+m);
    r   = (t(mi) - t0).^3 / 6;            % regressor (column)
    xm  = x(mi);
    Umq = sum(r .* (xm - x0)) / sum(r.^2);% least-squares jerk (x0 fixed)
    eMov = sqrt(mean((xm - (x0 + Umq.*r)).^2));

    errCurve(q) = eStat + eMov;           % combined RMS error (Eq. 7)
    UmCurve(q)  = Umq;
end

% ---------------------------------------------------------------------------
% Select onset = latest local minimum of the error curve (Eq. 8)
% ---------------------------------------------------------------------------
valid = find(~isnan(errCurve));
isMin = false(N,1);
for k = 1:numel(valid)
    q = valid(k);
    leftOK  = (k==1)            || errCurve(q) <= errCurve(valid(k-1));
    rightOK = (k==numel(valid)) || errCurve(q) <= errCurve(valid(k+1));
    isMin(q) = leftOK && rightOK;
end
locmins = find(isMin);
if isempty(locmins)
    [~,onsetIdx] = min(errCurve);         % fallback: global minimum
else
    onsetIdx = locmins(end);              % latest local minimum
end

onsetTime = t(onsetIdx);
Um        = UmCurve(onsetIdx);

info = struct('errCurve', errCurve, 'searchIdx', (qLo:qHi)', ...
              'searchMax', searchMax, 'signal', x, 'm', m, 'Ts', Ts, ...
              'externalSpeed', ~isempty(extSpeed));

% ---------------------------------------------------------------------------
% Optional diagnostic plot
% ---------------------------------------------------------------------------
if doPlot
    figure('Name','MACC onset detection','Color','w');
    ax1 = subplot(3,1,1);
    plot(t, x, 'b'); hold on;
    xline(onsetTime,'k--','LineWidth',1.2);
    ylabel('position'); title('MACC-based onset detection'); grid on;
    ax2 = subplot(3,1,2);
    plot(t, av, 'Color',[0 .5 0]); hold on;
    yline(thr,':','20% peak','Color',[.4 .4 .4]);
    xline(onsetTime,'k--');
    if ~isempty(extSpeed)
        ylabel('speed (external)');
    else
        ylabel('speed (from pos)');
    end
    grid on;
    ax3 = subplot(3,1,3);
    plot(t, errCurve, 'r'); hold on;
    plot(onsetTime, errCurve(onsetIdx), 'ko','MarkerFaceColor','k');
    xline(onsetTime,'k--'); ylabel('model error'); xlabel('time'); grid on;
    linkaxes([ax1 ax2 ax3],'x');
end
end