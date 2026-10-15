%% BRUNO BORGHI - compare the FFT of different subjects using the same time window



%% Select the subjects' ID to be compared

subjectsList   =  ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];
maxSamples     =  1700000;                   % is the amount of samples required to clip the first 7 hours of recording




%% Save subjects Data


% Each visit's acc.bin is read directly with its full path (ReadAccBin, at the end of this file): no dataStorage
% dialog to confirm, and no risk of reading another visit's acc.bin found through the MATLAB path. ReadAccBin returns
% exactly what dataStorage returns as its first output.
% A visit without data (no acc.bin / acc.csv in its folder) or shorter than maxSamples is stored as [] and
% skipped in the sections below, so the other visits are still analysed and plotted.
dataFolder      =  MovisensDataFolder;           % ErrorFields/Movisens, with one subfolder per visit
skippedVisits   =  strings(0);

for count = 1:length(subjectsList)
    for visit = [1, 4, 7]
        name        =  subjectsList(count) + "_Visit" + visit;
        varName     =  "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_" + visit;
        visitFolder =  fullfile(dataFolder, name);

        if isfile(fullfile(visitFolder, 'acc.bin'))
            acceleration    =  ReadAccBin(visitFolder);
        elseif isfile(fullfile(visitFolder, 'acc.csv'))
            acceleration    =  readmatrix(fullfile(visitFolder, 'acc.csv'));     % same raw counts as acc.bin (CSV-only visits)
        else
            skippedVisits(end+1)  =  name + ": no acc.bin / acc.csv in " + visitFolder;    %#ok<SAGROW>
            assignin('base', varName, []);
            continue
        end

        if size(acceleration, 1) < maxSamples
            skippedVisits(end+1)  =  name + ": only " + size(acceleration, 1) + " samples, fewer than maxSamples = " + maxSamples;   %#ok<SAGROW>
            assignin('base', varName, []);
            continue
        end
        assignin('base', varName, acceleration(1:maxSamples, :));
    end
end

if ~isempty(skippedVisits)
    fprintf('\nVisits skipped (no data in the figures):\n');
    fprintf('  %s\n', skippedVisits);
end




%% Signal conversion

LSBvalue    =  0.0001;  % LSB = 5 / 2^16, because of a 5V ADC with 16bit resolution
baseline    =  0;
unitMeasure =  1;       % signalConversion needs this since Mar 2026: 1 = result in g, as signalConversion did before



for count = 1:length(subjectsList)

    % visit 1
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1";
    acceleration    =   evalin('base', varName);
    if ~isempty(acceleration)       % [] = visit skipped
        assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1", signalConversion(acceleration, LSBvalue, baseline, unitMeasure));
    end
    
    
    % visit 4
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4";
    acceleration    =   evalin('base', varName);
    if ~isempty(acceleration)       % [] = visit skipped
        assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4", signalConversion(acceleration, LSBvalue, baseline, unitMeasure));
    end

    % visit 7
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7";
    acceleration    =   evalin('base', varName);
    if ~isempty(acceleration)       % [] = visit skipped
        assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7", signalConversion(acceleration, LSBvalue, baseline, unitMeasure));
    end

end




%% Normalization

timeStamp           =  1/64:1/64:length(("acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1"))/64;
timeStamp1          =  (timeStamp/60)/60; % hours




%% Background noise with Fast Fourier Transform (FFT)

xLimits = [1000, 1]; % absurd min e max frequencies to then overwrite when a smaller/bigger values is founded (just for plotting axes limits purposes)
yLimits = [1000, 1]; % same for power of the signal
xLim = [0, 10];
yLimits = [0, 2];

% subplotNumber = length(subjectsList);
subplotNumber = 3;
colorCode     = 1;                    % subplotWithInsetFunction has 7 colors: colorCode is wrapped with mod(), subject 8 reuses color 1
axIndex       = 1;
cloudVolumes  = NaN(length(subjectsList), 3);   % alpha-shape volume of each inset cloud; columns = Visit 1, 4, 7 (NaN = visit skipped)
yLimitsAll    = [Inf, -Inf];           % min and max of every plotted FFT, applied to all panels after the loop

fig1 = figure(1);
set(fig1, 'WindowState', 'maximized');



