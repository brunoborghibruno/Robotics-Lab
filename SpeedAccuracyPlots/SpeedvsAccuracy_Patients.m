%% BRUNO BORGHI - Speed vs Accuracy Patients plot
% When running the program, be sure to have the ".../Dropbox/EA_R01/PostProcessing/MATLAB/SpeedAccuracyPlots" folder open in the Current Folder

close all; clear all; clc;

 %% Select the subjects' ID to be compared


% subjectsList            =   ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28"];
subjectsList            =   ["E-5", "E-16", "E-21", "E-25", "E-26", "E-28", "E-38", "E-42", "E-44", "E-47", "E-56", "E-69", "E-81", "E-91", "E-93"];

% subjectsList    =  ["P-2"];
% EF_First_Group    =   ["E-5", "E-21", "E-25"];

% SHAM_First_Group  =   ["E-16", "E-26", "E-28"];


treatmentVisit  =  ["Visit_1", "Visit_2", "Visit_3", "Visit_4", "Visit_5", "Visit_6", "Visit_7", "Visit_8"];
% treatmentVisit          =   ["Visit_1", "Visit_2", "Visit_3"];

visitsToCompare             =   [treatmentVisit(2), treatmentVisit(5), treatmentVisit(8)];
% visitsToCompare     =   [treatmentVisit(1), treatmentVisit(2), treatmentVisit(3)];


% Every metric listed here is extracted once and stored in the "Error" struct
% under its own field name, so the expensive loading loop below never has to be
% re-run when you change your mind. The metric that is actually plotted is
% picked further down, at the top of the "Calculates all the improved accuracy
% values for every subject" section (variable "errorMetric").
errorMetricsToStore =   ["MaximumErrorAmplitude", "MaximumPerpendicularError"];

typeOfMetric    =   'launch';
% typeOfMetric    =   'entire';


% ── Wrong movement-onset annotation on the EF figure titles ──────────────────
%  Adds "V2 30% | V3 12% | V4 45% bad" next to the title of every ERROR-FIELD
%  figure (the SHAM and the Visit_1-vs-Visit_8 figures are left alone). Each
%  number is the share of intermittent-exposure practiced-direction trials whose
%  onset the robot detected PREMATURELY, i.e. the same quantity the grid in
%  BimodalErrorDistribution/MovementOnsetDetectionAnalysis.m plots.
%  The visits reported are the ones the figure spans, EXCLUDING the closing
%  visit: a Visit_2-vs-Visit_5 figure reports Visit_2, Visit_3 and Visit_4.
%  The rates come from ScanAllVisits(), shared with MovementOnsetDetectionAnalysis.m
%  and re-run from scratch on every run of this script (it is the slow step —
%  it re-derives the MACC onset of every trial of every visit).
SHOW_WRONG_ONSET_IN_TITLE = true;
EF_MOVEMENT_RANGE         = [210 250];   % MovementNumber window used to type a visit EF vs SHAM
% ───────────────────────────────────────────────────────────────────────────


functionsFolder         =   pwd; % it saves the current folder calleed MATLAB where all the programs and data is
initialFolder           =   functionsFolder(1:end-19); 

% Speed thresholds for patients
lowSpeedThreshold       =   0.1976;
highSpeedThreshold      =   0.5138;

redColor                =   [0.6350 0.0780 0.1840]; % not red anymore but brown
blackColor              =   [0 0.3 0.6];            % not black anymore but lavander

% markerList = ['o', 's', '^', 'd', 'x', '+', '*', 'v', '>'];  % Add more if needed
colors                  =   lines(length(subjectsList)); % built-in colormap with distinct colors

xAxisLimits             =   [0, 0.1];
yAxisLimits             =   [10, 0];

scatterSize             =   100;

medianGlobalPosition    =   1; % write to 1 if you want to have the median of all the global position in the rose plots

% system(['xdg-open "', char(fullfile(pwd, subjectsList(count))), '"'])





%% Store the Error metric from all the subjects

dir0_Saved          =   0;
dir1_Saved          =   0;
dir2_Saved          =   0;
dir3_Saved          =   0;
EF_First_Group      =   [];
SHAM_First_Group    =   [];



addpath(initialFolder);
addpath(functionsFolder);

