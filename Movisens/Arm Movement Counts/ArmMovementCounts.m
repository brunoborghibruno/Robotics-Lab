%% BRUNO BORGHI - How much and how hard the affected arm moves in daily life (Movisens Move 4 gyroscope)
%
% Goal: three arm-use values per patient and visit (Visits 1, 4, 7) from the sensor worn on the affected wrist at
% home, and whether they change more over EF weeks than over SHAM weeks. Higher = more use of the affected arm.
% Rationale in ArmMovementCounts_Rationale.txt.
%
% Data: one folder per visit in ErrorFields/Movisens (e.g. E-26_Visit1). angularrate.bin holds the gyroscope:
% int16, little-endian, 3 interleaved axes, 64 Hz, 0.07 deg/s per count (unisens.xml and Move 4 datasheet).
% maxSamples = "all" uses the whole recording; a number uses only the first maxSamples (1700000 = 7.4 h, the same
% window as SPARC_Analysis.m and SignalComparison_FFT.m), and a visit shorter than that is skipped (NaN).
% With usePressure = true the window starts when the patient leaves the building (pressureReading.m), not at the start
% of the recording, so the lab time is left out.
%
% Method, for each visit (steps 1-4 are the same as SPARC_Analysis.m):
%   1. Read angularrate.bin and convert counts to deg/s. If usePressure, find the exit time with the barometer
%      (pressureReading.m: first pressure rise > 4 hPa within 3 min, the elevator down) and keep the data from then on.
%   2. Subtract each axis's median (gyroscope bias, ~1-3 deg/s).
%   3. Angular speed = norm of the 3 axes, low-passed at 10 Hz (4th-order Butterworth, filtfilt).
%   4. Movement events: speed above threshold/3 (10 deg/s), reaching threshold (30 deg/s), lasting 0.5-10 s.
%   5. Metrics:
%        eventsPerHour = number of events / hours recorded           (how often the arm moves)
%        activePercent = % of samples with speed > activeThreshold   (how long the arm moves)
%        intensity     = median over events of the event's peak speed (how hard the arm moves, deg/s)
%
% Output:
%   exitTable   : Subject, Visit, minutes from recording start to the exit, size of the pressure rise (NaN = no rise
%                 found, window starts at minute 0). Only with usePressure = true.
%   countsTable : Subject, Visit, startHour, hours, eventsPerHour, activePercent, intensity.
%   Figure 1    : each metric per subject, one bar per visit.
%   Figure 2    : SHAM vs EF raincloud of the changes (later - earlier visit, positive = more use), drawn like the
%                 raincloud in SPARC_Analysis.m. Only subjects with both changes are shown, so both pairs have the
%                 same subjects. Dot fill: dark blue if either recording of that change started after
%                 lateHour (16:00), so its window covers evening/night; dark yellow otherwise (startTimeColors).
%                 This uses the recording start time, not the exit time.
%   Console     : per metric, paired Wilcoxon signed-rank of each subject's EF change vs its SHAM change.
%
% Limits: one wrist only, so no use ratio between the two arms. Daily activity varies from day to day for
% reasons unrelated to therapy. The thresholds are first guesses (check them with Figure 2 of SPARC_Analysis.m).
%
% Sources:
%   - Lang CE et al. A method for quantifying upper limb performance in daily life using accelerometers.
%     J Vis Exp 2017 (https://www.jove.com/t/55673). (hours of use, magnitude from wrist sensors)
%   - Bailey RR, Klaesner JW, Lang CE. Quantifying real-world upper-limb activity in nondisabled adults and adults
%     with chronic stroke. Neurorehabil Neural Repair 2015;29(10):969-978.
%   - Waddell KJ et al. Does task-specific training improve upper limb performance in daily life poststroke?
%     Neurorehabil Neural Repair 2017;31(3):290-300. (clinic gains did not show up in daily-life arm use)
%   - Movisens Move 4 datasheet: https://www.movisens.com/en/products/move-4/



%% Settings

maxSamples       =  5529600;    % "all" = whole recording (any length); a number = first maxSamples only.
                                % 1700000 samples / 64 Hz = 26562 s = 7.4 h, the same window as SPARC_Analysis.m
usePressure      =  false;       % true = window starts when the patient leaves the building (pressureReading.m);
                                % false = pressure not used at all, window starts at the start of the recording

subjectsList     =  ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];
visits           =  [1, 4, 7];

