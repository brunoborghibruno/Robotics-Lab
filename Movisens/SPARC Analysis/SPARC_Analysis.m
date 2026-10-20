%% BRUNO BORGHI - SPARC smoothness of wrist movements from the Movisens Move 4 gyroscope
%
% Goal: one smoothness value per patient and visit (Visits 1, 4, 7) from the wrist sensor worn at home, to see
% whether movements get smoother over the protocol. SPARC closer to 0 = smoother (see SPARC.m).
%
% Data: one folder per visit in ErrorFields/Movisens (e.g. E-26_Visit1). angularrate.bin holds the gyroscope:
% int16, little-endian, 3 interleaved axes, 64 Hz, 0.07 deg/s per count (unisens.xml and Move 4 datasheet).
% Recordings are ~48 h of free-living data with no task markers. maxSamples = "all" uses the whole recording;
% a number uses only the first maxSamples (1700000 = 7.4 h, the same window as SignalComparison_FFT.m), and a
% visit shorter than that is skipped (NaN). A visit with no angularrate.bin is always skipped.
%
% Method, for each visit:
%   1. Read angularrate.bin and convert counts to deg/s.
%   2. Subtract each axis's median: removes the gyroscope bias (~1-3 deg/s), since the wrist is still most of the time.
%   3. Angular speed = norm of the 3 axes, low-passed at 10 Hz (4th-order Butterworth, zero-phase filtfilt).
%   4. Movement events: stretches where speed stays above threshold/3 (10 deg/s), reach threshold (30 deg/s)
%      at least once, and last 0.5-10 s. The low edge keeps the start and end of each movement.
%   5. SPARC of each event (SPARC.m), then the median over all events of the visit.
%
% Output:
%   sparcTable : Subject, Visit, nEvents, medianSPARC.
%   Figure 1   : median SPARC per subject, one bar per visit.
%   Figure 2   : one minute of speed for exampleSubject/exampleVisit with the detected events shaded, to check
%                that the threshold picks real movements.
%   Figure 3   : change between visits (V4 - V1, V7 - V4), positive = smoother; EF weeks black, SHAM weeks gray.
%   Figure 4   : SHAM vs EF raincloud of the same changes (as the volume raincloud in SignalComparison_FFT.m).
%
% Limits: in free-living data an event can contain several movements in a row, and walking arm swing is detected
% too. The median over hundreds or thousands of events per visit reduces this but does not remove it.
% The thresholds are first guesses; check them on Figure 2 before trusting the results.
%
% Sources:
%   - Balasubramanian S, Melendez-Calderon A, Roby-Brami A, Burdet E. On the analysis of movement smoothness.
%     J NeuroEng Rehabil 2015;12:112. (SPARC algorithm)
%   - Melendez-Calderon A, Shirota C, Balasubramanian S. Estimating movement smoothness from inertial measurement
%     units. Front Bioeng Biotechnol 2021;8:558771. (SPARC on IMU rotational data)
%   - Saes M et al. Smoothness metric during reach-to-grasp after stroke: part 2. J NeuroEng Rehabil 2021
%     (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8461930/). (SPARC tracks recovery after stroke)
%   - Lang CE et al. A method for quantifying upper limb performance in daily life using accelerometers.
%     J Vis Exp 2017 (https://www.jove.com/t/55673). (wrist sensors for free-living arm use after stroke)
%   - Movisens Move 4 datasheet: https://www.movisens.com/en/products/move-4/



%% Settings

subjectsList  =  ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];
visits        =  [1, 4, 7];
maxSamples    =  1700000;    % "all" = whole recording (any length); a number = first maxSamples only.
                             % 1700000 samples / 64 Hz = 26562 s = 7.4 h, the same window as SignalComparison_FFT.m

fs            =  64;         % Hz (unisens.xml)
gyroLSB       =  0.07;       % deg/s per count (unisens.xml lsbValue; Move 4 range +/-2000 deg/s)

threshold     =  30;         % deg/s: an event must reach this speed; its edges are where speed drops below threshold/3
minDur        =  0.5;        % s, shortest event kept
maxDur        =  10;         % s, longest event kept

exampleSubject  =  "E-26";   % subject and visit shown in Figure 2
exampleVisit    =  1;

% The data are in ErrorFields/Movisens; this script is in ErrorFields/Post Processing/Movisens/SPARC Analysis
scriptFolder  =  fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
dataFolder    =  fullfile(fileparts(fileparts(fileparts(scriptFolder))), 'Movisens');



