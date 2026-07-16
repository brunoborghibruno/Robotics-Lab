%% BRUNO BORGHI - Function that re-creates the environment of the Error Field experiment and plot the experiment trajectories on top


% subjectsList            =   ["E-5", "E-16", "E-21", "E-25", "E-26"];
subjectsList    =   ["E-69"];

% treatmentVisit          =   [ "Visit_1", "Visit_2", "Visit_3", "Visit_4", "Visit_5", "Visit_6", "Visit_7", "Visit_8", "Visit_9"];
treatmentVisit  =   ["Visit_1", "Visit_5", "Visit_7"];


% phasesToPlot    =   ["Familiarization", "UnpracticedIntermittentExposure", "Baseline", "IntermittentExposure", "Training", "Washout", "UnpracticedWashout"];
phaseToPlot    =   ["IntermittentExposure"];



initialFolder   =   pwd; % it saves the current folder calleed MATLAB where all the programs and data is


% dir0_Color   =  [  0, 145, 117];
% dir1_Color   =  [255, 223,   0];
% dir2_Color   =  [  0,  87, 179];
% dir3_Color   =  [188,   0,  96];

dir0_Color   =  [0, 0.569, 0.459];
dir1_Color   =  [1, 0.875, 0];
dir2_Color   =  [0.737, 0, 0.376];
dir3_Color   =  [0, 0.341, 0.702];

dir4_Color   =  ones(1,3) - [0, 0.569, 0.459];
dir5_Color   =  ones(1,3) - [1, 0.875, 0];
dir6_Color   =  ones(1,3) - [0.737, 0, 0.376];
dir7_Color   =  ones(1,3) - [0, 0.341, 0.702];

% markerList = ['o', 's', '^', 'd', 'x', '+', '*', 'v', '>'];  % Add more if needed
colors                  =   lines(length(subjectsList)); % built-in colormap with distinct colors


scatterSize             =   100;

medianGlobalPosition    =   1; % write to 1 if you want to have the median of all the global position in the rose plots

% UnpracticedDirections   =   1;






%% Store the Error metric from all the subjects

% 
% targetNumber = 1;
% targetsList  = zeros(15,3); % each row a target position

movementNumbExperimentPhases = [];
movementNumbSaved            = 0;
addpath(initialFolder);
fig = figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
set(fig, 'WindowState', 'maximized');

