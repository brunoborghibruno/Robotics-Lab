clear all;
close all;
clc
% Load Data From Files
global ErrorFit Data InputFile PhaseIndex SpecialMovementIndex InterpolatedData IntermittentExposureData HypothesisTest SysID PostTrainingDistributions PrePostAnalysis
oldFolder=pwd;
% % % % % % % % % % % % % % % % COMPLETED SUBJECTS


% % % % newFolder=strcat(oldFolder,'/E-5/10152024/'); % VISIT 1
% % % % newFolder=strcat(oldFolder,'/E-5/10212024/'); % VISIT 2
% % % % newFolder=strcat(oldFolder,'/E-5/10232024/'); % VISIT 3 
% % % % newFolder=strcat(oldFolder,'/E-5/10252024/'); % VISIT 4
% % % % newFolder=strcat(oldFolder,'/E-5/10282024/'); % VISIT 5
% % % % newFolder=strcat(oldFolder,'/E-5/10302024/'); % VISIT 6
% % % % newFolder=strcat(oldFolder,'/E-5/1152024/');  % VISIT 7
% % % % newFolder=strcat(oldFolder,'/E-5/11142024/'); % VISIT 8
% % % % newFolder=strcat(oldFolder,'/E-5/12162024/'); % VISIT 9

% % % % newFolder=strcat(oldFolder,'/E-16/372025/');  % VISIT 1
% % % % newFolder=strcat(oldFolder,'/E-16/3102025/'); % VISIT 2
% % % % newFolder=strcat(oldFolder,'/E-16/3122025/'); % VISIT 3 
% % % % newFolder=strcat(oldFolder,'/E-16/3142025/'); % VISIT 4
% % % % newFolder=strcat(oldFolder,'/E-16/3162025/'); % VISIT 5
% % % % newFolder=strcat(oldFolder,'/E-16/3182025/'); % VISIT 6
% % % % newFolder=strcat(oldFolder,'/E-16/3202025/'); % VISIT 7
% % % % newFolder=strcat(oldFolder,'/E-16/3282025/'); % VISIT 8
% % % % newFolder=strcat(oldFolder,'/E-16/4282025/'); % VISIT 9

% % % % newFolder=strcat(oldFolder,'/E-21/4302025/'); % VISIT 1
% % % % newFolder=strcat(oldFolder,'/E-21/552025/'); % VISIT 2
% % % % newFolder=strcat(oldFolder,'/E-21/572025/'); % VISIT 3
% % % % newFolder=strcat(oldFolder,'/E-21/592025/'); % VISIT 4
% % % % newFolder=strcat(oldFolder,'/E-21/5122025/'); % VISIT 5
% % % % newFolder=strcat(oldFolder,'/E-21/5142025/'); % VISIT 6
% % % % newFolder=strcat(oldFolder,'/E-21/5162025/'); % VISIT 7
% % % % newFolder=strcat(oldFolder,'/E-21/5202025/'); % VISIT 8
% % % % newFolder=strcat(oldFolder,'/E-21/772025/'); % VISIT 9

% % % % newFolder=strcat(oldFolder,'/E-25/572025/'); % VISIT 1
% % % % newFolder=strcat(oldFolder,'/E-25/5192025/'); % VISIT 2
% % % % newFolder=strcat(oldFolder,'/E-25/5212025/'); % VISIT 3
% % % % newFolder=strcat(oldFolder,'/E-25/5232025/'); % VISIT 4
% % % % newFolder=strcat(oldFolder,'/E-25/5272025/'); % VISIT 5
% % % % newFolder=strcat(oldFolder,'/E-25/5282025/'); % VISIT 6
% % % % newFolder=strcat(oldFolder,'/E-25/5302025/'); % VISIT 7
% % % % newFolder=strcat(oldFolder,'/E25/622025/'); % VISIT 8
% % % % newFolder=strcat(oldFolder,'/E-25/7112025/'); % VISIT 9

% % % % newFolder=strcat(oldFolder,'/P-1/512025/'); % VISIT 1
% % % % newFolder=strcat(oldFolder,'/P-1/582025/'); % VISIT 2

% % % % newFolder=strcat(oldFolder,'/E-22/4182025/'); % BASELINE VISIT
% % % % newFolder=strcat(oldFolder,'/E-22/4222025/'); % VISIT 1

% % % % newFolder=strcat(oldFolder,'/E-26/7112025/'); % VISIT 1
% % % % newFolder=strcat(oldFolder,'/E-26/7222025/'); % VISIT 2
% % % % newFolder=strcat(oldFolder,'/E-26/7242025/'); % VISIT 3
% % % % newFolder=strcat(oldFolder,'/E-26/7252025/'); % VISIT 4
% % % % newFolder=strcat(oldFolder,'/E-26/7292025/'); % VISIT 5
% % % % newFolder=strcat(oldFolder,'/E-26/7312025/'); % VISIT 6
% % % % newFolder=strcat(oldFolder,'/E-26/812025/'); % VISIT 7
% % % % newFolder=strcat(oldFolder,'/E-26/852025/'); % VISIT 8
% % % % newFolder=strcat(oldFolder,'/E-26/992025/'); % VISIT 9

