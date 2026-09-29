%% BRUNO BORGHI - Speed vs Accuracy Neurotypical plot
% When running the program, be sure to have the ".../Dropbox/EA_R01/PostProcessing/MATLAB/SpeedAccyracyPlot" folder open in the Current Folder


% print('SpeedAccuracyPlot_ForSnapShot', '-dpng', '-r400')
clear all; close all; clc;

 %% Select the subjects' ID to be compared

subjectsList = ["31"];
% subjectsList            =   ["31", "32", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "47", "48", "49", "50", "51", "53", "54", "55", "56", "57", "58", "59", "60"];
% subjectsList            =   ["31", "32", "34", "35", "36", "37", "38", "39", "41", "42", "43", "44", "45", "47", "48", "49", "50", "51", "53", "54", "55", "56", "57", "58", "59"];
% subjectsList            =   ["31", "32", "34", "35", "36", "37", "38", "39", "41", "42", "43", "44", "45", "47", "48", "49", "50", "51", "53", "54", "55", "56", "57", "58", "59"];



% EFgroup         =   ["31", "37", "38", "40", "44", "45", "48", "55"];

% EFgroup         =   ["31", "37", "38", "44", "45", "48", "59", "60"];
% EAgroup         =   ["32", "34", "41", "43", "47", "50", "51", "57"];
% CONTROLgroup    =   ["35", "36", "39", "42", "49", "53", "54", "56"];

EFgroup = ["31"];



% Every metric listed here is extracted once and stored in the "Error" struct
% under its own field name, so the expensive loading loop below never has to be
% re-run when you change your mind. The metric that is actually plotted is
% picked further down, at the top of the "Calculates all the improved accuracy
% values for every subject" section (variable "errorMetric").
errorMetricsToStore =   ["MaximumErrorAmplitude", "MaximumPerpendicularError"];


speedAccuracyFolder     =   pwd; % it saves the current folder calleed MATLAB where all the programs and data is
initialFolder           =   speedAccuracyFolder(1:end-19);

% Speed thresholds for neurotypical
lowSpeedThreshold       =   0.2766;
highSpeedThreshold      =   0.4348;

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

dir0_Saved = 0;
dir1_Saved = 0;
dir2_Saved = 0;
dir3_Saved = 0;


addpath(initialFolder);

for count = 1:length(subjectsList)

    cd(strcat([initialFolder+"/"+subjectsList(count)]));                     % Open the folder with the respective data of that subject

    firstMedianCalculation  =   1;
    load(subjectsList(count) + ".mat");
    for metricCount = 1:length(errorMetricsToStore)
        thisMetric  =   errorMetricsToStore(metricCount);
        Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(thisMetric)).Baseline                =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionZero, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionOne, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionTwo, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionThree, thisMetric, 'launch')'];
        Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(thisMetric)).IntermittentExposure    =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, thisMetric, 'launch')'];
        Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(thisMetric)).Training                =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, thisMetric, 'launch')'];
        Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(thisMetric)).PostTrainingForced      =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, thisMetric, 'launch')'];
        Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(thisMetric)).PostTrainingNoForce     =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, thisMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, thisMetric, 'launch')'];
    end
    Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.Baseline                                                =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionThree, 'Speed', 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.IntermittentExposure                                    =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, 'Speed', 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.Training                                                =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, 'Speed', 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.PostTrainingForced                                      =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, 'Speed', 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.PostTrainingNoForce                                     =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, 'Speed', 'launch')'];
    % Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining            =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, errorMetric, 'launch')'];
    % Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.PostTraining                                            =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, 'Speed', 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, 'Speed', 'launch')'];


    if (medianGlobalPosition == 1)
        % Store the first value and then skip this for all the successive trials
        if (firstMedianCalculation  ==   1)
            % Intermittent Exposure
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir0               =   Data{SpecialMovementIndex.Baseline.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir1               =   Data{SpecialMovementIndex.Baseline.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir2               =   Data{SpecialMovementIndex.Baseline.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir3               =   Data{SpecialMovementIndex.Baseline.DirectionThree(1)}.GlobalPosition;
            % Intermittent Exposure
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir0   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir1   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir2   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionThree(1)}.GlobalPosition;
            % Training
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir0               =   Data{SpecialMovementIndex.PureTraining.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir1               =   Data{SpecialMovementIndex.PureTraining.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir2               =   Data{SpecialMovementIndex.PureTraining.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir3               =   Data{SpecialMovementIndex.PureTraining.DirectionThree(1)}.GlobalPosition;
            % Post Training
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir0           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir1           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir2           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir3           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionThree(1)}.GlobalPosition;
            % Post Training No Force
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir1    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir2    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir3    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionThree(1)}.GlobalPosition;

            firstMedianCalculation  =   0;
        end



        %%%%%%%%%%%%%%%% Baseline %%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 0
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionZero]'

            if (dir0_Saved == 0 && Data{movementNumber}.MovementDirection == 0)
                GlobalPosition.IdealTrajectory_Dir0 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir0_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir0               =   medianPos;



        %%%%%%%%%%%% DIRECTION 1
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionOne]'

            if (dir1_Saved == 0 && Data{movementNumber}.MovementDirection == 1)
                GlobalPosition.IdealTrajectory_Dir1 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir1_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir1);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir1_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir1               =   medianPos;



        %%%%%%%%%%%% DIRECTION 2
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionTwo]'

            if (dir2_Saved == 0 && Data{movementNumber}.MovementDirection == 2)
                GlobalPosition.IdealTrajectory_Dir2 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir2_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir2);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir2_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir2               =   medianPos;



        %%%%%%%%%%%% DIRECTION 3
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionThree]'

            if (dir3_Saved == 0 && Data{movementNumber}.MovementDirection == 3)
                GlobalPosition.IdealTrajectory_Dir3 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir3_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir3);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir3_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir3               =   medianPos;

        



        %%%%%%%%%%%%%%%% Intermittent Exposure %%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%% DIRECTION 0
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionZero]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir0               =   medianPos;




        %%%%%%%%%%%% DIRECTION 1
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionOne]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir1);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir1_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir1               =   medianPos;





        %%%%%%%%%%%% DIRECTION 2
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionTwo]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir2);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir2_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir2               =   medianPos;





        %%%%%%%%%%%% DIRECTION 3

        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionThree]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

       [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3               =   medianPos;





        %%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%% DIRECTION 0
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PureTraining.DirectionZero]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

       [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir0               =   medianPos;





        %%%%%%%%%%%% DIRECTION 1
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PureTraining.DirectionOne]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir1);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir1_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir1               =   medianPos;





        %%%%%%%%%%%% DIRECTION 2
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PureTraining.DirectionTwo]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir2);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir2_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir2               =   medianPos;





        %%%%%%%%%%%% DIRECTION 3

        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PureTraining.DirectionThree]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Training.Dir3);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir3               =   medianPos;






        %%%%%%%%%%%%%%%% Post Training - Force On %%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 0
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionZero]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir0               =   medianPos;




        %%%%%%%%%%%% DIRECTION 1
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionOne]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir1);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir1_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir1               =   medianPos;




        %%%%%%%%%%%% DIRECTION 2
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionTwo]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir2);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir2_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir2               =   medianPos;




        %%%%%%%%%%%% DIRECTION 3

        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionThree]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir3);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir3_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir3               =   medianPos;


        %%%%%%%%%%%%%%%% Post Training - Force Off %%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 0
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionZero]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0               =   medianPos;


        %%%%%%%%%%%% DIRECTION 1
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionOne]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir1);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir1_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir1               =   medianPos;


        %%%%%%%%%%%% DIRECTION 2
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionTwo]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir2);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir2_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir2               =   medianPos;


        %%%%%%%%%%%% DIRECTION 3
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionThree]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0               =   medianPos;




    end

    cd(speedAccuracyFolder);

end



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

