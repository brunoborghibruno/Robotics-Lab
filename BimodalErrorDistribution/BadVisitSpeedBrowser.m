%% Bad-Visit Speed Browser - Bruno Borghi
%
%  Inspired by BimodalExtentErrorDistributions.m (same disk-scan + interactive,
%  arrow-key visit browser), but purpose-built for MANUALLY grading each visit's
%  speed profiles..
%
%  For every patient/visit it loads from disk (no global Data) and, for the
%  intermittent-exposure practiced-direction trials only —
%       SpecialMovementIndex.IntermittentExposure.DirectionZero  (direction 0)
%                                              .DirectionOne   (direction 1)
%                                              .DirectionTwo   (direction 2)
%                                              .DirectionThree (direction 3)
%  (these hold DIRECT indices into that visit's Data cell array, not
%  MovementNumbers) — it overlays EVERY trial's speed profile, one on top of
%  another (launch onset aligned to t = 0), in four axes (one per direction).
%
%  Next to each direction's (big) speed axis, on the right, a stacked PAIR of
%  smaller companion axes shows the same trials':
%    - top    : FORWARD-VELOCITY ("compensation") profile — the velocity
%               component projected onto the movement/target direction, exactly
%               as VelocityCompensationAnalysis.m computes it. It is signed, so a
%               dip below zero means the hand moved BACK toward the start.
%    - bottom : EXTENT ERROR profile — the same trials' ExtentError vs. time.
%  The four directions keep their 2x2 arrangement; each direction cell is laid
%  out as [ big speed  |  velocity (top) / extent error (bottom) ]. This lets you
%  weigh the speed profile, any backward-movement compensation, and the extent
%  error together when grading a visit good/bad.
%
%  Interactive controls:Firs
%    - "< Prev" / "Next >" buttons OR left/right arrow keys step through every
%      (subject, visit) pair in scan order.
%    - A "Bad visit" checkbox: tick it when the displayed visit's speed profiles
%      look bad. Its state is stored per visit and persisted immediately (see
%      the badVisitsList output below), so you can close the window at any time
%      without losing your grading.
%
%  Visit type (Error-Fields ON vs. SHAM) is detected automatically: among the
%  trials with MovementNumber in [210, 250], if ANY sample of
%  Data{i}.TherapyForceAmplitude is non-zero the visit is an Error-Fields (EF)
%  visit; otherwise it is a SHAM visit. The type is shown next to the title and
%  stored alongside the bad-visit flag.
%
%  Output (assigned to the base workspace AND saved to badVisitsList.mat, next
%  to this script, on every checkbox change):
%    badVisitsList — struct with subject-by-visit matrices:
%        .SubjectIDs   (nSubjects x 1 string)  row labels
%        .VisitNumbers (1 x nVisits   double)  column labels (1..nVisits)
%        .BadVisit     (nSubjects x nVisits)   1 = bad, 0 = ok, NaN = no data
%        .VisitType    (nSubjects x nVisits string) "EF" / "SHAM" / "Unknown"
%                                                    / "" (no data)
%        .Present      (nSubjects x nVisits logical) true where a visit loaded
%        .Summary      (table) human-readable "<BAD|ok>-<TYPE>" grid, rows =
%                      subjects, one column per visit — quick to eyeball.

% ── Options ───────────────────────────────────────────────────────────────────
SPEED_ALPHA         =   0.4;    % line transparency for the overlaid speed trials
SPEED_WIDTH         =   2;      % speed line width
SHOW_LAUNCH_BLACK   =   true;   % draw each trial's launch-window samples in black
MJ_DESIRED_TIME     =   0.65;   % minimum-jerk template duration   [s] (as InspectIndividualTrial)
MJ_DESIRED_DISTANCE =   0.1;    % minimum-jerk template reach dist [m] (as InspectIndividualTrial)
USE_CACHE           =   true;   % reuse the last disk scan when subjectIDs unchanged
                                % (skips reloading every .mat when you only tweak
                                %  plot options). Set false to force a reload.

