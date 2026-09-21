%% Bimodal Extent-Error Distributions
%
%  Same scan logic as MovementOnsetDetectionAnalysis.m: loads every patient
%  visit from disk (no global Data) and pools their trajectories.
%
%  Draws four axes (one per practiced direction, 0..3). For each direction it
%  gathers the ExtentError vs. time curve of EVERY intermittent-exposure trial
%  of that direction, across ALL patients and ALL visits — i.e. the trials
%  whose Data-cell indices are listed in
%       SpecialMovementIndex.IntermittentExposure.DirectionZero  (direction 0)
%                                              .DirectionOne   (direction 1)
%                                              .DirectionTwo   (direction 2)
%                                              .DirectionThree (direction 3)
%  (these hold DIRECT indices into that visit's Data cell array, not
%  MovementNumbers).
%
%  Each trial's time axis is shifted so the launch onset sits at t = 0 (as
%  PlotTimeSeries in InspectIndividualTrial does). All trials of a direction
%  are then resampled onto a common time grid and summarised as:
%    - a THICK mean line (the direction colour, four colours total), and
%    - a SEMI-TRANSPARENT band spanning mean +/- 2 * standard deviation.
%
%  X axis = time (s), Y axis = extent-error magnitude.

% ── Options ─────────────────────────────────────────────────────────────────
UNIT                =   'm';    % 'm' or 'cm' for the extent-error magnitude axis
RESAMPLE_DT         =   0.01;   % common time-grid step [s] (trials are ~10 ms sampled)
MIN_COVERAGE        =   0.5;    % keep the band only where >= this fraction of trials exist
SPEED_ALPHA         =   0.4;   % line transparency for the overlaid individual speed trials
SPEED_FRACTION      =   1;   % fraction of speed trials to plot per direction (0.10 = 10%, 0.20 = 20%, 1.00 = all)
SPEED_SEED          =   42;     % RNG seed for the random subsample (fixed = same trials each run; [] = different each run)
SPEED_WIDTH         =   3;      % speed line width at >= 20% of trials
SPEED_WIDTH_SPARSE  =   3;    % speed line width when SPEED_FRACTION < 0.20 (sparE-47_Visit_7se subsample)
PLOT_EXTENT_ERROR   =   true;  % draw Figure 1 (ExtentError mean +/- 2*SD)
PLOT_SPEED          =   false;   % draw Figure 2 (individual speed trajectories)
BROWSE_VISITS       =   true;   % INTERACTIVE mode: step through ONE visit at a time
                                % (per subject, in order), Next/Prev buttons or arrow
                                % keys. Replaces the pooled figures above. The metric
                                % shown follows the toggles: PLOT_SPEED -> speed,
                                % else PLOT_EXTENT_ERROR -> extent error (speed wins
                                % if both are on).
USE_CACHE           =   true;   % reuse the last disk scan when subjectIDs/UNIT are unchanged
                                % (skips reloading every .mat when you only tweak plot options
                                %  like thickness/alpha/fraction/toggles). Set false to force a reload.
% ── Subjects to analyze ──────────────────────────────────────────────────────
%  The ID form selects the population automatically (per subject):
%    'E-<n>' (e.g. 'E-5') -> STROKE PATIENT: 9 visits, files <ID>/<ID>_Visit_<v>.mat
%    '<n>'   (e.g. '31')  -> HEALTHY subject: 1 visit,  file  <ID>/<ID>.mat
%  Mixed lists are fine; each subject is dispatched on its own ID form.
%
%  Stroke patient population:
subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28','E-38','E-42','E-44','E-47','E-56','E-69'};
% subjectIDs = {'E-56'};

%  Healthy single-visit population (example):
% subjectIDs = {'31','32','34','35','36','37','38','39','40','41','42','43','44','45','47','48','49','50','51','53','54','55','56','57','58','59','60'};
% ────────────────────────────────────────────────────────────────────────────

% Locate the project root (holds the E-XX/ data + helper functions). Works whether
% this script sits at the root or has been moved into a subfolder (e.g.
% BimodalErrorDistribution/): the root is the folder with the main pipeline file.
scriptDir = fileparts(mfilename('fullpath'));
if isfile(fullfile(scriptDir, 'MainAnalysis_Nine_Phase.m'))
    rootDir = scriptDir;               % script is at the project root
