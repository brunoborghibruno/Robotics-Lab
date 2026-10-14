function [movementNumberXData, trialCorrectlySaved]  =  ExtractFromCSV(inputFile)
% NAVEED REZA AGHAMOHAMMADI
% THIS FUNCTION EXTRACTS THE CONTENT OF CSV FILE INTO A STRUCT
    tempBigMatrix=readmatrix(inputFile);

    if (size(tempBigMatrix,1) < 24) % 24 used as a reference number since an empty file still have the header and so 20 rows
        trialCorrectlySaved  =  false;
        movementNumberXData  =  false;
    else
        trialCorrectlySaved  =  true;
    tempBigStringMatrix=readmatrix(inputFile,"OutputType","string");
    selectedLinesIndex=find(~isnan(tempBigMatrix(:,1)));
    selectedLinesIndex=selectedLinesIndex(1:end);
%     Datas
    movementNumberXData.UnityTime       =   tempBigMatrix(selectedLinesIndex,1);
    movementNumberXData.BurtTime        =   tempBigMatrix(selectedLinesIndex,2);
    movementNumberXData.HandPosition    =   tempBigMatrix(selectedLinesIndex,3:5);
    movementNumberXData.CursorPosition  =   tempBigMatrix(selectedLinesIndex,6:8);
    movementNumberXData.Distortion      =   tempBigMatrix(selectedLinesIndex,9:11);
    movementNumberXData.Velocity        =   tempBigMatrix(selectedLinesIndex,12:14);
    movementNumberXData.Acceleration    =   tempBigMatrix(selectedLinesIndex,15:17);
    %movementNumberXData.MovementTime=tempBigMatrix(selectedLinesIndex,3);
    %movementNumberXData.LocalPosition=tempBigMatrix(selectedLinesIndex,7:9);
    % movementNumberXData.GlobalVelocity=tempBigMatrix(selectedLinesIndex,10:12);
    % movementNumberXData.GlobalRobotForce=tempBigMatrix(selectedLinesIndex,13:15);
    % movementNumberXData.TherapyForceAmplitude=tempBigMatrix(selectedLinesIndex,16);
    % movementNumberXData.InFrameTherapy=tempBigMatrix(selectedLinesIndex,17:19);
    % movementNumberXData.ExtentError=tempBigMatrix(selectedLinesIndex,20);
    % movementNumberXData.HorizontalError=tempBigMatrix(selectedLinesIndex,21);
    % movementNumberXData.VerticalError=tempBigMatrix(selectedLinesIndex,22);
    % movementNumberXData.PerpendicularError=tempBigMatrix(selectedLinesIndex,23);
    % movementNumberXData.ErrorProbability=tempBigMatrix(selectedLinesIndex,24);
    % movementNumberXData.MahalanobisDistance=tempBigMatrix(selectedLinesIndex,25);
    % movementNumberXData.GravityGain=tempBigMatrix(selectedLinesIndex,26);
    % movementNumberXData.TrialTime=tempBigMatrix(selectedLinesIndex,27);
    % for counter=1:numel(selectedLinesIndex)
    %     movementNumberXData.DistributionMean{counter,:}=ReadThisValue(tempBigStringMatrix(selectedLinesIndex(counter),28));
    %     movementNumberXData.DistributionCovariance{counter,:}=ReadThisValue(tempBigStringMatrix(selectedLinesIndex(counter),29));
    %     movementNumberXData.OnsetDetected(counter,:)=ReadThisBoolean(tempBigStringMatrix(selectedLinesIndex(counter),30));
    %     movementNumberXData.TherapyWindow(counter,:)=ReadThisBoolean(tempBigStringMatrix(selectedLinesIndex(counter),31));
    % end
