%% Wrong Movement-Onset Detection Analysis
%
%  Mirrors the structure of ErrorAmplitudeBimodalDistributionAnalysis.m, but
%  instead of the bimodal error check it quantifies how often the robot's
%  real-time movement-onset detection fired PREMATURELY (a "wrong" onset).
%
%  For every patient visit it:
%    1. Loads the visit .mat (global `Data` + `SpecialMovementIndex`).
%    2. Runs CalculateMACCOnset(), which compares the robot onset against the
%       MACC-model onset for every trial and writes a `PrematureDetection`
%       flag into each Data{i}:
%           true  -> robot fired BEFORE the true onset  (WRONG detection)
%           false -> robot fired at/after the true onset (correct)
%           NaN   -> trial could not be processed
%    3. Restricts attention to the intermittent-exposure, practiced-direction
%       trials only, i.e. the indices listed in
%           SpecialMovementIndex.IntermittentExposure.DirectionZero
%                                                  .DirectionOne
%                                                  .DirectionTwo
%                                                  .DirectionThree
%       (these hold INDICES into Data, not movement numbers).
%    4. Counts, among those trials, how many have PrematureDetection == true.
%
%  Outputs (left in the base workspace after running):
%    results          - flat struct array, one row per visit, used for the plots.
%                       Dir* fields (DirNumWrong / DirNumTargets / DirFracWrong,
%                       1x4, column d+1 = direction d) hold the per-direction
%                       split of the same trials.
%    WrongOnsetTrials - nested struct: WrongOnsetTrials.<subj>.Visit<v>.WrongMovementNumbers
%
%  Two figures are drawn: the overall wrong/total per visit, and the same grid
%  with each cell broken down by practiced direction (SHOW_DIRECTION_FIGURE).
%
%  NOTE ON RUNTIME: CalculateMACCOnset() re-derives the onset for EVERY trial
%  of a visit (not just the intermittent-exposure ones), so a full 12-patient
%  x 9-visit scan is heavy. It therefore runs ONCE: if `results` and
%  `WrongOnsetTrials` are already in the workspace, a re-run skips the whole
%  scan and goes straight to the plot. Set FORCE_RESCAN = true (or
%  `clear results`) when the data or the scan settings changed.

% ── Patients to analyze (each = 9 numbered visits, files <ID>/<ID>_Visit_<v>.mat) ──
subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28','E-38','E-42','E-44','E-47','E-56','E-69','E-91','E-93'};

% ── Blindness ────────────────────────────────────────────────────────────────
%  true  -> subject IDs are hidden everywhere they would be shown (console log
%           and the heatmap y-axis): each patient is labelled 'Patient N', with
%           N the position in the subjectIDs list above.
%  false -> real IDs ('E-5', 'E-16', ...) are shown, as before.
%  Only the DISPLAY changes: the data files loaded and the SubjectID stored in
%  `results` / `WrongOnsetTrials` always keep the real ID.
BLINDNESS = true;
% ───────────────────────────────────────────────────────────────────────────

% ── Error-Fields ON vs. SHAM visit detection ─────────────────────────────────
%  Same rule BadVisitSpeedBrowser.m uses (its DetectVisitType): among the trials
%  whose MovementNumber falls in EF_MOVEMENT_RANGE, if ANY TherapyForceAmplitude
%  sample is non-zero the visit delivered error fields (EF); if every such trial
%  is all-zero it is a SHAM visit; if no trial falls in the range (or the field is
%  missing) the type is "Unknown" and no box is drawn.
%  EF visits get a green outline drawn around their cell in the grid.
EF_MOVEMENT_RANGE = [210 250];      % MovementNumber window searched for therapy force
SHOW_EF_BOXES     = true;           % false = plain grid, no outlines
EF_BOX_COLOR      = [0 0.65 0.25];  % green
EF_BOX_WIDTH      = 5;              % outline thickness
% ───────────────────────────────────────────────────────────────────────────