else
    rootDir = fileparts(scriptDir);    % script is in a subfolder -> root is one level up
end
originalDir = pwd;  % remember where we started, so we can return here at the end
addpath(rootDir);   % so helper .m files (CalculateMACCOnset, maccOnset, ...) resolve
cd(rootDir);        % move to the project root so the E-XX/ data folders are found
basePath = rootDir;   % = the folder holding the E-XX/ data

% ── Load-once cache ──────────────────────────────────────────────────────────
% The disk scan (loading every visit .mat) is the slow step; plotting is instant.
% We stash the scanned trajectories in a global so re-running this script to tweak
% PLOT-ONLY options (thickness, alpha, fraction, toggles) reuses them and skips the
% reload. The cache is invalidated automatically if subjectIDs or UNIT change, or
% if USE_CACHE is false. It clears when you `clear all` / restart MATLAB.
global BIMODAL_EXTENT_CACHE
cacheKey = struct('subjectIDs', {subjectIDs}, 'unit', UNIT);
if USE_CACHE && ~isempty(BIMODAL_EXTENT_CACHE) && isfield(BIMODAL_EXTENT_CACHE, 'visits') ...
        && isequal(BIMODAL_EXTENT_CACHE.key, cacheKey)
    Scan = BIMODAL_EXTENT_CACHE;
    fprintf('Using cached scan of %d visits (no reload). Set USE_CACHE=false to force a reload.\n', Scan.nVisits);
else
    Scan     = CollectAllTrajectories(basePath, subjectIDs, UNIT);
    Scan.key = cacheKey;
    BIMODAL_EXTENT_CACHE = Scan;
end

try
    if BROWSE_VISITS
        % Interactive: one visit at a time, Next/Prev to walk through every
        % (subject, visit) pair in the order they were scanned.
        BrowseVisits(Scan, UNIT, RESAMPLE_DT, MIN_COVERAGE, SPEED_ALPHA, SPEED_FRACTION, SPEED_SEED, PLOT_EXTENT_ERROR, PLOT_SPEED, SPEED_WIDTH, SPEED_WIDTH_SPARSE);
    else
        DrawBimodalFigures(Scan, UNIT, RESAMPLE_DT, MIN_COVERAGE, SPEED_ALPHA, SPEED_FRACTION, SPEED_SEED, PLOT_EXTENT_ERROR, PLOT_SPEED, SPEED_WIDTH, SPEED_WIDTH_SPARSE);
    end
catch ME
    cd(originalDir);   % restore the working directory even if something errors out
    rethrow(ME);
end

cd(originalDir);   % all data is loaded/plotted -> go back to where we started


%% =========================================================================

