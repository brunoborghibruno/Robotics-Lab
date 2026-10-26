%% BRUNO BORGHI - Speed vs Accuracy Improvement Area across the treatment days
% For every patient and visit, the Improvement Area of SpeedvsAccuracy_Patients.m measured against a reference visit,
% drawn with DaysProgressPlot.m: one trace per patient, EF-first and SHAM-first patients as two groups.
% The reference is the IE of Visit 1 or the IE of the previous visit (referenceVisit below).
% With baselineReference = "first2visits" the baseline reference is one line fitted to the IE trials of Visits 1 and 2 pooled.
%   Dot of visit k  : Intermittent Exposure (IE) of visit k vs the reference
%   Wing of visit k : Post-Training of visit k vs the same reference (training visits 2-7 only)
% With "baseline" Visit 1 = 0 (Visits 1 and 2 = 0 with "first2visits"); with "previous" Visit 1 has no value and a visit after a missing one is NaN too.
% Positive = more accurate at the same speed than the reference. Fit and area as in SpeedAccuracyCupolasSubplotMinimal.m:
% log(1/error) vs peak speed, the four practiced directions pooled, area over the full speed range.
% Thick segment = Error Field week (Visits 2-4 for EF first, Visits 5-7 for SHAM first).

close all; clear all; clc;

%% Settings

subjectsList        =   ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];
visits              =   1:9;
trainingVisits      =   2:7;        % visits with a Post-Training phase (the wings)

referenceVisit      =   "baseline";     % "baseline" = every visit vs Visit 1; "previous" = every visit vs the visit before
baselineReference   =   "baseline";     % only with referenceVisit = "baseline": "baseline" = IE of Visit 1; "first2visits" = IE trials of Visits 1 and 2 pooled

% errorMetric         =   "MaximumErrorAmplitude";
errorMetric         =   "MaximumPerpendicularError";
% errorMetric         =   "LaunchDeviationAngle";
typeOfMetric        =   'launch';

speedFeedbackRange  =   [0.1976, 0.5138];   % patients' speed thresholds (only used if fullRange = 0)
fullRange           =   1;                  % 1 = area over the full speed range, as in SpeedvsAccuracy_Patients.m

visitLabels         =   {"Baseline", "T-1", "T-2", "T-3", "T-4", "T-5", "T-6", "Post", "FollowUp"};
verticalLines       =   [1.5, 4.5, 7.5, 8.5];
averageAllSubjects  =   true;       % true = thick mean curve per group (EF first, SHAM first) over faded subject traces; false = one curve per subject
showPrePostLines    =   false;       % false = hide the dotted IE -> Post-Training lines (the wings)

%% Load speed and error of every visit and fit the speed-accuracy lines

global Data PhaseIndex SpecialMovementIndex InputFile

functionsFolder     =   fileparts(mfilename('fullpath'));
initialFolder       =   fileparts(functionsFolder);
addpath(initialFolder);
addpath(functionsFolder);

nSubjects           =   numel(subjectsList);
nVisits             =   numel(visits);
fitIE               =   cell(nSubjects, nVisits);   % each cell: [speed; log(1/error)] of the fitted line
fitPost             =   cell(nSubjects, nVisits);
speedIE             =   cell(nSubjects, nVisits);   % raw IE speed and error, kept for the pooled Visits 1-2 reference
errIE               =   cell(nSubjects, nVisits);
isEFFirst           =   false(nSubjects, 1);

