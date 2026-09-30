%% BRUNO BORGHI  -  Baseline average calculation for selected subject during the EF program

clear all; close all; clc;


 %% Select the subjects' ID to be compared


subjectsList    =   ["31", "32", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "47", "48", "49", "50", "51", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63"];



EFgroup         =   ["31", "37", "38", "40", "44", "45", "48", "55", "59", "62"];
EAgroup         =   ["32", "34", "41", "43", "47", "50", "51", "57", "58", "63"];
CONTROLgroup    =   ["35", "36", "39", "42", "49", "53", "54", "56", "60", "61"];



% Metric to analyse and plot. Angle metrics are in [deg], the others in [m].
errorMetric     =   "MaximumErrorAmplitude";
% errorMetric     =   "MaximumPerpendicularError";
% errorMetric     =   "MaximumExtentError";
% errorMetric      =   "LaunchDeviationAngle";


initialFolder           =   pwd;
addpath(initialFolder);

medianGlobalPosition    =   1; % write to 1 if you want to have the median of all the global position in the rose plots




%% Store the data



dir0_Saved = 0;
dir1_Saved = 0;
dir2_Saved = 0;
dir3_Saved = 0;
dir4_Saved = 0;
dir5_Saved = 0;
dir6_Saved = 0;
dir7_Saved = 0;


for count = 1:length(subjectsList)

    cd(strcat([initialFolder+"/"+subjectsList(count)]));                     % Open the folder with the respective data of that subject

    firstMedianCalculation  =   1;
    load(subjectsList(count) + ".mat");
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Baseline.AllDirections                          =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Baseline.Direction0                             =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Baseline.Direction1                             =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Baseline.Direction2                             =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Baseline.Direction3                             =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionThree, errorMetric, 'launch')'];

    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedBaseline.AllDirections               =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionFour, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionFive, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionSix, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.Baseline.DirectionSeven, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedBaseline.Direction4                  =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionFour, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedBaseline.Direction5                  =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionFive, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedBaseline.Direction6                  =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionSix, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedBaseline.Direction7                  =   [GetErrorVector(SpecialMovementIndex.Baseline.DirectionSeven, errorMetric, 'launch')'];
    
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedIntermittentExposure.AllDirections   =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionFour, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionFive, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionSix, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionSeven, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedIntermittentExposure.Direction4      =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionFour, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedIntermittentExposure.Direction5      =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionFive, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedIntermittentExposure.Direction6      =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionSix, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedIntermittentExposure.Direction7      =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionSeven, errorMetric, 'launch')'];

    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure.AllDirections              =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure.Direction0                 =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure.Direction1                 =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure.Direction2                 =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).IntermittentExposure.Direction3                 =   [GetErrorVector(SpecialMovementIndex.IntermittentExposure.DirectionThree, errorMetric, 'launch')'];

    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Training.AllDirections                          =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Training.Direction0                             =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Training.Direction1                             =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Training.Direction2                             =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).Training.Direction3                             =   [GetErrorVector(SpecialMovementIndex.PureTraining.DirectionThree, errorMetric, 'launch')'];
    
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced.AllDirections                =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced.Direction0                   =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced.Direction1                   =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced.Direction2                   =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingForced.Direction3                   =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, errorMetric, 'launch')'];
    
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingForced.AllDirections     =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionFour, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionFive, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionSix, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionSeven, errorMetric, 'launch')'];;
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingForced.Direction4        =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionFour, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingForced.Direction5        =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionFive, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingForced.Direction6        =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionSix, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingForced.Direction7        =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionSeven, errorMetric, 'launch')'];

    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingNoForce.AllDirections               =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingNoForce.Direction0                  =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingNoForce.Direction1                  =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingNoForce.Direction2                  =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTrainingNoForce.Direction3                  =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, errorMetric, 'launch')'];

    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingNoForce.AllDirections    =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionFour, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionFive, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionSix, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionSeven, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingNoForce.Direction4       =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionFour, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingNoForce.Direction5       =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionFive, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingNoForce.Direction6       =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionSix, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).UnpracticedPostTrainingNoForce.Direction7       =   [GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionSeven, errorMetric, 'launch')'];
    
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining.AllDirections                      =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionZero, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionOne, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionTwo, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, errorMetric, 'launch')', GetErrorVector(SpecialMovementIndex.PostTraining.NoForce.DirectionThree, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining.Direction0                         =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionZero, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining.Direction1                         =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionOne, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining.Direction2                         =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionTwo, errorMetric, 'launch')'];
    Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).PostTraining.Direction3                         =   [GetErrorVector(SpecialMovementIndex.PostTraining.Forced.DirectionThree, errorMetric, 'launch')'];


    if (medianGlobalPosition == 1)
        % Store the first value and then skip this for all the successive trials
        if (firstMedianCalculation  ==   1)
            % Baseline
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir0               =   Data{SpecialMovementIndex.Baseline.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir1               =   Data{SpecialMovementIndex.Baseline.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir2               =   Data{SpecialMovementIndex.Baseline.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir3               =   Data{SpecialMovementIndex.Baseline.DirectionThree(1)}.GlobalPosition;
            % Unpracticed Baseline
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir4               =   Data{SpecialMovementIndex.Baseline.DirectionFour(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir5               =   Data{SpecialMovementIndex.Baseline.DirectionFive(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir6               =   Data{SpecialMovementIndex.Baseline.DirectionSix(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir7               =   Data{SpecialMovementIndex.Baseline.DirectionSeven(1)}.GlobalPosition;
            % Unpracticed Intermittent Exposure
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir4   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionFour(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir5   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionFive(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir6   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionSix(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir7   =   Data{SpecialMovementIndex.IntermittentExposure.DirectionSeven(1)}.GlobalPosition;
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
            % Unpracticed Post Training
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir4           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionFour(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir5           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionFive(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir6           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionSix(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir7           =   Data{SpecialMovementIndex.PostTraining.Forced.DirectionSeven(1)}.GlobalPosition;
            % Post Training No Force
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir0    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionZero(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir1    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionOne(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir2    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionTwo(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir3    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionThree(1)}.GlobalPosition;

            % Unpracticed Post Training No Force
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir4    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionFour(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir5    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionFive(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir6    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionSix(1)}.GlobalPosition;
            GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir7    =   Data{SpecialMovementIndex.PostTraining.NoForce.DirectionSeven(1)}.GlobalPosition;

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





        %%%%%%%%%%%%%%%%% Unpracticed Baseline %%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 4
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionFour]'

            if (dir4_Saved == 0 && Data{movementNumber}.MovementDirection == 4)
                GlobalPosition.IdealTrajectory_Dir4 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir4_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir4);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir4_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir4               =   medianPos;


        %%%%%%%%%%%% DIRECTION 5
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionFive]'

            if (dir5_Saved == 0 && Data{movementNumber}.MovementDirection == 5)
                GlobalPosition.IdealTrajectory_Dir5 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir5_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir5);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir5_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir5               =   medianPos;


        %%%%%%%%%%%% DIRECTION 6
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionSix]'

            if (dir6_Saved == 0 && Data{movementNumber}.MovementDirection == 6)
                GlobalPosition.IdealTrajectory_Dir6 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir6_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir6);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir6_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir6               =   medianPos;


        %%%%%%%%%%%% DIRECTION 7
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.Baseline.DirectionSeven]'

            if (dir7_Saved == 0 && Data{movementNumber}.MovementDirection == 7)
                GlobalPosition.IdealTrajectory_Dir7 = [Data{movementNumber}.StartPosition'; Data{movementNumber}.TargetPosition'];
                dir7_Saved                          = 1;
            end

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir7);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir7_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).Baseline.Dir7               =   medianPos;



        %%%%%%%%%%%%%%% Unpracticed Intermittent Exposure %%%%%%%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%% DIRECTION 4
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionFour]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir4);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir4_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir4               =   medianPos;




        %%%%%%%%%%%% DIRECTION 5
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionFive]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir5);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir5_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir5               =   medianPos;





        %%%%%%%%%%%% DIRECTION 6
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionSix]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir6);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir6_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir6               =   medianPos;





        %%%%%%%%%%%% DIRECTION 7

        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.IntermittentExposure.DirectionSeven]'

            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;

        end

       [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir7);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir7_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).IntermittentExposure.Dir7               =   medianPos;

        



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





        %%%%%%%%%%%%%%%% Unpracticed Post Training - Force On %%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 4
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionFour]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir4);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir4_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir4               =   medianPos;




        %%%%%%%%%%%% DIRECTION 5
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionFive]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir5);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir5_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir5               =   medianPos;




        %%%%%%%%%%%% DIRECTION 6
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionSix]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir6);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir6_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir6               =   medianPos;




        %%%%%%%%%%%% DIRECTION 7

        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.Forced.DirectionSeven]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir7);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir7_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTraining.Dir7               =   medianPos;




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




        %%%%%%%%%%%%%%%% Unpracticed Post Training - Force Off %%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% DIRECTION 4
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionFour]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir4);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir4_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir4               =   medianPos;


        %%%%%%%%%%%% DIRECTION 5
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionFive]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir5);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir5_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir5               =   medianPos;


        %%%%%%%%%%%% DIRECTION 6
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionSix]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir6);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir6_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir6               =   medianPos;


        %%%%%%%%%%%% DIRECTION 7
        % Preallocate a cell to collect all the GlobalPosition data
        allPos = {};

        % 1. Loop through all movement numbers and collect GlobalPosition
        for movementNumber = [SpecialMovementIndex.PostTraining.NoForce.DirectionSeven]'
            thisPos = Data{movementNumber}.GlobalPosition - Data{movementNumber}.GlobalPosition(1,:);
            allPos{end+1} = thisPos;
        end

        [medianPos, stdPos] = computeMedianAndStandardDeviation(allPos, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir7);


        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir7_StDeviation   =   stdPos;
        GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).PostTrainingNoForce.Dir7               =   medianPos;




    end

    cd(initialFolder);

