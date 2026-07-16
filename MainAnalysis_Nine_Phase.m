clear all;close all;clc

%% Load Data From Files
global ErrorFit Data InputFile PhaseIndex SpecialMovementIndex InterpolatedData IntermittentExposureData HypothesisTest SysID PostTrainingDistributions PrePostAnalysis
oldFolder=pwd;
% % % % % % % % % % % % % % % % COMPLETED SUBJECTS

% % % % % % % GROUP 1
% % newFolder=strcat(oldFolder,'/31/8222024/');
% newFolder=strcat(oldFolder,'/37/162025/');
% % newFolder=strcat(oldFolder,'/38/172025/');
% % newFolder=strcat(oldFolder,'/40/182025/');
% % newFolder=strcat(oldFolder,'/44/6102025/');
% % newFolder=strcat(oldFolder,'/45/6112025/');
% % newFolder=strcat(oldFolder,'/48/6232025/');
% % newFolder=strcat(oldFolder,'/55/7112025/');
% % newFolder=strcat(oldFolder,'/59/852025/');
% newFolder=strcat(oldFolder,'/60/922025/');



% % % % % % % GROUP 2
% % newFolder=strcat(oldFolder,'/32/1142024/');
% % newFolder=strcat(oldFolder,'/34/12112024/');
% % newFolder=strcat(oldFolder,'/41/192025/');
% % newFolder=strcat(oldFolder,'/43/712025/');
% % newFolder=strcat(oldFolder,'/47/6122025/');
% % newFolder=strcat(oldFolder,'/50/6232025/');
% % newFolder=strcat(oldFolder,'/51/6242025/');
% % newFolder=strcat(oldFolder,'/57/7152025/');
% newFolder=strcat(oldFolder,'/58/842025/');



% % % % % % % GROUP 3
% % newFolder=strcat(oldFolder,'/35/12182024/');
% % newFolder=strcat(oldFolder,'/36/12192024/');
% % newFolder=strcat(oldFolder,'/39/712025/');
% % newFolder=strcat(oldFolder,'/42/6262025/');
% % newFolder=strcat(oldFolder,'/49/6242025/');
% % newFolder=strcat(oldFolder,'/53/712025/');
% % newFolder=strcat(oldFolder,'/54/7102025/');
% % newFolder=strcat(oldFolder,'/56/7142025/');
% % newFolder=strcat(oldFolder,'/61/11102025/');
% % newFolder=strcat(oldFolder,'/62/11142025/');
newFolder=strcat(oldFolder,'/63/11142025/');


% % % % % % % % % % % % % % % % IN-PROGRESS SUBJECTS



copyfile('ExtractFromCSV.m',newFolder); 
copyfile('ExtractFromNinePhaseInputCSV.m',newFolder);
copyfile('hdrload.m',newFolder);
copyfile('ReadInterpolatedErrorFiles.m',newFolder);
copyfile('ReadIntermittentExposureMovementFiles.m',newFolder);

cd(newFolder);
filesInDirectory=[];
filesInDirectoryTemp=dir;
for counter=1:numel(filesInDirectoryTemp)
   if(filesInDirectoryTemp(counter).bytes>=10000)
       filesInDirectory=[filesInDirectory;filesInDirectoryTemp(counter)];
   end
end
fileNames={filesInDirectory.name}.';
fileNamesIndex=[];
for counter=1:numel(fileNames)
%     disp(fileNames{counter})    % Line commented because it diplay on
%     video all the values and slow down a lot the running process
    if contains(fileNames{counter},'Participant_')
        fileNamesIndex=[fileNamesIndex;counter;];
    end
%     disp("counter = "+counter+" "+fileNames{counter}+" : "+contains(fileNames{counter},'Participant_'))
end
sortedFileNames=cell(numel(fileNamesIndex),1);
for counter=1:numel(fileNamesIndex)
    tempString=fileNames{fileNamesIndex(counter)};
    underlinePositions=strfind(tempString,'_');
    dotPoistion=strfind(tempString,'.');
    first=underlinePositions(end);
    last=dotPoistion;
    tempString=tempString(first+1:last-1);
    position=str2num(tempString);
    if position==0
        continue
    else
        sortedFileNames{position}=fileNames{fileNamesIndex(counter)};
    end
end
dataCounter=1;
for movementCounter=1:length(sortedFileNames)
    disp(movementCounter);
    if ~isequal(sortedFileNames{movementCounter},[])
        Data{dataCounter,1}=ExtractFromCSV(sortedFileNames{movementCounter});
        dataCounter=dataCounter+1;
    end
end
clear tempString tempStringLength sortedFileNames position movementCounter filesInDirectory fileNames fileNamesIndex counter first last underlinePositions dataCounter filesInDirectoryTemp dotPoistion
switch Data{1}.ExperimentMode
    case '2D'
        InputFile=ExtractFromNinePhaseInputCSV('HealthyExperimentDesign2D.csv');
        InterpolatedData.DirectionZero=ReadInterpolatedErrorFiles(0);
        IntermittentExposureData.DirectionZero=ReadIntermittentExposureMovementFiles(0);
        InterpolatedData.DirectionOne=ReadInterpolatedErrorFiles(1);
        IntermittentExposureData.DirectionOne=ReadIntermittentExposureMovementFiles(1);
        InterpolatedData.DirectionTwo=ReadInterpolatedErrorFiles(2);
        IntermittentExposureData.DirectionTwo=ReadIntermittentExposureMovementFiles(2);
    case '3D'
        InputFile=ExtractFromNinePhaseInputCSV('HealthyExperimentDesign3D.csv');
        InterpolatedData.DirectionZero=ReadInterpolatedErrorFiles(0);
        IntermittentExposureData.DirectionZero=ReadIntermittentExposureMovementFiles(0);
        InterpolatedData.DirectionOne=ReadInterpolatedErrorFiles(1);
        IntermittentExposureData.DirectionOne=ReadIntermittentExposureMovementFiles(1);
        InterpolatedData.DirectionTwo=ReadInterpolatedErrorFiles(2);
        IntermittentExposureData.DirectionTwo=ReadIntermittentExposureMovementFiles(2);
        InterpolatedData.DirectionThree=ReadInterpolatedErrorFiles(3);
        IntermittentExposureData.DirectionThree=ReadIntermittentExposureMovementFiles(3);
end

cd(oldFolder)
clear oldFolder newFolder type


% Getting The Phase Indexes

familiarizationIndex=[];
baselineIndex=[];
unpracticedIntermittentExposurePhaseIndex=[];
intermittentExposurePhase=[];
trainingPhase=[];
testPhase=[];
unpracticedTestPhase=[];
washoutPhase=[];
unpracticedWashoutPhase=[];

for counter=1:numel(Data)
    if isstruct(Data{counter}) == false || ismember(Data{counter}.MovementNumber, InputFile.RestTrials) || Data{counter}.PhaseBeginningTrial
        continue
    else
        if  strcmp(Data{counter}.ExperimentPhase(1:3),'Sta')==true(1) || strcmp(Data{counter}.ExperimentPhase(1:3),'End')==true(1)
            continue
        elseif strcmp(Data{counter}.ExperimentPhase(1:3),'Fam')==true(1)
            familiarizationIndex=[familiarizationIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'BaselinePhase')==true(1)
            baselineIndex=[baselineIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'UnpracticedIntermittentExposurePhase')==true(1)
            unpracticedIntermittentExposurePhaseIndex=[unpracticedIntermittentExposurePhaseIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'IntermittentExposurePhase')==true(1)
            intermittentExposurePhase=[intermittentExposurePhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'TrainingPhase')==true(1)
            trainingPhase=[trainingPhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'TestPhase')==true(1)
            testPhase=[testPhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'UnpracticedTestPhase')==true(1)
            unpracticedTestPhase=[unpracticedTestPhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'WashoutPhase')==true(1)
            washoutPhase=[washoutPhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'UnpracticedWashoutPhase')==true(1)
            unpracticedWashoutPhase=[unpracticedWashoutPhase;counter];
        end
    end
    disp(['MovementNumber: ', num2str(Data{counter}.MovementNumber)]);
    disp(['Is Rest Trial: ', num2str(ismember(Data{counter}.MovementNumber, InputFile.RestTrials))]);
end
PhaseIndex.Familiarization=familiarizationIndex;
PhaseIndex.UnpracticedIntermittentExposure=unpracticedIntermittentExposurePhaseIndex;
PhaseIndex.Baseline=baselineIndex;
PhaseIndex.IntermittentExposure=intermittentExposurePhase;
PhaseIndex.Training=trainingPhase;
PhaseIndex.Test=testPhase;
PhaseIndex.UnpracticedTest=unpracticedTestPhase;
PhaseIndex.Washout=washoutPhase;
PhaseIndex.UnpracticedWashout=unpracticedWashoutPhase;
clear familiarizationIndex unpracticedIntermittentExposurePhaseIndex baselineIndex intermittentExposurePhase trainingPhase testPhase unpracticedTestPhase washoutPhase unpracticedWashoutPhase counter
% Special Movements
% Intermittent Exposure (pre-training force on)
SpecialMovementIndex.IntermittentExposure.DirectionZero=[];
SpecialMovementIndex.IntermittentExposure.DirectionOne=[];
SpecialMovementIndex.IntermittentExposure.DirectionTwo=[];
SpecialMovementIndex.IntermittentExposure.DirectionThree=[];
SpecialMovementIndex.IntermittentExposure.DirectionFour=[];
SpecialMovementIndex.IntermittentExposure.DirectionFive=[];
SpecialMovementIndex.IntermittentExposure.DirectionSix=[];
SpecialMovementIndex.IntermittentExposure.DirectionSeven=[];
allINTXIndexes=sort([PhaseIndex.UnpracticedIntermittentExposure;PhaseIndex.IntermittentExposure]);
for counter=1:numel(allINTXIndexes)
    tempDirection=Data{allINTXIndexes(counter)}.MovementDirection;
    tempMovementNumber=Data{allINTXIndexes(counter)}.MovementNumber;
    if InputFile.Dictionary(tempMovementNumber).DistortionType==1
            switch tempDirection
                case 0
                    SpecialMovementIndex.IntermittentExposure.DirectionZero=[SpecialMovementIndex.IntermittentExposure.DirectionZero;allINTXIndexes(counter)];
                case 1
                    SpecialMovementIndex.IntermittentExposure.DirectionOne=[SpecialMovementIndex.IntermittentExposure.DirectionOne;allINTXIndexes(counter)];
                case 2
                    SpecialMovementIndex.IntermittentExposure.DirectionTwo=[SpecialMovementIndex.IntermittentExposure.DirectionTwo;allINTXIndexes(counter)];
                case 3
                    SpecialMovementIndex.IntermittentExposure.DirectionThree=[SpecialMovementIndex.IntermittentExposure.DirectionThree;allINTXIndexes(counter)];
                case 4
                    SpecialMovementIndex.IntermittentExposure.DirectionFour=[SpecialMovementIndex.IntermittentExposure.DirectionFour;allINTXIndexes(counter)];
                case 5
                    SpecialMovementIndex.IntermittentExposure.DirectionFive=[SpecialMovementIndex.IntermittentExposure.DirectionFive;allINTXIndexes(counter)];
                case 6
                    SpecialMovementIndex.IntermittentExposure.DirectionSix=[SpecialMovementIndex.IntermittentExposure.DirectionSix;allINTXIndexes(counter)];
                case 7
                    SpecialMovementIndex.IntermittentExposure.DirectionSeven=[SpecialMovementIndex.IntermittentExposure.DirectionSeven;allINTXIndexes(counter)];
            end
    end
    clear tempDirection tempMovementNumber