% ── Second figure: per-direction breakdown ───────────────────────────────────
%  Same grid/colours as the first figure, but each cell lists the wrong-onset
%  rate of each of the 4 practiced directions instead of the overall ratio, so a
%  visit with a high rate can be checked for a single bad direction vs. all four.
%  The 4 directions are laid out 2 x 2 across the cell:
%      Dir0: 25%   Dir1:  8%
%      Dir2:  0%   Dir3: 58%
SHOW_DIRECTION_FIGURE = true;   % false = only the summary figure
%  DIR_SHOW_COUNTS = true appends the trial counts ('Dir0: 25% (3/12)'). Those
%  are too wide to sit two-per-line, so that mode reverts to 4 stacked lines in
%  a much smaller font — leave it false for the large, readable 2 x 2 layout.
DIR_SHOW_COUNTS       = false;
%  DIR_FONT_SIZE sets the size of the per-direction percentages. [] = automatic
%  (sized off the number of visit columns). Too large and the two columns of a
%  cell run into each other — lower it if they overlap.
DIR_FONT_SIZE         = 14;
% ───────────────────────────────────────────────────────────────────────────

% Locate the project root (holds the E-XX/ data + helper functions). Works whether
% this script sits at the root or has been moved into a subfolder (e.g.
% BimodalErrorDistribution/): the root is the folder with the main pipeline file.
scriptDir = fileparts(mfilename('fullpath'));
if isfile(fullfile(scriptDir, 'MainAnalysis_Nine_Phase.m'))
    rootDir = scriptDir;               % script is at the project root
else
    rootDir = fileparts(scriptDir);    % script is in a subfolder -> root is one level up
end
addpath(rootDir);   % so helper .m files (CalculateMACCOnset, maccOnset, ...) resolve
cd(rootDir);        % so the E-XX/ data folders are found
basePath = rootDir;   % = the folder holding the E-XX/ data

% The cd above is only needed while the data are being read. The script always
% restores the folder it lives in (scriptDir) before it ends — see the cd at the
% bottom — so you are left where this file is, not in the data root.

% ── Scan, or reuse the scan already in the workspace ─────────────────────────
% The heavy step is ScanAllVisits (it loads every visit .mat and re-runs the
% MACC onset detection on every trial). This is a script, so `results` and
% `WrongOnsetTrials` survive in the base workspace after the first run: on a
% re-run we detect them and jump straight to the plot.
%   FORCE_RESCAN = true  -> always re-scan, even if a cached scan exists
%                           (use after changing subjectIDs, EF_MOVEMENT_RANGE,
%                            CalculateMACCOnset, or the visit .mat files).
%   clear results        -> also forces a fresh scan on the next run.
% BLINDNESS is applied at plot time, so toggling it and re-running is free.
FORCE_RESCAN = false;

% ScanAllVisits() (with its helpers DetectVisitType() and GatherIntXIndices())
% used to be a local function of this script. It now lives at the project root
% as a standalone ScanAllVisits.m, unchanged, so that
% SpeedAccuracyPlots/SpeedvsAccuracy_Patients.m can run the same scan to
% annotate its Error-Fields figure titles. The addpath(rootDir) above is what
% makes it resolve from here.

% (This is a script, so exist(...,'var') sees the workspace it was run from.)
% A `results` scanned before the per-direction breakdown existed lacks
% DirNumWrong; it is treated as no cache so the second figure has its data.
haveCache = exist('results','var') && exist('WrongOnsetTrials','var') ...
            && ~isempty(results) && isfield(results, 'DirNumWrong');

% try/catch so an error mid-scan still leaves you in this script's folder
% rather than stranded in the data root.
try
    if FORCE_RESCAN || ~haveCache
        [results, WrongOnsetTrials] = ScanAllVisits(basePath, subjectIDs, EF_MOVEMENT_RANGE, BLINDNESS);
    else
        fprintf(['Reusing the cached scan already in the workspace: %d visits ' ...
                 '(set FORCE_RESCAN = true, or "clear results", to re-scan).\n'], numel(results));
    end

    PlotOnsetSummary(results, SHOW_EF_BOXES, EF_BOX_COLOR, EF_BOX_WIDTH, BLINDNESS);

    if SHOW_DIRECTION_FIGURE
        PlotOnsetByDirection(results, SHOW_EF_BOXES, EF_BOX_COLOR, EF_BOX_WIDTH, ...
                             BLINDNESS, DIR_SHOW_COUNTS, DIR_FONT_SIZE);
    end
catch scanErr
    cd(scriptDir);
    rethrow(scanErr);
end

% ── Back to the folder this script lives in ──────────────────────────────────
cd(scriptDir);


%% =========================================================================