for s = 1:nSubjects
    for v = 1:nVisits
        fileName    =   fullfile(initialFolder, subjectsList(s), subjectsList(s) + "_Visit_" + visits(v) + ".mat");
        if ~isfile(fileName)
            fprintf('%s not found, left as NaN\n', fileName);
            continue
        end
        fprintf('Loading %s Visit %d\n', subjectsList(s), visits(v));
        loaded                  =   load(fileName, 'Data', 'PhaseIndex', 'SpecialMovementIndex', 'InputFile');
        Data                    =   loaded.Data;
        PhaseIndex              =   loaded.PhaseIndex;
        SpecialMovementIndex    =   loaded.SpecialMovementIndex;
        InputFile               =   loaded.InputFile;

        if visits(v) == 2
            isEFFirst(s)    =   Data{1}.GroupNumber == 4;
        end

        [speed, err]    =   PhaseSpeedError("IntermittentExposure", errorMetric, typeOfMetric);
        speedIE{s, v}   =   speed;
        errIE{s, v}     =   err;
        fitIE{s, v}     =   SpeedAccuracyFit(speed, err);

        if ismember(visits(v), trainingVisits)
            AddPostTrainingPhaseIndexToSpecialMovementIndex();
            [speed, err]    =   PhaseSpeedError("PostTraining", errorMetric, typeOfMetric);
            fitPost{s, v}   =   SpeedAccuracyFit(speed, err);
        end
    end
end

%% Improvement Area of every visit against the reference IE line (Visit 1 or the previous visit)

if ~ismember(baselineReference, ["baseline", "first2visits"])
    error("baselineReference must be ""baseline"" or ""first2visits"", not ""%s"".", baselineReference);
end
useFirst2Visits =   referenceVisit == "baseline" && baselineReference == "first2visits";
if useFirst2Visits
    referenceLabel  =   "Visits 1-2";
elseif referenceVisit == "baseline"
    referenceLabel  =   "Visit 1";
elseif referenceVisit == "previous"
    referenceLabel  =   "previous visit";
else
    error("referenceVisit must be ""baseline"" or ""previous"", not ""%s"".", referenceVisit);
end

beginArea   =   NaN(nSubjects, nVisits);
endArea     =   NaN(nSubjects, nVisits);
for s = 1:nSubjects
    if useFirst2Visits
        pooledReference =   SpeedAccuracyFit([speedIE{s, 1}, speedIE{s, 2}], [errIE{s, 1}, errIE{s, 2}]);
    end
    for v = 1:nVisits
        if useFirst2Visits
            reference   =   pooledReference;
        elseif referenceVisit == "baseline"
            reference   =   fitIE{s, 1};
        elseif v > 1
            reference   =   fitIE{s, v - 1};
        else
            reference   =   [];             % Visit 1 has no previous visit
        end
        if isempty(reference), continue; end
        if ~isempty(fitIE{s, v})
            beginArea(s, v) =   ComputeSignedAreaBetweenLines(reference(1,:), reference(2,:), fitIE{s, v}(1,:), fitIE{s, v}(2,:), [], 0, speedFeedbackRange, fullRange);
        end
        if ~isempty(fitPost{s, v})
            endArea(s, v)   =   ComputeSignedAreaBetweenLines(reference(1,:), reference(2,:), fitPost{s, v}(1,:), fitPost{s, v}(2,:), [], 0, speedFeedbackRange, fullRange);
        end
    end
    if useFirst2Visits             % Visits 1 and 2 are the baseline itself
        beginArea(s, ~isnan(beginArea(s, 1:2)))    =   0;
    end
end

groupName   =   repmat("SHAM first", nSubjects, 1);
groupName(isEFFirst)    =   "EF first";
areaTable   =   table(repelem(subjectsList', nVisits), repelem(groupName, nVisits), repmat(visits', nSubjects, 1), ...
                      reshape(beginArea', [], 1), reshape(endArea', [], 1), ...
                      'VariableNames', {'Subject', 'Group', 'Visit', 'BeginArea', 'EndArea'});

%% Days progress plot

% Multi-group DaysProgressPlot needs the same number of rows in each group: pad the smaller one with NaN rows.
efRows      =   find(isEFFirst);
shamRows    =   find(~isEFFirst);
nRows       =   max(numel(efRows), numel(shamRows));
padRows     =   @(values, rows) [values(rows, :); NaN(nRows - numel(rows), nVisits)];
meanRows    =   @(values, rows) mean(values(rows, :), 1, 'omitnan');   % group mean at each visit, missing visits skipped
yLabelText  =   "Improvement Area (vs " + referenceLabel + ")";
groupNames  =   {"EF first (" + numel(efRows) + ")"; "SHAM first (" + numel(shamRows) + ")"};