% groupsToCompare     =   ["EF", "EA", "CONTROL"];
groupsToCompare     =   ["EF"];
phasesToCompare     =   ["Baseline", "IntermittentExposure", "PostTrainingForced", "PostTrainingNoForce"];
ForceOnComparison   =   ["ImprovedAccuracyForceOn", "ImprovedAccuracyForceOff", "ImprovedAccuracyBaselineIntermExp"];
directionsToCompare =   ["Dir0", "Dir1", "Dir2", "Dir3"];
xLines              =   [lowSpeedThreshold, highSpeedThreshold];
axesHandlesIndex    =   1;
allMainAxes         =   [];
% idealTrajectory0    =   [];
% idealTrajectory1    =   [];
% idealTrajectory2    =   [];
% idealTrajectory3    =   [];
maxError                =    0;
minError                =    100;
maxSpeed                =    0;
minSpeed                =    100;
baselineRegressionLineX =   [];
baselineRegressionLineY =   [];
graphCount = 1;
firstTimeEF = 0;
firstTimeEA = 0;
firstTimeCONTROL = 0;
rowNumber = round(length(subjectsList)/2);
colNumber = round(length(subjectsList)/2);
% rowNumber = 2;
% colNumber = 1;


% Random global pos - we don't need them
EF_globalPos_IntermittentExp_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir0(1,:);
EF_globalPos_IntermittentExp_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir1(1,:);
EF_globalPos_IntermittentExp_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir2(1,:);
EF_globalPos_IntermittentExp_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir3(1,:);

EF_globalStd_IntermittentExp_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir0(1,:);
EF_globalStd_IntermittentExp_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir1(1,:);
EF_globalStd_IntermittentExp_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir2(1,:);
EF_globalStd_IntermittentExp_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).IntermittentExposure.Dir3(1,:);

EF_globalPos_PostTraining_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir0(1,:);
EF_globalPos_PostTraining_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir1(1,:);
EF_globalPos_PostTraining_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir2(1,:);
EF_globalPos_PostTraining_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir3(1,:);

EF_globalStd_PostTraining_Dir0 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir0(1,:);
EF_globalStd_PostTraining_Dir1 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir1(1,:);
EF_globalStd_PostTraining_Dir2 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir2(1,:);
EF_globalStd_PostTraining_Dir3 = GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(subjectsList(1))).PostTraining.Dir3(1,:);

idealTrajectory0                                    =   GlobalPosition.IdealTrajectory_Dir0 - GlobalPosition.IdealTrajectory_Dir0(1,:);
idealTrajectory1                                    =   GlobalPosition.IdealTrajectory_Dir1 - GlobalPosition.IdealTrajectory_Dir1(1,:);
idealTrajectory2                                    =   GlobalPosition.IdealTrajectory_Dir2 - GlobalPosition.IdealTrajectory_Dir2(1,:);
idealTrajectory3                                    =   GlobalPosition.IdealTrajectory_Dir3 - GlobalPosition.IdealTrajectory_Dir3(1,:);



errorVector =   [];
speedVector =   [];
% Collect Max e Min for Error and Speed
for count = subjectsList
    for counter = 1:length(phasesToCompare)
        errorVector =   [errorVector, Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))];
        speedVector =   [speedVector, Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))];
        if max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))) > maxError
            maxError = max(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter))));
        end
        if min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))) < minError
            minError = min(Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter))));
        end
        if max(Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))) > maxSpeed
            maxSpeed = max(Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter))));
        end
        if min(Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))) < minSpeed
            minSpeed = min(Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter))));
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


xLimits = [speed_lower_bound, speed_upper_bound];
yLimits = [error_lower_bound, error_upper_bound];






for count = subjectsList
    if ismember(count, EFgroup)
        for counter = 1:length(phasesToCompare)
            % filter and normalize error
            errorToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
            speedToFilter   =   Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));

            [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, minError, maxError, speedToFilter, minSpeed, maxSpeed, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound);

            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = normalizedError;
            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = normalizedSpeed;
        end
    elseif ismember(count, EAgroup)
        for counter = 1:length(phasesToCompare)
            % filter and normalize error
            errorToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
            speedToFilter   =   Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
            
            [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, minError, maxError, speedToFilter, minSpeed, maxSpeed, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound);

            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = normalizedError;
            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = normalizedSpeed;
        end
    elseif ismember(count, CONTROLgroup)
        for counter = 1:length(phasesToCompare)
            % filter and normalize error
            errorToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
            speedToFilter   =   Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
            
            [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, minError, maxError, speedToFilter, minSpeed, maxSpeed, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound);

            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = normalizedError;
            SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = normalizedSpeed;
        end
    end
end




for count = subjectsList
    if ismember(count, EFgroup)
        % Baseline vs Interm Exp plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(3))) = improvedAccuracy;
        
        % Force on plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(1))) = improvedAccuracy;
        % [baselineRegressionLineX, baselineRegressionLineY]  =   ComputeRegressionArea(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error);
        % [~, ~, improvedAccuracy]                            =   ComputeRegressionArea(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, baselineRegressionLineX, baselineRegressionLineY);
        % SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(1))) = improvedAccuracy;

        % Force off plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_2                  =   hAx;
        insetAxes1Saved_2           =   insetAxes1;
        insetAxes2Saved_2           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_2, insetAxes1Saved_2, insetAxes2Saved_2, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(2))) = improvedAccuracy;
    elseif ismember(count, EAgroup)
        % Baseline vs Interm Exp plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(3))) = improvedAccuracy;
        
        % Force on plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(1))) = improvedAccuracy;
        
        % Force off plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_2                  =   hAx;
        insetAxes1Saved_2           =   insetAxes1;
        insetAxes2Saved_2           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_2, insetAxes1Saved_2, insetAxes2Saved_2, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(2))) = improvedAccuracy;
    elseif ismember(count, CONTROLgroup)
        % Baseline vs Interm Exp plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Interm Exp', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(3))) = improvedAccuracy;

        % Force on plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_1                  =   hAx;
        insetAxes1Saved_1           =   insetAxes1;
        insetAxes2Saved_1           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(1))) = improvedAccuracy;

        % Force off plots
        [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
        hAxSaved_2                  =   hAx;
        insetAxes1Saved_2           =   insetAxes1;
        insetAxes2Saved_2           =   insetAxes2;
        allMainAxes(graphCount)     =   hAx;
        graphCount                  =   graphCount + 1;
        [~, ~, ~, ~, ~, improvedAccuracy]             =   SpeedAccuracyCupolasSubplotMinimal(SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_2, insetAxes1Saved_2, insetAxes2Saved_2, baselineRegressionLineX, baselineRegressionLineY);
        SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(ForceOnComparison(2))) = improvedAccuracy;
    end

end




%% Copulas distribution plot and analysis for ONE SUBJECT ONLY


fig = figure;
% set(fig, 'WindowState', 'maximized');
groupsToCompare     =   ["EF"];
phasesToCompare     =   ["Baseline", "IntermittentExposure", "PostTrainingForced", "PostTrainingNoForce"];
directionsToCompare =   ["Dir0", "Dir1", "Dir2", "Dir3"];
xLines              =   [lowSpeedThreshold, highSpeedThreshold];
axesHandlesIndex    =   1;
allMainAxes         =   [];
idealTrajectory0    =   [];
idealTrajectory1    =   [];
idealTrajectory2    =   [];
idealTrajectory3    =   [];
maxX                =    0;
maxY                =    0;
baselineRegressionLineX =   [];
baselineRegressionLineY =   [];
graphCount = 1;
firstTimeEF = 0;
firstTimeEA = 0;
firstTimeCONTROL = 0;
% rowNumber = round(length(subjectsList)/2);
% colNumber = round(length(subjectsList)/2);
rowNumber = 1;
colNumber = 3;
count = EFgroup(1); % change this index to select a different subject to analyze in the EF group


for counter = 1:length(phasesToCompare)
    SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error;
    SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = SingleSubjectProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed;

    % % filter and normalize error
    % errorToFilter   =   Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
    % speedToFilter   =   Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
    % 
    % [normalizedError, normalizedSpeed] = filterAndNormalize(errorToFilter, minError, maxError, speedToFilter, minSpeed, maxSpeed, error_lower_bound, error_upper_bound, speed_lower_bound, speed_upper_bound);
    % SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = normalizedError;
    % SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = normalizedSpeed;