function PlotOnsetSummary(results, showEFBoxes, efColor, efWidth, blindness)
% Subject x Visit heatmap of the number of wrong onset detections.
%   colour  = number of wrong detections (white = 0, deepening red = more)
%   gray    = no .mat file / visit not scanned
%   text    = "wrong/total" and the percentage for each scanned visit
%   green outline = Error-Fields ON visit (see DetectVisitType)
%
% blindness = true replaces the y-axis subject IDs with 'Patient N', numbered
% by the order the subjects appear in `results`.

    if nargin < 2 || isempty(showEFBoxes), showEFBoxes = true;          end
    if nargin < 3 || isempty(efColor),     efColor     = [0 0.65 0.25]; end
    if nargin < 4 || isempty(efWidth),     efWidth     = 5;             end
    if nargin < 5 || isempty(blindness),   blindness   = false;         end

    if isempty(results)
        disp('No results to display.');
        return
    end

    [G, subjectLabels] = BuildOnsetGrids(results, blindness);

    % Cell text: wrong/total on the first line, the percentage on the second.
    % One block, centred in the cell (dx = 0 horizontal offset).
    cellText = @(s,v) struct('dx', 0, 'halign', 'center', ...
        'str', sprintf('%d/%d\n%.0f%%', G.count(s,v), G.target(s,v), 100*G.frac(s,v)));

    DrawOnsetHeatmap(G, subjectLabels, cellText, 11, ...
        'Wrong (premature) movement-onset detections — intermittent-exposure Dir 0-3 trials', ...
        'Number of wrong onset detections for the EF formation trials', ...
        showEFBoxes, efColor, efWidth);
end


function PlotOnsetByDirection(results, showEFBoxes, efColor, efWidth, blindness, showCounts, dirFontSize)
% Same grid, colours and EF outlines as PlotOnsetSummary, but each cell breaks
% the wrong-onset rate down by practiced direction, laid out 2 x 2 so the text
% uses the full width of the cell and can be printed large:
%
%       Dir0: 25%   Dir1:  8%
%       Dir2:  0%   Dir3: 58%
%
% so a visit flagged in the first figure can be checked for whether the wrong
% detections sit in one direction or spread evenly over all four. The cell
% COLOUR is still the visit's total wrong count, so both figures shade
% identically and can be compared side by side.
%
% showCounts = true adds the "(3/12)" trial counts. Those are ~twice as wide, so
% they do not fit two-per-line: that mode falls back to 4 stacked lines in a
% smaller font (the layout this figure had before).

    if nargin < 2 || isempty(showEFBoxes), showEFBoxes = true;          end
    if nargin < 3 || isempty(efColor),     efColor     = [0 0.65 0.25]; end
    if nargin < 4 || isempty(efWidth),     efWidth     = 5;             end
    if nargin < 5 || isempty(blindness),   blindness   = false;         end
    if nargin < 6 || isempty(showCounts),  showCounts  = false;         end
    if nargin < 7,                         dirFontSize = [];            end

    if isempty(results)
        disp('No results to display.');
        return
    end
    if ~isfield(results, 'DirNumWrong')
        disp(['`results` has no per-direction breakdown (it was scanned by an ' ...
              'older version). Set FORCE_RESCAN = true, or "clear results", and re-run.']);
        return
    end

    [G, subjectLabels] = BuildOnsetGrids(results, blindness);

    cellText = @(s,v) DirectionCellText(G, s, v, showCounts);

    % 2 x 2 layout leaves room for a readable font; the wide 4-line variant
    % (showCounts) has to stay small. What limits the size is the CELL WIDTH,
    % i.e. the number of visit columns, not the number of subject rows.
    % An explicit dirFontSize (DIR_FONT_SIZE) overrides the automatic size.
    if ~isempty(dirFontSize)
        % use the size given
    elseif showCounts
        if G.numSubjects > 10, dirFontSize = 8;  else, dirFontSize = 9;  end
    elseif G.numVisits > 6
        dirFontSize = 10;
    else
        dirFontSize = 13;
    end

    DrawOnsetHeatmap(G, subjectLabels, cellText, dirFontSize, ...
        'Wrong (premature) onset detections per practiced direction — intermittent-exposure trials', ...
        'Number of wrong onset detections for the EF formation trials (all 4 directions)', ...
        showEFBoxes, efColor, efWidth);
end