% % % % % % % % % % % % % % % % IN-PROGRESS SUBJECTS

% newFolder=strcat(oldFolder,'/E-28/1032025/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-28/1062025/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-28/1082025/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-28/10102025/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-28/10132025/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-28/10152025/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-28/10172025/'); % VISIT 7
% % newFolder=strcat(oldFolder,'/E-28/10222025/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-28/11172025/'); % VISIT 9


% % newFolder=strcat(oldFolder,'/P-2/11112025/'); % SCI first visit
% % newFolder=strcat(oldFolder,'/P-2/11132025/'); % SCI second visit
% newFolder=strcat(oldFolder,'/P-2/11172025/'); % SCI third visit


% newFolder=strcat(oldFolder,'/E-38/1152026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-38/1212026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-38/1222026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-38/1232026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-38/1282026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-38/1292026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-38/1302026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-38/242026/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-38/3122026/'); % VISIT 9


% newFolder=strcat(oldFolder,'/E-42/422026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-42/462026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-42/472026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-42/4132026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-42/4152026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-42/4162026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-42/4172026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-42/4212026/'); % VISIT 8
newFolder=strcat(oldFolder,'/E-42/5152026/'); % VISIT 9


% newFolder=strcat(oldFolder,'/E-44/1292026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-44/242026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-44/252026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-44/262026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-44/2102026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-44/2122026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-44/2132026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-44/2162026/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-44/3232026/'); % VISIT 9



% newFolder=strcat(oldFolder,'/E-47/1302026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-47/232026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-47/252026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-47/262026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-47/2112026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-47/2122026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-47/2132026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-47/2192026/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-47/3272026/'); % VISIT 9



% newFolder=strcat(oldFolder,'/E-56/2272026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-56/322026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-56/352026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-56/362026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-56/392026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-56/3122026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-56/3132026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-56/3162026/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-56/4132026/'); % VISIT 9



% newFolder=strcat(oldFolder,'/E-69/4162026/'); % VISIT 1
% newFolder=strcat(oldFolder,'/E-69/4222026/'); % VISIT 2
% newFolder=strcat(oldFolder,'/E-69/4232026/'); % VISIT 3
% newFolder=strcat(oldFolder,'/E-69/4242026/'); % VISIT 4
% newFolder=strcat(oldFolder,'/E-69/4272026/'); % VISIT 5
% newFolder=strcat(oldFolder,'/E-69/4282026/'); % VISIT 6
% newFolder=strcat(oldFolder,'/E-69/512026/'); % VISIT 7
% newFolder=strcat(oldFolder,'/E-69/542026/'); % VISIT 8
% newFolder=strcat(oldFolder,'/E-69/612026/'); % VISIT 9











%Test subject E-1
% newFolder=strcat(oldFolder,'/E-1/392026/'); % Visit_5