end








%% Find the average value of error

phaseToAverage = "Baseline";


for count = 1:length(subjectsList)

    averageMatrix(count,:)      =   Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections;
    averageMatrix_Dir0(count,:) =   Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0;
    averageMatrix_Dir1(count,:) =   Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1;
    averageMatrix_Dir2(count,:) =   Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2;
    averageMatrix_Dir3(count,:) =   Error.(matlab.lang.makeValidName(subjectsList(count))).(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3;


end


% normality test (h=0 means normal distributed)
% A single NaN trial makes mu/sigma NaN and would blank the whole column, so
% the parameters are estimated on the valid subjects only.
for count = 1:size(averageMatrix,2)

    thisColumn  =   averageMatrix(~isnan(averageMatrix(:, count)), count);

    % Estimate parameters
    mu      =   mean(thisColumn);
    sigma   =   std(thisColumn);

    if (numel(thisColumn) < 2 || sigma == 0)
        warning("Normality test skipped for trial %d: %d valid subject(s).", count, numel(thisColumn));
        continue
    end

    % Perform one-sample KS test
    [h,p]   =   kstest((thisColumn - mu)/sigma);

    if (h ~= 0)
    disp(h);
    end

end



%% Mean and 95% condifence interval (CI)

Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections        =   mean(averageMatrix, 1, 'omitnan');
Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections(1,:)   =   mean(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections, 'omitnan');

Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0           =   mean(averageMatrix_Dir0, 1, 'omitnan');
Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0(1,:)      =   mean(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0, 'omitnan');

Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1           =   mean(averageMatrix_Dir1, 1, 'omitnan');
Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1(1,:)      =   mean(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1, 'omitnan');

Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2           =   mean(averageMatrix_Dir2, 1, 'omitnan');
Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2(1,:)      =   mean(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2, 'omitnan');

Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3           =   mean(averageMatrix_Dir3, 1, 'omitnan');
Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3(1,:)      =   mean(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3, 'omitnan');


% Standard error of the mean. NaN trials are omitted, so each trial is divided
% by the number of subjects that actually contributed to it.
SEM_AllDirections   =   std(averageMatrix,      0, 1, 'omitnan') ./ sqrt(sum(~isnan(averageMatrix),      1));    % 1 x 19
SEM_Direction0      =   std(averageMatrix_Dir0, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(averageMatrix_Dir0), 1));
SEM_Direction1      =   std(averageMatrix_Dir1, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(averageMatrix_Dir1), 1));
SEM_Direction2      =   std(averageMatrix_Dir2, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(averageMatrix_Dir2), 1));
SEM_Direction3      =   std(averageMatrix_Dir3, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(averageMatrix_Dir3), 1));

