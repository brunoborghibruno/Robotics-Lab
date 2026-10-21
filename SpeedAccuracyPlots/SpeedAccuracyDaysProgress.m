%% BRUNO BORGHI - Speed vs Accuracy Improvement Area across the treatment days
% For every patient and visit, the Improvement Area of SpeedvsAccuracy_Patients.m measured against a reference visit,
% drawn with DaysProgressPlot.m: one trace per patient, EF-first and SHAM-first patients as two groups.
% The reference is the IE of Visit 1 or the IE of the previous visit (referenceVisit below).
%   Dot of visit k  : Intermittent Exposure (IE) of visit k vs the reference
%   Wing of visit k : Post-Training of visit k vs the same reference (training visits 2-7 only)
% With "baseline" Visit 1 = 0; with "previous" Visit 1 has no value and a visit after a missing one is NaN too.
% Positive = more accurate at the same speed than the reference. Fit and area as in SpeedAccuracyCupolasSubplotMinimal.m:
% log(1/error) vs peak speed, the four practiced directions pooled, area over the full speed range.
% Thick segment = Error Field week (Visits 2-4 for EF first, Visits 5-7 for SHAM first).

close all; clear all; clc;

%% Settings

subjectsList        =   ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];
visits              =   1:9;
trainingVisits      =   2:7;        % visits with a Post-Training phase (the wings)

referenceVisit      =   "previous";     % "baseline" = every visit vs Visit 1; "previous" = every visit vs the visit before

errorMetric         =   "MaximumErrorAmplitude";
% errorMetric         =   "MaximumPerpendicularError";
typeOfMetric        =   'launch';

speedFeedbackRange  =   [0.1976, 0.5138];   % patients' speed thresholds (only used if fullRange = 0)
fullRange           =   1;                  % 1 = area over the full speed range, as in SpeedvsAccuracy_Patients.m

visitLabels         =   {"Baseline", "T-1", "T-2", "T-3", "T-4", "T-5", "T-6", "Post", "FollowUp"};
verticalLines       =   [1.5, 4.5, 7.5, 8.5];

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
        fitIE{s, v}     =   SpeedAccuracyFit(speed, err);

        if ismember(visits(v), trainingVisits)
            AddPostTrainingPhaseIndexToSpecialMovementIndex();
            [speed, err]    =   PhaseSpeedError("PostTraining", errorMetric, typeOfMetric);
            fitPost{s, v}   =   SpeedAccuracyFit(speed, err);
        end
    end
end

%% Improvement Area of every visit against the reference IE line (Visit 1 or the previous visit)

if referenceVisit == "baseline"
    referenceLabel  =   "Visit 1";
elseif referenceVisit == "previous"
    referenceLabel  =   "previous visit";
else
    error("referenceVisit must be ""baseline"" or ""previous"", not ""%s"".", referenceVisit);
end

beginArea   =   NaN(nSubjects, nVisits);
endArea     =   NaN(nSubjects, nVisits);
for s = 1:nSubjects
    for v = 1:nVisits
        if referenceVisit == "baseline"
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

figure(1); clf
set(gcf, 'WindowState', 'maximized');
ax = axes;
DaysProgressPlot(ax, {padRows(beginArea, efRows); padRows(beginArea, shamRows)}, ...
                     {padRows(endArea, efRows); padRows(endArea, shamRows)}, ...
                     {2:4; 5:7}, verticalLines, "Improvement Area (vs " + referenceLabel + ")", visitLabels, [], [], ...
                     {"EF first (" + numel(efRows) + ")"; "SHAM first (" + numel(shamRows) + ")"});
yline(ax, 0, '--', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
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