for count = 1:length(subjectsList)

    cd(strcat([initialFolder+"/"+subjectsList(count)]));        % Open the folder with the respective data of that subject

    groupTypeIndex  =   0;

    for index = 1:length(treatmentVisit)

        firstMedianCalculation  =   1;
        load(subjectsList(count) + "_" + treatmentVisit(index) +".mat");

        % if (strcmp((subjectsList(count) + "_" + treatmentVisit(index) +".mat"), "E-56_Visit_6.mat") || strcmp((subjectsList(count) + "_" + treatmentVisit(index) +".mat"), "E-56_Visit_7.mat"))
        %     x = 1;
        % end

        % Assign the treatment_first type
        if groupTypeIndex == 0 && strcmp(treatmentVisit(index), "Visit_2")
            if Data{1}.GroupNumber == 4
                EF_First_Group = [EF_First_Group, subjectsList(count)];
            else
                SHAM_First_Group = [SHAM_First_Group, subjectsList(count)];
            end
            groupTypeIndex  =   1;
        end

        for metricCount = 1:length(errorMetricsToStore)
            thisMetric  =   errorMetricsToStore(metricCount);
            Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).(matlab.lang.makeValidName(thisMetric)).IntermittentExposure    =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, thisMetric, typeOfMetric)'];
        end
        Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).MaxSpeed.IntermittentExposure                                    =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, 'Speed', typeOfMetric)'];

        if (index > 1 && index < 8)
        % if (index > 0 && index < 3)
            AddPostTrainingPhaseIndexToSpecialMovementIndex();       % Temporary function to add the post training error values since they are missing in he saved data until subject E25
            for metricCount = 1:length(errorMetricsToStore)
                thisMetric  =   errorMetricsToStore(metricCount);
                Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).(matlab.lang.makeValidName(thisMetric)).Training        =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, thisMetric, typeOfMetric)'];
                Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).(matlab.lang.makeValidName(thisMetric)).PostTraining    =   [GetErrorVector(SpecialMovementIndex.PostTraining.DirectionZero, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionOne, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionTwo, thisMetric, typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionThree, thisMetric, typeOfMetric)'];
            end
            Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).MaxSpeed.Training                                        =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, 'Speed', typeOfMetric)'];
            Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).MaxSpeed.PostTraining                                    =   [GetErrorVector(SpecialMovementIndex.PostTraining.DirectionZero, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionOne, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionTwo, 'Speed', typeOfMetric)', GetErrorVector(SpecialMovementIndex.PostTraining.DirectionThree, 'Speed', typeOfMetric)'];
        end

        if (medianGlobalPosition == 1)
            % Store the first value and then skip this for all the successive trials
            if (firstMedianCalculation  ==   1)
                % Intermittent Exposure
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionZero(1)}.GlobalPosition;
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionOne(1)}.GlobalPosition;
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionTwo(1)}.GlobalPosition;
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionThree(1)}.GlobalPosition;
                if (index > 1 && index < 8)
                % if (index > 0 && index < 3)
                    % Training
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0               =   Data{SpecialMovementIndex.PureTraining.DirectionZero(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1               =   Data{SpecialMovementIndex.PureTraining.DirectionOne(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2               =   Data{SpecialMovementIndex.PureTraining.DirectionTwo(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3               =   Data{SpecialMovementIndex.PureTraining.DirectionThree(1)}.GlobalPosition;
                end
                if (index > 1 && index < 8)
                % if (index > 0 && index < 3)
                    % Post Training
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0           =   Data{SpecialMovementIndex.PostTraining.DirectionZero(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1           =   Data{SpecialMovementIndex.PostTraining.DirectionOne(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2           =   Data{SpecialMovementIndex.PostTraining.DirectionTwo(1)}.GlobalPosition;
                    GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3           =   Data{SpecialMovementIndex.PostTraining.DirectionThree(1)}.GlobalPosition;
                end
                firstMedianCalculation  =   0;
            end


            % Intermittent Exposure

            %%%%%%%%%%%% DIRECTION 0
            % Preallocate a cell to collect all the GlobalPosition data
            allPos = {};

            % 1. Loop through all movement numbers and collect GlobalPosition
            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionZero]'
                thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
                allPos{end+1} = thisPos;
            end

            % 2. Find the maximum number of rows (trajectory length)
            maxLen = max(cellfun(@(x) size(x, 1), allPos));

            % 3. Pad all trajectories to max length using the last value
            for i = 1:length(allPos)
                traj = allPos{i};
                padSize = maxLen - size(traj, 1);
                if padSize > 0
                    pad = repmat(traj(end, :), padSize, 1);  % replicate last row
                    traj = [traj; pad];
                end
                allPos{i} = traj;  % update
            end

            % 4. Concatenate into a 3D array (time x 3 x repetitions)
            allData = cat(3, allPos{:});  % size: (maxLen x 3 x numMovements)

            % 5. Compute standard deviation across trials (3rd dimension)
            stdPos = std(allData, 0, 3, 'omitnan');  % size: (maxLen x 3)
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0_StDeviation = stdPos;

            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionZero]'

                if (dir0_Saved == 0 && Data{movementNumber}.MovementDirection == 0)
                    GlobalPosition.IdealTrajectory_Dir0 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                    dir0_Saved                          = 1;
                end

                % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0 = median(cat(3, oldPos, newPos), 3);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
            end



            %%%%%%%%%%%% DIRECTION 1
            % Preallocate a cell to collect all the GlobalPosition data
            allPos = {};

            % 1. Loop through all movement numbers and collect GlobalPosition
            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionOne]'
                thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
                allPos{end+1} = thisPos;
            end

            % 2. Find the maximum number of rows (trajectory length)
            maxLen = max(cellfun(@(x) size(x, 1), allPos));

            % 3. Pad all trajectories to max length using the last value
            for i = 1:length(allPos)
                traj = allPos{i};
                padSize = maxLen - size(traj, 1);
                if padSize > 0
                    pad = repmat(traj(end, :), padSize, 1);  % replicate last row
                    traj = [traj; pad];
                end
                allPos{i} = traj;  % update
            end

            % 4. Concatenate into a 3D array (time x 3 x repetitions)
            allData = cat(3, allPos{:});  % size: (maxLen x 3 x numMovements)

            % 5. Compute standard deviation across trials (3rd dimension)
            stdPos = std(allData, 0, 3, 'omitnan');  % size: (maxLen x 3)
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1_StDeviation = stdPos;
            
            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionOne]'

                if (dir1_Saved == 0 && Data{movementNumber}.MovementDirection == 1)
                    GlobalPosition.IdealTrajectory_Dir1 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                    dir1_Saved                          = 1;
                end

                % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1 = median(cat(3, oldPos, newPos), 3);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
            end



            %%%%%%%%%%%% DIRECTION 2
            % Preallocate a cell to collect all the GlobalPosition data
            allPos = {};

            % 1. Loop through all movement numbers and collect GlobalPosition
            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionTwo]'
                thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
                allPos{end+1} = thisPos;
            end

            % 2. Find the maximum number of rows (trajectory length)
            maxLen = max(cellfun(@(x) size(x, 1), allPos));

            % 3. Pad all trajectories to max length using the last value
            for i = 1:length(allPos)
                traj = allPos{i};
                padSize = maxLen - size(traj, 1);
                if padSize > 0
                    pad = repmat(traj(end, :), padSize, 1);  % replicate last row
                    traj = [traj; pad];
                end
                allPos{i} = traj;  % update
            end

            % 4. Concatenate into a 3D array (time x 3 x repetitions)
            allData = cat(3, allPos{:});  % size: (maxLen x 3 x numMovements)

            % 5. Compute standard deviation across trials (3rd dimension)
            stdPos = std(allData, 0, 3, 'omitnan');  % size: (maxLen x 3)
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2_StDeviation = stdPos;

            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionTwo]'

                if (dir2_Saved == 0 && Data{movementNumber}.MovementDirection == 2)
                    GlobalPosition.IdealTrajectory_Dir2 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                    dir2_Saved                          = 1;
                end

                % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2 = median(cat(3, oldPos, newPos), 3);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
            end



            %%%%%%%%%%%% DIRECTION 3

            % Preallocate a cell to collect all the GlobalPosition data
            allPos = {};

            % 1. Loop through all movement numbers and collect GlobalPosition
            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionThree]'
                thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
                allPos{end+1} = thisPos;
            end

            % 2. Find the maximum number of rows (trajectory length)
            maxLen = max(cellfun(@(x) size(x, 1), allPos));

            % 3. Pad all trajectories to max length using the last value
            for i = 1:length(allPos)
                traj = allPos{i};
                padSize = maxLen - size(traj, 1);
                if padSize > 0
                    pad = repmat(traj(end, :), padSize, 1);  % replicate last row
                    traj = [traj; pad];
                end
                allPos{i} = traj;  % update
            end

            % 4. Concatenate into a 3D array (time x 3 x repetitions)
            allData = cat(3, allPos{:});  % size: (maxLen x 3 x numMovements)

            % 5. Compute standard deviation across trials (3rd dimension)
            stdPos = std(allData, 0, 3, 'omitnan');  % size: (maxLen x 3)
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3_StDeviation = stdPos;

            for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionThree]'

                if (dir3_Saved == 0 && Data{movementNumber}.MovementDirection == 3)
                GlobalPosition.IdealTrajectory_Dir3 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir3_Saved                          = 1;
                end

                % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3 = median(cat(3, oldPos, newPos), 3);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
            end
               
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rest of the experiment visit (no Baseline/PostEvaluation/FollowUp visits) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (index > 1 && index < 8)
            % if (index > 0 && index < 3)
                % Training
                for movementNumber = [SpecialMovementIndex.PureTraining.DirectionZero]'
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir0(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PureTraining.DirectionOne]'
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir1(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PureTraining.DirectionTwo]'
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir2(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PureTraining.DirectionThree]'
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).Training.Dir3(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                % Post Training
                for movementNumber = [SpecialMovementIndex.PostTraining.DirectionZero(:).']
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir0(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PostTraining.DirectionOne(:).']
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir1(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PostTraining.DirectionTwo(:).']
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir2(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
                for movementNumber = [SpecialMovementIndex.PostTraining.DirectionThree(:).']
                    % Extract current data
                oldPos = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3;
                newPos = Data{movementNumber}.GlobalPosition;

                % Find lengths
                lenOld = size(oldPos, 1);
                lenNew = size(newPos, 1);
                targetLen = max(size(oldPos, 1), size(newPos, 1));

                % Pad oldPos if needed
                if lenOld < targetLen
                    padding = repmat(oldPos(end, :), targetLen - lenOld, 1);
                    oldPos = [oldPos; padding];
                end

                % Pad newPos if needed
                if lenNew < targetLen
                    padding = repmat(newPos(end, :), targetLen - lenNew, 1);
                    newPos = [newPos; padding];
                end

                % Compute median
                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3 = median(cat(3, oldPos, newPos), 3);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
                    % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).PostTraining.Dir3(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
                end
            end
        end
    end

    cd(initialFolder);

end






% The subject loop above left pwd on initialFolder, and the current folder wins
% over the path: the root copy of SpeedAccuracyCupolasSubplotMinimal.m (older
% signature, no xLimits/yLimits) would shadow the one in this folder.
cd(functionsFolder);

%% Calculates all the improved accuracy values for every subject

% ---- Choose here which of the stored metrics is plotted from now on --------
% Both metrics are already inside "Error", so you can switch this line and
% re-run only from this section downwards (Ctrl+Enter) - no reloading needed.
errorMetric     =   "MaximumErrorAmplitude";
% errorMetric     =   "MaximumPerpendicularError";

if ~ismember(errorMetric, errorMetricsToStore)
    error("errorMetric '%s' was not stored. Add it to errorMetricsToStore and re-run the loading section.", errorMetric);
end
% ---------------------------------------------------------------------------

% ── Wrong movement-onset rates that annotate the EF titles ───────────────────
% ScanAllVisits() takes an absolute base path and does not touch pwd, so it is
% safe to call here, after the cd(functionsFolder) above. It sets the global
% Data while it works; every GetErrorVector call of the loading section is long
% finished by now, so nothing downstream is disturbed.
onsetResults = [];
if SHOW_WRONG_ONSET_IN_TITLE
    fprintf('\nScanning the movement-onset detection of every visit (slow step)...\n');
    onsetResults = ScanAllVisits(initialFolder, cellstr(subjectsList), EF_MOVEMENT_RANGE, false);
end
% ───────────────────────────────────────────────────────────────────────────

ImprovedAccuracyComparison  =   ["Treatment_1_vs_4_SHAM", "Treatment_1_vs_4_EF", "Visit_1_vs_8"];
% ForceOnComparison   =   ["ImprovedAccuracyForceOn", "ImprovedAccuracyForceOff", "ImprovedAccuracyBaselineIntermExp"];
% directionsToCompare =   ["Dir0", "Dir1", "Dir2", "Dir3"];
xLines              =   [lowSpeedThreshold, highSpeedThreshold];
axesHandlesIndex    =   1;
allMainAxes         =   [];
% first20MovementsOfIntermExp = 1;
% idealTrajectory0    =   [];
% idealTrajectory1    =   [];
% idealTrajectory2    =   [];
% idealTrajectory3    =   [];
maxError                =   0;
minError                =   100;
maxSpeed                =   0;
minSpeed                =   100;
baselineRegressionLineX =   [];
baselineRegressionLineY =   [];
graphCount              =   1;
firstTimeEF             =   0;
firstTimeEA             =   0;
firstTimeCONTROL        =   0;
% rowNumber = round(length(subjectsList)/2);
% colNumber = round(length(subjectsList)/2);
rowNumber               =   2;
colNumber               =   1;


% Random global pos - we just need them as input to the function plot
EF_globalPos_IntermittentExp_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0(1,:);
EF_globalPos_IntermittentExp_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1(1,:);
EF_globalPos_IntermittentExp_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2(1,:);
EF_globalPos_IntermittentExp_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3(1,:);

EF_globalStd_IntermittentExp_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0(1,:);
EF_globalStd_IntermittentExp_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1(1,:);
EF_globalStd_IntermittentExp_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2(1,:);
EF_globalStd_IntermittentExp_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3(1,:);

EF_globalPos_PostTraining_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0(1,:);
EF_globalPos_PostTraining_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1(1,:);
EF_globalPos_PostTraining_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2(1,:);
EF_globalPos_PostTraining_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3(1,:);

EF_globalStd_PostTraining_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir0(1,:);
EF_globalStd_PostTraining_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir1(1,:);
EF_globalStd_PostTraining_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir2(1,:);
EF_globalStd_PostTraining_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).(matlab.lang.makeValidName(visitsToCompare(1))).IntermittentExposure.Dir3(1,:);

idealTrajectory0                =   GlobalPosition.IdealTrajectory_Dir0 - GlobalPosition.IdealTrajectory_Dir0(1,:);
idealTrajectory1                =   GlobalPosition.IdealTrajectory_Dir1 - GlobalPosition.IdealTrajectory_Dir1(1,:);
idealTrajectory2                =   GlobalPosition.IdealTrajectory_Dir2 - GlobalPosition.IdealTrajectory_Dir2(1,:);
idealTrajectory3                =   GlobalPosition.IdealTrajectory_Dir3 - GlobalPosition.IdealTrajectory_Dir3(1,:);



errorVector =   [];
speedVector =   [];
% Collect Max e Min for Error and Speed
for count = [subjectsList]
    for counter = [visitsToCompare]
        errorVector =   [errorVector, Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure];
        speedVector =   [speedVector, Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure];
        if max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure) > maxError
            maxError = max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);
        end
        if min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure) < minError
            minError = min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);
        end
        if max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure) > maxSpeed
            maxSpeed = max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure);
        end
        if min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure) < minSpeed
            minSpeed = min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure);
        end
    end