fs               =  64;         % Hz (unisens.xml)
gyroLSB          =  0.07;       % deg/s per count (unisens.xml lsbValue; Move 4 range +/-2000 deg/s)

threshold        =  30;         % deg/s: an event must reach this speed; its edges are where speed drops below threshold/3
minDur           =  0.5;        % s, shortest event kept
maxDur           =  10;         % s, longest event kept
activeThreshold  =  10;         % deg/s: above this the wrist counts as moving (active time)
startTimeColors  =  true;       % true = Figure 2 dots filled by recording start time; false = white dots
lateHour         =  16;         % recordings that started after this hour (16 = 4 pm) are marked in Figure 2

% EF-first subjects, as in SignalComparison_FFT.m and SPARC_Analysis.m. A NEW SUBJECT MUST BE ADDED HERE if it
% started with EF. E-47's V6 EF inside a SHAM week counts as SHAM.
firstWeekEF      =  ismember(subjectsList, ["E-5", "E-21", "E-25", "E-44", "E-47", "E-81"]);

% The data are in ErrorFields/Movisens; this script is in ErrorFields/Post Processing/Movisens/Arm Movement Counts
scriptFolder  =  fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
dataFolder    =  fullfile(fileparts(fileparts(fileparts(scriptFolder))), 'Movisens');



%% Metrics per visit

[b, a]         =  butter(4, 10 / (fs/2));      % 10 Hz low-pass for the speed
nSubjects      =  length(subjectsList);
hours          =  NaN(nSubjects, length(visits));
eventsPerHour  =  NaN(nSubjects, length(visits));
activePercent  =  NaN(nSubjects, length(visits));
intensity      =  NaN(nSubjects, length(visits));
startHour      =  NaN(nSubjects, length(visits));   % clock time when the recording started, in hours (15.5 = 15:30)
exitMinute     =  NaN(nSubjects, length(visits));   % minutes from recording start to leaving the building
jumpHPa        =  NaN(nSubjects, length(visits));   % pressure rise at the exit (hPa)

