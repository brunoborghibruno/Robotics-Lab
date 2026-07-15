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
%    results          - flat struct array, one row per visit, used for the plot.
%    WrongOnsetTrials - nested struct: WrongOnsetTrials.<subj>.Visit<v>.WrongMovementNumbers
%
%  NOTE ON RUNTIME: CalculateMACCOnset() re-derives the onset for EVERY trial
%  of a visit (not just the intermittent-exposure ones), so a full 12-patient
%  x 9-visit scan is heavy. Comment out the `results = ...` line below to
%  re-plot a cached `results` without re-scanning.

% ── Patients to analyze (each = 9 numbered visits, files <ID>/<ID>_Visit_<v>.mat) ──
subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28', ...
              'E-38','E-42','E-44','E-47','E-56','E-69'};
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

% Comment out the next line to re-plot a cached `results`/`WrongOnsetTrials`.
[results, WrongOnsetTrials] = ScanAllVisits(basePath, subjectIDs);

PlotOnsetSummary(results);


%% =========================================================================

function [results, WrongOnsetTrials] = ScanAllVisits(basePath, subjectIDs)
% Loops over the 9 numbered visits of every patient, runs the MACC onset
% check, and tallies the premature (wrong) detections among the
% intermittent-exposure practiced-direction trials.

    global Data %#ok<GVMIS>  % CalculateMACCOnset() reads/writes the global Data

    results = struct('SubjectID',{}, 'VisitNum',{}, ...
                     'NumTargets',{}, 'NumWrong',{}, 'NumUnprocessed',{}, ...
                     'FracWrong',{}, 'WrongMovementNumbers',{}, 'WrongDataIndices',{});
    rowCount = 0;

    WrongOnsetTrials = struct();
    grandWrong  = 0;
    grandTarget = 0;

    for s = 1:numel(subjectIDs)
        subjectID    = subjectIDs{s};
        subjectField = matlab.lang.makeValidName(subjectID);   % 'E-5' -> 'E_5'
        subjectDir   = fullfile(basePath, subjectID);

        WrongOnsetTrials.(subjectField).SubjectID = subjectID;

        for v = 1:9
            fpath      = fullfile(subjectDir, sprintf('%s_Visit_%d.mat', subjectID, v));
            visitField = sprintf('Visit%d', v);
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

            % ── Target trials: intermittent-exposure practiced directions 0..3 ──
            idxList = GatherIntXIndices(loaded.SpecialMovementIndex);
            if isempty(idxList)
                fprintf('%-6s Visit %d  |  no IntermittentExposure Dir0-3 trials - skipped\n', subjectID, v);
                continue
            end

            % ── Run the MACC onset detection on this visit's Data ──────────────
            % CalculateMACCOnset() operates on the global Data and is chatty; the
            % evalc() wrapper runs it while discarding its per-trial printouts.
            Data = loaded.Data;                       %#ok<NASGU>  % populate the global
            try
                evalc('CalculateMACCOnset();');
            catch
                fprintf('%-6s Visit %d  |  CalculateMACCOnset failed - skipped\n', subjectID, v);
                continue
            end

            % ── Tally premature (wrong) detections among the target trials ─────
            idxList = idxList(idxList >= 1 & idxList <= numel(Data));
            wrongIdx = [];
            wrongMN  = [];
            nUnproc  = 0;
            for k = 1:numel(idxList)
                % idx is a DIRECT index into the Data cell array (Data{idx}),
                % NOT a MovementNumber. The SpecialMovementIndex fields store
                % Data-cell positions; MovementNumber is only read back out of
                % the selected trial below for reporting.
                idx = idxList(k);
                d = Data{idx};
                if isempty(d) || ~isfield(d, 'PrematureDetection'), nUnproc = nUnproc + 1; continue; end
                pd = d.PrematureDetection;
                if isnan(pd)
                    nUnproc = nUnproc + 1;
                elseif pd == true
                    wrongIdx(end+1,1) = idx;                 %#ok<AGROW>
                    if isfield(d, 'MovementNumber')
                        wrongMN(end+1,1) = d.MovementNumber; %#ok<AGROW>
                    else
                        wrongMN(end+1,1) = NaN;              %#ok<AGROW>
                    end
                end
            end

            nTargets = numel(idxList);
            nWrong   = numel(wrongIdx);
            fracWrong = nWrong / max(nTargets - nUnproc, 1);   % over the trials we could process

            fprintf('%-6s Visit %d  |  IntX Dir0-3 trials=%3d  wrong=%3d (%3.0f%%)  unprocessed=%2d\n', ...
                subjectID, v, nTargets, nWrong, 100*fracWrong, nUnproc);

            % ── Store flat result row ─────────────────────────────────────────
            rowCount = rowCount + 1;
            results(rowCount).SubjectID            = subjectID;
            results(rowCount).VisitNum             = v;
            results(rowCount).NumTargets           = nTargets;
            results(rowCount).NumWrong             = nWrong;
            results(rowCount).NumUnprocessed       = nUnproc;
            results(rowCount).FracWrong            = fracWrong;
            results(rowCount).WrongMovementNumbers = wrongMN;
            results(rowCount).WrongDataIndices     = wrongIdx;

            % ── Store nested "all subjects / visits / trials" variable ────────
            WrongOnsetTrials.(subjectField).(visitField).VisitNum             = v;
            WrongOnsetTrials.(subjectField).(visitField).NumTargets           = nTargets;
            WrongOnsetTrials.(subjectField).(visitField).NumWrong             = nWrong;
            WrongOnsetTrials.(subjectField).(visitField).NumUnprocessed       = nUnproc;
            WrongOnsetTrials.(subjectField).(visitField).WrongMovementNumbers = wrongMN;
            WrongOnsetTrials.(subjectField).(visitField).WrongDataIndices     = wrongIdx;

            grandWrong  = grandWrong  + nWrong;
            grandTarget = grandTarget + nTargets;
        end
    end

    fprintf('\nScanned %d visits.  Total wrong onset detections: %d / %d IntX Dir0-3 trials (%.1f%%)\n', ...
        numel(results), grandWrong, grandTarget, 100*grandWrong/max(grandTarget,1));
