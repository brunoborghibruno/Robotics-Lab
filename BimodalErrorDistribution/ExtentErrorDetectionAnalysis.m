%% Extent-Error Trajectories — Subject x EF-Visit Grid
%
%  Same grid idea as MovementOnsetDetectionAnalysis.m (one ROW per subject), but
%  with only 3 COLUMNS: the three consecutive visits in which the Error Fields
%  (EF) were applied. Every cell holds the BimodalExtentErrorDistributions.m
%  extent-error figure for that subject and visit: 4 small axes (practiced
%  directions 0-3, 2 x 2) with the thick mean line, the semi-transparent
%  mean +/- 2*SD band and the launch phase of the mean in black. The per-direction
%  titles are dropped (unreadable at this size).
%
%  Columns are "1st / 2nd / 3rd EF visit", not fixed visit numbers: the crossover
%  puts the EF block at visits 2-4 for some patients and 5-7 for others. The
%  actual visit number is printed in the corner of each cell (SHOW_VISIT_NUMBER).
%
%  EF typing follows BaselineErrorAcrossEFVisits.m (DetectVisitType): a visit is
%  EF if any TRAINING-phase trial has a non-zero TherapyForceAmplitude. Only the
%  first run of 3 CONSECUTIVE EF visits is plotted, so E-47's extra EF visit 6
%  (inside its sham week) is ignored.
%
%  The drawing code (PlotMeanBand, CollectTrajectory, ...) is copied unchanged
%  from BimodalExtentErrorDistributions.m, whose helpers are local functions.
%
%  All the direction axes of the whole grid share ONE y axis (Y_LIMIT_MODE), so
%  a cell can be compared to any other cell across subjects, visits and
%  directions without re-reading the ticks.
%
%  NOTE ON RUNTIME: every visit .mat of every subject is loaded once (the types
%  of all visits are needed to find the EF block). The scan is left in the
%  workspace as `EFGridScan`; a re-run skips it and only redraws. Set
%  FORCE_RESCAN = true (or `clear EFGridScan`) when the data changed.

% ── Patients to analyze (each = 9 numbered visits, files <ID>/<ID>_Visit_<v>.mat) ──
% subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28','E-38','E-42','E-44','E-47','E-56','E-69','E-91','E-93'};
subjectIDs = {'P-2'};


% ── Blindness ────────────────────────────────────────────────────────────────
%  true  -> rows and console log say 'Patient N' (position in subjectIDs).
%  false -> real IDs ('E-5', 'E-16', ...).
%  Only the DISPLAY changes; the real IDs still select the data files.
BLINDNESS = false;

% ── Same plot options as BimodalExtentErrorDistributions.m ───────────────────
UNIT                = 'm';            % 'm' or 'cm' for the extent-error axis
RESAMPLE_DT         = 0.01;           % common time-grid step [s]
MIN_COVERAGE        = 0.5;            % keep the band only where >= this fraction of trials exist
TRAINING_PHASE_NAME = 'TrainingPhase';% ExperimentPhase used for EF/SHAM typing

% ── Grid appearance ──────────────────────────────────────────────────────────
SHOW_VISIT_NUMBER  = true;   % 'V5' tag in the corner of each cell
TICK_FONT_SIZE     = 7;      % tick labels of the small direction axes
LABEL_FONT_SIZE    = 28;     % row labels (subject IDs) / column headers (EF visit)
VISIT_TAG_FONT_SIZE = 16;    % the 'V5' tag inside the cells
FOOTER_FONT_SIZE   = 12;     % the shared 'x: Time ...' line at the bottom

% ── Individual trials ────────────────────────────────────────────────────────
%  Every single trial drawn as a thin semi-transparent line over the band, so
%  the spread behind the mean +/- 2*SD is visible trial by trial.
TrialOpts.show      = true;
TrialOpts.alpha     = 0.25;   % 0 = invisible, 1 = opaque
TrialOpts.lineWidth = 0.5;
TrialOpts.color     = [];     % [] = the direction colour; e.g. [0.3 0.3 0.3] for grey