%     movementNumberXData.OnsetDetectedIndex=find(movementNumberXData.OnsetDetected==true(1));
%     movementNumberXData.TherapyWindowIndex=find(movementNumberXData.TherapyWindow==true(1));
%     if(size(tempBigMatrix,2)>31)
%         movementNumberXData.DistortionForce=tempBigMatrix(selectedLinesIndex,32:34);
%         movementNumberXData.TotalForce=tempBigMatrix(selectedLinesIndex,35:37);
%         movementNumberXData.PathDistance=tempBigMatrix(selectedLinesIndex,38);
%     end
%     if(size(tempBigMatrix,2)>38)
%         movementNumberXData.DistributionTime=tempBigMatrix(selectedLinesIndex,39);
%         movementNumberXData.MinimumJerkDistance=tempBigMatrix(selectedLinesIndex,40);
%     end
%     if(size(tempBigMatrix,2)>40)
%         movementNumberXData.ARPositionEstimate=tempBigMatrix(selectedLinesIndex,41:43);
%         movementNumberXData.MAPositionEstimate=tempBigMatrix(selectedLinesIndex,46:48);
%         movementNumberXData.HybridEstimatePosition=tempBigMatrix(selectedLinesIndex,50:52);
%         movementNumberXData.ActualPosition=tempBigMatrix(selectedLinesIndex,53:55);
%         movementNumberXData.ARVelocityEstimate=tempBigMatrix(selectedLinesIndex,56:58);
%         movementNumberXData.MAVelocityEstimate=tempBigMatrix(selectedLinesIndex,61:63);
%         movementNumberXData.HybridEstimateVelocity=tempBigMatrix(selectedLinesIndex,65:67);
%         movementNumberXData.ActualVelocity=tempBigMatrix(selectedLinesIndex,68:70);
%         movementNumberXData.EstimationExecutionTime=tempBigMatrix(selectedLinesIndex,71);
%         for counter=1:numel(selectedLinesIndex)
%             movementNumberXData.ARPositionEstimateAbsulteBias{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),44));
%             movementNumberXData.ARPositionEstimateWeights{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),45));
%             movementNumberXData.MAPositionEstimateAbsulteBias{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),49));
%             movementNumberXData.ARVelocityEstimateAbsulteBias{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),59));
%             movementNumberXData.ARVelocityEstimateWeights{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),60));
%             movementNumberXData.MAVelocityEstimateAbsulteBias{counter,:}=ReadThisVector(tempBigStringMatrix(selectedLinesIndex(counter),64));
%         end
%     end
%     if(size(tempBigMatrix,2)>71)
%         movementNumberXData.RobotJointAngles=tempBigMatrix(selectedLinesIndex,72:75);
%         movementNumberXData.RobotJointVelocities=tempBigMatrix(selectedLinesIndex,76:79);
%     end
% %     Header
%     movementNumberXData.SubjectID=ReadThisString(h(1,:));
%     movementNumberXData.Date=ReadThisString(h(2,:));

    % Modificaton April 12th since it doesn't work
    % movementNumberXData.ExperimentMode='2D';
    % switch ReadThisBoolean(h(3,:))
    %     case true
    %         movementNumberXData.ExperimentMode='2D';
    %     case false
    %         movementNumberXData.ExperimentMode='3D';
    % end
    % movementNumberXData.Time=ReadThisString(h(4,:));
    % movementNumberXData.ExperimentPhase=ReadThisString(h(5,:));
    % movementNumberXData.MovementNumber=ReadThisValue(h(6,:));
    % movementNumberXData.MovementDirection=ReadThisValue(h(7,:));
    % movementNumberXData.DistortionFlag=ReadThisDigit(h(8,:));
    % movementNumberXData.RestingMovementFlag=ReadThisBoolean(h(9,:));
    % movementNumberXData.PhaseBeginningTrial=ReadThisBoolean(h(10,:));
    % movementNumberXData.NotReachedTarget=ReadThisBoolean(h(11,:));
    % movementNumberXData.BadMovementFlag=ReadThisBoolean(h(12,:));
    % movementNumberXData.IntermittentExposureFlag=ReadThisBoolean(h(13,:));
    % movementNumberXData.AdaptationCatchTrialFlag=ReadThisBoolean(h(14,:));
    % movementNumberXData.PerformanceInFieldCatchTrailFlag=ReadThisBoolean(h(15,:));
    % movementNumberXData.StartPosition=ReadThisValue(h(16,:));
    % movementNumberXData.TargetPosition=ReadThisValue(h(17,:));
    % movementNumberXData.TargetShiftValue=ReadThisValue(h(18,:));
    % movementNumberXData.TherapyAllowed=ReadThisBoolean(h(19,:));
    % if(size(tempBigMatrix,2)>40)
    %     movementNumberXData.PatientExperiment=ReadThisBoolean(h(20,:));
    %     movementNumberXData.QueueSize=ReadThisValue(h(21,:));
    %     movementNumberXData.ARFilterOrder=ReadThisValue(h(22,:));
    %     movementNumberXData.NoEstimationTrial=ReadThisBoolean(h(23,:));
    % end
    % if(size(tempBigMatrix,2)>71)
    %     movementNumberXData.MAFilterOrder=ReadThisValue(h(24,:));
    % end
    end
end

function output=ReadThisString(inputString)
startIndex=strfind(inputString,',');
startIndex=startIndex(1)+1;
trimmedString=inputString(startIndex:end);
spaceCharecterIndex=find(trimmedString==' ');
trimmedString(spaceCharecterIndex)=[];
commaCharecterIndex=find(trimmedString==',');
trimmedString(commaCharecterIndex)=[];
output=trimmedString;
end

function returnedValue=ReadThisValue(inputString)
index=findstr(',',inputString)+1;
if ~isempty(index)
    str=inputString(index:end);
    if ~isempty(find(str==','))
        commaCharecterIndex=find(str==',');
        str(commaCharecterIndex)=[];
        returnedValue=str2num(str);
    else
        returnedValue=str2num(inputString(index:end));
    end
else
    returnedValue=str2num(inputString);
end
end

function returnedBoolean=ReadThisBoolean(inputString)
index=findstr(':',inputString)+2;
if ~isempty(index)
    returnedString=inputString(index:end);
    switch returnedString(1)
        case 'F'
            returnedBoolean=false(1);
        case 'T'
            returnedBoolean=true(1);
    end
else
    switch inputString(1)
        case 'False'
            returnedBoolean=false(1);
        case 'True'
            returnedBoolean=true(1);
    end
end
end

function output=ReadThisDigit(inputString)
startIndex=strfind(inputString,':');startIndex=startIndex(1)+2;
trimmedString=inputString(startIndex:end);
spaceCharecterIndex=find(trimmedString==' ');
trimmedString(spaceCharecterIndex)=[];
if(trimmedString=='0')
    output=false(1);
else
    output=true(1);
end
end

% function output=ReadThisVector(inputString)
%     startIndex=strfind(inputString,',');
%     startIndex=startIndex(1)+1;
%     output = inputString(:,startIndex+1:end-1);
% end

function output = ReadThisVector(inputString)
% Remove leading and trailing parentheses, if present
startIndex=strfind(inputString,',');
startIndex=startIndex(1)+2;
endIndex=strfind(inputString,')');
inputString = inputString(startIndex:endIndex);

inputString = strrep(inputString, '(', '');  
inputString = strrep(inputString, ')', '');  
output = str2double(strsplit(inputString, ','));
end