for count = 1:length(subjectsList)

    % visit 1
    varName             =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1";
    acceleration        =   evalin('base', varName);
    if isempty(acceleration)
        % Visit skipped: keep the grid layout with an empty panel
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1",[]);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1",[]);
        subplotNumber = subplotNumber + 1;
        subplot(length(subjectsList)+1, 3, subplotNumber);
        text(0.5, 0.5, subjectsList(count) + " Visit 1: no data", 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        axis off;
    else
        [frequency, power]  =   FilterAndFFT(acceleration);
        % power(1:50)         =   0.1;
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1",frequency);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1",power');
        if (min(frequency) < xLimits(1))
            xLimits(1) = min(frequency);
        end
        if (max(frequency) > xLimits(2))
            xLimits(2) = max(frequency);
        end
        % Shared y range: only the points drawn and visible (first half of the spectrum, frequency inside xLim)
        shown       =  frequency(1:end/2) >= xLim(1) & frequency(1:end/2) <= xLim(2);
        powerShown  =  power(1:end/2);
        powerShown  =  powerShown(shown);
        yLimitsAll  =  [min(yLimitsAll(1), min(powerShown)), max(yLimitsAll(2), max(powerShown))];
        fig1;
        hold on;
        subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, 1, '\bf Visit 1', [], "\bf All Subjects \rm" + newline + "Amplitude", [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimits, subjectsList(count));  % all plots superimposed
        subplotNumber = subplotNumber + 1;
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        % varName = "Subj " + (matlab.lang.makeValidName(subjectsList(count))) + " - Visit1";
        varName = "\bf Subj " + (matlab.lang.makeValidName(subjectsList(count)));
        varName = strrep(varName, 'E_', ' ');
        if (count == length(subjectsList))
            cloudVolumes(count, 1) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], '\bf Frequency [Hz]', varName, [], 1, xLim, yLimits, '', acceleration);
        else
            cloudVolumes(count, 1) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], [], varName, [], 1, xLim, yLimits, '', acceleration);
        end
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        box off;
    end
    

    % % Get the position of the current subplot axis
    % mainAxPosition = get(, 'Position');
    % 
    % % Define the inset 1 position
    % insetAx1_Position = [mainAxPosition(1) + mainAxPosition(3) * 0.8, ... % X post
    %     mainAxPosition(2) + mainAxPosition(4) * 0.6, ...               % Y pos
    %     mainAxPosition(3) * 0.4, ...                                    % Width
    %     mainAxPosition(4) * 0.4];                                       % Height
    % 
    % % Create a new inset axis
    % insetAx1 = axes('Position', insetAx1_Position);
    % hold(insetAx1, 'on');



    % visit 4
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4";
    acceleration    =   evalin('base', varName);
    if isempty(acceleration)
        % Visit skipped: keep the grid layout with an empty panel
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4",[]);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4",[]);
        subplotNumber = subplotNumber + 1;
        subplot(length(subjectsList)+1, 3, subplotNumber);
        text(0.5, 0.5, subjectsList(count) + " Visit 4: no data", 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        axis off;
    else
        [frequency, power]  =  FilterAndFFT(acceleration);
        % power(1:50)         =   0.1;
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4",frequency);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4",power');
        if (min(frequency) < xLimits(1))
            xLimits(1) = min(frequency);
        end
        if (max(frequency) > xLimits(2))
            xLimits(2) = max(frequency);
        end
        % Shared y range: only the points drawn and visible (first half of the spectrum, frequency inside xLim)
        shown       =  frequency(1:end/2) >= xLim(1) & frequency(1:end/2) <= xLim(2);
        powerShown  =  power(1:end/2);
        powerShown  =  powerShown(shown);
        yLimitsAll  =  [min(yLimitsAll(1), min(powerShown)), max(yLimitsAll(2), max(powerShown))];
        fig1;
        hold on;
        subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, 2, '\bf Visit 4', [], [], [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimits, subjectsList(count));  % all plots superimposed
        subplotNumber = subplotNumber + 1;
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        varName = "\bf Subj " + (matlab.lang.makeValidName(subjectsList(count)));
        varName = strrep(varName, 'E_', ' ');
        if (count == length(subjectsList))
            cloudVolumes(count, 2) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], '\bf Frequency [Hz]', [], [], 1, xLim, yLimits, '', acceleration);
        else
            cloudVolumes(count, 2) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], [], [], [], 1, xLim, yLimits, '', acceleration);
        end
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        box off;
    end


    % visit 7
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7";
    acceleration    =   evalin('base', varName);
    if isempty(acceleration)
        % Visit skipped: keep the grid layout with an empty panel
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7",[]);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7",[]);
        subplotNumber = subplotNumber + 1;
        subplot(length(subjectsList)+1, 3, subplotNumber);
        text(0.5, 0.5, subjectsList(count) + " Visit 7: no data", 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        axis off;
    else
        [frequency, power]  =  FilterAndFFT(acceleration);
        % power(1:50)         =   0.1;
        assignin('base',"freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7",frequency);
        assignin('base',"power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7",power');
        if (min(frequency) < xLimits(1))
            xLimits(1) = min(frequency);
        end
        if (max(frequency) > xLimits(2))
            xLimits(2) = max(frequency);
        end
        % Shared y range: only the points drawn and visible (first half of the spectrum, frequency inside xLim)
        shown       =  frequency(1:end/2) >= xLim(1) & frequency(1:end/2) <= xLim(2);
        powerShown  =  power(1:end/2);
        powerShown  =  powerShown(shown);
        yLimitsAll  =  [min(yLimitsAll(1), min(powerShown)), max(yLimitsAll(2), max(powerShown))];
        fig1;
        hold on;
        subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, 3, '\bf Visit 7', [], [], [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimits, subjectsList(count));  % all plots superimposed
        subplotNumber = subplotNumber + 1;
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        varName = "\bf Subj " + (matlab.lang.makeValidName(subjectsList(count)));
        varName = strrep(varName, 'E_', ' ');
        if (count == length(subjectsList))
            cloudVolumes(count, 3) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], '\bf Frequency [Hz]', [], [], 1, xLim, yLimits, '', acceleration);
        else
            cloudVolumes(count, 3) = subplotWithInsetFunction(frequency(1:length(frequency)/2), power(1:length(power)/2), length(subjectsList)+1, 3, subplotNumber, [], [], [], [], 1, xLim, yLimits, '', acceleration);
        end
        ax(axIndex) = gca;
        axIndex = axIndex + 1;
        box off;
    end

    colorCode     = colorCode + 1;