copyfile('ExtractFromCSV.m',newFolder);
copyfile('ExtractFromSevenPhaseInputCSV.m',newFolder);
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
failedExtractTrials = [];
dataCounter=1;
for movementCounter=1:length(sortedFileNames)
    disp("Trying exatracting "+ movementCounter + " ---> " +sortedFileNames{movementCounter});
    if ~isequal(sortedFileNames{movementCounter},[])
        [Data{dataCounter,1}, tempTrialSavedCorrectly] = ExtractFromCSV(sortedFileNames{movementCounter});
        if tempTrialSavedCorrectly == false
            failedExtractTrials = [failedExtractTrials,movementCounter];
            disp("!!!!!!!!!!!  DATA COULD NOT BE EXTRACTED FROM ---->  " + pwd + "\"  +  sortedFileNames{movementCounter});
        end
        clear tempTrialSavedCorrectly
        dataCounter=dataCounter+1;
    end
end
disp("-------------------------------------------------------------------")
disp("TOTAL OF #"+numel(failedExtractTrials)+" failed to be extracted !!!");
disp(failedExtractTrials)
clear tempString tempStringLength sortedFileNames position movementCounter filesInDirectory fileNames fileNamesIndex counter first last underlinePositions dataCounter filesInDirectoryTemp dotPoistion

InputFile=ExtractFromSevenPhaseInputCSV('PatientExperimentDesign3D.csv');
InterpolatedData.DirectionZero=ReadInterpolatedErrorFiles(0);
IntermittentExposureData.DirectionZero=ReadIntermittentExposureMovementFiles(0);
InterpolatedData.DirectionOne=ReadInterpolatedErrorFiles(1);
IntermittentExposureData.DirectionOne=ReadIntermittentExposureMovementFiles(1);
InterpolatedData.DirectionTwo=ReadInterpolatedErrorFiles(2);
IntermittentExposureData.DirectionTwo=ReadIntermittentExposureMovementFiles(2);
InterpolatedData.DirectionThree=ReadInterpolatedErrorFiles(3);
IntermittentExposureData.DirectionThree=ReadIntermittentExposureMovementFiles(3);

cd(oldFolder)
clear oldFolder newFolder type
% Getting The Phase Indexes
% 

familiarizationIndex=[];
baselineIndex=[];
unpracticedIntermittentExposurePhaseIndex=[];
intermittentExposurePhase=[];
trainingPhase=[];
washoutPhase=[];
unpracticedWashoutPhase=[];

for counter=1:numel(Data)
    if isstruct(Data{counter}) == false || ~isfield(Data{counter},"MovementNumber")
        continue
    elseif ismember(Data{counter}.MovementNumber, InputFile.RestTrials) || Data{counter}.PhaseBeginningTrial
        continue
    else
        if  strcmp(Data{counter}.ExperimentPhase(1:3),'End')==true(1) || strcmp(Data{counter}.ExperimentPhase(1:5),'Start')==true(1)
            continue
        elseif strcmp(Data{counter}.ExperimentPhase(1:5),'Famil')==true(1)
            familiarizationIndex=[familiarizationIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'BaselinePhase')==true(1)
            baselineIndex=[baselineIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'UnpracticedIntermittentExposurePhase')==true(1)
            unpracticedIntermittentExposurePhaseIndex=[unpracticedIntermittentExposurePhaseIndex;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'IntermittentExposurePhase')==true(1)
            intermittentExposurePhase=[intermittentExposurePhase;counter];
        elseif strcmp(Data{counter}.ExperimentPhase,'TrainingPhase')==true(1)
            trainingPhase=[trainingPhase;counter];
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
PhaseIndex.Washout=washoutPhase;
PhaseIndex.UnpracticedWashout=unpracticedWashoutPhase;
clear familiarizationIndex unpracticedIntermittentExposurePhaseIndex baselineIndex intermittentExposurePhase trainingPhase washoutPhase unpracticedWashoutPhase counter
% Special Movements
SpecialMovementIndex.IntermittentExposure.DirectionZero=[];
SpecialMovementIndex.IntermittentExposure.DirectionOne=[];
SpecialMovementIndex.IntermittentExposure.DirectionTwo=[];
SpecialMovementIndex.IntermittentExposure.DirectionThree=[];
SpecialMovementIndex.IntermittentExposure.DirectionFour=[];
SpecialMovementIndex.IntermittentExposure.DirectionFive=[];
SpecialMovementIndex.IntermittentExposure.DirectionSix=[];
SpecialMovementIndex.IntermittentExposure.DirectionSeven=[];
allINTXIndexes=sort([PhaseIndex.IntermittentExposure]);
for counter=1:numel(allINTXIndexes)
    tempDirection=Data{allINTXIndexes(counter)}.MovementDirection;
    tempMovementNumber=Data{allINTXIndexes(counter)}.MovementNumber;
    if InputFile.Dictionary(tempMovementNumber).DistortionType==0 && ismember(tempMovementNumber,InputFile.RestTrials) == false
            switch tempDirection
                case 0
                    SpecialMovementIndex.IntermittentExposure.DirectionZero=[SpecialMovementIndex.IntermittentExposure.DirectionZero;allINTXIndexes(counter)];
                case 1
                    SpecialMovementIndex.IntermittentExposure.DirectionOne=[SpecialMovementIndex.IntermittentExposure.DirectionOne;allINTXIndexes(counter)];
                case 2
                    SpecialMovementIndex.IntermittentExposure.DirectionTwo=[SpecialMovementIndex.IntermittentExposure.DirectionTwo;allINTXIndexes(counter)];
                case 3
                    SpecialMovementIndex.IntermittentExposure.DirectionThree=[SpecialMovementIndex.IntermittentExposure.DirectionThree;allINTXIndexes(counter)];
            end
    end
    clear tempDirection tempMovementNumber
end
clear allINTXIndexes
SpecialMovementIndex.PureTraining.DirectionZero=[];
SpecialMovementIndex.PureTraining.DirectionOne=[];
SpecialMovementIndex.PureTraining.DirectionTwo=[];
SpecialMovementIndex.PureTraining.DirectionThree=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionZero=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionOne=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionTwo=[];
SpecialMovementIndex.AdaptationCatchTrial.DirectionThree=[];

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
%
%% Calculate Error Amplitude and MAX Errors, Directional Error
if ~isfield(Data{1},"TrueLaunchIndex"), AddTrueLaunchIndex(); end
for counter=1:numel(Data)
    if isstruct(Data{counter})==false || numel(fieldnames(Data{counter})) < 70
        continue
    else
        tempExtErr=Data{counter}.ExtentError;
        temHorErr=Data{counter}.HorizontalError;
        tempVerErr=Data{counter}.VerticalError;
        tempSpeed=vecnorm(Data{counter}.GlobalVelocity')';
        tempPosition=Data{counter}.GlobalPosition;
        if isfield(Data{counter},"OnsetDetectedIndex") || isempty(Data{counter}.OnsetDetectedIndex) || numel(Data{counter}.OnsetDetectedIndex)==1
            Data{counter}.ErrorAmplitude=vecnorm([tempExtErr,temHorErr,tempVerErr]')';
            Data{counter}.Maximum.Launch.ErrorAmplitude=nan;
            Data{counter}.Maximum.Launch.ExtentError=nan;
            Data{counter}.Maximum.Launch.HorizontalError=nan;
            Data{counter}.Maximum.Launch.VerticalError=nan;
            Data{counter}.Maximum.Launch.PerpendicularError=nan;
            Data{counter}.Maximum.Launch.Speed=nan;
            Data{counter}.LaunchDeviationAngle=nan;
            Data{counter}.BadTrialFlag='y';
            Data{counter}.PureLaunchDeviationAngle = nan;
            Data{counter}.Maximum.PureLaunch.ErrorAmplitude=nan;
            Data{counter}.Maximum.PureLaunch.ExtentError=nan;
            Data{counter}.Maximum.PureLaunch.HorizontalError=nan;
            Data{counter}.Maximum.PureLaunch.VerticalError=nan;
            Data{counter}.Maximum.PureLaunch.PerpendicularError=nan;
            Data{counter}.Maximum.PureLaunch.Speed=nan;
        else
            disp(counter)
            % tempLaunchIndex=GetLaunchIndex(Data{counter}.OnsetDetectedIndex,Data{counter}.TrialTime);
            tempLaunchIndex=Data{counter}.TherapyWindowIndex;
            tempPureLaunchIndex = Data{counter}.TrueLaunchIndex;
            Data{counter}.ErrorAmplitude=vecnorm([tempExtErr,temHorErr,tempVerErr]')';
            Data{counter}.Maximum.Launch.ErrorAmplitude=GetMaximumOf(Data{counter}.ErrorAmplitude(tempLaunchIndex));
            Data{counter}.Maximum.Launch.ExtentError=GetMaximumOf(tempExtErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.HorizontalError=GetMaximumOf(temHorErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.VerticalError=GetMaximumOf(tempVerErr(tempLaunchIndex));
            Data{counter}.Maximum.Launch.PerpendicularError=GetMaximumOf(Data{counter}.PerpendicularError(tempLaunchIndex));
            Data{counter}.Maximum.Launch.Speed=GetMaximumOf(tempSpeed(tempLaunchIndex));
            [Data{counter}.LaunchDeviationAngle, Data{counter}.PureLaunchDeviationAngle] = GetLaunchDeviationAngle(Data{counter}.LocalPosition,Data{counter}.GlobalVelocity,tempLaunchIndex,tempPureLaunchIndex);
            Data{counter}.ErrorAmplitude=vecnorm([tempExtErr,temHorErr,tempVerErr]')';
            Data{counter}.Maximum.PureLaunch.ErrorAmplitude=GetMaximumOf(Data{counter}.ErrorAmplitude(tempPureLaunchIndex));
            Data{counter}.Maximum.PureLaunch.ExtentError=GetMaximumOf(tempExtErr(tempPureLaunchIndex));
            Data{counter}.Maximum.PureLaunch.HorizontalError=GetMaximumOf(temHorErr(tempPureLaunchIndex));
            Data{counter}.Maximum.PureLaunch.VerticalError=GetMaximumOf(tempVerErr(tempPureLaunchIndex));
            Data{counter}.Maximum.PureLaunch.PerpendicularError=GetMaximumOf(Data{counter}.PerpendicularError(tempPureLaunchIndex));
            Data{counter}.Maximum.PureLaunch.Speed=GetMaximumOf(tempSpeed(tempPureLaunchIndex));
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
CalculateMaximumSpeedErrorAccuraccy();
CalculateMahalanobisDistance();
prematueMovements = GetPrematureOnsetDetectedMovements();
% Bad Trial
badtrialCounter=1;
for counter=1:numel(Data)
    if isstruct(Data{counter})
        if Data{counter}.UnIdealStart == true
            disp(Data{counter}.MovementNumber + " ---> "+ Data{counter}.TargetPosition([2,3],:))
            Data{counter}.BadTrialFlag='y';
            badtrialCounter=badtrialCounter+1;
        end
    else
        continue
    end
end
disp("Total Bad trials = " + badtrialCounter)
clear badtrialCounter
% 
badtrialCounter=1;
notreachedCounter=1;
bothCounter=1;
for counter=1:numel(Data)
    if ~isstruct(Data{counter}) || ~isfield(Data{counter},"RestingMovementFlag")
        continue
    elseif Data{counter}.RestingMovementFlag == true
        continue
    else
        if Data{counter}.UnIdealStart == true && Data{counter}.NotReachedTarget == false
            badtrialCounter=badtrialCounter+1;
        end
        if Data{counter}.NotReachedTarget == true && Data{counter}.UnIdealStart == false
            notreachedCounter=notreachedCounter+1;
        end
        if Data{counter}.NotReachedTarget == true && Data{counter}.UnIdealStart == true
            bothCounter=bothCounter+1;
        end
    end
end
disp("UN IDEAL START = "+badtrialCounter)
disp("NOT REACHED TARGET = "+notreachedCounter)
disp("BOTH = "+bothCounter)
%% Statistical Analysis 
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
    if(isempty(Data{counter})|| Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
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
AddToSysID;
% Calculating CrossValidated Exponential Regressions --> FIX MOVEMENT NUMBERS AND INDEXES
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
% 

PostTrainingDistributions.DirectionZero=[];
PostTrainingDistributions.DirectionOne=[];
PostTrainingDistributions.DirectionTwo=[];
PostTrainingDistributions.DirectionThree=[];
PostTrainingDistributions.DirectionZero=SetUpDistributions(directionZeroTestMovementNumbers);
PostTrainingDistributions.DirectionOne=SetUpDistributions(directionOneTestMovementNumbers);
PostTrainingDistributions.DirectionTwo=SetUpDistributions(directionTwoTestMovementNumbers);
PostTrainingDistributions.DirectionThree=SetUpDistributions(directionThreeTestMovementNumbers);

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
%% Comparison of Artifitial and Test 

artifitialInterpollatedData.DirectionZero=SetUpDistributions(SpecialMovementIndex.IntermittentExposure.DirectionZero);
artifitialInterpollatedData.DirectionOne=SetUpDistributions(SpecialMovementIndex.IntermittentExposure.DirectionOne);
artifitialInterpollatedData.DirectionTwo=SetUpDistributions(SpecialMovementIndex.IntermittentExposure.DirectionTwo);
artifitialInterpollatedData.DirectionThree=SetUpDistributions(SpecialMovementIndex.IntermittentExposure.DirectionThree);
artifitialPrePostAnalysis.WassersteinDistanceDifference.DirectionZero=GetWassersteinDistanceDifference(artifitialInterpollatedData.DirectionZero,PostTrainingDistributions.DirectionZero,'y',0);
artifitialPrePostAnalysis.WassersteinDistanceDifference.DirectionOne=GetWassersteinDistanceDifference(artifitialInterpollatedData.DirectionOne,PostTrainingDistributions.DirectionOne,'y',1);
artifitialPrePostAnalysis.WassersteinDistanceDifference.DirectionTwo=GetWassersteinDistanceDifference(artifitialInterpollatedData.DirectionTwo,PostTrainingDistributions.DirectionTwo,'y',2);
artifitialPrePostAnalysis.WassersteinDistanceDifference.DirectionThree=GetWassersteinDistanceDifference(artifitialInterpollatedData.DirectionThree,PostTrainingDistributions.DirectionThree,'y',3);


%% Anterior Directional Analysis for E-56 Visit 3
subjectHeightInInches = 68;
subjectAgeYears = 79;
subjectSex = 'm';
subjectWeightLbs = 200;
AddAnteriorPosition(subjectAgeYears,subjectSex,subjectHeightInInches,subjectWeightLbs);
%% 
close all;
PlotErrorTimeSeries([1:numel(Data)],'MaximumAmplitudeError','launch');
PlotErrorTimeSeries([1:numel(Data)], 'MaximumErrorAmplitude', 'launch', [], [], 1);
PlotErrorTimeSeries([1:numel(Data)], 'MaximumErrorAmplitude', 'launch', [], [], 'StartPositionAnterior');
PlotErrorTimeSeries([1:numel(Data)], 'MaximumErrorAmplitude', 'launch', [], [], 'StartPositionElevation');
PlotErrorTimeSeries([1:numel(Data)], 'MaximumPerpendicularError', 'launch', [], [], 'AnteriorAtOnset');
PlotErrorTimeSeries([1:numel(Data)], 'MaximumAppliedForce', 'launch', [], [], 'Speed');
%% Position analysis
C = [EquiDistantColorGenerator(4,9742); ones(4,3) - EquiDistantColorGenerator(4,9742)];
allCombinations = GetAnatomicalCombinationString();
desiredDirection = [];
errorType = 'MaximumErrorAmplitude';
subCombinations = {'Start Elbow Mid';'Start Shoulder Low';'Start Shoulder Mid';'Target Elbow Mid';'Target Shoulder Low';'Target Shoulder Mid';'Start Elbow Mid Shoulder Mid'};
combinations = allCombinations;
for counter = 1 : numel(combinations)
    [tempMovementNumbers, tempMovementDirections] = GetMovementAnatomicalType(combinations{counter}, desiredDirection);
    disp("------------------------------   " + combinations{counter} + "   ------------------------------")
    if isempty(tempMovementNumbers) || numel(tempMovementNumbers) < 2
        disp(" COMBINATION EMPTY OR HAS LESS THAN 2 MEMBERS !!!")
        continue
    else
        disp(" COMBINATION HAS " + numel(tempMovementNumbers) + " MEMBERS")
        ax = axes;
        currentDirs = sort(unique(tempMovementDirections));
        bcValues = nan(1, 8);
        bfValues = false(1, 8);
        for dirCounter = 1 : numel(currentDirs)
            d = currentDirs(dirCounter);
            logInd = ismember(tempMovementDirections, d);
            tempErrors = GetErrorVector(FetchIndexFromMovementNumber(tempMovementNumbers(logInd)), errorType, 'launch');
            tempErrors = rmoutliers(tempErrors,"percentiles",[10 90]);
            PlotDistributionViolinOnXValue(ax, d, tempErrors, C(d+1, :));
            if numel(tempErrors) >= 4
                [bfValues(d+1), bcValues(d+1)] = bimodalitycoeff(tempErrors);
            end
            clear logInd tempErrors
        end
        xlim(ax, [-1 8]);
        xticks(ax, 0:7);
        % Build per-direction tick labels from BC values; bold when BF is true
        tickLabels = repmat({'-'}, 8, 1);
        for d = 0:7
            if ismember(d, currentDirs)
                if ~isnan(bcValues(d+1))
                    bcStr = sprintf('%.2f', bcValues(d+1));
                    if bfValues(d+1)
                        tickLabels{d+1} = ['\bf' bcStr];
                    else
                        tickLabels{d+1} = bcStr;
                    end
                else
                    tickLabels{d+1} = 'n/a';
                end
            end
        end
        ax.XAxis.TickLabelInterpreter = 'tex';
        xticklabels(ax, tickLabels);
        ylim(ax, [0 0.225]);
        title(ax, combinations{counter})
        ylabel(ax,errorType);
        
        xlabel(ax, 'Bimodality Coefficient :{\bf True} if > 5/9')
        set(gcf,"Position",[67   516   560   420]);
        pause
        close all
    end
    clear tempMovementNumbers tempMovementDirections tempIndexes figureHandle ax bcValues bfValues
end


%% Data log stop sign





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  --------  STOP HERE THE DATA FILE LOG  --------  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% Plot of Erros During formation of Error Fields
ax=axes;hold(ax,"on");
PracticedColor=EquiDistantColorGenerator(4,9742);
UnpracticedColor=ones(size(PracticedColor))-PracticedColor;
    ColorMatrix=[PracticedColor;UnpracticedColor];
for counter=1:numel(Data)
    if ~isstruct(Data{counter})
        continue
    elseif Data{counter}.RestingMovementFlag == true
        continue
    elseif Data{counter}.UnIdealStart == true && Data{counter}.NotReachedTarget == false
        continue
            plot3(ax,Data{counter}.GlobalPosition(:,1),Data{counter}.GlobalPosition(:,3),Data{counter}.GlobalPosition(:,2),"Color",zeros(1,3))
    elseif Data{counter}.NotReachedTarget == true && Data{counter}.UnIdealStart == false
        continue
            plot3(ax,Data{counter}.GlobalPosition(:,1),Data{counter}.GlobalPosition(:,3),Data{counter}.GlobalPosition(:,2),"Color",zeros(1,3))
    elseif Data{counter}.NotReachedTarget == true && Data{counter}.UnIdealStart == true
        continue
            plot3(ax,Data{counter}.GlobalPosition(:,1),Data{counter}.GlobalPosition(:,3),Data{counter}.GlobalPosition(:,2),"Color",zeros(1,3))
    else
        plot3(ax,Data{counter}.GlobalPosition(:,1),Data{counter}.GlobalPosition(:,3),Data{counter}.GlobalPosition(:,2),"Color",ColorMatrix(Data{counter}.MovementDirection+1,:));
    end
end

%% Interpolation Results
% switch Data{1}.ExperimentMode
%     case '2D'
%         MakeTimeSliceClip('DirectionZeroTimeSlice',InterpolatedData.DirectionZero.DistributionTimes,...
%                                            InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices,...
%                                            InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices, ...
%                                            InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionZeroDistribution',InterpolatedData.DirectionZero.DistributionTimes,...
%                                                               InterpolatedData.DirectionZero.DistributionMeans,...
%                                                               InterpolatedData.DirectionZero.DistributionCovariances);
%         
%         MakeTimeSliceClip('DirectionOneTimeSlice',InterpolatedData.DirectionOne.DistributionTimes,...
%                                                    InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices,...
%                                                    InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices, ...
%                                                    InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionOneDistribution',InterpolatedData.DirectionOne.DistributionTimes,...
%                                                               InterpolatedData.DirectionOne.DistributionMeans,...
%                                                               InterpolatedData.DirectionOne.DistributionCovariances);
%         MakeTimeSliceClip('DirectionTwoTimeSlice',InterpolatedData.DirectionTwo.DistributionTimes,...
%                                                    InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices,...
%                                                    InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices, ...
%                                                    InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionTwoDistribution',InterpolatedData.DirectionTwo.DistributionTimes,...
%                                                               InterpolatedData.DirectionTwo.DistributionMeans,...
%                                                               InterpolatedData.DirectionTwo.DistributionCovariances);
%     case '3D'
%         MakeTimeSliceClip('DirectionZeroTimeSlice',InterpolatedData.DirectionZero.DistributionTimes,...
%                                            InterpolatedData.DirectionZero.ExtentErrorAtTimeSlices,...
%                                            InterpolatedData.DirectionZero.HorizontalErrorAtTimeSlices, ...
%                                            InterpolatedData.DirectionZero.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionZeroDistribution',InterpolatedData.DirectionZero.DistributionTimes,...
%                                                               InterpolatedData.DirectionZero.DistributionMeans,...
%                                                               InterpolatedData.DirectionZero.DistributionCovariances);
%         
%         MakeTimeSliceClip('DirectionOneTimeSlice',InterpolatedData.DirectionOne.DistributionTimes,...
%                                                    InterpolatedData.DirectionOne.ExtentErrorAtTimeSlices,...
%                                                    InterpolatedData.DirectionOne.HorizontalErrorAtTimeSlices, ...
%                                                    InterpolatedData.DirectionOne.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionOneDistribution',InterpolatedData.DirectionOne.DistributionTimes,...
%                                                               InterpolatedData.DirectionOne.DistributionMeans,...
%                                                               InterpolatedData.DirectionOne.DistributionCovariances);
%         MakeTimeSliceClip('DirectionTwoTimeSlice',InterpolatedData.DirectionTwo.DistributionTimes,...
%                                                    InterpolatedData.DirectionTwo.ExtentErrorAtTimeSlices,...
%                                                    InterpolatedData.DirectionTwo.HorizontalErrorAtTimeSlices, ...
%                                                    InterpolatedData.DirectionTwo.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionTwoDistribution',InterpolatedData.DirectionTwo.DistributionTimes,...
%                                                               InterpolatedData.DirectionTwo.DistributionMeans,...
%                                                               InterpolatedData.DirectionTwo.DistributionCovariances);
%         MakeTimeSliceClip('DirectionThreeTimeSlice',InterpolatedData.DirectionThree.DistributionTimes,...
%                                                    InterpolatedData.DirectionThree.ExtentErrorAtTimeSlices,...
%                                                    InterpolatedData.DirectionThree.HorizontalErrorAtTimeSlices, ...
%                                                    InterpolatedData.DirectionThree.VerticalErrorAtTimeSlices);
%         MakeErrorDistributionClip('DirectionThreeDistribution',InterpolatedData.DirectionThree.DistributionTimes,...
%                                                               InterpolatedData.DirectionThree.DistributionMeans,...
%                                                               InterpolatedData.DirectionThree.DistributionCovariances);
% 
% end

%% Perpendicular Error Plot : Launch
C=EquiDistantColorGenerator(4,9742);
[maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([1:numel(Data)],'MaximumPerpendicularError','launch');
% [maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumPerpendicularError','launch','CreareEmptySpace');
% [maxPerpPlotFigHandle,maxPerpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumPerpendicularError','launch');

% AddRosePlots(maxPerpPlotFigHandle,maxPerpPlotAxHandle,'MaximumPerpendicularError','launch');
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
figure;PlotErrorTimeSeries([1:numel(Data)],'Speed','launch');

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
set(maxDevPlotAxHandle,"YLim",[0,200])
clear C


%% Error Amplitude Plot : Entire Length
PlotErrorTimeSeries([1:numel(Data)],'MaximumSpeedErrorMagnitude');


%% Error Amplitude Plot : Launch
C=EquiDistantColorGenerator(4,9742);
[maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries([1:numel(Data)],'MaximumErrorAmplitude','launch');
% [maxErrAmpPlotFigHandle,maxErrAmpPlotAxHandle]=PlotErrorTimeSeries([5:numel(Data)],'MaximumErrorAmplitude','launch','CreateEmptySpace');
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


%% Speed Error Magnitude
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),0)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),1)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),2)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),3)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),4)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),5)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),6)),'MaximumSpeedErrorMagnitude')
% PlotErrorTimeSeries(FetchIndexFromMovementNumber(GetMovementNumber(1:numel(Data),7)),'MaximumSpeedErrorMagnitude')
[maxSpdErrPlotFigHandle,maxSpdErrPlotAxHandle]=PlotErrorTimeSeries([1:numel(Data)],'MaximumSpeedErrorMagnitude');
%% Path Distance and Launch Verification
phasebeginTrials=cumsum([1,InputFile.PhaseDurations(1:end-1)]);
lowSpeedThreshold=0.2766;
highSpeedThreshold=0.4348;
slowManualCounter=1;
goodManualCounter=1;
fastManualCounter=1;
for counter=1:numel(Data)
    if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1) || Data{counter}.BadTrialFlag == 'y')
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