end

EF_allPos_Baseline_Dir0{1}              =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0(1,:);
EF_allPos_Baseline_Dir1{1}              =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1(1,:);
EF_allPos_Baseline_Dir2{1}              =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2(1,:);
EF_allPos_Baseline_Dir3{1}              =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3(1,:);

EF_allPos_IntermittentExp_Dir0{1}       =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0(1,:);
EF_allPos_IntermittentExp_Dir1{1}       =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1(1,:);
EF_allPos_IntermittentExp_Dir2{1}       =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2(1,:);
EF_allPos_IntermittentExp_Dir3{1}       =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3(1,:);

EF_allPos_PostTraining_Dir0{1}          =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0(1,:);
EF_allPos_PostTraining_Dir1{1}          =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1(1,:);
EF_allPos_PostTraining_Dir2{1}          =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2(1,:);
EF_allPos_PostTraining_Dir3{1}          =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3(1,:);

EF_allPos_PostTrainingNoForce_Dir0{1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0(1,:);
EF_allPos_PostTrainingNoForce_Dir1{1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1(1,:);
EF_allPos_PostTrainingNoForce_Dir2{1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2(1,:);
EF_allPos_PostTrainingNoForce_Dir3{1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3(1,:);


% BASELINE
[EF_globalPos_Baseline_Dir0, EF_globalStd_Baseline_Dir0]                        =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir0);
[EF_globalPos_Baseline_Dir1, EF_globalStd_Baseline_Dir1]                        =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir1);
[EF_globalPos_Baseline_Dir2, EF_globalStd_Baseline_Dir2]                        =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir2);
[EF_globalPos_Baseline_Dir3, EF_globalStd_Baseline_Dir3]                        =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir3);


% INTERMITTENT EXPOSURE
[EF_globalPos_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir0]          =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir0);
[EF_globalPos_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir1]          =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir1);
[EF_globalPos_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir2]          =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir2);
[EF_globalPos_IntermittentExp_Dir3, EF_globalStd_IntermittentExp_Dir3]          =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir3);


% POST TRAINING
[EF_globalPos_PostTraining_Dir0, EF_globalStd_PostTraining_Dir0]                =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir0);
[EF_globalPos_PostTraining_Dir1, EF_globalStd_PostTraining_Dir1]                =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir1);
[EF_globalPos_PostTraining_Dir2, EF_globalStd_PostTraining_Dir2]                =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir2);
[EF_globalPos_PostTraining_Dir3, EF_globalStd_PostTraining_Dir3]                =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir3);


% POST TRAINING NO FORCE
[EF_globalPos_PostTrainingNoForce_Dir0, EF_globalStd_PostTrainingNoForce_Dir0]  =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir0);
[EF_globalPos_PostTrainingNoForce_Dir1, EF_globalStd_PostTrainingNoForce_Dir1]  =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir1);
[EF_globalPos_PostTrainingNoForce_Dir2, EF_globalStd_PostTrainingNoForce_Dir2]  =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir2);
[EF_globalPos_PostTrainingNoForce_Dir3, EF_globalStd_PostTrainingNoForce_Dir3]  =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir3);



idealTrajectory0    =   GlobalPosition.IdealTrajectory_Dir0 - GlobalPosition.IdealTrajectory_Dir0(1,:);
idealTrajectory1    =   GlobalPosition.IdealTrajectory_Dir1 - GlobalPosition.IdealTrajectory_Dir1(1,:);
idealTrajectory2    =   GlobalPosition.IdealTrajectory_Dir2 - GlobalPosition.IdealTrajectory_Dir2(1,:);
idealTrajectory3    =   GlobalPosition.IdealTrajectory_Dir3 - GlobalPosition.IdealTrajectory_Dir3(1,:);


%%%%%%%%%%%%%%    PLOTS   %%%%%%%%%%%%%%%

improvedAccuracy = zeros(2,3);
rowNumber = 1;
colNumber = 3;

% Force on plots
[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 1, 'Baseline vs Interm Exp', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Baseline', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
% [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracySubplotFunction(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3);
hAxSaved_1                                                                          =   hAx;
insetAxes1Saved_1                                                                   =   insetAxes1;
insetAxes2Saved_1                                                                   =   insetAxes2;
allMainAxes(graphCount)                                                             =   hAx;
graphCount                                                                          =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(1,1)]                                              =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Baseline vs Interm Exp', 'Speed', 'Accuracy', xLines, 4, 'filled', 1, 'Interm Exposure', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);

% Force on plots
[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 2, 'Pre vs Post Training Force On', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, xLimits, yLimits);
% [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracySubplotFunction(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3);
hAxSaved_2                                                                          =   hAx;
insetAxes1Saved_2                                                                   =   insetAxes1;
insetAxes2Saved_2                                                                   =   insetAxes2;
allMainAxes(graphCount)                                                             =   hAx;
graphCount                                                                          =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(1,1)]                                              =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 2, 'Pre vs Post Training Force On', 'Speed', 'Accuracy', xLines, 3, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, xLimits, yLimits, hAxSaved_2, insetAxes1Saved_2, insetAxes2Saved_2, baselineRegressionLineX, baselineRegressionLineY);
% [~, ~, ~, ~, ~, improvedAccuracy(1,1)]                                              =   SpeedAccuracySubplotFunction(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);



% Force off plots
[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 3, 'Pre vs Post Training Force Off', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_Baseline_Dir0, EF_globalPos_Baseline_Dir1, EF_globalPos_Baseline_Dir2, EF_globalPos_Baseline_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_Baseline_Dir0, EF_globalStd_Baseline_Dir1, EF_globalStd_Baseline_Dir2, EF_globalStd_Baseline_Dir3, xLimits, yLimits);
% [hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]     =   SpeedAccuracySubplotFunction(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 2, '', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_Baseline_Dir0, EF_globalPos_Baseline_Dir1, EF_globalPos_Baseline_Dir2, EF_globalPos_Baseline_Dir3, EF_globalStd_Baseline_Dir0, EF_globalStd_Baseline_Dir1, EF_globalStd_Baseline_Dir2, EF_globalStd_Baseline_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3);
hAxSaved_3                                                                          =   hAx;
insetAxes1Saved_3                                                                   =   insetAxes1;
insetAxes2Saved_3                                                                   =   insetAxes2;
allMainAxes(graphCount)                                                             =   hAx;
graphCount                                                                          =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(2,1)]                                              =   SpeedAccuracyCupolasSubplotMinimal(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 3, 'Pre vs Post Training Force Off', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTrainingNoForce_Dir0, EF_globalPos_PostTrainingNoForce_Dir1, EF_globalPos_PostTrainingNoForce_Dir2, EF_globalPos_PostTrainingNoForce_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTrainingNoForce_Dir0, EF_globalStd_PostTrainingNoForce_Dir1, EF_globalStd_PostTrainingNoForce_Dir2, EF_globalStd_PostTrainingNoForce_Dir3, xLimits, yLimits, hAxSaved_3, insetAxes1Saved_3, insetAxes2Saved_3, baselineRegressionLineX, baselineRegressionLineY);
% [~, ~, ~, ~, ~, improvedAccuracy(2,1)]                                              =   SpeedAccuracySubplotFunction(SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, SingleSubject.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 2, '', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTrainingNoForce_Dir0, EF_globalPos_PostTrainingNoForce_Dir1, EF_globalPos_PostTrainingNoForce_Dir2, EF_globalPos_PostTrainingNoForce_Dir3, EF_globalStd_PostTrainingNoForce_Dir0, EF_globalStd_PostTrainingNoForce_Dir1, EF_globalStd_PostTrainingNoForce_Dir2, EF_globalStd_PostTrainingNoForce_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, hAxSaved_4, insetAxes1Saved_4, insetAxes2Saved_4, baselineRegressionLineX, baselineRegressionLineY);