% ── Subjects to analyze ───────────────────────────────────────────────────────
%  The ID form selects the population automatically (per subject):
%    'E-<n>' (e.g. 'E-5') -> STROKE PATIENT: 9 visits, files <ID>/<ID>_Visit_<v>.mat
%    '<n>'   (e.g. '31')  -> HEALTHY subject: 1 visit,  file  <ID>/<ID>.mat
%  Mixed lists are fine; each subject is dispatched on its own ID form.
subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28','E-38','E-42','E-44','E-47','E-56','E-69'};
% ──────────────────────────────────────────────────────────────────────────────

% Locate the project root (holds the E-XX/ data + helper functions). Works whether
% this script sits at the root or in a subfolder (e.g. BimodalErrorDistribution/).
scriptDir = fileparts(mfilename('fullpath'));
if isfile(fullfile(scriptDir, 'MainAnalysis_Nine_Phase.m'))
    rootDir = scriptDir;               % script is at the project root
else
    rootDir = fileparts(scriptDir);    % script is in a subfolder -> root is one level up
end
originalDir = pwd;  % remember where we started, so we can return here at the end
addpath(rootDir);   % so helper .m files (ConstructTimeFromSampleTime, ...) resolve
cd(rootDir);        % move to the project root so the E-XX/ data folders are found
basePath = rootDir;   % = the folder holding the E-XX/ data
saveFile = fullfile(scriptDir, 'badVisitsList.mat');   % where the grading is stored

% ── Load-once cache (the disk scan is the slow step; plotting is instant) ──────
global BADVISIT_SPEED_CACHE %#ok<GVMIS>
cacheKey = struct('subjectIDs', {subjectIDs});
if USE_CACHE && ~isempty(BADVISIT_SPEED_CACHE) && isfield(BADVISIT_SPEED_CACHE, 'visits') ...
        && isequal(BADVISIT_SPEED_CACHE.key, cacheKey) ...
        && (isempty(BADVISIT_SPEED_CACHE.visits) || isfield(BADVISIT_SPEED_CACHE.visits, 'errLists'))
    Scan = BADVISIT_SPEED_CACHE;
    fprintf('Using cached scan of %d visits (no reload). Set USE_CACHE=false to force a reload.\n', Scan.nVisits);
else
    Scan     = CollectAllVisits(basePath, subjectIDs);
    Scan.key = cacheKey;
    BADVISIT_SPEED_CACHE = Scan;
end

try
    BrowseBadVisits(Scan, subjectIDs, saveFile, SPEED_ALPHA, SPEED_WIDTH, SHOW_LAUNCH_BLACK, ...
        MJ_DESIRED_TIME, MJ_DESIRED_DISTANCE);
catch ME
    cd(originalDir);   % restore the working directory even if something errors out
    rethrow(ME);
end

cd(originalDir);   % go back to where we started


%% =========================================================================