% % % % %% ZOH Comparison
% % % % orderCounter=1;
% % % % for order=2:7    
% % % %     load('Leah_2D_April24_2024_left.mat')
% % % %     OLD_ZOH_Counter=[];
% % % %     OLD_ZOH_Time=[];
% % % %     for counter=1:numel(Data)
% % % %         tempActualPosition=Data{counter}.ActualPosition;
% % % %         tempTrialTime=Data{counter}.SampleTime;
% % % %         [tempZOHX,tempTimeZOHX]=CheckZOH(tempActualPosition(:,1),order,tempTrialTime);
% % % %         [tempZOHY,tempTimeZOHY]=CheckZOH(tempActualPosition(:,2),order,tempTrialTime);
% % % %         [tempZOHZ,tempTimeZOHZ]=CheckZOH(tempActualPosition(:,3),order,tempTrialTime);
% % % %         OLD_ZOH_Counter=[OLD_ZOH_Counter;sum([tempZOHX,tempZOHY,tempZOHZ])];
% % % %         OLD_ZOH_Time=[OLD_ZOH_Time;tempTimeZOHX(:);tempTimeZOHY(:);tempTimeZOHZ(:)];
% % % %         clear tempActualPosition tempZOHX tempZOHY tempZOHZ tempTimeZOHX tempTimeZOHY tempTimeZOHZ
% % % %     end
% % % %     clearvars -except OLD_ZOH_Counter order OLD_ZOH_Time orderCounter
% % % %     load('S_18_2D_26_April_2024.mat')
% % % %     NEW_ZOH_Counter=[];
% % % %     NEW_ZOH_Time=[];
% % % %     for counter=1:numel(Data)
% % % %         tempActualPosition=Data{counter}.ActualPosition;
% % % %         tempTrialTime=Data{counter}.SampleTime;
% % % %         [tempZOHX,tempTimeZOHX]=CheckZOH(tempActualPosition(:,1),order,tempTrialTime);
% % % %         [tempZOHY,tempTimeZOHY]=CheckZOH(tempActualPosition(:,2),order,tempTrialTime);
% % % %         [tempZOHZ,tempTimeZOHZ]=CheckZOH(tempActualPosition(:,3),order,tempTrialTime);
% % % %         NEW_ZOH_Counter=[NEW_ZOH_Counter;sum([tempZOHX,tempZOHY,tempZOHZ])];
% % % %         NEW_ZOH_Time=[NEW_ZOH_Time;tempTimeZOHX(:);tempTimeZOHY(:);tempTimeZOHZ(:)];
% % % %         clear tempActualPosition tempZOHX tempZOHY tempZOHZ tempTimeZOHX tempTimeZOHY tempTimeZOHZ
% % % %     end
% % % %     clearvars -except OLD_ZOH_Counter NEW_ZOH_Counter OLD_ZOH_Time NEW_ZOH_Time order orderCounter
% % % %     disp(order)
% % % %     fig(orderCounter)=figure;subplot(1,2,1);histogram(OLD_ZOH_Time);xlabel('Hold Time (s)');xline(mean(OLD_ZOH_Time));title("BURT 2018 Hold time for "+num2str(order)+" holds")
% % % %            subplot(1,2,2);histogram(NEW_ZOH_Time);xlabel('Hold Time (s)');xline(mean(NEW_ZOH_Time));title("BURT 2023 Hold time for "+num2str(order)+" holds")
% % % %            exportgraphics(fig(orderCounter),strcat("Hold",num2str(order),".png"));
% % % %            pause(0.5)
% % % % end
% % % % 
% % % % 
% % % % %% Movement Time
% % % % 
% % % % movementExecutionTime  =  [];
% % % % 
% % % % for counter=1:numel(Data)
% % % %     if(Data{counter}.RestingMovementFlag==true(1) || ismember(Data{counter}.MovementNumber,phasebeginTrials)==true(1))
% % % %         continue
% % % %     else
% % % %         movementExecutionTime  =  [movementExecutionTime;Data{counter}.MovementTime];
% % % %     end
% % % % end
% % % % 
% % % % plot(movementExecutionTime, '.');
% % % % 
% % % % PlotErrorTimeSeiesVariableSize([1:numel(Data)],'MaximumErrorAmplitude','launch', [], movementExecutionTime)