%% SPARC per visit

[b, a]       =  butter(4, 10 / (fs/2));      % 10 Hz low-pass for the speed
nSubjects    =  length(subjectsList);
medianSPARC  =  NaN(nSubjects, length(visits));
nEvents      =  zeros(nSubjects, length(visits));

for s = 1:nSubjects
    for v = 1:length(visits)
        visitFolder  =  fullfile(dataFolder, subjectsList(s) + "_Visit" + visits(v));
        if ~isfile(fullfile(visitFolder, 'angularrate.bin'))
            fprintf('Skipped %s: no angularrate.bin\n', visitFolder);
            continue
        end

        omega  =  ReadGyroBin(visitFolder) * gyroLSB;          % N x 3, deg/s
        if ~strcmp(maxSamples, "all")
            if size(omega, 1) < maxSamples
                fprintf('Skipped %s: only %d samples\n', visitFolder, size(omega, 1));
                continue
            end
            omega  =  omega(1:maxSamples, :);
        end
        omega  =  omega - median(omega);                       % remove the gyroscope bias (wrist is still most of the time)
        speed  =  filtfilt(b, a, vecnorm(omega, 2, 2));        % angular speed, deg/s

        events =  FindEvents(speed, fs, threshold, minDur, maxDur);
        S      =  zeros(size(events, 1), 1);
        for k = 1:size(events, 1)
            S(k)  =  SPARC(speed(events(k,1):events(k,2)), fs);
        end

        medianSPARC(s, v)  =  median(S);
        nEvents(s, v)      =  size(events, 1);

        if subjectsList(s) == exampleSubject && visits(v) == exampleVisit
            exampleSpeed  =  speed;
            exampleEvents =  events;
        end
    end
end

sparcTable  =  table(repelem(subjectsList', length(visits)), repmat(visits', nSubjects, 1), ...
                     reshape(nEvents', [], 1), reshape(medianSPARC', [], 1), ...
                     'VariableNames', {'Subject', 'Visit', 'nEvents', 'medianSPARC'});
disp(sparcTable)



%% Figure 1 - median SPARC per subject and visit

figure(1); clf
bar(categorical(subjectsList, subjectsList), medianSPARC)
legend("Visit " + visits, 'Location', 'southoutside', 'Orientation', 'horizontal')
ylabel('Median SPARC (closer to 0 = smoother)')
title('Wrist movement smoothness (gyroscope)')



%% Figure 3 - change in SPARC between visits, colored by the treatment week in between

% Delta = later visit - earlier visit: positive = smoother (SPARC closer to 0), negative = less smooth.
% V1 -> V4 = first treatment week, V4 -> V7 = second week. EF-first list as in SignalComparison_FFT.m (E-47's V6 EF
% inside a SHAM week counts as SHAM). A NEW SUBJECT MUST BE ADDED HERE if it started with EF.
firstWeekEF      =  ismember(subjectsList, ["E-5", "E-21", "E-25", "E-44", "E-47", "E-81"]);
isEFChange       =  [firstWeekEF', ~firstWeekEF'];                        % columns: V4 - V1, V7 - V4
deltaSPARC       =  [medianSPARC(:,2) - medianSPARC(:,1), medianSPARC(:,3) - medianSPARC(:,2)];
treatmentColors  =  [0.55 0.55 0.55; 0 0 0];                              % SHAM gray, EF black (as in SignalComparison_FFT.m)

figure(3); clf
changeBars  =  bar(categorical(subjectsList, subjectsList), deltaSPARC, 'FaceColor', 'flat');
for k = 1:2
    changeBars(k).CData  =  treatmentColors(isEFChange(:, k) + 1, :);
end
yline(0)
xlabel({'Subject', 'left bar = Visit 4 - Visit 1,   right bar = Visit 7 - Visit 4'})
ylabel('\Delta median SPARC (positive = smoother)')
title('Change in wrist movement smoothness between visits')
text(0.02, 0.97, 'EF', 'Units', 'normalized', 'Color', treatmentColors(2, :), 'FontWeight', 'bold')
text(0.02, 0.92, 'SHAM', 'Units', 'normalized', 'Color', treatmentColors(1, :), 'FontWeight', 'bold')



%% Figure 4 - SHAM vs EF raincloud of the SPARC changes (same drawing as the volume raincloud in SignalComparison_FFT.m)