function Scan = CollectAllVisits(basePath, subjectIDs)
% Pass 1 (the slow, cacheable step): scans every patient/visit .mat from disk,
% gathers the launch-aligned speed trajectories of the intermittent-exposure
% practiced-direction trials, and detects the visit type (EF vs SHAM).

    dirFields = {'DirectionZero','DirectionOne','DirectionTwo','DirectionThree'};

    visits  = struct([]);   % per-visit records (see BrowseBadVisits)
    nVisits = 0;

    for s = 1:numel(subjectIDs)
        subjectID  = subjectIDs{s};
        subjectDir = fullfile(basePath, subjectID);

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

            % One record for this visit: per-direction speed lists + type.
            rec = struct();
            rec.subjectID       = subjectID;
            rec.subjectIndex    = s;                    % row in the output matrices
            rec.visitNum        = v;                    % column in the output matrices
            rec.isPatient       = isPatient;
            rec.visitType       = DetectVisitType(Data);
            rec.speedLists      = {{}, {}, {}, {}};      % {d} = cell of [time, speed]
            rec.speedLaunchList = {{}, {}, {}, {}};      % {d} = cell of logical launch masks
            rec.velLists        = {{}, {}, {}, {}};      % {d} = cell of [time, forwardVel] (compensation view)
            rec.velLaunchList   = {{}, {}, {}, {}};      % {d} = cell of logical launch masks (velocity)
            rec.errLists        = {{}, {}, {}, {}};      % {d} = cell of [time, extentError]
            rec.errLaunchList   = {{}, {}, {}, {}};      % {d} = cell of logical launch masks (extent error)

            for dCount = 1:4
                idxList = GetDirectionIndices(SpecialMovementIndex, dirFields{dCount});
                for k = 1:numel(idxList)
                    idx = idxList(k);
                    if idx < 1 || idx > numel(Data) || isempty(Data{idx}), continue; end
                    [spTraj, spLaunchMask] = CollectSpeedTrajectory(Data{idx});
                    if ~isempty(spTraj)
                        rec.speedLists{dCount}{end+1}      = spTraj;       %#ok<AGROW>
                        rec.speedLaunchList{dCount}{end+1} = spLaunchMask; %#ok<AGROW>
                    end
                    % Forward-velocity (target-direction) trajectory for the same
                    % trial — the VelocityCompensationAnalysis.m signal.
                    [vfTraj, vfLaunchMask] = CollectForwardVelocityTrajectory(Data{idx});
                    if ~isempty(vfTraj)
                        rec.velLists{dCount}{end+1}      = vfTraj;       %#ok<AGROW>
                        rec.velLaunchList{dCount}{end+1} = vfLaunchMask; %#ok<AGROW>
                    end
                    % ExtentError vs. time for the same trial (launch-aligned).
                    [eeTraj, eeLaunchMask] = CollectExtentErrorTrajectory(Data{idx});
                    if ~isempty(eeTraj)
                        rec.errLists{dCount}{end+1}      = eeTraj;       %#ok<AGROW>
                        rec.errLaunchList{dCount}{end+1} = eeLaunchMask; %#ok<AGROW>
                    end
                end
            end

            % Keep the visit even if some directions are empty, as long as it
            % produced at least one speed trace (so the type still gets graded).
            hasAny = any(~cellfun(@isempty, rec.speedLists));
            if hasAny
                if isempty(visits), visits = rec; else, visits(end+1) = rec; end %#ok<AGROW>
            else
                nVisits = nVisits - 1;   % nothing usable -> don't count it
            end
        end
    end

    Scan.visits  = visits;
    Scan.nVisits = nVisits;
end


function vtype = DetectVisitType(Data)
% Error-Fields ON vs. SHAM detection. Among the trials with MovementNumber in
% [210, 250], if ANY TherapyForceAmplitude sample is non-zero the visit applied
% error fields (EF); if all such trials are all-zero it is a SHAM visit. If no
% trial falls in that range (or the field is missing) the type is "Unknown".

    isEF  = false;
    found = false;
    for i = 1:numel(Data)
        d = Data{i};
        if isempty(d) || ~isfield(d, 'MovementNumber') || isempty(d.MovementNumber), continue; end
        mn = d.MovementNumber;
        if mn >= 210 && mn <= 250
            if isfield(d, 'TherapyForceAmplitude') && ~isempty(d.TherapyForceAmplitude)
                found = true;
                if any(d.TherapyForceAmplitude(:) ~= 0)
                    isEF = true;
                    break   % one non-zero sample is enough to call it EF
                end
            end
        end
    end

    if ~found
        vtype = "Unknown";
    elseif isEF
        vtype = "EF";
    else
        vtype = "SHAM";
    end
end


function BrowseBadVisits(Scan, subjectIDs, saveFile, speedAlpha, speedWidth, showLaunchBlack, ...
        mjDesiredTime, mjDesiredDistance)