for i = 1:length(allMainAxes)
    if isgraphics(allMainAxes(i))
        % xlim(allMainAxes(i), xAxisLimits);
        xlim(allMainAxes(i), [0.17 0.45]);
        ylim(allMainAxes(i), [2.7 4.5]);
        zlim(allMainAxes(i), [0 3.2]); % hard coded to be removed
    end
end



%% Raincloud plot for improvement area distributions



RainCloudDistributionPlot(SingleSubjectProcessedData, 'true');






%% Raincloud plot for improvement area normalized on the baseline direct effects distributions


RainCloudDistributionNormalizedDirectEffects(SingleSubjectProcessedData);



%% Area Improvement Fon vs Area De-provement Foff - group analysis STATISTICS

% EF group
EF_ForceOn = [];
EF_ForceOff = [];
for count = 1:8
    EF_ForceOn  = [EF_ForceOn, SingleSubjectProcessedData.EF.(matlab.lang.makeValidName(EFgroup(count))).ImprovedAccuracyForceOn];
    EF_ForceOff = [EF_ForceOff, SingleSubjectProcessedData.EF.(matlab.lang.makeValidName(EFgroup(count))).ImprovedAccuracyForceOff];
end

% EA group
EA_ForceOn = [];
EA_ForceOff = [];
for count = 1:8
    EA_ForceOn  = [EA_ForceOn, SingleSubjectProcessedData.EA.(matlab.lang.makeValidName(EAgroup(count))).ImprovedAccuracyForceOn];
    EA_ForceOff = [EA_ForceOff, SingleSubjectProcessedData.EA.(matlab.lang.makeValidName(EAgroup(count))).ImprovedAccuracyForceOff];
end

% CONTROL group
CONTROL_ForceOn = [];
CONTROL_ForceOff = [];
for count = 1:8
    CONTROL_ForceOn  = [CONTROL_ForceOn, SingleSubjectProcessedData.CONTROL.(matlab.lang.makeValidName(CONTROLgroup(count))).ImprovedAccuracyForceOn];
    CONTROL_ForceOff = [CONTROL_ForceOff, SingleSubjectProcessedData.CONTROL.(matlab.lang.makeValidName(CONTROLgroup(count))).ImprovedAccuracyForceOff];
end

NonParametricStatistics([EF_ForceOn', EF_ForceOff'], "Statistics_ImprovedAccuracy_ForceOn_vs_ForceOff_EF")

NonParametricStatistics([EA_ForceOn', EA_ForceOff'], "Statistics_ImprovedAccuracy_ForceOn_vs_ForceOff_EA")

NonParametricStatistics([CONTROL_ForceOn', CONTROL_ForceOff'], "Statistics_ImprovedAccuracy_ForceOn_vs_ForceOff_CONTROL ")



% Area Improvement Fon - Area Deprovement Foff Group 1 vs Group 2 vs Group 3 - group analysis STATISTICS

EF_Difference = EF_ForceOn - EF_ForceOff;

EA_Difference = EA_ForceOn - EA_ForceOff;

NonParametricStatistics([EF_Difference', EA_Difference'], "Statistics_ImprovedAccuracy_ForceOn_vs_ForceOff_EF_vs_EA")


EF_Difference = EF_ForceOn - EF_ForceOff;

CONTROL_Difference = CONTROL_ForceOn - CONTROL_ForceOff;

NonParametricStatistics([EF_Difference', CONTROL_Difference'], "Statistics_ImprovedAccuracy_ForceOn_vs_ForceOff_EF_vs_CONTROL")





%% ALL SUBJECTS single plot - Speed vs Accuracy (1/MaxPerpError) - Baseline (PRE) vs Baseline (POST) 

IntermittentExposure_MaxErrorAmp = [];
IntermittentExposure_Speed = [];
PostTraining_MaxErrorAmp = [];
PostTraining_Speed = [];

for count = 1:length(subjectsList)
    IntermittentExposure_MaxErrorAmp    =   [IntermittentExposure_MaxErrorAmp,  Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure];
    IntermittentExposure_Speed          =   [IntermittentExposure_Speed,  Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.IntermittentExposure];
end

for count = 1:length(subjectsList)
    PostTraining_MaxErrorAmp   =   [PostTraining_MaxErrorAmp,  Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced];
    PostTraining_Speed         =   [PostTraining_Speed,  Error.(matlab.lang.makeValidName(subjectsList(count))).MaxSpeed.PostTrainingForced];
end


% Remove outliers and NaN to allow polyfit to work

% [IntermittentExposure_MaxErrorAmp, indexesBaseline]    = rmoutliers(IntermittentExposure_MaxErrorAmp);
% goodIndexesBaseline                                             = find(~indexesBaseline);
% IntermittentExposure_Speed                     = IntermittentExposure_Speed(goodIndexesBaseline);
% 
% [PostTraining_MaxErrorAmp, indexesPostEvaluation]  = rmoutliers(PostTraining_MaxErrorAmp);
% goodIndexesPostEvaluation                                                 = find(~indexesPostEvaluation);
% PostTraining_Speed                   = PostTraining_Speed(goodIndexesPostEvaluation);

finiteIndexes_Baseline                      =   isfinite(IntermittentExposure_MaxErrorAmp);
IntermittentExposure_MaxErrorAmp   =   IntermittentExposure_MaxErrorAmp(finiteIndexes_Baseline);
IntermittentExposure_Speed         =   IntermittentExposure_Speed(finiteIndexes_Baseline);  

finiteIndexes_PostEvaluation                    =   isfinite(PostTraining_MaxErrorAmp);
PostTraining_MaxErrorAmp =   PostTraining_MaxErrorAmp(finiteIndexes_PostEvaluation);
PostTraining_Speed       =   PostTraining_Speed(finiteIndexes_PostEvaluation);

% Logarithmic scale

IntermittentExposure_MaxErrorAmp       = log(1./IntermittentExposure_MaxErrorAmp);
PostTraining_MaxErrorAmp = log(1./PostTraining_MaxErrorAmp);
% IntermittentExposure_MaxErrorAmp = 1./IntermittentExposure_MaxErrorAmp;
% PostTraining_MaxErrorAmp = 1./PostTraining_MaxErrorAmp;

% Perform linear regression on combined Baseline data
baselineCoeff           =   polyfit(IntermittentExposure_Speed, IntermittentExposure_MaxErrorAmp, 1);
postEvaluationCoeff     =   polyfit(PostTraining_Speed, PostTraining_MaxErrorAmp, 1);

