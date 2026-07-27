

function InspectIndividualTrial(trialNumber, unit, resamplingFrequency)

% Description: This function opens a figure and displays detailed information about a specific trial or set of trials from a dataset.
% 
% Arguments:
% 
% trialNumber (int/array): Either a single trial number or an array of trial numbers to inspect.
% unit (str, optional): The unit of measurement for data points in plots (default: "cm"). Valid options include "m", "cm", "N", and "m/s".
% ResamplingFrequency: Reample the parameters, if you don't want to resample leave it blank
% 
% A new figure with multiple subplots displaying various aspects of the chosen trial(s):
% Local frame plot with colored markers representing extent errors and launch trajectory.
% Global frame plot with global positions, start and target points.
% Time series plots for different parameters like speed, extent error, perpendicular error, horizontal error, vertical error, curl force amplitude, therapy force amplitude, and error amplitude.
% Notes:
% 
% The function assumes the existence of a global variable Data containing information for all trials.
% It iterates through the specified trial(s) and extracts relevant data like local positions, velocities, errors, force amplitudes, etc.
% The figure is divided into multiple subplots for efficient visualization of different aspects.
% Each subplot uses helper functions like LocalFramePlot, GlobalFramePlot, and PlotTimeSeries to generate specific visualizations.
% The function dynamically adjusts plot layout based on the number of trial(s) being inspected.
% This function is a powerful tool for in-depth analysis of individual trials and comparing them across different parameters.
%     if ~exist('isIndex'), 

    global Data InterpolatedData
    global fg1
    global PhaseTracking  % Initialize this variable like: PhaseTracking = cell(2,1); PhaseTracking{2,1} = 242 (movement after the first movement of the whole phase you want to rose plot)
    global ErrorFit

    if ~exist('unit'), unit='m'; end
    if ~exist('resamplingFrequency'), resamplingFrequency=0; end

    
    % Set all the figures full screen size
    set(groot, 'defaultFigureUnits', 'normalized');
    set(groot, 'defaultFigurePosition', [0 0 1 1]);

    fg1 = figure(1);
    fg1.WindowState = 'maximized';
    % set(fg1, 'MenuBar', 'none');
    % set(fg1, 'ToolBar', 'none');
    
    plotRows                =   20;
    plotColoumns            =   20;
    launchTimeLength        =   300e-3;
    sampleTime              =   10e-3;
    launchWindowLength      =   launchTimeLength/sampleTime;
    desiredTime             =   0.65;   % Variable used for the Minimum Jerk calcolous
    desiredDistance         =   0.1;    % Variable used for the Minimum Jerk calcolous
    xAxisLimits             =   [0 2];
    movementNumberVector    =   [];
    corruptedIndexes        =   [];

    for trialCounter=1:numel(Data)
        if isfield(Data{trialCounter}, 'MovementNumber')
            movementNumberVector=[movementNumberVector; Data{trialCounter}.MovementNumber];
        end
        if ~[isfield(Data{trialCounter}, 'ExperimentPhase')] || ~[isfield(Data{trialCounter}, 'RestingMovementFlag')]
            corruptedIndexes    =   [corruptedIndexes, trialCounter];
        end
    end
    
    actualTrialNumber  =  [];  % This is going to be the exact index in the Data cell array that contains the movement number desired (which is called TrialNumber in the function's input)
    
    for trialCounter=1:numel(trialNumber)
        actualTrialNumber=[actualTrialNumber; find(trialNumber(trialCounter)==movementNumberVector)];
    end
    
    if any(actualTrialNumber ~= 0) && ~any(ismember(actualTrialNumber(end), corruptedIndexes))
    experimentPhase     =  Data{actualTrialNumber(end)}.ExperimentPhase;
    switch Data{actualTrialNumber(end)}.ExperimentMode
        case '2D'
            experimentMode = '2D';
        case '3D'
            experimentMode = '3D';
    end

    % % Keep track of all movements in that phase and if there is a phase
    % % change it keeps track of it to plot the rose plot of that phase
    % if (~strcmp(Data{actualTrialNumber(trialCounter),1}.ExperimentPhase, Data{actualTrialNumber(trialCounter)-1,1}.ExperimentPhase))
    %     PhaseTracking{1,1}  =  Data{actualTrialNumber(trialCounter),1}.ExperimentPhase;
    %     PhaseTracking{2,1}  =  actualTrialNumber(trialCounter);
    % end



    for experimentPhasePosition = actualTrialNumber : -1 : 1
        if isfield(Data{experimentPhasePosition}, 'ExperimentPhase')
            experimentPhaseCheck = Data{experimentPhasePosition}.ExperimentPhase;
            if ~strcmp(experimentPhaseCheck, experimentPhase)
                PhaseTracking = experimentPhasePosition + 1;
                break;
            end

            if (experimentPhasePosition == 1)
                PhaseTracking = 1;
            end
        end
    end



    
    for trialCounter=1:numel(actualTrialNumber)
            
        errorProbability{trialCounter,:}   =  Data{actualTrialNumber(trialCounter)}.ErrorProbability;
        forceFlag{trialCounter,:}          =  Data{actualTrialNumber(trialCounter)}.ErrorProbability;
        localPosition{trialCounter,:}      =  Data{actualTrialNumber(trialCounter)}.LocalPosition;
        velocity{trialCounter,:}           =  Data{actualTrialNumber(trialCounter)}.GlobalVelocity;
        extentErr{trialCounter,:}          =  Data{actualTrialNumber(trialCounter)}.ExtentError;
        perpErr{trialCounter,:}            =  Data{actualTrialNumber(trialCounter)}.PerpendicularError;
        horzErr{trialCounter,:}            =  Data{actualTrialNumber(trialCounter)}.HorizontalError;
        vertErr{trialCounter,:}            =  Data{actualTrialNumber(trialCounter)}.VerticalError;
        if (isempty(Data{actualTrialNumber(trialCounter)}.OnsetDetectedIndex))
            launchIndex{trialCounter,:}   =  0;
        else
            launchIndex{trialCounter,:}   =  Data{actualTrialNumber(trialCounter)}.TherapyWindowIndex;
            if isempty(Data{actualTrialNumber(trialCounter)}.TherapyWindowIndex)
                launchIndex{trialCounter,:}   =  0;
            end
        end
        movementDirection{trialCounter,:}     =  Data{actualTrialNumber(trialCounter)}.MovementDirection;
        movementNumber{trialCounter,:}        =  Data{actualTrialNumber(trialCounter)}.MovementNumber;
        globalPosition{trialCounter,:}        =  Data{actualTrialNumber(trialCounter)}.GlobalPosition;
        startPosition{trialCounter,:}         =  Data{actualTrialNumber(trialCounter)}.StartPosition;
        targetPosition{trialCounter,:}        =  Data{actualTrialNumber(trialCounter)}.TargetPosition;
        speed{trialCounter,:}                 =  vecnorm((velocity{trialCounter,:})');
        mahalanobisDistance{trialCounter, :}  =  Data{actualTrialNumber(trialCounter)}.MahalanobisDistance;
        
        % Creating a time variable from DeltaTime
        
        time{trialCounter,:}                 =  ConstructTimeFromSampleTime(Data{actualTrialNumber(trialCounter)}.SampleTime); % NAVEED : 
        therapyAmp{trialCounter,:}           =  Data{actualTrialNumber(trialCounter)}.TherapyForceAmplitude;
        inFrameTherapy{trialCounter,:}       =  Data{actualTrialNumber(trialCounter)}.InFrameTherapy;
        allForce{trialCounter,:}             =  Data{actualTrialNumber(trialCounter)}.GlobalRobotForce;
        globalForce{trialCounter,:}          =  vecnorm((allForce{trialCounter,:})');
        curlForce{trialCounter, :}           =  Data{actualTrialNumber(trialCounter)}.DistortionForce;
        pathDistance{trialCounter,:}         =  Data{actualTrialNumber(trialCounter)}.PathDistance;


        realStartPosition{trialCounter,:}    =  Data{actualTrialNumber(trialCounter)}.GlobalPosition(1,:);
        realTargetPosition{trialCounter,:}   =  Data{actualTrialNumber(trialCounter)}.GlobalPosition(end,:);
        mahalanobisDistance{trialCounter,:}  =  Data{actualTrialNumber(trialCounter)}.MahalanobisDistance;
        patientExperiment{trialCounter,:}    =  Data{actualTrialNumber(trialCounter)}.PatientExperiment;
        therapyAllowed{trialCounter,:}       =  Data{actualTrialNumber(trialCounter)}.TherapyAllowed;

        
        % Calculate the MaxPerpendiculaError

        if (trialCounter == numel(actualTrialNumber))
            trialIndexes    =   PhaseTracking:actualTrialNumber(end);
            trialIndexes    =   trialIndexes(~ismember(trialIndexes, corruptedIndexes));
            indexesToPlot   =   trialIndexes;
            % indexesToPlot   =   find(cellfun(@(x) x.RestingMovementFlag == 0, Data(trialIndexes))) + PhaseTracking - 1;
            if strcmp(experimentMode,'2D')
                trialDirection{1,:}  =  find(cellfun(@(x) x.MovementDirection == 0, Data(indexesToPlot, :)));
                trialDirection{2,:}  =  find(cellfun(@(x) x.MovementDirection == 1, Data(indexesToPlot, :)));
                trialDirection{3,:}  =  find(cellfun(@(x) x.MovementDirection == 2, Data(indexesToPlot, :)));
                trialDirection{4,:}  =  find(cellfun(@(x) x.MovementDirection == 3, Data(indexesToPlot, :)));
                trialDirection{5,:}  =  find(cellfun(@(x) x.MovementDirection == 4, Data(indexesToPlot, :)));
                trialDirection{6,:}  =  find(cellfun(@(x) x.MovementDirection == 5, Data(indexesToPlot, :)));
            else
                trialDirection{1,:}  =  find(cellfun(@(x) x.MovementDirection == 0, Data(indexesToPlot, :)));
                trialDirection{2,:}  =  find(cellfun(@(x) x.MovementDirection == 1, Data(indexesToPlot, :)));
                trialDirection{3,:}  =  find(cellfun(@(x) x.MovementDirection == 2, Data(indexesToPlot, :)));
                trialDirection{4,:}  =  find(cellfun(@(x) x.MovementDirection == 3, Data(indexesToPlot, :)));
                trialDirection{5,:}  =  find(cellfun(@(x) x.MovementDirection == 4, Data(indexesToPlot, :)));
                trialDirection{6,:}  =  find(cellfun(@(x) x.MovementDirection == 5, Data(indexesToPlot, :)));
                trialDirection{7,:}  =  find(cellfun(@(x) x.MovementDirection == 6, Data(indexesToPlot, :)));
                trialDirection{8,:}  =  find(cellfun(@(x) x.MovementDirection == 7, Data(indexesToPlot, :)));
            end
            intermittentExposureIndexes             =  find(cellfun(@(x) strcmp(x.ExperimentPhase, 'IntermittentExposurePhase') && x.DistortionFlag == 1, Data(indexesToPlot, :)));
            unpracticedIntermittentExposureIndexes  =  find(cellfun(@(x) strcmp(x.ExperimentPhase, 'UnpracticedIntermittentExposurePhase') && x.DistortionFlag == 1, Data(indexesToPlot, :)));
            performanceInFieldIndexes               =  find(cellfun(@(x) x.PerformanceInFieldCatchTrailFlag == 1, Data(indexesToPlot, :)));
            therapyIndexes                          =  find(cellfun(@(x) x.TherapyAllowed == 1, Data(indexesToPlot, :)));
            testIndexes                             =  find(cellfun(@(x) strcmp(x.ExperimentPhase, 'TestPhase'), Data(indexesToPlot, :)));
            unpracticedTestIndexes                  =  find(cellfun(@(x) strcmp(x.ExperimentPhase, 'UnpracticedTestPhase'), Data(indexesToPlot, :)));
            % maxPerpError        =  [];
            % if (exist('ErrorFit', 'var'))
            %     maxPerpError        =  cellfun(@(x) x.Maximum.Launch.PerpendicularError, Data(indexesToPlot, :));
            %     disp('MaxPerpendicularError obtained from ErrorFit');
            % else

            nullTherapyWindowsIndexes = find(cellfun(@(x) length(x.TherapyWindowIndex) < 1, Data(indexesToPlot, :)));
            % filteredIndexes = setdiff(indexesToPlot, nullTherapyWindowsIndexes);
            tempMaxPerpError  =  cellfun(@(x) x.PerpendicularError(x.TherapyWindowIndex), Data(indexesToPlot, :), 'UniformOutput', false);
            maxPerpError      =  cellfun(@max, tempMaxPerpError, 'UniformOutput', false);
            % if (nullTherapyWindowsIndexes ~= 0)
            %     maxPerpError{nullTherapyWindowsIndexes} = 0;
            % end
            disp('MaxPerpendicularError obtained from TherapyWindowIndex');

                % end
            % maxPerpError = [];
            % for perpErrorCount = PhaseTracking:actualTrialNumber(end)
            %     if (Data{perpErrorCount}.RestingMovementFlag == 0 & Data{perpErrorCount}.PhaseBeginningTrial == 0)
            %         maxPerpError(1,:) = [maxPerpError(1,:), Data{perpErrorCount}.Maximum.Launch.PerpendicularError];
            %         maxPerpError(2,:) =
            %     end
            % end
        end

        %--->   to be deleted
        %         errorAmp{counter,:}=Data{actualTrialNumber(counter)}.ErrorAmplitude;
        %<---   to be deleted

        rotationMatrix                     =  GetUnityToLocalRotationMatrix(movementDirection{trialCounter,:}, '3D');
%       rotationMatrix                     =  GetUnityToLocalRotationMatrix(movementDirection{trialCounter,:},'2D');
        globalTherapy{trialCounter,:}      =  ((rotationMatrix')*(inFrameTherapy{trialCounter,:})')';
        % curlForce{trialCounter,:}          =  ((allForce{trialCounter,:})'-(rotationMatrix')*((inFrameTherapy{trialCounter,:})'))';
        curlForceAmp{trialCounter,:}       =  vecnorm((curlForce{trialCounter,:})');


        % For loop to find the highest and lower value of the position error and forces to then plot all the three Y axis accordingly

        maxErr    =  max([max(horzErr{trialCounter, :}), max(vertErr{trialCounter, :}), max(perpErr{trialCounter, :})]);
        minErr    =  min([min(horzErr{trialCounter, :}), min(vertErr{trialCounter, :}), max(perpErr{trialCounter, :})]);

        maxForce  =  max([max(globalForce{trialCounter, :}), max(therapyAmp{trialCounter, :}), max(curlForceAmp{trialCounter, :})]);
        minForce  =  min([min(globalForce{trialCounter, :}), min(therapyAmp{trialCounter, :}), max(curlForceAmp{trialCounter, :})]);

        maxSpeed  =  max([max(speed{trialCounter,:}), max(abs(velocity{trialCounter,:}(:,1))), max(abs(velocity{trialCounter,:}(:,2))), max(abs(velocity{trialCounter,:}(:,3)))]);
        if (maxSpeed < 0.5138)  % if the speed is lower than the higher threshold (0.5138)
            maxSpeed = 0.6;
        end
        minSpeed  =  min([min(speed{trialCounter,:}), min(abs(velocity{trialCounter,:}(:,1))), min(abs(velocity{trialCounter,:}(:,2))), min(abs(velocity{trialCounter,:}(:,3)))]);




       if (size(trialNumber, 2) == trialCounter)
        
        %       Plot of the 2nd big image on the left
        if (~isempty(Data{actualTrialNumber(trialCounter)}.OnsetDetectedIndex))
            ind=[];
            for i=floor(plotRows/2)+1:plotRows
                for j=1:floor(plotColoumns/2)
                    ind=[ind,plotRows*(i-1)+j];
                end
            end
            ax_15      =  subplot(plotRows,plotColoumns,ind);hold on;
            GlobalFramePlot(ax_15,globalPosition{trialCounter,:},realStartPosition{trialCounter,:},targetPosition{trialCounter,:},launchIndex{trialCounter,:},actualTrialNumber(trialCounter),allForce{trialCounter,:},unit,globalTherapy{trialCounter,:},time{trialCounter,:}, resamplingFrequency)  % Change inFrameTherapy with globalTherapy
            hold on;
            if (size(trialNumber, 2) > 1)
                GlobalFramePlot(ax_15,globalPosition{trialCounter-1,:},realStartPosition{trialCounter-1,:},targetPosition{trialCounter-1,:},launchIndex{trialCounter-1,:},actualTrialNumber(trialCounter),allForce{trialCounter-1,:},unit,globalTherapy{trialCounter-1,:},time{trialCounter-1,:}, resamplingFrequency) % Change inFrameTherapy with globalTherapy
            end
            if (size(trialNumber, 2) > 2)
                hold on;
                GlobalFramePlot(ax_15,globalPosition{trialCounter-2,:},realStartPosition{trialCounter-2,:},targetPosition{trialCounter-2,:},launchIndex{trialCounter-2,:},actualTrialNumber(trialCounter),allForce{trialCounter-2,:},unit,globalTherapy{trialCounter-2,:},time{trialCounter-2,:}, resamplingFrequency) % Change inFrameTherapy with globalTherapy
            end
            tempHorizontalAdjustValue = -0.08;
        tempVerticalAdjustValue   = - 0.05;
        pos =  get(ax_15, 'Position');posnew =  pos;posnew(1) =  posnew(1) + tempHorizontalAdjustValue;posnew(2) =  posnew(2) + tempVerticalAdjustValue;
        set(ax_15, 'Position', posnew);
        end
        grid off;
        axis off;



        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIRST COLUMN PLOT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Calcolous of the first column
        ind=[];i=1;for j=5*plotColoumns/10:7*plotColoumns/10, ind=[ind,plotRows*(i-1)+j]; end
        ax_1=subplot(plotRows/4,plotColoumns,ind);
        hold on;

        

        % Plot of the Minumum Jerk traslated in the right position (aligned with the peak of the recorded speed) and of the speed profile
        ind_time  =  find(time{trialCounter,:} >= 0 & time{trialCounter,:} < 0.650);
        time_mj   =  time{trialCounter,:}(ind_time);
        [mj_position, mj_velocity]  =  MinimumJerkTrajectory(desiredTime, desiredDistance, time_mj);
        deltaTime1  =  find(max(speed{trialCounter,:}) == (speed{trialCounter,:}));     % Creation of a variable to store the difference in time between the two curves and traslate one of them
        deltaTime1  =  time{trialCounter,:}(deltaTime1) - time{trialCounter,:}(ind_time(1));
        % deltaTime1  =  deltaTime1 - time(launchIndex{trialCounter,:}(1));
        deltaTime2  =  find(max(mj_velocity) == mj_velocity);
        deltaTime2  =  time_mj(deltaTime2);
        if (length(deltaTime1)>1)
            deltaTime1 = deltaTime1(1);
        end
        deltaTime   =  deltaTime1 - deltaTime2;
        time_mj     =  time_mj + deltaTime;
        if ~launchIndex{trialCounter,:} == 0
            deltaTime1  =  time{trialCounter,:}(launchIndex{trialCounter,:});
        else
            deltaTime1 = time{trialCounter,:}(1);
        end
        % Calculate the resampled time vector for Minimum Jerk
        % mj_time = time_mj - deltaTime1(1:length(time_mj));
        mj_time = time_mj - deltaTime1(1);
        mj_velocityR = interp1(mj_time, mj_velocity, (mj_time(1):0.01:mj_time(end)));
        deltaTime1  =  deltaTime1(1);
        % resample the Minimum Jerk values at 100Hz
        mj_time         =  time_mj - deltaTime1;
        mj_velocityR    =  interp1(mj_time, mj_velocity, (mj_time(1):0.01:mj_time(end)));
        cla(ax_1);
        PlotTimeSeries(ax_1, experimentMode, mj_velocityR, [mj_time(1):0.01:mj_time(end)], 'minimumJerk', 0,movementDirection{trialCounter,:}, movementNumber{trialCounter,:},'m/s');
        PlotTimeSeries(ax_1, experimentMode, speed{trialCounter,:},time{trialCounter,:},'speed',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'m/s', minSpeed, maxSpeed)
        tempVerticalAdjustValue   = 0;
        tempHorizontalAdjustValue = 0; 
        pos =  get(ax_1, 'Position');posnew =  pos; posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_1, 'Position', posnew);
        
       
        
        ind=[];i=2;for j=5*plotColoumns/10:7*plotColoumns/10, ind=[ind,plotRows*(i-1)+j]; end
        ax_2=subplot(plotRows/4,plotColoumns,ind);hold on;
        cla(ax_2);
        % PlotTimeSeries(ax_2, experimentMode, globalForce{trialCounter,:},time{trialCounter,:},'Global',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'N',minForce,maxForce)
        PlotTimeSeries(ax_2, experimentMode, mahalanobisDistance{trialCounter,:},time{trialCounter,:},'MahalanobisDistance',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'N')
        tempVerticalAdjustValue   = 0; 
        tempHorizontalAdjustValue = 0;
        pos =  get(ax_2, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_2, 'Position', posnew);



        ind=[];i=3;for j=5*plotColoumns/10:7*plotColoumns/10, ind=[ind,plotRows*(i-1)+j]; end
        ax_3=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_3,experimentMode,curlForceAmp{trialCounter,:},time{trialCounter,:},'Curl',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'N',minForce,maxForce)
        tempVerticalAdjustValue   = 0;
        tempHorizontalAdjustValue = 0;
        pos =  get(ax_3, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_3, 'Position', posnew);



        ind=[];i=4;for j=5*plotColoumns/10:7*plotColoumns/10, ind=[ind,plotRows*(i-1)+j]; end
        ax_4=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_4,experimentMode,therapyAmp{trialCounter,:},pathDistance{trialCounter,:},'Therapy',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'N',minForce,maxForce)
        tempVerticalAdjustValue   = 0;
        tempHorizontalAdjustValue = 0;
        pos =  get(ax_4, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_4, 'Position', posnew);



        ind=[];i=5;for j=5*plotColoumns/10:7*plotColoumns/10, ind=[ind,plotRows*(i-1)+j]; end
        ax_5=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_5,experimentMode,errorProbability{trialCounter,:},pathDistance{trialCounter,:},'ErrorProbability',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'nan');
        tempVerticalAdjustValue   = 0;
        tempHorizontalAdjustValue = 0;
        pos =  get(ax_5, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_5, 'Position', posnew);




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  SECOND COLUMN PLOT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        ind=[];i=1;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_10=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_10,experimentMode,abs(velocity{trialCounter, :}(:,1)),time{trialCounter,:},'velocity',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'m/s', minSpeed, maxSpeed)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_10, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_10, 'Position', posnew);


        ind=[];i=1;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_13=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_13,experimentMode,abs(velocity{trialCounter, :}(:,2)),time{trialCounter,:},'velocity',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'m/s', minSpeed, maxSpeed)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_11, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_11, 'Position', posnew);


        ind=[];i=1;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_12=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_12,experimentMode,abs(velocity{trialCounter, :}(:,3)),time{trialCounter,:},'velocity',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},'m/s', minSpeed, maxSpeed)
        tempVerticalAdjustValue = 0;
        tempHorizontalAdjustValue = 0.03;
        pos =  get(ax_12, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_12, 'Position', posnew);



        ind=[];i=2;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_9=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_9,experimentMode,globalPosition{trialCounter,:}(:,1),time{trialCounter,:},'Position',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_9, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_9, 'Position', posnew);


        ind=[];i=2;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_15=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_15,experimentMode,globalPosition{trialCounter,1}(:,2),time{trialCounter,:},'Position',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_15, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_15, 'Position', posnew);


        ind=[];i=2;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_16=subplot(plotRows/4,plotColoumns,ind);hold on;
        PlotTimeSeries(ax_16,experimentMode,globalPosition{trialCounter,1}(:,3),time{trialCounter,:},'Position',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        tempVerticalAdjustValue = 0;
        tempHorizontalAdjustValue = 0.03;
        pos =  get(ax_16, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_16, 'Position', posnew);



        ind=[];i=3;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_10=subplot(plotRows/4,plotColoumns,ind);hold on;
        %         PlotTimeSeries(ax_6,extentErr{trialCounter,:},time{trialCounter,:},'extent',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        PlotTimeSeries(ax_10,experimentMode,extentErr{trialCounter,:},pathDistance{trialCounter,:},'Combined Errors',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_6, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_6, 'Position', posnew);



        ind=[];i=3;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_13=subplot(plotRows/4,plotColoumns,ind);hold on;
        %         PlotTimeSeries(ax_7,horzErr{trialCounter,:},time{trialCounter,:},'horizontal',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit,minErr,maxErr)
        PlotTimeSeries(ax_13,experimentMode,horzErr{trialCounter,:},pathDistance{trialCounter,:},'Combined Errors',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        % tempVerticalAdjustValue = 0;
        % tempHorizontalAdjustValue = 0.03;
        % pos =  get(ax_6, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        % set(ax_6, 'Position', posnew);




        ind=[];i=3;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ax_12=subplot(plotRows/4,plotColoumns,ind);hold on;
        %         PlotTimeSeries(ax_8,vertErr{trialCounter,:},time{trialCounter,:},'vertical',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit,minErr,maxErr)
        PlotTimeSeries(ax_12,experimentMode,vertErr{trialCounter,:},pathDistance{trialCounter,:},'Combined Errors',launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit)
        tempVerticalAdjustValue = 0;
        tempHorizontalAdjustValue = 0.03;
        pos =  get(ax_12, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_12, 'Position', posnew);


        ind=[];i=4;for j=3*plotColoumns/4:plotColoumns, ind=[ind,plotRows*(i-1)+j]; end
        ind_ext=[];i=5;for j=3*plotColoumns/4:plotColoumns, ind_ext=[ind_ext,plotRows*(i-1)+j]; end
        ax_17=subplot(plotRows/4,plotColoumns,[ind ind_ext]);hold on;
        % PracticedColor=EquiDistantColorGenerator(4,0.84913);
        PracticedColor=EquiDistantColorGenerator(4,9742);
        UnpracticedColor=ones(size(PracticedColor))-PracticedColor;
%         UnpracticedColor=[1 0 0;0 0 1;0 1 0;1 0 1];
        % UnpracticedColor=[0.2 0.4 0.1; 0.4 0.1 0.4; 0.8 0.3 0.1; 0 0 1];
        if strcmp(experimentMode, '2D')
            C=[PracticedColor(1:3,:);UnpracticedColor(1:3,:)];
        else
            C=[PracticedColor;UnpracticedColor];
        end
        PlotMaxLaunchPerpError(ax_17, maxPerpError, trialDirection, unpracticedIntermittentExposureIndexes, intermittentExposureIndexes, performanceInFieldIndexes, therapyIndexes, testIndexes, unpracticedTestIndexes, patientExperiment{trialCounter,:}, therapyAllowed{trialCounter,:}, C, 'm');
        tempVerticalAdjustValue = 0;
        tempHorizontalAdjustValue = 0.03;
        pos =  get(ax_17, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_17, 'Position', posnew);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Plot of the 1st big image onthe left    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        ind=[];
        for i=1:floor(plotRows/2)
            for j=1:floor(plotColoumns/2-1)
                ind=[ind,plotRows*(i-1)+j];
            end
        end

        ax_14=subplot(plotRows,plotColoumns,ind);hold on;
        tempHorizontalAdjustValue = -0.08;
        pos =  get(ax_14, 'Position');posnew =  pos;posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_14, 'Position', posnew);



        % Robotic Simulation --->
        % RoboticSimulation(ax_14, time{trialCounter,:}, globalPosition{trialCounter,:}, experimentPhase, actualTrialNumber(trialCounter))
        % rotate3d off
        % <---

        % Rose Plot --->
        RosePlot(ax_14, experimentPhase, actualTrialNumber(end), movementDirection{trialCounter, :},  unit, trialIndexes, Data, trialDirection, maxPerpError, indexesToPlot, experimentMode) % correct number is actualTrialNumber(trialCounter)
        % <---

        % Trajectory-dot plot ---->
        % LocalFramePlot(ax_14,localPosition{trialCounter,:},extentErr{trialCounter,:},velocity{trialCounter,:},launchIndex{trialCounter,:},movementDirection{trialCounter,:},movementNumber{trialCounter,:},unit, 0, experimentPhase)
        % <----


        % Plot of the direction rose
        ind=[];
        for i=floor(plotRows/2)-1:floor(plotRows/2)+1
            for j=floor(plotColoumns/2)-2:floor(plotColoumns/2)-1
                ind=[ind,plotRows*(i-1)+j];
            end
        end
        % PracticedColor=EquiDistantColorGenerator(4,0.84913);
        PracticedColor=EquiDistantColorGenerator(4,9742);
        UnpracticedColor=ones(size(PracticedColor))-PracticedColor;
        % UnpracticedColor=[1 0 0;0 0 1;0 1 0;1 0 1];
        % UnpracticedColor=[0.2 0.4 0.1; 0.4 0.1 0.4; 0.8 0.3 0.1; 0 0 1];
        ax_20=subplot(plotRows,plotColoumns,ind);hold on;
        if strcmp(experimentMode, '2D')
            C=[PracticedColor(1:3,:);UnpracticedColor(1:3,:)];
            PlotDirectionGuide2D(ax_20,[0:5]',C, 6);
        else
            C=[PracticedColor;UnpracticedColor];
            PlotDirectionGuide2D(ax_20,[0:7]',C, 8);
        end
        tempVerticalAdjustValue = 0;
        tempHorizontalAdjustValue = -0.05;
        pos =  get(ax_20, 'Position');posnew =  pos;posnew(2) =  posnew(2) + tempVerticalAdjustValue; posnew(1) =  posnew(1) + tempHorizontalAdjustValue;
        set(ax_20, 'Position', posnew);
        % pos1 =  get(ax_17, 'Position');
        % copyobj(get(gca(pos),'Children'), gca(fg1));
        % set(gca(pos),'Children',fg1);


        end
    end

    end
    
end



function PlotTimeSeries(axObject,experimentMode,value,time,type,launchIndex,movementDirection,movementNumber,unit,Ymin,Ymax)
% Description: This function generates a time series plot of various movement parameters for a specific trial and direction.
% 
% Arguments:
% 
% axObject (axes): The axes object where the time series will be drawn.
% value (ndarray, Nx1): A vector containing the data points for the chosen parameter (e.g., extent error, speed).
% time (ndarray, Nx1): A vector of corresponding timestamps for each data point.
% type (str): The type of parameter being plotted. Options include:
% 'extent': Extent error
% 'perpendicular': Perpendicular error
% 'horizontal': Horizontal error
% 'Vertical': Vertical error
% 'Curl': Curl force amplitude
% 'Therapy': Therapy force amplitude
% 'speed': Speed
% 'errAmp': Error amplitude
% launchIndex (int): The index of the data point representing the launch (onset) position.
% movementDirection (int): An integer between 1 and 8 representing the movement direction (e.g., 1 for forward).
% movementNumber (int): The trial number or identifier for this specific movement.
% unit (str): The unit of measurement for the data points (e.g., "m", "cm", "N", or "m/s").
% Outputs:
% 
% A time series plot within the provided axes object, showing:
% Data points for the chosen parameter plotted over time.
% Colored markers for launch and non-launch points (distinguishable by color).
% Axis labels with title and unit information.
% Title including movement direction, trial number, and parameter type.
% Notes:
% 
% The function defines several constants like fsz, mkz, and mkz2 for text size and marker size. You can adjust these values for better visual clarity.
% The time data is shifted to start at the launch point (time = 0) for easier interpretation of the plot.
% Different color palettes are used for practiced and unpracticed movements (configurable through PracticedColor and UnpracticedColor).
% The function adjusts the axis labels and title based on the chosen type and movementDirection parameters.
% This function is useful for analyzing the temporal evolution of various movement parameters for specific trials and directions.
    fsz=16;
    mkz=16;
    mkz2=12;
    if (launchIndex ~= 0)
    time=time-time(launchIndex(1));
    end
    % PracticedColor=EquiDistantColorGenerator(4,0.84913);
    PracticedColor=EquiDistantColorGenerator(4,9742);
    UnpracticedColor=ones(size(PracticedColor))-PracticedColor;
    % UnpracticedColor=[1 0 0;0 0 1;0 1 0;1 0 1];
    % UnpracticedColor=[0.2 0.4 0.1; 0.4 0.1 0.4; 0.8 0.3 0.1; 0 0 1];
    if strcmp(experimentMode,'2D')==true, C=[PracticedColor(1:3,:);UnpracticedColor(1:3,:)]; else, C=[PracticedColor;UnpracticedColor]; end
    switch type
        case 'extent'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Extent Error";
            xlabelString="Path (m)";
        case 'Combined Errors'
            plotSpeed=false(1);
            plotForce=false(1);
            legend1='Ext';
            legend2='Horiz';
            legend3='Vert';
            titleString="Position Errors";
            xlabelString="Path (m)";
        case 'horizontal'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Horizontal Error";
            xlabelString="Path (m)";
        case 'vertical'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Vertical Error";
            xlabelString="Path (m)";
        case 'Curl'
            plotSpeed=false(1);
            plotForce=true(1);
            titleString="Curl Force";
            axisColor=[0.4940 0.1840 0.5560];
            xlabelString="Time (s)";
        case 'Therapy'
            plotSpeed=false(1);
            plotForce=true(1);
            titleString="Therapy Force";
            axisColor=[0.4940 0.1840 0.5560];
            xlabelString="Path (m)";
        case 'speed'
            plotSpeed=true(1);
            plotForce=false(1);
            titleString="Speed";
            axisColor=[0 0.4470 0.7410];
            xlabelString="Time (s)";
        case 'velocity'
            plotSpeed=false(1);
            plotForce=false(1);
            legend1='Vel X';
            legend2='Vel Y';
            legend3='Vel Z';
            titleString="Velocity";
            axisColor=[0 0.4470 0.7410];
            xlabelString="Time (s)";
        case 'errAmp'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Error Magnitude";
            xlabelString="Time (s)";
        case 'Global'
            plotSpeed=false(1);
            plotForce=true(1);
            titleString="Total Force";
            axisColor=[0.4940 0.1840 0.5560];
            xlabelString="Time (s)";
        case 'ErrorProbability'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Error Probability";
            xlabelString="Path (m)";
        case 'minimumJerk'
            plotSpeed = true(1);
            plotForce = false(1);
            titleString = "Speed";
            xlabelString="Time (s)";
        case 'MahalanobisDistance'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Mahalanobis Distance";
            xlabelString="Path (m)";
        case 'PathDistance'
            plotSpeed=false(1);
            plotForce=false(1);
            titleString="Path Distance";
            xlabelString="Time (s)";
        case 'Position'
            plotSpeed=false(1);
            plotForce=false(1);
            legend1='Pos X';
            legend2='Pos Y';
            legend3='Pos Z';
            titleString="Position";
            xlabelString="Time (s)";
    end

    switch movementDirection
        case 1-1
            tempColor=C(1,:);
        case 2-1
            tempColor=C(2,:);
        case 3-1
            tempColor=C(3,:);
        case 4-1
            tempColor=C(4,:);
        case 5-1
            tempColor=C(5,:);
        case 6-1
            tempColor=C(6,:);
        case 7-1
            tempColor=C(7,:);
        case 8-1
            tempColor=C(8,:);
    end
    
    switch unit
        case 'm'
            displayUnitGain=1;
            unitString=" (m)";
        case 'cm'
            displayUnitGain=100;
            unitString=" (cm)";
        case 'N'
            displayUnitGain=1;
            unitString=" (N)";
        case 'm/s'
            displayUnitGain=1;
            unitString=" (m/s)";
        case 'nan'
            displayUnitGain=1;
            unitString="";
    end
    if (strcmp(type,'minimumJerk'))
        plot(axObject,time(1:numel(value)),displayUnitGain*value(1:numel(value)),'.','Color',[0.6350  0.0780  0.1840],'MarkerSize',mkz);  % Red color = [0.6350  0.0780  0.1840]
        hold on;
    else
        if (strcmp(type, 'Combined Errors') | strcmp(type, 'velocity') | strcmp(type, 'Position'))
            plot(axObject,time(1:numel(value)),displayUnitGain*value(1:numel(value)),'.-','MarkerSize',mkz);
            L = legend(legend1, '', legend2, '', legend3);
            L.AutoUpdate = 'off';
        else
            plot(axObject,time(1:numel(value)),displayUnitGain*value(1:numel(value)),'.-','Color',tempColor,'MarkerSize',mkz);
        end
        % hold on;
    end
    if (launchIndex ~= 0)
        plot(axObject,time(launchIndex),displayUnitGain*value(launchIndex),'.-','Color','k','MarkerSize',mkz);
    end
    
    xlim([time(1), time(end)]);

    % Only if you give Y axis extremis you get inside this
    if  (exist("Ymin") && exist("Ymax"))
        if (Ymax > Ymin)
            ylim([displayUnitGain*Ymin, displayUnitGain*Ymax]);
        end
    end
    

    Ylm=ylim;
    Xlm=xlim;

    if plotSpeed==true(1)
        if strcmp(experimentMode,'2D')==true
            lowSpeedThreshold=0.2766; % Healthy
            highSpeedThreshold=0.4348; % Healthy
        else
            lowSpeedThreshold=0.1976; % Patientt
            highSpeedThreshold=0.5138; % Patient
        end
        % lowSpeedThreshold=0.1976;
        % highSpeedThreshold=0.5138;
        yl1  =  yline(lowSpeedThreshold, '--', 'Min Threshold', 'FontSize',fsz-7);
        yl1.LabelVerticalAlignment = 'middle';
        yl2  =  yline(highSpeedThreshold, '--', 'Max Threshold', 'FontSize',fsz-7);
        yl2.LabelVerticalAlignment = 'middle';
    end

    if  (exist("Ymin") && exist("Ymax"))
        set(gca, 'linewidth', 2, 'YColor', axisColor);
    end

    set(gca, 'linewidth', 2);
    ylabel(titleString+unitString,'FontSize',fsz-5, 'FontWeight', 'bold', 'Color','k');
    ytickangle(90);
    xlabel(xlabelString,'FontSize',fsz-5, 'FontWeight', 'bold', 'Position',[Xlm(2) Ylm(1)]);
    title(titleString,'FontSize',fsz-3);
end



function PlotMaxLaunchPerpError(axObject, value, dirIndexes, unpracticedIntermittentExposureIndexes, intermittentExposureIndexes, performanceInFieldIndexes, therapyIndexes, testIndexes, unpracticedTestIndexes, patientExperiment, therapyAllowed, C, unit)


mkz=8;
mkz_s=14;
mkz_c=12;
lsz=1.5;
fsz=20;


if ~exist('unit')
    unit = 'm';
end


titleString="Max Perpendicular Error";

switch unit
    case 'm'
        displayUnitGain=1;
        unitString=" (m)";
        xlabelString="Trial";
    case 'cm'
        displayUnitGain=100;
        unitString=" (cm)";
        xlabelString="Trial";
end



% Specific shapes plot

if (~isempty(unpracticedIntermittentExposureIndexes))
    if (length(dirIndexes)<=6)
        plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(4,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(5,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(6,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
    else
        plot(axObject, dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(5,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(6,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{7,1}(find(ismember(dirIndexes{7,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{7,1}(find(ismember(dirIndexes{7,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(7,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{8,1}(find(ismember(dirIndexes{8,1}, unpracticedIntermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{8,1}(find(ismember(dirIndexes{8,1}, unpracticedIntermittentExposureIndexes))))),'o','Color',C(8,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
    end
plot(nan, nan, 'o','Color','k','MarkerSize',mkz_c,'LineWidth',lsz, 'DisplayName', 'Curl Force');
hold on;
legend('show', 'Location','northeast');
end

if (~isempty(intermittentExposureIndexes))
    plot(axObject, dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, intermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, intermittentExposureIndexes))))),'o','Color',C(1,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
    plot(axObject, dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, intermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, intermittentExposureIndexes))))),'o','Color',C(2,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
    plot(axObject, dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, intermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, intermittentExposureIndexes))))),'o','Color',C(3,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
    if (length(dirIndexes) > 6)
        plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, intermittentExposureIndexes))), displayUnitGain*cell2mat(value(dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, intermittentExposureIndexes))))),'o','Color',C(4,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
    end

plot(nan, nan, 'o','Color','k','MarkerSize',mkz_c,'LineWidth',lsz, 'DisplayName', 'Curl Force');
hold on;
legend('show', 'Location','northeast');
end

if (~isempty(therapyIndexes) && therapyAllowed == 0)
% plot(axObject, dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, therapyIndexes))), displayUnitGain*value(dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, therapyIndexes)))),'o','Color',C(1,:),'MarkerSize',mkz_c,'LineWidth',lsz);
% hold on;
% plot(axObject, dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, therapyIndexes))), displayUnitGain*value(dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, therapyIndexes)))),'o','Color',C(2,:),'MarkerSize',mkz_c,'LineWidth',lsz);
% hold on;
% plot(axObject, dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, therapyIndexes))), displayUnitGain*value(dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, therapyIndexes)))),'o','Color',C(3,:),'MarkerSize',mkz_c,'LineWidth',lsz);
% hold on;
if ~isempty([value{dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, therapyIndexes)))}])
    plot(axObject, dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, therapyIndexes))), displayUnitGain*[value{dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, therapyIndexes)))}],'s','MarkerEdgeColor',C(1,:),'MarkerSize',mkz_s,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