% Interactive per-visit browser with a "Bad visit" checkbox. Shows ONE visit at
% a time (4 axes, one per practiced direction) with every intermittent-exposure
% speed profile overlaid. Steps through visits with the buttons / arrow keys and
% records each visit's bad flag + type into the badVisitsList matrices, which are
% pushed to the base workspace and saved to disk on every change.

    visits = Scan.visits;
    nV     = numel(visits);
    if nV == 0
        warning('BadVisitSpeedBrowser:noVisits', ...
            'No visits with speed trajectories to browse. Check subjectIDs / data paths.');
        return
    end

    % ── Build the subject-by-visit output matrices ───────────────────────────
    nSub  = numel(subjectIDs);
    nCols = max([visits.visitNum]);        % columns = highest visit number seen

    badVisitsList = struct();
    badVisitsList.SubjectIDs   = string(subjectIDs(:));
    badVisitsList.VisitNumbers = 1:nCols;
    badVisitsList.BadVisit     = nan(nSub, nCols);        % NaN = no data
    badVisitsList.VisitType    = strings(nSub, nCols);    % "" = no data
    badVisitsList.Present      = false(nSub, nCols);

    for kk = 1:nV
        r = visits(kk).subjectIndex;
        c = visits(kk).visitNum;
        badVisitsList.BadVisit(r, c)  = 0;                % present -> default "ok"
        badVisitsList.VisitType(r, c) = visits(kk).visitType;
        badVisitsList.Present(r, c)   = true;
    end

    persistBadVisits();   % write the initial (all-ok) grid so the file exists

    PracticedColor = EquiDistantColorGenerator(4, 9742);
    dirLabels = {'Direction 0','Direction 1','Direction 2','Direction 3'};

    % ── Minimum-jerk speed template (same as InspectIndividualTrial). Its time
    %    axis is shifted so the template STARTS at t = -0.1 s (rather than 0), i.e.
    %    the launch onset falls 0.1 s into the template. Only its positive-speed
    %    portion is plotted, in red, on every axis.
    MJ_START_TIME   = -0.1;   % x-axis time at which the red template begins [s]
    mjTime          = (0:0.01:mjDesiredTime)';
    [~, mjVelocity] = MinimumJerkTrajectory(mjDesiredTime, mjDesiredDistance, mjTime);
    mjKeep          = mjVelocity > 0;
    mjTimePlot      = mjTime(mjKeep) + MJ_START_TIME;   % shift start to MJ_START_TIME
    mjVelPlot       = mjVelocity(mjKeep);

    % ── Figure + axes + navigation controls ──────────────────────────────────
    fig = figure('Name', 'Bad-visit speed browser', 'NumberTitle', 'off', 'Color', 'w');
    fig.WindowState = 'maximized';

    % Layout: the four directions keep a 2x2 arrangement. Each direction cell is
    % split into a BIG speed axis on the left and, on the right, a stacked pair of
    % SMALLER axes — forward-velocity ("compensation") on top and extent error on
    % the bottom. Positions are set EXPLICITLY (not via subplot defaults) so the
    % twelve axes fill the page with minimal white borders.
    xL = 0.045; xR = 0.995;    % left / right figure margins
    yB = 0.085; yT = 0.930;    % bottom (above control strip) / top (below sgtitle)
    colGap = 0.070;            % horizontal gap between the 2 direction columns
    rowGap = 0.105;            % vertical gap between the 2 direction rows
    cellW  = (xR - xL - colGap) / 2;      % width  of one direction cell
    cellH  = (yT - yB - rowGap) / 2;      % height of one direction cell

    SPEED_FRAC = 0.60;         % fraction of the cell width taken by the big speed axis
    innerGap   = 0.030;        % gap between the speed axis and the small-axes column
    smallVGap  = 0.090;        % vertical gap between the stacked velocity / extent axes
    speedW = SPEED_FRAC*cellW - 0.5*innerGap;
    smallW = (1 - SPEED_FRAC)*cellW - 0.5*innerGap;
    smallH = (cellH - smallVGap) / 2;

    ax    = gobjects(1, 4);    % big speed axes
    axVel = gobjects(1, 4);    % forward-velocity (compensation) axes (top-right, small)
    axErr = gobjects(1, 4);    % extent-error axes (bottom-right, small)
    for d = 1:4
        dCol  = mod(d-1, 2);                 % 0 = left column, 1 = right column
        dRow  = double(d > 2);               % 0 = top row,    1 = bottom row
        cellX = xL + dCol*(cellW + colGap);          % left edge of this direction cell
        cellY = yT - (dRow+1)*cellH - dRow*rowGap;   % bottom edge of this direction cell

        % Big speed axis: left portion, full cell height.
        ax(d) = axes('Parent', fig, 'Position', [cellX, cellY, speedW, cellH]);

        % Small stacked axes: right portion, split top (velocity) / bottom (extent).
        smallX = cellX + speedW + innerGap;
        axVel(d) = axes('Parent', fig, ...
            'Position', [smallX, cellY + smallH + smallVGap, smallW, smallH]);
        axErr(d) = axes('Parent', fig, ...
            'Position', [smallX, cellY, smallW, smallH]);
    end

    k = 1;   % current visit index (shared with the nested callbacks)

    uicontrol(fig, 'Style', 'pushbutton', 'String', '< Prev', ...
        'Units', 'normalized', 'Position', [0.30 0.005 0.10 0.045], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Callback', @(~,~) step(-1));
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Next >', ...
        'Units', 'normalized', 'Position', [0.48 0.005 0.10 0.045], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Callback', @(~,~) step(+1));
    counterTxt = uicontrol(fig, 'Style', 'text', 'String', '', ...
        'Units', 'normalized', 'Position', [0.40 0.008 0.08 0.035], ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
        'HorizontalAlignment', 'center');
    badChk = uicontrol(fig, 'Style', 'checkbox', 'String', 'Bad visit', ...
        'Units', 'normalized', 'Position', [0.62 0.005 0.12 0.045], ...
        'FontSize', 13, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
        'Callback', @(src,~) onToggleBad(src));

    fig.KeyPressFcn = @onKey;

    render();

    % ── Nested helpers (share k, ax, visits, badVisitsList, ...) ──────────────
    function step(delta)
        newK = min(max(k + delta, 1), nV);   % clamp at the ends
        if newK == k, return; end
        k = newK;
        render();
    end

    function onKey(~, evt)
        switch evt.Key
            case {'rightarrow', 'n'}, step(+1);
            case {'leftarrow',  'p'}, step(-1);
            case {'b', 'space'}                       % quick-toggle the bad flag
                set(badChk, 'Value', ~get(badChk, 'Value'));
                onToggleBad(badChk);
        end
    end

    function onToggleBad(src)
        rec = visits(k);
        badVisitsList.BadVisit(rec.subjectIndex, rec.visitNum) = double(get(src, 'Value'));
        persistBadVisits();
        updateSuperTitle();   % reflect BAD/ok in the header immediately
    end

    function render()
        rec = visits(k);

        % Common y-axis for all four directions: the largest speed seen across
        % every trial of this visit (the MJ template is smaller, so it's covered).
        maxSpeed = 0;
        for d = 1:4
            for i = 1:numel(rec.speedLists{d})
                maxSpeed = max(maxSpeed, max(rec.speedLists{d}{i}(:,2)));
            end
        end
        maxSpeed = max(maxSpeed, max([mjVelPlot; 0]));
        if ~isfinite(maxSpeed) || maxSpeed <= 0, maxSpeed = 1; end

        % Common y-axis for the forward-velocity axes: signed, so keep both the
        % lowest (most backward) and highest value across all four directions.
        velMin = 0; velMax = 0;
        for d = 1:4
            for i = 1:numel(rec.velLists{d})
                velMin = min(velMin, min(rec.velLists{d}{i}(:,2)));
                velMax = max(velMax, max(rec.velLists{d}{i}(:,2)));
            end
        end
        if ~(isfinite(velMin) && isfinite(velMax)) || velMax <= velMin
            velMin = -1; velMax = 1;
        end
        velPad = 0.05*(velMax - velMin);

        % Common y-axis for the extent-error axes: signed, shared across directions.
        errMin = 0; errMax = 0;
        for d = 1:4
            for i = 1:numel(rec.errLists{d})
                errMin = min(errMin, min(rec.errLists{d}{i}(:,2)));
                errMax = max(errMax, max(rec.errLists{d}{i}(:,2)));
            end
        end
        if ~(isfinite(errMin) && isfinite(errMax)) || errMax <= errMin
            errMin = -1; errMax = 1;
        end
        errPad = 0.05*(errMax - errMin);

        for d = 1:4
            col = PracticedColor(d, :);

            % ── Speed profile (left axis of the pair) ────────────────────────
            cla(ax(d), 'reset');
            hold(ax(d), 'on');

            n = PlotSpeedOverlay(ax(d), rec.speedLists{d}, rec.speedLaunchList{d}, ...
                    col, speedAlpha, speedWidth, showLaunchBlack);

            % Minimum-jerk template (positive-speed portion only), starting at t = 0.
            plot(ax(d), mjTimePlot, mjVelPlot, '-', 'Color', [0.5 0 0.125 0.85], 'LineWidth', speedWidth+3);

            grid(ax(d), 'off'); box(ax(d), 'off');
            set(ax(d), 'LineWidth', 3, 'FontSize', 12);   % speed axes ~twice as thick
            ylim(ax(d), [0, 1.05*maxSpeed]);   % same y-scale on all four speed axes
            xlabel(ax(d), 'Time (s)', 'FontSize', 13, 'FontWeight', 'bold');
            ylabel(ax(d), 'Speed (m/s)', 'FontSize', 13, 'FontWeight', 'bold');
            title(ax(d), sprintf('%s  (n = %d)', dirLabels{d}, n), ...
                'FontSize', 13, 'FontWeight', 'bold', 'Color', col);

            % ── Forward-velocity "compensation" profile (top-right, small) ───
            cla(axVel(d), 'reset');
            hold(axVel(d), 'on');

            % Zero reference: below it the hand is moving back toward the start.
            yline(axVel(d), 0, ':', 'Color', [0.6 0.6 0.6], 'LineWidth', 1, ...
                'HandleVisibility', 'off');

            PlotSpeedOverlay(axVel(d), rec.velLists{d}, rec.velLaunchList{d}, ...
                    col, speedAlpha, speedWidth, showLaunchBlack);

            grid(axVel(d), 'off'); box(axVel(d), 'off');
            % Grey axis rulers/ticks (rulers don't support alpha; [0.7 0.7 0.7]
            % is what 70%-transparent black axes would look like on white).
            set(axVel(d), 'LineWidth', 1.5, 'FontSize', 10, ...
                'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            ylim(axVel(d), [velMin - velPad, velMax + velPad]);   % shared, signed
            ylabel(axVel(d), 'Forward vel (m/s)', 'FontSize', 10, 'FontWeight', 'bold');
            title(axVel(d), 'Velocity in target direction', ...
                'FontSize', 10, 'FontWeight', 'bold', 'Color', col);

            % ── Extent-error profile (bottom-right, small) ───────────────────
            cla(axErr(d), 'reset');
            hold(axErr(d), 'on');

            % Zero reference: the target extent (no over/undershoot).
            yline(axErr(d), 0, ':', 'Color', [0.6 0.6 0.6], 'LineWidth', 1, ...
                'HandleVisibility', 'off');

            PlotSpeedOverlay(axErr(d), rec.errLists{d}, rec.errLaunchList{d}, ...
                    col, speedAlpha, speedWidth, showLaunchBlack);

            grid(axErr(d), 'off'); box(axErr(d), 'off');
            set(axErr(d), 'LineWidth', 1.5, 'FontSize', 10, ...
                'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7]);
            ylim(axErr(d), [errMin - errPad, errMax + errPad]);   % shared, signed
            xlabel(axErr(d), 'Time (s)', 'FontSize', 10, 'FontWeight', 'bold');
            ylabel(axErr(d), 'Extent error (m)', 'FontSize', 10, 'FontWeight', 'bold');
            title(axErr(d), 'Extent error', ...
                'FontSize', 10, 'FontWeight', 'bold', 'Color', col);
        end

        % Sync the checkbox to the stored value for this visit.
        stored = badVisitsList.BadVisit(rec.subjectIndex, rec.visitNum);
        set(badChk, 'Value', stored == 1);
        set(counterTxt, 'String', sprintf('%d / %d', k, nV));

        updateSuperTitle();
    end

    function updateSuperTitle()
        rec = visits(k);
        if rec.isPatient
            who = sprintf('%s — Visit %d', rec.subjectID, rec.visitNum);
        else
            who = sprintf('Healthy %s', rec.subjectID);
        end
        stored = badVisitsList.BadVisit(rec.subjectIndex, rec.visitNum);
        if stored == 1, grade = 'BAD'; else, grade = 'ok'; end
        sgtitle(sprintf('%s   [%s]   grade: %s      (%d of %d)', ...
            who, rec.visitType, grade, k, nV), ...
            'FontSize', 16, 'FontWeight', 'bold');
    end

    function persistBadVisits()
        % Build a readable "<BAD|ok>-<TYPE>" table, then push to base + disk.
        badVisitsList.Summary = BuildSummaryTable(badVisitsList);
        assignin('base', 'badVisitsList', badVisitsList);
        try
            save(saveFile, 'badVisitsList');
        catch saveErr
            warning('BadVisitSpeedBrowser:saveFailed', ...
                'Could not save badVisitsList to %s (%s).', saveFile, saveErr.message);
        end
    end
end


function T = BuildSummaryTable(B)
% Human-readable subject-by-visit grid: each cell is "<BAD|ok>-<TYPE>", or "-"
% where no visit was loaded. Rows are subjects, one column per visit.

    [nSub, nCols] = size(B.BadVisit);
    C = strings(nSub, nCols);
    for r = 1:nSub
        for c = 1:nCols
            if ~B.Present(r, c)
                C(r, c) = "-";
            else
                if B.BadVisit(r, c) == 1, g = "BAD"; else, g = "ok"; end
                C(r, c) = g + "-" + B.VisitType(r, c);
            end
        end
    end
    varNames = "V" + string(B.VisitNumbers);
    T = array2table(C, 'RowNames', cellstr(B.SubjectIDs), 'VariableNames', cellstr(varNames));
end


function nUsed = PlotSpeedOverlay(ax, speedList, launchMaskList, col, alpha, lineW, showLaunchBlack)
% Overlays every trial's real speed vs. time (launch-aligned, one on top of
% another) as a semi-transparent line; optionally each trial's launch-window
% samples in black. Returns the trial count.

    nUsed = numel(speedList);
    for i = 1:nUsed
        t  = speedList{i}(:,1);
        sp = speedList{i}(:,2);

        plot(ax, t, sp, '-', 'Color', [col, alpha], 'LineWidth', lineW);

        if showLaunchBlack
            lm = launchMaskList{i};
            if any(lm)
                plot(ax, t(lm), sp(lm), '-', 'Color', [0 0 0 alpha], 'LineWidth', lineW);
            end
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


function [traj, launchMask] = CollectForwardVelocityTrajectory(d)
% Returns [time, forwardVel] for one trial (launch onset shifted to t = 0) and a
% logical launch-window mask. traj is [] if unusable. This is the
% VelocityCompensationAnalysis.m signal: forwardVel = GlobalVelocity projected
% onto the movement-direction unit vector (velocity toward the intended target;
% NEGATIVE = hand moving back toward the start).

    traj       = [];
    launchMask = [];
    if ~isfield(d, 'GlobalVelocity') || isempty(d.GlobalVelocity), return; end
    if ~isfield(d, 'SampleTime')     || isempty(d.SampleTime),     return; end

    fwd = GetMovementDirectionVector(d);   % 1x3 unit vector (global frame)
    if isempty(fwd), return; end

    V = d.GlobalVelocity;
    if size(V, 2) ~= 3
        if size(V, 1) == 3, V = V'; else, return; end   % coerce to N x 3
    end

    forwardVel = V * fwd(:);                 % N×1 projection onto movement direction [m/s]
    time       = ConstructTimeFromSampleTime(d.SampleTime);
    time       = time(:);

    launchIndex = GetLaunchWindow(d);
    hasLaunch   = ~(isscalar(launchIndex) && launchIndex == 0) ...
                  && launchIndex(1) >= 1 && launchIndex(1) <= numel(time);
    if hasLaunch
        time = time - time(launchIndex(1));   % shift so launch onset is at t = 0
    end

    n = min(numel(time), numel(forwardVel));
    if n < 2, return; end
    time       = time(1:n);
    forwardVel = forwardVel(1:n);

    launchMask = false(n, 1);
    if hasLaunch
        li = launchIndex(launchIndex >= 1 & launchIndex <= n);
        launchMask(li) = true;
    end
    traj = [time, forwardVel];
end


function [traj, launchMask] = CollectExtentErrorTrajectory(d)
% Returns [time, extentError] for one trial (launch onset shifted to t = 0) and a
% logical launch-window mask. traj is [] if unusable. ExtentError is the signed
% error along the movement extent, as used by BimodalExtentErrorDistributions.m /
% PrematureOnsetVsHighError.m (kept in native units, m).

    traj       = [];
    launchMask = [];
    if ~isfield(d, 'ExtentError') || isempty(d.ExtentError), return; end
    if ~isfield(d, 'SampleTime')  || isempty(d.SampleTime),  return; end

    extentError = d.ExtentError(:);            % N×1 signed extent error [m]
    time        = ConstructTimeFromSampleTime(d.SampleTime);
    time        = time(:);

    launchIndex = GetLaunchWindow(d);
    hasLaunch   = ~(isscalar(launchIndex) && launchIndex == 0) ...
                  && launchIndex(1) >= 1 && launchIndex(1) <= numel(time);
    if hasLaunch
        time = time - time(launchIndex(1));   % shift so launch onset is at t = 0
    end

    n = min(numel(time), numel(extentError));
    if n < 2, return; end
    time        = time(1:n);
    extentError = extentError(1:n);

    launchMask = false(n, 1);
    if hasLaunch
        li = launchIndex(launchIndex >= 1 & launchIndex <= n);
        launchMask(li) = true;
    end
    traj = [time, extentError];
end


function fwd = GetMovementDirectionVector(d)
% Unit vector (1x3, global/Unity frame) pointing along the intended movement
% direction for this trial. Primary source: the per-trial RotationMatrix, whose
% first row is the local +x axis (= movement direction) in global coordinates.
% Falls back to the canonical direction table keyed by MovementDirection (0..7).

    fwd = [];
    if isfield(d, 'RotationMatrix') && ~isempty(d.RotationMatrix) && isequal(size(d.RotationMatrix), [3 3])
        fwd = d.RotationMatrix(1, :);
    elseif isfield(d, 'MovementDirection') && ~isempty(d.MovementDirection)
        mdir = d.MovementDirection;
        [d0,d1,d2,d3,d4,d5,d6,d7] = GetDirectionsAndMatrixes('numeric');
        table = [d0'; d1'; d2'; d3'; d4'; d5'; d6'; d7'];
        if mdir >= 0 && mdir <= 7
            fwd = table(mdir + 1, :);
        end
    end
    if ~isempty(fwd)
        nrm = norm(fwd);
        if nrm > 0, fwd = fwd / nrm; end   % ensure a unit vector -> true component [m/s]
    end
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
