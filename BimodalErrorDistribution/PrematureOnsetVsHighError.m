%% Premature Onset  vs.  High Extent Error
%
%  Tests whether the HIGH extent-error trials are the SAME trials that suffered
%  a premature movement-onset detection — i.e. whether the "high-error" cluster
%  is largely an onset-detection artifact rather than real behaviour.
%
%  This script lives in  BimodalErrorDistribution/  but the data (E-XX/ folders)
%  and every helper function live one level up in the project root. So it first
%  cd-s to the root and puts it on the path (derived from its OWN location, so it
%  works regardless of where the project is stored):
%       scriptDir = .../BimodalErrorDistribution
%       rootDir   = .../Post Processing        <- E-XX/ data + helper .m files
%
%  For every patient/visit it:
%    1. Loads that visit's Data into the global Data.
%    2. Runs CalculateMACCOnset() -> writes PrematureDetection + the MACC "true"
%       onset (TrueOnsetDetected) into each trial.
%    3. Per trial, records:
%         - premature?   (PrematureDetection == true)
%         - high error?  (max |ExtentError| DURING THE LAUNCH PHASE > threshold;
%                         launch phase = TherapyWindowIndex, onset -> 0.105 m)
%         - onset lag    (MACC onset time - robot onset time; >0 = fired early)
%
%  Outputs
%    - A 2x2 contingency table (premature x high-error), overall and per group,
%      printed to the command window with the key conditional percentages.
%    - A scatter of  max extent error  vs.  onset lag  (the "dose-response":
%      the earlier the false onset, the bigger the error).
%    - A `trialTable` in the base workspace with one row per trial for any
%      follow-up analysis.

% ── Directory setup: run from the project root (E-XX/ data + helpers) ────────
% Works whether this script sits at the root or in a subfolder (e.g.
% BimodalErrorDistribution/): the root is the folder with the main pipeline file.
scriptDir = fileparts(mfilename('fullpath'));
if isfile(fullfile(scriptDir, 'MainAnalysis_Nine_Phase.m'))
    rootDir = scriptDir;               % script is at the project root
else
    rootDir = fileparts(scriptDir);    % script is in a subfolder -> root is one level up
end
addpath(rootDir);   % so CalculateMACCOnset, maccOnset, ... resolve
cd(rootDir);        % so the E-XX/ data folders are found

% ── Options ─────────────────────────────────────────────────────────────────
HIGH_ERROR_THRESHOLD = 0.08;   % [m] a trial is "high error" if max |ExtentError| exceeds this
% ── Subjects to analyze ──────────────────────────────────────────────────────
%    'E-<n>' -> stroke patient: 9 visits, files <ID>/<ID>_Visit_<v>.mat
%    '<n>'   -> healthy subject: 1 visit,  file  <ID>/<ID>.mat
subjectIDs = {'E-5','E-16','E-21','E-25','E-26','E-28','E-38','E-42','E-44','E-47','E-56','E-69'};
% ────────────────────────────────────────────────────────────────────────────

trialTable = PrematureVsHighError(rootDir, subjectIDs, HIGH_ERROR_THRESHOLD);


%% =========================================================================