end


% filteredError = removeOutliers(errorVector, 90);
% filteredSpeed = removeOutliers(speedVector, 90);

% Collect the precentiles for both Error and Speed for the outliers removal
error_lower_bound = prctile(errorVector, 10);    % for example 10%
error_upper_bound = prctile(errorVector, 90);   % for example 90%

speed_lower_bound = prctile(speedVector, 10);    % for example 10%
speed_upper_bound = prctile(speedVector, 90);   % for example 90%




for count = [subjectsList]
        for counter = [visitsToCompare]
            % filter and normalize error
            errorToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure;
            speedToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).MaxSpeed.IntermittentExposure;

            % [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, minError, maxError, speedToFilter, minSpeed, maxSpeed, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound);
            normalizedError = errorToFilter;
            normalizedSpeed = speedToFilter;

            SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).Error = normalizedError;
            SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(counter)).Speed = normalizedSpeed;
        end
end

% xLines   =   normalizeData(xLines, minSpeed, maxSpeed);

xLimits = [speed_lower_bound, speed_upper_bound];
yLimits = [error_lower_bound, error_upper_bound];




%% Draw the per-subject Speed vs Accuracy figures

% Re-runnable on its own (Ctrl+Enter) once the section above has run: it only
% reads SingleSubjectProcessedData, onsetResults and the EF_globalPos_* inputs,
% all of which stay in the workspace. In particular it does NOT repeat the
% movement-onset scan, so the EF titles keep the percentages already computed.
% The two counters are reset here so a re-run redraws from figure 1 instead of
% appending to the handles of the previous run.
graphCount      =   1;
allMainAxes     =   [];

for count = subjectsList

    % Visit_4 vs Visit_1 SHAM TREATMENT
    if ismember(count, EF_First_Group)

        % Treatment_Sham_1 vs Treatment_Sham_4 plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ImprovedAccuracyComparison(1))) = improvedAccuracy;

        % Treatment_EF_1 vs Treatment_EF_4 plots
        % Title of the ERROR-FIELD figure: 'Error Field' plus the wrong-onset rate of
        % each treatment visit this comparison spans, the closing visit excluded.
        efTitle = ['Error Field' WrongOnsetTitleSuffix(onsetResults, char(count), ...
                                                       VisitNumberFromName(visitsToCompare(1)), ...
                                                       VisitNumberFromName(visitsToCompare(2)))];
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Error, rowNumber, colNumber, 1, efTitle, 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Error, rowNumber, colNumber, 1, efTitle, 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ImprovedAccuracyComparison(2))) = improvedAccuracy;

    else

        % Treatment_Sham_1 vs Treatment_Sham_4 plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ImprovedAccuracyComparison(1))) = improvedAccuracy;

        % Treatment_EF_1 vs Treatment_EF_4 plots
        % Title of the ERROR-FIELD figure: 'Error Field' plus the wrong-onset rate of
        % each treatment visit this comparison spans, the closing visit excluded.
        efTitle = ['Error Field' WrongOnsetTitleSuffix(onsetResults, char(count), ...
                                                       VisitNumberFromName(visitsToCompare(2)), ...
                                                       VisitNumberFromName(visitsToCompare(3)))];
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(2))).Error, rowNumber, colNumber, 1, efTitle, 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Error, rowNumber, colNumber, 1, efTitle, 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ImprovedAccuracyComparison(2))) = improvedAccuracy;

    end

    % Visit_1 vs Visit_8 plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(visitsToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ImprovedAccuracyComparison(3))) = improvedAccuracy;





end


%% ALL SUBJECTS single plot - Speed vs Accuracy (1/MaxPerpError) - Baseline (PRE) vs Baseline (POST) 

IntermittentExposure_Baseline_MaxErrorAmp = [];
IntermittentExposure_Baseline_Speed = [];
IntermittentExposure_PostEvaluation_MaxErrorAmp = [];
IntermittentExposure_PostEvaluation_Speed = [];

for count = 1:length(subjectsList)
    IntermittentExposure_Baseline_MaxErrorAmp    =   [IntermittentExposure_Baseline_MaxErrorAmp,  Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(1)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure];
    IntermittentExposure_Baseline_Speed          =   [IntermittentExposure_Baseline_Speed,  Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(1)).MaxSpeed.IntermittentExposure];
end

for count = 1:length(subjectsList)
    IntermittentExposure_PostEvaluation_MaxErrorAmp   =   [IntermittentExposure_PostEvaluation_MaxErrorAmp,  Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(end)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure];
    IntermittentExposure_PostEvaluation_Speed         =   [IntermittentExposure_PostEvaluation_Speed,  Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(end)).MaxSpeed.IntermittentExposure];
end


% Remove outliers and NaN to allow polyfit to work

% [IntermittentExposure_Baseline_MaxErrorAmp, indexesBaseline]    = rmoutliers(IntermittentExposure_Baseline_MaxErrorAmp);
% goodIndexesBaseline                                             = find(~indexesBaseline);
% IntermittentExposure_Baseline_Speed                     = IntermittentExposure_Baseline_Speed(goodIndexesBaseline);
% 
% [IntermittentExposure_PostEvaluation_MaxErrorAmp, indexesPostEvaluation]  = rmoutliers(IntermittentExposure_PostEvaluation_MaxErrorAmp);
% goodIndexesPostEvaluation                                                 = find(~indexesPostEvaluation);
% IntermittentExposure_PostEvaluation_Speed                   = IntermittentExposure_PostEvaluation_Speed(goodIndexesPostEvaluation);

finiteIndexes_Baseline                      =   isfinite(IntermittentExposure_Baseline_MaxErrorAmp);
IntermittentExposure_Baseline_MaxErrorAmp   =   IntermittentExposure_Baseline_MaxErrorAmp(finiteIndexes_Baseline);
IntermittentExposure_Baseline_Speed         =   IntermittentExposure_Baseline_Speed(finiteIndexes_Baseline);  

finiteIndexes_PostEvaluation                    =   isfinite(IntermittentExposure_PostEvaluation_MaxErrorAmp);
IntermittentExposure_PostEvaluation_MaxErrorAmp =   IntermittentExposure_PostEvaluation_MaxErrorAmp(finiteIndexes_PostEvaluation);
IntermittentExposure_PostEvaluation_Speed       =   IntermittentExposure_PostEvaluation_Speed(finiteIndexes_PostEvaluation);

% Logarithmic scale

IntermittentExposure_Baseline_MaxErrorAmp       = log(1./IntermittentExposure_Baseline_MaxErrorAmp);
IntermittentExposure_PostEvaluation_MaxErrorAmp = log(1./IntermittentExposure_PostEvaluation_MaxErrorAmp);
% IntermittentExposure_Baseline_MaxErrorAmp = 1./IntermittentExposure_Baseline_MaxErrorAmp;
% IntermittentExposure_PostEvaluation_MaxErrorAmp = 1./IntermittentExposure_PostEvaluation_MaxErrorAmp;

% Perform linear regression on combined Baseline data
baselineCoeff           =   polyfit(IntermittentExposure_Baseline_Speed, IntermittentExposure_Baseline_MaxErrorAmp, 1);
postEvaluationCoeff     =   polyfit(IntermittentExposure_PostEvaluation_Speed, IntermittentExposure_PostEvaluation_MaxErrorAmp, 1);

% Define the range of speeds for plotting the fit line
speedRangeBaseline          =   linspace(min(IntermittentExposure_Baseline_Speed), max(IntermittentExposure_Baseline_Speed), 100);
speedRangePostEvaluation    =   linspace(min(IntermittentExposure_PostEvaluation_Speed), max(IntermittentExposure_PostEvaluation_Speed), 100);

% Evaluate the linear fit across the speed range
baselineFitLine         =   polyval(baselineCoeff, speedRangeBaseline);
postEvaluationFitLine   =   polyval(postEvaluationCoeff, speedRangePostEvaluation);






fig = figure;
set(fig, 'WindowState', 'maximized');
annotation('textbox', [0.25, 1, 0.5, 0], 'String', 'Subjects: ' +strjoin(subjectsList, ', '), 'FontSize', 25, 'FontWeight', 'bold', 'Color', [0, 0, 0], 'HorizontalAlignment', 'center', 'EdgeColor', 'none'); % PRE in black

hold on;
% set(gca, 'XColor', 'none');

legendHandles = gobjects(length(subjectsList), 1);  % Preallocate (Baseline and Post)
legendLabels = strings(length(subjectsList), 1);