% Define the range of speeds for plotting the fit line
speedRangeBaseline          =   linspace(min(IntermittentExposure_Speed), max(IntermittentExposure_Speed), 100);
speedRangePostEvaluation    =   linspace(min(PostTraining_Speed), max(PostTraining_Speed), 100);

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
    x_baseline                  =   Error.(subjectName).MaxSpeed.IntermittentExposure;
    y_baseline                  =   log(1 ./ Error.(subjectName).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);
    % scatter(x_baseline, y_baseline, scatterSize, 'filled', 'MarkerFaceColor', blackColor, 'Marker', markerShape);
    scatter(x_baseline, y_baseline, scatterSize, 'filled', 'MarkerFaceColor', colorNow, 'MarkerEdgeColor', 'none');

    % Plot PostEvaluation data
    xData = Error.(subjectName).MaxSpeed.IntermittentExposure;
    yData = log(1 ./ Error.(subjectName).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure);

    h = scatter(xData, yData, 60, 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', colorNow, 'LineWidth', 3);
    legendHandles(count) = h;
    legendLabels(count) = subjectsList(count);
end


legendObj = legend(legendHandles, legendLabels, 'Location', 'bestoutside');
legendObj.Title.String = 'Subjects';
legendObj.FontSize = 20;

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

% scatter(IntermittentExposure_Speed, IntermittentExposure_MaxErrorAmp, 60, 'filled', 'MarkerFaceColor', blackColor); % Baseline Visit
% scatter(PostTraining_Speed, PostTraining_MaxErrorAmp, 60, 'filled', 'MarkerFaceColor', redColor);  % PostEvaluation visit

% Plot the fit line on top of the scatter plot
plot(speedRangeBaseline, baselineFitLine, '-', 'Color', [0, 0, 0], 'LineWidth', 5, 'DisplayName', 'Baseline Fit');
plot(speedRangePostEvaluation, postEvaluationFitLine, '--', 'Color', [0, 0, 0], 'LineWidth', 5, 'DisplayName', 'PostEvaluation Fit');

set(gca,'FontSize',15);
set(gca, 'color', 'none');  
% Adjust x-axis ticks to include threshold values
xticks([0.1, lowSpeedThreshold, highSpeedThreshold, 0.6]);

xlabel('Speed [m/s]', 'FontSize', 20, 'FontWeight','bold');
axisThickness = gca;
axisThickness.FontWeight = 'bold';     
ylabel('Accuracy (1/'+errorMetric+")", 'FontSize', 20, 'FontWeight','bold');
xLine5 = xline(highSpeedThreshold, '--', 'Fast Feedback', 'LabelHorizontalAlignment','center','LabelVerticalAlignment','top', 'FontSize',25);
xLine5.LineWidth = 2;
xLine6 = xline(lowSpeedThreshold, '--', 'Slow Feedback', 'LabelHorizontalAlignment','center','LabelVerticalAlignment','top', 'FontSize',25);
xLine6.LineWidth = 2;

% Annotate labels for each line towards the origin
text(0.005, baselineCoeff(1) * 0 + baselineCoeff(2) + 0.2, 'Pre Training', 'Color', [0, 0, 0], 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
text(0.005, postEvaluationCoeff(1) * 0 + postEvaluationCoeff(2) + 0.4, 'Post Training', 'Color', [0, 0, 0], 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');






%% Copulas distribution plot and analysis for EF vs EA vs CONTROL AUTOMATED


fig = figure;
set(fig, 'WindowState', 'maximized');
groupsToCompare     =   ["EF", "EA", "CONTROL"];
phasesToCompare     =   ["Baseline", "IntermittentExposure", "PostTrainingForced", "PostTrainingNoForce"];
directionsToCompare =   ["Dir0", "Dir1", "Dir2", "Dir3"];
xLines              =   [lowSpeedThreshold, highSpeedThreshold];
axesHandlesIndex    =   1;
allMainAxes         =   [];
idealTrajectory0    =   [];
idealTrajectory1    =   [];
idealTrajectory2    =   [];
idealTrajectory3    =   [];
maxX                =    0;
maxY                =    0;
baselineRegressionLineX =   [];
baselineRegressionLineY =   [];
graphCount = 1;
firstTimeEF = 0;
firstTimeEA = 0;
firstTimeCONTROL = 0;
% rowNumber = round(length(subjectsList)/2);
% colNumber = round(length(subjectsList)/2);
rowNumber = 2;
colNumber = 3;


%%%%% Baseline %%%%%%%
% EF
EF_allPos_Baseline_Dir0          =   {};
EF_allPos_Baseline_Dir1          =   {};
EF_allPos_Baseline_Dir2          =   {};
EF_allPos_Baseline_Dir3          =   {};
% EA
EA_allPos_Baseline_Dir0          =   {};
EA_allPos_Baseline_Dir1          =   {};
EA_allPos_Baseline_Dir2          =   {};
EA_allPos_Baseline_Dir3          =   {};
% CONTROL
CONTROL_allPos_Baseline_Dir0     =   {};
CONTROL_allPos_Baseline_Dir1     =   {};
CONTROL_allPos_Baseline_Dir2     =   {};
CONTROL_allPos_Baseline_Dir3     =   {};

%%%%% Intermittent Exposure %%%%%%%
% EF
EF_allPos_IntermittentExp_Dir0          =   {};
EF_allPos_IntermittentExp_Dir1          =   {};
EF_allPos_IntermittentExp_Dir2          =   {};
EF_allPos_IntermittentExp_Dir3          =   {};
% EA
EA_allPos_IntermittentExp_Dir0          =   {};
EA_allPos_IntermittentExp_Dir1          =   {};
EA_allPos_IntermittentExp_Dir2          =   {};
EA_allPos_IntermittentExp_Dir3          =   {};
% CONTROL
CONTROL_allPos_IntermittentExp_Dir0     =   {};
CONTROL_allPos_IntermittentExp_Dir1     =   {};
CONTROL_allPos_IntermittentExp_Dir2     =   {};
CONTROL_allPos_IntermittentExp_Dir3     =   {};

%%%%%%%% Post Training %%%%%%%%
% EF
EF_allPos_PostTraining_Dir0             =   {};
EF_allPos_PostTraining_Dir1             =   {};
EF_allPos_PostTraining_Dir2             =   {};
EF_allPos_PostTraining_Dir3             =   {};
% EA
EA_allPos_PostTraining_Dir0          =   {};
EA_allPos_PostTraining_Dir1          =   {};
EA_allPos_PostTraining_Dir2          =   {};
EA_allPos_PostTraining_Dir3          =   {};
% CONTROL 
CONTROL_allPos_PostTraining_Dir0     =   {};
CONTROL_allPos_PostTraining_Dir1     =   {};
CONTROL_allPos_PostTraining_Dir2     =   {};
CONTROL_allPos_PostTraining_Dir3     =   {};


%%%%%%%% Post Training %%%%%%%%
% EF
EF_allPos_PostTrainingNoForce_Dir0             =   {};
EF_allPos_PostTrainingNoForce_Dir1             =   {};
EF_allPos_PostTrainingNoForce_Dir2             =   {};
EF_allPos_PostTrainingNoForce_Dir3             =   {};
% EA
EA_allPos_PostTrainingNoForce_Dir0          =   {};
EA_allPos_PostTrainingNoForce_Dir1          =   {};
EA_allPos_PostTrainingNoForce_Dir2          =   {};
EA_allPos_PostTrainingNoForce_Dir3          =   {};
% CONTROL 
CONTROL_allPos_PostTrainingNoForce_Dir0     =   {};
CONTROL_allPos_PostTrainingNoForce_Dir1     =   {};
CONTROL_allPos_PostTrainingNoForce_Dir2     =   {};
CONTROL_allPos_PostTrainingNoForce_Dir3     =   {};



for count = subjectsList
    if ismember(count, EFgroup)
        for counter = 1:length(phasesToCompare)
            if firstTimeEF < 4
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
            firstTimeEF = firstTimeEF + 1;
            else
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error; Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))];
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed; Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))];
            end
         end
       
        EF_allPos_Baseline_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0(1,:);
        EF_allPos_Baseline_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1(1,:);
        EF_allPos_Baseline_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2(1,:);
        EF_allPos_Baseline_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3(1,:);

        EF_allPos_IntermittentExp_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0(1,:);
        EF_allPos_IntermittentExp_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1(1,:);
        EF_allPos_IntermittentExp_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2(1,:);
        EF_allPos_IntermittentExp_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3(1,:);
        
        EF_allPos_PostTraining_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0(1,:);
        EF_allPos_PostTraining_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1(1,:);
        EF_allPos_PostTraining_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2(1,:);
        EF_allPos_PostTraining_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3(1,:);

        EF_allPos_PostTrainingNoForce_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0(1,:);
        EF_allPos_PostTrainingNoForce_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1(1,:);
        EF_allPos_PostTrainingNoForce_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2(1,:);
        EF_allPos_PostTrainingNoForce_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3(1,:);

    elseif ismember(count, EAgroup)
        for counter = 1:length(phasesToCompare)
            if firstTimeEA < 4
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
                firstTimeEA = firstTimeEA + 1;
            else
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error; Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))];
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed; Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))];
            end
        end
       
        EA_allPos_Baseline_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0(1,:);
        EA_allPos_Baseline_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1(1,:);
        EA_allPos_Baseline_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2(1,:);
        EA_allPos_Baseline_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3(1,:);

        EA_allPos_IntermittentExp_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0(1,:);
        EA_allPos_IntermittentExp_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1(1,:);
        EA_allPos_IntermittentExp_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2(1,:);
        EA_allPos_IntermittentExp_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3(1,:);
        
        EA_allPos_PostTraining_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0(1,:);
        EA_allPos_PostTraining_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1(1,:);
        EA_allPos_PostTraining_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2(1,:);
        EA_allPos_PostTraining_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3(1,:);

        EA_allPos_PostTrainingNoForce_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0(1,:);
        EA_allPos_PostTrainingNoForce_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1(1,:);
        EA_allPos_PostTrainingNoForce_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2(1,:);
        EA_allPos_PostTrainingNoForce_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3(1,:);


    elseif ismember(count, CONTROLgroup)
        for counter = 1:length(phasesToCompare)
            if firstTimeCONTROL < 4
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)));
                ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)));
                firstTimeCONTROL = firstTimeCONTROL + 1;
            else
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Error; Error.(matlab.lang.makeValidName(count)).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phasesToCompare(counter)))];
            ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed = [ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(counter))).Speed; Error.(matlab.lang.makeValidName(count)).MaxSpeed.(matlab.lang.makeValidName(phasesToCompare(counter)))];
            end
        end
       
        CONTROL_allPos_Baseline_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir0(1,:);
        CONTROL_allPos_Baseline_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir1(1,:);
        CONTROL_allPos_Baseline_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir2(1,:);
        CONTROL_allPos_Baseline_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).Baseline.Dir3(1,:);

        CONTROL_allPos_IntermittentExp_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir0(1,:);
        CONTROL_allPos_IntermittentExp_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir1(1,:);
        CONTROL_allPos_IntermittentExp_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir2(1,:);
        CONTROL_allPos_IntermittentExp_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).IntermittentExposure.Dir3(1,:);
        
        CONTROL_allPos_PostTraining_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir0(1,:);
        CONTROL_allPos_PostTraining_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir1(1,:);
        CONTROL_allPos_PostTraining_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir2(1,:);
        CONTROL_allPos_PostTraining_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTraining.Dir3(1,:);

        CONTROL_allPos_PostTrainingNoForce_Dir0{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir0(1,:);
        CONTROL_allPos_PostTrainingNoForce_Dir1{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir1(1,:);
        CONTROL_allPos_PostTrainingNoForce_Dir2{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir2(1,:);
        CONTROL_allPos_PostTrainingNoForce_Dir3{end+1}   =   GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3 - GlobalPosition.(matlab.lang.makeValidName(count)).PostTrainingNoForce.Dir3(1,:);

    end
end



for count1 = 1:length(groupsToCompare)
    for count2 = 1:length(phasesToCompare)
        ProcessedData.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).Error    =   median(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).Error);
        ProcessedData.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).Speed    =   median(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).Speed);
    end