end
clear allINTXIndexes

% Unpractice Intermittent Exposure (unpracticed pre-training force on)



% Training trials
SpecialMovementIndex.PureTraining.DirectionZero=[];
SpecialMovementIndex.PureTraining.DirectionOne=[];
SpecialMovementIndex.PureTraining.DirectionTwo=[];
SpecialMovementIndex.PureTraining.DirectionThree=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionZero=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionOne=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionTwo=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionThree=[];
SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionZero=[];
SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionOne=[];
SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionTwo=[];
SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionThree=[];

for counter=1:numel(PhaseIndex.Training)
    tempDirection=Data{PhaseIndex.Training(counter)}.MovementDirection;
    tempMovementNumber=Data{PhaseIndex.Training(counter)}.MovementNumber;
    if InputFile.Dictionary(tempMovementNumber).DistortionType==0
        switch tempDirection
            case 0
                SpecialMovementIndex.AdaptationCatchTrial.DirectionZero=[SpecialMovementIndex.AdaptationCatchTrial.DirectionZero;PhaseIndex.Training(counter)];
            case 1
                SpecialMovementIndex.AdaptationCatchTrial.DirectionOne=[SpecialMovementIndex.AdaptationCatchTrial.DirectionOne;PhaseIndex.Training(counter)];
            case 2
                SpecialMovementIndex.AdaptationCatchTrial.DirectionTwo=[SpecialMovementIndex.AdaptationCatchTrial.DirectionTwo;PhaseIndex.Training(counter)];
            case 3
                SpecialMovementIndex.AdaptationCatchTrial.DirectionThree=[SpecialMovementIndex.AdaptationCatchTrial.DirectionThree;PhaseIndex.Training(counter)];
        end
    elseif InputFile.Dictionary(tempMovementNumber).DistortionType==2
        switch tempDirection
            case 0
                SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionZero=[SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionZero;PhaseIndex.Training(counter)];
            case 1
                SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionOne=[SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionOne;PhaseIndex.Training(counter)];
            case 2
                SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionTwo=[SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionTwo;PhaseIndex.Training(counter)];
            case 3
                SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionThree=[SpecialMovementIndex.PerformanceInFieldCatchTrail.DirectionThree;PhaseIndex.Training(counter)];
        end
    elseif InputFile.Dictionary(tempMovementNumber).DistortionType==1
        switch tempDirection
            case 0
                SpecialMovementIndex.PureTraining.DirectionZero=[SpecialMovementIndex.PureTraining.DirectionZero;PhaseIndex.Training(counter)];
            case 1
                SpecialMovementIndex.PureTraining.DirectionOne=[SpecialMovementIndex.PureTraining.DirectionOne;PhaseIndex.Training(counter)];
            case 2
                SpecialMovementIndex.PureTraining.DirectionTwo=[SpecialMovementIndex.PureTraining.DirectionTwo;PhaseIndex.Training(counter)];
            case 3
                SpecialMovementIndex.PureTraining.DirectionThree=[SpecialMovementIndex.PureTraining.DirectionThree;PhaseIndex.Training(counter)];
        end
    end
    clear tempDirection tempMovementNumber
end
clear counter
AddPostTrainingPhaseIndexToSpecialMovementIndex;

% Calculate Error Amplitude and MAX Errors, Directional Error
for counter=1:numel(Data)
    if isstruct(Data{counter})==false
        continue
    else
        tempExtErr=Data{counter}.ExtentError;
        temHorErr=Data{counter}.HorizontalError;
        tempVerErr=Data{counter}.VerticalError;
        tempSpeed=vecnorm(Data{counter}.GlobalVelocity')';
        tempPosition=Data{counter}.GlobalPosition;
        if isempty(Data{counter}.OnsetDetectedIndex)
            Data{counter}.ErrorAmplitude=vecnorm([tempExtErr,temHorErr,tempVerErr]')';
            Data{counter}.Maximum.Launch.ErrorAmplitude=nan;
            Data{counter}.Maximum.Launch.ExtentError=nan;
            Data{counter}.Maximum.Launch.HorizontalError=nan;
            Data{counter}.Maximum.Launch.VerticalError=nan;
            Data{counter}.Maximum.Launch.PerpendicularError=nan;
            Data{counter}.Maximum.Launch.Speed=nan;
            Data{counter}.LaunchDeviationAngle=nan;
            Data{counter}.BadTrialFlag='y';
        else
            tempLaunchIndex=GetLaunchIndex(Data{counter}.OnsetDetectedIndex,Data{counter}.TrialTime);
            Data{counter}.ErrorAmplitude=vecnorm([tempExtErr,temHorErr,tempVerErr]')';
            Data{counter}.Maximum.Launch.ErrorAmplitude=GetMaximumOf(Data{counter}.ErrorAmplitude(tempLaunchIndex));
            Data{counter}.Maximum.Launch.ExtentError=GetMaximumOf(tempExtErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.HorizontalError=GetMaximumOf(temHorErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.VerticalError=GetMaximumOf(tempVerErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.PerpendicularError=GetMaximumOf(Data{counter}.PerpendicularError(tempLaunchIndex));
            Data{counter}.Maximum.Launch.Speed=GetMaximumOf(tempSpeed(tempLaunchIndex));
            Data{counter}.LaunchDeviationAngle=GetLaunchDeviationAngle(Data{counter}.LocalPosition,Data{counter}.GlobalVelocity,tempLaunchIndex);
            Data{counter}.BadTrialFlag='n';
        end
        Data{counter}.Maximum.Entire.ErrorAmplitude=GetMaximumOf(Data{counter}.ErrorAmplitude);
        Data{counter}.Maximum.Entire.ExtentError=GetMaximumOf(tempExtErr);
        Data{counter}.Maximum.Entire.HorizontalError=GetMaximumOf(temHorErr);
        Data{counter}.Maximum.Entire.VerticalError=GetMaximumOf(tempVerErr);
        Data{counter}.Maximum.Entire.PerpendicularError=GetMaximumOf(Data{counter}.PerpendicularError);
        Data{counter}.Maximum.Entire.Speed=GetMaximumOf(tempSpeed);
        clear tempExtErr temHorErr tempVerErr tempLaunchIndex tempSpeed tempPosition
    end
end
clear counter
if ~isfield(Data{111},'UnIdealStart'), DiscoverUnIdealStart; end
CalculateMaximumSpeedErrorAccuraccy;
CalculateMahalanobisDistance;
CalculateContinuousDeviationAngle;
% Statistical Analysis on maximum perpendicular error
baselineIndex=PhaseIndex.Baseline;
for counter=1:numel(baselineIndex), HypothesisTest.MaximumPerpendicularError.H0.Baseline(counter,:)=Data{baselineIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H0.BaselineDirections(counter,:)=Data{baselineIndex(counter)}.MovementDirection; end
washoutIndex=PhaseIndex.Washout;
for counter=1:numel(washoutIndex), HypothesisTest.MaximumPerpendicularError.H0.Washout(counter,:)=Data{washoutIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H0.WashoutDirections(counter,:)=Data{washoutIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumPerpendicularError.H0.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H0.Baseline;HypothesisTest.MaximumPerpendicularError.H0.Washout]);
[HypothesisTest.MaximumPerpendicularError.H0.ResultsTable,HypothesisTest.MaximumPerpendicularError.H0.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H0.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H0.Baseline,HypothesisTest.MaximumPerpendicularError.H0.Washout),'Baseline-Washout Table');
HypothesisTest.MaximumPerpendicularError.H0.BaselineMovementNumbers=GetMovementNumber(baselineIndex);
HypothesisTest.MaximumPerpendicularError.H0.WashoutMovementNumbers=GetMovementNumber(washoutIndex);
clear baselineIndex washoutIndex
disp(HypothesisTest.MaximumPerpendicularError.H0.ResultsTable)

% Hypothesis H3 DirectionZero : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionZero;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.InitialTraining;HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.LateTraining]);
[HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.ResultsTable,HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.InitialTraining,HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.LateTraining),'InitialTraining-LateTraining DirectionZero Table');
HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumPerpendicularError.H3.DirectionZero.ResultsTable)

% Hypothesis H3 DirectionOne : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionOne;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.InitialTraining;HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.LateTraining]);
[HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.ResultsTable,HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.InitialTraining,HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.LateTraining),'InitialTraining-LateTraining DirectionOne Table');
HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumPerpendicularError.H3.DirectionOne.ResultsTable)


% Hypothesis H3 DirectionTwo : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionTwo;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.InitialTraining;HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.LateTraining]);
[HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.ResultsTable,HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.InitialTraining,HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.LateTraining),'InitialTraining-LateTraining DirectionTwo Table');
HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumPerpendicularError.H3.DirectionTwo.ResultsTable)

% Hypothesis H3 DirectionThree : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=SpecialMovementIndex.PureTraining.DirectionThree;
    numberOfTrialsConsidered=10;
    LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
    InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end
    
    HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.InitialTraining;HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.LateTraining]);
    [HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.ResultsTable,HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.InitialTraining,HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.LateTraining),'InitialTraining-LateTraining DirectionThree Table');
    HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
    HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
    clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
    disp(HypothesisTest.MaximumPerpendicularError.H3.DirectionThree.ResultsTable)