function Scan = CollectAllTrajectories(basePath, subjectIDs, unit)
% Pass 1 (the slow, cacheable step): scans every patient/visit .mat from disk
% and gathers the launch-aligned ExtentError + speed trajectories per direction.
%
% Trajectories are kept BOTH per-visit (Scan.visits, one record per loaded
% visit — used by the interactive BrowseVisits mode) AND pooled across all
% visits (Scan.trajLists/... — used by the DrawBimodalFigures pooled figures).
% The pooled lists are derived from the per-visit records so there is a single
% source of truth.

    switch unit
        case 'cm', gain = 100;
        otherwise, gain = 1;      % default metres
    end

    dirFields = {'DirectionZero','DirectionOne','DirectionTwo','DirectionThree'};

    visits  = struct([]);   % per-visit records (see BrowseVisits)
    nVisits = 0;

    for s = 1:numel(subjectIDs)
        subjectID  = subjectIDs{s};
        subjectDir = fullfile(basePath, subjectID);

        % Dispatch on the ID form (same as ErrorAmplitudeBimodalDistributionAnalysis.m):
        %   'E-<n>' -> stroke patient: 9 visits, files <ID>/<ID>_Visit_<v>.mat
        %   '<n>'   -> healthy subject: 1 visit,  file  <ID>/<ID>.mat
        % Mixed lists are fine; each subject is dispatched on its own ID form.
        isPatient = startsWith(subjectID, 'E-');
        if isPatient, visitNums = 1:9; else, visitNums = 1; end

        for v = visitNums
            if isPatient
                fpath = fullfile(subjectDir, sprintf('%s_Visit_%d.mat', subjectID, v));
            else
                fpath = fullfile(subjectDir, sprintf('%s.mat', subjectID));
            end
            if ~isfile(fpath), continue; end

            try
                loaded = load(fpath, 'Data', 'SpecialMovementIndex');
            catch
                continue
            end
            if ~isfield(loaded, 'Data') || ~isfield(loaded, 'SpecialMovementIndex')
                fprintf('%-6s Visit %d  |  missing Data or SpecialMovementIndex - skipped\n', subjectID, v);
                continue
            end
            nVisits = nVisits + 1;

            Data = loaded.Data;
            SpecialMovementIndex = loaded.SpecialMovementIndex;

            % One record for this visit: per-direction trajectory lists.
            rec = struct();
            rec.subjectID       = subjectID;
            rec.visitNum        = v;
            rec.isPatient       = isPatient;
            rec.trajLists       = {{}, {}, {}, {}};   % {d} = cell of [time, extentError]
            rec.launchEndLists  = {[], [], [], []};   % {d} = launch-window end time [s]
            rec.speedLists       = {{}, {}, {}, {}};  % {d} = cell of [time, speed]
            rec.speedLaunchList  = {{}, {}, {}, {}};  % {d} = cell of logical launch masks

            for dCount = 1:4
                idxList = GetDirectionIndices(SpecialMovementIndex, dirFields{dCount});
                for k = 1:numel(idxList)
                    idx = idxList(k);
                    if idx < 1 || idx > numel(Data) || isempty(Data{idx}), continue; end
                    [traj, launchEnd] = CollectTrajectory(Data{idx}, gain);
                    if ~isempty(traj)
                        rec.trajLists{dCount}{end+1}      = traj;      %#ok<AGROW>
                        rec.launchEndLists{dCount}(end+1) = launchEnd; %#ok<AGROW>
                    end

                    [spTraj, spLaunchMask] = CollectSpeedTrajectory(Data{idx});
                    if ~isempty(spTraj)
                        rec.speedLists{dCount}{end+1}      = spTraj;       %#ok<AGROW>
                        rec.speedLaunchList{dCount}{end+1} = spLaunchMask; %#ok<AGROW>
                    end
                end
            end

            % Keep the visit only if it actually produced some trajectories,
            % so the browser doesn't step through blank screens.
            hasAny = any(~cellfun(@isempty, rec.trajLists)) ...
                  || any(~cellfun(@isempty, rec.speedLists));
            if hasAny
                if isempty(visits), visits = rec; else, visits(end+1) = rec; end %#ok<AGROW>
            end
        end
    end

    % Derive the pooled lists (across all visits) from the per-visit records.
    trajLists       = {{}, {}, {}, {}};
    launchEndLists  = {[], [], [], []};
    speedLists      = {{}, {}, {}, {}};
    speedLaunchList = {{}, {}, {}, {}};
    for kk = 1:numel(visits)
        for d = 1:4
            trajLists{d}       = [trajLists{d},       visits(kk).trajLists{d}];
            launchEndLists{d}  = [launchEndLists{d},  visits(kk).launchEndLists{d}];
            speedLists{d}      = [speedLists{d},      visits(kk).speedLists{d}];
            speedLaunchList{d} = [speedLaunchList{d}, visits(kk).speedLaunchList{d}];
        end
    end

    Scan.visits          = visits;
    Scan.trajLists       = trajLists;
    Scan.launchEndLists  = launchEndLists;
    Scan.speedLists      = speedLists;
    Scan.speedLaunchList = speedLaunchList;
    Scan.nVisits         = nVisits;
end