end

% for count1 = 1:length(groupsToCompare)
%     for count2 = 1:length(phasesToCompare)
%         for count3 = 1:length(directionsToCompare)
%             [Pos, Std] = computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir0);
%             ProcessedGlobalPos.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).(matlab.lang.makeValidName(directionsToCompare(count3))).Position = Pos;
%             ProcessedGlobalPos.(matlab.lang.makeValidName(groupsToCompare(count1))).(matlab.lang.makeValidName(phasesToCompare(count2))).(matlab.lang.makeValidName(directionsToCompare(count3))).StandardDeviation = Std;
%         end
%     end
% end
% 
% %%
% [medianCell, stdCell] = computeMedianAndStandardDeviation(testCell);
% 
% %%

% BASELINE
[EF_globalPos_Baseline_Dir0, EF_globalStd_Baseline_Dir0]              =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir0);
[EF_globalPos_Baseline_Dir1, EF_globalStd_Baseline_Dir1]              =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir1);
[EF_globalPos_Baseline_Dir2, EF_globalStd_Baseline_Dir2]              =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir2);
[EF_globalPos_Baseline_Dir3, EF_globalStd_Baseline_Dir3]              =   computeMedianAndStandardDeviation(EF_allPos_Baseline_Dir3);

[EA_globalPos_Baseline_Dir0, EA_globalStd_Baseline_Dir0]              =   computeMedianAndStandardDeviation(EA_allPos_Baseline_Dir0);
[EA_globalPos_Baseline_Dir1, EA_globalStd_Baseline_Dir1]              =   computeMedianAndStandardDeviation(EA_allPos_Baseline_Dir1);
[EA_globalPos_Baseline_Dir2, EA_globalStd_Baseline_Dir2]              =   computeMedianAndStandardDeviation(EA_allPos_Baseline_Dir2);
[EA_globalPos_Baseline_Dir3, EA_globalStd_Baseline_Dir3]              =   computeMedianAndStandardDeviation(EA_allPos_Baseline_Dir3);

[CONTROL_globalPos_Baseline_Dir0, CONTROL_globalStd_Baseline_Dir0]    =   computeMedianAndStandardDeviation(CONTROL_allPos_Baseline_Dir0);
[CONTROL_globalPos_Baseline_Dir1, CONTROL_globalStd_Baseline_Dir1]    =   computeMedianAndStandardDeviation(CONTROL_allPos_Baseline_Dir1);
[CONTROL_globalPos_Baseline_Dir2, CONTROL_globalStd_Baseline_Dir2]    =   computeMedianAndStandardDeviation(CONTROL_allPos_Baseline_Dir2);
[CONTROL_globalPos_Baseline_Dir3, CONTROL_globalStd_Baseline_Dir3]    =   computeMedianAndStandardDeviation(CONTROL_allPos_Baseline_Dir3);

% INTERMITTENT EXPOSURE
[EF_globalPos_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir0]              =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir0);
[EF_globalPos_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir1]              =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir1);
[EF_globalPos_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir2]              =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir2);
[EF_globalPos_IntermittentExp_Dir3, EF_globalStd_IntermittentExp_Dir3]              =   computeMedianAndStandardDeviation(EF_allPos_IntermittentExp_Dir3);

[EA_globalPos_IntermittentExp_Dir0, EA_globalStd_IntermittentExp_Dir0]              =   computeMedianAndStandardDeviation(EA_allPos_IntermittentExp_Dir0);
[EA_globalPos_IntermittentExp_Dir1, EA_globalStd_IntermittentExp_Dir1]              =   computeMedianAndStandardDeviation(EA_allPos_IntermittentExp_Dir1);
[EA_globalPos_IntermittentExp_Dir2, EA_globalStd_IntermittentExp_Dir2]              =   computeMedianAndStandardDeviation(EA_allPos_IntermittentExp_Dir2);
[EA_globalPos_IntermittentExp_Dir3, EA_globalStd_IntermittentExp_Dir3]              =   computeMedianAndStandardDeviation(EA_allPos_IntermittentExp_Dir3);

[CONTROL_globalPos_IntermittentExp_Dir0, CONTROL_globalStd_IntermittentExp_Dir0]    =   computeMedianAndStandardDeviation(CONTROL_allPos_IntermittentExp_Dir0);
[CONTROL_globalPos_IntermittentExp_Dir1, CONTROL_globalStd_IntermittentExp_Dir1]    =   computeMedianAndStandardDeviation(CONTROL_allPos_IntermittentExp_Dir1);
[CONTROL_globalPos_IntermittentExp_Dir2, CONTROL_globalStd_IntermittentExp_Dir2]    =   computeMedianAndStandardDeviation(CONTROL_allPos_IntermittentExp_Dir2);
[CONTROL_globalPos_IntermittentExp_Dir3, CONTROL_globalStd_IntermittentExp_Dir3]    =   computeMedianAndStandardDeviation(CONTROL_allPos_IntermittentExp_Dir3);

% POST TRAINING
[EF_globalPos_PostTraining_Dir0, EF_globalStd_PostTraining_Dir0]              =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir0);
[EF_globalPos_PostTraining_Dir1, EF_globalStd_PostTraining_Dir1]              =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir1);
[EF_globalPos_PostTraining_Dir2, EF_globalStd_PostTraining_Dir2]              =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir2);
[EF_globalPos_PostTraining_Dir3, EF_globalStd_PostTraining_Dir3]              =   computeMedianAndStandardDeviation(EF_allPos_PostTraining_Dir3);