end
% Hypothesis H2 All Directions : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
else
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
end
numberOfTrialsConsidered=20;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumPerpendicularError.H2.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H2.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumPerpendicularError.H2.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.PerpendicularError; HypothesisTest.MaximumPerpendicularError.H2.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumPerpendicularError.H2.IsNonNormal=swtest([HypothesisTest.MaximumPerpendicularError.H2.InitialTraining;HypothesisTest.MaximumPerpendicularError.H2.LateTraining]);
[HypothesisTest.MaximumPerpendicularError.H2.ResultsTable,HypothesisTest.MaximumPerpendicularError.H2.PostHucPVals,HypothesisTest.MaximumPerpendicularError.H2.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumPerpendicularError.H2.InitialTraining,HypothesisTest.MaximumPerpendicularError.H2.LateTraining),'InitialTraining-LateTraining All Directions Table');
HypothesisTest.MaximumPerpendicularError.H2.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumPerpendicularError.H2.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumPerpendicularError.H2.ResultsTable)
clear counter

baselineIndex=PhaseIndex.Baseline;
for counter=1:numel(baselineIndex), HypothesisTest.MaximumErrorAmplitude.H0.Baseline(counter,:)=Data{baselineIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H0.BaselineDirections(counter,:)=Data{baselineIndex(counter)}.MovementDirection; end
washoutIndex=PhaseIndex.Washout;
for counter=1:numel(washoutIndex), HypothesisTest.MaximumErrorAmplitude.H0.Washout(counter,:)=Data{washoutIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H0.WashoutDirections(counter,:)=Data{washoutIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumErrorAmplitude.H0.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H0.Baseline;HypothesisTest.MaximumErrorAmplitude.H0.Washout]);
[HypothesisTest.MaximumErrorAmplitude.H0.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H0.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H0.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H0.Baseline,HypothesisTest.MaximumErrorAmplitude.H0.Washout),'Baseline-Washout Table');
HypothesisTest.MaximumErrorAmplitude.H0.BaselineMovementNumbers=GetMovementNumber(baselineIndex);
HypothesisTest.MaximumErrorAmplitude.H0.WashoutMovementNumbers=GetMovementNumber(washoutIndex);
clear baselineIndex washoutIndex
disp(HypothesisTest.MaximumErrorAmplitude.H0.ResultsTable)

% Hypothesis H3 DirectionZero : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionZero;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.InitialTraining;HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.LateTraining]);
[HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.InitialTraining,HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.LateTraining),'InitialTraining-LateTraining DirectionZero Table');
HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumErrorAmplitude.H3.DirectionZero.ResultsTable)

% Hypothesis H3 DirectionOne : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionOne;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.InitialTraining;HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.LateTraining]);
[HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.InitialTraining,HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.LateTraining),'InitialTraining-LateTraining DirectionOne Table');
HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumErrorAmplitude.H3.DirectionOne.ResultsTable)


% Hypothesis H3 DirectionTwo : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionTwo;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.InitialTraining;HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.LateTraining]);
[HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.InitialTraining,HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.LateTraining),'InitialTraining-LateTraining DirectionTwo Table');
HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumErrorAmplitude.H3.DirectionTwo.ResultsTable)

% Hypothesis H3 DirectionThree : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=SpecialMovementIndex.PureTraining.DirectionThree;
    numberOfTrialsConsidered=10;
    LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
    InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end
    
    HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.InitialTraining;HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.LateTraining]);
    [HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.InitialTraining,HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.LateTraining),'InitialTraining-LateTraining DirectionThree Table');
    HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
    HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
    clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
    disp(HypothesisTest.MaximumErrorAmplitude.H3.DirectionThree.ResultsTable)
end
% Hypothesis H2 All Directions : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
else
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
end
numberOfTrialsConsidered=20;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H2.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H2.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.MaximumErrorAmplitude.H2.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.Maximum.Launch.ErrorAmplitude; HypothesisTest.MaximumErrorAmplitude.H2.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.MaximumErrorAmplitude.H2.IsNonNormal=swtest([HypothesisTest.MaximumErrorAmplitude.H2.InitialTraining;HypothesisTest.MaximumErrorAmplitude.H2.LateTraining]);
[HypothesisTest.MaximumErrorAmplitude.H2.ResultsTable,HypothesisTest.MaximumErrorAmplitude.H2.PostHucPVals,HypothesisTest.MaximumErrorAmplitude.H2.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.MaximumErrorAmplitude.H2.InitialTraining,HypothesisTest.MaximumErrorAmplitude.H2.LateTraining),'InitialTraining-LateTraining All Directions Table');
HypothesisTest.MaximumErrorAmplitude.H2.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.MaximumErrorAmplitude.H2.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.MaximumErrorAmplitude.H2.ResultsTable)
clear counter

baselineIndex=PhaseIndex.Baseline;
for counter=1:numel(baselineIndex), HypothesisTest.LaunchDeviationAngle.H0.Baseline(counter,:)=Data{baselineIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H0.BaselineDirections(counter,:)=Data{baselineIndex(counter)}.MovementDirection; end
washoutIndex=PhaseIndex.Washout;
for counter=1:numel(washoutIndex), HypothesisTest.LaunchDeviationAngle.H0.Washout(counter,:)=Data{washoutIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H0.WashoutDirections(counter,:)=Data{washoutIndex(counter)}.MovementDirection; end

HypothesisTest.LaunchDeviationAngle.H0.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H0.Baseline;HypothesisTest.LaunchDeviationAngle.H0.Washout]);
[HypothesisTest.LaunchDeviationAngle.H0.ResultsTable,HypothesisTest.LaunchDeviationAngle.H0.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H0.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H0.Baseline,HypothesisTest.LaunchDeviationAngle.H0.Washout),'Baseline-Washout Table');
HypothesisTest.LaunchDeviationAngle.H0.BaselineMovementNumbers=GetMovementNumber(baselineIndex);
HypothesisTest.LaunchDeviationAngle.H0.WashoutMovementNumbers=GetMovementNumber(washoutIndex);
clear baselineIndex washoutIndex
disp(HypothesisTest.LaunchDeviationAngle.H0.ResultsTable)

% Hypothesis H3 DirectionZero : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionZero;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.InitialTraining;HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.LateTraining]);
[HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.ResultsTable,HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.InitialTraining,HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.LateTraining),'InitialTraining-LateTraining DirectionZero Table');
HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.LaunchDeviationAngle.H3.DirectionZero.ResultsTable)

% Hypothesis H3 DirectionOne : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionOne;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.InitialTraining;HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.LateTraining]);
[HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.ResultsTable,HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.InitialTraining,HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.LateTraining),'InitialTraining-LateTraining DirectionOne Table');
HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.LaunchDeviationAngle.H3.DirectionOne.ResultsTable)


% Hypothesis H3 DirectionTwo : InitialTraining - LateTraining
trainingIndex=SpecialMovementIndex.PureTraining.DirectionTwo;
numberOfTrialsConsidered=10;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.InitialTraining;HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.LateTraining]);
[HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.ResultsTable,HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.InitialTraining,HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.LateTraining),'InitialTraining-LateTraining DirectionTwo Table');
HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.LaunchDeviationAngle.H3.DirectionTwo.ResultsTable)

% Hypothesis H3 DirectionThree : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=SpecialMovementIndex.PureTraining.DirectionThree;
    numberOfTrialsConsidered=10;
    LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(LateTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
    InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
    for counter=1:numel(InitialTrainingIndex), HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end
    
    HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.InitialTraining;HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.LateTraining]);
    [HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.ResultsTable,HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.InitialTraining,HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.LateTraining),'InitialTraining-LateTraining DirectionThree Table');
    HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
    HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
    clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
    disp(HypothesisTest.LaunchDeviationAngle.H3.DirectionThree.ResultsTable)
end
% Hypothesis H2 All Directions : InitialTraining - LateTraining
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
else
    trainingIndex=sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