function DrawBimodalFigures(Scan, unit, dt, minCoverage, speedAlpha, speedFraction, speedSeed, plotExtentError, plotSpeed, speedWidth, speedWidthSparse)
% Pass 2 (the fast, plot-only step): draws the figures from a pre-scanned struct.
%   Figure 1 — ExtentError vs. time: mean +/- 2*SD band per direction.
%   Figure 2 — Speed vs. time: the individual (real) trajectories overlaid,
%              semi-transparent, with each trial's launch phase in black.

    switch unit
        case 'cm', unitStr = '(cm)';
        otherwise, unitStr = '(m)';   % default metres
    end

    % Same 4-colour "practiced" palette as InspectIndividualTrial.
    PracticedColor = EquiDistantColorGenerator(4, 9742);
    dirLabels = {'Direction 0','Direction 1','Direction 2','Direction 3'};

    trajLists       = Scan.trajLists;
    launchEndLists  = Scan.launchEndLists;
    speedLists      = Scan.speedLists;
    speedLaunchList = Scan.speedLaunchList;
    nVisits         = Scan.nVisits;

    % ── Figure 1: one axes per direction, mean +/- 2*SD band ─────────────────
    if plotExtentError
        fig = figure;
        fig.WindowState = 'maximized';

        for dCount = 1:4
            ax  = subplot(2, 2, dCount);
            hold(ax, 'on');
            col = PracticedColor(dCount, :);

            n = PlotMeanBand(ax, trajLists{dCount}, launchEndLists{dCount}, col, dt, minCoverage);

            grid(ax, 'off'); box(ax, 'off');
            set(ax, 'LineWidth', 1.5, 'FontSize', 12);
            xlabel(ax, 'Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel(ax, ['Extent Error ' unitStr], 'FontSize', 14, 'FontWeight', 'bold');
            title(ax, sprintf('%s  (Intermittent Exposure, n = %d)', dirLabels{dCount}, n), ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', col);
        end
        sgtitle('Extent-error trajectories — intermittent-exposure practiced directions, all patients/visits  (mean \pm 2 SD)', ...
            'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'tex');
    end

    fprintf('\nScanned %d visits.  Trajectories pooled: Dir0=%d  Dir1=%d  Dir2=%d  Dir3=%d\n', ...
        nVisits, numel(trajLists{1}), numel(trajLists{2}), numel(trajLists{3}), numel(trajLists{4}));

    % ── Figure 2: individual speed trajectories overlaid (launch phase black) ─
    if plotSpeed
        figSpeed = figure;
        figSpeed.WindowState = 'maximized';

        for dCount = 1:4
            ax  = subplot(2, 2, dCount);
            hold(ax, 'on');
            col = PracticedColor(dCount, :);

            nSp = PlotSpeedOverlay(ax, speedLists{dCount}, speedLaunchList{dCount}, col, speedAlpha, speedFraction, speedSeed, speedWidth, speedWidthSparse);

            grid(ax, 'off'); box(ax, 'off');
            set(ax, 'LineWidth', 1.5, 'FontSize', 12);
            xlabel(ax, 'Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel(ax, 'Speed (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
            title(ax, sprintf('%s  (Intermittent Exposure, n = %d)', dirLabels{dCount}, nSp), ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', col);
        end
        sgtitle('Speed trajectories — intermittent-exposure practiced directions, all patients/visits  (launch phase in black)', ...
            'FontSize', 16, 'FontWeight', 'bold');
    end
end


function BrowseVisits(Scan, unit, dt, minCoverage, speedAlpha, speedFraction, speedSeed, plotExtentError, plotSpeed, speedWidth, speedWidthSparse)
% Interactive per-visit browser. Shows ONE visit at a time (4 axes, one per
% practiced direction) and lets you step to the next/previous visit with the
% "Next >" / "< Prev" buttons or the left/right arrow keys. Visits are walked
% in scan order: all of subject 1's visits, then subject 2's, and so on.
%
% The metric drawn follows the same toggles as the pooled figures:
%   plotSpeed        -> individual speed trajectories (launch phase in black)
%   plotExtentError  -> ExtentError mean +/- 2*SD band
% If both are on, speed is shown (it's the busier plot); flip PLOT_SPEED off to
% browse the extent-error band instead.

    visits = Scan.visits;
    nV     = numel(visits);
    if nV == 0
        warning('BimodalExtentErrorDistributions:noVisits', ...
            'No visits with trajectories to browse. Check subjectIDs / data paths.');
        return
    end

    switch unit
        case 'cm', unitStr = '(cm)';
        otherwise, unitStr = '(m)';
    end

    % Speed wins when both toggles are on; fall back to extent if speed is off.
    if plotSpeed
        metric = 'speed';
    elseif plotExtentError
        metric = 'extent';
    else
        metric = 'speed';
        fprintf(['BrowseVisits: both PLOT_SPEED and PLOT_EXTENT_ERROR are off; ' ...
                 'defaulting to the speed view.\n']);
    end

    PracticedColor = EquiDistantColorGenerator(4, 9742);
    dirLabels = {'Direction 0','Direction 1','Direction 2','Direction 3'};

    % ── Figure + axes + navigation controls ─────────────────────────────────
    fig = figure('Name', 'Bimodal visit browser', 'NumberTitle', 'off', ...
                 'Color', 'w');
    fig.WindowState = 'maximized';

    ax = gobjects(1, 4);
    for d = 1:4
        ax(d) = subplot(2, 2, d);
        % Leave a strip at the very bottom for the buttons.
        p = get(ax(d), 'Position');
        p(2) = p(2) + 0.05*(1 - p(2));   % nudge axes up a touch
        set(ax(d), 'Position', p);
    end

    k = 1;   % current visit index (shared with the nested callbacks)

    uicontrol(fig, 'Style', 'pushbutton', 'String', '< Prev', ...
        'Units', 'normalized', 'Position', [0.36 0.005 0.10 0.045], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Callback', @(~,~) step(-1));
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Next >', ...
        'Units', 'normalized', 'Position', [0.54 0.005 0.10 0.045], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Callback', @(~,~) step(+1));
    counterTxt = uicontrol(fig, 'Style', 'text', 'String', '', ...
        'Units', 'normalized', 'Position', [0.46 0.008 0.08 0.035], ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
        'HorizontalAlignment', 'center');

    fig.KeyPressFcn = @onKey;

    render();

    % ── Nested helpers (share k, ax, visits, ...) ────────────────────────────
    function step(delta)
        newK = min(max(k + delta, 1), nV);   % clamp at the ends
        if newK == k, return; end            % already at first/last
        k = newK;
        render();
    end

    function onKey(~, evt)
        switch evt.Key
            case {'rightarrow', 'space', 'n'}, step(+1);
            case {'leftarrow', 'p'},           step(-1);
        end
    end

    function render()
        rec = visits(k);
        for d = 1:4
            cla(ax(d), 'reset');
            hold(ax(d), 'on');
            col = PracticedColor(d, :);

            if strcmp(metric, 'speed')
                n = PlotSpeedOverlay(ax(d), rec.speedLists{d}, rec.speedLaunchList{d}, ...
                        col, speedAlpha, speedFraction, speedSeed, speedWidth, speedWidthSparse);
                yLbl = 'Speed (m/s)';
            else
                n = PlotMeanBand(ax(d), rec.trajLists{d}, rec.launchEndLists{d}, ...
                        col, dt, minCoverage);
                yLbl = ['Extent Error ' unitStr];
            end

            grid(ax(d), 'off'); box(ax(d), 'off');
            set(ax(d), 'LineWidth', 1.5, 'FontSize', 12);
            xlabel(ax(d), 'Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel(ax(d), yLbl, 'FontSize', 14, 'FontWeight', 'bold');
            title(ax(d), sprintf('%s  (n = %d)', dirLabels{d}, n), ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', col);
        end

        if rec.isPatient
            who = sprintf('%s — Visit %d', rec.subjectID, rec.visitNum);
        else
            who = sprintf('Healthy %s', rec.subjectID);
        end
        sgtitle(sprintf('%s      (%d of %d)', who, k, nV), ...
            'FontSize', 16, 'FontWeight', 'bold');
        set(counterTxt, 'String', sprintf('%d / %d', k, nV));
    end
end


function nUsed = PlotMeanBand(ax, trajList, launchEnds, col, dt, minCoverage)
% Resamples all trajectories onto a common time grid, then draws a thick mean
% line with a semi-transparent mean +/- 2*SD band. The launch phase of the
% mean line — from t = 0 (launch onset) to the trial-averaged launch-window
% end — is drawn in black. Returns the trial count.

    nUsed = numel(trajList);
    if nUsed == 0, return; end

    % Common time grid spanning the launch-aligned trajectories.
    tStart = min(cellfun(@(x) x(1,1),   trajList));
    tEnd   = max(cellfun(@(x) x(end,1), trajList));
    timeGrid = floor(tStart/dt)*dt : dt : ceil(tEnd/dt)*dt;

    % Resample each trajectory onto the grid (NaN outside its own range).
    M = nan(nUsed, numel(timeGrid));
    for i = 1:nUsed
        t = trajList{i}(:,1);
        y = trajList{i}(:,2);
        [t, iu] = unique(t, 'stable');      % interp1 needs distinct samples
        y = y(iu);
        if numel(t) < 2, continue; end
        M(i,:) = interp1(t, y, timeGrid, 'linear', NaN);
    end

    count = sum(~isnan(M), 1);
    muAll = mean(M, 1, 'omitnan');
    sdAll = std(M,  0, 1, 'omitnan');

    % Keep only grid points covered by enough trials, then the longest
    % contiguous run of them (so the band has no interior gaps).
    valid = count >= max(2, ceil(minCoverage * nUsed));
    [lo, hi] = LongestTrueRun(valid);
    if isempty(lo), return; end

    tg    = timeGrid(lo:hi);
    mu    = muAll(lo:hi);
    sd    = sdAll(lo:hi);
    upper = mu + 2*sd;
    lower = mu - 2*sd;

    % Semi-transparent +/- 2*SD band ...
    fill(ax, [tg, fliplr(tg)], [upper, fliplr(lower)], col, ...
        'FaceAlpha', 0.20, 'EdgeColor', 'none', 'HandleVisibility', 'off');

    % ... thick, high-contrast mean line on top.
    plot(ax, tg, mu, '-', 'Color', col, 'LineWidth', 3);

    % ... launch phase of the mean line in black: from t = 0 (launch onset,
    % where every trial is aligned) to the trial-averaged launch-window end.
    meanLaunchEnd = mean(launchEnds(~isnan(launchEnds)));
    if ~isnan(meanLaunchEnd) && meanLaunchEnd > 0
        launchMask = tg >= 0 & tg <= meanLaunchEnd;
        if any(launchMask)
            plot(ax, tg(launchMask), mu(launchMask), '-', 'Color', 'k', ...
                'LineWidth', 3, 'HandleVisibility', 'off');
        end
    end
end


function nUsed = PlotSpeedOverlay(ax, speedList, launchMaskList, col, alpha, fraction, seed, widthFull, widthSparse)
% Overlays trial's real speed vs. time (launch-aligned) as a semi-transparent
% line, with each trial's launch-window samples in black. Only a random
% `fraction` (0..1) of the available trials is drawn — 1.0 plots all of them.

    nTotal = numel(speedList);

    % Pick a random subset of size round(fraction * nTotal).
    nKeep = min(nTotal, max(0, round(fraction * nTotal)));
    if nKeep < nTotal
        if ~isempty(seed), rng(seed); end        % reproducible subsample when seed set
        pick = randperm(nTotal, nKeep);
    else
        pick = 1:nTotal;                          % fraction >= 1: keep all
    end

    % With few trials on screen (sparse subsample), draw thicker lines so each
    % trajectory stays visible; keep them thin when plotting the full set.
    if fraction < 0.20, lineW = widthSparse; else, lineW = widthFull; end

    nUsed = numel(pick);
    for i = pick
        t  = speedList{i}(:,1);
        sp = speedList{i}(:,2);

        % Full speed trajectory, semi-transparent direction colour.
        plot(ax, t, sp, '-', 'Color', [col, alpha], 'LineWidth', lineW);

        % Launch-window samples on top, semi-transparent black.
        lm = launchMaskList{i};
        if any(lm)
            plot(ax, t(lm), sp(lm), '-', 'Color', [0 0 0 alpha], 'LineWidth', lineW);
        end
    end
end


function [traj, launchMask] = CollectSpeedTrajectory(d)
% Returns [time, speed] for one trial (launch onset shifted to t = 0) and a
% logical mask flagging the launch-window samples. traj is [] if unusable.
% Speed = magnitude of GlobalVelocity, as InspectIndividualTrial computes it.

    traj       = [];
    launchMask = [];
    if ~isfield(d, 'GlobalVelocity') || isempty(d.GlobalVelocity), return; end
    if ~isfield(d, 'SampleTime')     || isempty(d.SampleTime),     return; end

    speed = vecnorm(d.GlobalVelocity, 2, 2);   % N×1 speed magnitude [m/s]
    time  = ConstructTimeFromSampleTime(d.SampleTime);
    time  = time(:);

    launchIndex = GetLaunchWindow(d);
    hasLaunch   = ~(isscalar(launchIndex) && launchIndex == 0) ...
                  && launchIndex(1) >= 1 && launchIndex(1) <= numel(time);
    if hasLaunch
        time = time - time(launchIndex(1));   % shift so launch onset is at t = 0
    end

    n = min(numel(time), numel(speed));
    if n < 2, return; end
    time  = time(1:n);
    speed = speed(1:n);

    launchMask = false(n, 1);
    if hasLaunch
        li = launchIndex(launchIndex >= 1 & launchIndex <= n);
        launchMask(li) = true;
    end
    traj = [time, speed];
end


function [traj, launchEnd] = CollectTrajectory(d, gain)
% Returns [time, extentError] for one trial with the launch onset shifted to
% t = 0 (as InspectIndividualTrial does), plus launchEnd = the shifted time at
% the end of the launch window (NaN if no launch). traj is [] if unusable.

    traj      = [];
    launchEnd = NaN;
    if ~isfield(d, 'ExtentError') || isempty(d.ExtentError), return; end
    if ~isfield(d, 'SampleTime')  || isempty(d.SampleTime),  return; end

    extentError = gain * d.ExtentError(:);
    time        = ConstructTimeFromSampleTime(d.SampleTime);
    time        = time(:);

    % Launch window = TherapyWindowIndex (0 when no onset was detected),
    % exactly as InspectIndividualTrial derives launchIndex.
    launchIndex = GetLaunchWindow(d);
    if ~(isscalar(launchIndex) && launchIndex == 0) ...
            && launchIndex(1) >= 1 && launchIndex(1) <= numel(time)
        time = time - time(launchIndex(1));   % shift so launch onset is at t = 0
        if launchIndex(end) >= 1 && launchIndex(end) <= numel(time)
            launchEnd = time(launchIndex(end));   % launch-window end in shifted time
        end
    end

    n = min(numel(time), numel(extentError));
    if n < 2, return; end
    traj = [time(1:n), extentError(1:n)];
end


function idxList = GetDirectionIndices(SpecialMovementIndex, field)
% Data-cell indices of the intermittent-exposure trials for one direction.

    idxList = [];
    if isfield(SpecialMovementIndex, 'IntermittentExposure') && ...
            isfield(SpecialMovementIndex.IntermittentExposure, field)
        idxList = SpecialMovementIndex.IntermittentExposure.(field)(:);
    end
end


function launchIndex = GetLaunchWindow(d)
% Mirrors InspectIndividualTrial: the launch window is TherapyWindowIndex,
% unless no onset was detected or the window is empty, in which case 0.

    launchIndex = 0;
    if isfield(d, 'OnsetDetectedIndex') && ~isempty(d.OnsetDetectedIndex) && ...
            isfield(d, 'TherapyWindowIndex') && ~isempty(d.TherapyWindowIndex)
        launchIndex = d.TherapyWindowIndex(:);
    end
end


function [lo, hi] = LongestTrueRun(mask)
% Start/end indices of the longest run of consecutive true values in mask.

    lo = []; hi = []; best = 0;
    i = 1; N = numel(mask);
    while i <= N
        if mask(i)
            j = i;
            while j < N && mask(j+1), j = j + 1; end
            if (j - i + 1) > best, best = j - i + 1; lo = i; hi = j; end
            i = j + 1;
        else
            i = i + 1;
        end
    end
end