[EA_globalPos_PostTraining_Dir0, EA_globalStd_PostTraining_Dir0]              =   computeMedianAndStandardDeviation(EA_allPos_PostTraining_Dir0);
[EA_globalPos_PostTraining_Dir1, EA_globalStd_PostTraining_Dir1]              =   computeMedianAndStandardDeviation(EA_allPos_PostTraining_Dir1);
[EA_globalPos_PostTraining_Dir2, EA_globalStd_PostTraining_Dir2]              =   computeMedianAndStandardDeviation(EA_allPos_PostTraining_Dir2);
[EA_globalPos_PostTraining_Dir3, EA_globalStd_PostTraining_Dir3]              =   computeMedianAndStandardDeviation(EA_allPos_PostTraining_Dir3);

[CONTROL_globalPos_PostTraining_Dir0, CONTROL_globalStd_PostTraining_Dir0]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTraining_Dir0);
[CONTROL_globalPos_PostTraining_Dir1, CONTROL_globalStd_PostTraining_Dir1]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTraining_Dir1);
[CONTROL_globalPos_PostTraining_Dir2, CONTROL_globalStd_PostTraining_Dir2]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTraining_Dir2);
[CONTROL_globalPos_PostTraining_Dir3, CONTROL_globalStd_PostTraining_Dir3]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTraining_Dir3);

% POST TRAINING NO FORCE
[EF_globalPos_PostTrainingNoForce_Dir0, EF_globalStd_PostTrainingNoForce_Dir0]              =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir0);
[EF_globalPos_PostTrainingNoForce_Dir1, EF_globalStd_PostTrainingNoForce_Dir1]              =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir1);
[EF_globalPos_PostTrainingNoForce_Dir2, EF_globalStd_PostTrainingNoForce_Dir2]              =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir2);
[EF_globalPos_PostTrainingNoForce_Dir3, EF_globalStd_PostTrainingNoForce_Dir3]              =   computeMedianAndStandardDeviation(EF_allPos_PostTrainingNoForce_Dir3);

[EA_globalPos_PostTrainingNoForce_Dir0, EA_globalStd_PostTrainingNoForce_Dir0]              =   computeMedianAndStandardDeviation(EA_allPos_PostTrainingNoForce_Dir0);
[EA_globalPos_PostTrainingNoForce_Dir1, EA_globalStd_PostTrainingNoForce_Dir1]              =   computeMedianAndStandardDeviation(EA_allPos_PostTrainingNoForce_Dir1);
[EA_globalPos_PostTrainingNoForce_Dir2, EA_globalStd_PostTrainingNoForce_Dir2]              =   computeMedianAndStandardDeviation(EA_allPos_PostTrainingNoForce_Dir2);
[EA_globalPos_PostTrainingNoForce_Dir3, EA_globalStd_PostTrainingNoForce_Dir3]              =   computeMedianAndStandardDeviation(EA_allPos_PostTrainingNoForce_Dir3);

[CONTROL_globalPos_PostTrainingNoForce_Dir0, CONTROL_globalStd_PostTrainingNoForce_Dir0]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTrainingNoForce_Dir0);
[CONTROL_globalPos_PostTrainingNoForce_Dir1, CONTROL_globalStd_PostTrainingNoForce_Dir1]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTrainingNoForce_Dir1);
[CONTROL_globalPos_PostTrainingNoForce_Dir2, CONTROL_globalStd_PostTrainingNoForce_Dir2]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTrainingNoForce_Dir2);
[CONTROL_globalPos_PostTrainingNoForce_Dir3, CONTROL_globalStd_PostTrainingNoForce_Dir3]    =   computeMedianAndStandardDeviation(CONTROL_allPos_PostTrainingNoForce_Dir3);


idealTrajectory0                                    =   GlobalPosition.IdealTrajectory_Dir0 - GlobalPosition.IdealTrajectory_Dir0(1,:);
idealTrajectory1                                    =   GlobalPosition.IdealTrajectory_Dir1 - GlobalPosition.IdealTrajectory_Dir1(1,:);
idealTrajectory2                                    =   GlobalPosition.IdealTrajectory_Dir2 - GlobalPosition.IdealTrajectory_Dir2(1,:);
idealTrajectory3                                    =   GlobalPosition.IdealTrajectory_Dir3 - GlobalPosition.IdealTrajectory_Dir3(1,:);



%%%%%%%%%%%%%%    PLOTS   %%%%%%%%%%%%%%%
improvedAccuracy = zeros(2,3);

% Force on plots
[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_IntermittentExp_Dir0, EF_globalPos_IntermittentExp_Dir1, EF_globalPos_IntermittentExp_Dir2, EF_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_IntermittentExp_Dir0, EF_globalStd_IntermittentExp_Dir1, EF_globalStd_IntermittentExp_Dir2, EF_globalStd_IntermittentExp_Dir3);
hAxSaved_1                  =   hAx;
insetAxes1Saved_1           =   insetAxes1;
insetAxes2Saved_1           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(1,1)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 1, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTraining_Dir0, EF_globalPos_PostTraining_Dir1, EF_globalPos_PostTraining_Dir2, EF_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTraining_Dir0, EF_globalStd_PostTraining_Dir1, EF_globalStd_PostTraining_Dir2, EF_globalStd_PostTraining_Dir3, hAxSaved_1, insetAxes1Saved_1, insetAxes2Saved_1, baselineRegressionLineX, baselineRegressionLineY);


[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 2, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EA_globalPos_IntermittentExp_Dir0, EA_globalPos_IntermittentExp_Dir1, EA_globalPos_IntermittentExp_Dir2, EA_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EA_globalStd_IntermittentExp_Dir0, EA_globalStd_IntermittentExp_Dir1, EA_globalStd_IntermittentExp_Dir2, EA_globalStd_IntermittentExp_Dir3);
hAxSaved_2                  =   hAx;
insetAxes1Saved_2           =   insetAxes1;
insetAxes2Saved_2           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(1,2)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 2, 'Error Augmentation', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EA_globalPos_PostTraining_Dir0, EA_globalPos_PostTraining_Dir1, EA_globalPos_PostTraining_Dir2, EA_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EA_globalStd_PostTraining_Dir0, EA_globalStd_PostTraining_Dir1, EA_globalStd_PostTraining_Dir2, EA_globalStd_PostTraining_Dir3, hAxSaved_2, insetAxes1Saved_2, insetAxes2Saved_2, baselineRegressionLineX, baselineRegressionLineY);


[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(2))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(2))).Error, rowNumber, colNumber, 3, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', CONTROL_globalPos_IntermittentExp_Dir0, CONTROL_globalPos_IntermittentExp_Dir1, CONTROL_globalPos_IntermittentExp_Dir2, CONTROL_globalPos_IntermittentExp_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, CONTROL_globalStd_IntermittentExp_Dir0, CONTROL_globalStd_IntermittentExp_Dir1, CONTROL_globalStd_IntermittentExp_Dir2, CONTROL_globalStd_IntermittentExp_Dir3);
hAxSaved_3                  =   hAx;
insetAxes1Saved_3           =   insetAxes1;
insetAxes2Saved_3           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(1,3)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(3))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(3))).Error, rowNumber, colNumber, 3, 'Sham', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', CONTROL_globalPos_PostTraining_Dir0, CONTROL_globalPos_PostTraining_Dir1, CONTROL_globalPos_PostTraining_Dir2, CONTROL_globalPos_PostTraining_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, CONTROL_globalStd_PostTraining_Dir0, CONTROL_globalStd_PostTraining_Dir1, CONTROL_globalStd_PostTraining_Dir2, CONTROL_globalStd_PostTraining_Dir3, hAxSaved_3, insetAxes1Saved_3, insetAxes2Saved_3, baselineRegressionLineX, baselineRegressionLineY);




% Force off plots
[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 4, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EF_globalPos_Baseline_Dir0, EF_globalPos_Baseline_Dir1, EF_globalPos_Baseline_Dir2, EF_globalPos_Baseline_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_Baseline_Dir0, EF_globalStd_Baseline_Dir1, EF_globalStd_Baseline_Dir2, EF_globalStd_Baseline_Dir3);
hAxSaved_4                  =   hAx;
insetAxes1Saved_4           =   insetAxes1;
insetAxes2Saved_4           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(2,1)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(1))).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 4, 'Error Field', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EF_globalPos_PostTrainingNoForce_Dir0, EF_globalPos_PostTrainingNoForce_Dir1, EF_globalPos_PostTrainingNoForce_Dir2, EF_globalPos_PostTrainingNoForce_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EF_globalStd_PostTrainingNoForce_Dir0, EF_globalStd_PostTrainingNoForce_Dir1, EF_globalStd_PostTrainingNoForce_Dir2, EF_globalStd_PostTrainingNoForce_Dir3, hAxSaved_4, insetAxes1Saved_4, insetAxes2Saved_4, baselineRegressionLineX, baselineRegressionLineY);