for count = 1:length(subjectsList)

    cd(strcat([initialFolder+"/"+subjectsList(count)]));      % Open the folder with the respective data of that subject

    % fig             =   figure(1);
    % fig.WindowState =   'maximized';
    
    % set(fig, 'Color', 'none'); % white background
    hAxTiled = tiledlayout(length(treatmentVisit), 4, 'TileSpacing','tight','Padding','compact');

    for visitIndex = 1:length(treatmentVisit)

        % Initialize the target reached count
        targetReached_Dir0      =   0;
        targetNotReached_Dir0   =   0;
        targetReached_Dir1      =   0;
        targetNotReached_Dir1   =   0;
        targetReached_Dir2      =   0;
        targetNotReached_Dir2   =   0;
        targetReached_Dir3      =   0;
        targetNotReached_Dir3   =   0;
        targetReached_Dir4      =   0;
        targetNotReached_Dir4   =   0;
        targetReached_Dir5      =   0;
        targetNotReached_Dir5   =   0;
        targetReached_Dir6      =   0;
        targetNotReached_Dir6   =   0;
        targetReached_Dir7      =   0;
        targetNotReached_Dir7   =   0;

        firstMedianCalculation  =   1;
        load(subjectsList(count) + "_" + treatmentVisit(visitIndex) + ".mat");

        movementNumbExperimentPhases = [];
        % if movementNumbSaved == 0
            for i = 1:length(phaseToPlot)
                movementNumbExperimentPhases = [movementNumbExperimentPhases; [PhaseIndex.(matlab.lang.makeValidName(phaseToPlot(i)))]];
            end
            % movementNumbSaved = 1;
        % end

        movementNumbExperimentPhases = sort(movementNumbExperimentPhases);

        if (Data{movementNumbExperimentPhases(1)}.MovementDirection < 4)
            % Practiced Directions
            hAx_Dir0    =   nexttile(hAxTiled, 1+(4*(visitIndex-1)));
            % hAx_Dir0    =   subplot(length(treatmentVisit), 4, 1+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir1    =   subplot(length(treatmentVisit), 4, 2+(4*(visitIndex-1)));
            hAx_Dir1    =   nexttile(hAxTiled, 2+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir2    =   subplot(length(treatmentVisit), 4, 3+(4*(visitIndex-1)));
            hAx_Dir2    =   nexttile(hAxTiled, 3+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir3    =   subplot(length(treatmentVisit), 4, 4+(4*(visitIndex-1)));
            hAx_Dir3    =   nexttile(hAxTiled, 4+(4*(visitIndex-1)));
            hold on;
        else
            % Unpracticed Directions
            hAx_Dir4    =   nexttile(hAxTiled, 1+(4*(visitIndex-1)));
            % hAx_Dir0    =   subplot(length(treatmentVisit), 4, 1+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir1    =   subplot(length(treatmentVisit), 4, 2+(4*(visitIndex-1)));
            hAx_Dir5    =   nexttile(hAxTiled, 2+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir2    =   subplot(length(treatmentVisit), 4, 3+(4*(visitIndex-1)));
            hAx_Dir6    =   nexttile(hAxTiled, 3+(4*(visitIndex-1)));
            hold on;
            % hAx_Dir3    =   subplot(length(treatmentVisit), 4, 4+(4*(visitIndex-1)));
            hAx_Dir7    =   nexttile(hAxTiled, 4+(4*(visitIndex-1)));
            hold on;
        end


        targetNumber = 1;
        targetsList  = zeros(15,3);

        for movementNumb = [movementNumbExperimentPhases]' % 1:length(Data)

            if ismember(movementNumb, movementNumbExperimentPhases)

                GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)) =   Data{movementNumb}.GlobalPosition;
                GlobalTime.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb))     =   Data{movementNumb}.SampleTime;
                targetPosition  =    (Data{movementNumb}.TargetPosition)';

                if ~ismember(targetPosition, targetsList, 'rows')
                    targetsList(targetNumber,:)     =   targetPosition;
                    targetNumber                    =   targetNumber + 1;
                end

                % if targetNumber == 16
                %     surfAxisObject_Dir0 = PlotTargetIn3D(hAx_Dir0, targetsList);
                %     surfAxisObject_Dir1 = PlotTargetIn3D(hAx_Dir1, targetsList);
                %     surfAxisObject_Dir2 = PlotTargetIn3D(hAx_Dir2, targetsList);
                %     surfAxisObject_Dir3 = PlotTargetIn3D(hAx_Dir3, targetsList);
                %     targetNumber = 1;
                % end

                targetReached   =   ~(Data{movementNumb}.NotReachedTarget);
                groupNumber     =   Data{movementNumb}.GroupNumber;
                % disp(groupNumber);


                if Data{movementNumb}.MovementDirection < 4   % Practiced Directions

                    if Data{movementNumb}.MovementDirection == 0 % Direction 0

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       =   dir0_Color;
                        if targetReached == 1
                            targetReached_Dir0      =   targetReached_Dir0 + 1;
                            PlotRealTrajectories(hAx_Dir0, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir0, targetNotReached_Dir0, targetPosition);
                        else
                            targetNotReached_Dir0   =   targetNotReached_Dir0 + 1;
                            PlotRealTrajectories(hAx_Dir0, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir0, targetNotReached_Dir0);
                        end

                    elseif Data{movementNumb}.MovementDirection == 1 % Direction 1

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir1_Color;
                        if targetReached == 1
                            targetReached_Dir1      =   targetReached_Dir1 + 1;
                            PlotRealTrajectories(hAx_Dir1, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir1, targetNotReached_Dir1, targetPosition);
                        else
                            targetNotReached_Dir1      =   targetNotReached_Dir1 + 1;
                            PlotRealTrajectories(hAx_Dir1, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir1, targetNotReached_Dir1);
                        end

                    elseif Data{movementNumb}.MovementDirection == 2 % Direction 2

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir2_Color;
                        if targetReached == 1
                            targetReached_Dir2      =   targetReached_Dir2 + 1;
                            PlotRealTrajectories(hAx_Dir2, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, targetPosition, targetReached_Dir2, targetNotReached_Dir2, targetPosition);
                        else
                            targetNotReached_Dir2      =   targetNotReached_Dir2 + 1;
                            PlotRealTrajectories(hAx_Dir2, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir2, targetNotReached_Dir2);
                        end
                    elseif Data{movementNumb}.MovementDirection == 3 % Direction 3

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir3_Color;
                        if targetReached == 1
                            targetReached_Dir3      =   targetReached_Dir3 + 1;
                            PlotRealTrajectories(hAx_Dir3, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir3, targetNotReached_Dir3, targetPosition);
                        else
                            targetNotReached_Dir3      =   targetNotReached_Dir3 + 1;
                            PlotRealTrajectories(hAx_Dir3, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir3, targetNotReached_Dir3);
                        end
                    end

                else   % Unpracticed directions


                    if Data{movementNumb}.MovementDirection == 4 % Direction 4

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       =   dir4_Color;
                        if targetReached == 1
                            targetReached_Dir4      =   targetReached_Dir4 + 1;
                            PlotRealTrajectories(hAx_Dir4, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir4, targetNotReached_Dir4, targetPosition);
                        else
                            targetNotReached_Dir4   =   targetNotReached_Dir0 + 1;
                            PlotRealTrajectories(hAx_Dir4, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir4, targetNotReached_Dir4);
                        end

                    elseif Data{movementNumb}.MovementDirection == 5 % Direction 5

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir5_Color;
                        if targetReached == 1
                            targetReached_Dir5      =   targetReached_Dir5 + 1;
                            PlotRealTrajectories(hAx_Dir5, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir5, targetNotReached_Dir5, targetPosition);
                        else
                            targetNotReached_Dir5      =   targetNotReached_Dir5 + 1;
                            PlotRealTrajectories(hAx_Dir5, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir5, targetNotReached_Dir5);
                        end

                    elseif Data{movementNumb}.MovementDirection == 6 % Direction 6

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir6_Color;
                        if targetReached == 1
                            targetReached_Dir6      =   targetReached_Dir6 + 1;
                            PlotRealTrajectories(hAx_Dir6, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, targetPosition, targetReached_Dir6, targetNotReached_Dir6, targetPosition);
                        else
                            targetNotReached_Dir6      =   targetNotReached_Dir6 + 1;
                            PlotRealTrajectories(hAx_Dir6, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir6, targetNotReached_Dir6);
                        end
                    elseif Data{movementNumb}.MovementDirection == 7 % Direction 7

                        % disp(movementNumb + " " + treatmentVisit(visitIndex) + " " + Data{movementNumb}.MovementDirection);
                        color       = dir7_Color;
                        if targetReached == 1
                            targetReached_Dir7      =   targetReached_Dir7 + 1;
                            PlotRealTrajectories(hAx_Dir7, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir7, targetNotReached_Dir7, targetPosition);
                        else
                            targetNotReached_Dir7      =   targetNotReached_Dir7 + 1;
                            PlotRealTrajectories(hAx_Dir7, GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumb)), color, phaseToPlot, groupNumber, targetReached_Dir7, targetNotReached_Dir7);
                        end
                    end


                end


            end


        end

        if Data{movementNumb}.MovementDirection < 4 && targetNumber > 15
            PlotTargetIn3D(hAx_Dir0, targetsList);
            PlotTargetIn3D(hAx_Dir1, targetsList);
            PlotTargetIn3D(hAx_Dir2, targetsList);
            PlotTargetIn3D(hAx_Dir3, targetsList);
            targetNumber = 1;
        elseif Data{movementNumb}.MovementDirection > 4 && targetNumber > 10
            targetsList(~any(targetsList,2),:) = [];
            PlotTargetIn3D(hAx_Dir4, targetsList);
            PlotTargetIn3D(hAx_Dir5, targetsList);
            PlotTargetIn3D(hAx_Dir6, targetsList);
            PlotTargetIn3D(hAx_Dir7, targetsList);
            targetNumber = 1;
        end

        % if targetNumber == 16
        %     for surfCount = 1:length(surfAxisObject_Dir0)
        %         uistack(surfAxisObject_Dir0(surfCount), 'top');
        %         uistack(surfAxisObject_Dir1(surfCount), 'top');
        %         uistack(surfAxisObject_Dir2(surfCount), 'top');
        %         uistack(surfAxisObject_Dir3(surfCount), 'top');
        %     end
        % end

        % titleText = ['\fontsize{', num2str(titleSize), '}', treatmentVisit(index), '\fontsize{', num2str(titleSize), '}', '\newline']; % ' Improvement Area : ', num2str(areaBetweenLines, '%.3f')];



        if (visitIndex == 1)
            if Data{movementNumb}.MovementDirection < 4
                mainAxPosition = get(hAx_Dir0, 'Position');
            else
                mainAxPosition = get(hAx_Dir4, 'Position');
            end

            % Define the inset 1 position
            insetAx_Position = [mainAxPosition(1) + mainAxPosition(3) - 0.1, ...   % X post
                mainAxPosition(2) + mainAxPosition(4) * -0.5, ...                   % Y pos
                mainAxPosition(3) * 0.3, ...                                        % Width
                mainAxPosition(4) * 0.3];                                           % Height

            % Create a new inset axis
            insetAx = axes('Position', insetAx_Position);
            PlotProtocolTargets(insetAx, [-0.17, 25]);


            % % --- Lock positions before linking ---
            % hAx.ActivePositionProperty = 'position';
            % insetAx.ActivePositionProperty = 'position';

            % --- Link only camera properties ---
            if Data{movementNumb}.MovementDirection < 4
                hlink = linkprop([hAx_Dir0 insetAx], {'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle'});
            else
                hlink = linkprop([hAx_Dir4 insetAx], {'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraViewAngle'});
            end

        %     setappdata(hAx, 'CameraLink', hlink);
        % 
        %     % --- Restore positions (prevents subplot resizing) ---
        %     hAx.Position = hAxPos;
        %     insetAx.Position = insetPos;
        end



    end

    % --- Make all tiles uniform in size ---
    allAxes = findall(gcf, 'Type', 'axes');

    % Remove titles and colorbars from position calculations
    axMain = allAxes(~ismember(get(allAxes,'Tag'), {'Colorbar','legend'}));

    % Normalize the position of all axes
    for i = 1:numel(axMain)
        axMain(i).ActivePositionProperty = 'outerposition';
        axis(axMain(i), 'equal');
        axis(axMain(i), 'off');
        box(axMain(i), 'off');
    end


    % Add a single large title above the tiled layout
    sgt = sgtitle(hAxTiled, "Subject: " + subjectsList + " - Treatment Visit: " + treatmentVisit);

    % Adjust appearance if needed
    sgt.FontSize = 40;
    sgt.FontWeight = 'bold';
    sgt.Interpreter = 'none'; % or 'tex' / 'latex' as needed


    cd(initialFolder);

