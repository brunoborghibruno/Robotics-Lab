function results = DeltaErrorComparison(options)
% DELTAERRORCOMPARISON  Pre vs. post training error change, SHAM visits vs. EF visits, pooled over patients.
%
% HOW TO USE
%   r = DeltaErrorComparison();                                   % every SHAM and EF visit, all 14 patients
%   r = DeltaErrorComparison('Comparison', "first to last");      % first visit's pre vs. last visit's post
%   r = DeltaErrorComparison('Subjects', ["E-16", "E-21"], 'ErrorMetric', "MaximumPerpendicularError");
%
% THE TWO COMPARISONS ('Comparison' option)
%   "all visits"     (default) Each SHAM and EF visit on its own: that visit's pre-training trials against the
%                    same visit's post-training trials. One delta per visit (about 3 SHAM + 3 EF per patient).
%   "first to last"  One delta per patient and group: the pre-training trials of the FIRST visit of that type
%                    against the post-training trials of the LAST visit of that type (e.g. EF visit 2 -> 4).
%                    Shows the change over the whole treatment week instead of within one session.
%
% WHAT IS MEASURED
%   Pre   = mean of the last  NTrials good trials per direction with MovementNumber < PreTrainingEnd    (210)
%   Post  = mean of the first NTrials good trials per direction with MovementNumber > PostTrainingStart (547)
%   Delta = (Pre - Post) / Pre          (positive = smaller error after training)
%   Bar   = mean of the deltas of the group (SHAM left, EF right)
%   Dot   = one single post-training trial, (Pre - trial) / Pre, with the Pre of its own comparison
% Visits are typed from the data: no training-phase trials = Short (visits 1, 8, 9, skipped), any therapy force
% during training = EF, otherwise SHAM. Same analysis as Figures 2 and 3 of baselineAverageCalculation.m.
%
% FIGURES
%   1. Per direction: SHAM and EF bars for each direction, one dot per post-training trial, and one rose per group
%      (pre-training trials in gray, post-training trials in color).
%   2. Delta Across Treatment Week (all directions pooled): one SHAM bar (gray) and one EF bar (black) per subject,
%      side by side, with that subject's post-training trials as dots. The roses next to it (PooledRoses) show only
%      the subject chosen with SubjectIDRosePlot.
%   3. (PlotWorseRoses) Post-training trials that got worse (negative dot), all patients together, SHAM rose left
%      and EF rose right, against the pre-training trials they are compared with (gray).
%   Every rose plot shows, per direction, the mean launch trajectory with a semi-transparent tube of +-1 standard
%   deviation around it (RoseMean); with RoseMean = false it shows every single trajectory instead.
%
% OPTIONS (name-value)
%   Comparison        "all visits" or "first to last" (see above)   (default: "all visits")
%   Subjects          patient folders, e.g. ["E-5", "E-16"]         (default: the 14 patients with complete data)
%   Visits            visit numbers to try, missing files are skipped (default: 1:9)
%   ErrorMetric       any metric of GetErrorVector, launch window     (default: "MaximumErrorAmplitude")
%   Directions        practiced directions                           (default: 0:3)
%   NTrials           pre / post trials averaged per direction       (default: 5)
%   PreTrainingEnd    pre trials have MovementNumber below this      (default: 210, as Figure 2)
%   PostTrainingStart post trials have MovementNumber above this     (default: 547, as Figure 2; training ends at 547)
%   Blindness         true = "Patient N" instead of E-XX on figures and console (default: false)
%   ForceRescan       true = reload every .mat instead of using the cache of the previous call (default: false)
%   PlotWorseRoses    draw figure 3                                  (default: true)
%   RoseMean          rose plots show the mean trajectory per direction + a 1 SD tube, instead of every single
%                     trajectory                                     (default: true)
%   LabelWorseTrials  label every worse trajectory with patient, visit and movement number, only when
%                     RoseMean is false                              (default: false)
%   PooledRoses       rose insets next to the bars of figure 2       (default: true)
%   SubjectIDRosePlot subject whose SHAM and EF roses are drawn in figure 2, e.g. "E-16"
%                     (default: the first subject in Subjects)
%
% OUTPUT
%   results.Comparisons  one element per delta (a visit, or a first -> last pair): subject, VisitLabel ("V3" or
%                        "V2->V4"), type, Pre / Post / Delta per direction and pooled, single trial errors
%   results.Visits       every SHAM / EF visit that was read, with its own pre and post trials
%   results.Group.SHAM / results.Group.EF: bars, dots and the comparisons behind them
%   results.SubjectDeltas table, one row per subject: SHAM and EF delta (all directions) and how many
%                        comparisons each is the mean of (figure 2)
%   results.Options      the options used
%
% Uses GetErrorVector.m, DrawRoses.m and EquiDistantColorGenerator.m (root folder). Visit typing is the
% DetectVisitType logic of BaselineErrorAcrossEFVisits.m.

    arguments
        options.Comparison          (1,1) string    {mustBeMember(options.Comparison, ["all visits", "first to last"])} =   "all visits"
        options.Subjects            (1,:) string    =   ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-91", "E-93"]
        options.Visits              (1,:) double    =   1:9
        options.ErrorMetric         (1,1) string    =   "MaximumErrorAmplitude"
        options.Directions          (1,:) double    =   0:3
        options.NTrials             (1,1) double    =   5
        options.PreTrainingEnd      (1,1) double    =   210
        options.PostTrainingStart   (1,1) double    =   547
        options.Blindness           (1,1) logical   =   false
        options.ForceRescan         (1,1) logical   =   false
        options.PlotWorseRoses      (1,1) logical   =   true
        options.RoseMean            (1,1) logical   =   true
        options.LabelWorseTrials    (1,1) logical   =   false
        options.PooledRoses         (1,1) logical   =   true
        options.SubjectIDRosePlot   (1,1) string    =   ""
    end

    % Visits already analysed by a previous call, so changing a plot option does not reload every .mat
    persistent visitCache
    if isempty(visitCache) || options.ForceRescan
        visitCache  =   containers.Map('KeyType', 'char', 'ValueType', 'any');
    end

    rootFolder      =   fileparts(mfilename('fullpath'));
    startFolder     =   pwd;
    restoreFolder   =   onCleanup(@() cd(startFolder));     % back to the starting folder, also on error
    addpath(rootFolder);

    if options.SubjectIDRosePlot == ""
        options.SubjectIDRosePlot   =   options.Subjects(1);
    elseif ~ismember(options.SubjectIDRosePlot, options.Subjects)
        error('DeltaErrorComparison:roseSubject', 'SubjectIDRosePlot "%s" is not one of the Subjects (%s).', ...
            options.SubjectIDRosePlot, strjoin(options.Subjects, ', '));
    end

    groupNames      =   ["SHAM", "EF"];                     % left bar, right bar
    groupColors     =   [0.55 0.55 0.55; 0 0 0];            % bar outline / rose title: SHAM gray, EF black
    directionColors =   EquiDistantColorGenerator(4, 9742); % same direction colors as DrawRoses
    nDirections     =   numel(options.Directions);

    %% Load, type and analyse every visit
    visits  =   struct([]);
    for subjectCount = 1:numel(options.Subjects)
        subjectID       =   options.Subjects(subjectCount);
        subjectLabel    =   DisplayName(subjectID, subjectCount, options.Blindness);
        visitTypes      =   strings(1, 0);

        for visitNumber = options.Visits
            cacheKey    =   sprintf('v2|%s|%d|%s|%d|%s|%d|%d', subjectID, visitNumber, options.ErrorMetric, options.NTrials, mat2str(options.Directions), options.PreTrainingEnd, options.PostTrainingStart);
            if isKey(visitCache, cacheKey)
                visit   =   visitCache(cacheKey);
            else
                visit   =   AnalyseVisit(rootFolder, subjectID, visitNumber, options);
                visitCache(cacheKey)    =   visit;
            end
            if visit.Type == "Missing", continue; end
            if ismember(visit.Type, groupNames) && ~isempty(visits)
                % Same selected trials as an earlier visit of this patient = the same session saved twice
                % (e.g. E-5_Visit_2.mat and E-5_Visit_3.mat are identical files): keep only the first one
                isSame  =   arrayfun(@(v) v.SubjectID == subjectID && isequal(v.PreTrialError, visit.PreTrialError) && isequal(v.PostTrialError, visit.PostTrialError), visits);
                if any(isSame)
                    fprintf('  %s Visit %d skipped: same trials as Visit %d (duplicate file?)\n', subjectLabel, visitNumber, visits(find(isSame, 1)).VisitNumber);
                    visit.Type  =   "Duplicate";
                end
            end
            visitTypes(end + 1)     =   "V" + visitNumber + " " + visit.Type;     %#ok<AGROW>
            if ~ismember(visit.Type, groupNames), continue; end

            visit.SubjectLabel      =   subjectLabel;
            visit.SubjectNumber     =   subjectCount;
            if isempty(visits), visits = visit; else, visits(end + 1) = visit; end  %#ok<AGROW>
        end
        fprintf('%-10s %s\n', subjectLabel, strjoin(visitTypes, ' | '));
    end
    if isempty(visits)
        error('DeltaErrorComparison:noVisits', 'No SHAM or EF visit found for the selected subjects.');
    end

    %% Comparisons: one per visit ("all visits") or one per patient and group ("first to last")
    fprintf('\nComparison: %s\n', options.Comparison);
    if options.Comparison == "all visits"
        comparisons     =   EachVisitComparisons(visits);
        comparisonText  =   "each visit, own pre vs. post";
    else
        comparisons     =   FirstToLastComparisons(visits, groupNames);
        comparisonText  =   "first visit pre vs. last visit post";
    end
    if isempty(comparisons)
        error('DeltaErrorComparison:noComparisons', 'No visit has both good pre and good post trials.');
    end

    %% Groups: bar = mean of the deltas, dots = single post-training trials normalized by the Pre of their comparison
    for groupCount = 1:numel(groupNames)
        inGroup     =   find([comparisons.Type] == groupNames(groupCount));
        group.ComparisonIndex       =   inGroup;
        group.Comparisons           =   string({comparisons(inGroup).SubjectLabel}) + " " + [comparisons(inGroup).VisitLabel];
        group.Delta                 =   mean([comparisons(inGroup).Delta], 2, 'omitnan');
        group.DeltaAllDirections    =   mean([comparisons(inGroup).DeltaAllDirections], 'omitnan');
        group.PostTrialDelta        =   cell(nDirections, 1);
        for dirCount = 1:nDirections
            group.PostTrialDelta{dirCount}  =   cell2mat(arrayfun(@(c) c.PostTrialDelta{dirCount}, comparisons(inGroup), 'UniformOutput', false));
        end
        group.PostTrialDeltaAll     =   [comparisons(inGroup).PostTrialDeltaAll];
        group.PostTrialDirectionAll =   [comparisons(inGroup).PostTrialDirectionAll];
        Group.(groupNames(groupCount))  =   group;

        fprintf('\n%s: %d comparisons (%s)\n', groupNames(groupCount), numel(inGroup), strjoin(group.Comparisons, ', '));
        fprintf('  delta per direction = [%s], all directions = %.3f\n', num2str(group.Delta', '%.3f  '), group.DeltaAllDirections);
    end

    %% Per subject: mean of the subject's all-direction deltas in each group (bars of figure 2)
    subjectNumbers  =   unique([comparisons.SubjectNumber]);
    subjectLabels   =   strings(numel(subjectNumbers), 1);
    subjectDelta    =   nan(numel(subjectNumbers), numel(groupNames));
    subjectCount    =   zeros(numel(subjectNumbers), numel(groupNames));
    for rowCount = 1:numel(subjectNumbers)
        ofSubject   =   comparisons([comparisons.SubjectNumber] == subjectNumbers(rowCount));
        subjectLabels(rowCount) =   ofSubject(1).SubjectLabel;
        for groupCount = 1:numel(groupNames)
            inGroup     =   [ofSubject.Type] == groupNames(groupCount);
            subjectCount(rowCount, groupCount)  =   sum(inGroup);
            if any(inGroup)
                subjectDelta(rowCount, groupCount)  =   mean([ofSubject(inGroup).DeltaAllDirections], 'omitnan');
            end
        end
    end
    subjectDeltas   =   table(subjectLabels, subjectDelta(:, 1), subjectDelta(:, 2), subjectCount(:, 1), subjectCount(:, 2), ...
                              'VariableNames', {'Subject', 'SHAM', 'EF', 'nSHAM', 'nEF'});
    fprintf('\nDelta per subject (all directions, mean of the subject''s %s):\n', ternaryText(options.Comparison == "all visits", "visits", "first -> last comparison"));
    disp(subjectDeltas);

    results.Comparisons =   comparisons;
    results.SubjectDeltas   =   subjectDeltas;
    results.Visits      =   visits;
    results.Group       =   Group;
    results.Options     =   options;

    %% Figures
    [roseData, preRoseIndex, postRoseIndex] =   GroupRoseData(comparisons, groupNames);
    nPatients       =   numel(unique([comparisons.SubjectNumber]));
    titleSubjects   =   nPatients + " patient" + repmat('s', 1, nPatients > 1);
    options.ComparisonText  =   comparisonText;             % second title line of every figure
    results.Figures.Direction   =   PlotDirectionBars(Group, groupNames, groupColors, directionColors, options, titleSubjects, roseData, preRoseIndex, postRoseIndex);
    roseComparisons =   comparisons([comparisons.SubjectID] == options.SubjectIDRosePlot);     % figure 2 roses: one subject only
    results.Figures.Pooled      =   PlotSubjectBars(comparisons, subjectNumbers, subjectLabels, subjectDelta, roseComparisons, groupNames, groupColors, directionColors, options);
    if options.PlotWorseRoses
        [results.WorseTrials, results.Figures.WorseRoses]   =   PlotWorseRoses(comparisons, groupNames, groupColors, directionColors, options, comparisonText);
    end
end



%% ─── Analysis ────────────────────────────────────────────────────────────────

function visit = AnalyseVisit(rootFolder, subjectID, visitNumber, options)
    % Loads one visit, types it EF / SHAM / Short and, for EF and SHAM, selects the pre / post trials.
    % A visit with good pre trials but no good post trials (or the reverse) is kept: "first to last" can still use
    % the half that exists. Only the Data structs of the selected trials are kept (for the rose plots).

    visit   =   struct('SubjectID', subjectID, 'VisitNumber', visitNumber, 'VisitLabel', "V" + visitNumber, 'Type', "Missing", ...
                       'HasPre', false, 'HasPost', false, ...
                       'Pre', [], 'Post', [], 'Delta', [], 'PostTrialDelta', {{}}, 'PreTrialError', {{}}, 'PostTrialError', {{}}, ...
                       'PreMovementNumber', {{}}, 'PostMovementNumber', {{}}, 'PreTrialData', {{}}, 'PostTrialData', {{}}, ...
                       'PreAllDirections', NaN, 'PostAllDirections', NaN, 'DeltaAllDirections', NaN, ...
                       'PostTrialDeltaAll', [], 'PostTrialDirectionAll', [], 'TrainingMovements', [NaN NaN]);

    visitFile   =   fullfile(rootFolder, subjectID, subjectID + "_Visit_" + visitNumber + ".mat");
    if ~isfile(visitFile)
        visitFile   =   replace(visitFile, ".mat", "_EF.mat");     % P-1 files are saved as P-1_Visit_X_EF.mat
    end
    if ~isfile(visitFile), return; end

    fprintf('Loading %s ...\n', visitFile);
    visitData   =   load(visitFile, 'Data', 'InputFile');
    [visit.Type, visit.TrainingMovements]   =   DetectVisitType(visitData.Data);
    if ~ismember(visit.Type, ["EF", "SHAM"]), return; end

    % Same pre / post windows as Figure 2 of baselineAverageCalculation.m (in the data, training is movements 212-547)
    [~, ~, ~, ~, visit.PreTrialError, visit.PostTrialError, preDataIndex, postDataIndex] ...
        =   ComputeNormalizedDelta(visitData, options.ErrorMetric, options.Directions, options.PreTrainingEnd, options.PostTrainingStart, options.NTrials);

    visit.PreTrialData          =   cellfun(@(index) reshape(visitData.Data(index), 1, []), preDataIndex,  'UniformOutput', false);    % rows, so they can be appended
    visit.PostTrialData         =   cellfun(@(index) reshape(visitData.Data(index), 1, []), postDataIndex, 'UniformOutput', false);
    visit.PreMovementNumber     =   cellfun(@(trials) cellfun(@(trial) trial.MovementNumber, trials), visit.PreTrialData,  'UniformOutput', false);
    visit.PostMovementNumber    =   cellfun(@(trials) cellfun(@(trial) trial.MovementNumber, trials), visit.PostTrialData, 'UniformOutput', false);
    visit.HasPre                =   ~isempty([visit.PreTrialError{:}]);
    visit.HasPost               =   ~isempty([visit.PostTrialError{:}]);
    if ~visit.HasPre && ~visit.HasPost
        fprintf('  %s Visit %d (%s): skipped, no good pre or post trials\n', subjectID, visitNumber, visit.Type);
        visit.Type  =   "NoGoodTrials";
        return
    end
    visit   =   ComputeDeltas(visit);
end


function comparison = ComputeDeltas(comparison)
    % Pre / Post means, Delta = (Pre - Post) / Pre per direction and with all directions pooled, and the delta of
    % every single post trial, from the PreTrialError / PostTrialError of the comparison (NaN where a half is missing)
    comparison.Pre      =   cellfun(@MeanOrNaN, comparison.PreTrialError);
    comparison.Post     =   cellfun(@MeanOrNaN, comparison.PostTrialError);
    comparison.Delta    =   (comparison.Pre - comparison.Post) ./ comparison.Pre;
    comparison.PostTrialDelta   =   arrayfun(@(dirCount) (comparison.Pre(dirCount) - comparison.PostTrialError{dirCount}) ./ comparison.Pre(dirCount), ...
                                             (1:numel(comparison.Pre))', 'UniformOutput', false);

    preAll      =   [comparison.PreTrialError{:}];
    postAll     =   [comparison.PostTrialError{:}];
    comparison.PreAllDirections         =   MeanOrNaN(preAll);
    comparison.PostAllDirections        =   MeanOrNaN(postAll);
    comparison.DeltaAllDirections       =   (comparison.PreAllDirections - comparison.PostAllDirections) / comparison.PreAllDirections;
    comparison.PostTrialDeltaAll        =   (comparison.PreAllDirections - postAll) ./ comparison.PreAllDirections;
    comparison.PostTrialDirectionAll    =   repelem(1:numel(comparison.Pre), cellfun(@numel, comparison.PostTrialError)');
end


function value = MeanOrNaN(values)
    % mean, NaN for an empty set
    if isempty(values), value = NaN; else, value = mean(values); end
end


function comparisons = EachVisitComparisons(visits)
    % "all visits": every visit with both good pre and good post trials is one comparison
    hasBoth     =   [visits.HasPre] & [visits.HasPost];
    for visitCount = find(~hasBoth)
        fprintf('  %s %s (%s): skipped, no good %s trials\n', visits(visitCount).SubjectLabel, visits(visitCount).VisitLabel, ...
            visits(visitCount).Type, string(repmat('pre', 1, ~visits(visitCount).HasPre)) + string(repmat('post', 1, ~visits(visitCount).HasPost)));
    end
    comparisons =   visits(hasBoth);
    for visitCount = 1:numel(comparisons)
        PrintComparison(comparisons(visitCount));
    end
end


function comparisons = FirstToLastComparisons(visits, groupNames)
    % "first to last": for every patient and group, the pre trials of the first visit of that type (that has good
    % pre trials) against the post trials of the last visit of that type (that has good post trials)
    comparisons     =   struct([]);
    for subjectNumber = unique([visits.SubjectNumber])
        for groupName = groupNames
            ofType      =   visits([visits.SubjectNumber] == subjectNumber & [visits.Type] == groupName);
            [~, order]  =   sort([ofType.VisitNumber]);
            ofType      =   ofType(order);
            firstIndex  =   find([ofType.HasPre], 1, 'first');
            lastIndex   =   find([ofType.HasPost], 1, 'last');
            if isempty(firstIndex) || isempty(lastIndex) || ofType(firstIndex).VisitNumber >= ofType(lastIndex).VisitNumber
                if ~isempty(ofType)
                    fprintf('  %s %s: skipped, no earlier visit with pre trials and later visit with post trials\n', ofType(1).SubjectLabel, groupName);
                end
                continue
            end

            % Pre half from the first visit, post half from the last visit
            comparison                      =   ofType(firstIndex);
            last                            =   ofType(lastIndex);
            comparison.PostTrialError       =   last.PostTrialError;
            comparison.PostTrialData        =   last.PostTrialData;
            comparison.PostMovementNumber   =   last.PostMovementNumber;
            comparison.HasPost              =   true;
            comparison.VisitLabel           =   "V" + ofType(firstIndex).VisitNumber + "->V" + last.VisitNumber;
            comparison                      =   ComputeDeltas(comparison);
            PrintComparison(comparison);
            if isempty(comparisons), comparisons = comparison; else, comparisons(end + 1) = comparison; end  %#ok<AGROW>
        end
    end
end


function PrintComparison(comparison)
    fprintf('  %s %s (%s): pre = %.4f (%d trials), post = %.4f (%d trials), delta = %.3f\n', comparison.SubjectLabel, comparison.VisitLabel, comparison.Type, ...
        comparison.PreAllDirections, numel([comparison.PreTrialError{:}]), comparison.PostAllDirections, numel([comparison.PostTrialError{:}]), comparison.DeltaAllDirections);
end


function [visitType, trainingMovements] = DetectVisitType(Data)
    % Same rule as DetectVisitType in BaselineErrorAcrossEFVisits.m: "EF" if any training-phase trial applied a
    % non-zero therapy force, "SHAM" if training trials exist but none did, "Short" when there is no training
    % phase (visits 1, 8, 9). Also returns the first and last MovementNumber of the training phase.

    visitType           =   "Short";
    trainingMovements   =   [NaN NaN];
    isEF                =   false;
    for index = 1:numel(Data)
        trial   =   Data{index};
        if isempty(trial) || ~isfield(trial, 'ExperimentPhase') || ~strcmp(trial.ExperimentPhase, 'TrainingPhase'), continue; end
        trainingMovements   =   [min(trainingMovements(1), trial.MovementNumber), max(trainingMovements(2), trial.MovementNumber)];
        if isfield(trial, 'TherapyForceAmplitude') && any(trial.TherapyForceAmplitude(:) ~= 0)
            isEF    =   true;
        end
    end
    if isnan(trainingMovements(1)), return; end
    if isEF, visitType = "EF"; else, visitType = "SHAM"; end
end


function [preMean, postMean, delta, postTrialDelta, preTrialError, postTrialError, preDataIndex, postDataIndex] = ComputeNormalizedDelta(visitData, errorMetric, directions, preEnd, postStart, nTrials)
    % Copy of computeNormalizedDelta in baselineAverageCalculation.m.
    % For each direction: mean of the last nTrials good trials before preEnd, mean of the first nTrials good trials
    % after postStart, and delta = (pre - post) / pre. postTrialDelta{dir} = (pre - each single post trial) / pre.
    % Trials are picked by their MovementNumber field (Data index != MovementNumber).

    % GetErrorVector reads the Data and InputFile globals
    global Data InputFile
    Data        =   visitData.Data;
    InputFile   =   visitData.InputFile;

    nData               =   numel(Data);
    movementNumber      =   nan(nData, 1);
    movementDirection   =   nan(nData, 1);
    isGoodTrial         =   false(nData, 1);
    for index = 1:nData
        if isempty(Data{index}) || ~isfield(Data{index}, 'MovementNumber')
            continue
        end
        movementNumber(index)       =   Data{index}.MovementNumber;
        movementDirection(index)    =   Data{index}.MovementDirection;
        % Older visit files (e.g. E-5, 2024) have no UnIdealStart field: a missing flag counts as not flagged
        isBad                       =   isfield(Data{index}, 'BadTrialFlag') && strcmp(Data{index}.BadTrialFlag, 'y');
        isUnIdealStart              =   isfield(Data{index}, 'UnIdealStart') && isequal(Data{index}.UnIdealStart, true);
        isGoodTrial(index)          =   ~isBad && ~isUnIdealStart && ~isempty(Data{index}.PathDistance);
    end

    candidateIndex                  =   find(isGoodTrial);
    errorValue                      =   nan(nData, 1);
    if ~isempty(candidateIndex)                                             % e.g. E-56 Visit 3: every trial flagged bad
        errorValue(candidateIndex)  =   GetErrorVector(candidateIndex, char(errorMetric), 'launch');
    end
    isGoodTrial                     =   isGoodTrial & ~isnan(errorValue);      % NaN = rest / phase-beginning trial

    preMean         =   nan(numel(directions), 1);
    postMean        =   nan(numel(directions), 1);
    postTrialDelta  =   cell(numel(directions), 1);
    preTrialError   =   cell(numel(directions), 1);
    postTrialError  =   cell(numel(directions), 1);
    preDataIndex    =   cell(numel(directions), 1);
    postDataIndex   =   cell(numel(directions), 1);

    for dirCount = 1:numel(directions)
        inDirection     =   isGoodTrial & movementDirection == directions(dirCount);

        preIndex        =   find(inDirection & movementNumber < preEnd);
        [~, order]      =   sort(movementNumber(preIndex));
        preIndex        =   preIndex(order(max(1, end-nTrials+1):end));      % last nTrials before training

        postIndex       =   find(inDirection & movementNumber > postStart);
        [~, order]      =   sort(movementNumber(postIndex));
        postIndex       =   postIndex(order(1:min(nTrials, end)));           % first nTrials after training

        preMean(dirCount)           =   mean(errorValue(preIndex));
        postMean(dirCount)          =   mean(errorValue(postIndex));
        postTrialDelta{dirCount}    =   (preMean(dirCount) - errorValue(postIndex)') ./ preMean(dirCount);
        preTrialError{dirCount}     =   errorValue(preIndex)';
        postTrialError{dirCount}    =   errorValue(postIndex)';
        preDataIndex{dirCount}      =   preIndex';
        postDataIndex{dirCount}     =   postIndex';
    end

    delta   =   (preMean - postMean) ./ preMean;
end


function label = DisplayName(subjectID, subjectNumber, blindness)
    % "Patient N" (position in Subjects) when blinded, the real ID otherwise
    if blindness
        label   =   "Patient " + subjectNumber;
    else
        label   =   string(subjectID);
    end
end



%% ─── Figures ─────────────────────────────────────────────────────────────────

function [roseData, preRoseIndex, postRoseIndex] = GroupRoseData(visits, groupNames)
    % The kept pre / post trials of all the visits of each group, appended into one Data cell per group,
    % with the indexes of the pre and of the post trials in it (input of DrawRoses)
    roseData        =   cell(1, numel(groupNames));
    preRoseIndex    =   cell(1, numel(groupNames));
    postRoseIndex   =   cell(1, numel(groupNames));
    for groupCount = 1:numel(groupNames)
        roseData{groupCount}    =   {};
        for visitCount = find([visits.Type] == groupNames(groupCount))
            preTrials   =   [visits(visitCount).PreTrialData{:}];
            postTrials  =   [visits(visitCount).PostTrialData{:}];
            nStored     =   numel(roseData{groupCount});
            preRoseIndex{groupCount}    =   [preRoseIndex{groupCount},  nStored + (1:numel(preTrials))];
            postRoseIndex{groupCount}   =   [postRoseIndex{groupCount}, nStored + numel(preTrials) + (1:numel(postTrials))];
            roseData{groupCount}        =   [roseData{groupCount}, preTrials, postTrials];
        end
    end
end


function figureHandle = PlotDirectionBars(Group, groupNames, groupColors, directionColors, options, titleSubjects, roseData, preRoseIndex, postRoseIndex)
    % SHAM and EF bars for each direction: fill = direction, outline = group, one dot per post-training trial
    directions  =   options.Directions;
    nGroups     =   numel(groupNames);
    deltaMatrix =   nan(numel(directions), nGroups);
    for groupCount = 1:nGroups
        deltaMatrix(:, groupCount)  =   Group.(groupNames(groupCount)).Delta;
    end

    figureHandle    =   figure('Name', 'Delta Error - per direction', 'Color', 'w', 'WindowState', 'maximized');
    deltaBars   =   bar(directions, deltaMatrix, 'grouped', 'LineWidth', 4, 'FaceAlpha', 0.8);
    for groupCount = 1:nGroups
        deltaBars(groupCount).FaceColor     =   'flat';
        deltaBars(groupCount).CData         =   directionColors(1:numel(directions), :);
        deltaBars(groupCount).EdgeColor     =   groupColors(groupCount, :);
    end
    yline(0, 'k', 'LineWidth', 2);

    hold on;
    dotHandles  =   gobjects(0);
    for groupCount = 1:nGroups
        for dirCount = 1:numel(directions)
            dotValues   =   Group.(groupNames(groupCount)).PostTrialDelta{dirCount};
            dotSpread   =   linspace(-0.12, 0.12, numel(dotValues)) * (numel(dotValues) > 1);   % horizontal spread so dots don't stack
            dotHandles(end + 1)     =   scatter(deltaBars(groupCount).XEndPoints(dirCount) + dotSpread, dotValues, 30, ...
                'MarkerFaceColor', directionColors(dirCount, :), 'MarkerEdgeColor', groupColors(groupCount, :), 'LineWidth', 0.5, ...
                'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
        end
    end
    hold off;
    uistack(dotHandles, 'bottom');  % dots behind the bars (moving the bars instead would swap their positions in the group)

    ax              =   gca;
    set(ax, 'XTick', directions, 'XTickLabel', "Dir " + string(directions), 'LineWidth', 3, 'FontSize', 25, 'FontWeight', 'bold', 'Box', 'off');
    xlabel("Movement Direction", 'FontSize', 30, 'FontWeight', 'bold');
    ylabel("(Pre - Post) / Pre", 'FontSize', 30, 'FontWeight', 'bold');
    title([titleSubjects + " - Normalized " + options.ErrorMetric + " change after training", "(" + options.ComparisonText + ")"], 'FontSize', 25, 'FontWeight', 'bold');
    subtitle(RoseLegendText(options), 'FontSize', 18);

    % Group labels stacked to the right of the last bar group, one rose per group under them (xlim widened to make room)
    xlim([directions(1) - 0.5, directions(end) + 2.2]);
    yLimits     =   ylim;
    for groupCount = 1:nGroups
        text(directions(end) + 0.5, yLimits(2) - (groupCount - 1) * 0.1 * diff(yLimits), groupNames(groupCount) + " visits", ...
            'Color', groupColors(groupCount, :), 'FontSize', 32, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
    end
    roseCenters =   [(directions(end) + 1.35) * [1; 1], yLimits(2) - [0.40; 0.76] * diff(yLimits)];
    AddGroupRoseInsets(figureHandle, ax, roseCenters, 0.2, roseData, preRoseIndex, postRoseIndex, groupColors, groupNames, options, directionColors);
end


function figureHandle = PlotSubjectBars(comparisons, subjectNumbers, subjectLabels, subjectDelta, roseComparisons, groupNames, groupColors, directionColors, options)
    % Delta Across Treatment Week: for every subject a SHAM bar (gray, left) and an EF bar (black, right) of the
    % all-direction delta, with that subject's post-training trials as dots colored by direction. The roses next
    % to the bars show only the comparisons of options.SubjectIDRosePlot.
    nSubjects   =   numel(subjectNumbers);
    nGroups     =   numel(groupNames);
    barOffset   =   [-0.2, 0.2];            % SHAM left, EF right of the subject's tick
    barWidth    =   0.35;

    figureHandle    =   figure('Name', 'Delta Across Treatment Week', 'Color', 'w', 'WindowState', 'maximized');
    hold on;
    barHandles  =   gobjects(0);
    dotHandles  =   gobjects(0);
    for rowCount = 1:nSubjects
        ofSubject   =   comparisons([comparisons.SubjectNumber] == subjectNumbers(rowCount));
        for groupCount = 1:nGroups
            if isnan(subjectDelta(rowCount, groupCount)), continue; end     % no comparison of this type for this subject
            xCenter     =   rowCount + barOffset(groupCount);
            barHandles(end + 1)     =   bar(xCenter, subjectDelta(rowCount, groupCount), barWidth, 'FaceColor', 'none', ...
                                            'EdgeColor', groupColors(groupCount, :), 'LineWidth', 3);  %#ok<AGROW>
            inGroup     =   ofSubject([ofSubject.Type] == groupNames(groupCount));
            dotValues   =   [inGroup.PostTrialDeltaAll];
            dotColors   =   directionColors([inGroup.PostTrialDirectionAll], :);
            if isempty(dotValues), continue; end
            dotSpread   =   linspace(-0.4, 0.4, numel(dotValues)) * barWidth * (numel(dotValues) > 1);
            dotHandles(end + 1)     =   scatter(xCenter + dotSpread, dotValues, 20, dotColors, 'filled', ...
                                            'MarkerEdgeColor', groupColors(groupCount, :), 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);  %#ok<AGROW>
        end
    end
    yline(0, 'k', 'LineWidth', 2);
    hold off;
    if ~isempty(dotHandles), uistack(dotHandles, 'bottom'); end     % dots behind the bars

    ax              =   gca;
    set(ax, 'XTick', 1:nSubjects, 'XTickLabel', subjectLabels, 'LineWidth', 3, 'FontSize', 20, 'FontWeight', 'bold', 'Box', 'off');
    ylabel("(Pre - Post) / Pre", 'FontSize', 30, 'FontWeight', 'bold');
    title(["Delta Across Treatment Week", options.ErrorMetric + ", all directions (" + options.ComparisonText + ")"], 'FontSize', 25, 'FontWeight', 'bold');

    % With PooledRoses: the SHAM and EF roses of one subject side by side above the bars (ylim raised to make
    % room); their gray / black titles are also the legend of the bar outlines. Without roses: SHAM / EF labels.
    xlim([0.4, nSubjects + 0.6]);
    yLimits     =   ylim;
    if options.PooledRoses && ~isempty(roseComparisons)
        subtitle(RoseLegendText(options) + "   (roses: " + roseComparisons(1).SubjectLabel + ")", 'FontSize', 18);
        ylim([yLimits(1), yLimits(2) + 0.75 * diff(yLimits)]);
        [roseData, preRoseIndex, postRoseIndex] =   GroupRoseData(roseComparisons, groupNames);
        roseCenters =   [0.4 + (nSubjects + 0.2) * [0.3; 0.7], (yLimits(2) + 0.32 * diff(yLimits)) * [1; 1]];
        AddGroupRoseInsets(figureHandle, ax, roseCenters, 0.22, roseData, preRoseIndex, postRoseIndex, groupColors, groupNames, options, directionColors, ...
            " - " + roseComparisons(1).SubjectLabel);
    else
        for groupCount = 1:nGroups
            text(nSubjects + 0.5, yLimits(2) - (groupCount - 1) * 0.08 * diff(yLimits), groupNames(groupCount) + " visits", ...
                'Color', groupColors(groupCount, :), 'FontSize', 26, 'FontWeight', 'bold', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
        end
    end
end


function value = ternaryText(condition, ifTrue, ifFalse)
    if condition, value = ifTrue; else, value = ifFalse; end
end


function [worseTable, figureHandle] = PlotWorseRoses(visits, groupNames, groupColors, directionColors, options, comparisonText)
    % One rose per group with every post-training trial that got worse (negative dot), all patients and visits
    % together, drawn on top of the pre-training trials of the same visit and direction (gray).
    % Returns and prints the table of the worse trials.

    roseZoom            =   1.3;        % bigger = rose fills more of its tile (pooled roses spread wider than single-visit ones)
    preLineWidth        =   2;          % gray pre-training trajectories
    postLineWidth       =   3;          % colored worse post-training trajectories
    meanLineWidth       =   5;          % mean trajectories (RoseMean)

    tableRows   =   {};
    figureHandle    =   figure('Name', 'Delta Error - worse post-training trials', 'Color', 'w', 'WindowState', 'maximized');
    worseLayout     =   tiledlayout(figureHandle, 1, numel(groupNames), 'TileSpacing', 'compact', 'Padding', 'compact');
    roseAxes    =   gobjects(1, numel(groupNames));
    roseTitles  =   strings(numel(groupNames), 2);

    for groupCount = 1:numel(groupNames)
        worseTrials     =   {};
        worseLabels     =   strings(1, 0);
        grayTrials      =   {};
        nPostTrials     =   0;
        for visitCount = find([visits.Type] == groupNames(groupCount))
            visit   =   visits(visitCount);
            for dirCount = 1:numel(options.Directions)
                nPostTrials     =   nPostTrials + numel(visit.PostTrialDelta{dirCount});
                isWorse         =   visit.PostTrialDelta{dirCount} < 0;
                if ~any(isWorse), continue; end
                worseTrials     =   [worseTrials, visit.PostTrialData{dirCount}(isWorse)];         %#ok<AGROW>
                grayTrials      =   [grayTrials,  visit.PreTrialData{dirCount}];                    %#ok<AGROW>
                for trialCount = find(isWorse)
                    movementNumber  =   visit.PostMovementNumber{dirCount}(trialCount);
                    worseLabels(end + 1)    =   visit.SubjectLabel + " " + visit.VisitLabel + " " + movementNumber;  %#ok<AGROW>
                    tableRows(end + 1, :)   =   {visit.SubjectLabel, visit.VisitLabel, visit.Type, options.Directions(dirCount), movementNumber, ...
                                                 visit.Pre(dirCount), visit.PostTrialError{dirCount}(trialCount), visit.PostTrialDelta{dirCount}(trialCount)};  %#ok<AGROW>
                end
            end
        end

        roseAxes(groupCount)    =   nexttile(worseLayout);
        if options.RoseMean
            DrawMeanRose(roseAxes(groupCount), grayTrials, options.Directions, repmat([0.45 0.45 0.45], size(directionColors, 1), 1), meanLineWidth, false, true);
            DrawMeanRose(roseAxes(groupCount), worseTrials, options.Directions, directionColors, meanLineWidth, true, false);
        else
            if ~isempty(grayTrials)
                DrawRoses(roseAxes(groupCount), grayTrials, 1:numel(grayTrials), [], 1);                 % empty 4th input = gray, no force arrows
            end
            preLines    =   findobj(roseAxes(groupCount), 'Type', 'line', 'Marker', '.');                % trajectories are '.' lines, target lines have no marker
            if ~isempty(worseTrials)
                DrawRoses(roseAxes(groupCount), worseTrials, 1:numel(worseTrials), 1, 1);              % colored by direction, no force arrows
            end
            postLines   =   setdiff(findobj(roseAxes(groupCount), 'Type', 'line', 'Marker', '.'), preLines);
            set(preLines,  'LineWidth', preLineWidth);
            set(postLines, 'LineWidth', postLineWidth);
        end

        if options.LabelWorseTrials && ~options.RoseMean
            for trialCount = 1:numel(worseTrials)
                trial           =   worseTrials{trialCount};
                launchPosition  =   trial.GlobalPosition(trial.TherapyWindowIndex(end), :) - trial.GlobalPosition(1, :);   % same frame as DrawRoses
                text(roseAxes(groupCount), launchPosition(1), launchPosition(3), launchPosition(2), " " + worseLabels(trialCount), ...
                    'Color', directionColors(trial.MovementDirection + 1, :), 'FontSize', 9, 'FontWeight', 'bold');
            end
        end
        roseTitles(groupCount, :)   =   [groupNames(groupCount) + " visits", "Worse post-training trials: " + numel(worseTrials) + " of " + nPostTrials];
    end

    % Same view and scale for both roses, each centered on its own trajectories and zoomed in
    for roseCount = 1:numel(roseAxes)
        axis(roseAxes(roseCount), "equal");
        axis(roseAxes(roseCount), "off");
        view(roseAxes(roseCount), 26, 26);
    end
    allLimits   =   [vertcat(roseAxes.XLim), vertcat(roseAxes.YLim), vertcat(roseAxes.ZLim)];
    set(roseAxes, 'XLim', [min(allLimits(:, 1)), max(allLimits(:, 2))], 'YLim', [min(allLimits(:, 3)), max(allLimits(:, 4))], 'ZLim', [min(allLimits(:, 5)), max(allLimits(:, 6))]);
    roseViewAngle   =   nan(1, numel(roseAxes));
    for roseCount = 1:numel(roseAxes)
        roseLines       =   findobj(roseAxes(roseCount), 'Type', 'line');
        if isempty(roseLines), continue; end
        roseX           =   [roseLines.XData];
        roseY           =   [roseLines.YData];
        roseZ           =   [roseLines.ZData];
        roseCenter      =   [min(roseX) + max(roseX), min(roseY) + max(roseY), min(roseZ) + max(roseZ)] / 2;
        cameraOffset    =   roseAxes(roseCount).CameraPosition - roseAxes(roseCount).CameraTarget;
        roseAxes(roseCount).CameraTarget    =   roseCenter;
        roseAxes(roseCount).CameraPosition  =   roseCenter + cameraOffset;
        roseViewAngle(roseCount)            =   roseAxes(roseCount).CameraViewAngle;
    end
    set(roseAxes, 'CameraViewAngle', max(roseViewAngle) / roseZoom);

    % Figure title first: it shrinks the tiles, and the tile titles below are placed from the final tile positions
    title(worseLayout, ["Post-training trials worse than the pre-training mean (" + options.ErrorMetric + ", launch window)", "(" + comparisonText + ")"], 'FontSize', 18, 'FontWeight', 'bold');
    if options.RoseMean
        subtitle(worseLayout, "Mean trajectory per direction, shaded = " + char(177) + "1 SD:   Gray = pre-training trials     Colored = post-training trials that got worse (n = trials averaged)", 'FontSize', 16);
    else
        subtitle(worseLayout, "Gray = pre-training trials     Colored = post-training trials that got worse", 'FontSize', 16);
    end

    % Titles as text boxes pinned to the top of each tile: a normal axes title moves with the zoom
    drawnow;
    for roseCount = 1:numel(roseAxes)
        tilePosition    =   roseAxes(roseCount).Position;
        annotation(figureHandle, 'textbox', [tilePosition(1), tilePosition(2) + tilePosition(4) - 0.06, tilePosition(3), 0.06], 'String', roseTitles(roseCount, :), ...
            'Color', groupColors(roseCount, :), 'FontSize', 18, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end

    if isempty(tableRows)
        tableRows   =   cell(0, 8);
    end
    worseTable  =   cell2table(tableRows, 'VariableNames', {'Subject', 'Visit', 'Type', 'Direction', 'Movement', 'PreMean', 'TrialError', 'Delta'});
    fprintf('\nPost-training trials worse than the pre-training mean of their direction (%s): %d\n', options.ErrorMetric, height(worseTable));
    disp(worseTable);
end


function DrawMeanRose(axisHandle, trials, directions, colors, lineWidth, showCount, drawTargets)
    % One mean launch trajectory per direction with a semi-transparent tube of +-1 SD around it.
    % colors(direction + 1, :) = color of that direction. Same frame as DrawRoses (start-relative global position,
    % plotted as x, z, y). showCount = write "n = trials" at the end of each mean; drawTargets = black target lines.
    hold(axisHandle, "on");
    if isempty(trials), hold(axisHandle, "off"); return; end
    trialDirections =   cellfun(@(trial) trial.MovementDirection, trials);
    for dirCount = 1:numel(directions)
        ofDirection     =   trials(trialDirections == directions(dirCount));
        if isempty(ofDirection), continue; end
        color           =   colors(directions(dirCount) + 1, :);

        if drawTargets      % mean start -> target vector of the trials of this direction
            targetVector    =   mean(cell2mat(cellfun(@(trial) (trial.TargetPosition(:) - trial.StartPosition(:))', ofDirection', 'UniformOutput', false)), 1);
            plot3(axisHandle, [0 targetVector(1)], [0 targetVector(3)], [0 targetVector(2)], 'k-', 'LineWidth', 1);
        end

        [meanPath, tube]    =   MeanTrajectoryAndSpread(ofDirection);
        if isempty(meanPath), continue; end
        if ~isempty(tube)
            surf(axisHandle, tube.X, tube.Z, tube.Y, 'FaceColor', color, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
        end
        plot3(axisHandle, meanPath(:, 1), meanPath(:, 3), meanPath(:, 2), '-', 'Color', color, 'LineWidth', lineWidth);
        if showCount
            text(axisHandle, meanPath(end, 1), meanPath(end, 3), meanPath(end, 2), "  n = " + numel(ofDirection), ...
                'Color', color, 'FontSize', 14, 'FontWeight', 'bold');
        end
    end
    hold(axisHandle, "off");
end


function [meanPath, tube] = MeanTrajectoryAndSpread(trials, nPoints, nAround)
    % Mean of the launch-window trajectories (start-relative, as in DrawRoses) and a tube of +-1 SD around it.
    % Trials have different numbers of samples, so each one is resampled to nPoints evenly spaced along its own path
    % length before averaging. At each point the spread of the trials is taken in the plane perpendicular to the mean
    % path (the spread along the path is timing, not direction): the tube cross-section is the 1 SD ellipse of that
    % spread. tube.X / Y / Z are nPoints x (nAround + 1) surface grids; tube = [] with fewer than 2 trials.
    if nargin < 2, nPoints = 100; end
    if nargin < 3, nAround = 24; end
    meanPath    =   [];
    tube        =   [];

    resampled   =   nan(nPoints, 3, numel(trials));
    for trialCount = 1:numel(trials)
        trial       =   trials{trialCount};
        position    =   trial.GlobalPosition(trial.TherapyWindowIndex, :) - trial.GlobalPosition(1, :);
        pathLength  =   [0; cumsum(vecnorm(diff(position), 2, 2))];
        [pathLength, keep]  =   unique(pathLength);                 % drop samples where the hand did not move
        if numel(pathLength) < 2, continue; end
        resampled(:, :, trialCount) =   interp1(pathLength / pathLength(end), position(keep, :), linspace(0, 1, nPoints)');
    end
    resampled   =   resampled(:, :, squeeze(~any(isnan(resampled), [1 2])));
    if isempty(resampled), return; end
    meanPath    =   mean(resampled, 3);
    if size(resampled, 3) < 2, return; end

    tangent     =   [gradient(meanPath(:, 1)), gradient(meanPath(:, 2)), gradient(meanPath(:, 3))];
    angles      =   linspace(0, 2 * pi, nAround + 1);
    tube.X      =   zeros(nPoints, nAround + 1);
    tube.Y      =   zeros(nPoints, nAround + 1);
    tube.Z      =   zeros(nPoints, nAround + 1);
    previousAxis    =   [];
    for pointCount = 1:nPoints
        direction   =   tangent(pointCount, :)' / max(norm(tangent(pointCount, :)), eps);
        deviation   =   squeeze(resampled(pointCount, :, :))' - meanPath(pointCount, :);   % trials x 3
        projector   =   eye(3) - direction * direction';                                   % removes the along-path part
        covariance  =   projector * cov(deviation) * projector;
        [vectors, values]   =   eig((covariance + covariance') / 2, 'vector');
        [~, order]  =   max(values);
        majorAxis   =   vectors(:, order);
        if ~isempty(previousAxis) && dot(majorAxis, previousAxis) < 0
            majorAxis   =   -majorAxis;                     % keep the ellipse orientation continuous along the path
        end
        previousAxis    =   majorAxis;
        minorAxis   =   cross(direction, majorAxis);
        minorAxis   =   minorAxis / max(norm(minorAxis), eps);
        majorSD     =   sqrt(max(majorAxis' * covariance * majorAxis, 0));
        minorSD     =   sqrt(max(minorAxis' * covariance * minorAxis, 0));
        ring        =   meanPath(pointCount, :)' + majorAxis * majorSD * cos(angles) + minorAxis * minorSD * sin(angles);
        tube.X(pointCount, :)   =   ring(1, :);
        tube.Y(pointCount, :)   =   ring(2, :);
        tube.Z(pointCount, :)   =   ring(3, :);
    end
end


function legendText = RoseLegendText(options)
    % How to read the rose insets of the bar plots
    if options.RoseMean
        legendText  =   "Roses: mean trajectory per direction, shaded = " + char(177) + "1 SD.   Gray = pre-training   Colored = post-training";
    else
        legendText  =   "Roses: every trajectory.   Gray = pre-training   Colored = post-training";
    end
end


function roseAxes = AddGroupRoseInsets(figureHandle, barAxes, centers, insetSize, roseData, preIndex, postIndex, groupColors, groupNames, options, directionColors, titleSuffix)
    % One rose per group as a small axes floating on top of barAxes: the pre-training trials in gray and the
    % post-training trials colored by direction, as the mean trajectory per direction with its 1 SD tube
    % (options.RoseMean) or as every single trajectory (DrawRoses).
    % centers(group, :) = [x y] of the rose center in barAxes data units, insetSize = rose side in figure units.
    % All roses share the same limits and view angle, so the groups can be compared.

    if nargin < 12, titleSuffix = ""; end            % e.g. " - E-16" when the roses show one subject
    barPosition     =   barAxes.Position;
    xLimits         =   barAxes.XLim;
    yLimits         =   barAxes.YLim;
    roseAxes        =   gobjects(1, size(centers, 1));
    grayColors      =   repmat([0.45 0.45 0.45], size(directionColors, 1), 1);

    for groupCount = 1:size(centers, 1)
        xNormalized     =   barPosition(1) + (centers(groupCount, 1) - xLimits(1)) / diff(xLimits) * barPosition(3);
        yNormalized     =   barPosition(2) + (centers(groupCount, 2) - yLimits(1)) / diff(yLimits) * barPosition(4);
        roseAxes(groupCount)    =   axes('Parent', figureHandle, 'Position', [xNormalized - insetSize / 2, yNormalized - insetSize / 2, insetSize, insetSize]);
        if options.RoseMean
            DrawMeanRose(roseAxes(groupCount), roseData{groupCount}(preIndex{groupCount}),  options.Directions, grayColors,      2.5, false, true);
            DrawMeanRose(roseAxes(groupCount), roseData{groupCount}(postIndex{groupCount}), options.Directions, directionColors, 2.5, false, false);
        else
            DrawRoses(roseAxes(groupCount), roseData{groupCount}, preIndex{groupCount}, [], 1);     % empty 4th input = gray, no force arrows
            DrawRoses(roseAxes(groupCount), roseData{groupCount}, postIndex{groupCount}, 1, 1);     % colored by direction, no force arrows
        end
        axis(roseAxes(groupCount), "equal");
        axis(roseAxes(groupCount), "off");
        view(roseAxes(groupCount), 26, 26);
        % Group name pinned just above the inset box (an axes title would move with the camera zoom below)
        annotation(figureHandle, 'textbox', [xNormalized - insetSize / 2, yNormalized + insetSize / 2, insetSize, 0.03], 'String', groupNames(groupCount) + " visits" + titleSuffix, ...
            'Color', groupColors(groupCount, :), 'FontSize', 18, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end

    % Same limits for every rose, each camera centered on its own trajectories, one view angle for all (same scale)
    allLimits   =   [vertcat(roseAxes.XLim), vertcat(roseAxes.YLim), vertcat(roseAxes.ZLim)];
    set(roseAxes, 'XLim', [min(allLimits(:, 1)), max(allLimits(:, 2))], 'YLim', [min(allLimits(:, 3)), max(allLimits(:, 4))], 'ZLim', [min(allLimits(:, 5)), max(allLimits(:, 6))]);
    roseViewAngle   =   nan(1, numel(roseAxes));
    for roseCount = 1:numel(roseAxes)
        roseLines       =   findobj(roseAxes(roseCount), 'Type', 'line');
        if isempty(roseLines), continue; end
        roseX           =   [roseLines.XData];
        roseY           =   [roseLines.YData];
        roseZ           =   [roseLines.ZData];
        roseCenter      =   [min(roseX) + max(roseX), min(roseY) + max(roseY), min(roseZ) + max(roseZ)] / 2;
        cameraOffset    =   roseAxes(roseCount).CameraPosition - roseAxes(roseCount).CameraTarget;
        roseAxes(roseCount).CameraTarget    =   roseCenter;
        roseAxes(roseCount).CameraPosition  =   roseCenter + cameraOffset;
        roseViewAngle(roseCount)            =   roseAxes(roseCount).CameraViewAngle;
    end
    set(roseAxes, 'CameraViewAngle', max(roseViewAngle) / 2.1);      % zoom in: the 3D box of an equal-axis rose is much bigger than the trajectories
    figureHandle.CurrentAxes    =   barAxes;       % leave the bar axes as the current axes without moving them over the roses
end