[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 5, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', EA_globalPos_Baseline_Dir0, EA_globalPos_Baseline_Dir1, EA_globalPos_Baseline_Dir2, EA_globalPos_Baseline_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EA_globalStd_Baseline_Dir0, EA_globalStd_Baseline_Dir1, EA_globalStd_Baseline_Dir2, EA_globalStd_Baseline_Dir3);
hAxSaved_5                  =   hAx;
insetAxes1Saved_5           =   insetAxes1;
insetAxes2Saved_5           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(2,2)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(2))).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 5, 'Error Augmentation', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', EA_globalPos_PostTrainingNoForce_Dir0, EA_globalPos_PostTrainingNoForce_Dir1, EA_globalPos_PostTrainingNoForce_Dir2, EA_globalPos_PostTrainingNoForce_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, EA_globalStd_PostTrainingNoForce_Dir0, EA_globalStd_PostTrainingNoForce_Dir1, EA_globalStd_PostTrainingNoForce_Dir2, EA_globalStd_PostTrainingNoForce_Dir3, hAxSaved_5, insetAxes1Saved_5, insetAxes2Saved_5, baselineRegressionLineX, baselineRegressionLineY);


[hAx, insetAxes1, insetAxes2, baselineRegressionLineX, baselineRegressionLineY]   =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(1))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(1))).Error, rowNumber, colNumber, 6, 'Error Field', 'Speed', 'Accuracy', xLines, 1, 'filled', 1, 'Pre Training', CONTROL_globalPos_Baseline_Dir0, CONTROL_globalPos_Baseline_Dir1, CONTROL_globalPos_Baseline_Dir2, CONTROL_globalPos_Baseline_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, CONTROL_globalStd_Baseline_Dir0, CONTROL_globalStd_Baseline_Dir1, CONTROL_globalStd_Baseline_Dir2, CONTROL_globalStd_Baseline_Dir3);
hAxSaved_6                  =   hAx;
insetAxes1Saved_6           =   insetAxes1;
insetAxes2Saved_6           =   insetAxes2;
allMainAxes(graphCount)     =   hAx;
graphCount                  =   graphCount + 1;
[~, ~, ~, ~, ~, improvedAccuracy(2,3)]             =   SpeedAccuracyCupolasSubplot(ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(4))).Speed, ProcessedData.(matlab.lang.makeValidName(groupsToCompare(3))).(matlab.lang.makeValidName(phasesToCompare(4))).Error, rowNumber, colNumber, 6, 'Sham', 'Speed', 'Accuracy', xLines, 2, 'filled', 1, 'Post Training', CONTROL_globalPos_PostTrainingNoForce_Dir0, CONTROL_globalPos_PostTrainingNoForce_Dir1, CONTROL_globalPos_PostTrainingNoForce_Dir2, CONTROL_globalPos_PostTrainingNoForce_Dir3, idealTrajectory0, idealTrajectory1, idealTrajectory2, idealTrajectory3, CONTROL_globalStd_PostTrainingNoForce_Dir0, CONTROL_globalStd_PostTrainingNoForce_Dir1, CONTROL_globalStd_PostTrainingNoForce_Dir2, CONTROL_globalStd_PostTrainingNoForce_Dir3, hAxSaved_6, insetAxes1Saved_6, insetAxes2Saved_6, baselineRegressionLineX, baselineRegressionLineY);



for i = 1:length(allMainAxes)
    if isgraphics(allMainAxes(i))
        % xlim(allMainAxes(i), xAxisLimits);
        % xlim(allMainAxes(i), [0.15 0.45]);
        % ylim(allMainAxes(i), [2.3 4]);
        zlim(allMainAxes(i), [0 8]); % hard coded to be removed
    end
end

% print('SpeedAccuracyPlot_Copulas', '-dpng', '-r400')



%% Histogram with areas of Post Training fit - Pre Training fit

figure(2)

vals1 = improvedAccuracy(1,:);      % Force ON
vals2 = [improvedAccuracy(2,:)];    % Force OFF
plotStackedTransparent(vals1, vals2);





%% Padding for statistic test


IntermittentExposure_Baseline_MaxErrorAmp_Padded = [IntermittentExposure_Baseline_MaxErrorAmp, nan(1, 26)];

NonParametricStatistics([IntermittentExposure_Baseline_MaxErrorAmp_Padded', PostTraining_MaxErrorAmp'], "Statistics_Speed_vs_Accuracy")













%% From here on: functions used in the program





function [medianPosition, stdPosition] = computeMedianAndStandardDeviation(GlobalPosition, oldPosition)

        if nargin < 2
            oldPosition = GlobalPosition{1,1};
        end


        % 2. Find the maximum number of rows (trajectory length)
        maxLen = max(cellfun(@(x) size(x, 1), GlobalPosition));

        % 3. Pad all trajectories to max length using the last value
        for i = 1:length(GlobalPosition)
            traj = GlobalPosition{i};
            padSize = maxLen - size(traj, 1);
            if padSize > 0
                pad = repmat(traj(end, :), padSize, 1);  % replicate last row
                traj = [traj; pad];
            end
            GlobalPosition{i} = traj;  % update
        end

        % 4. Concatenate into a 3D array (time x 3 x repetitions)
        allData = cat(3, GlobalPosition{:});  % size: (maxLen x 3 x numMovements)

        % 5. Compute standard deviation across trials (3rd dimension)
        stdPosition = std(allData, 0, 3, 'omitnan');  % size: (maxLen x 3)

        for movementNumber = 1:length(GlobalPosition)

            % Extract current data
            if (movementNumber == 1)
                oldPos = oldPosition;
            else
                oldPos = medianPosition;
            end
            newPos = GlobalPosition{movementNumber};

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

            % if (movementNumber == 2)
            % % Compute median
            %     medianPosition = median(cat(3, oldPos{1,1}, newPos{1,1}), 3);
            % else
            medianPosition = median(cat(3, oldPos, newPos), 3);
            % end
            % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,1) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,1), Data{movementNumber}.GlobalPosition(:,1)], 2);
            % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,2) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,2), Data{movementNumber}.GlobalPosition(:,2)], 2);
            % GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,3) = median([GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(index)).IntermittentExposure.Dir0(:,3), Data{movementNumber}.GlobalPosition(:,3)], 2);
        end

end





function plotStackedTransparent(valuesOn, valuesOff, yAxisLabel)
    % valuesOn  = e.g. [0.04, 0.03, 0.02]
    % valuesOff = e.g. [-0.02, 0.02, -0.02]

    labels = {"EF group","EA group","SHAM group"};

    % Width of bars
    w = 0.6;  

    hold on
    for i = 1:numel(valuesOn)
        % First vector (Force ON)
        b1 = bar(i, valuesOn(i), w, 'FaceColor',[0.2 0.6 1], 'FaceAlpha',0.6, 'EdgeColor','none');

        % Second vector (Force OFF) drawn at same x position
        b2 = bar(i, valuesOff(i), w, 'FaceColor',[1 0.4 0.4], 'FaceAlpha',0.6, 'EdgeColor','none');
    end
    hold off

    % X-axis labels
    set(gca,'XTick',1:3,'XTickLabel',labels);
    ax = gca;
    ax.LineWidth = 3;   % thickness of x and y axes
    ax.FontSize = 25;   % bigger tick labels
    ax.FontWeight = "bold";

    % Y-axis label
    ylabel("Performance Improvement" + newline+ "After Training", 'FontSize', 35, 'FontWeight','bold');

    % Title with matching colors
    title(['\color[rgb]{0.2,0.6,1} Force ON      \color[rgb]{1,0.4,0.4} Force OFF'], 'FontSize', 25, 'FontWeight','bold');
    set(gca, 'Box', 'off');
    set(gca, 'Color', 'none');
end