end


% Same y-axis for every subject and visit. The 3D point-cloud insets (XColor 'none') keep their own limits, and so do
% the hidden "no data" panels (their text would move). ax() can't be used here: after an inset call gca is the inset.
fftAxes = findobj(fig1, 'Type', 'axes', 'Visible', 'on');
fftAxes = fftAxes(~arrayfun(@(a) isequal(a.XColor, 'none'), fftAxes));
set(fftAxes, 'YLim', yLimitsAll);
fprintf('FFT y-axis for all subjects: [%g, %g]\n', yLimitsAll);

% fig1.Title = "Fast Fourier Transform of all the patients";






%% Power Spectral Density analysis

% One-sided PSD of the same filtered signal used for the FFT above (OneSidedPSD, end of the file).
% xLim is the one from the FFT section; one y range for every panel, applied after the loop.
yLimitsPSD    = [Inf, -Inf];
subplotNumber = 4;
colorCode     = 1;

fig2 = figure(2);


for count = 1:length(subjectsList)

    % VISIT 1
    if isempty(evalin('base', "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1"))   % visit skipped
        subplotNumber = subplotNumber + 1;
    else
        varName     =   "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1";
        power_1     =   evalin('base', varName);
        varName     =   "freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1";
        freq_1      =   evalin('base', varName);

        powerSpectrum_1  =   abs(power_1/length(freq_1)).^2;                   % Two-sided power spectrum
        powerSpectrum_1  =   powerSpectrum_1(1:floor(length(freq_1)/2)+1);     % Keep only the positive frequencies
        powerFreq_1      =   freq_1(1:floor(length(freq_1)/2)+1);              % Corresponding frequency vector
    
        % Frequency Bands:     0>freq>1 = rest/slow movements      1>freq>5 = active/functional upper-limb movements
        freq_rest_1    =  find(freq_1 >= 0 & freq_1 <= 1);
        freq_active_1  =  find(freq_1 > 1  & freq_1 <= 5);

        % Compute power in each band
        power_total_1    =   sum(power_1); 
        power_rest_1     =   sum(power_1(freq_rest_1));
        power_active_1   =   sum(power_1(freq_active_1));

        % Relative power
        relativePower_rest_1      =  power_rest_1 / power_total_1;
        relativePower_active_1    =  power_active_1 / power_total_1;

        [f, psd_1]  =   OneSidedPSD(power_1, freq_1, 64);

        % Shared y range: only the points inside xLim
        shown       =  f >= xLim(1) & f <= xLim(2);
        yLimitsPSD  =  [min(yLimitsPSD(1), min(psd_1(shown))), max(yLimitsPSD(2), max(psd_1(shown)))];

        fig2;
        hold on;
        subplotWithInsetFunction(f, psd_1, length(subjectsList)+1, 3, 1, '\bf Visit 1', 'Frequency [Hz]', 'PSD', [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimitsPSD, []);  % all plots superimposed
        varName = "Subj_" + (matlab.lang.makeValidName(subjectsList(count))) + "_Visit1";
        subplotWithInsetFunction(f, psd_1, length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimitsPSD, []);
        box off;
        subplotNumber = subplotNumber + 1;
    end



    % VISIT 4
    if isempty(evalin('base', "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4"))   % visit skipped
        subplotNumber = subplotNumber + 1;
    else
        varName     =   "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4";
        power_4     =   evalin('base', varName);
        varName     =   "freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4";
        freq_4      =   evalin('base', varName);

        [f, psd_4]  =   OneSidedPSD(power_4, freq_4, 64);

        % Shared y range: only the points inside xLim
        shown       =  f >= xLim(1) & f <= xLim(2);
        yLimitsPSD  =  [min(yLimitsPSD(1), min(psd_4(shown))), max(yLimitsPSD(2), max(psd_4(shown)))];

        fig2;
        hold on;
        subplotWithInsetFunction(f, psd_4, length(subjectsList)+1, 3, 2, '\bf Visit 4', 'Frequency [Hz]', 'PSD', [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimitsPSD, []);  % all plots superimposed
        varName = "Subj_" + (matlab.lang.makeValidName(subjectsList(count))) + "_Visit4";
        subplotWithInsetFunction(f, psd_4, length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimitsPSD, []);
        box off;
        subplotNumber = subplotNumber + 1;
    end



    % VISIT 7
    if isempty(evalin('base', "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7"))   % visit skipped
        subplotNumber = subplotNumber + 1;
    else
        varName     =   "power_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7";
        power_7     =   evalin('base', varName);
        varName     =   "freq_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7";
        freq_7      =   evalin('base', varName);

        [f, psd_7]  =   OneSidedPSD(power_7, freq_7, 64);

        % Shared y range: only the points inside xLim
        shown       =  f >= xLim(1) & f <= xLim(2);
        yLimitsPSD  =  [min(yLimitsPSD(1), min(psd_7(shown))), max(yLimitsPSD(2), max(psd_7(shown)))];

        fig2;
        hold on;
        subplotWithInsetFunction(f, psd_7, length(subjectsList)+1, 3, 3, '\bf Visit 7', 'Frequency [Hz]', 'PSD', [], [mod(colorCode - 1, 7) + 1, 0.5], xLim, yLimitsPSD, []);  % all plots superimposed
        varName = "Subj_" + (matlab.lang.makeValidName(subjectsList(count))) + "_Visit7";
        subplotWithInsetFunction(f, psd_7, length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimitsPSD, []);
        box off;
        subplotNumber = subplotNumber + 1;
    end

    colorCode     = colorCode + 1;

end

set(findobj(fig2, 'Type', 'axes'), 'YLim', yLimitsPSD);
fprintf('PSD y-axis for all subjects: [%g, %g]\n', yLimitsPSD);




%% Point-cloud volume (alpha shape)

% Volumes of the figure 1 insets (cloudPointsVolumeAnalysis), in g^3 since the acceleration is in g.
cloudVolumeTable = table(subjectsList', cloudVolumes(:,1), cloudVolumes(:,2), cloudVolumes(:,3), 'VariableNames', {'Subject', 'Visit1', 'Visit4', 'Visit7'});
disp(cloudVolumeTable);

% Treatment between the recordings: V1 -> V4 = first treatment week (visits 2-4), V4 -> V7 = second week (visits 5-7).
% EF first = Data{1}.GroupNumber == 4 in the robot Visit_2 file (same rule as SpeedvsAccuracy_Patients.m), checked for all
% 15 subjects on 2026-10-14. A NEW SUBJECT MUST BE ADDED HERE if it started with EF, otherwise it counts as SHAM first.
% E-47 had V6 EF inside a SHAM week: counted as SHAM (2 of 3 visits).
firstWeekEF      = ismember(subjectsList, ["E-5", "E-21", "E-25", "E-44", "E-47", "E-81"]);
isEFChange       = [firstWeekEF', ~firstWeekEF'];          % columns: V4 - V1, V7 - V4
volumeChange     = [cloudVolumes(:,2) - cloudVolumes(:,1), cloudVolumes(:,3) - cloudVolumes(:,2)];
treatmentColors  = [0.55 0.55 0.55; 0 0 0];                % SHAM gray, EF black (same as DeltaErrorComparison)
treatmentNames   = ["SHAM", "EF"];

fprintf('\nPoint-cloud volume change [g^3]:\n');
for count = 1:length(subjectsList)
    fprintf('  %-6s  V4-V1 = %8.4f (%s)   V7-V4 = %8.4f (%s)\n', subjectsList(count), volumeChange(count, 1), treatmentNames(isEFChange(count, 1) + 1), volumeChange(count, 2), treatmentNames(isEFChange(count, 2) + 1));
end


% Volume per visit: one group per subject, one bar per visit
fig3 = figure(3);
set(fig3, 'WindowState', 'maximized');
volumeBars = bar(cloudVolumes, 'LineWidth', 1.5);
set(gca, 'XTick', 1:length(subjectsList), 'XTickLabel', subjectsList, 'LineWidth', 3, 'FontSize', 20, 'FontWeight', 'bold', 'Box', 'off');
xlabel('\bf Subject', 'FontSize', 22);
ylabel('\bf Volume [g^3]', 'FontSize', 22);
title('Point-cloud volume (alpha shape) per visit', 'FontSize', 25);
legend(volumeBars, ["Visit 1", "Visit 4", "Visit 7"], 'Location', 'northeast', 'Box', 'off');


% Volume change between visits: left bar = V4 - V1, right bar = V7 - V4, colored by the treatment in between
fig4 = figure(4);
set(fig4, 'WindowState', 'maximized');
changeBars = bar(volumeChange, 'FaceColor', 'flat', 'LineWidth', 1.5);
for barCount = 1:2
    changeBars(barCount).CData = treatmentColors(isEFChange(:, barCount) + 1, :);
end
yline(0, 'LineWidth', 2);
set(gca, 'XTick', 1:length(subjectsList), 'XTickLabel', subjectsList, 'LineWidth', 3, 'FontSize', 20, 'FontWeight', 'bold', 'Box', 'off');
xlabel({'\bf Subject', '\rm left bar = Visit 4 - Visit 1,   right bar = Visit 7 - Visit 4'}, 'FontSize', 22);
ylabel('\bf Volume change [g^3]', 'FontSize', 22);
title('Change in point-cloud volume between visits', 'FontSize', 25);
text(0.02, 0.97, 'EF', 'Units', 'normalized', 'Color', treatmentColors(2, :), 'FontSize', 24, 'FontWeight', 'bold');
text(0.02, 0.90, 'SHAM', 'Units', 'normalized', 'Color', treatmentColors(1, :), 'FontSize', 24, 'FontWeight', 'bold');


% EF vs SHAM raincloud, drawn like RainCloudDistributionTwoPhases_Patients (SpeedAccuracyPlots/SpeedvsAccuracy_Patients.m):
% left pair = Visit 4 - Visit 1, right pair = Visit 7 - Visit 4. In each pair the SHAM-first subjects face left and the
% EF-first subjects face right; the color is the treatment of that week (SHAM yellow, Error Field orange, same colors).
% Lines join the two changes of the same subject.
linesOn         = true;                  % false = no lines joining the two changes of the same subject
shamColor       = [0.85, 0.60, 0.10];
efColor         = [0.80, 0.30, 0.05];
lineC           = [0.3 0.3 0.3];
connectColor    = [0.2 0.2 0.2 0.4];
scatterSizeDots = 800;
markerSizeDotMedian = 40;
lineWidthScatter    = 4;
lineWidthBarraNera  = 8;
halfWidth       = 0.35;
centerGap       = 0.03;
labelFontSize   = 50;
startGroup      = {~firstWeekEF', firstWeekEF'};   % 1 = SHAM first (left halves), 2 = EF first (right halves)
startName       = ["SHAM first", "EF first"];
groupSide       = [-1, 1];
dotX            = NaN(length(subjectsList), 2);
cloudHandle     = gobjects(1, 2);                 % one SHAM and one EF cloud for the legend

fig5 = figure(5);
set(fig5, 'WindowState', 'maximized');
hold on;
fprintf('\nVolume change per raincloud [g^3]:\n');
for changeCount = 1:2
    for groupCount = 1:2
        rows    = find(startGroup{groupCount} & ~isnan(volumeChange(:, changeCount)));
        if isempty(rows), continue; end
        values  = volumeChange(rows, changeCount);
        isEF    = isEFChange(rows(1), changeCount);
        color   = shamColor * ~isEF + efColor * isEF;
        side    = groupSide(groupCount);
        edgeX   = changeCount + side * centerGap;
        [cloud, dotX(rows, changeCount)] = DrawHalfViolin(edgeX, values, color, side, halfWidth);
        if ~isempty(cloud), cloudHandle(isEF + 1) = cloud; end
        scatter(dotX(rows, changeCount), values, scatterSizeDots, 'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', color, 'LineWidth', lineWidthScatter);
        quartiles = prctile(values, [25 50 75]);
        plot([edgeX edgeX], quartiles([1 3]), '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(edgeX, quartiles(2), 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor', lineC, 'MarkerSize', markerSizeDotMedian, 'LineWidth', 1.5);
        fprintf('  %-14s %-10s %-4s n = %d, median = %.4f\n', ternaryText(changeCount == 1, "V4 - V1", "V7 - V4"), startName(groupCount), treatmentNames(isEF + 1), numel(values), quartiles(2));
    end
end

% Same subject: its V4 - V1 dot joined to its V7 - V4 dot
if linesOn
    for row = find(all(~isnan(volumeChange), 2))'
        plot(dotX(row, :), volumeChange(row, :), '-', 'Color', connectColor, 'LineWidth', 2);
    end
end

yline(0, '--', 'Color', 'b');
xlim([0.4, 2.6]);
ylabel('Volume change [g^3]', 'FontSize', labelFontSize, 'FontWeight', 'bold');
set(gca, 'XTick', 1:2, 'XTickLabel', {'Visits 1 ↔ 4', 'Visits 4 ↔ 7'}, 'FontSize', labelFontSize, 'FontWeight', 'bold', 'LineWidth', 2, 'Box', 'off', 'Color', 'none');
title('Point-cloud volume change: SHAM vs EF', 'FontSize', 70);
legend([cloudHandle(2), cloudHandle(1)], {'Error Field', 'SHAM'}, 'FontSize', 30, 'Location', 'northeast', 'Box', 'off');
hold off;






% %% Power Spectral Density analysis _ DOESNT WORK
% 
% 
% xLimits = [1000, 1]; % absurd min e max frequencies to then overwrite when a smaller/bigger values is founded (just for plotting axes limits purposes)
% yLimits = [1000, 1]; % same for power of the signal
% % xLim = [0, 20];
% % yLim = [0, 150];
% 
% subplotNumber = 4;
% colorCode     = 1;
% 
% fig2 = figure(2);
% 
% 
% for count = 1:length(subjectsList)
% 
%     % VISIT 1
%     varName     =   "power_" + subjectsList(count) + "_1";
%     power_1     =   evalin('base', varName);
%     varName     =   "freq_" + subjectsList(count) + "_1";
%     freq_1      =   evalin('base', varName);
%     varName     =   "acc_raw_" + subjectsList(count) + "_1";
%     acc_raw_1   =   evalin('base', varName);  
%     N           =   length(acc_raw_1);                % Number of points
%     power_1     =   power_1(1:floor(N/2)+1);          % Take positive frequencies only (maybe not needed because we already halved the FFT)
%     Fs          =   64;
% 
% 
% 
%     % Compute two-sided PSD and scale
%     psd_1 = (1/(Fs*N)) * abs(power_1).^2;
% 
%     % Double the power (except at DC and Nyquist if even length)
%     psd_1(2:end-1) = 2 * psd_1(2:end-1);
% 
%     % Frequency vector  (might be not needed since I already have a frequency vector from the FFT calculation)
%     f = Fs*(0:floor(N/2))/N;
% 
%     if (min(f) < xLimits(1))
%         xLimits(1) = min(f);
%     end
%     if (max(f) > xLimits(2))
%         xLimits(2) = max(f);
%     end
%     if (min(psd_1) < yLimits(1))
%         yLimits(1) = min(psd_1);
%     end
%     if (max(psd_1) > yLimits(2))
%         yLimits(2) = max(psd_1);
%     end
% 
%     fig2;
%     hold on;
%     subplotWithInsetFunction(f(1:length(f)/2), psd_1(1:length(psd_1)/2), length(subjectsList)+1, 3, 1, 'Visit_1', 'Frequency [Hz]', 'PSD', [], colorCode, xLim, yLimits);  % all plots superimposed
%     varName = "Subj_" + subjectsList(count) + "_Visit1";
%     subplotWithInsetFunction(f(1:length(f)/2), psd_1(1:length(psd_1)/2), length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimits);
%     box off;
%     subplotNumber = subplotNumber + 1;
% 
% 
% 
%     % VISIT 4
%     varName     =   "power_" + subjectsList(count) + "_4";
%     power_4     =   evalin('base', varName);
%     varName     =   "freq_" + subjectsList(count) + "_4";
%     freq_4      =   evalin('base', varName);
%     varName     =   "acc_raw_" + subjectsList(count) + "_4";
%     acc_raw_4   =   evalin('base', varName);  
%     N           =   length(acc_raw_4);                % Number of points
%     power_4     =   power_4(1:floor(N/2)+1);          % Take positive frequencies only (maybe not needed because we already halved the FFT)
%     Fs          =   64;
% 
%     % Compute two-sided PSD and scale
%     psd_4 = (1/(Fs*N)) * abs(power_4).^2;
% 
%     % Double the power (except at DC and Nyquist if even length)
%     psd_4(2:end-1) = 2 * psd_4(2:end-1);
% 
%     % Frequency vector  (might be not needed since I already have a frequency vector from the FFT calculation)
%     f = Fs*(0:floor(N/2))/N;
% 
%     if (min(f) < xLimits(1))
%         xLimits(1) = min(f);
%     end
%     if (max(f) > xLimits(2))
%         xLimits(2) = max(f);
%     end
%     if (min(psd_4) < yLimits(1))
%         yLimits(1) = min(psd_4);
%     end
%     if (max(psd_4) > yLimits(2))
%         yLimits(2) = max(psd_4);
%     end
% 
%     fig2;
%     hold on;
%     subplotWithInsetFunction(f(1:length(f)/2), psd_4(1:length(psd_4)/2), length(subjectsList)+1, 3, 1, 'Visit_4', 'Frequency [Hz]', 'PSD', [], colorCode, xLim, yLimits);  % all plots superimposed
%     varName = "Subj_" + subjectsList(count) + "_Visit4";
%     subplotWithInsetFunction(f(1:length(f)/2), psd_4(1:length(psd_4)/2), length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimits);
%     box off;
%     subplotNumber = subplotNumber + 1;
% 
% 
% 
% 
%     % VISIT 7
%     varName     =   "power_" + subjectsList(count) + "_7";
%     power_7     =   evalin('base', varName);
%     varName     =   "freq_" + subjectsList(count) + "_7";
%     freq_7      =   evalin('base', varName);
%     varName     =   "acc_raw_" + subjectsList(count) + "_7";
%     acc_raw_7   =   evalin('base', varName);  
%     N           =   length(acc_raw_7);                % Number of points
%     power_7     =   power_7(1:floor(N/2)+1);          % Take positive frequencies only (maybe not needed because we already halved the FFT)
%     Fs          =   64;
% 
%     % Compute two-sided PSD and scale
%     psd_7 = (1/(Fs*N)) * abs(power_7).^2;
% 
%     % Double the power (except at DC and Nyquist if even length)
%     psd_7(2:end-1) = 2 * psd_7(2:end-1);
% 
%     % Frequency vector  (might be not needed since I already have a frequency vector from the FFT calculation)
%     f = Fs*(0:floor(N/2))/N;
% 
%     if (min(f) < xLimits(1))
%         xLimits(1) = min(f);
%     end
%     if (max(f) > xLimits(2))
%         xLimits(2) = max(f);
%     end
%     if (min(psd_7) < yLimits(1))
%         yLimits(1) = min(psd_7);
%     end
%     if (max(psd_7) > yLimits(2))
%         yLimits(2) = max(psd_7);
%     end
% 
%     fig2;
%     hold on;
%     subplotWithInsetFunction(f(1:length(f)/2), psd_7(1:length(psd_7)/2), length(subjectsList)+1, 3, 1, 'Visit_7', 'Frequency [Hz]', 'PSD', [], colorCode, xLim, yLimits);  % all plots superimposed
%     varName = "Subj_" + subjectsList(count) + "_Visit7";
%     subplotWithInsetFunction(f(1:length(f)/2), psd_7(1:length(psd_7)/2), length(subjectsList)+1, 3, subplotNumber, varName, 'Frequency [Hz]', 'PSD', [], 1, xLim, yLimits);
%     box off;
%     subplotNumber = subplotNumber + 1;
% 
% 
% 
% 
% 
% 
% end



  





%% End









function acceleration = ReadAccBin(visitFolder)
% Acceleration of one visit from its acc.bin: N x 3 raw counts (int16 stored, returned as double), the same as the
% first output of dataStorage in "bin" mode (dataStorage.m, lines 74-76), but without its input dialog.
fileID      =  fopen(fullfile(visitFolder, 'acc.bin'), 'rb');
if fileID == -1
    error('SignalComparison_FFT:cannotOpen', 'Cannot open %s', fullfile(visitFolder, 'acc.bin'));
end
closeFile   =  onCleanup(@() fclose(fileID));
acceleration  =  fread(fileID, [3 inf], 'int16')';   % 1st column = Z axis; 2nd column = X axis; 3rd column = -Y
end


function [freq_range_filtered, power_tot_filtered] = FilterAndFFT(acceleration)

% Denoise and Detrend each axis
acc_x = detrend(wdenoise(double(acceleration(:,1))));
acc_y = detrend(wdenoise(double(acceleration(:,2))));
acc_z = detrend(wdenoise(double(acceleration(:,3))));

% Reconstruct denoised and detrended signal
effective_acc_cleaned = [acc_x, acc_y, acc_z];

% Filter the cleaned signal
[filteredData, ~, ~] = dataFiltering(effective_acc_cleaned, 12, 0.5, 64, 10);

% Get magnitude
% normalizedFilteredData = detrend(vecnorm(filteredData, 2, 2));
normalizedFilteredData = mean(filteredData, 2);


% Apply FFT
[freq_range_filtered, power_tot_filtered] = FastFourierTransf(normalizedFilteredData, 64);
% power_tot_filtered(1) = 0;  % Set DC component to zero for better visualization


end



function [f, psd] = OneSidedPSD(power, freq, fs)
% power = |FFT|^2/N from FastFourierTransf. One-sided PSD = |FFT|^2/(fs*N) = power/fs, doubled except at DC and at
% Nyquist (Nyquist exists only for an even N). Same result as periodogram(x, [], N, fs).
n             =  length(power);
nHalf         =  floor(n/2) + 1;
f             =  freq(1:nHalf);
psd           =  power(1:nHalf) / fs;
lastDoubled   =  nHalf - (mod(n, 2) == 0);
psd(2:lastDoubled)  =  2 * psd(2:lastDoubled);
end



function [cloud, dotX] = DrawHalfViolin(edgeX, values, color, side, halfWidth)
% Half violin (kernel density, ksdensity) starting at edgeX and facing side (-1 left, +1 right), as in
% RainCloudDistributionTwoPhases_Patients. dotX = x of each value inside the cloud; the spread is fixed (no rand), so the
% figure is the same on every run and the subject lines meet the dots.
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


function text = ternaryText(condition, textTrue, textFalse)
if condition, text = textTrue; else, text = textFalse; end
end



function [freq_range, power_tot] = FastFourierTransf(effective_acc_raw, fs)



fn  =  fs/2; % Since only half of the fft is useful, the other half is just the mirrored part
n           =  length(effective_acc_raw);

% create the Fast Fourirer Transform 

% fft_1 = fft(acc_x_direction); 
% fft_2 = fft(acc_y_direction); 
% fft_3 = fft(acc_z_direction); 
fft_effective  =  fft(effective_acc_raw);


freq_range  =  (0:n-1)*(fs/n);  % fs = sampling frequency
% power1      =  abs(fft_1).^2/n;
% power2      =  abs(fft_2).^2/n;
% power3      =  abs(fft_3).^2/n;
power_tot   =  abs(fft_effective).^2/n;




end



% print('FFT_Comparison_E5_E16_E21_AccelerationMean', '-dpng', '-r500')