for count = 1:length(subjectsList)
    
    subjectName                 =   matlab.lang.makeValidName(subjectsList(count));
    % markerShape                 =   markerList(mod(count-1, length(markerList)) + 1);
    colorNow = colors(count, :);  % get subject-specific color


    % Plot Baseline
    x_baseline                  =   Error.(subjectName).(treatmentVisit(1)).MaxSpeed.IntermittentExposure;
    y_baseline                  =   log(1 ./ Error.(subjectName).(treatmentVisit(1)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);
    % scatter(x_baseline, y_baseline, scatterSize, 'filled', 'MarkerFaceColor', blackColor, 'Marker', markerShape);
    scatter(x_baseline, y_baseline, scatterSize, 'filled', 'MarkerFaceColor', colorNow, 'MarkerEdgeColor', 'none');

    % Plot PostEvaluation data
    xData = Error.(subjectName).(treatmentVisit(end)).MaxSpeed.IntermittentExposure;
    yData = log(1 ./ Error.(subjectName).(treatmentVisit(end)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);

    h = scatter(xData, yData, 60, 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', colorNow, 'LineWidth', 3);
    legendHandles(count) = h;
    legendLabels(count) = subjectsList(count);
end


legendObj = legend(legendHandles, legendLabels, 'Location', 'bestoutside', 'Color',[0, 0, 0]);
legendObj.Title.String = 'Subjects';
legendObj.FontSize = 20;
legendObj.BackgroundAlpha = 0;

% Make legend box bigger by modifying its Position [left, bottom, width, height]
hLegend.FontSize = 14;
hLegend.Units = 'normalized'; % Use normalized units for easier control
hLegend.Position = [0.75, 0.2, 0.8, 0.6];  % Adjust these values as needed
% legendObj.AutoUpdate = 'off';

plot(NaN, NaN, '-', 'Color', [0, 0, 0], 'LineWidth', 2, 'DisplayName', 'Baseline Fit');
plot(NaN, NaN, '--', 'Color', [0, 0, 0], 'LineWidth', 2, 'DisplayName', 'PostEvaluation Fit');
legendObj.AutoUpdate = 'off';
% for count = 1:length(subjectsList)
%     subjName = matlab.lang.makeValidName(subjectsList(count));
%     marker = markerList(mod(count - 1, length(markerList)) + 1);  % Reuse markers if more subjects than shapes
% 
%     if count == 1  % First subject uses filled style
%         scatter(Error.(subjName).(treatmentVisit(1)).MaxSpeed.IntermittentExposure, log(1 ./ Error.(subjName).(treatmentVisit(1)).MaxErrorAmp.IntermittentExposure), 60, marker, 'filled', 'MarkerFaceColor', blackColor);
%         scatter(Error.(subjName).(treatmentVisit(8)).MaxSpeed.IntermittentExposure, log(1 ./ Error.(subjName).(treatmentVisit(8)).MaxErrorAmp.IntermittentExposure), 60, marker, 'filled', 'MarkerFaceColor', redColor);
%     else
%         scatter(Error.(subjName).(treatmentVisit(1)).MaxSpeed.IntermittentExposure, log(1 ./ Error.(subjName).(treatmentVisit(1)).MaxErrorAmp.IntermittentExposure), 60, marker, 'MarkerEdgeColor', blackColor, 'LineWidth', 1.5);
%         scatter(Error.(subjName).(treatmentVisit(8)).MaxSpeed.IntermittentExposure, log(1 ./ Error.(subjName).(treatmentVisit(8)).MaxErrorAmp.IntermittentExposure), 60, marker, 'MarkerEdgeColor', redColor, 'LineWidth', 1.5);
%     end
% 
% end

% legendEntries = strcat("Subject ", subjectsList);
% leg = legend(legendEntries, 'Location', 'bestoutside');
% leg.AutoUpdate = 'off';

% scatter(IntermittentExposure_Baseline_Speed, IntermittentExposure_Baseline_MaxErrorAmp, 60, 'filled', 'MarkerFaceColor', blackColor); % Baseline Visit
% scatter(IntermittentExposure_PostEvaluation_Speed, IntermittentExposure_PostEvaluation_MaxErrorAmp, 60, 'filled', 'MarkerFaceColor', redColor);  % PostEvaluation visit

% Plot the fit line on top of the scatter plot
plot(speedRangeBaseline, baselineFitLine, '-', 'Color', [0, 0, 0], 'LineWidth', 5, 'DisplayName', 'Baseline Fit');
plot(speedRangePostEvaluation, postEvaluationFitLine, '--', 'Color', [0, 0, 0], 'LineWidth', 5, 'DisplayName', 'PostEvaluation Fit');

set(gca,'FontSize',15);
set(gca, 'color', 'none'); 
set(gca, 'box', 'off');
% set(gca, 'Color', 'w');
% set(gcf, 'Color', 'w');
% Adjust x-axis ticks to include threshold values
xticks([0.1, lowSpeedThreshold, highSpeedThreshold, 0.6]);

xlabel('Speed [m/s]', 'FontSize', 20, 'FontWeight','bold');
axisThickness = gca;
axisThickness.FontWeight = 'bold';     
ylabel('Accuracy (1/'+errorMetric+")", 'FontSize', 20, 'FontWeight','bold');
xLine5 = xline(highSpeedThreshold, '--', 'Fast Feedback', 'LabelHorizontalAlignment','center','LabelVerticalAlignment','top', 'FontSize',25,'Color','k');
xLine5.LineWidth = 2;
xLine6 = xline(lowSpeedThreshold, '--', 'Slow Feedback', 'LabelHorizontalAlignment','center','LabelVerticalAlignment','top', 'FontSize',25,'Color','k');
xLine6.LineWidth = 2;

% Annotate labels for each line towards the origin
text(0.005, baselineCoeff(1) * 0 + baselineCoeff(2) + 0.2, 'First Visit', 'Color', [0, 0, 0], 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
text(0.005, postEvaluationCoeff(1) * 0 + postEvaluationCoeff(2) + 0.4, 'Last Visit', 'Color', [0, 0, 0], 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');



%% Copulas distribution plot and analysis

% Two figures are produced, identical in structure, only the pair of visits being
% compared changes: the first one is Visit_2 (baseline) vs Visit_5 (post
% evaluation), the second one Visit_5 (baseline) vs Visit_8 (post evaluation).
% Each row of copulaVisitPairs is [baselineVisit, postEvaluationVisit].
copulaVisitPairs    =   [treatmentVisit(2), treatmentVisit(5); treatmentVisit(5), treatmentVisit(8)];

for pairCount = 1:size(copulaVisitPairs, 1)

visitsPair          =   copulaVisitPairs(pairCount, :);

fig = figure;
set(fig, 'WindowState', 'maximized');
set(fig, 'Name', char(strrep(visitsPair(1), '_', ' ') + " vs " + strrep(visitsPair(2), '_', ' ')));
% visitsToCompare     =   [treatmentVisit(1), treatmentVisit(8)];
xLines              =   [lowSpeedThreshold, highSpeedThreshold];
axesHandlesIndex    =   1;
allMainAxes         =   [];
idealTrajectory0    =   [];
idealTrajectory1    =   [];
idealTrajectory2    =   [];
idealTrajectory3    =   [];
maxX                =    0;
maxY                =    0;
maxError                =   0;
minError                =   100;
maxSpeed                =   0;
minSpeed                =   100;
baselineRegressionLineX =   [];
baselineRegressionLineY =   [];
phaseToCompare     =    "IntermittentExposure";
colNumber = round(length(subjectsList)/2);
rowNumber = 2;
% colNumber = round(length(subjectsList)/2);
% rowNumber = 2;
% colNumber = 3;


errorVector =   [];
speedVector =   [];
% Collect Max e Min for Error and Speed
for count = subjectsList
    for counter = visitsPair
        errorVector =   [errorVector, Error.(matlab.lang.makeValidName(count)).(counter).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToCompare))];

        speedVector =   [speedVector, Error.(matlab.lang.makeValidName(count)).(counter).MaxSpeed.(matlab.lang.makeValidName(phaseToCompare))];

        if max(Error.(matlab.lang.makeValidName(count)).(counter).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToCompare))) > maxError
            maxError = max(Error.(matlab.lang.makeValidName(count)).(counter).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToCompare)));
        end
        if min(Error.(matlab.lang.makeValidName(count)).(counter).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToCompare))) < minError
            minError = min(Error.(matlab.lang.makeValidName(count)).(counter).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToCompare)));
        end
        if max(Error.(matlab.lang.makeValidName(count)).(counter).MaxSpeed.(matlab.lang.makeValidName(phaseToCompare))) > maxSpeed
            maxSpeed = max(Error.(matlab.lang.makeValidName(count)).(counter).MaxSpeed.(matlab.lang.makeValidName(phaseToCompare)));
        end
        if min(Error.(matlab.lang.makeValidName(count)).(counter).MaxSpeed.(matlab.lang.makeValidName(phaseToCompare))) < minSpeed
            minSpeed = min(Error.(matlab.lang.makeValidName(count)).(counter).MaxSpeed.(matlab.lang.makeValidName(phaseToCompare)));
        end
    end
end

% Collect the precentiles for both Error and Speed for the outliers removal
error_lower_bound = prctile(errorVector, 10);    % for example 10%
error_upper_bound = prctile(errorVector, 90);   % for example 90%

speed_lower_bound = prctile(speedVector, 10);    % for example 10%
speed_upper_bound = prctile(speedVector, 90);   % for example 90%

xLimits = [speed_lower_bound, speed_upper_bound];
yLimits = [error_lower_bound, error_upper_bound];

% Which treatment each group received over the block being compared. EF_First_Group
% is built from the Visit_2 GroupNumber, so those subjects trained with the Error
% Field over the first block (Visit_2 -> Visit_5) and with SHAM over the second one
% (Visit_5 -> Visit_8); the SHAM-first subjects are the mirror image. The block is
% identified by the visit it starts from, not by the loop counter.
if (strcmp(visitsPair(1), treatmentVisit(2)))    % first treatment block
    EF_First_Group_Label    =   "EF";
    SHAM_First_Group_Label  =   "SHAM";