SEM_Direction0(1,:)    =   mean(SEM_Direction0, 'omitnan');
SEM_Direction1(1,:)    =   mean(SEM_Direction1, 'omitnan');
SEM_Direction2(1,:)    =   mean(SEM_Direction2, 'omitnan');
SEM_Direction3(1,:)    =   mean(SEM_Direction3, 'omitnan');


% 95% confidence interval multiplier (t-distribution)
tval = tinv(0.975, (length(subjectsList)-1));


% Half-width of the 95% CI
Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections     =   tval * SEM_AllDirections;    % 1 x 19
Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0        =   tval * SEM_Direction0;   
Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1        =   tval * SEM_Direction1;
Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2        =   tval * SEM_Direction2; 
Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3        =   tval * SEM_Direction3;  



%% Plot

% Read current figure position (units are pixels by default)
f = gcf;
pos = f.Position;   % pos = [left bottom width height]

% ...later create or use another figure and set the same size:
f = figure; 
f.Position = pos;

subjectToPlot   =   ["P-2"];
visitToPlot     =   "Visit_4";

upper_AllDirections     =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections + Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections;
lower_AllDirections     =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections - Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections;

upper_Direction0        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0 + Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0;
lower_Direction0        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0 - Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0;

upper_Direction1        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1 + Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1;
lower_Direction1        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1 - Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1;