function trialTable = PrematureVsHighError(basePath, subjectIDs, thr)
% Scans every patient/visit, flags premature onset + high error per trial,
% then prints the 2x2 table and draws the error-vs-lag scatter.

    global Data %#ok<GVMIS>  (CalculateMACCOnset operates on the global Data)

    subj   = {};   % per-trial columns we accumulate
    grp    = {};
    vis    = [];
    maxErr = [];
    prem   = logical([]);
    lagMs  = [];

    nVisits = 0;  nNaN = 0;

    for s = 1:numel(subjectIDs)
        subjectID  = subjectIDs{s};
        subjectDir = fullfile(basePath, subjectID);
        isPatient  = startsWith(subjectID, 'E-');
        if isPatient, visitNums = 1:9; else, visitNums = 1; end

        for v = visitNums
            if isPatient
                fpath = fullfile(subjectDir, sprintf('%s_Visit_%d.mat', subjectID, v));
            else
                fpath = fullfile(subjectDir, sprintf('%s.mat', subjectID));
            end
            if ~isfile(fpath), continue; end

            try
                loaded = load(fpath, 'Data');
            catch
                continue
            end
            if ~isfield(loaded, 'Data'), continue; end

            Data = loaded.Data;            % populate the global Data
            try
                CalculateMACCOnset();      % writes PrematureDetection + TrueOnsetDetected
            catch ME
                fprintf('%-6s Visit %d  |  CalculateMACCOnset failed (%s) - skipped\n', ...
                    subjectID, v, ME.message);
                continue
            end
            nVisits = nVisits + 1;

            for c = 1:numel(Data)
                d = Data{c};
                if isempty(d), continue; end

                % Need a usable premature flag and the pieces for error + lag.
                if ~isfield(d, 'PrematureDetection') || ~islogical(d.PrematureDetection) ...
                        || ~isscalar(d.PrematureDetection)
                    nNaN = nNaN + 1;  continue          % NaN / unprocessable onset
                end
                if ~isfield(d, 'ExtentError') || isempty(d.ExtentError), continue; end

                % Max |ExtentError| during the LAUNCH PHASE only — the samples in
                % TherapyWindowIndex (robot onset -> 0.105 m path distance), which
                % is exactly where a premature onset inflates the error.
                if ~isfield(d, 'TherapyWindowIndex') || isempty(d.TherapyWindowIndex), continue; end
                lw = d.TherapyWindowIndex(:);
                lw = lw(lw >= 1 & lw <= numel(d.ExtentError));
                if isempty(lw), continue; end
                me = max(abs(d.ExtentError(lw)));
                if ~isfinite(me), continue; end

                lag = ComputeOnsetLagMs(d);             % NaN if not computable

                subj{end+1}   = subjectID;              %#ok<AGROW>
                if isPatient, grp{end+1} = 'Stroke'; else, grp{end+1} = 'Healthy'; end %#ok<AGROW>
                vis(end+1)    = v;                      %#ok<AGROW>
                maxErr(end+1) = me;                     %#ok<AGROW>
                prem(end+1)   = d.PrematureDetection;   %#ok<AGROW>
                lagMs(end+1)  = lag;                    %#ok<AGROW>
            end
        end
    end

    trialTable = table(subj(:), grp(:), vis(:), maxErr(:), prem(:), lagMs(:), ...
        'VariableNames', {'Subject','Group','Visit','MaxExtentError','Premature','OnsetLag_ms'});

    highErr = maxErr(:) > thr;
    prem    = prem(:);

    fprintf('\nScanned %d visits.  Usable trials: %d   (skipped %d with NaN/unprocessable onset)\n', ...
        nVisits, numel(prem), nNaN);
    fprintf('High-error threshold: max |ExtentError| in launch phase > %.3f m\n', thr);

    % ── 2x2 table: overall, then per group ──────────────────────────────────
    PrintContingency('ALL SUBJECTS', prem, highErr);
    groups = unique(grp);
    if numel(groups) > 1
        for gi = 1:numel(groups)
            sel = strcmp(grp(:), groups{gi});
            PrintContingency(upper(groups{gi}), prem(sel), highErr(sel));
        end
    end

    % ── Scatter: max extent error vs. onset lag (dose-response) ──────────────
    DrawScatter(lagMs(:), maxErr(:), prem, thr);
end