function T = DirectionCellText(G, s, v, showCounts)
% Per-direction label of one cell, as text blocks for DrawOnsetHeatmap: each
% element has .dx (horizontal offset from the cell centre, in cell widths) and
% .str. A direction with no trial, or with every trial unprocessed, shows '-'
% instead of a percentage.
%
%   showCounts = false -> two blocks side by side, Dir0/Dir2 left, Dir1/Dir3
%                         right, so the 4 numbers fill the cell in a 2 x 2 grid.
%   showCounts = true  -> one block of 4 stacked lines (too wide to pair up).

    lines = cell(1,4);
    for k = 1:4
        nTrials = G.dirTarget(s, v, k);
        nWrong  = G.dirWrong(s, v, k);
        frac    = G.dirFrac(s, v, k);
        if showCounts
            if isnan(frac)
                lines{k} = sprintf('Dir%d: -', k-1);
            else
                lines{k} = sprintf('Dir%d: %.0f%% (%d/%d)', k-1, 100*frac, nWrong, nTrials);
            end
        else
            % Short 'D0' labels: two of them have to fit side by side in one
            % cell, which is what allows the larger font.
            if isnan(frac)
                lines{k} = sprintf('D%d   -', k-1);
            else
                lines{k} = sprintf('D%d %3.0f%%', k-1, 100*frac);
            end
        end
    end

    if showCounts
        T = struct('dx', 0, 'halign', 'center', 'str', strjoin(lines, newline));
    else
        % Two separate text objects rather than one padded string: the default
        % font is proportional, so space padding would not line the columns up.
        % The left block is left-aligned against the left cell edge and the
        % right block right-aligned against the right edge (±0.46 of a cell
        % width), so the text spans the whole cell and the gap falls in the
        % middle, where it separates the two columns.
        T = struct('dx',     {-0.46, 0.46}, ...
                   'halign', {'left', 'right'}, ...
                   'str',    {strjoin(lines([1 3]), newline), ...
                              strjoin(lines([2 4]), newline)});
    end
end


function [G, subjectLabels] = BuildOnsetGrids(results, blindness)
% Turns the flat `results` rows into the Subject x Visit matrices both figures
% draw. NaN marks a visit that was not scanned (drawn gray).
%   G.count / G.target / G.frac      - overall, per cell
%   G.dirWrong / G.dirTarget / G.dirFrac - numSubjects x numVisits x 4 (dir 0..3)
%   G.isEF                           - true where the visit delivered error fields
%
% subjectLabels are the y-axis labels: the real IDs, or 'Patient N' numbered by
% row when blinded. Rows are still matched to results by the real SubjectID.

    subjectList = unique({results.SubjectID}, 'stable');
    numSubjects = numel(subjectList);
    numVisits   = max([results.VisitNum]);

    if blindness
        subjectLabels = arrayfun(@(s) sprintf('Patient %d', s), 1:numSubjects, ...
            'UniformOutput', false);
    else
        subjectLabels = subjectList;
    end

    G.numSubjects = numSubjects;
    G.numVisits   = numVisits;
    G.numResults  = numel(results);
    G.count     = nan(numSubjects, numVisits);      % NaN -> missing (gray)
    G.target    = nan(numSubjects, numVisits);
    G.frac      = nan(numSubjects, numVisits);
    G.isEF      = false(numSubjects, numVisits);    % true -> draw the green outline
    G.dirWrong  = nan(numSubjects, numVisits, 4);
    G.dirTarget = nan(numSubjects, numVisits, 4);
    G.dirFrac   = nan(numSubjects, numVisits, 4);

    hasDir = isfield(results, 'DirNumWrong');

    for r = 1:numel(results)
        s = find(strcmp(subjectList, results(r).SubjectID));
        v = results(r).VisitNum;
        G.count(s,  v) = results(r).NumWrong;
        G.target(s, v) = results(r).NumTargets;
        G.frac(s,   v) = results(r).FracWrong;
        % Older cached `results` (scanned before EF typing existed) have no
        % VisitType field — treat those as untyped rather than erroring.
        if isfield(results, 'VisitType')
            G.isEF(s, v) = strcmp(string(results(r).VisitType), "EF");
        end
        if hasDir && ~isempty(results(r).DirNumWrong)
            G.dirWrong(s, v, :)  = results(r).DirNumWrong;
            G.dirTarget(s, v, :) = results(r).DirNumTargets;
            G.dirFrac(s, v, :)   = results(r).DirFracWrong;
        end
    end