end
numberOfTrialsConsidered=20;
LateTrainingIndex=flip(trainingIndex);LateTrainingIndex=LateTrainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(LateTrainingIndex), HypothesisTest.LaunchDeviationAngle.H2.LateTraining(counter,:)=Data{LateTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H2.LateTrainingDirections(counter,:)=Data{LateTrainingIndex(counter)}.MovementDirection; end
InitialTrainingIndex=trainingIndex(1:numberOfTrialsConsidered);
for counter=1:numel(InitialTrainingIndex), HypothesisTest.LaunchDeviationAngle.H2.InitialTraining(counter,:)=Data{InitialTrainingIndex(counter)}.LaunchDeviationAngle; HypothesisTest.LaunchDeviationAngle.H2.InitialTrainingDirections(counter,:)=Data{InitialTrainingIndex(counter)}.MovementDirection; end

HypothesisTest.LaunchDeviationAngle.H2.IsNonNormal=swtest([HypothesisTest.LaunchDeviationAngle.H2.InitialTraining;HypothesisTest.LaunchDeviationAngle.H2.LateTraining]);
[HypothesisTest.LaunchDeviationAngle.H2.ResultsTable,HypothesisTest.LaunchDeviationAngle.H2.PostHucPVals,HypothesisTest.LaunchDeviationAngle.H2.PostHucH]=NonParametricStatistics(ShapeIntoMatrix(HypothesisTest.LaunchDeviationAngle.H2.InitialTraining,HypothesisTest.LaunchDeviationAngle.H2.LateTraining),'InitialTraining-LateTraining All Directions Table');
HypothesisTest.LaunchDeviationAngle.H2.InitialTrainingMovementNumbers=GetMovementNumber(InitialTrainingIndex);
HypothesisTest.LaunchDeviationAngle.H2.LateTrainingMovementNumbers=GetMovementNumber(LateTrainingIndex);
clear InitialTrainingIndex LateTrainingIndex numberOfTrialsConsidered trainingIndex
disp(HypothesisTest.LaunchDeviationAngle.H2.ResultsTable)
clear counter
% SYSTEM IDENTIFICATION : RAW DATA AGGREGATION
phasebeginTrials=cumsum([1,InputFile.PhaseDurations(1:end-1)]);
switch Data{1}.ExperimentMode
    case '2D'
        trialIndex = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
        [d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7,R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7]=GetDirectionsAndMatrixes('numeric');
    case '3D'
        trialIndex = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
        [d_0,d_1,d_2,d_3,d_4,d_5,R_0,R_1,R_2,R_3,R_4,R_5]=GetDirectionsAndMatrixes2D();
end
clear d_0 d_1 d_2 d_3 d_4 d_5 d_6 d_7 R_4 R_5 R_6 R_7
directionZeroCounter=1;
directionOneCounter=1;
directionTwoCounter=1;
directionThreeCounter=1;
for counter=1:numel(trialIndex)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
        continue
    else
        tempMovementNumber=Data{trialIndex(counter)}.MovementNumber;
        tempLaunchIndex=GetLaunchIndex(Data{trialIndex(counter)}.OnsetDetectedIndex,Data{trialIndex(counter)}.TrialTime);
        tempTotalForce = Data{trialIndex(counter)}.GlobalRobotForce;
        tempTherapyForce = Data{trialIndex(counter)}.InFrameTherapy;
        tempExtentError = Data{trialIndex(counter)}.ExtentError;
        tempHorizontalError = Data{trialIndex(counter)}.HorizontalError;
        tempVerticalError = Data{trialIndex(counter)}.VerticalError;
        tempDevationAngle = Data{trialIndex(counter)}.LaunchDeviationAngle;
        tempStartPosition = Data{trialIndex(counter)}.StartPosition';
        temptargetPosition = Data{trialIndex(counter)}.TargetPosition';
        tempPerpendicularError = Data{trialIndex(counter)}.PerpendicularError;
        tempTime = Data{trialIndex(counter)}.TrialTime;
        switch Data{trialIndex(counter)}.MovementDirection
            case 0
                R=R_0;
            case 1
                R=R_1;
            case 2
                R=R_2;
            case 3
                R=R_3;
        end
        tempInFrameTotalForce = (R*(tempTotalForce'))';
        switch Data{trialIndex(counter)}.MovementDirection
            case 0
                SysID.DirectionZero.MovementNumber(directionZeroCounter,:)=tempMovementNumber;
                SysID.DirectionZero.LaunchIndex{directionZeroCounter,:}=tempLaunchIndex;
                SysID.DirectionZero.Time{directionZeroCounter,:}=tempTime;
                SysID.DirectionZero.InFrameTherapyForce{directionZeroCounter,:}=tempTherapyForce(tempLaunchIndex,:);
                SysID.DirectionZero.InFrameTotalForce{directionZeroCounter,:}=tempInFrameTotalForce;
                SysID.DirectionZero.ExtentError{directionZeroCounter,:}=tempExtentError;
                SysID.DirectionZero.HorizontalError{directionZeroCounter,:}=tempHorizontalError;
                SysID.DirectionZero.VerticalError{directionZeroCounter,:}=tempVerticalError;
                SysID.DirectionZero.PerpendicularError{directionZeroCounter,:}=tempPerpendicularError;
                [SysID.DirectionZero.Output.PerpendicularError(directionZeroCounter,:),perpMaxIndexOfLaunchIndex]=GetMaximumOf(tempPerpendicularError(tempLaunchIndex));
                [SysID.DirectionZero.Output.ExtentError(directionZeroCounter,:),extMaxIndexOfLaunchIndex]=GetMaximumOf(tempExtentError(tempLaunchIndex));
                [SysID.DirectionZero.Output.HorizontalError(directionZeroCounter,:),horMaxIndexOfLaunchIndex]=GetMaximumOf(tempHorizontalError(tempLaunchIndex));
                [SysID.DirectionZero.Output.VerticalError(directionZeroCounter,:),verMaxIndexOfLaunchIndex]=GetMaximumOf(tempVerticalError(tempLaunchIndex));
                SysID.DirectionZero.Output.DevationAngle(directionZeroCounter,:) = tempDevationAngle;
                SysID.DirectionZero.Input.TherapyForce(directionZeroCounter,:) = [tempTherapyForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                  tempTherapyForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                  tempTherapyForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionZero.Input.TotalForce(directionZeroCounter,:) = [tempInFrameTotalForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionZero.Input.StartPosition(directionZeroCounter,:) = tempStartPosition;
                SysID.DirectionZero.Input.TargetPosition(directionZeroCounter,:) = temptargetPosition;
                directionZeroCounter = directionZeroCounter + 1;
            case 1
                SysID.DirectionOne.MovementNumber(directionOneCounter,:)=tempMovementNumber;
                SysID.DirectionOne.LaunchIndex{directionOneCounter,:}=tempLaunchIndex;
                SysID.DirectionOne.Time{directionOneCounter,:}=tempTime;
                SysID.DirectionOne.InFrameTherapyForce{directionOneCounter,:}=tempTherapyForce(tempLaunchIndex,:);
                SysID.DirectionOne.InFrameTotalForce{directionOneCounter,:}=tempInFrameTotalForce;
                SysID.DirectionOne.ExtentError{directionOneCounter,:}=tempExtentError;
                SysID.DirectionOne.HorizontalError{directionOneCounter,:}=tempHorizontalError;
                SysID.DirectionOne.VerticalError{directionOneCounter,:}=tempVerticalError;
                SysID.DirectionOne.PerpendicularError{directionOneCounter,:}=tempPerpendicularError;
                [SysID.DirectionOne.Output.PerpendicularError(directionOneCounter,:),perpMaxIndexOfLaunchIndex]=GetMaximumOf(tempPerpendicularError(tempLaunchIndex));
                [SysID.DirectionOne.Output.ExtentError(directionOneCounter,:),extMaxIndexOfLaunchIndex]=GetMaximumOf(tempExtentError(tempLaunchIndex));
                [SysID.DirectionOne.Output.HorizontalError(directionOneCounter,:),horMaxIndexOfLaunchIndex]=GetMaximumOf(tempHorizontalError(tempLaunchIndex));
                [SysID.DirectionOne.Output.VerticalError(directionOneCounter,:),verMaxIndexOfLaunchIndex]=GetMaximumOf(tempVerticalError(tempLaunchIndex));
                SysID.DirectionOne.Output.DevationAngle(directionOneCounter,:) = tempDevationAngle;
                SysID.DirectionOne.Input.TherapyForce(directionOneCounter,:) = [tempTherapyForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                  tempTherapyForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                  tempTherapyForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionOne.Input.TotalForce(directionOneCounter,:) = [tempInFrameTotalForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionOne.Input.StartPosition(directionOneCounter,:) = tempStartPosition;
                SysID.DirectionOne.Input.TargetPosition(directionOneCounter,:) = temptargetPosition;
                directionOneCounter = directionOneCounter + 1;
            case 2
                SysID.DirectionTwo.MovementNumber(directionTwoCounter,:)=tempMovementNumber;
                SysID.DirectionTwo.LaunchIndex{directionTwoCounter,:}=tempLaunchIndex;
                SysID.DirectionTwo.Time{directionTwoCounter,:}=tempTime;
                SysID.DirectionTwo.InFrameTherapyForce{directionTwoCounter,:}=tempTherapyForce(tempLaunchIndex,:);
                SysID.DirectionTwo.InFrameTotalForce{directionTwoCounter,:}=tempInFrameTotalForce;
                SysID.DirectionTwo.ExtentError{directionTwoCounter,:}=tempExtentError;
                SysID.DirectionTwo.HorizontalError{directionTwoCounter,:}=tempHorizontalError;
                SysID.DirectionTwo.VerticalError{directionTwoCounter,:}=tempVerticalError;
                SysID.DirectionTwo.PerpendicularError{directionTwoCounter,:}=tempPerpendicularError;
                [SysID.DirectionTwo.Output.PerpendicularError(directionTwoCounter,:),perpMaxIndexOfLaunchIndex]=GetMaximumOf(tempPerpendicularError(tempLaunchIndex));
                [SysID.DirectionTwo.Output.ExtentError(directionTwoCounter,:),extMaxIndexOfLaunchIndex]=GetMaximumOf(tempExtentError(tempLaunchIndex));
                [SysID.DirectionTwo.Output.HorizontalError(directionTwoCounter,:),horMaxIndexOfLaunchIndex]=GetMaximumOf(tempHorizontalError(tempLaunchIndex));
                [SysID.DirectionTwo.Output.VerticalError(directionTwoCounter,:),verMaxIndexOfLaunchIndex]=GetMaximumOf(tempVerticalError(tempLaunchIndex));
                SysID.DirectionTwo.Output.DevationAngle(directionTwoCounter,:) = tempDevationAngle;
                SysID.DirectionTwo.Input.TherapyForce(directionTwoCounter,:) = [tempTherapyForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                  tempTherapyForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                  tempTherapyForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionTwo.Input.TotalForce(directionTwoCounter,:) = [tempInFrameTotalForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionTwo.Input.StartPosition(directionTwoCounter,:) = tempStartPosition;
                SysID.DirectionTwo.Input.TargetPosition(directionTwoCounter,:) = temptargetPosition;
                directionTwoCounter = directionTwoCounter + 1;
            case 3
                SysID.DirectionThree.MovementNumber(directionThreeCounter,:)=tempMovementNumber;
                SysID.DirectionThree.LaunchIndex{directionThreeCounter,:}=tempLaunchIndex;
                SysID.DirectionThree.Time{directionThreeCounter,:}=tempTime;
                SysID.DirectionThree.InFrameTherapyForce{directionThreeCounter,:}=tempTherapyForce(tempLaunchIndex,:);
                SysID.DirectionThree.InFrameTotalForce{directionThreeCounter,:}=tempInFrameTotalForce;
                SysID.DirectionThree.ExtentError{directionThreeCounter,:}=tempExtentError;
                SysID.DirectionThree.HorizontalError{directionThreeCounter,:}=tempHorizontalError;
                SysID.DirectionThree.VerticalError{directionThreeCounter,:}=tempVerticalError;
                SysID.DirectionThree.PerpendicularError{directionThreeCounter,:}=tempPerpendicularError;
                [SysID.DirectionThree.Output.PerpendicularError(directionThreeCounter,:),perpMaxIndexOfLaunchIndex]=GetMaximumOf(tempPerpendicularError(tempLaunchIndex));
                [SysID.DirectionThree.Output.ExtentError(directionThreeCounter,:),extMaxIndexOfLaunchIndex]=GetMaximumOf(tempExtentError(tempLaunchIndex));
                [SysID.DirectionThree.Output.HorizontalError(directionThreeCounter,:),horMaxIndexOfLaunchIndex]=GetMaximumOf(tempHorizontalError(tempLaunchIndex));
                [SysID.DirectionThree.Output.VerticalError(directionThreeCounter,:),verMaxIndexOfLaunchIndex]=GetMaximumOf(tempVerticalError(tempLaunchIndex));
                SysID.DirectionThree.Output.DevationAngle(directionThreeCounter,:) = tempDevationAngle;
                SysID.DirectionThree.Input.TherapyForce(directionThreeCounter,:) = [tempTherapyForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                  tempTherapyForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                  tempTherapyForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionThree.Input.TotalForce(directionThreeCounter,:) = [tempInFrameTotalForce(tempLaunchIndex(extMaxIndexOfLaunchIndex),1),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(horMaxIndexOfLaunchIndex),2),...
                                                                                tempInFrameTotalForce(tempLaunchIndex(verMaxIndexOfLaunchIndex),3)];
                SysID.DirectionThree.Input.StartPosition(directionThreeCounter,:) = tempStartPosition;
                SysID.DirectionThree.Input.TargetPosition(directionThreeCounter,:) = temptargetPosition;
                directionThreeCounter = directionThreeCounter + 1;
        end
    end
    clear tempMovementNumber tempLaunchIndex tempTotalForce tempTherapyForce tempExtentError tempHorizontalError tempVerticalError extMaxIndexOfLaunchIndex 
    clear horMaxIndexOfLaunchIndex verMaxIndexOfLaunchIndex R tempInFrameTotalForce tempDevationAngle tempStartPosition temptargetPosition tempTime tempPerpendicularError perpMaxIndexOfLaunchIndex
end
clear phasebeginTrials trialIndex counter directionZeroCounter directionOneCounter directionTwoCounter directionThreeCounter R_0 R_1 R_2 R_3

% Calculating CrossValidated Exponential Regressions
% for Perpendicular Error Plot : Launch
% for Perpendicular Error Plot : Launch
if strcmp(Data{1}.ExperimentMode,'2D')==true
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
else
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
end
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumPerpendicularError','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumPerpendicularError.Launch.Fitness=tempFitnessStruct;
ErrorFit.MaximumPerpendicularError.Launch.Ensemble=tempFitEnsemble;
ErrorFit.MaximumPerpendicularError.Launch.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Dependent Exponential Regression
% Direction Zero
index = sort([SpecialMovementIndex.PureTraining.DirectionZero]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumPerpendicularError','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Fitness=tempFitnessStruct;
ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Ensemble=tempFitEnsemble;
ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction One
index = sort([SpecialMovementIndex.PureTraining.DirectionOne]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumPerpendicularError','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.Fitness=tempFitnessStruct;
ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.Ensemble=tempFitEnsemble;
ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Two
index = sort([SpecialMovementIndex.PureTraining.DirectionTwo]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumPerpendicularError','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.Fitness=tempFitnessStruct;
ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.Ensemble=tempFitEnsemble;
ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Three
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    index = sort([SpecialMovementIndex.PureTraining.DirectionThree]);
    movementNumbers=GetMovementNumber(index);
    values=GetErrorVector(index,'MaximumPerpendicularError','launch');
    nanIndex=isnan(values);
    values(nanIndex)=[];
    movementNumbers(nanIndex)=[];
    [tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
    ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.Fitness=tempFitnessStruct;
    ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.Ensemble=tempFitEnsemble;
    ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.MovementNumbers=movementNumbers;
    clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
end
% Exponential Regression for Launch Deviation Angle
if strcmp(Data{1}.ExperimentMode,'2D')==true
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
else
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
end
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'LaunchDeviationAngle','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.LaunchDeviationAngle.Fitness=tempFitnessStruct;
ErrorFit.LaunchDeviationAngle.Ensemble=tempFitEnsemble;
ErrorFit.LaunchDeviationAngle.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Dependent Exponential Regression
% Direction Zero
index = sort([SpecialMovementIndex.PureTraining.DirectionZero]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'LaunchDeviationAngle','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.LaunchDeviationAngle.DirectionZero.Fitness=tempFitnessStruct;
ErrorFit.LaunchDeviationAngle.DirectionZero.Ensemble=tempFitEnsemble;
ErrorFit.LaunchDeviationAngle.DirectionZero.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction One
index = sort([SpecialMovementIndex.PureTraining.DirectionOne]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'LaunchDeviationAngle','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.LaunchDeviationAngle.DirectionOne.Fitness=tempFitnessStruct;
ErrorFit.LaunchDeviationAngle.DirectionOne.Ensemble=tempFitEnsemble;
ErrorFit.LaunchDeviationAngle.DirectionOne.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Two
index = sort([SpecialMovementIndex.PureTraining.DirectionTwo]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'LaunchDeviationAngle','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.LaunchDeviationAngle.DirectionTwo.Fitness=tempFitnessStruct;
ErrorFit.LaunchDeviationAngle.DirectionTwo.Ensemble=tempFitEnsemble;
ErrorFit.LaunchDeviationAngle.DirectionTwo.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Three
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    index = sort([SpecialMovementIndex.PureTraining.DirectionThree]);
    movementNumbers=GetMovementNumber(index);
    values=GetErrorVector(index,'LaunchDeviationAngle','launch');
    nanIndex=isnan(values);
    values(nanIndex)=[];
    movementNumbers(nanIndex)=[];
    [tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
    ErrorFit.LaunchDeviationAngle.DirectionThree.Fitness=tempFitnessStruct;
    ErrorFit.LaunchDeviationAngle.DirectionThree.Ensemble=tempFitEnsemble;
    ErrorFit.LaunchDeviationAngle.DirectionThree.MovementNumbers=movementNumbers;
    clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
end
% Exponential Regression for Maximum Error Amplitude
if strcmp(Data{1}.ExperimentMode,'2D')==true
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo]);
else
    index = sort([SpecialMovementIndex.PureTraining.DirectionZero;SpecialMovementIndex.PureTraining.DirectionOne;SpecialMovementIndex.PureTraining.DirectionTwo;SpecialMovementIndex.PureTraining.DirectionThree]);
end
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumErrorAmplitude','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumErrorAmplitude.Fitness=tempFitnessStruct;
ErrorFit.MaximumErrorAmplitude.Ensemble=tempFitEnsemble;
ErrorFit.MaximumErrorAmplitude.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Dependent Exponential Regression
% Direction Zero
index = sort([SpecialMovementIndex.PureTraining.DirectionZero]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumErrorAmplitude','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumErrorAmplitude.DirectionZero.Fitness=tempFitnessStruct;
ErrorFit.MaximumErrorAmplitude.DirectionZero.Ensemble=tempFitEnsemble;
ErrorFit.MaximumErrorAmplitude.DirectionZero.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction One
index = sort([SpecialMovementIndex.PureTraining.DirectionOne]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumErrorAmplitude','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumErrorAmplitude.DirectionOne.Fitness=tempFitnessStruct;
ErrorFit.MaximumErrorAmplitude.DirectionOne.Ensemble=tempFitEnsemble;
ErrorFit.MaximumErrorAmplitude.DirectionOne.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Two
index = sort([SpecialMovementIndex.PureTraining.DirectionTwo]);
movementNumbers=GetMovementNumber(index);
values=GetErrorVector(index,'MaximumErrorAmplitude','launch');
nanIndex=isnan(values);
values(nanIndex)=[];
movementNumbers(nanIndex)=[];
[tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
ErrorFit.MaximumErrorAmplitude.DirectionTwo.Fitness=tempFitnessStruct;
ErrorFit.MaximumErrorAmplitude.DirectionTwo.Ensemble=tempFitEnsemble;
ErrorFit.MaximumErrorAmplitude.DirectionTwo.MovementNumbers=movementNumbers;
clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
% Direction Three
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    index = sort([SpecialMovementIndex.PureTraining.DirectionThree]);
    movementNumbers=GetMovementNumber(index);
    values=GetErrorVector(index,'MaximumErrorAmplitude','launch');
    nanIndex=isnan(values);
    values(nanIndex)=[];
    movementNumbers(nanIndex)=[];
    [tempFitnessStruct, tempFitEnsemble]=ExpRegCV([movementNumbers,values],[],[],[],1);
    ErrorFit.MaximumErrorAmplitude.DirectionThree.Fitness=tempFitnessStruct;
    ErrorFit.MaximumErrorAmplitude.DirectionThree.Ensemble=tempFitEnsemble;
    ErrorFit.MaximumErrorAmplitude.DirectionThree.MovementNumbers=movementNumbers;
    clear tempFitnessStruct tempFitEnsemble nanIndex values movementNumbers index
end

% Wasserstein Distance Analysis
testPhaseMovementNumbers=GetMovementNumber(PhaseIndex.Washout);
directionZeroTestMovementNumbers=[];
directionOneTestMovementNumbers=[];
directionTwoTestMovementNumbers=[];
directionThreeTestMovementNumbers=[];
for counter=1:numel(PhaseIndex.Washout)
    switch Data{PhaseIndex.Washout(counter)}.MovementDirection
        case 0
            directionZeroTestMovementNumbers=[directionZeroTestMovementNumbers;Data{PhaseIndex.Washout(counter)}.MovementNumber];
        case 1
            directionOneTestMovementNumbers=[directionOneTestMovementNumbers;Data{PhaseIndex.Washout(counter)}.MovementNumber];
        case 2
            directionTwoTestMovementNumbers=[directionTwoTestMovementNumbers;Data{PhaseIndex.Washout(counter)}.MovementNumber];
        case 3
            directionThreeTestMovementNumbers=[directionThreeTestMovementNumbers;Data{PhaseIndex.Washout(counter)}.MovementNumber];
    end
end
PostTrainingDistributions.DirectionZero=[];
PostTrainingDistributions.DirectionOne=[];
PostTrainingDistributions.DirectionTwo=[];
PostTrainingDistributions.DirectionThree=[];
PostTrainingDistributions.DirectionZero=SetUpDistributions(directionZeroTestMovementNumbers);
PostTrainingDistributions.DirectionOne=SetUpDistributions(directionOneTestMovementNumbers);
PostTrainingDistributions.DirectionTwo=SetUpDistributions(directionTwoTestMovementNumbers);
if ~isempty(directionThreeTestMovementNumbers)
    PostTrainingDistributions.DirectionThree=SetUpDistributions(directionThreeTestMovementNumbers);
end
clear counter testPhaseMovementNumbers directionZeroTestMovementNumbers directionOneTestMovementNumbers directionTwoTestMovementNumbers directionThreeTestMovementNumbers
[PrePostAnalysis.WassersteinDistanceDifference.DirectionZero,...
 PrePostAnalysis.WassersteinDistance.DirectionZero.Pre.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionZero.Post.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionZero.Pre.Summation,...
 PrePostAnalysis.WassersteinDistance.DirectionZero.Post.Summation]=GetWassersteinDistanceDifference(InterpolatedData.DirectionZero,PostTrainingDistributions.DirectionZero,'y',0);
[PrePostAnalysis.WassersteinDistanceDifference.DirectionOne,...
 PrePostAnalysis.WassersteinDistance.DirectionOne.Pre.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionOne.Post.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionOne.Pre.Summation,...
 PrePostAnalysis.WassersteinDistance.DirectionOne.Post.Summation]=GetWassersteinDistanceDifference(InterpolatedData.DirectionOne,PostTrainingDistributions.DirectionOne,'y',1);
[PrePostAnalysis.WassersteinDistanceDifference.DirectionTwo,...
 PrePostAnalysis.WassersteinDistance.DirectionTwo.Pre.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionTwo.Post.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionTwo.Pre.Summation,...
 PrePostAnalysis.WassersteinDistance.DirectionTwo.Post.Summation]=GetWassersteinDistanceDifference(InterpolatedData.DirectionTwo,PostTrainingDistributions.DirectionTwo,'y',2);
[PrePostAnalysis.WassersteinDistanceDifference.DirectionThree,...
 PrePostAnalysis.WassersteinDistance.DirectionThree.Pre.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionThree.Post.Individuals,...
 PrePostAnalysis.WassersteinDistance.DirectionThree.Pre.Summation,...
 PrePostAnalysis.WassersteinDistance.DirectionThree.Post.Summation]=GetWassersteinDistanceDifference(InterpolatedData.DirectionThree,PostTrainingDistributions.DirectionThree,'y',3);


%% Data log stop sign





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  --------  STOP HERE THE DATA FILE LOG  --------  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% Plot of Erros During formation of Error Fields
fsz=12;
switch Data{1}.ExperimentMode
    case '2D'
        numberOfDirections=3;
    case '3D'
        numberOfDirections=4;
end
for counter=1:numberOfDirections
    ax_1(counter)=subplot(3,numberOfDirections,counter);
    hold(ax_1(counter),"on");box(ax_1(counter),"off");
    xlabel(ax_1(counter),'Path Distance (m)');ylabel(ax_1(counter),'Extent Error (m)');
    set(ax_1(counter),"FontSize",fsz)
end
for counter=1*(numberOfDirections)+1:2*numberOfDirections
    ax_2(counter-1*(numberOfDirections))=subplot(3,numberOfDirections,counter); 
    hold(ax_2(counter-1*(numberOfDirections)),"on");box(ax_2(counter-1*(numberOfDirections)),"off");
    xlabel(ax_2(counter-1*(numberOfDirections)),'Path Distance (m)');ylabel(ax_2(counter-1*(numberOfDirections)),'Horizontal Error (m)');
    set(ax_2(counter-1*(numberOfDirections)),"FontSize",fsz)
end
for counter=2*(numberOfDirections)+1:3*numberOfDirections
    ax_3(counter-2*(numberOfDirections))=subplot(3,numberOfDirections,counter); 
    hold(ax_3(counter-2*(numberOfDirections)),"on");box(ax_3(counter-2*(numberOfDirections)),"off");
    xlabel(ax_3(counter-2*(numberOfDirections)),'Path Distance (m)');ylabel(ax_3(counter-2*(numberOfDirections)),'Vertical Error (m)');
    set(ax_3(counter-2*(numberOfDirections)),"FontSize",fsz)
end
switch Data{1}.ExperimentMode
    case '2D'
        for counter=0:2
            switch counter
                case 0
                    extErr=InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices;
                case 1
                    extErr=InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices;
                case 2
                    extErr=InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices;
            end
            pathDistance=InterpolatedData.DirectionZero.DistributionTimes;
            for counter_2=1:size(extErr,2)
                plot(ax_1(1,counter+1),pathDistance(2:end),extErr(:,counter_2),'.','MarkerSize',2);title(ax_1(1,counter+1),"d = "+num2str(counter))
                plot(ax_2(1,counter+1),pathDistance(2:end),horErr(:,counter_2),'.','MarkerSize',2);title(ax_2(1,counter+1),"d = "+num2str(counter))
                plot(ax_3(1,counter+1),pathDistance(2:end),verErr(:,counter_2),'.','MarkerSize',2);title(ax_3(1,counter+1),"d = "+num2str(counter))
            end
            EnsembleCVPatchPlot(ax_1(1,counter+1),pathDistance(2:end),mean(extErr,2),extErr,[0 0 0],[0.6 0.6 0.6]);
            EnsembleCVPatchPlot(ax_2(1,counter+1),pathDistance(2:end),mean(horErr,2),horErr,[0 0 0],[0.6 0.6 0.6]);
            EnsembleCVPatchPlot(ax_3(1,counter+1),pathDistance(2:end),mean(verErr,2),verErr,[0 0 0],[0.6 0.6 0.6]);
            clear extErr horErr verErr pathDistance
        end
    case '3D'
        for counter=0:3
            switch counter
                case 0
                    extErr=InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices;
                case 1
                    extErr=InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices;
                case 2
                    extErr=InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices;
                case 3
                    extErr=InterpolatedData.DirectionThree.ExtentErrorAtTimeSlices;
                    horErr=InterpolatedData.DirectionThree.HorizontalErrorAtTimeSlices;
                    verErr=InterpolatedData.DirectionThree.VerticalErrorAtTimeSlices;
            end
            pathDistance=InterpolatedData.DirectionZero.DistributionTimes;
            for counter_2=1:size(extErr,2)
                plot(ax_1(1,counter+1),pathDistance(2:end),extErr(:,counter_2),'.','MarkerSize',2);title(ax_1(1,counter+1),"d = "+num2str(counter))
                plot(ax_2(1,counter+1),pathDistance(2:end),horErr(:,counter_2),'.','MarkerSize',2);title(ax_2(1,counter+1),"d = "+num2str(counter))
                plot(ax_3(1,counter+1),pathDistance(2:end),verErr(:,counter_2),'.','MarkerSize',2);title(ax_3(1,counter+1),"d = "+num2str(counter))
            end
            EnsembleCVPatchPlot(ax_1(1,counter+1),pathDistance(2:end),mean(extErr,2),extErr,[0 0 0],[0.6 0.6 0.6]);
            EnsembleCVPatchPlot(ax_2(1,counter+1),pathDistance(2:end),mean(horErr,2),horErr,[0 0 0],[0.6 0.6 0.6]);
            EnsembleCVPatchPlot(ax_3(1,counter+1),pathDistance(2:end),mean(verErr,2),verErr,[0 0 0],[0.6 0.6 0.6]);
            clear extErr horErr verErr pathDistance
        end
end
ForceSameAxisLimits(ax_1,'y');ForceSameAxisLimits(ax_2,'y');ForceSameAxisLimits(ax_3,'y');
clear counter counter_2 ax_1 ax_2 ax_3 numberOfDirections ans fsz
%% Interpolation Results
switch Data{1}.ExperimentMode
    case '2D'
        MakeTimeSliceClip('DirectionZeroTimeSlice',InterpolatedData.DirectionZero.DistributionTimes,...
                                           InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices,...
                                           InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices, ...
                                           InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionZeroDistribution',InterpolatedData.DirectionZero.DistributionTimes,...
                                                              InterpolatedData.DirectionZero.DistributionMeans,...
                                                              InterpolatedData.DirectionZero.DistributionCovariances);
        
        MakeTimeSliceClip('DirectionOneTimeSlice',InterpolatedData.DirectionOne.DistributionTimes,...
                                                   InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices,...
                                                   InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices, ...
                                                   InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionOneDistribution',InterpolatedData.DirectionOne.DistributionTimes,...
                                                              InterpolatedData.DirectionOne.DistributionMeans,...
                                                              InterpolatedData.DirectionOne.DistributionCovariances);
        MakeTimeSliceClip('DirectionTwoTimeSlice',InterpolatedData.DirectionTwo.DistributionTimes,...
                                                   InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices,...
                                                   InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices, ...
                                                   InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionTwoDistribution',InterpolatedData.DirectionTwo.DistributionTimes,...
                                                              InterpolatedData.DirectionTwo.DistributionMeans,...
                                                              InterpolatedData.DirectionTwo.DistributionCovariances);
    case '3D'
        MakeTimeSliceClip('DirectionZeroTimeSlice',InterpolatedData.DirectionZero.DistributionTimes,...
                                           InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices,...
                                           InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices, ...
                                           InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionZeroDistribution',InterpolatedData.DirectionZero.DistributionTimes,...
                                                              InterpolatedData.DirectionZero.DistributionMeans,...
                                                              InterpolatedData.DirectionZero.DistributionCovariances);
        
        MakeTimeSliceClip('DirectionOneTimeSlice',InterpolatedData.DirectionOne.DistributionTimes,...
                                                   InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices,...
                                                   InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices, ...
                                                   InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionOneDistribution',InterpolatedData.DirectionOne.DistributionTimes,...
                                                              InterpolatedData.DirectionOne.DistributionMeans,...
                                                              InterpolatedData.DirectionOne.DistributionCovariances);
        MakeTimeSliceClip('DirectionTwoTimeSlice',InterpolatedData.DirectionTwo.DistributionTimes,...
                                                   InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices,...
                                                   InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices, ...
                                                   InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionTwoDistribution',InterpolatedData.DirectionTwo.DistributionTimes,...
                                                              InterpolatedData.DirectionTwo.DistributionMeans,...
                                                              InterpolatedData.DirectionTwo.DistributionCovariances);
        MakeTimeSliceClip('DirectionThreeTimeSlice',InterpolatedData.DirectionThree.DistributionTimes,...
                                                   InterpolatedData.DirectionThree.ExtentErrorAtTimeSlices,...
                                                   InterpolatedData.DirectionThree.HorizontalErrorAtTimeSlices, ...
                                                   InterpolatedData.DirectionThree.VerticalErrorAtTimeSlices);
        MakeErrorDistributionClip('DirectionThreeDistribution',InterpolatedData.DirectionThree.DistributionTimes,...
                                                              InterpolatedData.DirectionThree.DistributionMeans,...
                                                              InterpolatedData.DirectionThree.DistributionCovariances);

end

%% Perpendicular Error Plot : Launch
C=EquiDistantColorGenerator(4,9742);
[maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([1:numel(Data)],'MaximumPerpendicularError','launch');
% [maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumPerpendicularError','launch','CreareEmptySpace');
% [maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumPerpendicularError','launch');

% AddRosePlots(maxPerpPlotFigHandle,maxPerpPlotAxHandle,'MaximumPerpendicularError','launch');
% PlotErrorTimeSeries([1:numel(Data)],'Speed','launch');
AddExponentialFit(maxPerpPlotAxHandle,ErrorFit.MaximumPerpendicularError.Launch.MovementNumbers,ErrorFit.MaximumPerpendicularError.Launch.Fitness,ErrorFit.MaximumPerpendicularError.Launch.Ensemble,[0.3,0.3,0.3],[0.6,0.6,0.6])
if isempty(ErrorFit.MaximumPerpendicularError.DirectionZero)==false
    AddExponentialFit(maxPerpPlotAxHandle,ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers,ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Fitness,ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Ensemble,C(1,:),C(1,:))
end
if isempty(ErrorFit.MaximumPerpendicularError.DirectionOne)==false
    AddExponentialFit(maxPerpPlotAxHandle,ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.MovementNumbers,ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.Fitness,ErrorFit.MaximumPerpendicularError.DirectionOne.Launch.Ensemble,C(2,:),C(2,:))
end
if isempty(ErrorFit.MaximumPerpendicularError.DirectionTwo)==false
    AddExponentialFit(maxPerpPlotAxHandle,ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.MovementNumbers,ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.Fitness,ErrorFit.MaximumPerpendicularError.DirectionTwo.Launch.Ensemble,C(3,:),C(3,:))
end
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    AddExponentialFit(maxPerpPlotAxHandle,ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.MovementNumbers,ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.Fitness,ErrorFit.MaximumPerpendicularError.DirectionThree.Launch.Ensemble,C(4,:),C(4,:))
end
clear C


% exportgraphics(gcf,"ForJim.emf",'ContentType','vector')
% exportgraphics(gcf,"ForJim.eps",'ContentType','vector')
% exportgraphics(gcf,"D:\Box Sync\Error Fields Paper Files\Temp.png",'ContentType','vector')
% exportgraphics(gcf,"ForJim.png","Resolution",600);
% savefig(gcf,"ForJim")
%% Speed Plot
PlotErrorTimeSeries([1:numel(Data)],'Speed','launch');

%% Deviation Angle Plot : Launch
C=EquiDistantColorGenerator(4,9742);
[maxDevPlotFigHandle,maxDevPlotAxHandle]=PlotErrorTimeSeries([1:numel(Data)],'LaunchDeviationAngle');
% AddRosePlots(maxDevPlotFigHandle,maxDevPlotAxHandle,'LaunchDeviationAngle','launch');
AddExponentialFit(maxDevPlotAxHandle,ErrorFit.LaunchDeviationAngle.MovementNumbers,ErrorFit.LaunchDeviationAngle.Fitness,ErrorFit.LaunchDeviationAngle.Ensemble,[0.3,0.3,0.3],[0.6,0.6,0.6])
if isempty(ErrorFit.LaunchDeviationAngle.DirectionZero)==false
    AddExponentialFit(maxDevPlotAxHandle,ErrorFit.LaunchDeviationAngle.DirectionZero.MovementNumbers,ErrorFit.LaunchDeviationAngle.DirectionZero.Fitness,ErrorFit.LaunchDeviationAngle.DirectionZero.Ensemble,C(1,:),C(1,:))
end
if isempty(ErrorFit.LaunchDeviationAngle.DirectionOne)==false
    AddExponentialFit(maxDevPlotAxHandle,ErrorFit.LaunchDeviationAngle.DirectionOne.MovementNumbers,ErrorFit.LaunchDeviationAngle.DirectionOne.Fitness,ErrorFit.LaunchDeviationAngle.DirectionOne.Ensemble,C(2,:),C(2,:))
end
if isempty(ErrorFit.LaunchDeviationAngle.DirectionTwo)==false
    AddExponentialFit(maxDevPlotAxHandle,ErrorFit.LaunchDeviationAngle.DirectionTwo.MovementNumbers,ErrorFit.LaunchDeviationAngle.DirectionTwo.Fitness,ErrorFit.LaunchDeviationAngle.DirectionTwo.Ensemble,C(3,:),C(3,:))
end
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    AddExponentialFit(maxDevPlotAxHandle,ErrorFit.LaunchDeviationAngle.DirectionThree.MovementNumbers,ErrorFit.LaunchDeviationAngle.DirectionThree.Fitness,ErrorFit.LaunchDeviationAngle.DirectionThree.Ensemble,C(4,:),C(4,:))
end
clear C
%% Error Amplitude Plot : Entire Length
PlotErrorTimeSeries([1:numel(Data)],'MaximumErrorAmplitude','entire');

%% Azimuth Angle
PlotErrorTimeSeries([1:numel(Data)],"MaximumAzimuthAngle")
%% ElevationAngle
PlotErrorTimeSeries([1:numel(Data)],"MaximumElevationAngle")
%% Error Amplitude Plot : Launch
C=EquiDistantColorGenerator(4,0.9742);
[maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumErrorAmplitude','launch');
% [maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries(GetIndexForDirection(0),'MaximumErrorAmplitude','launch');
% [maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries(GetIndexForDirection(1),'MaximumErrorAmplitude','launch');
% [maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries(GetIndexForDirection(2),'MaximumErrorAmplitude','launch');
% [maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries(GetIndexForDirection(3),'MaximumErrorAmplitude','launch');
% AddRosePlots(maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle,'MaximumErrorAmplitude','launch');
AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.MovementNumbers,ErrorFit.MaximumErrorAmplitude.Fitness,ErrorFit.MaximumErrorAmplitude.Ensemble,[0.3,0.3,0.3],[0.6,0.6,0.6])
if isempty(ErrorFit.MaximumErrorAmplitude.DirectionZero)==false
    AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.DirectionZero.MovementNumbers,ErrorFit.MaximumErrorAmplitude.DirectionZero.Fitness,ErrorFit.MaximumErrorAmplitude.DirectionZero.Ensemble,C(1,:),C(1,:))
end
if isempty(ErrorFit.MaximumErrorAmplitude.DirectionOne)==false
    AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.DirectionOne.MovementNumbers,ErrorFit.MaximumErrorAmplitude.DirectionOne.Fitness,ErrorFit.MaximumErrorAmplitude.DirectionOne.Ensemble,C(2,:),C(2,:))
end
if isempty(ErrorFit.MaximumErrorAmplitude.DirectionTwo)==false
    AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.DirectionTwo.MovementNumbers,ErrorFit.MaximumErrorAmplitude.DirectionTwo.Fitness,ErrorFit.MaximumErrorAmplitude.DirectionTwo.Ensemble,C(3,:),C(3,:))
end
if strcmp(Data{1}.ExperimentMode,'3D')==true(1)
    AddExponentialFit(maxErrAmpPlotAxHandle,ErrorFit.MaximumErrorAmplitude.DirectionThree.MovementNumbers,ErrorFit.MaximumErrorAmplitude.DirectionThree.Fitness,ErrorFit.MaximumErrorAmplitude.DirectionThree.Ensemble,C(4,:),C(4,:))
end
clear C

%% Estimation Execution Time
execTime=[];for counter=1:numel(Data), if Data{counter}.RestingMovementFlag==true(1), continue, else, execTime=[execTime;Data{counter}.EstimationExecutionTime]; end, end
histogram(execTime,50,'Normalization','probability')
disp("In "+num2str(100*(numel(find(execTime<0.004)))/(numel(execTime))) + " % of times, the estimation function took less than 4 ms to be calculated ")
clear counter execTime

%% Execution Time
load('S_17_2D_15_May_2024.mat')
phasebeginTrials=cumsum([1,InputFile.PhaseDurations(1:8)]);
totalDeltaTime=[];
for counter=1:numel(Data)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
        continue
    else
        totalDeltaTime=[totalDeltaTime;Data{counter}.SampleTime];
    end
end
s_18_sampleTime = totalDeltaTime;
clearvars -except s_18_sampleTime
load('Leah_2D_April24_2024_left.mat');
phasebeginTrials=cumsum([1,InputFile.PhaseDurations(1:8)]);
totalDeltaTime=[];
for counter=1:numel(Data)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
        continue
    else
        totalDeltaTime=[totalDeltaTime;Data{counter}.SampleTime];
    end
end
leah_sampleTime = totalDeltaTime;
clearvars -except s_18_sampleTime leah_sampleTime
%% 

C=EquiDistantColorGenerator(2,0.90579);
ax_1=axes;hold(ax_1,"on");
s_18=rmoutliers(s_18_sampleTime,"percentiles",[0 99.5]);
histogram(ax_1,s_18,'Normalization','probability','FaceColor',C(1,:),'EdgeColor',C(1,:));
leah=rmoutliers(leah_sampleTime,"percentiles",[0 99.5]);
histogram(ax_1,leah,'Normalization','probability','FaceColor',C(2,:),'EdgeColor',C(2,:));
qs_18=quantile(s_18,[0.25 0.5 0.75]);
qLeah=quantile(leah,[0.25 0.5 0.75]);
for counter=1:numel(qs_18)
    switch counter
        case 1
            lstr="Q 25% = ";
        case 2
            lstr="Q 50% = ";
        case 3
            lstr="Q 75% = ";
    end
    xline(ax_1,qs_18(counter),'-',lstr+num2str(1000*round(qs_18(counter),4))+" ms",'LabelHorizontalAlignment','left','Color',C(1,:),FontSize=18,LineWidth=3)
    xline(ax_1,qLeah(counter),'-',lstr+num2str(1000*round(qLeah(counter),4))+" ms",'LabelHorizontalAlignment','right','Color',C(2,:),FontSize=18,LineWidth=3)
end
title(ax_1,"Loop execution time for"+['\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', C(1,:)) '} BURT 2023 ',',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', C(2,:)) '} BURT 2018 ']);
xticks(ax_1,[0,1e-3,5e-3,10e-3,15e-3,20e-3]);
xticklabels(ax_1,{"0 ms","1 ms","5 ms","10 ms","15 ms","20 ms"});
set(ax_1,"FontSize",16)
% tickz=sort([quantile(s_18,[0.25 0.5 0.75]),quantile(leah,[0.25 0.5 0.75])]);tickz=[0,tickz,15e-3];
% labels=compose('%f',tickz);
% xticklabels(ax_1,labels);
% xlabel("Loop Execution Time (ms)")
% xticks (ax_1,[min(leah_sampleTime),quantile(leah_sampleTime,[0.25,0.5,0.75]),max(leah_sampleTime)]);xtickangle(ax_2,90);
% xline(ax_1,q_leah,'--',{"25 %","50 %","75 %"},'LabelHorizontalAlignment','center')

% ax_3=subplot(2,2,3);ylabel(ax_3,"ExecutionTime for BURT 2023 ABOVE 75% Quantile ");hold(ax_3,"on")
% s_18_above_75=s_18_sampleTime(s_18_sampleTime>q_s_18(3));
% histogram(s_18_above_75);
% xline(ax_3,quantile(s_18_above_75,[0.25,0.5,0.75]),'--',{"25 %","50 %","75 %"},'LabelHorizontalAlignment','center')
% xticks (ax_3,[min(s_18_above_75),quantile(s_18_above_75,[0.25,0.5,0.75]),max(s_18_above_75)]);xtickangle(ax_3,90)
% 
% ax_4=subplot(2,2,4);ylabel(ax_4,"ExecutionTime for BURT 2018 ABOVE 75% Quantile ");hold(ax_4,"on")
% leah_above_75=leah_sampleTime(leah_sampleTime>q_leah(3));
% histogram(leah_above_75);
% xline(ax_4,quantile(leah_above_75,[0.25,0.5,0.75]),'--',{"25 %","50 %","75 %"},'LabelHorizontalAlignment','center')
% xticks (ax_4,[min(leah_above_75),quantile(leah_above_75,[0.25,0.5,0.75]),max(leah_above_75)]);xtickangle(ax_4,90)

%% Path Distance and Launch Verification
phasebeginTrials=cumsum([1,InputFile.PhaseDurations(1:8)]);
lowSpeedThreshold=0.2766;
highSpeedThreshold=0.4348;
slowManualCounter=1;
goodManualCounter=1;
fastManualCounter=1;
for counter=1:numel(Data)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
        continue
    else
        tempLanuchIndex=Data{counter}.TherapyWindowIndex;
        tempLaunchPathDistance=Data{counter}.PathDistance(tempLanuchIndex);
        tempLaunchTime=Data{counter}.TrialTime(tempLanuchIndex);
        tempMaxLaunchSpeed=Data{counter}.Maximum.Launch.Speed;
        if tempMaxLaunchSpeed>=lowSpeedThreshold && tempMaxLaunchSpeed<=highSpeedThreshold
            goodPathTimeCell{goodManualCounter,1}=tempLaunchPathDistance;
            goodPathTimeCell{goodManualCounter,2}=tempLaunchTime;
            goodMinMaxTime(goodManualCounter,:)=[tempLaunchTime(1),tempLaunchTime(end)];
            goodManualCounter=goodManualCounter+1;
        elseif tempMaxLaunchSpeed<lowSpeedThreshold
            slowPathTimeCell{slowManualCounter,1}=tempLaunchPathDistance;
            slowPathTimeCell{slowManualCounter,2}=tempLaunchTime;
            slowMinMaxTime(slowManualCounter,:)=[tempLaunchTime(1),tempLaunchTime(end)];
            slowManualCounter=slowManualCounter+1;
        elseif tempMaxLaunchSpeed>highSpeedThreshold
            fastPathTimeCell{fastManualCounter,1}=tempLaunchPathDistance;
            fastPathTimeCell{fastManualCounter,2}=tempLaunchTime;
            fastMinMaxTime(fastManualCounter,:)=[tempLaunchTime(1),tempLaunchTime(end)];
            fastManualCounter=fastManualCounter+1;
        end
        clear tempLanuchIndex tempLaunchPathDistance tempLaunchTime tempMaxLaunchSpeed 
    end
end
clear counter lowSpeedThreshold highSpeedThreshold phasebeginTrials goodManualCounter slowManualCounter fastManualCounter
ax(1)=subplot(3,3,1);hold(ax(1),"on");xlabel(ax(1),"Path Distance (m)");ylabel(ax(1),"Time");title(ax(1),"Good Speed Feedback");
ax(4)=subplot(3,3,4);hold(ax(4),"on");xlabel(ax(4),"Path Distance (m)");ylabel(ax(4),"Time");title(ax(4),"Slow Speed Feedback");
ax(7)=subplot(3,3,7);hold(ax(7),"on");xlabel(ax(7),"Path Distance (m)");ylabel(ax(7),"Time");title(ax(7),"Fast Speed Feedback");
for counter=1:size(goodPathTimeCell,1)
    plot(ax(1),goodPathTimeCell{counter,1},goodPathTimeCell{counter,2},'.-');
end
for counter=1:size(slowPathTimeCell,1)
    plot(ax(4),slowPathTimeCell{counter,1},slowPathTimeCell{counter,2},'.-');
end
for counter=1:size(fastPathTimeCell,1)
    plot(ax(7),fastPathTimeCell{counter,1},fastPathTimeCell{counter,2},'.-');
end
ax(2)=subplot(3,3,2);violinplot(goodMinMaxTime(:,1));title(ax(2),"GOOD : TIME AT Path=0.005");
ax(3)=subplot(3,3,3);violinplot(goodMinMaxTime(:,2));title(ax(3),"GOOD : TIME AT Path=0.105");
ax(5)=subplot(3,3,5);violinplot(slowMinMaxTime(:,1));title(ax(5),"SLOW : TIME AT Path=0.005");
ax(6)=subplot(3,3,6);violinplot(slowMinMaxTime(:,2));title(ax(6),"SLOW : TIME AT Path=0.105");
ax(8)=subplot(3,3,8);violinplot(fastMinMaxTime(:,1));title(ax(8),"FAST : TIME AT Path=0.005");
ax(9)=subplot(3,3,9);violinplot(fastMinMaxTime(:,2));title(ax(9),"FAST : TIME AT Path=0.105");
clear counter ax goodPathTimeCell goodMinMaxTime slowPathTimeCell slowMinMaxTime fastPathTimeCell fastMinMaxTime

%% ZOH Comparison
orderCounter=1;
for order=2:7    
    load('Leah_2D_April24_2024_left.mat')
    OLD_ZOH_Counter=[];
    OLD_ZOH_Time=[];
    for counter=1:numel(Data)
        tempActualPosition=Data{counter}.ActualPosition;
        tempTrialTime=Data{counter}.SampleTime;
        [tempZOHX,tempTimeZOHX]=CheckZOH(tempActualPosition(:,1),order,tempTrialTime);
        [tempZOHY,tempTimeZOHY]=CheckZOH(tempActualPosition(:,2),order,tempTrialTime);
        [tempZOHZ,tempTimeZOHZ]=CheckZOH(tempActualPosition(:,3),order,tempTrialTime);
        OLD_ZOH_Counter=[OLD_ZOH_Counter;sum([tempZOHX,tempZOHY,tempZOHZ])];
        OLD_ZOH_Time=[OLD_ZOH_Time;tempTimeZOHX(:);tempTimeZOHY(:);tempTimeZOHZ(:)];
        clear tempActualPosition tempZOHX tempZOHY tempZOHZ tempTimeZOHX tempTimeZOHY tempTimeZOHZ
    end
    clearvars -except OLD_ZOH_Counter order OLD_ZOH_Time orderCounter
    load('S_18_2D_26_April_2024.mat')
    NEW_ZOH_Counter=[];
    NEW_ZOH_Time=[];
    for counter=1:numel(Data)
        tempActualPosition=Data{counter}.ActualPosition;
        tempTrialTime=Data{counter}.SampleTime;
        [tempZOHX,tempTimeZOHX]=CheckZOH(tempActualPosition(:,1),order,tempTrialTime);
        [tempZOHY,tempTimeZOHY]=CheckZOH(tempActualPosition(:,2),order,tempTrialTime);
        [tempZOHZ,tempTimeZOHZ]=CheckZOH(tempActualPosition(:,3),order,tempTrialTime);
        NEW_ZOH_Counter=[NEW_ZOH_Counter;sum([tempZOHX,tempZOHY,tempZOHZ])];
        NEW_ZOH_Time=[NEW_ZOH_Time;tempTimeZOHX(:);tempTimeZOHY(:);tempTimeZOHZ(:)];
        clear tempActualPosition tempZOHX tempZOHY tempZOHZ tempTimeZOHX tempTimeZOHY tempTimeZOHZ
    end
    clearvars -except OLD_ZOH_Counter NEW_ZOH_Counter OLD_ZOH_Time NEW_ZOH_Time order orderCounter
    disp(order)
    fig(orderCounter)=figure;subplot(1,2,1);histogram(OLD_ZOH_Time);xlabel('Hold Time (s)');xline(mean(OLD_ZOH_Time));title("BURT 2018 Hold time for "+num2str(order)+" holds")
           subplot(1,2,2);histogram(NEW_ZOH_Time);xlabel('Hold Time (s)');xline(mean(NEW_ZOH_Time));title("BURT 2023 Hold time for "+num2str(order)+" holds")
           exportgraphics(fig(orderCounter),strcat("Hold",num2str(order),".png"));
           pause(0.5)
end


%% Movement Time

movementExecutionTime  =  [];

for counter=1:numel(Data)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
        continue
    else
        movementExecutionTime  =  [movementExecutionTime;Data{counter}.MovementTime];
    end
end

plot(movementExecutionTime, '.');

PlotErrorTimeSeiesVariableSize([1:numel(Data)],'MaximumErrorAmplitude','launch', [], movementExecutionTime)