upper_Direction2        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2 + Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2;
lower_Direction2        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2 - Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2;

upper_Direction3        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3 + Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3;
lower_Direction3        =   Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3 - Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3;


x_AllDirections =   1:length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections);
x_Direction0    =   1:length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0);
x_Direction1    =   1:length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1);
x_Direction2    =   1:length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2);
x_Direction3    =   1:length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3);


% % --- Shaded area ---
% fill([x fliplr(x)], [upper fliplr(lower)], [0.8 0.8 1], 'LineStyle','none');      
% hold on;
% 
% % --- Mean curve ---
% plot(x, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)), 'b', 'LineWidth', 2);
    
x_target_AllDirections  =   linspace(0, 210, length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections));   % 19 points stretched over 0–210
x_target_Direction0     =   linspace(0, 4, length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0));
x_target_Direction1     =   linspace(4, 8, length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1));
x_target_Direction2     =   linspace(8, 12, length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2));
x_target_Direction3     =   linspace(12, 16, length(Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3));

x_smooth    =   linspace(0, 210, 589);
x_smooth_0  =   linspace(0, 4, 589);
x_smooth_1  =   linspace(4, 8, 589);
x_smooth_2  =   linspace(8, 12, 589);
x_smooth_3  =   linspace(12, 16, 589);

m_interp_AllDirections  =   interp1(x_target_AllDirections, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections,  x_smooth, 'pchip');
CI_interp_AllDirections =   interp1(x_target_AllDirections, Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).AllDirections, x_smooth, 'pchip');

m_interp_Direction0  =   interp1(x_target_Direction0, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0,  x_smooth_0, 'pchip');
CI_interp_Direction0 =   interp1(x_target_Direction0, Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction0, x_smooth_0, 'pchip');

m_interp_Direction1  =   interp1(x_target_Direction1, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1,  x_smooth_1, 'pchip');
CI_interp_Direction1 =   interp1(x_target_Direction1, Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction1, x_smooth_1, 'pchip');

m_interp_Direction2  =   interp1(x_target_Direction2, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2,  x_smooth_2, 'pchip');
CI_interp_Direction2 =   interp1(x_target_Direction2, Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction2, x_smooth_2, 'pchip');

m_interp_Direction3  =   interp1(x_target_Direction3, Error.Average.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3,  x_smooth_3, 'pchip');
CI_interp_Direction3 =   interp1(x_target_Direction3, Error.ConfidenceInterval.(matlab.lang.makeValidName(errorMetric)).(matlab.lang.makeValidName(phaseToAverage)).Direction3, x_smooth_3, 'pchip');


upper_AllDirections     =   m_interp_AllDirections + CI_interp_AllDirections;
lower_AllDirections     =   m_interp_AllDirections - CI_interp_AllDirections;

upper_Direction0     =   m_interp_Direction0 + CI_interp_Direction0;
lower_Direction0     =   m_interp_Direction0 - CI_interp_Direction0;

upper_Direction1     =   m_interp_Direction1 + CI_interp_Direction1;
lower_Direction1     =   m_interp_Direction1 - CI_interp_Direction1;

upper_Direction2     =   m_interp_Direction2 + CI_interp_Direction2;
lower_Direction2     =   m_interp_Direction2 - CI_interp_Direction2;

upper_Direction3     =   m_interp_Direction3 + CI_interp_Direction3;
lower_Direction3     =   m_interp_Direction3 - CI_interp_Direction3;