end


function DrawOnsetHeatmap(G, subjectLabels, cellTextFcn, cellFontSize, titleStr, cbLabel, ...
                          showEFBoxes, efColor, efWidth)
% Draws the Subject x Visit heatmap shared by both figures. Colour always
% encodes G.count (wrong detections); cellTextFcn(s,v) supplies the label
% printed inside each scanned cell, which is what distinguishes the two.

    numSubjects = G.numSubjects;
    numVisits   = G.numVisits;

    fig = figure;
    fig.WindowState = 'maximized';
    ax  = axes(fig);

    hImg = imagesc(ax, G.count);
    set(hImg, 'AlphaData', ~isnan(G.count));   % missing cells show the gray axis
    ax.Color = [0.75 0.75 0.75];

    % White (0 wrong) -> deep red (many wrong)
    cN   = 256;
    cmap = [linspace(1, 0.6, cN)', linspace(1, 0.06, cN)', linspace(1, 0.06, cN)'];
    colormap(ax, cmap);
    maxCount = max(G.count(:));
    if isempty(maxCount) || ~isfinite(maxCount) || maxCount <= 0, maxCount = 1; end
    caxis(ax, [0 maxCount]);
    cb = colorbar(ax);
    cb.Label.String   = cbLabel;
    cb.Label.FontSize = 14;

    ax.XTick      = 1:numVisits;
    ax.XTickLabel = arrayfun(@(v) sprintf('V%d', v), 1:numVisits, 'UniformOutput', false);
    ax.YTick      = 1:numSubjects;
    ax.YTickLabel = subjectLabels;
    ax.FontSize   = 16;
    ax.FontWeight = 'bold';

    xlabel(ax, 'Visit',   'FontSize', 18, 'FontWeight', 'bold');
    ylabel(ax, 'Subject', 'FontSize', 18, 'FontWeight', 'bold');
    title(ax, titleStr, 'FontSize', 16, 'FontWeight', 'bold');

    % Annotate each scanned cell. cellTextFcn returns one or more blocks, each
    % with a .dx offset from the cell centre (in cell widths) — that is how the
    % per-direction figure puts two columns side by side inside one cell.
    hold(ax, 'on');
    for s = 1:numSubjects
        for v = 1:numVisits
            if ~isnan(G.count(s, v))
                % Dark text on light cells, white text on dark-red cells.
                if G.count(s, v) > 0.6 * maxCount, txtColor = [1 1 1]; else, txtColor = [0 0 0]; end
                blocks = cellTextFcn(s, v);
                for b = 1:numel(blocks)
                    text(ax, v + blocks(b).dx, s, blocks(b).str, ...
                        'HorizontalAlignment', blocks(b).halign, 'VerticalAlignment', 'middle', ...
                        'FontSize', cellFontSize, 'FontWeight', 'bold', 'Color', txtColor);
                end
            end
        end
    end

    % ── Green outline around every Error-Fields ON visit ─────────────────────
    % imagesc puts cell (s,v) between x = v±0.5 and y = s±0.5, so a unit
    % rectangle at that corner traces the cell border exactly. Drawn after the
    % text so the outline always sits on top.
    nEF = 0;
    if showEFBoxes
        for s = 1:numSubjects
            for v = 1:numVisits
                if G.isEF(s, v)
                    rectangle(ax, 'Position', [v-0.5, s-0.5, 1, 1], ...
                        'EdgeColor', efColor, 'LineWidth', efWidth, 'FaceColor', 'none');
                    nEF = nEF + 1;
                end
            end
        end
    end

    % Legend: a dummy off-grid marker carries the green box into a legend entry.
    if showEFBoxes && nEF > 0
        hEF = plot(ax, NaN, NaN, 's', 'MarkerSize', 14, 'LineWidth', efWidth, ...
            'MarkerEdgeColor', efColor, 'MarkerFaceColor', 'none');
        legend(ax, hEF, 'Error Fields ON visit', 'TextColor', efColor, ...
            'FontSize', 14, 'FontWeight', 'bold', 'Location', 'southoutside', ...
            'Orientation', 'horizontal', 'Box', 'off');
    end

    hold(ax, 'off');

    if showEFBoxes
        fprintf('Error-Fields ON visits outlined in green: %d of %d scanned.\n', ...
            nEF, G.numResults);
    end
end