else                                             % second treatment block
    EF_First_Group_Label    =   "SHAM";
    SHAM_First_Group_Label  =   "EF";
end

for count = 1:length(subjectsList)
    % The panel title reports the treatment received over this block, not the subject ID
    if (ismember(subjectsList(count), EF_First_Group))
        panelTitle  =   EF_First_Group_Label;
    else
        panelTitle  =   SHAM_First_Group_Label;
    end

    % Same annotation as the per-subject figures, on the EF panels only: the
    % wrong-onset rate of each treatment visit this block spans, the closing
    % visit excluded (Visit_2 vs Visit_5 -> Visit_2, Visit_3, Visit_4). The
    % compact style is used because a 2 x 7 panel cannot hold the labelled one.
    % SHAM panels keep their plain title.
    if (strcmp(panelTitle, "EF"))
        panelTitle  =   panelTitle + string(WrongOnsetTitleSuffix(onsetResults, ...
                            char(subjectsList(count)), ...
                            VisitNumberFromName(visitsPair(1)), ...
                            VisitNumberFromName(visitsPair(2)), 'compact'));
    end
    for index = 1:length(treatmentVisit)
        xTemp               =   Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).MaxSpeed.IntermittentExposure;
        yTemp               =   Error.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure;
        % Logical indices: true for good values
        isOutlierX = isoutlier(xTemp);
        isOutlierY = isoutlier(yTemp);

        % Combine to remove any point that is an outlier in either x or y
        validIdx = ~(isOutlierX | isOutlierY);

        % Apply to both vectors
        x = xTemp(validIdx);
        y = yTemp(validIdx);
        % Store values for the rose plots
        globalPos_Dir0          =   (GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(1,:));
        globalPos_Dir1          =   (GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1(1,:));
        globalPos_Dir2          =   (GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2(1,:));
        globalPos_Dir3          =   (GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3(1,:));
        globalStDeviation_Dir0  =   GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0_StDeviation;
        globalStDeviation_Dir1  =   GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir1_StDeviation;
        globalStDeviation_Dir2  =   GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir2_StDeviation;
        globalStDeviation_Dir3  =   GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir3_StDeviation;
        idealTrajectory0        =   [0, 0, 0; GlobalPosition.IdealTrajectory_Dir0(2,:) - GlobalPosition.IdealTrajectory_Dir0(1,:)]; 
        idealTrajectory1        =   [0, 0, 0; GlobalPosition.IdealTrajectory_Dir1(2,:) - GlobalPosition.IdealTrajectory_Dir1(1,:)];
        idealTrajectory2        =   [0, 0, 0; GlobalPosition.IdealTrajectory_Dir2(2,:) - GlobalPosition.IdealTrajectory_Dir2(1,:)]; 
        idealTrajectory3        =   [0, 0, 0; GlobalPosition.IdealTrajectory_Dir3(2,:) - GlobalPosition.IdealTrajectory_Dir3(1,:)]; 


        if (min(x) < xAxisLimits(1))
            xAxisLimits(1) = min(x);
        end
        if (max(x) > xAxisLimits(2))
            xAxisLimits(2) = max(x);
        end
        if (min(log(1./y)) < yAxisLimits(1))
            yAxisLimits(1) = min(log(1./y));
        end
        if (max(log(1./y)) > yAxisLimits(2))
            yAxisLimits(2) = max(log(1./y));
        end
        
        % Get the max and min for the histogram plot inside the copulas
        for counter = 1:length(visitsPair)            
            xTry   =   Error.(matlab.lang.makeValidName(subjectsList(count))).(visitsPair(counter)).MaxSpeed.IntermittentExposure;
            yTry   =   Error.(matlab.lang.makeValidName(subjectsList(count))).(visitsPair(counter)).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure;
            yTry   =   log(1./yTry);
            if (max(xTry) > maxX)
                maxX = max(xTry);
            end
            if (max(yTry) > maxY)
                maxY = max(yTry);
            end
        end

        if (strcmp(treatmentVisit(index),visitsPair(1))) % baseline
            [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(x, y, rowNumber, colNumber, count, char(panelTitle), 'Speed', 'Accuracy', xLines, 1, 'filled', 1, char(visitsPair(1)), globalPos_Dir0, globalPos_Dir1, globalPos_Dir2, globalPos_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, globalStDeviation_Dir0, globalStDeviation_Dir1, globalStDeviation_Dir2, globalStDeviation_Dir3, xLimits, yLimits);  % color number is now 1 but it should be "count" to make it change
            % [hAx, insetAxes1, insetAxes2]   =   SpeedAccuracyCupolasSubplot(x, y, round(length(subjectsList)/2), round(length(subjectsList)/2), count, char(subjectsList(count)), 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline');  % color number is now 1 but it should be "count" to make it change
            hAxSaved                        =   hAx;
            insetAxes1Saved                 =   insetAxes1;
            insetAxes2Saved                 =   insetAxes2;
        elseif (strcmp(treatmentVisit(index),visitsPair(2))) % post evaluation
            [hAx, insetAxes1, insetAxes2, ~, ~, improvedAccuracy]    =   SpeedAccuracyCupolasSubplotMinimal(x, y, rowNumber, colNumber, count, char(panelTitle), 'Speed', 'Accuracy', xLines, 2, 'filled', 1, char(visitsPair(2)), globalPos_Dir0, globalPos_Dir1, globalPos_Dir2, globalPos_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, globalStDeviation_Dir0, globalStDeviation_Dir1, globalStDeviation_Dir2, globalStDeviation_Dir3, xLimits, yLimits, hAxSaved, insetAxes1Saved, insetAxes2Saved, baselineRegressionLineX, baselineRegressionLineY);
            % [hAx, insetAxes1, insetAxes2]    =   SpeedAccuracyCupolasSubplot(x, y, round(length(subjectsList)/2), round(length(subjectsList)/2), count, char(subjectsList(count)), 'Speed', 'Accuracy', xLines, 4, 'filled', 1, 'Post Evaluation');
        % else
            % [hAx, insetAxes1, insetAxes2, ~, ~]    =   SpeedAccuracyCupolasSubplotMinimal(x, y, rowNumber, colNumber, count, char(subjectsList(count)), 'Speed', 'Accuracy', xLines, 0, 'filled', 1, '', [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, globalStDeviation_Dir0, globalStDeviation_Dir1, globalStDeviation_Dir2, globalStDeviation_Dir3, xLimits, yLimits, hAxSaved, insetAxes1Saved, insetAxes2Saved);
            % [hAx, insetAxes1, insetAxes2]    =   SpeedAccuracyCupolasSubplot(x, y, round(length(subjectsList)/2), round(length(subjectsList)/2), count, char(subjectsList(count)), 'Speed', 'Accuracy', xLines, 0, 'filled', 0, '');
        end
        % set(gca, 'Color', 'none');
        % if exist(hAx)
            allMainAxes(axesHandlesIndex) = hAx;
            axesHandlesIndex = axesHandlesIndex + 1;
        % end
    end
end
 
% [hAx, insetAxes] = SpeedAccuracySubplotFunction(zeros(length(x)), zeros(length(y)), round(length(subjectsList)/2), round(length(subjectsList)/2), count, '', 'Speed', 'Accuracy', xLines, 0, 'filled', 0, 'PostEvaluation', [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, hAxSaved, insetAxesSaved);
% set(gca, 'Color', 'none');
% set(findall(gcf,'Type','axes'), 'XLim', xAxisLimits, 'YLim', yAxisLimits);
for i = 1:length(allMainAxes)
    if isgraphics(allMainAxes(i))
        % xlim(allMainAxes(i), xAxisLimits);
        xlim(allMainAxes(i), [0 0.55]);
        ylim(allMainAxes(i), yAxisLimits);
        zlim(allMainAxes(i), [0 20]); % hard coded to be removed
    end
end

% Fill the window. subplot() keeps a fixed share of every cell for margins, which
% is reasonable at 2x3 and wastes about a third of the canvas at 2x7. Repack the
% panels edge to edge, dragging each one's inset axes along, and scale the fonts
% down: the sizes inside SpeedAccuracyCupolasSubplotMinimal (title 50, labels 40)
% were chosen for a handful of large panels. Every panel is forced onto the same
% limits just above, so the shared labels lose nothing.
% FontScale 2.20: tick numbers 44 pt, axis labels 88 pt, and the four 20 pt texts
% ('slow', 'fast' and the two visit names, e.g. 'Visit_2'/'Visit_5') 44 pt. This is the compromise
% between 1.60, which fitted the panels cleanly, and 3.20, where 'slow'/'fast'
% merged, the visit name spilled into the neighbouring panel and the x tick
% numbers collided across panel borders. Some overlap of those in-panel texts
% remains at 2.20 - with 7 columns a panel is only ~200 px wide, so text much
% above 44 pt cannot fit inside one.
% The titles keep the old 0.55 so only the numbers, labels and texts grow.
TightenSubplotGrid(fig, allMainAxes, rowNumber, colNumber, ...
                   'Margin',         [0.100 0.180 0.008 0.045], ...  % [left bottom right top]
                   'Gap',            [0.010 0.060], ...              % [horizontal vertical]
                   'FontScale',      2.20, ...
                   'TitleFontScale', 0.55, ...
                   'SharedLabels',   true);

hold off;


% print(char("SpeedAccuracyPlot_Copulas_" + visitsPair(1) + "_vs_" + visitsPair(2)), '-dpng', '-r400')

end




%% Raincloud plot for improvement area distributions for "SHAM" vs "EF" vs "Visit 1-8"


RainCloudDistribution_Patients(SingleSubjectProcessedData, 'true', errorMetric, 1, ImprovedAccuracyComparison, SHAM_First_Group, EF_First_Group);




%% Raincloud plot for improvement area distribution for "SHAM" vs "EF" only

% Read the table with the Fugl-Meyer scores
cd(functionsFolder(1:end-35));
% GroupAssignment =   readtable("Group Assignment.xlsx");
opts = detectImportOptions('Group Assignment.xlsx');
opts = setvartype(opts,'string');   % forza tutte le colonne a string
GroupAssignment_all = readtable('Group Assignment.xlsx',opts);
idx = find(contains(GroupAssignment_all{:,1}, "PATIENTS ASSESSMENTS", 'IgnoreCase', true), 1);
GroupAssignment = GroupAssignment_all(idx:end, :);

cd(functionsFolder);



RainCloudDistributionTwoPhases_Patients(SingleSubjectProcessedData, false, errorMetric, ImprovedAccuracyComparison, SHAM_First_Group, EF_First_Group);




%% Padding for statistic test


% IntermittentExposure_Baseline_MaxErrorAmp_Padded = [IntermittentExposure_Baseline_MaxErrorAmp, nan(1, 26)];

% NonParametricStatistics([IntermittentExposure_Baseline_MaxErrorAmp_Padded', IntermittentExposure_PostEvaluation_MaxErrorAmp'], "Statistics_Speed_vs_Accuracy")






%% FUNCTIONS



function RainCloudDistributionTwoPhases_Patients(SingleSubjectProcessedData, linesOn, errorType, namesToCompare, SHAM_First, EF_First)

if nargin < 3
    errorType = 'Max Error';
end


% Extract subject data into SHAM-first and EF-first grouping
for i = 1:2
    for j = 1:min(length(SHAM_First), length(EF_First))
        Data_SHAM_First{i}(j,1) = SingleSubjectProcessedData.(matlab.lang.makeValidName(SHAM_First(j))).(matlab.lang.makeValidName(namesToCompare(i)));
        Data_EF_First{i}(j,1)   = SingleSubjectProcessedData.(matlab.lang.makeValidName(EF_First(j))).(matlab.lang.makeValidName(namesToCompare(end-i)));
    end
end

% Build unified Data cell (each element = subjects × 2)
for i = 1:2
    Data{i} = [Data_SHAM_First{i}, Data_EF_First{i}];  % col1=SHAM, col2=EF
end

figure;
hold on;

% Graphic Parameters
scatterSizeDots     = 800;
markerSizeDotMedian = 40;
lineWidthScatter    = 4;
lineWidthBarraNera  = 8;
xpos                = 1:2;       
width               = 0.35;      
npts                = 200;       
colorStandard       = [0.2, 0.2, 0.2];
colorEFfirst        = [0.8, 0.3, 0.05; 0.85, 0.6, 0.1];
colorSHAMfirst      = [0.85, 0.60, 0.10; 0.8, 0.3, 0.05];
edgeC               = 'none';
alphaF              = 0.5;
offset              = 0.03;  
lineC               = [0.3 0.3 0.3];
xLabelFontSize      = 50;

nSubjects = length(SHAM_First);
xJitter_SH = NaN(nSubjects, numel(xpos));
xJitter_EF = NaN(nSubjects, numel(xpos));

% ======= MIRRORED RAINCLOUDS LOOP =======
for i = 1:numel(xpos)

    xi = xpos(i);

    y_SHAM = Data_SHAM_First{i}(~isnan(Data_SHAM_First{i}));
    y_EF   = Data_EF_First{i}(~isnan(Data_EF_First{i}));

    % --- SHAM (Left-facing) ---
    if numel(y_SHAM) > 1
        [f, yi] = ksdensity(y_SHAM, 'NumPoints', npts);
        f = f ./ max(f);
        xLeft = (xi - offset) - f*width;
        patch([xLeft, xi - offset], [yi, yi(end)], colorSHAMfirst(i,:), 'FaceAlpha', alphaF, 'EdgeColor', edgeC);

        f_int = interp1(yi,f,y_SHAM);
        xJitter_SH(1:length(y_SHAM), i) = (xi - offset) - (0.05 + rand(size(y_SHAM))).*(f_int*width);

        scatter(xJitter_SH(1:length(y_SHAM), i), y_SHAM, scatterSizeDots, 'MarkerFaceColor',[1 1 1], 'MarkerEdgeColor', colorSHAMfirst(i,:), 'LineWidth', lineWidthScatter);
        q = prctile(y_SHAM,[25 50 75]);
        plot([xi-offset xi-offset],[q(1) q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(xi-offset,q(2),'o','MarkerFaceColor',colorSHAMfirst(i,:),'MarkerEdgeColor',lineC,'MarkerSize',markerSizeDotMedian,'LineWidth',1.5);
    end

    % --- EF (Right-facing) ---
    if numel(y_EF) > 1
        [f, yi] = ksdensity(y_EF, 'NumPoints', npts);
        f = f ./ max(f);
        xRight = (xi + offset) + f*width;
        patch([xi + offset, xRight], [yi, yi(end)], colorEFfirst(i,:), 'FaceAlpha', alphaF, 'EdgeColor', edgeC);

        f_int = interp1(yi,f,y_EF);
        xJitter_EF(1:length(y_EF), i) = (xi + offset) + (0.05 + rand(size(y_EF))).*(f_int*width);

        scatter(xJitter_EF(1:length(y_EF), i), y_EF, scatterSizeDots, 'MarkerFaceColor',[1 1 1], 'MarkerEdgeColor', colorEFfirst(i,:), 'LineWidth', lineWidthScatter);
        q = prctile(y_EF,[25 50 75]);
        plot([xi+offset xi+offset],[q(1) q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(xi+offset,q(2),'o','MarkerFaceColor',colorEFfirst(i,:),'MarkerEdgeColor',lineC,'MarkerSize',markerSizeDotMedian,'LineWidth',1.5);
    end

end

% ===== CONNECTING LINES (if requested) =====
if linesOn
    for s = 1:nSubjects
        if ~any(isnan(Data{1}(s,1:2))) && ~any(isnan(Data{2}(s,1:2)))
            % SHAM↔SHAM (yellow)
            plot([xJitter_SH(s,1), xJitter_SH(s,2)], [Data{1}(s,1), Data{2}(s,1)], '-', 'Color', [colorStandard 0.4], 'LineWidth', 2);
            % EF↔EF (red)
            plot([xJitter_EF(s,1), xJitter_EF(s,2)], [Data{1}(s,2), Data{2}(s,2)], '--', 'Color', [colorStandard 0.4], 'LineWidth', 2);
        end
    end
end

% Final Aesthetic Adjustments
yline(0,'--','Color','b');
ylabel('Improvement Area','FontSize',xLabelFontSize,'FontWeight','bold');
set(gca,'XTick',xpos,'XTickLabel',{'Visits 1 ↔ 4','Visits 4 ↔ 7'},'FontSize',xLabelFontSize,'FontWeight','bold','LineWidth',2,'Box','off');
set(gca, 'Color', 'none');
% title({'How much improvement in decoupled SHAM and EF sessions?', errorType}, 'FontSize', 70);
title({'Patients keep improving when transitioning from SHAM to EF but not viceversa'}, 'FontSize', 70);


% ---- Add group labels only once ----
xLimits = xlim;
yLimits = ylim;

% Place labels slightly above the data range
yText = yLimits(2) - 0.05 * range(yLimits);
text(xLimits(1) + 0.5*range(xLimits), yText-(0.2*yText), 'SHAM', 'Color', colorSHAMfirst(1,:), 'FontSize', 40, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
text(xLimits(1) + 0.5*range(xLimits), yText, 'Error Field', 'Color', colorEFfirst(1,:), 'FontSize', 40, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

end









function RainCloudDistribution_Patients(SingleSubjectProcessedData, linesOn, errorType, practicedDirections, namesToCompare, SHAM_First, EF_First)

if nargin < 3
    errorType = 'Max Error';
end

if nargin < 4
    practicedDirections = 1;
end


% EF, EA, SHAM
tempData = struct2cell(SingleSubjectProcessedData);
tempGroup = tempData;

for i = 1:length(namesToCompare)
    % tempGroup = struct2cell(tempData{i});
    for j = 1:min(length(SHAM_First), length(EF_First))
        if practicedDirections == 1
            Data_SHAM_First{i}(j,1) =   SingleSubjectProcessedData.(matlab.lang.makeValidName(SHAM_First(j))).(matlab.lang.makeValidName(namesToCompare(i)));
            Data_EF_First{i}(j,1)   =   SingleSubjectProcessedData.(matlab.lang.makeValidName(EF_First(j))).(matlab.lang.makeValidName(namesToCompare(i)));
        end
    end
end

% Combine into a single Data cell {1×3}, each element sized (nSubjects × 2)
for i = 1:length(namesToCompare)
    Data{i} = [Data_SHAM_First{i}, Data_EF_First{i}];  % column 1 = SHAM, column 2 = EF
end


figure;

% Parametri grafici
scatterSizeDots     =   800;
markerSizeDotMedian =   40;
lineWidthScatter    =   4;
lineWidthBarraNera  =   8;
xpos                =   1:3;       % 3 tick asse X
width               =   0.35;      % larghezza massima della mezza-violin
npts                =   200;       % risoluzione densità
colorStandard       =   [0.2, 0.2, 0.2];
colorEFfirst        =   [0.2 0.2 0.2];
colorSHAMfirst      =   [0.2 0.2 0.2];
% colorEFfirst        =   [0.8, 0.3, 0.05];
% colorSHAMfirst      =   [0.85, 0.60, 0.10];
edgeC               =   'none';
alphaF              =   0.5;
medW                =   2;
hold on;
offset              =   0.03;  
lineC               =   [0.3 0.3 0.3];
bigTitleSize        =   90;
xLabelFontSize      =   50;
legendSize          =   30;
if practicedDirections == 1
    labelNames          =   {namesToCompare(1), namesToCompare(2), namesToCompare(3)};
else
    labelNames          =   {'Unpracticed Baseline - Interm Exp', 'Unpracticed Pre-Post Force Off', 'Unpracticed Pre-Post Force On'};
end


% Preallocate jitter arrays aligned with subjects
nSubjects   = numel(fieldnames(SingleSubjectProcessedData));
xJitter     = NaN(nSubjects,numel(xpos));

for i = 1:numel(xpos)

    dataL       = [Data_EF_First{i}; Data_SHAM_First{i}];  % gruppo "sinistra"
    % dataR       = Data{i}(:,2);  % gruppo "destra"
    % dataSingle  = Data{i}(:,3);  % gruppo a tutta sinistra
    xi          = xpos(i);
    

    % ---- Half sinistra (dataL) ----
    y               =   dataL(~isnan(dataL));
    y_SHAM_First    =   Data_SHAM_First{i}(~isnan(Data_SHAM_First{i}));
    y_EF_First      =   Data_EF_First{i}(~isnan(Data_EF_First{i}));

    if numel(y) > 1
        [f, yi] = ksdensity(y, 'NumPoints', npts);
        f = f./max(f);
        xLeft = (xi - offset) - f*width;   

        patch([xLeft, xi - offset], [yi, yi(end)], colorStandard, 'FaceAlpha', alphaF, 'EdgeColor', edgeC, 'LineWidth', 0.5);

        finterp = interp1(yi, f, y, 'linear','extrap'); 

        xj   =   (xi) - (0.05 + 1*rand(size(y))).*(finterp*width);
        % xj_EF_First     =   (xi) - (0.05 + 1*rand(size(y))).*(finterp*width);
        % xJitter(~isnan(dataL),i) = xj;

        % Store jitter separately for SHAM and EF (same order as Data cell)
xJitter(1:length(y_SHAM_First), i) = xj(1:length(y_SHAM_First));
xJitter(length(y_SHAM_First)+1:length(y), i) = xj(length(y_SHAM_First)+1:end);

% Now scatter using stored values
scatter(xJitter(1:length(y_SHAM_First), i), y_SHAM_First, scatterSizeDots, ...
    'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', colorSHAMfirst, ...
    'MarkerFaceAlpha', 0.8, 'LineWidth', lineWidthScatter);

scatter(xJitter(length(y_SHAM_First)+1:length(y), i), y_EF_First, scatterSizeDots, ...
    'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', colorEFfirst, ...
    'MarkerFaceAlpha', 0.8, 'LineWidth', lineWidthScatter);


        q = prctile(y,[25 50 75]);
        plot([xi - offset, xi - offset], [q(1), q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(xi - offset, q(2), 'o', 'MarkerFaceColor', colorStandard, 'MarkerEdgeColor', lineC, 'LineWidth', 1.5,'MarkerSize', markerSizeDotMedian);
    end


end

% ---> UNCOMMENT THIS IF YOU WANT LINES CONNECTING THE DOTS
% if linesOn
%     for s = 1:nSubjects
%         for i = 1:(numel(xpos)-1)
%             if ~isnan(Data{i}(s)) && ~isnan(Data{i+1}(s))
%                 plot([xJitter(s,i), xJitter(s,i+1)], ...
%                      [Data{i}(s), Data{i+1}(s)], ...
%                      '-', 'Color', [0 0 0 0.3], 'LineWidth', 1.5);
%             end
%         end
%     end
% end

% <---





yline(0, '--', 'Color','b');

ylabel('Improvement Area', 'FontSize', xLabelFontSize, 'FontWeight','bold');

allY = cell2mat(cellfun(@(x) x(:), [Data_EF_First, Data_SHAM_First], 'UniformOutput', false));
allY = allY(~isnan(allY));

if isempty(allY)
    ylim([-1 1]);
else
    ymin = min(allY); ymax = max(allY);
    if ymin == ymax
        ymin = ymin - 1e-3; ymax = ymax + 1e-3;
    else
        padding = 0.3 * (ymax - ymin);
        ymin = ymin - padding; ymax = ymax + padding;
    end
    ylim([ymin ymax]);
end

if ~isempty(allY) && min(allY) < 0 && max(allY) > 0
    yticks(unique([get(gca,'YTick'), 0]));
end

set(gca, 'Color', 'none');
title({'Aggregate Group Analysis', errorType}, 'FontSize', bigTitleSize);

% Personalizzazione assi
% set(gca, 'LineWidth', 2, 'XTick', xpos, 'XTickLabel', {"SHAM" +newLine+ "Treatments",'EF Treatment','Visit_1 ↔ Visi_4'}, 'FontSize', xLabelFontSize, 'FontWeight', 'bold', 'Box', 'off');                                 % toglie il riquadro superiore e destro
set(gca, 'LineWidth', 2, 'XTick', xpos, 'XTickLabel', {'1 ↔ 4\newlineSHAM', '1 ↔ 4\newlineEF', '1 ↔ 8\newlineVisits'}, 'FontSize', xLabelFontSize, 'FontWeight', 'bold', 'Box', 'off');

ax = gca;
ax.XAxis.Exponent = 0;   
ax.YAxis.Exponent = 0;   
ax.ZAxis.Exponent = 0;   


% ---- Add group labels only once ----
xLimits = xlim;
yLimits = ylim;

% Place labels slightly above the data range
yText = yLimits(2) - 0.05 * range(yLimits);
% text(xLimits(1) + 0.2*range(xLimits), yText, 'SHAM\_First', 'Color', colorSHAMfirst, 'FontSize', 40, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
% text(xLimits(2) - 0.2*range(xLimits), yText, 'EF\_First', 'Color', colorEFfirst, 'FontSize', 40, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

end


function TightenSubplotGrid(figHandle, mainAxes, rowNumber, colNumber, varargin)
%TIGHTENSUBPLOTGRID  Repack a subplot grid so the panels fill the figure.
%
% subplot() reserves a fixed share of the canvas for margins. That is reasonable
% for 2x3 and wasteful for 2x7: even in a maximised window roughly two thirds of
% the area is white space and each copula ends up small. This moves every panel
% onto a tight grid instead.
%
% The inset axes (the rose plot and the two marginal histograms) are created in
% SpeedAccuracyCupolasSubplotMinimal with axes('Position', ...) computed from the
% parent's Position AT THAT MOMENT, in figure coordinates. They are not children
% of the main axes and do not follow it, so moving a panel on its own would leave
% its insets behind. Each inset is therefore attached to the panel whose
% rectangle contains its bottom-left corner - which is where the plotting
% function anchors it, at 0.8-0.85 of the panel width and 0.2-0.6 of its height -
% and then moved by the same affine map as that panel.
%
% The grid slot of each panel is measured rather than assumed. subplot() insets
% the whole grid inside the figure, so columns do not start at (col-1)/colNumber,
% and it also shrinks individual panels to fit oversized labels, so panels in one
% column do not even share an origin. Panel CENTRES survive both, and are binned
% onto a uniform grid to recover the row and column.
%
% NAME-VALUE OPTIONS
%   'Margin'       [left bottom right top], normalised, the room left around the
%                  grid for the shared labels   (default [0.042 0.075 0.008 0.045])
%   'Gap'          [horizontal vertical] between panels    (default [0.010 0.060])
%   'FontScale'    multiplies every FontSize in the figure (default 1, no change)
%   'TitleFontScale' the factor for the panel titles only, so the tick numbers
%                  and axis labels can be enlarged without the subject names
%                  growing with them   (default [], meaning follow 'FontScale')
%   'SharedLabels' drop the x label and tick labels off every row but the bottom,
%                  and the y label and tick labels off every column but the first.
%                  Only correct when every panel shares the same limits, which the
%                  caller enforces just before calling.        (default false)

    p = inputParser;
    p.addParameter('Margin',       [0.042 0.075 0.008 0.045]);
    p.addParameter('Gap',          [0.010 0.060]);
    p.addParameter('FontScale',    1);
    p.addParameter('TitleFontScale', []);
    p.addParameter('SharedLabels', false);
    p.parse(varargin{:});
    margin       = p.Results.Margin;
    gap          = p.Results.Gap;
    fontScale    = p.Results.FontScale;
    sharedLabels = p.Results.SharedLabels;
    titleFontScale = p.Results.TitleFontScale;
    if isempty(titleFontScale)
        titleFontScale = fontScale;
    end

    % allMainAxes is appended to on every visit iteration, not only on the two
    % that draw, so it holds repeats and - on the first subject - whatever hAx
    % was left in the workspace by the previous section's figure. Keep the axes
    % that belong to THIS figure, once each, in the order they were created.
    mainAxes = mainAxes(isgraphics(mainAxes));
    mainAxes = mainAxes(arrayfun(@(a) isequal(ancestor(a, 'figure'), figHandle), mainAxes));
    isFirst  = true(size(mainAxes));
    for k = 2:numel(mainAxes)
        isFirst(k) = ~any(mainAxes(k) == mainAxes(1:k-1));
    end
    mainAxes = mainAxes(isFirst);
    if isempty(mainAxes)
        warning('TightenSubplotGrid:noAxes', 'No axes of this figure to lay out.');
        return
    end

    % Positions of every axes in the figure, read once before anything moves.
    allAxes = findall(figHandle, 'Type', 'axes');
    oldPos  = get(allAxes, 'Position');
    if ~iscell(oldPos), oldPos = {oldPos}; end
    oldPos  = vertcat(oldPos{:});

    isMain   = ismember(allAxes, mainAxes);
    mainRows = find(isMain);
    mainRect = oldPos(mainRows, :);

    % Grid slot of each panel, binned from the panel centres. Rows count from the
    % top, the way subplot numbers them.
    centreX  = mainRect(:, 1) + mainRect(:, 3) / 2;
    centreY  = mainRect(:, 2) + mainRect(:, 4) / 2;
    panelCol = BinOntoGrid(centreX, colNumber);
    panelRow = rowNumber - BinOntoGrid(centreY, rowNumber) + 1;

    % The rectangle each panel gets once the margins are down to what the labels
    % actually need.
    panelWidth  = (1 - margin(1) - margin(3) - gap(1) * (colNumber - 1)) / colNumber;
    panelHeight = (1 - margin(2) - margin(4) - gap(2) * (rowNumber - 1)) / rowNumber;
    if panelWidth <= 0 || panelHeight <= 0
        error('TightenSubplotGrid:badLayout', ...
              'Margin and Gap leave no room for a %dx%d grid.', rowNumber, colNumber);
    end

    % Attach every other axes to the panel whose rectangle holds its bottom-left
    % corner - where the plotting function anchors its insets. If subplot shrank
    % the panel after the inset was placed the corner can fall just outside, so
    % fall back to the nearest panel centre.
    tol     = 1e-4;
    ownerOf = zeros(numel(allAxes), 1);
    ownerOf(mainRows) = 1:numel(mainRows);
    for j = 1:numel(allAxes)
        if ownerOf(j) > 0, continue, end
        inside = oldPos(j,1) >= mainRect(:,1) - tol & ...
                 oldPos(j,1) <= mainRect(:,1) + mainRect(:,3) + tol & ...
                 oldPos(j,2) >= mainRect(:,2) - tol & ...
                 oldPos(j,2) <= mainRect(:,2) + mainRect(:,4) + tol;
        owner = find(inside, 1);
        if isempty(owner)
            [~, owner] = min(hypot(oldPos(j,1) - centreX, oldPos(j,2) - centreY));
        end
        ownerOf(j) = owner;
    end

    % With the labels doubled, one x label per bottom panel and one y label per
    % first-column panel overlap their neighbours. Keep the text and size here,
    % strip every panel's copy below, and put a single pair on the whole grid
    % once the fonts have been scaled.
    if sharedLabels
        firstAx    = allAxes(mainRows(1));
        xLabText   = get(get(firstAx, 'XLabel'), 'String');
        yLabText   = get(get(firstAx, 'YLabel'), 'String');
        xLabSize   = get(get(firstAx, 'XLabel'), 'FontSize');
        yLabSize   = get(get(firstAx, 'YLabel'), 'FontSize');
        xLabWeight = get(get(firstAx, 'XLabel'), 'FontWeight');
        yLabWeight = get(get(firstAx, 'YLabel'), 'FontWeight');
    end

    for k = 1:numel(mainRows)
        old = mainRect(k, :);
        new = [margin(1) + (panelCol(k) - 1) * (panelWidth  + gap(1)), ...
               margin(2) + (rowNumber - panelRow(k)) * (panelHeight + gap(2)), ...
               panelWidth, panelHeight];
        scaleX = new(3) / old(3);
        scaleY = new(4) / old(4);

        for j = find(ownerOf == k)'
            q = oldPos(j, :);
            set(allAxes(j), 'Position', ...
                [new(1) + (q(1) - old(1)) * scaleX, ...
                 new(2) + (q(2) - old(2)) * scaleY, ...
                 q(3) * scaleX, ...
                 q(4) * scaleY]);
        end

        if sharedLabels
            ax = allAxes(mainRows(k));
            xlabel(ax, '');
            ylabel(ax, '');
            if panelRow(k) < rowNumber
                set(ax, 'XTickLabel', []);
            end
            if panelCol(k) > 1
                set(ax, 'YTickLabel', []);
            end
        end
    end

    % The panels are a fraction of the size the font sizes were chosen for. Read
    % every size BEFORE changing any of them: setting an axes' FontSize also
    % moves its auto-mode title and labels, so sizes read as we go would be
    % scaled twice.
    % Panel titles take titleFontScale instead, so the numbers and axis labels can
    % be made readable without the subject names swelling with them. (The
    % post-evaluation title is a TeX string carrying absolute \fontsize{} runs, so
    % it ignores FontSize altogether - pinning it here just keeps the intent
    % explicit and covers the plain-FontSize titles of the baseline-only branch.)
    if fontScale ~= 1 || titleFontScale ~= fontScale
        sized = findall(figHandle, '-property', 'FontSize');
        was   = get(sized, 'FontSize');
        if ~iscell(was), was = {was}; end
        titleHandles = gobjects(0);
        axesHere     = findall(figHandle, 'Type', 'axes');
        for k = 1:numel(axesHere)
            titleHandles(end+1) = get(axesHere(k), 'Title');  %#ok<AGROW>
        end
        for k = 1:numel(sized)
            if any(sized(k) == titleHandles)
                thisScale = titleFontScale;
            else
                thisScale = fontScale;
            end
            set(sized(k), 'FontSize', max(1, was{k} * thisScale));
        end
    end

    % The single shared pair, on an invisible axes spanning the whole grid, so the
    % labels centre on the figure instead of on one panel. The axes is invisible
    % but its labels are not, and it is created last so the font scaling above
    % does not touch it - hence the explicit * fontScale here.
    if sharedLabels
        gridRect = [margin(1), margin(2), ...
                    1 - margin(1) - margin(3), 1 - margin(2) - margin(4)];
        labelAx  = axes(figHandle, 'Position', gridRect, 'Visible', 'off', ...
                        'HitTest', 'off', 'HandleVisibility', 'off');
        uistack(labelAx, 'bottom');
        xl = xlabel(labelAx, xLabText, 'FontSize', max(1, xLabSize * fontScale), ...
                    'FontWeight', xLabWeight, 'Visible', 'on');
        yl = ylabel(labelAx, yLabText, 'FontSize', max(1, yLabSize * fontScale), ...
                    'FontWeight', yLabWeight, 'Visible', 'on');
        set([xl yl], 'Color', [0 0 0]);

        % The y label is rotated, so what limits it is the HEIGHT of the grid, not
        % the left margin: past a certain size the string is longer than the figure
        % is tall and clips off the top and bottom whatever room it is given.
        % Shrink it to fit instead of letting it clip. The 0.55 em is a rough mean
        % character width - good enough to catch the overflow, and it only ever
        % reduces the size that was asked for.
        gridPx    = getpixelposition(labelAx);
        ptToPx    = get(0, 'ScreenPixelsPerInch') / 72;
        askedSize = max(1, yLabSize * fontScale);
        approxLen = numel(char(yLabText)) * 0.55 * askedSize * ptToPx;
        if approxLen > 0.95 * gridPx(4)
            set(yl, 'FontSize', max(1, askedSize * 0.95 * gridPx(4) / approxLen));
        end
    end
end


function slot = BinOntoGrid(centres, nSlots)
% Which of nSlots evenly spaced positions each centre belongs to, 1 = smallest.
% Panels are evenly spaced but not identically sized, so binning the centres is
% far steadier than comparing edges.

    if nSlots <= 1 || range(centres) == 0
        slot = ones(size(centres));
        return
    end
    step = range(centres) / (nSlots - 1);
    slot = round((centres - min(centres)) / step) + 1;
    slot = min(nSlots, max(1, slot));
end


function n = VisitNumberFromName(visitName)
% "Visit_5" -> 5. NaN if the name does not carry a number.
    n = str2double(extractAfter(string(visitName), "Visit_"));
end


function txt = WrongOnsetTitleSuffix(onsetResults, subjectID, fromVisit, toVisit, style)
% Builds the "  |  V2 30% | V3 12% | V4 45% bad" tail appended to an EF figure
% title. It reports the visits from fromVisit up to but NOT including toVisit -
% the treatment visits run between the two visits the figure compares, e.g. a
% Visit_2-vs-Visit_5 figure reports Visit_2, Visit_3, Visit_4.
%
% style (optional):
%   'full'    - default, labels every visit: "  |  V2 30% | V3 12% | V4 45% bad"
%   'compact' - drops the labels: "  (30% 12% 45% bad)". Meant for the copulas
%               grid, where a 2 x 7 panel is far too narrow for the full form;
%               the visits are still in order, and the figure name already says
%               which pair of visits the grid spans.
%
% Each percentage is FracWrong from ScanAllVisits(): premature-onset trials over
% the processable intermittent-exposure practiced-direction trials of that visit.
% A visit that was never scanned (no .mat, or the scan skipped it) prints '-'.
% Returns '' when no scan is available, so the title falls back to plain
% 'Error Field' instead of erroring.

    txt = '';
    if nargin < 5 || isempty(style), style = 'full'; end
    if isempty(onsetResults) || isnan(fromVisit) || isnan(toVisit), return; end

    visitNums = fromVisit:(toVisit - 1);
    if isempty(visitNums), return; end

    compact = strcmpi(style, 'compact');

    parts = cell(1, numel(visitNums));
    for k = 1:numel(visitNums)
        v   = visitNums(k);
        row = find(strcmp({onsetResults.SubjectID}, subjectID) & ...
                   [onsetResults.VisitNum] == v, 1);
        if isempty(row) || isnan(onsetResults(row).FracWrong)
            if compact, parts{k} = '-'; else, parts{k} = sprintf('V%d -', v); end
        else
            pct = 100 * onsetResults(row).FracWrong;
            if compact
                parts{k} = sprintf('%.0f%%', pct);
            else
                parts{k} = sprintf('V%d %.0f%%', v, pct);
            end
        end
    end

    if compact
        txt = ['  (' strjoin(parts, ' ') ' bad)'];
    else
        txt = ['  |  ' strjoin(parts, ' | ') ' bad'];
    end
end