% plot error time series
C   =   EquiDistantColorGenerator(4,9742);

cd(strcat([initialFolder+"/"+subjectToPlot]));                     % Open the folder with the respective data of that subject
load(subjectToPlot + "_" + visitToPlot +".mat");

[maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]  =   PlotErrorTimeSeries([5:numel(Data)],errorMetric,'launch', false, false);

% AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.MovementNumbers,ErrorFit.MaximumErrorAmplitude.Fitness,ErrorFit.MaximumErrorAmplitude.Ensemble,[0.3,0.3,0.3],[0.6,0.6,0.6])

cd(initialFolder);

% Shaded CI
% h_All   =   fill(maxErrAmpPlotAxHandle, [x_smooth fliplr(x_smooth)],
% [upper_AllDirections     fliplr(lower_AllDirections)], 'k', 'FaceAlpha', 0.4, 'EdgeColor', 'none');   % Plot shaded area for all directions
% hold on;
h_0     =   fill(maxErrAmpPlotAxHandle, [x_smooth_0 fliplr(x_smooth_0)], [upper_Direction0     fliplr(lower_Direction0)], C(1,:), 'FaceAlpha', 0.6, 'EdgeColor', 'none');   % Direction 0
hold on
h_1     =   fill(maxErrAmpPlotAxHandle, [x_smooth_1 fliplr(x_smooth_1)], [upper_Direction1     fliplr(lower_Direction1)], C(2,:), 'FaceAlpha', 0.6, 'EdgeColor', 'none');
hold on;
h_2     =   fill(maxErrAmpPlotAxHandle, [x_smooth_2 fliplr(x_smooth_2)], [upper_Direction2     fliplr(lower_Direction2)], C(3,:), 'FaceAlpha', 0.6, 'EdgeColor', 'none');
hold on;
h_3     =   fill(maxErrAmpPlotAxHandle, [x_smooth_3 fliplr(x_smooth_3)], [upper_Direction3     fliplr(lower_Direction3)], C(4,:), 'FaceAlpha', 0.6, 'EdgeColor', 'none');


% Mean curve
% plot(maxErrAmpPlotAxHandle, x_smooth, m_interp_AllDirections, 'k', 'LineWidth', 4);
h_plot_0    =   plot(maxErrAmpPlotAxHandle, x_smooth_0, m_interp_Direction0, '--', 'Color', C(1,:), 'LineWidth', 4);
h_plot_1    =   plot(maxErrAmpPlotAxHandle, x_smooth_1, m_interp_Direction1, '--', 'Color', C(2,:), 'LineWidth', 4);
h_plot_2    =   plot(maxErrAmpPlotAxHandle, x_smooth_2, m_interp_Direction2, '--', 'Color', C(3,:), 'LineWidth', 4);
h_plot_3    =   plot(maxErrAmpPlotAxHandle, x_smooth_3, m_interp_Direction3, '--', 'Color', C(4,:), 'LineWidth', 4);

uistack([h_0; h_plot_0],'bottom');
uistack([h_1; h_plot_1],'bottom');
uistack([h_2; h_plot_2],'bottom');
uistack([h_3; h_plot_3],'bottom');



%% Figure 2 - Normalized pre/post training delta (EF visits)
% DELTA = (Pre Training - Post Training) / Pre Training, for each movement direction.
% Pre  = mean of the last  nTrialsToAverage good trials per direction with MovementNumber < preTrainingEnd
% Post = mean of the first nTrialsToAverage good trials per direction with MovementNumber > postTrainingStart
% Dots = (Pre - single Post trial) / Pre, one per post-training trial, to show the post-training variability

deltaSubject        =   "P-2";
deltaVisits         =   ["Visit_2", "Visit_4"];        % Visits with the EF force on
preTrainingEnd      =   210;                            % Training phase starts here
postTrainingStart   =   547;                            % Training phase ends here
nTrialsToAverage    =   5;
deltaDirections     =   0:3;
deltaColors         =   [0.45 0.62 0.80; 0 0 0];       % Visit 2 light blue, Visit 4 black
deltaLabels         =   ["EF + tDCS", "EF + SHAM tDCS"];

deltaMatrix         =   nan(numel(deltaDirections), numel(deltaVisits));
roseData            =   cell(1, numel(deltaVisits));       % Data of each visit, kept to draw the Pre / Post rose plots