end


function idxList = GatherIntXIndices(SpecialMovementIndex)
% Concatenates the intermittent-exposure indices for practiced directions
% 0..3 into a single sorted, unique column vector of Data indices.

    idxList = [];
    if ~isfield(SpecialMovementIndex, 'IntermittentExposure'), return; end
    ie = SpecialMovementIndex.IntermittentExposure;

    dirFields = {'DirectionZero','DirectionOne','DirectionTwo','DirectionThree'};
    for f = 1:numel(dirFields)
        if isfield(ie, dirFields{f}) && ~isempty(ie.(dirFields{f}))
            idxList = [idxList; ie.(dirFields{f})(:)]; %#ok<AGROW>
        end
    end
    idxList = unique(idxList);
end


function PlotOnsetSummary(results)
% Subject x Visit heatmap of the number of wrong onset detections.
%   colour  = number of wrong detections (white = 0, deepening red = more)
%   gray    = no .mat file / visit not scanned
%   text    = "wrong/total" and the percentage for each scanned visit

    if isempty(results)
        disp('No results to display.');
        return
    end

    subjectList = unique({results.SubjectID}, 'stable');
    numSubjects = numel(subjectList);
    numVisits   = max([results.VisitNum]);

    countMat  = nan(numSubjects, numVisits);   % NaN -> missing (gray)
    targetMat = nan(numSubjects, numVisits);
    fracMat   = nan(numSubjects, numVisits);

    for r = 1:numel(results)
        s = find(strcmp(subjectList, results(r).SubjectID));
        countMat(s,  results(r).VisitNum) = results(r).NumWrong;
        targetMat(s, results(r).VisitNum) = results(r).NumTargets;
        fracMat(s,   results(r).VisitNum) = results(r).FracWrong;
    end

    fig = figure;
    fig.WindowState = 'maximized';
    ax  = axes(fig);

    hImg = imagesc(ax, countMat);
    set(hImg, 'AlphaData', ~isnan(countMat));   % missing cells show the gray axis
    ax.Color = [0.75 0.75 0.75];

    % White (0 wrong) -> deep red (many wrong)
    cN   = 256;
    cmap = [linspace(1, 0.6, cN)', linspace(1, 0.06, cN)', linspace(1, 0.06, cN)'];
    colormap(ax, cmap);
    maxCount = max(countMat(:));
    if isempty(maxCount) || ~isfinite(maxCount) || maxCount <= 0, maxCount = 1; end
    caxis(ax, [0 maxCount]);
    cb = colorbar(ax);
    cb.Label.String   = 'Number of wrong onset detections';
    cb.Label.FontSize = 14;

    ax.XTick      = 1:numVisits;
    ax.XTickLabel = arrayfun(@(v) sprintf('V%d', v), 1:numVisits, 'UniformOutput', false);
    ax.YTick      = 1:numSubjects;
    ax.YTickLabel = subjectList;
    ax.FontSize   = 16;
    ax.FontWeight = 'bold';

    xlabel(ax, 'Visit',   'FontSize', 18, 'FontWeight', 'bold');
    ylabel(ax, 'Subject', 'FontSize', 18, 'FontWeight', 'bold');
    title(ax, 'Wrong (premature) movement-onset detections — intermittent-exposure Dir 0-3 trials', ...
        'FontSize', 16, 'FontWeight', 'bold');

    % Annotate each scanned cell with wrong/total and the percentage.
    hold(ax, 'on');
    for s = 1:numSubjects
        for v = 1:numVisits
            if ~isnan(countMat(s, v))
                % Dark text on light cells, white text on dark-red cells.
                if countMat(s, v) > 0.6 * maxCount, txtColor = [1 1 1]; else, txtColor = [0 0 0]; end
                text(ax, v, s, ...
                    sprintf('%d/%d\n%.0f%%', countMat(s,v), targetMat(s,v), 100*fracMat(s,v)), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                    'FontSize', 11, 'FontWeight', 'bold', 'Color', txtColor);
            end
        end
    end
    hold(ax, 'off');
end