function lag = ComputeOnsetLagMs(d)
% Onset lag = MACC "true" onset time - robot onset time, in ms.
% >0 means the robot fired BEFORE the true onset (premature). NaN if not computable.
    lag = NaN;
    if ~isfield(d, 'TrueOnsetDetected')  || isempty(d.TrueOnsetDetected),  return; end
    if ~isfield(d, 'TherapyWindowIndex') || isempty(d.TherapyWindowIndex), return; end
    if ~isfield(d, 'MovementTime')       || isempty(d.MovementTime),       return; end
    t        = d.MovementTime;
    maccIdx  = d.TrueOnsetDetected(1);
    robotIdx = d.TherapyWindowIndex(1);
    if maccIdx < 1 || maccIdx > numel(t) || robotIdx < 1 || robotIdx > numel(t), return; end
    lag = (t(maccIdx) - t(robotIdx)) * 1000;   % s -> ms
end


function PrintContingency(label, prem, highErr)
% Prints the 2x2 premature x high-error table plus the key percentages.
    A = sum( prem &  highErr);   % premature & high error
    B = sum( prem & ~highErr);   % premature & normal error
    C = sum(~prem &  highErr);   % not premature & high error
    D = sum(~prem & ~highErr);   % not premature & normal error
    N = A + B + C + D;

    fprintf('\n==================  %s  (n = %d)  ==================\n', label, N);
    fprintf('                    | High error | Normal error |   Row total\n');
    fprintf('  Premature         |   %6d   |    %6d    |   %6d\n', A, B, A+B);
    fprintf('  Not premature     |   %6d   |    %6d    |   %6d\n', C, D, C+D);
    fprintf('  Column total      |   %6d   |    %6d    |   %6d\n', A+C, B+D, N);

    if (A+C) > 0
        fprintf('  -> %.0f%% of HIGH-ERROR trials were premature   (A / (A+C))\n', 100*A/(A+C));
    end
    if (A+B) > 0
        fprintf('  -> %.0f%% of PREMATURE trials were high-error   (A / (A+B))\n', 100*A/(A+B));
    end
    if B*C > 0
        fprintf('  -> odds ratio = %.1f  (>>1 means the two go together)\n', (A*D)/(B*C));
    end
end


function DrawScatter(lagMs, maxErr, prem, thr)
% Scatter of max extent error vs. onset lag, coloured by premature flag.
    fig = figure; fig.WindowState = 'maximized';
    ax = axes(fig); hold(ax, 'on');

    ok = isfinite(lagMs) & isfinite(maxErr);
    p  = ok &  prem;
    q  = ok & ~prem;

    scatter(ax, lagMs(q), maxErr(q), 18, [0.2 0.4 0.8], 'filled', ...
        'MarkerFaceAlpha', 0.35, 'DisplayName', 'Not premature');
    scatter(ax, lagMs(p), maxErr(p), 18, [0.85 0.2 0.2], 'filled', ...
        'MarkerFaceAlpha', 0.45, 'DisplayName', 'Premature');

    yline(ax, thr, 'k--', sprintf('high-error = %.3f m', thr), ...
        'LineWidth', 1.2, 'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    xline(ax, 0, 'k:', 'robot = true onset', ...
        'LineWidth', 1, 'HandleVisibility', 'off');

    grid(ax, 'off'); box(ax, 'off');
    set(ax, 'LineWidth', 1.5, 'FontSize', 12);
    xlabel(ax, 'Onset lag  (ms;  >0 = robot fired early / premature)', ...
        'FontSize', 14, 'FontWeight', 'bold');
    ylabel(ax, 'Max |Extent Error| in launch phase  (m)', 'FontSize', 14, 'FontWeight', 'bold');
    title(ax, 'Extent error vs. onset lag — does firing early inflate the error?', ...
        'FontSize', 15, 'FontWeight', 'bold');
    legend(ax, 'Location', 'northwest');

    % Correlation over the finite points (dose-response strength).
    if nnz(ok) > 2
        r = corr(lagMs(ok), maxErr(ok), 'rows', 'complete');
        text(ax, 0.98, 0.02, sprintf('r = %.2f  (n = %d)', r, nnz(ok)), ...
            'Units', 'normalized', 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom', 'FontSize', 12, 'FontWeight', 'bold');
    end
end
