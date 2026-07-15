%% BRUNO - plot of all the movements - Bruno Borghi
% Load the .mat file of the experiment visit you want to read and look and
% then run this program. Choose the index range in the for loop, to
% identify the trials you want to plot




%% Overall plot


%  Data = Data6;  % overwrite on Data the subject you want
% 
% folder      =  cd;
% mkdir AllMovementsForcePlot;
% folderName  =  strcat(folder,'/AllMovementsForcePlot');

% phaseBeginTrials      =  [1, 33, 65, 81, 241, 497, 513, 529, 545];
% badErrorFields        =  [246, 248, 249, 253, 254, 256, 257, 259, 262, 263, 267, 276, 287, 288, 294, 309, 317, 319, 346, 347, 349, 351, 352, 365, 369, 370, 377, 379, 380, 384, 389, 395, 403, 404, 410, 412, 413, 416, 417, 421, 422, 425, 445, 452, 453, 459, 488, 489, 492];
% badErrorFields        =  [251, 254, 261, 277, 340, 352, 412, 447];
% badDataSampling       =  [118, 134, 158, 181, 182, 200, 259, 302, 325, 339, 348, 404, 421];
% letseeNewLaunch       =  [273, 275, 320, 321, 323, 329, 336, 339, 344, 345, 491];
global Data PhaseTracking
countTracker = [];
singlePlot = 1;
% PhaseTracking  =  cell(2,1);
% PhaseTracking{2,1}  =  241;  % use 8 to avoid first 8 movements (trash)

% indexesToAnalyze = Results.E_38.Visit7.Trials;
indexesToAnalyze = SpecialMovementIndex.IntermittentExposure.DirectionOne;

% for index = 58:length(Data)
for index = [indexesToAnalyze]'
    
    % movementNumb = Data{index,:}.MovementNumber;
    movementNumb  =  index;
        if (singlePlot == 0)
            countTracker  =  [countTracker, index];
            pos           =  length(countTracker);
            if (pos > 3)
                InspectIndividualTrial([countTracker(pos-2), countTracker(pos-1), countTracker(pos)],'m');
                hold on
                %     set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
                %     figureName   =  strcat('PEF_6_#', num2str(count));
                %     pictureName  =  fullfile(folderName, figureName);
                %     saveas(gcf, pictureName, 'jpg');

                pause;
                clf
            end
        else
            InspectIndividualTrial(movementNumb,'m');
            hold on
            pause;
            clf
        end
    
%     line of code for 
%     for t=242:496,figure(3); clf; InspectIndividualTrial(t,unit, Data); figure(1), clf, Plot3DTrajectory(t,unit,Data), pause; end
%
    
end
    





%% Animation plot



global Data PhaseTracking
singlePlot = 1;
fig = figure('Color','white', 'WindowState','maximized');   % create figure FIRST


% Starts at least from movement number 3
for index = 270:length(Data)


    try
        movementNumb = index;

        fig = GlobalFramePlotMovie(movementNumb, 30, [], [], [], [], [], [], fig);

    catch ME
        fprintf('Skipping movement %d error: %s\n', movementNumb, ME.message);
        continue;   % go to next movement
    end

    
end
    