for visitCount = 1:numel(deltaVisits)

    visitData   =   load(initialFolder + "/" + deltaSubject + "/" + deltaSubject + "_" + deltaVisits(visitCount) + ".mat");
    roseData{visitCount}    =   visitData.Data;

    fprintf('\n%s %s - %s\n', deltaSubject, deltaVisits(visitCount), errorMetric);
    [prePost.Pre, prePost.Post, prePost.Delta, prePost.PostTrialDelta, prePost.PreTrialError, prePost.PostTrialError, prePost.PreDataIndex, prePost.PostDataIndex]  =   computeNormalizedDelta(visitData, errorMetric, deltaDirections, preTrainingEnd, postTrainingStart, nTrialsToAverage);

    DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount))  =   prePost;
    deltaMatrix(:, visitCount)                                                          =   prePost.Delta;
end

figure('Name', 'Figure 2 - Normalized Delta');
deltaDirectionColors    =   EquiDistantColorGenerator(4, 9742);     % Same direction colors as the time-series plot (C)
deltaBars   =   bar(deltaDirections, deltaMatrix, 'grouped', 'LineWidth', 4);
for visitCount = 1:numel(deltaVisits)
    deltaBars(visitCount).FaceColor     =   'flat';
    deltaBars(visitCount).CData         =   deltaDirectionColors(1:numel(deltaDirections), :);   % Fill = movement direction
    deltaBars(visitCount).EdgeColor     =   deltaColors(visitCount, :);                          % Contour = visit (tDCS / SHAM)
end
yline(0, 'k', 'LineWidth', 2);

% One dot per post-training trial on top of its bar: fill = direction color, outline = visit color
hold on;
for visitCount = 1:numel(deltaVisits)
    postTrialDelta  =   DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount)).PostTrialDelta;
    for dirCount = 1:numel(deltaDirections)
        dotValues   =   postTrialDelta{dirCount};
        dotSpread   =   linspace(-0.06, 0.06, numel(dotValues)) * (numel(dotValues) > 1);   % small horizontal spread so dots don't stack
        scatter(deltaBars(visitCount).XEndPoints(dirCount) + dotSpread, dotValues, 450, ...
            'MarkerFaceColor', deltaDirectionColors(dirCount, :), 'MarkerEdgeColor', deltaColors(visitCount, :), 'LineWidth', 2.5);
    end
end
hold off;

set(gca, 'XTick', deltaDirections, 'XTickLabel', "Dir " + string(deltaDirections));
ax              =   gca;
ax.LineWidth    =   3;
ax.FontSize     =   25;
ax.FontWeight   =   "bold";
set(gca, 'Box', 'off');

xlabel("Movement Direction", 'FontSize', 30, 'FontWeight', 'bold');
ylabel("(Pre - Post) / Pre", 'FontSize', 30, 'FontWeight', 'bold');
title(deltaSubject + " - Normalized " + errorMetric + " change after training", 'FontSize', 25, 'FontWeight', 'bold');

% Colored labels stacked to the right of the last bar group (xlim widened to make room)
xlim([deltaDirections(1) - 0.5, deltaDirections(end) + 2.2]);
yLimits     =   ylim;
for visitCount = 1:numel(deltaVisits)
    text(deltaDirections(end) + 0.5, yLimits(2) - (visitCount - 1) * 0.1 * diff(yLimits), deltaLabels(visitCount), ...
        'Color', deltaColors(visitCount, :), 'FontSize', 32, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
end

% Rose plots of the trials behind the bars (all 4 directions): one Pre / Post pair per visit, stacked under the labels
preRoseIndex    =   cell(1, numel(deltaVisits));
postRoseIndex   =   cell(1, numel(deltaVisits));
for visitCount = 1:numel(deltaVisits)
    preRoseIndex{visitCount}    =   [DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount)).PreDataIndex{:}];
    postRoseIndex{visitCount}   =   [DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount)).PostDataIndex{:}];
end
roseCenters     =   [(deltaDirections(end) + 1.45) * [1; 1], yLimits(2) - [0.38; 0.72] * diff(yLimits)];
AddPrePostRoseInsets(gcf, ax, roseCenters, 0.13, roseData, preRoseIndex, postRoseIndex, deltaColors);


% All directions pooled: one bar per visit, using the same pre / post trials selected above for each direction.
% Pre = mean of all the selected pre trials, Post = mean of all the selected post trials, DELTA = (Pre - Post) / Pre
% Dots = (Pre - single Post trial) / Pre, filled with the color of the trial's direction
deltaAllDirections      =   nan(1, numel(deltaVisits));
postTrialDeltaAll       =   cell(1, numel(deltaVisits));
postTrialDirectionAll   =   cell(1, numel(deltaVisits));