if ~isempty([value{dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, therapyIndexes)))}])
    plot(axObject, dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, therapyIndexes))), displayUnitGain*[value{dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, therapyIndexes)))}],'s','MarkerEdgeColor',C(2,:),'MarkerSize',mkz_s,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
if ~isempty([value{dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, therapyIndexes)))}])
    plot(axObject, dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, therapyIndexes))), displayUnitGain*[value{dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, therapyIndexes)))}],'s','MarkerEdgeColor',C(3,:),'MarkerSize',mkz_s,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
if length(dirIndexes) > 6 && ~isempty([value{dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, therapyIndexes)))}])
    plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, therapyIndexes))), displayUnitGain*[value{dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, therapyIndexes)))}],'s','MarkerEdgeColor',C(4,:),'MarkerSize',mkz_s,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
plot(nan, nan, 'o','MarkerEdgeColor','k','MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(nan, nan, 's','MarkerEdgeColor','k','MarkerSize',mkz_s,'LineWidth',lsz, 'DisplayName', 'Therapy + Curl');
legend('show', 'Location','northeast');
% if ~isempty(ErrorFit.MaximumPerpendicularError.DirectionZero)
%     tempIndex0 = find(ismember(ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers - ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers(1), dirIndexes{1,1}));
%     tempIndex0 = tempIndex0(end);
%     AddExponentialFit(axObject,ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers(1:tempIndex0) - ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.MovementNumbers(1),ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Fitness,ErrorFit.MaximumPerpendicularError.DirectionZero.Launch.Ensemble,C(2,:),C(2,:))
% end
end

if (~isempty(performanceInFieldIndexes))
plot(axObject, dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, performanceInFieldIndexes))), displayUnitGain*cell2mat(value(dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, performanceInFieldIndexes))))),'o','Color',C(1,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, performanceInFieldIndexes))), displayUnitGain*cell2mat(value(dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, performanceInFieldIndexes))))),'o','Color',C(2,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, performanceInFieldIndexes))), displayUnitGain*cell2mat(value(dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, performanceInFieldIndexes))))),'o','Color',C(3,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
if (length(dirIndexes) > 6)
    plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, performanceInFieldIndexes))), displayUnitGain*cell2mat(value(dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, performanceInFieldIndexes))))),'o','Color',C(4,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
plot(nan, nan, 'o','Color','k','MarkerSize',mkz_c,'LineWidth',lsz, 'DisplayName', 'Curl Force');
hold on;
legend('show', 'Location','northeast');
end

if (~isempty(testIndexes))
plot(axObject, dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, testIndexes))), displayUnitGain*cell2mat(value(dirIndexes{1,1}(find(ismember(dirIndexes{1,1}, testIndexes))))),'o','Color',C(1,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, testIndexes))), displayUnitGain*cell2mat(value(dirIndexes{2,1}(find(ismember(dirIndexes{2,1}, testIndexes))))),'o','Color',C(2,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, testIndexes))), displayUnitGain*cell2mat(value(dirIndexes{3,1}(find(ismember(dirIndexes{3,1}, testIndexes))))),'o','Color',C(3,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
hold on;
if (length(dirIndexes) > 6)
    plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, testIndexes))), displayUnitGain*cell2mat(value(dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, testIndexes))))),'o','Color',C(4,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
    hold on;
end
plot(nan, nan, 'o','Color','k','MarkerSize',mkz_c,'LineWidth',lsz, 'DisplayName', 'Curl Force');
hold on;
legend('show', 'Location','northeast');
end

if (~isempty(unpracticedTestIndexes))
    if (length(dirIndexes) < 6)
        plot(axObject, dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{4,1}(find(ismember(dirIndexes{4,1}, unpracticedTestIndexes))))),'o','Color',C(4,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedTestIndexes))))),'o','Color',C(5,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedTestIndexes))))),'o','Color',C(6,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
    else
        plot(axObject, dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{5,1}(find(ismember(dirIndexes{5,1}, unpracticedTestIndexes))))),'o','Color',C(5,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{6,1}(find(ismember(dirIndexes{6,1}, unpracticedTestIndexes))))),'o','Color',C(6,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{7,1}(find(ismember(dirIndexes{7,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{7,1}(find(ismember(dirIndexes{7,1}, unpracticedTestIndexes))))),'o','Color',C(7,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
        plot(axObject, dirIndexes{8,1}(find(ismember(dirIndexes{8,1}, unpracticedTestIndexes))), displayUnitGain*cell2mat(value(dirIndexes{8,1}(find(ismember(dirIndexes{8,1}, unpracticedTestIndexes))))),'o','Color',C(8,:),'MarkerSize',mkz_c,'LineWidth',lsz, 'HandleVisibility', 'off');
        hold on;
    end
plot(nan, nan, 'o','Color','k','MarkerSize',mkz_c,'LineWidth',lsz, 'DisplayName', 'Curl Force');
hold on;
legend('show', 'Location','northeast');
end


% Normal dot plot
% if (length(dirIndexes{1,1}) > length([value{dirIndexes{1,1}}]))
%     dirIndexes{1,1} = dirIndexes{1,1}(1:end-(length(dirIndexes{1,1})-length([value{dirIndexes{1,1}}])));
% end
% dirIndexes{4,1}
% value
% displayUnitGain*[value{dirIndexes{4,1}}]
value(cellfun(@isempty,value)) = {0};
plot(axObject, dirIndexes{1,1}, displayUnitGain*[value{dirIndexes{1,1}}],'o','MarkerFaceColor',C(1,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{2,1}, displayUnitGain*[value{dirIndexes{2,1}}],'o','MarkerFaceColor',C(2,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{3,1}, displayUnitGain*[value{dirIndexes{3,1}}],'o','MarkerFaceColor',C(3,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{4,1}, displayUnitGain*[value{dirIndexes{4,1}}],'o','MarkerFaceColor',C(4,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{5,1}, displayUnitGain*[value{dirIndexes{5,1}}],'o','MarkerFaceColor',C(5,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{6,1}, displayUnitGain*[value{dirIndexes{6,1}}],'o','MarkerFaceColor',C(6,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');

if (length(dirIndexes) > 6)
hold on;
plot(axObject, dirIndexes{7,1}, displayUnitGain*[value{dirIndexes{7,1}}],'o','MarkerFaceColor',C(7,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
hold on;
plot(axObject, dirIndexes{8,1}, displayUnitGain*[value{dirIndexes{8,1}}],'o','MarkerFaceColor',C(8,:),'MarkerEdgeColor',[1,1,1],'MarkerSize',mkz, 'HandleVisibility', 'off');
end


set(gca, 'linewidth', 2);
ylabel(titleString+unitString,'FontSize',fsz-5, 'FontWeight', 'bold', 'Color','k');
ytickangle(90);
xlabel(xlabelString,'FontSize',fsz-5, 'FontWeight', 'bold');
title(titleString, 'FontSize',fsz-3);
ylim([0 max([value{:}])+0.01]);
% L1 = plot(nan, nan, 'color', first_color);
% L2 = plot(nan, nan, 'color', second_color);
% L3 = plot(nan, nan, 'color', third_color);
% legend([L1, L2, L3], {'inside', 'perimiter','outside'})

end





function GlobalFramePlot(axObject,globalPosition,idealStartPosition,idealTargetPosition,onSetIndex,movementNumber,allForce, unit, globalTherapy, time, resamplingFrequency)
% Description: This function creates a 3D plot of the global positions of a movement trajectory, highlighting the start and target positions with spheres and connecting them with a line.
% 
% Arguments:
% 
% axObject (axes): The axes object where the plot will be drawn.
% globalPosition (ndarray, Nx3): A matrix containing global positions for each data point (X, Y, Z coordinates).
% startPosition (ndarray, 3x1): A vector containing the starting position coordinates (X, Y, Z).
% targetPosition (ndarray, 3x1): A vector containing the target position coordinates (X, Y, Z).
% movementNumber (int): The trial number or identifier for this specific movement.
% unit (str): The unit of measurement for the positions (e.g., "m" or "cm").
% globalTherapy: therapy force
% time: the time vector, leave this input blank to avoid plotting the line connecting position points
% resamplingFrequency: is the frequency at which you want to resample the globalPosition data
%
% Outputs:
% 
% A 3D plot within the provided axes object, showing:
% Scatter plot of global positions for each data point.
% Spheres representing the start and target positions with different sizes.
% A line connecting the start and target positions.
% Axis labels with corresponding unit information.
% Title including trial number information.
% Notes:
% 
% This function is a companion to the LocalFramePlot function and visualizes the same movement data in the global reference frame.
% The function uses DrawSphere to create the start and target position spheres with different sizes for better differentiation.
% The plot is configured with grid lines, equal aspect ratio, and specific viewing angles for a consistent viewing experience.
% This function is helpful for comparing the global trajectory with the local frame representation and analyzing movement patterns in the broader context.
    fsz            =  16;
    lsz            =  2;
    mkz            =  16;
    mkz_2          =  50;
    azimuth        = -45;
    elevation      =  45;
    colorGreen     =  [0.2  0.8  0.2];
    startPosition  =  globalPosition(1,:);
    targetPosition =  globalPosition(end,:);
    if onSetIndex == 0
        onSetIndex = 1;
    end

    if ~exist('resamplingFrequency'), resamplingFrequency=0; end


    if ~exist('time')
        time=0;
    else
    freq         =  25; % Hz
    timeSteps    =  freq*time(end);
    x            =  linspace(startPosition(1), targetPosition(1), timeSteps);
    y            =  linspace(startPosition(2), targetPosition(2), timeSteps);
    z            =  linspace(startPosition(3), targetPosition(3), timeSteps);

    timeQ                       =  0:1/freq:timeSteps;
    interpolatedGlobalPosition  =  interp1(time, globalPosition, timeQ);
    interpolatedGlobalPosition  =  rmmissing(interpolatedGlobalPosition);
    end

    
    if (resamplingFrequency ~= 0)
        
        Xparameter                  =  globalPosition;
        Yparameter                  =  allForce;
        [globalPosition, allForce]  =  ResampleFunction (Xparameter, Yparameter, resamplingFrequency, 'position')
        
    end
    
    
    switch unit
        case 'm'
            displayUnitGain = 1;
        case 'cm'
            displayUnitGain = 100;
    end
    hold on;
    grid on;
    box off;
    plot3(axObject,displayUnitGain*globalPosition(:,1),displayUnitGain*globalPosition(:,3),displayUnitGain*globalPosition(:,2),'.','MarkerSize', mkz, 'Color', [0 0.4470 0.7410]);
    plot3(axObject,displayUnitGain*globalPosition(onSetIndex,1),displayUnitGain*globalPosition(onSetIndex,3),displayUnitGain*globalPosition(onSetIndex,2),'.','MarkerSize',mkz,'Color',[0, 0, 0]);
    plot3(axObject,displayUnitGain*globalPosition(onSetIndex(1),1),displayUnitGain*globalPosition(onSetIndex(1),3),displayUnitGain*globalPosition(onSetIndex(1),2),'.','MarkerSize', mkz_2, 'Color', colorGreen);
    DrawSphere(axObject,displayUnitGain*idealStartPosition,unit,'start');
    DrawSphere(axObject,displayUnitGain*idealTargetPosition,unit,'target');


    if ~exist('time')
        time=0;
    else
    freq         =  25; % Hz
    timeSteps    =  freq*time(end);
    x            =  linspace(idealStartPosition(1), idealTargetPosition(1), timeSteps);
    y            =  linspace(idealStartPosition(2), idealTargetPosition(2), timeSteps);
    z            =  linspace(idealStartPosition(3), idealTargetPosition(3), timeSteps);



    timeQ                       =  0:1/freq:timeSteps;
    interpolatedGlobalPosition  =  interp1(time, globalPosition, timeQ);
    interpolatedGlobalPosition  =  rmmissing(interpolatedGlobalPosition);



    % Plot of the connecting line between ideal and actual position 

    % plot3(axObject, displayUnitGain*[x;interpolatedGlobalPosition(:,1)'], displayUnitGain*[z;interpolatedGlobalPosition(:,3)'], displayUnitGain*[y;interpolatedGlobalPosition(:,2)'], 'Color', [0, 0, 0]);


    end
    
    % plot3(axObject,displayUnitGain*[startPosition(1) targetPosition(1)],displayUnitGain*[startPosition(3) targetPosition(3)],displayUnitGain*[startPosition(2) targetPosition(2)], 'o', 'Color', 'k');
    plot3(axObject, displayUnitGain*[x], displayUnitGain*[z], displayUnitGain*[y], '--', 'Color', [0, 0, 0]);
    ForcePlot(axObject,globalPosition,allForce,globalTherapy,unit, 0.2);
    axis equal;
%     view(axObject,azimuth,elevation);
    switch unit
        case 'm'
            unitString=" (m)";
        case 'cm'
            unitString=" (cm)";
    end
    xlabel(axObject,"X"+unitString,'FontSize',fsz);
    ylabel(axObject,"Z"+unitString,'FontSize',fsz);
    zlabel(axObject,"Y"+unitString,'FontSize',fsz);
    title(axObject,"Global Position",'FontSize',fsz);
end



function LocalFramePlot(axObject,localPosition,extentErr,velocity,launchIndex,movementDirection,movementNumber,unit,inFrameTherapy, experimentPhase)
% Description: This function generates a 3D plot of local frame positions, colored according to their extent errors, and highlights the launch trajectory and peak speed position.
% 
% Arguments:
% 
% axObject (axes): The axes object where the plot will be drawn.
% localPosition (ndarray, Nx3): A matrix containing local positions for each data point (X, Y, Z coordinates).
% extentErr (ndarray, Nx1): A vector of extent errors for each corresponding position.
% velocity (ndarray, Nx3): A matrix containing velocity values for each data point (X, Y, Z components).
% launchIndex (int): The index of the data point representing the launch (onset) position.
% movementDirection (str): A string describing the movement direction (e.g., "forward").
% movementNumber (int): The trial number or identifier for this specific movement.
% unit (str): The unit of measurement for the positions and errors (e.g., "m" or "cm").
% Outputs:
% 
% A 3D plot within the provided axes object, showing:
% Colored markers representing local positions with colors mapped to the extent errors.
% A line connecting the launch position, peak speed position, and target location.
% Text labels indicating launch, peak speed, and target positions.
% A colorbar visualization for extent errors.
% Axis labels with direction annotations specific to the movement direction.
% Title including trial number and deviation angle information.
% Notes:
% 
% This function uses several helper functions like MapErrorToColor and GetLaunchDeviationAngle for internal calculations.
% The color mapping applied to the markers is based on the MapErrorToColor function's output.
% The launch trajectory and peak speed position are highlighted using line segments and text labels.
% The unit argument determines the scaling and units displayed in the axis labels and title.
% This function is designed for visualizing and analyzing local frame positions and extent errors for specific movement directions and trials.
    if ~exist('inFrameTherapy')
        inFrameTherapy=zeros(size(velocity)); 
        plotForce=false(1);
    elseif isequal(inFrameTherapy,zeros(size(velocity)))==true(1)
        plotForce=false(1);
    elseif isequal(inFrameTherapy,zeros(size(velocity)))==false(1)
        plotForce=true(1);
    end    
    fsz=16;
    mkz=16;
    azimuth=-45;
    elevation=45;
    switch unit
        case 'm'
            displayUnitGain=1;
        case 'cm'
            displayUnitGain=100;
    end
    [colorMatrx,sortedColorMatrix,sortedExtentErr]=MapErrorToColor(extentErr);
    plot3(axObject,displayUnitGain*[0 .1],[0 0],[0 0],'k','LineWidth',2);
    hold on;
    grid on;
    box off;
    plot3(axObject,displayUnitGain*[0.1 .1],[0 0],[0 0],'x','MarkerSize',mkz);
    text(axObject,displayUnitGain*0.1,0,0,'Target','FontSize',fsz);
    [deviationAngle,localLaunchVector,peakLaunchVelocityIndex]=GetLaunchDeviationAngle(localPosition,velocity,launchIndex);
    scatter3(axObject,displayUnitGain*localPosition(:,1),displayUnitGain*localPosition(:,3),displayUnitGain*localPosition(:,2),mkz,colorMatrx,"filled");
    plot3(axObject,displayUnitGain*[localPosition(launchIndex(1),1) , localPosition(launchIndex(1),1) + localLaunchVector(1)],...
          displayUnitGain*[localPosition(launchIndex(1),2) , localPosition(launchIndex(1),2) + localLaunchVector(2)],...
          displayUnitGain*[localPosition(launchIndex(1),3) , localPosition(launchIndex(1),3) + localLaunchVector(3)],'LineWidth',2);
    plot3(axObject,displayUnitGain*[localPosition(launchIndex(1),1) , localPosition(launchIndex(1),1)],...
          displayUnitGain*[localPosition(launchIndex(1),2) , localPosition(launchIndex(1),2)],...
          displayUnitGain*[localPosition(launchIndex(1),3) , localPosition(launchIndex(1),3)],'^','MarkerSize',mkz);
    text(axObject,displayUnitGain*localPosition(launchIndex(1),1),...
         displayUnitGain*localPosition(launchIndex(1),2),...
         displayUnitGain*localPosition(launchIndex(1),3),'Onset','FontSize',fsz);
    plot3(axObject,displayUnitGain*[localPosition(launchIndex(1),1) + localLaunchVector(1) , localPosition(launchIndex(1),1) + localLaunchVector(1)],...
          displayUnitGain*[localPosition(launchIndex(1),2) + localLaunchVector(2) , localPosition(launchIndex(1),2) + localLaunchVector(2)],...
          displayUnitGain*[localPosition(launchIndex(1),3) + localLaunchVector(3) , localPosition(launchIndex(1),3) + localLaunchVector(3)],'o','MarkerSize',mkz);
    text(axObject,displayUnitGain*(localPosition(launchIndex(1),1) + localLaunchVector(1)),...
         displayUnitGain*(localPosition(launchIndex(1),2) + localLaunchVector(2)),...
         displayUnitGain*(localPosition(launchIndex(1),3) + localLaunchVector(3)),'Peak Speed Position','FontSize',fsz);
%     PlotColorBar(axObject,sortedColorMatrix,sortedExtentErr,unit);
    axis equal;
    view(axObject,azimuth,elevation);
    switch unit
        case 'm'
            unitString=" (m)";
        case 'cm'
            unitString=" (cm)";
    end
    xlabel(axObject,"^"+strcat('{','[',num2str(movementDirection),']','}')+"\rho_1"+unitString,'FontSize',fsz);
    ylabel(axObject,"^"+strcat('{','[',num2str(movementDirection),']','}')+"\rho_2"+unitString,'FontSize',fsz);
    zlabel(axObject,"^"+strcat('{','[',num2str(movementDirection),']','}')+"\rho_3"+unitString,'FontSize',fsz);
    title(axObject,"InFrame Position - "+num2str(experimentPhase)+" - #"+num2str(movementNumber)+" - Deviation Angle: "+num2str(deviationAngle)+"^o",'FontSize',fsz);
end




function RosePlot(axObject, experimentPhase, movementNumber, movementDirection, unit, trialIndexes, Data, trialDirection, maxPerpError, indexesToPlot, experimentMode)
% Rose plot creates a rose plot with all the movements of the specific phase
% contained. 

fsz  =  16;

switch unit
        case 'm'
            displayUnitGain=1;
            unitString=" (m)";
        case 'cm'
            displayUnitGain=100;
            unitString=" (cm)";
end


trialDirection{1,:}            =  find(cellfun(@(x) x.MovementDirection == 0, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex1]  =  sort([maxPerpError{trialDirection{1,:}}], 'descend');

trialDirection{2,:}            =  find(cellfun(@(x) x.MovementDirection == 1, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex2]  =  sort([maxPerpError{trialDirection{2,:}}], 'descend');

trialDirection{3,:}            =  find(cellfun(@(x) x.MovementDirection == 2, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex3]  =  sort([maxPerpError{trialDirection{3,:}}], 'descend');

trialDirection{4,:}            =  find(cellfun(@(x) x.MovementDirection == 3, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex4]  =  sort([maxPerpError{trialDirection{4,:}}], 'descend');

trialDirection{5,:}            =  find(cellfun(@(x) x.MovementDirection == 4, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex5]  =  sort([maxPerpError{trialDirection{5,:}}], 'descend');

trialDirection{6,:}            =  find(cellfun(@(x) x.MovementDirection == 5, Data(indexesToPlot, :)));
[~, maxPerpErrorSortedIndex6]  =  sort([maxPerpError{trialDirection{6,:}}], 'descend');

if strcmp(experimentMode,'2D')==false
    trialDirection{7,:}            =  find(cellfun(@(x) x.MovementDirection == 6, Data(indexesToPlot, :)));
    [~, maxPerpErrorSortedIndex6]  =  sort([maxPerpError{trialDirection{7,:}}], 'descend');

    trialDirection{8,:}            =  find(cellfun(@(x) x.MovementDirection == 7, Data(indexesToPlot, :)));
    [~, maxPerpErrorSortedIndex7]  =  sort([maxPerpError{trialDirection{8,:}}], 'descend');
end



% PracticedColor=EquiDistantColorGenerator(4,0.84913);
PracticedColor=EquiDistantColorGenerator(4,9742);
UnpracticedColor=ones(size(PracticedColor))-PracticedColor;
% UnpracticedColor=[1 0 0;0 0 1;0 1 0;1 0 1];
% UnpracticedColor=[0.2 0.4 0.1; 0.4 0.1 0.4; 0.8 0.3 0.1; 0 0 1];
% C=[PracticedColor(1:3,:);UnpracticedColor(1:3,:)];
C=[PracticedColor;UnpracticedColor];


numbOfMovementDir0  =  length(trialDirection{1,:});
numbOfMovementDir1  =  length(trialDirection{2,:});
numbOfMovementDir2  =  length(trialDirection{3,:});
numbOfMovementDir3  =  length(trialDirection{4,:});
numbOfMovementDir4  =  length(trialDirection{5,:});
numbOfMovementDir5  =  length(trialDirection{6,:});
numbOfMovementDir6  =  length(trialDirection{7,:});
numbOfMovementDir7  =  length(trialDirection{8,:});
dir0counter      =  1;
dir1counter      =  1;
dir2counter      =  1;
dir3counter      =  1;
dir4counter      =  1;
dir5counter      =  1;
dir6counter      =  1;
dir7counter      =  1;


if (movementDirection < 3)
    dir0colors       =  zeros(numbOfMovementDir0, 3);
    dir0colors(:,1)  =  linspace(C(1,1), 1, numbOfMovementDir0);
    dir0colors(:,2)  =  linspace(C(1,2), 1, numbOfMovementDir0);
    dir0colors(:,3)  =  linspace(C(1,3), 1, numbOfMovementDir0);
    dir0counter      =  1;

    dir1colors       =  zeros(numbOfMovementDir1, 3);
    dir1colors(:,1)  =  linspace(C(2,1), 1, numbOfMovementDir1);
    dir1colors(:,2)  =  linspace(C(2,2), 1, numbOfMovementDir1);
    dir1colors(:,3)  =  linspace(C(2,3), 1, numbOfMovementDir1);
    dir1counter      =  1;

    dir2colors       =  zeros(numbOfMovementDir2, 3);
    dir2colors(:,1)  =  linspace(C(3,1), 1, numbOfMovementDir2);
    dir2colors(:,2)  =  linspace(C(3,2), 1, numbOfMovementDir2);
    dir2colors(:,3)  =  linspace(C(3,3), 1, numbOfMovementDir2);
    dir2counter      =  1;
else
    dir3colors       =  zeros(numbOfMovementDir3, 3);
    dir3colors(:,1)  =  linspace(C(4,1), 1, numbOfMovementDir3);
    dir3colors(:,2)  =  linspace(C(4,2), 1, numbOfMovementDir3);
    dir3colors(:,3)  =  linspace(C(4,3), 1, numbOfMovementDir3);
    dir3counter      =  1;

    dir4colors       =  zeros(numbOfMovementDir4, 3);
    dir4colors(:,1)  =  linspace(C(5,1), 1, numbOfMovementDir4);
    dir4colors(:,2)  =  linspace(C(5,2), 1, numbOfMovementDir4);
    dir4colors(:,3)  =  linspace(C(5,3), 1, numbOfMovementDir4);
    dir4counter      =  1;

    dir5colors       =  zeros(numbOfMovementDir5, 3);
    dir5colors(:,1)  =  linspace(C(6,1), 1, numbOfMovementDir5);
    dir5colors(:,2)  =  linspace(C(6,2), 1, numbOfMovementDir5);
    dir5colors(:,3)  =  linspace(C(6,3), 1, numbOfMovementDir5);
    dir5counter      =  1;

    dir6colors       =  zeros(numbOfMovementDir6, 3);
    dir6colors(:,1)  =  linspace(C(7,1), 1, numbOfMovementDir6);
    dir6colors(:,2)  =  linspace(C(7,2), 1, numbOfMovementDir6);
    dir6colors(:,3)  =  linspace(C(7,3), 1, numbOfMovementDir6);
    dir6counter      =  1;

    dir7colors       =  zeros(numbOfMovementDir7, 3);
    dir7colors(:,1)  =  linspace(C(8,1), 1, numbOfMovementDir7);
    dir7colors(:,2)  =  linspace(C(8,2), 1, numbOfMovementDir7);
    dir7colors(:,3)  =  linspace(C(8,3), 1, numbOfMovementDir7);
    dir7counter      =  1;
end


for count = trialIndexes

    % if (Data{count}.DistortionFlag == 1)        % This is to plot in the rose plot only the trials with the force on
        if (Data{count}.RestingMovementFlag == 0 & Data{count}.PhaseBeginningTrial == 0)
            if (Data{count}.MovementDirection == 0)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir0colors(maxPerpErrorSortedIndex1(dir0counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(1,:)); % 3D and slow version
                dir0counter = dir0counter + 1;
            elseif (Data{count}.MovementDirection == 1)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir1colors(maxPerpErrorSortedIndex2(dir1counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(2,:)); % 3D and slow version
                dir1counter = dir1counter + 1;
            elseif (Data{count}.MovementDirection == 2)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir2colors(maxPerpErrorSortedIndex3(dir2counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(3,:)); % 3D and slow version
                dir2counter = dir2counter + 1;
            elseif (Data{count}.MovementDirection == 3)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir3colors(maxPerpErrorSortedIndex4(dir3counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(4,:)); % 3D and slow version
                dir3counter = dir3counter + 1;
            elseif (Data{count}.MovementDirection == 4)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir4colors(maxPerpErrorSortedIndex5(dir4counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(5,:)); % 3D and slow version
                dir4counter = dir4counter + 1;
            elseif (Data{count}.MovementDirection == 5)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir5colors(maxPerpErrorSortedIndex6(dir5counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(6,:)); % 3D and slow version
                dir5counter = dir5counter + 1;
            elseif (Data{count}.MovementDirection == 6)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir5colors(maxPerpErrorSortedIndex6(dir5counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(7,:)); % 3D and slow version
                dir6counter = dir6counter + 1;
            elseif (Data{count}.MovementDirection == 7)
                % plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2)- Data{count}.GlobalPosition(1,2)], '.-', 'Color', dir5colors(maxPerpErrorSortedIndex6(dir5counter), :)); % 3D and slow version
                plot3(axObject, displayUnitGain*[Data{count}.GlobalPosition(:,1) - Data{count}.GlobalPosition(1,1)], displayUnitGain*[Data{count}.GlobalPosition(:,3) - Data{count}.GlobalPosition(1,3)], displayUnitGain*[Data{count}.GlobalPosition(:,2) - Data{count}.GlobalPosition(1,2)], '.-', 'Color', C(8,:)); % 3D and slow version
                dir7counter = dir7counter + 1;
            end
            % plot3(axObject, displayUnitGain*[0; Data{count}.TargetPosition(1) - Data{count}.StartPosition(1)], displayUnitGain*[0; Data{count}.TargetPosition(3) - Data{count}.StartPosition(3)], displayUnitGain*[0; Data{count}.TargetPosition(2) - Data{count}.StartPosition(2)], 'LineWidth', 3, 'Color', 'k');
            plot3(axObject, displayUnitGain*[0; Data{count}.TargetPosition(1) - Data{count}.StartPosition(1)], displayUnitGain*[0; Data{count}.TargetPosition(3) - Data{count}.StartPosition(3)], displayUnitGain*[0; Data{count}.TargetPosition(2) - Data{count}.StartPosition(2)], 'LineWidth', 2, 'Color', 'k');
            hold on

        end

    % end
end

movementNumber = Data{movementNumber}.MovementNumber;
% view(2);
view(26, 50);
axis off
title(axObject,"Rose plot of the: "+num2str(experimentPhase)+" - Trial : "+num2str(movementNumber),'FontSize',fsz);

end





function RoboticSimulation(axObject, time, globalPosition, experimentPhase, movementNumber)
% This function create a robotic model of the system and let it execute the
% trajectory of the movement

% Define the robotic arm parameters
L1 = 0.65; % Length of vertical link (0.65)
L2 = 0.43; % Length of perpendicular link (0.43)
D1 = 0.156;  % (0.156)
D2 = 0.069;  % (0.069)
alpha0 = pi/2;
alpha2 = -pi/2;

% Define the DH parameters
L(1) = Link('d', 0, 'a',  0, 'alpha', alpha0);   % Joint 1
L(2) = Link('d', 0, 'a', L1, 'alpha', alpha2);  % Joint 2
L(3) = Link('d', D2, 'a', L2, 'alpha',  0);     % Joint 3 (rotated by 90 degrees)

% Create the robot object
robot = SerialLink(L, 'name', 'Burt');

% Define joint angles
q = [0, 0, -pi/3]; % Joint angles for link 1, link 2, and link 3 respectively

% Compute forward kinematics
T = robot.fkine(q);

% Extract end-effector position
endEffectorPosition = transl(T);

% Display end-effector position
% disp('End-Effector Position:');
% disp(endEffectorPosition);


fsz  =  16;

% Define desired end-effector trajectory
freq                        =  10; % Hz
timeSteps                   =  freq*time(end);
timeQ                       =  0:1/freq:timeSteps;
interpolatedGlobalPosition  =  interp1(time, globalPosition, timeQ);
interpolatedGlobalPosition  =  rmmissing(interpolatedGlobalPosition);
interpolatedGlobalPosition  =  interpolatedGlobalPosition;

x_desired = interpolatedGlobalPosition(:,1);  % Example trajectory in x-direction
y_desired = interpolatedGlobalPosition(:,3);  % Example trajectory in y-direction
z_desired = interpolatedGlobalPosition(:,2);  % Example trajectory in z-direction

% Initialize matrix to store end-effector positions
endEffectorPositions = zeros(3, length(x_desired));

% subplot(1,2,1)
% plot3(x_desired, y_desired, z_desired, 'b', 'LineWidth', 2)
% hold on
% scatter3(x_desired, y_desired, z_desired, 'ro');
% title('Trajectory')

% Loop through each time step to compute end-effector positions
for i = 1:length(x_desired)
    % Interpolate end-effector position at current time step
    endEffectorPositions(:, i) = [x_desired(i); y_desired(i); z_desired(i)];
    
    % Compute inverse kinematics to find joint angles for each end-effector position
    q = robot.ikine(transl(x_desired(i), y_desired(i), z_desired(i)), 'mask', [1 1 1 0 0 0], 'q0', [0, 0, 0]);

    
    % Plot the robot at each configuration along the trajectory
    robot.plot(q, 'workspace', [-0.3 1.5 -0.3 1.5 -0.25 1.5], 'nowrist', 'noarrow', 'nojoints'); % 'alpha', 0.5,
    axis off
    hold on
    plot3(interpolatedGlobalPosition(i,1), interpolatedGlobalPosition(i,3), interpolatedGlobalPosition(i,2), '.');
    hold on
    axis off
    view([-56.1916, 42.4889])

end
    axis off
    title(axObject,"InFrame Position - "+num2str(experimentPhase)+" - #"+num2str(movementNumber),'FontSize',fsz);

end


function PlotDirectionGuide2D(axOject,MovementDirections,ColorMatrix,actualMovementDirection)
    lsz=2;
    lsz2=1;
    fsz=16;
    % [d_0,d_1,d_2,d_3,d_4,d_5,R_0,R_1,R_2,R_3,R_4,R_5]=GetDirectionsAndMatrixes2D();
    [d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7,R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7]=GetDirectionsAndMatrixes('numeric');
    D=[d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7];
    allDirections=[0:7]';
    logIndex=ismember(allDirections,MovementDirections);
    hold(axOject,"on");
    axis(axOject,'equal');
    for counter=1:numel(MovementDirections)
        % directionText="d_"+num2str(counter-1);
        if logIndex(counter)==true(1)
            if (actualMovementDirection < 3)
                if (counter < 4)
                    q = quiver3(0,0,0,D(1,counter),D(3,counter),D(2,counter),'LineWidth',lsz,'Color',ColorMatrix(counter,:));
                else
                    q = quiver3(0,0,0,D(1,counter),D(3,counter),D(2,counter),'LineWidth',lsz,'Color',[.8 .8 .8]);
                end
            else
                if (counter < 4)
                    q = quiver3(0,0,0,D(1,counter),D(3,counter),D(2,counter),'LineWidth',lsz,'Color',[.8 .8 .8]);
                    set(q, 'HandleVisibility', 'off');
                else
                    q = quiver3(0,0,0,D(1,counter),D(3,counter),D(2,counter),'LineWidth',lsz,'Color',ColorMatrix(counter,:));
                end
            end

        else
            q = quiver3(0,0,0,D(1,counter),D(3,counter),D(2,counter),'LineWidth',lsz,'Color',0.5*ones(1,3));
            % text(D(1,counter),D(3,counter),D(2,counter),directionText,"FontSize",fsz,'Color',0.5*ones(1,3));
        end
        q.AutoScale = 0;
        q.MaxHeadSize = 3;
    end

    
%     view(axOject,0,30);
        % x0=10;
        % y0=10;
        % width=550;
        % height=400;
        % set(gcf,'position',[x0,y0,width,height]);
    axis(axOject,"off");
    title('Directions', 'FontWeight','bold', 'FontSize', 15);
end





function PlotColorBar(axObject,sortedColorMatrix,sortedExtentErr,unit)
% Description: This function generates a colorbar visualization for extent error data within a 3D plot.
% 
% Arguments:
% 
% axObject (axes): The axes object where the colorbar and markers will be drawn.
% sortedColorMatrix (ndarray, Nx3): A matrix of color values (RGB) corresponding to the sorted extent error values.
% sortedExtentErr (ndarray, Nx1): A vector of sorted extent error values.
% unit (str): The unit of the extent error data. Either:
% 'm': Meters (default gain = 1)
% 'cm': Centimeters (gain = 100 to adjust for smaller scale)
% Outputs:
% 
% A visualization within the provided axes object, including:
% Colored markers representing the sorted extent error magnitudes.
% Text labels indicating minimum, maximum, ideal, and median values.
% Notes:
% 
% The function uses the sorted sortedColorMatrix and sortedExtentErr to associate color and position information for each data point.
% Markers are plotted at specific 3D locations within the axes object.
% Text labels are added to highlight minimum, maximum, ideal (minimum absolute value), and median values of the extent errors.
% The unit argument determines the display scale for the error values in the text labels.
% This function is typically used in conjunction with LocalFramePlot to visualize the extent errors and their corresponding color-coded magnitudes in a 3D plot.

    rho_1=0.16;
    rho_2=-0.1;
    rho_3=-0.05;
    gain=1.05;
    fsz=16;
    mkz=16;
    digits=4;
    switch unit
        case 'm'
            displayUnitGain=1;
            unitString=" (m)";
        case 'cm'
            displayUnitGain=100;
            unitString=" (cm)";
    end
    points=[rho_1*displayUnitGain*ones(numel(sortedExtentErr),1),rho_2*displayUnitGain*ones(numel(sortedExtentErr),1),displayUnitGain*((linspace(-0.05,0.05,numel(sortedExtentErr)))')];
    for counter=1:numel(sortedExtentErr)
        plot3(axObject,points(counter,1),points(counter,2),points(counter,3),'.','Color',sortedColorMatrix(counter,:),'MarkerSize',mkz);hold on;
    end
        absSortedExtent=abs(sortedExtentErr);
        [minimumOfAbosultes,indexOf]=min(absSortedExtent);
        [temp idx] = min(abs(sortedExtentErr-median(sortedExtentErr)));
%         minumum
        ind=1;
        plot3(axObject,points(ind,1),points(ind,2),points(ind,3),'_','Color',sortedColorMatrix(ind,:),'MarkerSize',mkz+6);
        text(axObject,points(ind,1),gain*points(ind,2),points(ind,3),"min = "+num2str(round(displayUnitGain*sortedExtentErr(ind),digits))+unitString);
%         maximum
        ind=numel(sortedExtentErr);
        plot3(axObject,points(ind,1),points(ind,2),points(ind,3),'_','Color',sortedColorMatrix(ind,:),'MarkerSize',mkz+6);
        text(axObject,points(ind,1),gain*points(ind,2),points(ind,3),"max = "+num2str(round(displayUnitGain*sortedExtentErr(ind),digits))+unitString);
%         ideal
        ind=indexOf;
        plot3(axObject,points(ind,1),points(ind,2),points(ind,3),'_','Color',sortedColorMatrix(ind,:),'MarkerSize',mkz+6);
        text(axObject,points(ind,1),gain*points(ind,2),points(ind,3),"ideal = "+num2str(round(displayUnitGain*sortedExtentErr(ind),digits))+unitString);
%         median
        ind=idx;        
        plot3(axObject,points(ind,1),points(ind,2),points(ind,3),'_','Color',sortedColorMatrix(ind,:),'MarkerSize',mkz+6);        
        text(axObject,points(ind,1),gain*points(ind,2),points(ind,3),"median = "+num2str(round(displayUnitGain*sortedExtentErr(ind),digits))+unitString);
end



function DrawSphere(axObject,centerPosition,unit,type)
% Description: This function creates and draws a sphere object on the specified axes object.
% 
% Arguments:
% 
% axObject (axes): The axes object where the sphere will be drawn.
% centerPosition (ndarray, 3x1): The center position of the sphere in the chosen unit (X, Y, Z coordinates).
% unit (str): The unit of measurement for the sphere's radius and center position. Either:
% 'm': Meters (default gain = 1)
% 'cm': Centimeters (gain = 100 to adjust for smaller scale)
% type (str): The type of sphere to draw. Currently supported types are:
% 'start': Draws a smaller sphere representing the starting position.
% 'target': Draws a larger sphere representing the target position.
% Outputs:
% 
% A surface object representing the sphere drawn on the specified axes object.
% Notes:
% 
% The function uses the sphere function to generate the sphere mesh.
% The unit and type arguments determine the radius and visual properties of the sphere.
% The FaceAlpha property sets the transparency of the sphere (0.5 being semi-transparent).
% The EdgeColor property is set to 'none' to hide the sphere's edges.
% This function is typically used to visualize spheres in specific locations, such as the starting and target positions of a movement in a 3D plot.
% 
    gameObjectScaleInUnity=0.2;
    meterToUnityGain=20; % before was 30
    switch unit
        case 'm'
            displayUnitGain=1;
        case 'cm'
            displayUnitGain=100;
    end
    switch type
        case 'start'
            radius=gameObjectScaleInUnity/meterToUnityGain/2;
        case 'target'
            radius=gameObjectScaleInUnity/meterToUnityGain/2;
    end
    [X,Y,Z] = sphere(axObject);
    s = surf(axObject,displayUnitGain*(radius*X+centerPosition(1)),displayUnitGain*(radius*Z+centerPosition(3)),displayUnitGain*(radius*Y+centerPosition(2)),'FaceAlpha',0.5,'EdgeColor','none');
    s.EdgeColor = 'none';
    s.FaceColor = 'flat';

%     ctr  =  mean([displayUnitGain*(radius*X+centerPosition(1)), displayUnitGain*(radius*Z+centerPosition(3)), displayUnitGain*(radius*Y+centerPosition(2))]);
%     tria

end


function rotationMatrix=GetUnityToLocalRotationMatrix(direction,mode)
% Description: This function retrieves a rotation matrix for transforming vectors from Unity's left-handed world frame to a specific direction in your right-handed local coordinate system.
% 
% Arguments:
% 
% direction (int): An integer between 1 and 8, representing the desired direction in the local frame.
% 
% Outputs:
% 
% rotationMatrix (ndarray, 3x3): A rotation matrix that transforms a vector from Unity's left-handed frame to the specified direction vector in your right-handed local frame.
% Notes:
% 
% This function internally calls GetDirectionsAndMatrixes('numeric') to pre-calculate the necessary direction vectors and rotation matrices.
% The provided direction index corresponds to the order of the direction vectors calculated in GetDirectionsAndMatrixes.
% The rotation matrix accounts for the handedness difference between Unity's left-handed frame and your right-handed local frame, ensuring correct orientation of transformed vectors.
    if ~exist("mode"), mode='3D'; end
    switch mode
        case '2D'
            [d_0,d_1,d_2,d_3,d_4,d_5,R_0,R_1,R_2,R_3,R_4,R_5]=GetDirectionsAndMatrixes2D();
            switch direction
                case 1-1
                    rotationMatrix  =   R_0;
                case 2-1
                    rotationMatrix  =   R_1;
                case 3-1
                    rotationMatrix  =   R_2;
                case 4-1
                    rotationMatrix  =   R_3;
                case 5-1
                    rotationMatrix  =   R_4;
                case 6-1
                    rotationMatrix  =   R_5;
            end
        case '3D'
            [d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7,R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7]=GetDirectionsAndMatrixes('numeric');
            switch direction
                case 1-1
                    rotationMatrix  =   R_0;
                case 2-1
                    rotationMatrix  =   R_1;
                case 3-1
                    rotationMatrix  =   R_2;
                case 4-1
                    rotationMatrix  =   R_3;
                case 5-1
                    rotationMatrix  =   R_4;
                case 6-1
                    rotationMatrix  =   R_5;
                case 7-1
                    rotationMatrix  =   R_6;
                case 8-1
                    rotationMatrix  =   R_7;
            end
    end

end


function [d_0,d_1,d_2,d_3,d_4,d_5,R_0,R_1,R_2,R_3,R_4,R_5]=GetDirectionsAndMatrixes2D()
theta_1=pi/2+2*(2*pi/3);
theta_2=pi/2+1*(2*pi/3);
theta_3=pi/6;
theta_4=5*pi/6;
g=[0;-1;0];
d_0=[0;0;1];
R_0=[d_0';-cross(d_0,g)';cross(-cross(d_0,g),d_0)'];

d_1=[cos(theta_1);0;sin(theta_1)];
R_1=[d_1';-cross(d_1,g)';cross(-cross(d_1,g),d_1)'];

d_2=[cos(theta_2);0;sin(theta_2)];
R_2=[d_2';-cross(d_2,g)'/norm(-cross(d_2,g));cross(-cross(d_2,g),d_2)'/norm(cross(-cross(d_2,g),d_2))];

d_3=[0;0;-1];
R_3=[d_3';-cross(d_3,g)'/norm(-cross(d_3,g));cross(-cross(d_3,g),d_3)'/norm(cross(-cross(d_3,g),d_3))];

d_4=[cos(theta_3);0;sin(theta_3)];
R_4=[d_4';-cross(d_4,g)';cross(-cross(d_4,g),d_4)'];

d_5=[cos(theta_4);0;sin(theta_4)];
R_5=[d_5';-cross(d_5,g)';cross(-cross(d_5,g),d_5)'];
% ax=axes;hold on;
% plotLine(ax,d_0);
% plotLine(ax,d_1);
% plotLine(ax,d_2);
% plotLine(ax,d_3);
% plotLine(ax,d_4);
% plotLine(ax,d_5);
end



function [d_0,d_1,d_2,d_3,d_4,d_5,d_6,d_7,R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7]=GetDirectionsAndMatrixes(type)
% Description: This function calculates and returns direction vectors and rotation matrices for seven different directions, converting from Unity's left-handed frame to a right-handed local coordinate system.
% 
% Arguments:
% 
% type (str): Specifies the output format.
% 'numeric': Outputs pre-calculated direction vectors and rotation matrices as numerical values.
% 'symbolic': Outputs symbolic expressions for direction vectors and rotation matrices using the symbol theta for the rotation angle.
% Outputs:
% 
% d_i (ndarray, 3x1): Direction vectors for each of the seven directions (i = 0 to 6), transformed from Unity's left-handed frame to the right-handed local frame.
% R_i (ndarray, 3x3): Rotation matrices for each of the seven directions (i = 0 to 6), designed to rotate a vector from Unity's left-handed frame to the corresponding direction vector in the right-handed local frame.
% Direction Vectors:
% 
% Rotation Matrices:
% 
% R_i matrices perform the necessary rotations to transform a vector from Unity's left-handed coordinate system to the desired direction in the right-handed local frame.
% Notes:
% 
% The function considers the handedness difference between Unity's left-handed frame and your desired right-handed local frame.
% The rotation matrices are designed to account for this difference and correctly orient your vectors.
% This function can be useful for tasks like transforming data between Unity and your custom right-handed local coordinate system, aligning objects within different coordinate systems, and performing calculations with consistent handedness.
    switch type
        case 'numeric'
            theta=pi-2*asin(sqrt(3)/3);
        case 'symbolic'
            syms theta
    end
    g=[0;-1;0];
    d_0=[0;0;1];
    R_0=[d_0';-cross(d_0,g)';cross(-cross(d_0,g),d_0)'];
    
    d_1=[sin(theta);0;cos(theta)];
    R_1=[d_1';-cross(d_1,g)';cross(-cross(d_1,g),d_1)'];
    
    d_2=[(-1/2)*sin(theta);(sqrt(3)/2)*sin(theta);cos(theta)];
    R_2=[d_2';-cross(d_2,g)'/norm(-cross(d_2,g));cross(-cross(d_2,g),d_2)'/norm(cross(-cross(d_2,g),d_2))];
    
    d_3=[(-1/2)*sin(theta);-(sqrt(3)/2)*sin(theta);cos(theta)];
    R_3=[d_3';-cross(d_3,g)'/norm(-cross(d_3,g));cross(-cross(d_3,g),d_3)'/norm(cross(-cross(d_3,g),d_3))];
    
    d_4=[0;0;-1];
    R_4=[d_4';-cross(d_4,g)';cross(-cross(d_4,g),d_4)'];
    
    d_5=[-sin(theta);0;-cos(theta)];
    R_5=[d_5';-cross(d_5,g)';cross(-cross(d_5,g),d_5)'];
    
    d_6=[(1/2)*sin(theta);-(sqrt(3)/2)*sin(theta);-cos(theta)];
    R_6=[d_6';-cross(d_6,g)'/norm(-cross(d_6,g));cross(-cross(d_6,g),d_6)'/norm(cross(-cross(d_6,g),d_6))];
    
    d_7=[(1/2)*sin(theta);(sqrt(3)/2)*sin(theta);-cos(theta)];
    R_7=[d_7';-cross(d_7,g)'/norm(-cross(d_7,g));cross(-cross(d_7,g),d_7)'/norm(cross(-cross(d_7,g),d_7))];
end


function [colorGradientMatrix,sortedColorGradientMatrix,sortedErrors]=MapErrorToColor(errorVector)
    if errorVector==zeros(size(errorVector))
        colorGradientMatrix=repmat([0 0 1],numel(errorVector),1);
        sortedColorGradientMatrix=colorGradientMatrix;
        sortedErrors=errorVector;
    else
        adjustedErrorVector=errorVector-min(errorVector);
        redGradient = normalize(adjustedErrorVector);
        blueGradient = 1 - normalize(adjustedErrorVector);
        if size(adjustedErrorVector,1)>1
            colorGradientMatrix = [redGradient, zeros(size(redGradient)), blueGradient];
        elseif size(adjustedErrorVector,2)>1
            colorGradientMatrix = [redGradient', zeros(size(redGradient))', blueGradient'];
        end
        [sortedErrors, sortingIndex] =sort(errorVector);
        sortedColorGradientMatrix=colorGradientMatrix(sortingIndex,:);
    end
end


function normalizedVector=normalize(vector)
    normalizedVector=vector./max(abs(vector));
end


function [deviationAngle,localLaunchVector,peakLaunchVelocityIndex]=GetLaunchDeviationAngle(localPosition,velocity,launchIndex)
if (launchIndex(1) == 0)
    positionOffset=localPosition(1,:);
    speed=vecnorm((velocity(1,:))')';
peakLaunchVelocityIndex=1;
else
    positionOffset=localPosition(launchIndex(1),:);
    speed=vecnorm((velocity(launchIndex,:))')';
    [peakSpeed,peakIndex]=max(speed);
peakLaunchVelocityIndex=launchIndex(peakIndex);
end

peakSpeedPosition=localPosition(peakLaunchVelocityIndex,:)-positionOffset;
localLaunchVector=peakSpeedPosition;
deviationAngle=AngleOfInnerProduct([0.1,0,0],peakSpeedPosition);
end



%% Added function

function angle=AngleOfInnerProduct(vector_1,vector_2)
angle=acos(dot(vector_1,vector_2)/(norm(vector_1)*norm(vector_2)))*(180/pi);
end