for s = 1:nSubjects
    for v = 1:length(visits)
        visitFolder  =  fullfile(dataFolder, subjectsList(s) + "_Visit" + visits(v));
        if ~isfile(fullfile(visitFolder, 'angularrate.bin'))
            fprintf('Skipped %s: no angularrate.bin\n', visitFolder);
            continue
        end

        startText        =  extractBetween(fileread(fullfile(visitFolder, 'unisens.xml')), 'timestampStart="', '"');
        startTime        =  datetime(startText{1}, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss.SSS");
        startHour(s, v)  =  hour(startTime) + minute(startTime)/60 + second(startTime)/3600;

        omega  =  ReadGyroBin(visitFolder) * gyroLSB;          % N x 3, deg/s
        if usePressure
            [exitMinute(s, v), jumpHPa(s, v)]  =  pressureReading(visitFolder);
            omega  =  omega(exitMinute(s, v)*60*fs + 1 : end, :);   % drop the time before leaving the building
        end
        if ~strcmp(maxSamples, "all")
            if size(omega, 1) < maxSamples
                fprintf('Skipped %s: only %d samples\n', visitFolder, size(omega, 1));
                continue
            end
            omega  =  omega(1:maxSamples, :);
        end
        omega  =  omega - median(omega);                       % remove the gyroscope bias
        speed  =  filtfilt(b, a, vecnorm(omega, 2, 2));        % angular speed, deg/s
        events =  FindEvents(speed, fs, threshold, minDur, maxDur);

        peakSpeed  =  zeros(size(events, 1), 1);
        for k = 1:size(events, 1)
            peakSpeed(k)  =  max(speed(events(k,1):events(k,2)));
        end

        hours(s, v)          =  length(speed) / fs / 3600;
        eventsPerHour(s, v)  =  size(events, 1) / hours(s, v);
        activePercent(s, v)  =  100 * mean(speed > activeThreshold);
        intensity(s, v)      =  median(peakSpeed);
    end
end

if usePressure
    exitTable  =  table(repelem(subjectsList', length(visits)), repmat(visits', nSubjects, 1), reshape(exitMinute', [], 1), ...
                        reshape(jumpHPa', [], 1), 'VariableNames', {'Subject', 'Visit', 'exitMinute', 'jumpHPa'});
    fprintf('\nLeaving the building (pressureReading.m). jumpHPa = NaN: no rise found, window starts at minute 0.\n');
    disp(exitTable)
end

countsTable  =  table(repelem(subjectsList', length(visits)), repmat(visits', nSubjects, 1), reshape(startHour', [], 1), ...
                      reshape(hours', [], 1), reshape(eventsPerHour', [], 1), reshape(activePercent', [], 1), reshape(intensity', [], 1), ...
                      'VariableNames', {'Subject', 'Visit', 'startHour', 'hours', 'eventsPerHour', 'activePercent', 'intensity'});
disp(countsTable)

metrics      =  {eventsPerHour, activePercent, intensity};
metricNames  =  ["Events per hour", "Active time (%)", "Intensity (deg/s)"];



%% Figure 1 - each metric per subject and visit

figure(1); clf
for m = 1:3
    subplot(3, 1, m)
    bar(categorical(subjectsList, subjectsList), metrics{m})
    ylabel(metricNames(m))
end
legend("Visit " + visits, 'Location', 'southoutside', 'Orientation', 'horizontal')
sgtitle('Affected-arm use in daily life (gyroscope)')



%% Changes between visits and SHAM vs EF test

% Delta = later visit - earlier visit: positive = more use. V1 -> V4 = first treatment week, V4 -> V7 = second.
% Only subjects with both changes are kept, so each subject has one EF change and one SHAM change.
isEFChange  =  [firstWeekEF', ~firstWeekEF'];          % columns: V4 - V1, V7 - V4
deltas      =  cell(1, 3);
fprintf('\nEF change vs SHAM change (paired Wilcoxon signed-rank, positive = more use):\n');
for m = 1:3
    d          =  [metrics{m}(:,2) - metrics{m}(:,1), metrics{m}(:,3) - metrics{m}(:,2)];
    d(any(isnan(d), 2), :)  =  NaN;
    deltas{m}  =  d;

    ok         =  ~isnan(d(:,1));
    efDelta    =  sum(d(ok,:) .* isEFChange(ok,:), 2);
    shamDelta  =  sum(d(ok,:) .* ~isEFChange(ok,:), 2);
    fprintf('  %-18s n = %d   median EF = %+.3f   median SHAM = %+.3f   p = %.3f\n', metricNames(m), sum(ok), ...
            median(efDelta), median(shamDelta), signrank(efDelta, shamDelta));
end



%% Figure 2 - SHAM vs EF raincloud of the changes (same drawing as Figure 4 of SPARC_Analysis.m)

% Left pair = Visit 4 - Visit 1, right pair = Visit 7 - Visit 4. In each pair the SHAM-first subjects face left and
% the EF-first subjects face right; the color is the treatment of that week. Thick dark line = 25th-75th percentile,
% big dot = median. Gray lines join the two changes of the same subject. Dot fill: dark blue if either recording
% of that change started after lateHour, dark yellow otherwise.
linesOn     =  true;                          % false = no lines joining the two changes of the same subject
isLate      =  startHour > lateHour;
lateChange  =  [isLate(:,1) | isLate(:,2), isLate(:,2) | isLate(:,3)];   % columns: V4 - V1, V7 - V4
lateColor   =  [0.05, 0.15, 0.50];            % dark blue
earlyColor  =  [0.75, 0.60, 0.00];            % dark yellow
if ~startTimeColors
    lateChange(:)  =  false;
    earlyColor     =  [1 1 1];                % all dots white
end
shamColor   =  [0.85, 0.60, 0.10];
efColor     =  [0.80, 0.30, 0.05];
lineC       =  [0.3 0.3 0.3];
halfWidth   =  0.35;
centerGap   =  0.03;
startGroup  =  {~firstWeekEF', firstWeekEF'};    % SHAM first (left halves), EF first (right halves)
groupSide   =  [-1, 1];

figure(2); clf
set(gcf, 'WindowState', 'maximized');
for m = 1:3
    subplot(1, 3, m); hold on
    d            =  deltas{m};
    dotX         =  NaN(nSubjects, 2);
    cloudHandle  =  gobjects(1, 2);
    for c = 1:2
        for g = 1:2
            rows    =  find(startGroup{g} & ~isnan(d(:, c)));
            if isempty(rows), continue; end
            values  =  d(rows, c);
            isEF    =  isEFChange(rows(1), c);
            color   =  shamColor * ~isEF + efColor * isEF;
            edgeX   =  c + groupSide(g) * centerGap;
            [cloud, dotX(rows, c)]  =  DrawHalfViolin(edgeX, values, color, groupSide(g), halfWidth);
            if ~isempty(cloud), cloudHandle(isEF + 1) = cloud; end
            dotFill  =  repmat(earlyColor, numel(rows), 1);
            dotFill(lateChange(rows, c), :)  =  repmat(lateColor, sum(lateChange(rows, c)), 1);
            scatter(dotX(rows, c), values, 200, dotFill, 'filled', 'MarkerEdgeColor', color, 'LineWidth', 2);
            quartiles  =  prctile(values, [25 50 75]);
            plot([edgeX edgeX], quartiles([1 3]), '-', 'Color', lineC, 'LineWidth', 5);
            plot(edgeX, quartiles(2), 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', lineC, 'MarkerSize', 18, 'LineWidth', 1.5);
        end
    end
    if linesOn
        for row = find(all(~isnan(d), 2))'
            plot(dotX(row, :), d(row, :), '-', 'Color', [0.2 0.2 0.2 0.4], 'LineWidth', 1.5);
        end
    end
    yline(0, '--', 'Color', 'b');
    xlim([0.4, 2.6]);
    ylabel("\Delta " + metricNames(m), 'FontWeight', 'bold');
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Visits 1 ↔ 4', 'Visits 4 ↔ 7'}, 'FontSize', 18, 'FontWeight', 'bold', 'Box', 'off', 'Color', 'none');
    title(metricNames(m));
    hold off
end
if startTimeColors
    hold on
    lateDot   =  scatter(NaN, NaN, 200, lateColor, 'filled');
    earlyDot  =  scatter(NaN, NaN, 200, earlyColor, 'filled');
    hold off
    legend([cloudHandle(2), cloudHandle(1), lateDot, earlyDot], {'Error Field', 'SHAM', ...
           sprintf('Started after %d:00', lateHour), sprintf('Started before %d:00', lateHour)}, 'Location', 'northeast', 'Box', 'off');
else
    legend([cloudHandle(2), cloudHandle(1)], {'Error Field', 'SHAM'}, 'Location', 'northeast', 'Box', 'off');
end
sgtitle('Change in affected-arm use: SHAM vs EF (positive = more use)', 'FontSize', 24, 'FontWeight', 'bold');




function omega = ReadGyroBin(visitFolder)
% Gyroscope of one visit from its angularrate.bin: N x 3 raw counts (int16 stored, returned as double)
fileID     =  fopen(fullfile(visitFolder, 'angularrate.bin'), 'rb');
closeFile  =  onCleanup(@() fclose(fileID));
omega      =  fread(fileID, [3 inf], 'int16')';
end


function events = FindEvents(speed, fs, threshold, minDur, maxDur)
% Events = runs where speed > threshold/3 that reach threshold and last minDur-maxDur seconds. Returns [start end] indices.
moving  =  speed > threshold/3;
edges   =  diff([0; moving; 0]);
starts  =  find(edges == 1);
ends    =  find(edges == -1) - 1;

duration  =  (ends - starts + 1) / fs;
keep      =  duration >= minDur & duration <= maxDur;
for k = find(keep)'
    keep(k)  =  max(speed(starts(k):ends(k))) >= threshold;
end
events  =  [starts(keep), ends(keep)];
end


function [cloud, dotX] = DrawHalfViolin(edgeX, values, color, side, halfWidth)
% Half violin (kernel density) starting at edgeX and facing side (-1 left, +1 right). Copied from SignalComparison_FFT.m.
% dotX = x of each value inside the cloud; the spread is fixed (no rand), so the figure is the same on every run.
cloud = [];
dotX  = edgeX * ones(size(values));
if numel(values) < 2, return; end
[density, valueGrid]  =  ksdensity(values, 'NumPoints', 200);
density               =  density ./ max(density);
cloud                 =  patch([edgeX + side * density * halfWidth, edgeX], [valueGrid, valueGrid(end)], color, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
densityAtValue        =  interp1(valueGrid, density, values);
spread                =  0.15 + 0.7 * mod((1:numel(values))' * 0.618, 1);
dotX                  =  edgeX + side * spread .* densityAtValue * halfWidth;
end