end




    %% 
%     figRobot = figure(5); % full screen figure
%     % set(figRobot, 'WindowState', 'maximized');
%     % set(fig, 'Color', 'none'); % white background
%     hAxTiledRobotic = tiledlayout(1, 1, 'TileSpacing','tight','Padding','compact');
% 
%     hAx_Dir0_Robotic    =   nexttile(hAxTiledRobotic, 1);
% 
% for movementNumbRoboticSim = [movementNumbExperimentPhases]'
% 
%     if Data{movementNumbRoboticSim}.MovementDirection == 0 % Direction 0
%         time = cumsum(GlobalTime.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumbRoboticSim)));
%         globalPosRobot = GlobalPosition.(matlab.lang.makeValidName(subjectsList(count))).(treatmentVisit(visitIndex)).(sprintf('movement_%d', movementNumbRoboticSim));
%         simpleRoboticArm([globalPosRobot(:,1), globalPosRobot(:,3), globalPosRobot(:,2)], time, false, hAx_Dir0_Robotic, targetsList);
%     end
% 
% end




%% functions




function [] = PlotRealTrajectories(axisObject, globalPosition, color, visitIndexName, groupNumber, realTargetReached, realTargetNotReached, positionOfTheTarget)

trajectoryLineWidth     =   3;
titleSize               =   20;