% Left pair = Visit 4 - Visit 1, right pair = Visit 7 - Visit 4. In each pair the SHAM-first subjects face left and
% the EF-first subjects face right; the color is the treatment of that week. Thick dark line = 25th-75th percentile,
% big dot = median. Gray lines join the two changes of the same subject.
linesOn      =  true;                         % false = no lines joining the two changes of the same subject
shamColor    =  [0.85, 0.60, 0.10];
efColor      =  [0.80, 0.30, 0.05];
lineC        =  [0.3 0.3 0.3];
halfWidth    =  0.35;
centerGap    =  0.03;
startGroup   =  {~firstWeekEF', firstWeekEF'};    % SHAM first (left halves), EF first (right halves)
groupSide    =  [-1, 1];
dotX         =  NaN(nSubjects, 2);
cloudHandle  =  gobjects(1, 2);                   % one SHAM and one EF cloud for the legend

figure(4); clf; hold on
set(gcf, 'WindowState', 'maximized');
for c = 1:2
    for g = 1:2
        rows    =  find(startGroup{g} & ~isnan(deltaSPARC(:, c)));
        if isempty(rows), continue; end
        values  =  deltaSPARC(rows, c);
        isEF    =  isEFChange(rows(1), c);
        color   =  shamColor * ~isEF + efColor * isEF;
        edgeX   =  c + groupSide(g) * centerGap;
        [cloud, dotX(rows, c)]  =  DrawHalfViolin(edgeX, values, color, groupSide(g), halfWidth);
        if ~isempty(cloud), cloudHandle(isEF + 1) = cloud; end
        scatter(dotX(rows, c), values, 800, 'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', color, 'LineWidth', 4);
        quartiles  =  prctile(values, [25 50 75]);
        plot([edgeX edgeX], quartiles([1 3]), '-', 'Color', lineC, 'LineWidth', 8);
        plot(edgeX, quartiles(2), 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', lineC, 'MarkerSize', 40, 'LineWidth', 1.5);
    end
end

if linesOn
    for row = find(all(~isnan(deltaSPARC), 2))'
        plot(dotX(row, :), deltaSPARC(row, :), '-', 'Color', [0.2 0.2 0.2 0.4], 'LineWidth', 2);
    end
end

yline(0, '--', 'Color', 'b');
xlim([0.4, 2.6]);
ylabel('\Delta median SPARC (positive = smoother)', 'FontSize', 50, 'FontWeight', 'bold');
set(gca, 'XTick', 1:2, 'XTickLabel', {'Visits 1 ↔ 4', 'Visits 4 ↔ 7'}, 'FontSize', 50, 'FontWeight', 'bold', 'LineWidth', 2, 'Box', 'off', 'Color', 'none');
title('Wrist smoothness change: SHAM vs EF', 'FontSize', 70);
legend([cloudHandle(2), cloudHandle(1)], {'Error Field', 'SHAM'}, 'FontSize', 30, 'Location', 'northeast', 'Box', 'off');
hold off



%% Figure 2 - check of the event detection: one minute of speed with the detected events shaded

if exist('exampleSpeed', 'var')
    middle  =  exampleEvents(round(end/2), 1);              % a minute around the middle event
    window  =  max(1, middle - 30*fs) : min(length(exampleSpeed), middle + 30*fs);
    t       =  window / fs;

    figure(2); clf; hold on
    for k = find(exampleEvents(:,2) >= window(1) & exampleEvents(:,1) <= window(end))'
        xEvent =  min(max(exampleEvents(k, :), window(1)), window(end)) / fs;    % clipped to the plotted minute
        patch([xEvent(1) xEvent(2) xEvent(2) xEvent(1)], [0 0 1 1] * max(exampleSpeed(window)), [0.85 0.85 0.85], 'EdgeColor', 'none')
    end
    plot(t, exampleSpeed(window), 'k')
    yline(threshold, 'r--', 'threshold')
    xlabel('Time (s)'); ylabel('Angular speed (deg/s)')
    title(exampleSubject + " Visit " + exampleVisit + ": detected events (gray)")
end




function omega = ReadGyroBin(visitFolder)
% Gyroscope of one visit from its angularrate.bin: N x 3 raw counts (int16 stored, returned as double), read like ReadAccBin
fileID  =  fopen(fullfile(visitFolder, 'angularrate.bin'), 'rb');
closeFile  =  onCleanup(@() fclose(fileID));
omega   =  fread(fileID, [3 inf], 'int16')';
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