for visitCount = 1:numel(deltaVisits)
    prePost     =   DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount));
    preAll      =   [prePost.PreTrialError{:}];
    postAll     =   [prePost.PostTrialError{:}];

    prePost.PreAllDirections        =   mean(preAll);
    prePost.PostAllDirections       =   mean(postAll);
    prePost.DeltaAllDirections      =   (prePost.PreAllDirections - prePost.PostAllDirections) / prePost.PreAllDirections;
    DeltaAnalysis.(matlab.lang.makeValidName(deltaSubject)).(deltaVisits(visitCount))  =   prePost;

    deltaAllDirections(visitCount)      =   prePost.DeltaAllDirections;
    postTrialDeltaAll{visitCount}       =   (prePost.PreAllDirections - postAll) ./ prePost.PreAllDirections;
    postTrialDirectionAll{visitCount}   =   repelem(1:numel(deltaDirections), cellfun(@numel, prePost.PostTrialError)');

    fprintf('\n%s %s - all directions: pre = %.4f (%d trials), post = %.4f (%d trials), delta = %.3f\n', deltaSubject, deltaVisits(visitCount), ...
        prePost.PreAllDirections, numel(preAll), prePost.PostAllDirections, numel(postAll), prePost.DeltaAllDirections);
end

figure('Name', 'Figure 2 - Normalized Delta (All Directions)');
hold on;
for visitCount = 1:numel(deltaVisits)
    bar(visitCount, deltaAllDirections(visitCount), 0.6, 'FaceColor', 'w', 'EdgeColor', deltaColors(visitCount, :), 'LineWidth', 4);
    dotValues   =   postTrialDeltaAll{visitCount};
    dotSpread   =   linspace(-0.2, 0.2, numel(dotValues)) * (numel(dotValues) > 1);   % small horizontal spread so dots don't stack
    scatter(visitCount + dotSpread, dotValues, 450, deltaDirectionColors(postTrialDirectionAll{visitCount}, :), 'filled', ...
        'MarkerEdgeColor', deltaColors(visitCount, :), 'LineWidth', 2.5);
end
yline(0, 'k', 'LineWidth', 2);
hold off;

set(gca, 'XTick', 1:numel(deltaVisits), 'XTickLabel', deltaLabels);
xlim([0.4, numel(deltaVisits) + 0.6]);
ax              =   gca;
ax.LineWidth    =   3;
ax.FontSize     =   25;
ax.FontWeight   =   "bold";
set(gca, 'Box', 'off');

ylabel("(Pre - Post) / Pre", 'FontSize', 30, 'FontWeight', 'bold');
title(deltaSubject + " - Normalized " + errorMetric + " change after training (all directions)", 'FontSize', 25, 'FontWeight', 'bold');

% Rose plots of the trials behind each bar: Pre / Post pair right above each visit (ylim raised to make room)
yLimits     =   ylim;
ylim([yLimits(1), yLimits(2) + 0.5 * diff(yLimits)]);
roseCenters     =   [(1:numel(deltaVisits))', (yLimits(2) + 0.14 * diff(yLimits)) * ones(numel(deltaVisits), 1)];
AddPrePostRoseInsets(gcf, ax, roseCenters, 0.16, roseData, preRoseIndex, postRoseIndex, deltaColors);



%% External Functions

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




function [preMean, postMean, delta, postTrialDelta, preTrialError, postTrialError, preDataIndex, postDataIndex] = computeNormalizedDelta(visitData, errorMetric, directions, preEnd, postStart, nTrials)
    % For each direction: mean of the last nTrials good trials before preEnd, mean of the
    % first nTrials good trials after postStart, and delta = (pre - post) / pre.
    % postTrialDelta{dir} = (pre - each single post trial) / pre.
    % preTrialError{dir} / postTrialError{dir} = error of each selected pre / post trial.
    % preDataIndex{dir} / postDataIndex{dir} = index in Data of each selected pre / post trial (for DrawRoses).
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
        isGoodTrial(index)          =   ~strcmp(Data{index}.BadTrialFlag, 'y') && ~isequal(Data{index}.UnIdealStart, true) && ~isempty(Data{index}.PathDistance);
    end

    candidateIndex                      =   find(isGoodTrial);
    errorValue                          =   nan(nData, 1);
    errorValue(candidateIndex)          =   GetErrorVector(candidateIndex, errorMetric, 'launch');
    isGoodTrial                         =   isGoodTrial & ~isnan(errorValue);      % NaN = rest / phase-beginning trial

    preMean     =   nan(numel(directions), 1);
    postMean    =   nan(numel(directions), 1);
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

        if numel(preIndex) < nTrials || numel(postIndex) < nTrials
            warning('Direction %d: only %d pre and %d post good trials found (wanted %d).', directions(dirCount), numel(preIndex), numel(postIndex), nTrials);
        end

        preMean(dirCount)   =   mean(errorValue(preIndex));
        postMean(dirCount)  =   mean(errorValue(postIndex));
        postTrialDelta{dirCount}    =   (preMean(dirCount) - errorValue(postIndex)') ./ preMean(dirCount);
        preTrialError{dirCount}     =   errorValue(preIndex)';
        postTrialError{dirCount}    =   errorValue(postIndex)';
        preDataIndex{dirCount}      =   preIndex';
        postDataIndex{dirCount}     =   postIndex';

        fprintf('Dir %d  pre  trials [%s]  mean = %.4f\n', directions(dirCount), num2str(movementNumber(preIndex)'), preMean(dirCount));
        fprintf('Dir %d  post trials [%s]  mean = %.4f\n', directions(dirCount), num2str(movementNumber(postIndex)'), postMean(dirCount));
    end

    delta   =   (preMean - postMean) ./ preMean;
end


function roseAxes = AddPrePostRoseInsets(figureHandle, barAxes, centers, insetSize, roseData, preIndex, postIndex, visitColors)
    % Draws a Pre and a Post rose plot (DrawRoses) side by side for each visit, as small axes floating on top of barAxes.
    % centers(visit, :) = [x y] of the pair in barAxes data units (Pre on the left of x, Post on the right).
    % insetSize = side of each rose in figure normalized units. preIndex / postIndex{visit} = Data indexes to draw.
    % All roses share the same limits so Pre / Post and the visits can be compared.

    barPosition     =   barAxes.Position;
    xLimits         =   barAxes.XLim;
    yLimits         =   barAxes.YLim;
    roseAxes        =   gobjects(size(centers, 1), 2);
    roseLabels      =   ["Pre", "Post"];

    for visitCount = 1:size(centers, 1)
        xNormalized     =   barPosition(1) + (centers(visitCount, 1) - xLimits(1)) / diff(xLimits) * barPosition(3);
        yNormalized     =   barPosition(2) + (centers(visitCount, 2) - yLimits(1)) / diff(yLimits) * barPosition(4);
        roseIndex       =   {preIndex{visitCount}, postIndex{visitCount}};

        for prePostCount = 1:2
            roseAxes(visitCount, prePostCount)  =   axes('Parent', figureHandle, 'Position', [xNormalized + (prePostCount - 2) * insetSize, yNormalized - insetSize / 2, insetSize, insetSize]);
            DrawRoses(roseAxes(visitCount, prePostCount), roseData{visitCount}, roseIndex{prePostCount}, 1, 1);     % any 4th / 5th input = colored by direction, no force arrows
            axis(roseAxes(visitCount, prePostCount), "equal");
            axis(roseAxes(visitCount, prePostCount), "tight");
            axis(roseAxes(visitCount, prePostCount), "off");
            view(roseAxes(visitCount, prePostCount), 26, 26);
            title(roseAxes(visitCount, prePostCount), roseLabels(prePostCount), 'Color', visitColors(visitCount, :), 'FontSize', 18, 'FontWeight', 'bold', 'Visible', 'on');
        end
    end

    % Same scale for every rose
    allLimits   =   [vertcat(roseAxes.XLim), vertcat(roseAxes.YLim), vertcat(roseAxes.ZLim)];
    set(roseAxes, 'XLim', [min(allLimits(:, 1)), max(allLimits(:, 2))], 'YLim', [min(allLimits(:, 3)), max(allLimits(:, 4))], 'ZLim', [min(allLimits(:, 5)), max(allLimits(:, 6))]);
    for roseCount = 1:numel(roseAxes)
        camzoom(roseAxes(roseCount), 1.8);      % the 3D box of an equal-axis rose is much bigger than the trajectories, zoom in to fill the inset
    end
    figureHandle.CurrentAxes    =   barAxes;       % leave the bar axes as the current axes without moving them over the roses
end