figure(1); clf
set(gcf, 'WindowState', 'maximized');
ax = axes;
if averageAllSubjects
    % Every subject's trace, thin on every visit, then the group means on top (no second set of vertical lines)
    DaysProgressPlot(ax, {padRows(beginArea, efRows); padRows(beginArea, shamRows)}, ...
                         {padRows(endArea, efRows); padRows(endArea, shamRows)}, ...
                         {[]; []}, verticalLines, yLabelText, visitLabels, [], [], groupNames);
    set(findobj(ax, 'Type', 'line'), 'Tag', 'subject');
    DaysProgressPlot(ax, {meanRows(beginArea, efRows); meanRows(beginArea, shamRows)}, ...
                         {meanRows(endArea, efRows); meanRows(endArea, shamRows)}, ...
                         {2:4; 5:7}, [], yLabelText, visitLabels, [], [], groupNames);
else
    DaysProgressPlot(ax, {padRows(beginArea, efRows); padRows(beginArea, shamRows)}, ...
                         {padRows(endArea, efRows); padRows(endArea, shamRows)}, ...
                         {2:4; 5:7}, verticalLines, yLabelText, visitLabels, [], [], groupNames);
end
if ~showPrePostLines
    delete(findobj(ax, 'Type', 'line', 'LineStyle', ':'));
end
% Line widths and subject fading (xline/yline are not 'line' objects, so they keep their width)
meanWidthFactor =   1.5 * (1 + averageAllSubjects);     % group means twice as thick as the per-subject plot
for traceLine = findobj(ax, 'Type', 'line')'
    if strcmp(traceLine.Tag, 'subject')
        traceLine.LineWidth =   1.5 * traceLine.LineWidth;
        if strcmp(traceLine.LineStyle, 'none')      % dots: markers have no transparency, so blend 40% colour with white
            traceLine.MarkerFaceColor   =   0.3 * traceLine.MarkerFaceColor + 0.6;
            traceLine.Color             =   0.3 * traceLine.Color(1:3) + 0.6;
        else
            traceLine.Color(4)  =   0.3;            % 40% opacity (undocumented line alpha)
        end
    elseif averageAllSubjects && traceLine.LineWidth == 6       % EF-week segment of a group mean (thickBetweenDaysLW in DaysProgressPlot)
        traceLine.LineWidth =   13.5;                           % 1.5 x the per-subject plot's 9
    elseif averageAllSubjects && strcmp(traceLine.LineStyle, '-')
        traceLine.LineWidth =   6;                              % rest of the group mean trace
    else
        traceLine.LineWidth =   meanWidthFactor * traceLine.LineWidth;
    end
end
title(ax, "Speed-accuracy Improvement Area vs " + referenceLabel + " (" + errorMetric + ")");


%% FUNCTIONS

function [speed, err] = PhaseSpeedError(phaseName, errorMetric, typeOfMetric)
% Peak speed and error of every trial of one phase, the four practiced directions pooled (as in SpeedvsAccuracy_Patients.m).
global SpecialMovementIndex
speed   =   [];
err     =   [];
if ~isfield(SpecialMovementIndex, phaseName), return; end
for direction = ["DirectionZero", "DirectionOne", "DirectionTwo", "DirectionThree"]
    index   =   SpecialMovementIndex.(phaseName).(direction);
    speed   =   [speed, GetErrorVector(index, 'Speed', typeOfMetric)'];
    err     =   [err, GetErrorVector(index, errorMetric, typeOfMetric)'];
end
end


function fitLine = SpeedAccuracyFit(speed, err)
% Straight-line fit of log(1/error) on speed over 100 points, the same cleaning and fit as SpeedAccuracyCupolasSubplotMinimal.m.
keep    =   isfinite(err);
speed   =   speed(keep);
err     =   log(1 ./ err(keep));
if numel(speed) < 2
    fitLine =   [];
    return
end
coeff       =   polyfit(speed, err, 1);
speedRange  =   linspace(min(speed), max(speed), 100);
fitLine     =   [speedRange; polyval(coeff, speedRange)];
end