% ── Shared y axis ────────────────────────────────────────────────────────────
%  Every direction axes of every cell gets the SAME y limits, so all subjects,
%  visits and directions are drawn at one scale.
%    'band'   -> limits from the plotted mean +/- 2*SD envelopes (what is drawn)
%    'trials' -> limits from every raw trajectory sample (wider; single-trial
%                outliers then flatten all the other cells)
Y_LIMIT_MODE = 'band';
Y_PAD_FRAC   = 0.05;        % headroom added above and below, as a fraction of the range
Y_LIMITS     = [];          % [lo hi] to force the limits by hand ([] = automatic)

% ── "Didn't move" flag ───────────────────────────────────────────────────────
%  A direction axes gets a grey background when its MEAN curve ends (last
%  plotted point, far right) at or below `threshold`. An end near -0.1 m means
%  the target (~10 cm away) was never approached: the subject did not move.
FlagOpts.show      = true;
FlagOpts.threshold = -0.05;             % in UNIT (-0.1 m = never left the start; FlagOpts.threshold is the tolerance). Use -8 when UNIT = 'cm'.
FlagOpts.color     = [0.88 0.88 0.88];  % background of a flagged axes

% ── Scan cache ───────────────────────────────────────────────────────────────
FORCE_RESCAN = false;
% ───────────────────────────────────────────────────────────────────────────

% Locate the project root (holds the E-XX/ data + helper functions). Works whether
% this script sits at the root or in a subfolder (e.g. BimodalErrorDistribution/).
scriptDir = fileparts(mfilename('fullpath'));
if isfile(fullfile(scriptDir, 'MainAnalysis_Nine_Phase.m'))
    rootDir = scriptDir;               % script is at the project root
else
    rootDir = fileparts(scriptDir);    % script is in a subfolder -> root is one level up
end
addpath(rootDir);   % so helper .m files (ConstructTimeFromSampleTime, EquiDistantColorGenerator) resolve
cd(rootDir);        % so the E-XX/ data folders are found
basePath = rootDir;

% (This is a script, so exist(...,'var') sees the workspace it was run from.)
% The cache is only reused if it was scanned with the same subjects/unit/phase.
scanKey   = struct('subjectIDs', {subjectIDs}, 'unit', UNIT, 'trainingPhase', TRAINING_PHASE_NAME);
haveCache = exist('EFGridScan','var') && isstruct(EFGridScan) ...
            && isfield(EFGridScan, 'key') && isequal(EFGridScan.key, scanKey);

try
    if FORCE_RESCAN || ~haveCache
        EFGridScan     = ScanEFVisits(basePath, subjectIDs, UNIT, TRAINING_PHASE_NAME, BLINDNESS);
        EFGridScan.key = scanKey;
    else
        fprintf(['Reusing the cached scan already in the workspace ' ...
                 '(set FORCE_RESCAN = true, or "clear EFGridScan", to re-scan).\n']);
    end

    DrawEFGrid(EFGridScan, UNIT, RESAMPLE_DT, MIN_COVERAGE, BLINDNESS, ...
               SHOW_VISIT_NUMBER, TICK_FONT_SIZE, LABEL_FONT_SIZE, ...
               VISIT_TAG_FONT_SIZE, FOOTER_FONT_SIZE, ...
               Y_LIMIT_MODE, Y_PAD_FRAC, Y_LIMITS, TrialOpts, FlagOpts);
catch scanErr
    cd(scriptDir);
    rethrow(scanErr);
end

% ── Back to the folder this script lives in ──────────────────────────────────
cd(scriptDir);


%% =========================================================================