plot3(axisObject, globalPosition(:,1), globalPosition(:,3), globalPosition(:,2), '.-', 'LineWidth', trajectoryLineWidth, 'Color', color);
axis equal;
axis(axisObject, 'equal');
set(axisObject, 'Box', 'off');
axis(axisObject, 'off');
view(axisObject, -0.17, 17.7);

if nargin > 7

    sphereRadius    =   0.011;
    [Xs, Ys, Zs]   =   sphere(50);
    X = sphereRadius * Xs + positionOfTheTarget(1);
    Y = sphereRadius * Ys + positionOfTheTarget(3);
    Z = sphereRadius * Zs + positionOfTheTarget(2);
    C = 0.3*Xs + 0.5*Ys + 0.8*Zs;
    surf(axisObject, X, Y, Z, C, 'FaceAlpha', 0.8, 'EdgeColor',[0 0.6 0]);
    % n = 256;
    % green = [0 1 0];
    % yellow = [1 1 0];
    % cmap = [linspace(green(1), yellow(1), n)', ...
    %     linspace(green(2), yellow(2), n)', ...
    %     linspace(green(3), yellow(3), n)'];
    % colormap(axisObject, cmap);

end

% % Change target size to create a proportion effect
% if (startPosition(3) > 0.56)
%     sphereRadius = sphereRadiusTiny;
% elseif (startPosition(3) > 0.5 && startPosition(3) < 0.56)
%     sphereRadius = sphereRadiusSmall;
% elseif (startPosition(3) > 0.43 && startPosition(3) < 0.5)
%     sphereRadius = sphereRadiusStandard;
% else
%     sphereRadius = sphereRadiusBig;
% end
% 
% [Xs, Ys, Zs]   =   sphere(50);
% X = sphereRadius * Xs + startPosition(1);
% Y = sphereRadius * Ys + startPosition(3);
% Z = sphereRadius * Zs + startPosition(2);
% C = 0.3*Xs + 0.5*Ys + 0.8*Zs;
% surf(axisObject, X, Y, Z, C, 'FaceAlpha', 0.8, 'EdgeColor','none');
% colormap(linspace(0.6, 0.1, 256)' * [1 1 1] );


% if groupNumber == 4
    extraTitle = "";
%     extraTitle  =   "EF";
% else
%     extraTitle = "SHAM";
% end

if nargin > 5
    titleName       =   replace(visitIndexName, '_', ' ');
    totalTargets    =   realTargetReached + realTargetNotReached;
    titleName       =   titleName + " " + extraTitle + " - Success: " + realTargetReached + "/" + totalTargets;
else
    titleName   =   replace(visitIndexName, '_', ' ');
    titleName   =   titleName + " - " + extraTitle;
end
title(axisObject, titleName, 'FontSize', titleSize);

end



function [] = PlotTargetIn3D(axisObjectPlot, listOfTargets)

sphereRadius    =   0.01;
% sphereRadiusSmall       =   0.009;
% sphereRadiusTiny        =   0.008;
% sphereRadiusBig         =   0.011;
% Generate the unit sphere once
[Xs, Ys, Zs] = sphere(50);
C = 0.3*Xs + 0.5*Ys + 0.8*Zs; % Same color pattern for all spheres

% Loop over each start position
for i = 1:size(listOfTargets, 1)
    targetPosition = listOfTargets(i, :);

    % Shift sphere to correct location
    X = sphereRadius * Xs + targetPosition(1);
    Y = sphereRadius * Ys + targetPosition(3); % note: y corresponds to 2nd column
    Z = sphereRadius * Zs + targetPosition(2);

    set(gcf, 'Renderer', 'opengl');
    % Plot sphere in the specified axis
    surf(axisObjectPlot, X, Y, Z, C, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
    colormap(linspace(0.6, 0.1, 256)' * [1 1 1] );
    hold(axisObjectPlot, 'on');
end

end





% function RoboticTrajectorySimulation(axObject, globalPosition, time)
% 
% 
% robot   =   rigidBodyTree('DataFormat', 'column', 'MaxNumBodies', 3);
% 
% L1 = 0.65; % Length of vertical link
% L2 = 0.43; % Length of perpendicular link
% 
% h = 0.05; % length of the offset for the tool tip
% 
% % link1 body with joint1 joint
% body = rigidBody('link1');
% joint = rigidBodyJoint('joint1', 'revolute');
% setFixedTransform(joint,trvec2tform([0 0 0]));
% joint.JointAxis = [0 0 1];
% body.Joint = joint;
% addBody(robot, body, 'base');
% 
% % link2 body with joint2 joint
% body = rigidBody('link2');
% joint = rigidBodyJoint('joint2','revolute');
% setFixedTransform(joint, trvec2tform([L1,0,0]));
% joint.JointAxis = [0 0 1];
% body.Joint = joint;
% addBody(robot, body, 'link1');
% 
% % tool end effector with fix1 fixed joint
% body = rigidBody('tool');
% joint = rigidBodyJoint('fix1','fixed');
% setFixedTransform(joint, trvec2tform([L2, 0, 0]));
% body.Joint = joint;
% 
% % define reference frame
% body.addFrame('toolTip','tool',trvec2tform([h,0,0]));
% 
% % Add a visual for the 'toolTip' frame on the 'tool' rigid body.
% exampleHelperAddFrameVisual(body,"toolTip")
% addBody(robot, body, 'link2');
% 
% 
% % trajectory
% freq                        =  10; % Hz
% timeSteps                   =  freq*time(end);
% timeQ                       =  0:1/freq:timeSteps;
% interpolatedGlobalPosition  =  interp1(time, globalPosition, timeQ);
% interpolatedGlobalPosition  =  rmmissing(interpolatedGlobalPosition);
% interpolatedGlobalPosition  =  interpolatedGlobalPosition;
% 
% % Use an inverseKinematics object to find a solution of robotic configurations that achieve the given end-effector positions along the trajectory.
% % Pre-allocate configuration solutions as a matrix qs.
% q0 = homeConfiguration(robot);
% ndof = length(q0);
% qs = zeros(count, ndof);
% 
% % inverse kinematics
% ik = inverseKinematics('RigidBodyTree', robot);
% weights = [0, 0, 0, 1, 1, 0];
% endEffector = 'toolTip';
% 
% qInitial = q0; % Use home configuration as the initial guess
% for i = 1:count
%     % Solve for the configuration satisfying the desired end effector
%     % position
%     point = points(i,:);
%     qSol = ik(endEffector,trvec2tform(point),weights,qInitial);
%     % Store the configuration
%     qs(i,:) = qSol;
%     % Start from prior solution
%     qInitial = qSol;
% end
% 
% figure(2)
% show(robot,qs(1,:)');
% view(2)
% ax = gca;
% ax.Projection = 'orthographic';
% hold on
% plot(points(:,1),points(:,2))
% axis([-0.1 0.7 -0.3 0.5 -0.2 0.2])
% end



function simpleRoboticArm(positions, timeVec, isRightHanded, inputAx, listOfTargets)
% simpleRoboticArm - Animates a simple 2-link robotic arm following a 3D path
%
% Inputs:
%   positions      - Nx3 matrix of [x, y, z] positions for the end-effector
%   timeVec        - Nx1 vector of corresponding time stamps
%   isRightHanded  - true for right-handed arm, false for left-handed arm
%
% Example:
%   t = linspace(0,5,100)';
%   path = [0.3*sin(t) 0.3*cos(t) 0.2*sin(2*t)];
%   simpleRoboticArm(path, t, true);

    % --- Basic checks ---
    if size(positions,2) ~= 3
        error('positions must be an Nx3 matrix [x y z]');
    end
    if length(timeVec) ~= size(positions,1)
        error('timeVec length must match number of position rows');
    end

    % --- Arm parameters ---
    L1 = 0.65;   % first segment length (m)
    L2 = 0.43;   % second segment length (m)

    % --- Base position depending on handedness ---
    if isRightHanded
        base = [0.15, 0.08, 0.30];
        sideSign = 1;
    else
        base = [-0.15, 0.08, 0.255];
        positions(:,1) = -positions(:,1); % Mirror along X for left-handed
        sideSign = -1;
    end


        % --- Check for provided axes handle ---
    if nargin < 4 || isempty(inputAx) || ~isvalid(inputAx)
        fig = figure(5);
        inputAx = axes('Parent', fig);
        hold(inputAx, 'on');
        axis(inputAx, 'equal');
        set(gca, 'Color', 'none');
        grid(inputAx, 'off');
        xlabel(inputAx, 'X (m)'); ylabel(ax, 'Y (m)'); zlabel(ax, 'Z (m)');
        xlim(inputAx, [-0.6 0.6]); ylim(ax, [-0.2 0.8]); zlim(ax, [0 0.8]);
        view(inputAx, -25, 14);
        title(inputAx, 'Simple 2-Link Robotic Arm with Natural Elbow');
    else
        % If an external axis is provided, just prepare it
        % hold(inputAx, 'on');
        % axis(inputAx, 'equal');
        view(inputAx, -25, 14);
        axis(inputAx, 'equal');
        set(inputAx, 'Box', 'off');
        axis(inputAx, 'off');
    end


    %
    % fig = figure(5);
    % axis equal;
    % grid off;
    % hold on;
    % set(gca, 'Color', 'none');
    % xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    % xlim([-0.6 0.6]); ylim([-0.2 0.8]); zlim([0 0.8]);
    % view(-25,14);
    PlotTargetIn3D(inputAx, listOfTargets);
    % title('Simple 2-Link Robotic Arm with Natural Elbow');

    % --- Animation loop ---
    for i = 1:length(timeVec)
        effector = positions(i,:); % desired end-effector position

        % --- Relative position from base ---
        dx = effector(1) - base(1);
        dz = effector(3) - base(3);
        dy = effector(2) - base(2);

        % --- Planar inverse kinematics (in X-Z plane) ---
        r = sqrt(dx^2 + dz^2);
        r = max(r, 1e-6); % avoid division by zero

        % Law of cosines (elbow angle)
        cosTheta2 = (r^2 - L1^2 - L2^2) / (2*L1*L2);
        cosTheta2 = max(-1, min(1, cosTheta2));
        theta2 = acos(cosTheta2);

        % Shoulder angle
        k1 = L1 + L2*cos(theta2);
        k2 = L2*sin(theta2);
        theta1 = atan2(dz, dx) - atan2(k2, k1);

        % --- Compute 2D XZ joint position ---
        joint1_2D = [base(1) + L1*cos(theta1), base(3) + L1*sin(theta1)];

        % --- 3D elbow Y-position (symmetric outward bend) ---
        % Midway between base and effector, elbow bends outward from body center
        outwardSign = 1;   % default (right-handed)
        if ~isRightHanded
            outwardSign = -1;
        end

        elbowY = base(2) + 0.5*(effector(2) - base(2)) + outwardSign * 0.07;

        % --- Build full joint positions ---
        joint1 = [joint1_2D(1), elbowY, joint1_2D(2)];
        joint2 = effector;

        % --- Plot arm ---
        cla(inputAx);
        plot3(inputAx, ...
            [base(1) joint1(1) joint2(1)], ...
            [base(2) joint1(2) joint2(2)], ...
            [base(3) joint1(3) joint2(3)], ...
            'o-', 'LineWidth', 2);
        drawnow;

        % --- Timing control ---
        if i > 1
            pause(max(0, timeVec(i) - timeVec(i-1)));
        end
    end


end