function Scan = ScanEFVisits(basePath, subjectIDs, unit, trainingPhaseName, blindness)
% Loads every visit of every subject, types it EF/SHAM/Short, and keeps the
% launch-aligned ExtentError trajectories (per practiced direction) of the
% first 3 consecutive EF visits only.
%
% Scan.subjects(s) has:
%   .subjectID  - real ID
%   .efVisits   - 1x3 visit numbers plotted (NaN where missing)
%   .cells{c}   - struct with .trajLists / .launchEndLists (as in
%                 BimodalExtentErrorDistributions), [] if no data

    switch unit
        case 'cm', gain = 100;
        otherwise, gain = 1;      % default metres
    end
    dirFields = {'DirectionZero','DirectionOne','DirectionTwo','DirectionThree'};

    subjects = struct('subjectID', {}, 'efVisits', {}, 'cells', {});

    for s = 1:numel(subjectIDs)
        subjectID = subjectIDs{s};
        if blindness, label = sprintf('Patient %d', s); else, label = subjectID; end

        efRecs = struct('visitNum', {}, 'trajLists', {}, 'launchEndLists', {});
        for v = 1:9
            fpath = fullfile(basePath, subjectID, sprintf('%s_Visit_%d.mat', subjectID, v));
            if ~isfile(fpath), continue; end
            try
                loaded = load(fpath, 'Data', 'SpecialMovementIndex');
            catch
                continue
            end
            if ~isfield(loaded, 'Data') || ~isfield(loaded, 'SpecialMovementIndex')
                fprintf('%-10s Visit %d  |  missing Data or SpecialMovementIndex - skipped\n', label, v);
                continue
            end

            vtype = DetectVisitType(loaded.Data, trainingPhaseName);
            fprintf('%-10s Visit %d  |  %s\n', label, v, vtype);
            if ~strcmp(vtype, 'EF'), continue; end

            rec.visitNum       = v;
            rec.trajLists      = {{}, {}, {}, {}};
            rec.launchEndLists = {[], [], [], []};
            Data = loaded.Data;
            for dCount = 1:4
                idxList = GetDirectionIndices(loaded.SpecialMovementIndex, dirFields{dCount});
                for k = 1:numel(idxList)
                    idx = idxList(k);
                    if idx < 1 || idx > numel(Data) || isempty(Data{idx}), continue; end
                    [traj, launchEnd] = CollectTrajectory(Data{idx}, gain);
                    if ~isempty(traj)
                        rec.trajLists{dCount}{end+1}      = traj;      %#ok<AGROW>
                        rec.launchEndLists{dCount}(end+1) = launchEnd; %#ok<AGROW>
                    end
                end
            end
            efRecs(end+1) = rec; %#ok<AGROW>
        end

        % First run of 3 consecutive EF visits (e.g. 2-3-4, not E-47's 6).
        efNums = [efRecs.visitNum];
        pick   = [];
        for k = 1:numel(efNums) - 2
            if efNums(k+1) == efNums(k) + 1 && efNums(k+2) == efNums(k) + 2
                pick = k:k+2;
                break
            end
        end
        if isempty(pick)
            pick = 1:min(3, numel(efNums));
            fprintf(['%-10s  |  WARNING: no 3 consecutive EF visits (EF visits: %s) - ' ...
                     'plotting the first %d EF visit(s).\n'], label, mat2str(efNums), numel(pick));
        else
            fprintf('%-10s  |  EF visits plotted: %s\n', label, mat2str(efNums(pick)));
        end

        subj.subjectID = subjectID;
        subj.efVisits  = nan(1, 3);
        subj.cells     = cell(1, 3);
        for c = 1:numel(pick)
            subj.efVisits(c) = efRecs(pick(c)).visitNum;
            subj.cells{c}    = efRecs(pick(c));
        end
        subjects(end+1) = subj; %#ok<AGROW>
    end

    Scan.subjects = subjects;
end


function DrawEFGrid(Scan, unit, dt, minCoverage, blindness, showVisitNumber, tickFontSize, labelFontSize, ...
                    visitTagFontSize, footerFontSize, yLimitMode, yPadFrac, yLimits, trialOpts, flagOpts)
% Subject x (1st/2nd/3rd EF visit) grid. Every cell is split 2 x 2 into the
% four practiced-direction axes of BimodalExtentErrorDistributions' Figure 1.
% All of those axes end up on one common y axis (see the Y_LIMIT_* options).
% Axes whose mean curve ends significantly below zero get a grey background
% (see the FlagOpts options).

    switch unit
        case 'cm', unitStr = '(cm)';
        otherwise, unitStr = '(m)';
    end

    subjects    = Scan.subjects;
    numSubjects = numel(subjects);
    numCols     = 3;
    if numSubjects == 0
        disp('No subjects to display.');
        return
    end

    % Same 4-colour "practiced" palette as BimodalExtentErrorDistributions.
    PracticedColor = EquiDistantColorGenerator(4, 9742);

    % Every direction axes of the grid, plus the extent of the data drawn in
    % them: both are needed to put all the cells on one common y axis.
    allAxes  = gobjects(0);
    dataLo   = Inf;
    dataHi   = -Inf;

    fig = figure('Name', 'Extent error - EF visits grid', 'NumberTitle', 'off', 'Color', 'w');
    fig.WindowState = 'maximized';

    % Grid area in normalized figure units: room on the left for row labels,
    % on top for the column headers, at the bottom for the shared axis labels.
    gridL = 0.10;  gridR = 0.99;   % left band holds the row labels
    gridB = 0.04;  gridT = 0.93;   % top band holds the column headers
    cellW = (gridR - gridL) / numCols;
    cellH = (gridT - gridB) / numSubjects;

    % Inner margins of each direction axes, as fractions of its half-cell
    % (left leaves room for the y tick labels, bottom for the x tick labels).
    mL = 0.17; mR = 0.03; mB = 0.24; mT = 0.06;

    colHeaders = {'1st EF visit', '2nd EF visit', '3rd EF visit'};
    for c = 1:numCols
        annotation(fig, 'textbox', [gridL + (c-1)*cellW, gridT, cellW, 1 - gridT], ...
            'String', colHeaders{c}, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', labelFontSize + 2, ...
            'FontWeight', 'bold', 'LineStyle', 'none');
    end

    for s = 1:numSubjects
        if blindness
            rowLabel = sprintf('Patient %d', s);
        else
            rowLabel = subjects(s).subjectID;
        end
        cellY0 = gridT - s*cellH;      % row 1 at the top

        annotation(fig, 'textbox', [0, cellY0, gridL*0.95, cellH], ...
            'String', rowLabel, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', labelFontSize, ...
            'FontWeight', 'bold', 'LineStyle', 'none');

        for c = 1:numCols
            cellX0 = gridL + (c-1)*cellW;

            % Cell border, like the onset grid.
            annotation(fig, 'rectangle', [cellX0, cellY0, cellW, cellH], ...
                'Color', [0.6 0.6 0.6], 'LineWidth', 1);

            rec = subjects(s).cells{c};
            if isempty(rec)
                annotation(fig, 'textbox', [cellX0, cellY0, cellW, cellH], ...
                    'String', 'no data', 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', 'FontSize', labelFontSize, ...
                    'Color', [0.5 0.5 0.5], 'LineStyle', 'none');
                continue
            end

            for dCount = 1:4
                subRow = ceil(dCount / 2);          % 1 = top, 2 = bottom
                subCol = 2 - mod(dCount, 2);        % 1 = left, 2 = right
                hx = cellX0 + (subCol-1) * cellW/2;
                hy = cellY0 + (2-subRow) * cellH/2;
                pos = [hx + mL*cellW/2, hy + mB*cellH/2, ...
                       (1-mL-mR)*cellW/2, (1-mB-mT)*cellH/2];

                ax = axes(fig, 'Position', pos);
                hold(ax, 'on');
                [~, bandRange, endInfo] = PlotMeanBand(ax, rec.trajLists{dCount}, rec.launchEndLists{dCount}, ...
                                                       PracticedColor(dCount, :), dt, minCoverage, trialOpts);
                grid(ax, 'off'); box(ax, 'off');
                set(ax, 'LineWidth', 1, 'FontSize', tickFontSize);

                % "Didn't move" flag: grey background when the mean curve ends
                % at or below the threshold.
                if flagOpts.show
                    [isFlagged, nEnd] = IsFlaggedEnd(endInfo, flagOpts);
                    if isFlagged
                        set(ax, 'Color', flagOpts.color);
                        fprintf('%-10s V%d  D%d  |  flagged: mean end = %.4g %s, n = %d\n', ...
                                rowLabel, subjects(s).efVisits(c), dCount - 1, ...
                                endInfo.meanEnd, unit, nEnd);
                    end
                end
                hold(ax, 'off');

                allAxes(end+1) = ax; %#ok<AGROW>
                switch yLimitMode
                    case 'trials'
                        % Every sample of every trial of this direction.
                        for k = 1:numel(rec.trajLists{dCount})
                            y = rec.trajLists{dCount}{k}(:,2);
                            y = y(isfinite(y));
                            if isempty(y), continue; end
                            dataLo = min(dataLo, min(y));
                            dataHi = max(dataHi, max(y));
                        end
                    otherwise
                        % Only what the cell actually shows: the +/- 2*SD band.
                        if ~isempty(bandRange)
                            dataLo = min(dataLo, bandRange(1));
                            dataHi = max(dataHi, bandRange(2));
                        end
                end
            end

            if showVisitNumber
                annotation(fig, 'textbox', [cellX0, cellY0 + cellH*0.5, cellW*0.30, cellH*0.5], ...
                    'String', sprintf('V%d', subjects(s).efVisits(c)), ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
                    'FontSize', visitTagFontSize, 'FontWeight', 'bold', 'LineStyle', 'none', ...
                    'Margin', 1);
            end
        end
    end

    % ── One y axis for the whole grid ────────────────────────────────────────
    % Done after the loop, when the extent of every cell is known.
    if isempty(yLimits)
        if isfinite(dataLo) && isfinite(dataHi) && dataHi > dataLo
            pad     = yPadFrac * (dataHi - dataLo);
            yLimits = [dataLo - pad, dataHi + pad];
        elseif isfinite(dataLo) && isfinite(dataHi)
            pad     = max(abs(dataHi), 1) * 0.05;   % all cells flat at one value
            yLimits = [dataLo - pad, dataHi + pad];
        else
            yLimits = [];                            % nothing was drawn
        end
    end
    if ~isempty(yLimits) && ~isempty(allAxes)
        set(allAxes, 'YLim', yLimits);
        fprintf('Common y limits (%s, mode ''%s''): [%.4g  %.4g]\n', ...
                unitStr, yLimitMode, yLimits(1), yLimits(2));
    end

    % Shared axis labels (per-axes labels do not fit inside a cell), plus the
    % meaning of the grey "didn't move" background.
    footer = "x: Time (s)      y: Extent Error " + string(unitStr) + ...
             "      Directions per cell:  D0 D1 / D2 D3      (single trials, mean \pm 2 SD, launch phase in black)";
    if flagOpts.show
        footer = [footer; string(sprintf(['Grey background: mean curve ends at or below %g %s ' ...
                  '(\\approx -0.1 m = target never approached) = subject did not move'], ...
                  flagOpts.threshold, unit))];
    end
    annotation(fig, 'textbox', [gridL, 0, gridR - gridL, gridB], ...
        'String', footer, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FontSize', footerFontSize, 'FontWeight', 'bold', 'LineStyle', 'none', ...
        'Interpreter', 'tex');
end


function vtype = DetectVisitType(DataLocal, trainingPhaseName)
% Copied from BaselineErrorAcrossEFVisits.m.
% "EF" if any TRAINING-phase trial applied a non-zero therapy force, "SHAM" if
% training trials exist but none did, "Short" for the 211-trial visits (1, 8, 9)
% that have no training phase at all.

    vtype = 'Unknown';
    if ~iscell(DataLocal), return; end

    isEF  = false;
    found = false;
    for i = 1:numel(DataLocal)
        d = DataLocal{i};
        if isempty(d) || ~isfield(d, 'ExperimentPhase'), continue; end
        if ~strcmp(d.ExperimentPhase, trainingPhaseName), continue; end
        if ~isfield(d, 'TherapyForceAmplitude') || isempty(d.TherapyForceAmplitude), continue; end
        found = true;
        if any(d.TherapyForceAmplitude(:) ~= 0)
            isEF = true;
            break               % one non-zero sample is enough
        end
    end

    if ~found
        vtype = 'Short';        % no training phase -> visit 1, 8 or 9
    elseif isEF
        vtype = 'EF';
    else
        vtype = 'SHAM';
    end
end


%% ── Copied unchanged from BimodalExtentErrorDistributions.m ────────────────

function [nUsed, yRange, endInfo] = PlotMeanBand(ax, trajList, launchEnds, col, dt, minCoverage, trialOpts)
% Resamples all trajectories onto a common time grid, then draws a thick mean
% line with a semi-transparent mean +/- 2*SD band, optionally with every
% individual trial as a thin semi-transparent line in between. The launch phase of the
% mean line — from t = 0 (launch onset) to the trial-averaged launch-window
% end — is drawn in black. Returns the trial count and yRange = [min max] of
% what was drawn ([] when nothing was), which the caller uses to build the
% grid-wide y axis. endInfo describes the LAST point of the mean line
% (.meanEnd, its time .t, and .vals = the trial values averaged there), [] when
% nothing was drawn; the caller uses it for the "didn't move" flag.

    yRange  = [];
    endInfo = [];
    nUsed  = numel(trajList);
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

    % Last point of the mean line and the trial values it is the mean of.
    endVals = M(:, hi);
    endInfo = struct('meanEnd', mu(end), 't', tg(end), 'vals', endVals(~isnan(endVals)));

    % Semi-transparent +/- 2*SD band ...
    fill(ax, [tg, fliplr(tg)], [upper, fliplr(lower)], col, ...
        'FaceAlpha', 0.20, 'EdgeColor', 'none', 'HandleVisibility', 'off');

    % ... every individual trial on top of the band, thin and semi-transparent.
    % Drawn from the resampled matrix over the SAME window as the band, so a
    % trial cannot push the cell past the limits the band sets. They go before
    % the mean line, which therefore stays readable on top of them.
    if ~isempty(trialOpts) && isfield(trialOpts, 'show') && trialOpts.show
        if isfield(trialOpts, 'color') && ~isempty(trialOpts.color)
            trialCol = trialOpts.color;
        else
            trialCol = col;
        end
        for i = 1:nUsed
            yi = M(i, lo:hi);
            if all(isnan(yi)), continue; end
            hTrial = plot(ax, tg, yi, '-', 'Color', trialCol, ...
                'LineWidth', trialOpts.lineWidth, 'HandleVisibility', 'off');
            hTrial.Color(4) = trialOpts.alpha;   % 4th colour element = line transparency
        end
    end

    % ... thick, high-contrast mean line on top.
    plot(ax, tg, mu, '-', 'Color', col, 'LineWidth', 3);

    % Vertical extent of what was just drawn, for the grid-wide y axis.
    finiteBand = [upper(isfinite(upper)), lower(isfinite(lower))];
    if ~isempty(finiteBand)
        yRange = [min(finiteBand), max(finiteBand)];
    end

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


function [isFlagged, n] = IsFlaggedEnd(endInfo, flagOpts)
% True when the last point of the mean curve is at or below flagOpts.threshold.
% n = number of trials averaged at that point (for the console log).

    isFlagged = false;
    n = 0;
    if isempty(endInfo), return; end
    n = numel(endInfo.vals);
    isFlagged = endInfo.meanEnd <= flagOpts.threshold;
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
