%% BRUNO BORGHI - SpeedAccuracyCupolasSubplot

function [hAx, insetAx1, insetAx2, speedRangeBaseline, baselineFitLine, areaBetweenLines] = SpeedAccuracyCupolasSubplotMinimal(x, y, rowNumber, colNumber, subplotNumber, Title, xLabel, yLabel, xLines, colorNumb, scatterStyle, regressionLinesOn, Legend, position_Dir0, position_Dir1, position_Dir2, position_Dir3, idealTraj0, idealTraj1, idealTraj2, idealTraj3, std_Dir0, std_Dir1, std_Dir2, std_Dir3, xLimits, yLimits, hAxes, insetAxes1, insetAxes2, firstRegressionLineX, firstRegressionLineY)

colors              =   lines(rowNumber+colNumber); % built-in colormap with distinct colors
colori              =   [[0.1 0.5470 0.5410]; [0.4350 0.1780 0.0840]; [0.9290 0.6940 0.8250]; [0.15 0.15 0.15]]; % Green, Red, Yellow, Black colors
titleSize           =   40;
scatterSize         =   350;
dotEdgeColor        =   [1 1 1];  % thin white ring drawn on each dot so overlapping points stay separable
dotEdgeWidth        =   1;        % set dotEdgeWidth = 0 (or dotEdgeColor = 'none') to go back to edgeless dots
transparencyAlpha   =   1;
rosePlotSize        =   3;
noRosePlot          =   1;
speedFeedbackRange  =   xLines; % speed feddback range given to the subject during the experiment
plot3D              =   'false';
areaCalculatedOnFullRangeSpeed = 1;  % Change this to 1 if you want to calculate the Improvement Area between the full speed range, or 0 if you want only the speedFeedback range
% SpeedThresholdHigh  =   0.4348;   % Neurotypical highspeed threshold
% SpeedThresholdLow   =   0.2766;   % Neurotypical lowspeed threshold
% speedFeedback   =   [0.1976, 0.5138];

% temporary colors for the paper ICRA 2026
if nargin > 9 && ~isempty(colorNumb)
    if (colorNumb == 1)
        colors = [0.55 0.27 0.68]; % PURPLE
    elseif (colorNumb == 2)
        colors = [0.00 0.45 0.74]; % BLUE
    elseif (colorNumb == 3)
        colors = [0.00 0.60 0.30]; % GREEN
    elseif (colorNumb == 4)
        colors = [0.85 0.33 0.55]; % PINK
    elseif (colorNumb == 5)
        colors = [0.6350 0.0780 0.1840]; % BORDEAUX
    elseif (colorNumb == 6)
        colors = [0.9290 0.6940 0.1250]; % YELLOW
    else
        colors = [1, 1, 1];
    end
end

% if nargin > 9  &&  ~isempty(colorNumb)
%     if (colorNumb == 1)
%         % colors = colors(1, :);
%         colors = [0 0.3 0.6];            % not black anymore but lavander
%     elseif (colorNumb == 2)
%         % colors = colors(2, :);
%         colors = [0.6350 0.0780 0.1840]; % not red anymore but brown
%     elseif (colorNumb == 3)
%         colors = colors(3, :);
%     elseif (colorNumb == 4)
%         colors = colors(4, :);
%     elseif (colorNumb == 0)
%         colors = [0.2 0.2 0.2];
%         transparencyAlpha = 0.01;
%     end
% end


% redColor    =   [0.6350 0.0780 0.1840]; % not red anymore but brown
% blackColor  =   [0 0.3 0.6];            % not black anymore but lavander

if nargin < 13
    Legend = [];
end

if nargin < 12
    regressionLinesOn = 0;
end

% % remove NaN
finiteIndexes_Baseline  =   isfinite(y);
y                       =   y(finiteIndexes_Baseline);
x                       =   x(finiteIndexes_Baseline);  

% % remove outliers
% data = [x(:), y(:)];   % combine into a matrix (n-by-2)
% 
% % Compute Mahalanobis distance
% mu = mean(data);
% Sigma = cov(data);
% d = mahal(data, data);   % squared Mahalanobis distance
% 
% % Choose a threshold (e.g., chi-square with 2 DOF at 0.975 quantile)
% threshold = chi2inv(0.975, 2); 
% 
% % Keep only inliers
% inliers = d < threshold;
% 
% x = x(inliers);
% y = y(inliers);

% Logarithmic scale
y       = log(1./y);
% y = 1./y;

if(nargin >= 26)
    % yLimits = sort(log(1./yLimits));
    yLimits = sort(real(log(1./yLimits)));
end
% y   =   1./y;

% Perform linear regression on combined Baseline data
baselineCoeff           =   polyfit(x, y, 1);

% Define the range of speeds for plotting the fit line
speedRangeBaseline      =   linspace(min(x), max(x), 100);

% Evaluate the linear fit across the speed range
baselineFitLine         =   polyval(baselineCoeff, speedRangeBaseline);



% Plot the dots
if (nargin < 28)
    hAx = subplot(rowNumber, colNumber, subplotNumber);
else
    hAx = hAxes;
    insetAx1 = insetAxes1;
    insetAx2 = insetAxes2;
end



if nargin > 28 && ~isempty(xLines)
    % Call the function
    plotSpeedLines(hAx, xLines, [xLimits(1), yLimits(2)], {'slow','fast'});
    % xl = xline(hAx, xLines, '--');
    % plot3(hAx, (xLines(1)*ones(1, 10)), (linspace(0, 5, 10)), zeros(1, 10), '--', 'LineWidth', 3, 'Color', [0, 0, 0]);
    % hold on;
    % plot3(hAx, (xLines(2)*ones(1, 10)), (linspace(0, 5, 10)), zeros(1, 10), '--', 'LineWidth', 3, 'Color', [0 0 0]);
end


% if ~strcmp(scatterStyle, 'filled')

if (nargin > 28)
    % post evaluation
    
    %         if (colorNumb ~= 0)
    %             hcircle = scatter3(hAx, x, y, zeros(size(x)), scatterSize + 75, 'o', 'markerfacecolor', 'none', 'markeredgecolor', [1 1 1], 'markerfacealpha', 0.8, 'linewidth', 1);   % white contour (slightly larger marker) controls white border thickness
    %             uistack(hcircle, 'top');  % bring to top layer
    %         end
    % White border (slightly larger marker)
    % if strcmp(plot3D, 'true')
    %     hBorder = scatter3(hAx, x, y, zeros(size(x)), scatterSize+5, scatterStyle, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerEdgeAlpha', transparencyAlpha, 'MarkerFaceAlpha', transparencyAlpha);
    % else
    %     hBorder = scatter(hAx, x, y, scatterSize+5, scatterStyle, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerEdgeAlpha', transparencyAlpha, 'MarkerFaceAlpha', transparencyAlpha);
    % end

    hold(hAx, 'on');

    if strcmp(plot3D, 'true')
        % Actual colored dots (on top)
        hScatter = scatter3(hAx, x, y, zeros(size(x)), scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', dotEdgeColor, 'LineWidth', dotEdgeWidth, 'MarkerFaceAlpha', transparencyAlpha);
        % hscatter = scatter3(hAx, x, y, zeros(size(x)), scatterSize, scatterStyle, 'markerfacecolor', colors, 'markeredgecolor', 'none', 'markerfacealpha', transparencyAlpha);

        if (colorNumb ~= 0)
            if (nargin >= 26)
                % === Histogram Inset ===
                plotCopula3D(hAx, x, y, colors, 'false', xLimits, yLimits);
            else
                plotCopula3D(hAx, x, y, colors, 'false');
            end
        end
    else
        hScatter = scatter(hAx, x, y, scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', dotEdgeColor, 'LineWidth', dotEdgeWidth, 'MarkerFaceAlpha', transparencyAlpha);
    end

else % never runs through this
    % if strcmp(plot3D, 'true')
    %     hBorder = scatter3(hAx, x, y, zeros(size(x)), scatterSize+5, scatterStyle, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerEdgeAlpha', transparencyAlpha, 'MarkerFaceAlpha', transparencyAlpha);
    % else
    %     hBorder = scatter(hAx, x, y, scatterSize+5, scatterStyle, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerEdgeAlpha', transparencyAlpha, 'MarkerFaceAlpha', transparencyAlpha);
    % end

    hold(hAx, 'on');

    if strcmp(plot3D, 'true')
        % Actual colored dots (on top)
        hScatter = scatter3(hAx, x, y, zeros(size(x)), scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', dotEdgeColor, 'LineWidth', dotEdgeWidth, 'MarkerFaceAlpha', transparencyAlpha);
        %         if (colorNumb ~= 0)
        %             hcircle = scatter3(x, y, zeros(size(x)), scatterSize + 5, 'o', 'markerfacecolor', 'none', 'markeredgecolor', [1 1 1], 'linewidth', 3);   % white contour (slightly larger marker) controls white border thickness
        %             uistack(hcircle, 'top');  % bring to top layer
        %         end
        if (colorNumb ~= 0)
            if (nargin >= 26)
                % === Histogram Inset ===
                plotCopula3D(hAx, x, y, colors, 'false', xLimits, yLimits);
            else
                plotCopula3D(hAx, x, y, colors, 'false');
            end
            % view(-41.2, 20);
            view(-41.5, 46);
        end
    else
        hScatter = scatter(hAx, x, y, scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', dotEdgeColor, 'LineWidth', dotEdgeWidth, 'MarkerFaceAlpha', transparencyAlpha);
    end
end
hold on;
% else
%     if (nargin > 22)
%         % baseline
%         if (colorNumb ~= 0)
%             scatter3(hAx, x, y, zeros(size(x)), scatterSize + 16, 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [1 1 1], 'LineWidth', 3);   % White contour (slightly larger marker) controls white border thickness
%         end
%         hScatter = scatter3(hAx, x, y, zeros(size(x)), scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', transparencyAlpha);
% 
%         if (colorNumb ~= 0)
%             % === Histogram Inset ===
%             plotCopula3D(hAx, x, y, colors);
% 
%         end
%     else
%         hScatter = scatter3(x, y, zeros(size(x)), scatterSize, scatterStyle, 'MarkerFaceColor', colors, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', transparencyAlpha);
%         hold on;
%         if (colorNumb ~= 0)
%             hCircle = scatter3(x, y, zeros(size(x)), scatterSize + 10, 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1);   % White contour (slightly larger marker) controls white border thickness
%             uistack(hCircle, 'top');  % bring to top layer
%         end
% 
%         if (colorNumb ~= 0)
%             % === Histogram Inset ===
%             plotCopula3D(hAx, x, y, colors);
% 
%         end
%     endii
%     hold on;
if (regressionLinesOn == 1)
    if (nargin > 28) % you already plotted a line
        % plot(hAx, speedRangeBaseline, baselineFitLine, '-', 'Color', 'k', 'LineWidth', 6);  % Slightly thicker black background line
        % hold on;
        plot(hAx, speedRangeBaseline, baselineFitLine, '-', 'Color', [colors, 1], 'LineWidth', 7, 'DisplayName', 'Baseline Fit');
        if (nargin>28)
            areaBetweenLines = ComputeSignedAreaBetweenLines(firstRegressionLineX, firstRegressionLineY, speedRangeBaseline, baselineFitLine, hAx, 0, speedFeedbackRange, areaCalculatedOnFullRangeSpeed);
        end


    else
        % Plot the regression lines
        % plot(speedRangeBaseline, baselineFitLine, '-', 'Color', 'k', 'LineWidth', 6);  % Slightly thicker black background line
        % hold on;
        plot(speedRangeBaseline, baselineFitLine, '-', 'Color', [colors, 1], 'LineWidth', 7, 'DisplayName', 'Baseline Fit');
    end
end
% end
set(gca, 'Color', 'none');
set(gca, 'LineWidth', 3, 'FontSize', 20, 'FontWeight', 'bold');
set(gca, 'ZColor', 'none');

if (nargin >= 26)
    set(hAx, 'XLim', xLimits);
    set(hAx, 'YLim', yLimits);
end

% set(gca, 'TickLength', [1, 1]);
% set(gca, 'ZAxis', [0, 0]);
% set(gca, 'YTick', []);
grid off;
% set(gca, 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on'); % initially turn on all grids

% set(gca, 'ZGrid', 'on');               % keep Z grid logically on
% set(gca, 'GridColorMode', 'manual');
% set(gca, 'GridAlpha', 0.0);            % makes all grid lines fully transparent
% set(gca, 'XGrid', 'on', 'YGrid', 'on'); % re-enable x and y after hiding all
% set(gca, 'GridColor', [0 0 0]);
% grid minor;
% set(gca, 'ZGrid', 'off');              % disables z-grid only
% ax = gca;
% grid(ax,'off');
% set(ax,'XGrid','on','YGrid','on','ZGrid','off', 'XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off');
% ax.Box = 'off';           % removes the 3D box edges
% ax.BoxStyle = 'back';   % (optional) show only back edges if you later set Box on







if (nargin>5)
    if (nargin>28)
        titleText = ['\fontsize{', num2str(titleSize+10), '}', Title, '\fontsize{', num2str(titleSize), '}', '\newline', ' Improvement Area : ', num2str(areaBetweenLines, '%.3f')];
        title(hAx, titleText, 'Interpreter', 'tex');
    else
        title(hAx, Title, 'FontSize', titleSize+10);
    end
    
    xlabel(hAx, [xLabel ' [m/s]'], 'FontSize', titleSize);
    ylabel(hAx, [yLabel ' [1/m]'], 'FontSize', titleSize);
end

% Only include this in legend if Legend string is not empty
if (nargin>12 && ~isempty(Legend))

    % if (nargin < 22)
    % if strcmp(Legend, 'Pre Training') || strcmp(Legend, 'Baseline')
        % text(hAx, mean(x) + 0.2, mean(y) - 3, Legend, 'Color', colors, 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
        % Interpreter 'none': the label is now a visit name such as 'Visit_2', and the
        % default tex interpreter would swallow the underscore into a subscript.
        text(hAx, 0.35, 2.8+(rand), 3.2, Legend, 'Color', colors, 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Interpreter', 'none');
    % else
    %     % text(hAx, mean(x) - 0.1, mean(y) - 5, Legend, 'Color', colors, 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    %     text(hAx, 0.35, 4, 2.5, Legend, 'Color', colors, 'FontSize', 20, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
    % end

   
end



if (nargin > 14)

    % Optional input: insetAx
    if (nargin > 28)  % Assuming insetAx is the 16th argument
        hold(insetAxes1, 'on');
        hold(insetAxes2, 'on');
    else
        % Get the position of the current subplot axis
        mainAxPosition = get(hAx, 'Position');

        % Define the inset 1 position
        insetAx1_Position = [mainAxPosition(1) + mainAxPosition(3) * 0.85, ... % X post
            mainAxPosition(2) + mainAxPosition(4) * 0.6, ...               % Y pos
            mainAxPosition(3) * 0.4, ...                                    % Width
            mainAxPosition(4) * 0.4];                                       % Height
        
        % % Create a new inset axis
        insetAx1 = axes('Position', insetAx1_Position);
        hold(insetAx1, 'on');
        
        % Create a new figure
        % fig2 = figure(2);
        % hold on;
        % insetAx1 = subplot(1, 2, 1);

        if (noRosePlot == 1)
            axis(insetAx1, 'off');   % turns off all axis visuals
        end

        % Define the inset 2 position
        insetAx2_Position = [mainAxPosition(1) + mainAxPosition(3) * 0.8, ... % X post
            mainAxPosition(2) + mainAxPosition(4) * 0.2, ...               % Y pos
            mainAxPosition(3) * 0.4, ...                                    % Width
            mainAxPosition(4) * 0.4];                                       % Height

        % % Create a new inset axis
        insetAx2 = axes('Position', insetAx2_Position);
        hold(insetAx2, 'on');
        % insetAx2 = subplot(1, 2, 2);

        if (noRosePlot == 1)
            axis(insetAx2, 'off');   % turns off all axis visuals
        end


    end

    % if strcmp(scatterStyle, 'filled') % Baseline
        %%%%%%%%%%%%%%%%% INSET 1

        % % Get the standard deviations out
        % [~, ~, ~, std_X_Dir0, std_Y_Dir0, std_Z_Dir0, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2));
        % [~, ~, ~, std_X_Dir1, std_Y_Dir1, std_Z_Dir1, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2));
        % [~, ~, ~, std_X_Dir2, std_Y_Dir2, std_Z_Dir2, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2));
        % [~, ~, ~, std_X_Dir3, std_Y_Dir3, std_Z_Dir3, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2));

        if (noRosePlot == 0)
        [x_patch_Dir0, y_patch_Dir0, z_patch_Dir0]              =   RosePlotShadedPatches(position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), std_Dir0(:,1), std_Dir0(:,3), std_Dir0(:,2));
        patch(insetAx1, x_patch_Dir0, y_patch_Dir0, z_patch_Dir0, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir1, y_patch_Dir1, z_patch_Dir1]              =   RosePlotShadedPatches(position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), std_Dir1(:,1), std_Dir1(:,3), std_Dir1(:,2));
        patch(insetAx1, x_patch_Dir1, y_patch_Dir1, z_patch_Dir1, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir2, y_patch_Dir2, z_patch_Dir2]              =   RosePlotShadedPatches(position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), std_Dir2(:,1), std_Dir2(:,3), std_Dir2(:,2));
        patch(insetAx1, x_patch_Dir2, y_patch_Dir2, z_patch_Dir2, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir3, y_patch_Dir3, z_patch_Dir3]              =   RosePlotShadedPatches(position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), std_Dir3(:,1), std_Dir3(:,3), std_Dir3(:,2));
        patch(insetAx1, x_patch_Dir3, y_patch_Dir3, z_patch_Dir3, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');


        % background color

        % plot3(insetAx1, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx1, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx1, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx1, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);

        % Actual colored trajectories

        plot3(insetAx1, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '-', 'Color', colori(1,:), 'LineWidth', rosePlotSize);
        plot3(insetAx1, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '-', 'Color', colori(2,:), 'LineWidth', rosePlotSize);
        plot3(insetAx1, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '-', 'Color', colori(3,:), 'LineWidth', rosePlotSize);
        plot3(insetAx1, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '-', 'Color', colori(4,:), 'LineWidth', rosePlotSize);

        
        %%%%%%%%%%%%%%%%% INSET 2

        % % Get the standard deviations out
        % [~, ~, ~, std_X_Dir0, std_Y_Dir0, std_Z_Dir0, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2));
        % [~, ~, ~, std_X_Dir1, std_Y_Dir1, std_Z_Dir1, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2));
        % [~, ~, ~, std_X_Dir2, std_Y_Dir2, std_Z_Dir2, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2));
        % [~, ~, ~, std_X_Dir3, std_Y_Dir3, std_Z_Dir3, ~, ~, ~]  =   calculateEnsembleForPatches(position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2));

        [x_patch_Dir0, y_patch_Dir0, z_patch_Dir0]              =   RosePlotShadedPatches(position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), std_Dir0(:,1), std_Dir0(:,3), std_Dir0(:,2));
        patch(insetAx2, x_patch_Dir0, y_patch_Dir0, z_patch_Dir0, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir1, y_patch_Dir1, z_patch_Dir1]              =   RosePlotShadedPatches(position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), std_Dir1(:,1), std_Dir1(:,3), std_Dir1(:,2));
        patch(insetAx2, x_patch_Dir1, y_patch_Dir1, z_patch_Dir1, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir2, y_patch_Dir2, z_patch_Dir2]              =   RosePlotShadedPatches(position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), std_Dir2(:,1), std_Dir2(:,3), std_Dir2(:,2));
        patch(insetAx2, x_patch_Dir2, y_patch_Dir2, z_patch_Dir2, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');
        [x_patch_Dir3, y_patch_Dir3, z_patch_Dir3]              =   RosePlotShadedPatches(position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), std_Dir3(:,1), std_Dir3(:,3), std_Dir3(:,2));
        patch(insetAx2, x_patch_Dir3, y_patch_Dir3, z_patch_Dir3, colors, 'FaceAlpha', 0.35, 'EdgeColor', 'none');


        % background color

        % plot3(insetAx2, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx2, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx2, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);
        % plot3(insetAx2, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '-', 'Color', colors, 'LineWidth', rosePlotSize+3);

        % Actual colored trajcetories

        plot3(insetAx2, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '-', 'Color', colori(1,:), 'LineWidth', rosePlotSize);
        plot3(insetAx2, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '-', 'Color', colori(2,:), 'LineWidth', rosePlotSize);
        plot3(insetAx2, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '-', 'Color', colori(3,:), 'LineWidth', rosePlotSize);
        plot3(insetAx2, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '-', 'Color', colori(4,:), 'LineWidth', rosePlotSize);

    % else % Post Evaluation
    %     % Inset 1
    %     plot3(insetAx1, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '--', 'Color', colori(1,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx1, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '--', 'Color', colori(2,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx1, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '--', 'Color', colori(3,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx1, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '--', 'Color', colori(4,:), 'LineWidth', rosePlotSize);
    %     % Inset 2
    %     plot3(insetAx2, position_Dir0(:,1), position_Dir0(:,3), position_Dir0(:,2), '--', 'Color', colori(1,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx2, position_Dir1(:,1), position_Dir1(:,3), position_Dir1(:,2), '--', 'Color', colori(2,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx2, position_Dir2(:,1), position_Dir2(:,3), position_Dir2(:,2), '--', 'Color', colori(3,:), 'LineWidth', rosePlotSize);
    %     plot3(insetAx2, position_Dir3(:,1), position_Dir3(:,3), position_Dir3(:,2), '--', 'Color', colori(4,:), 'LineWidth', rosePlotSize);
    % end


    % Inset 1
    plot3(insetAx1, idealTraj0(:,1), idealTraj0(:,3), idealTraj0(:,2), '-', 'Color', 'k');
    plot3(insetAx1, idealTraj1(:,1), idealTraj1(:,3), idealTraj1(:,2), '-', 'Color', 'k');
    plot3(insetAx1, idealTraj2(:,1), idealTraj2(:,3), idealTraj2(:,2), '-', 'Color', 'k');
    plot3(insetAx1, idealTraj3(:,1), idealTraj3(:,3), idealTraj3(:,2), '-', 'Color', 'k');
    set(insetAx1, 'Color', 'none');
    set(insetAx1, 'XColor', 'none');
    set(insetAx1, 'YColor', 'none');
    set(insetAx1, 'ZColor', 'none');
    % view(26, 50);
    view(insetAx1, 4.68, 43.3);

    % Inset 2
    plot3(insetAx2, idealTraj0(:,1), idealTraj0(:,3), idealTraj0(:,2), '-', 'Color', 'k');
    plot3(insetAx2, idealTraj1(:,1), idealTraj1(:,3), idealTraj1(:,2), '-', 'Color', 'k');
    plot3(insetAx2, idealTraj2(:,1), idealTraj2(:,3), idealTraj2(:,2), '-', 'Color', 'k');
    plot3(insetAx2, idealTraj3(:,1), idealTraj3(:,3), idealTraj3(:,2), '-', 'Color', 'k');
    set(insetAx2, 'Color', 'none');
    set(insetAx2, 'XColor', 'none');
    set(insetAx2, 'YColor', 'none');
    set(insetAx2, 'ZColor', 'none');
    % view(26, 50);
    view(insetAx2, 257, -68);
    end

else
    hAx = [];  % default
    insetAx1 = []; % default
    insetAx2 = [];
end




end




% PLOT CUPOLA 3d
function plotCopula3D(axObject, x, y, color, normalizationFlag, xLimits, yLimits)

% Inputs:
%   axObject - Axes handle to plot into
%   x, y     - Data vectors
%   color    - RGB triplet (e.g., [0.3 0.6 0.8])
%   maxX     - Maximum value to normalize X-marginal (PDF height)
%   maxY     - Maximum value to normalize Y-marginal (PDF height)


% Create figure
% figure;
% hold on;
% grid on;
% box on;

% === 3D scatter ===
% scatter3(axObject, x, y, zeros(size(x)), 8, 'MarkerFaceColor', color);

% === Settings ===
% xOffset = 0.1 * range(y);  % offset histograms below Y
xOffset = 0;
% yOffset = 0.1 * range(x);  % offset histograms left of X
yOffset = 0;
histBins = 20;
kConfidence = sqrt(5.991); % 95% confidence for chi-squared with 2 DOF




% === X histogram (on X-Z at y = min(y) - offset) ===
if strcmp(normalizationFlag, 'true')
    [countsX, edgesX] = histcounts(x, histBins,'Normalization', 'pdf');
else
    [countsX, edgesX] = histcounts(x, histBins); 
end
% countsX = log(1./countsX);
centersX = (edgesX(1:end-1) + edgesX(2:end))/2;
barWidthX = diff(edgesX(1:2));
% yHistX = min(y) - xOffset;
yHistX  = yLimits(2);
% else
%     yHistX = max(y); % it needs the max value of the "accuracy" vector


for i = 1:length(centersX)
    x0 = centersX(i);
    z0 = countsX(i);
    fill3(axObject, [x0-barWidthX/2, x0+barWidthX/2, x0+barWidthX/2, x0-barWidthX/2], [yHistX, yHistX, yHistX, yHistX], [0, 0, z0, z0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    % fill3(axObject, [x0, x0, x0, x0], [yHistX, yHistX, yHistX, yHistX], [0, 0, z0, z0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
end

% x = log(1./x);
if strcmp(normalizationFlag, 'true')
    [xPDF, xVals] = ksdensity(x);
    plot3(axObject, xVals, yHistX * ones(size(xVals)), xPDF, 'Color', color, 'LineWidth', 2);
else
    [xPDF, xVals] = ksdensity(x);
    xPDF = xPDF * length(x) * (edgesX(2) - edgesX(1));  % scale to histogram counts
    plot3(axObject, xVals, yHistX * ones(size(xVals)), xPDF, 'Color', color, 'LineWidth', 2);
end

% === Y histogram (on Y-Z at x = min(x) - offset) ===
if strcmp(normalizationFlag, 'true')
    [countsY, edgesY] = histcounts(y, histBins,'Normalization', 'pdf');
else
    [countsY, edgesY] = histcounts(y, histBins); 
end
% countsY = log(1./countsY);
centersY = (edgesY(1:end-1) + edgesY(2:end))/2;
barWidthY = diff(edgesY(1:2));
% xHistY = min(x) - yOffset;
xHistY = xLimits(2);
% else
%     xHistY = max(x); % This needs the max of "speed" vector
%     % xHistY = 0.55;

for i = 1:length(centersY)
    y0 = centersY(i);
    z0 = countsY(i);
    % fill3(axObject, [xHistY, xHistY, xHistY, xHistY], [y0, y0, y0, y0], [z0, z0, 0, 0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    fill3(axObject, [xHistY, xHistY, xHistY, xHistY], [y0-barWidthY/2, y0+barWidthY/2, y0+barWidthY/2, y0-barWidthY/2], [z0, z0, 0, 0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');

end

if strcmp(normalizationFlag, 'true')
    % y = log(1./y);
    [yPDF, yVals] = ksdensity(y);
    plot3(axObject, xHistY * ones(size(yVals)), yVals, yPDF, 'Color', color, 'LineWidth', 2);
else
    [yPDF, yVals] = ksdensity(y);
    yPDF = yPDF * length(y) * (edgesY(2) - edgesY(1));  % scale to histogram counts
    plot3(axObject, xHistY * ones(size(yVals)),yVals, yPDF, 'Color', color, 'LineWidth', 2);
end
end






% function plotCopula3D(axObject, x, y, color, maxX, maxY)
% % plotCopula3D - Plots 3D scatter, histogram bars, and KDE curves
% % Inputs:
% %   axObject - Axes handle to plot into
% %   x, y     - Data vectors
% %   color    - RGB triplet (e.g., [0.3 0.6 0.8])
% %   maxX     - Maximum value to normalize X-marginal (PDF height)
% %   maxY     - Maximum value to normalize Y-marginal (PDF height)
% 
% hold(axObject, 'on');
% histBins = 20;
% 
% % === X histogram (X-Z plane at constant Y)
% [countsX, edgesX] = histcounts(x, histBins, 'Normalization', 'pdf');
% centersX = (edgesX(1:end-1) + edgesX(2:end)) / 2;
% barWidthX = diff(edgesX(1:2));
% % yHistX = max(y) + 0.1 * range(y);
% yHistX = 5;
% if nargin >= 5 && ~isempty(maxX)
%     countsX = countsX / maxX;
% end
% 
% for i = 1:length(centersX)
%     x0 = centersX(i);
%     z0 = countsX(i);
%     fill3(axObject, [x0 - barWidthX/2, x0 + barWidthX/2, x0 + barWidthX/2, x0 - barWidthX/2], [yHistX, yHistX, yHistX, yHistX], [0, 0, z0, z0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% end
% 
% [xPDF, xVals] = ksdensity(x);
% if nargin >= 5 && ~isempty(maxX)
%     xPDF = xPDF / maxX;
% end
% plot3(axObject, xVals, yHistX * ones(size(xVals)), xPDF, 'Color', color, 'LineWidth', 2);
% 
% % === Y histogram (Y-Z plane at constant X)
% [countsY, edgesY] = histcounts(y, histBins, 'Normalization', 'pdf');
% centersY = (edgesY(1:end-1) + edgesY(2:end)) / 2;
% barWidthY = diff(edgesY(1:2));
% % xHistY = min(x) - 0.1 * range(x);
% xHistY = 0.8;
% if nargin >= 6 && ~isempty(maxY)
%     countsY = countsY / maxY;
% end
% 
% for i = 1:length(centersY)
%     y0 = centersY(i);
%     z0 = countsY(i);
%     fill3(axObject, ...
%         [xHistY, xHistY, xHistY, xHistY], ...
%         [y0 - barWidthY/2, y0 + barWidthY/2, y0 + barWidthY/2, y0 - barWidthY/2], ...
%         [0, 0, z0, z0], color, 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% end
% 
% [yPDF, yVals] = ksdensity(y);
% if nargin >= 6 && ~isempty(maxY)
%     yPDF = yPDF / maxY;
% end
% plot3(axObject, xHistY * ones(size(yVals)), yVals, yPDF, 'Color', color, 'LineWidth', 2);
% 
% % Set view and z limit
% view(axObject, 45, 30);
% grid(axObject, 'on');
% box(axObject, 'on');
% axObject.Clipping = 'off';
% zlim(axObject, [0, 1]);
% 
% end




%% Plot shaded area behing the trajectoires in the rose plots
% It takes in input the trajectory X, Y and Z coordinates,
% and the standard devitations for both coordinates


function [x_patch, y_patch, z_patch] = RosePlotShadedPatches(trajectoryX, trajectoryY, trajectoryZ, stdX, stdY, stdZ)

n = length(trajectoryX);

% Preallocate normals and offset paths
normals =   zeros(n, 3);
upper   =   zeros(n, 3);
lower   =   zeros(n, 3);

if (n <= 1)
    x_patch = 0;
    y_patch = 0;
    z_patch = 0;
else

    for i = 1:n-1
        deltaX = trajectoryX(i+1) - trajectoryX(i);
        deltaY = trajectoryY(i+1) - trajectoryY(i);
        deltaZ = trajectoryZ(i+1) - trajectoryZ(i);
        tangent = [deltaX, deltaY, deltaZ];

        % Compute a normal vector
        normalVec = null(tangent); % Returns an orthonormal basis perpendicular to tangent

        % Choose one normal vector if multiple returned (use first column)
        if ~isempty(normalVec)
            thisNormal = normalVec(:,1);
        else
            thisNormal = [0; 0; 0];
        end

        % Save last valid normal for later
        lastNormal = thisNormal;

        % Store offset points
        normalsX(i) = thisNormal(1);
        normalsY(i) = thisNormal(2);
        normalsZ(i) = thisNormal(3);

        if (i < length(stdX))
            upperX(i) = trajectoryX(i) + stdX(i) * thisNormal(1);
            upperY(i) = trajectoryY(i) + stdY(i) * thisNormal(2);
            upperZ(i) = trajectoryZ(i) + stdZ(i) * thisNormal(3);
            lowerX(i) = trajectoryX(i) - stdX(i) * thisNormal(1);
            lowerY(i) = trajectoryY(i) - stdY(i) * thisNormal(2);
            lowerZ(i) = trajectoryZ(i) - stdZ(i) * thisNormal(3);
        else
            upperX(i) = trajectoryX(i) + stdX(end) * thisNormal(1);
            upperY(i) = trajectoryY(i) + stdY(end) * thisNormal(2);
            upperZ(i) = trajectoryZ(i) + stdZ(end) * thisNormal(3);
            lowerX(i) = trajectoryX(i) - stdX(end) * thisNormal(1);
            lowerY(i) = trajectoryY(i) - stdY(end) * thisNormal(2);
            lowerZ(i) = trajectoryZ(i) - stdZ(end) * thisNormal(3);
        end
    end

% Use last valid normal
offsetEnd = [stdX(end), stdY(end), stdZ(end)] .* lastNormal';
upperX(end) = trajectoryX(end) + offsetEnd(1);
upperY(end) = trajectoryY(end) + offsetEnd(2);
upperZ(end) = trajectoryZ(end) + offsetEnd(3);

lowerX(end) = trajectoryX(end) - offsetEnd(1);
lowerY(end) = trajectoryY(end) - offsetEnd(2);
lowerZ(end) = trajectoryZ(end) - offsetEnd(3);

% Create closed patch
x_patch = [upperX, flipud(lowerX)];
y_patch = [upperY, flipud(lowerY)];
z_patch = [upperZ, flipud(lowerZ)];
end

end



% Function that calculates the mean and standard deviation of two cell arrays (x and y and z)

function [medianX, medianY, medianZ, stdX, stdY, stdZ, errorX, errorY, errorZ] = calculateEnsembleForPatches(allX, allY, allZ)
% allX, allY, allZ should be matrices where each column is a trial
% All inputs must have the same number of rows (i.e., already padded if needed)

% Check that input sizes match
if ~isequal(size(allX), size(allY), size(allZ))
    error('allX, allY, and allZ must have the same size');
end

% Compute median across trials
medianX = median(allX, 2, 'omitnan');
medianY = median(allY, 2, 'omitnan');
medianZ = median(allZ, 2, 'omitnan');

% Standard deviation across trials
stdX = std(allX, 0, 2, 'omitnan');
stdY = std(allY, 0, 2, 'omitnan');
stdZ = std(allZ, 0, 2, 'omitnan');

% Standard error (standard deviation / sqrt(n))
nTrials = size(allX, 2);
errorX = stdX / sqrt(nTrials);
errorY = stdY / sqrt(nTrials);
errorZ = stdZ / sqrt(nTrials);
end


function area = ComputeSignedAreaBetweenLines(vector2_x, vector2_y, vector1_x, vector1_y, hAxPatch, subplotNumberPatch, speedFeedback, fullRange)

if subplotNumberPatch == 2
    colorPatch = [0.80, 0.30, 0.05];  % color for force on phases
elseif subplotNumberPatch == 3
    colorPatch = [0.85, 0.60, 0.10];  % color for force off phases
elseif subplotNumberPatch == 1
    colorPatch = [0.2, 0.2, 0.2];  % color for force off phases
else
    colorPatch = [0 0 0];
end
% colorPatch = [0.80, 0.30, 0.05];  % color for force on phases

% colorPatch above is the colour of a POSITIVE (improved) area. A negative area -
% the post-training line sitting on the worse side of the baseline one - is drawn
% in yellow instead, so the sign of every patch is readable straight off the plot.
colorPatchNegative  =   [0.95, 0.80, 0.10];  % yellow: negative (worsened) improvement area
pickAreaColor       =   @(areaSignValue) colorPatch * (areaSignValue >= 0) + colorPatchNegative * (areaSignValue < 0);


if fullRange == 0
    if (max(vector1_x)  < speedFeedback(1) || vector1_x(end-1) < speedFeedback(1) || max(vector2_x) < speedFeedback(1) || vector2_x(end-1) < speedFeedback(1) || min(vector1_x) > speedFeedback(2) || vector1_x(2) > speedFeedback(2) || min(vector2_x) > speedFeedback(2) || vector2_x(2) > speedFeedback(2))     % if the speed range of one phase is not entering at all in the speedFeedback range
        area = NaN;
    else
        % left point line 1
        x1 = min(vector1_x);
        if (x1 < speedFeedback(1))
            [~, idx]    =   min(abs(vector1_x - speedFeedback(1)));
            x1          =   vector1_x(idx);
        end
        index1  =   find(vector1_x == x1);
        y1      =   vector1_y(index1);

        % right point line 1
        x2 = max(vector1_x);
        if (x2 > speedFeedback(2))
            [~, idx]    =   min(abs(vector1_x - speedFeedback(2)));
            x2          =   vector1_x(idx);
        end
        index2  =   find(vector1_x == x2);
        y2      =   vector1_y(index2);

        % left point line 2
        x4 = min(vector2_x);
        if (x4 < speedFeedback(1))
            [~, idx]    =   min(abs(vector2_x - speedFeedback(1)));
            x4          =   vector2_x(idx);
        end
        index4  =   find(vector2_x == x4);
        y4      =   vector2_y(index4);

        % right point line 2
        x3 = max(vector2_x);
        if (x3 > speedFeedback(2))
            [~, idx]    =   min(abs(vector2_x - speedFeedback(2)));
            x3          =   vector2_x(idx);
        end
        index3  =   find(vector2_x == x3);
        y3      =   vector2_y(index3);


        % if ~isempty(intersect(vector1_y([index1,index2]), vector2_y([index4,index3])))
        % if ~isempty(intersect([round(min(vector1_y(index1), vector1_y(index2)),1):0.01:round(max(vector1_y(index1),vector1_y(index2)), 1)], [round(min(vector2_y(index3), vector2_y(index4)),1):0.01:round(max(vector2_y(index3),vector2_y(index4)), 1)]))

        % y23 = intersect(vector1_y(index1:index2), vector2_y(index3:index4));
        % x23 = vector1_x(find(vector1_y == y23));

        [x23, y23] = findIntersections(vector1_x(index1:index2), vector1_y(index1:index2), vector2_x(index4:index3), vector2_y(index4:index3));

        if ~isempty(x23)

            % Calculate the area
            % area1 = 0.5 * abs( x1*y23 + x23*y3 + x3*y1 - (y1*x23 + y23*x3 + y3*x1) );
            area1_unsigned  =   polyarea([x1, x23, x4], [y1, y23, y4]);
            % area2 = 0.5 * abs( x23*y2 + x2*y4 + x4*y23 - (y23*x2 + y2*x4 + y4*x23) );
            area2_unsigned  =   polyarea([x23, x2, x3], [y23, y2, y3]);

            areaSign1       =   ImprovementAreaSign([x1, y1], [x23, y23], [x23, y23], [x4, y4]);
            areaSign2       =   ImprovementAreaSign([x23, y23], [x2, y2], [x3, y3], [x23, y23]);

            area1           =   areaSign1 * area1_unsigned;
            area2           =   areaSign2 * area2_unsigned;

            area            =   area1 + area2;

            % if (y1(1) > y4(1))
            %     area = area1 - area2;
            % else
            %     area = area2 - area1;
            % end

            if nargin > 4 && ~isempty(colorPatch)
                patch(hAxPatch, [x1, x23, x4], [y1, y23, y4], pickAreaColor(areaSign1), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
                patch(hAxPatch, [x23, x2, x3], [y23, y2, y3], pickAreaColor(areaSign2), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
            end

        else

            % area = 0.5 * abs( x1*y2 + x2*y3 + x3*y4 + x4*y1 - (y1*x2 + y2*x3 + y3*x4 + y4*x1) );
            areaUnsigned = polyarea([x1, x2, x3, x4], [y1, y2, y3, y4]);

            areaSign = ImprovementAreaSign([x1, y1], [x2, y2], [x3, y3], [x4, y4]);
            area    =   areaSign*areaUnsigned;

            % if (norm([mean([x1 x2]), mean([y1, y2])]) < norm([mean([x3, x4]), mean([y3 y4])]))
            %     area = areaSign * area;
            % end

            fill(hAxPatch, [x1, x2, x3, x4], [y1, y2, y3, y4], pickAreaColor(areaSign), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
        end

    end
else
    % left point line 1
    x1 = min(vector1_x);
    index1  =   find(vector1_x == x1);
    y1      =   vector1_y(index1);

    % right point line 1
    x2 = max(vector1_x);
    index2  =   find(vector1_x == x2);
    y2      =   vector1_y(index2);

    % left point line 2
    x4 = min(vector2_x);
    index4  =   find(vector2_x == x4);
    y4      =   vector2_y(index4);

    % right point line 2
    x3 = max(vector2_x);
    index3  =   find(vector2_x == x3);
    y3      =   vector2_y(index3);

     [x23, y23] = findIntersections(vector1_x(index1:index2), vector1_y(index1:index2), vector2_x(index4:index3), vector2_y(index4:index3));

        if ~isempty(x23)

            % Calculate the area
            % area1 = 0.5 * abs( x1*y23 + x23*y3 + x3*y1 - (y1*x23 + y23*x3 + y3*x1) );
            area1_unsigned  =   polyarea([x1, x23, x4], [y1, y23, y4]);
            % area2 = 0.5 * abs( x23*y2 + x2*y4 + x4*y23 - (y23*x2 + y2*x4 + y4*x23) );
            area2_unsigned  =   polyarea([x23, x2, x3], [y23, y2, y3]);

            areaSign1       =   ImprovementAreaSign([x1, y1], [x23, y23], [x23, y23], [x4, y4]);
            areaSign2       =   ImprovementAreaSign([x23, y23], [x2, y2], [x3, y3], [x23, y23]);

            area1           =   areaSign1 * area1_unsigned;
            area2           =   areaSign2 * area2_unsigned;

            area            =   area1 + area2;

            % if (vecnorm([x1(1),y1(1)]) > vecnorm([x4(1), y4(1)]))
            %     area = area1 - area2;
            % else
            %     area = area2 - area1;
            % end

            if nargin > 4 && ~isempty(colorPatch)
                patch(hAxPatch, [x1, x23, x4], [y1, y23, y4], pickAreaColor(areaSign1), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
                patch(hAxPatch, [x23, x2, x3], [y23, y2, y3], pickAreaColor(areaSign2), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
            end

        else

            % area = 0.5 * abs( x1*y2 + x2*y3 + x3*y4 + x4*y1 - (y1*x2 + y2*x3 + y3*x4 + y4*x1) );
            % area = polyarea([x1, x2, x3, x4], [y1, y2, y3, y4]);

            areaUnsigned = polyarea([x1, x2, x3, x4], [y1, y2, y3, y4]);

            areaSign = ImprovementAreaSign([x1, y1], [x2, y2], [x3, y3], [x4, y4]);
            area    =   areaSign*areaUnsigned;

            % if (mean([y1 y2]) < mean([y3 y4]))
            % if (norm([mean([x1 x2]), mean([y1, y2])]) < norm([mean([x3, x4]), mean([y3 y4])]))
            %     area = -area;
            % end

            fill(hAxPatch, [x1, x2, x3, x4], [y1, y2, y3, y4], pickAreaColor(areaSign), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
        end

end
end

% function area = ComputeSignedAreaBetweenLines(vector2_x, vector2_y, vector1_x, vector1_y, hAxPatch, TitlePatch, speedFeedback)
% 
%     if strcmp(TitlePatch, 'Force On')
%         colorPatch = [0.80, 0.30, 0.05];
%     else
%         colorPatch = [0.85, 0.60, 0.10];
%     end
% 
%     % Restrict both lines to the same X range (speedFeedback interval)
%     mask1 = vector1_x >= speedFeedback(1) & vector1_x <= speedFeedback(2);
%     mask2 = vector2_x >= speedFeedback(1) & vector2_x <= speedFeedback(2);
% 
%     x_common = linspace(speedFeedback(1), speedFeedback(2), 200); % resample on common X
%     y1 = interp1(vector1_x(mask1), vector1_y(mask1), x_common, 'linear');
%     y2 = interp1(vector2_x(mask2), vector2_y(mask2), x_common, 'linear');
% 
%     % Polygon describing the area between curves
%     Xpoly = [x_common, fliplr(x_common)];
%     Ypoly = [y1, fliplr(y2)];
% 
%     % Area between lines
%     area = polyarea(Xpoly, Ypoly);
% 
%     % Signed area: make it negative if line1 is below line2 at the left edge
%     if y1(1) < y2(1)
%         area = -area;
%     end
% 
%     % Optional patch drawing
%     if nargin > 4 && ~isempty(hAxPatch)
%         patch(hAxPatch, Xpoly, Ypoly, colorPatch, 'FaceAlpha', 0.45, 'EdgeColor', 'none');
%     end
% end







% 
% function area = ComputeSignedAreaBetweenLines(x1, y1, x2, y2)
%     % Ensure column vectors
%     x1 = x1(:); y1 = y1(:);
%     x2 = x2(:); y2 = y2(:);
% 
%     % Common domain
%     xCommon = linspace(max(min(x1), min(x2)), ...
%                        min(max(x1), max(x2)), 1000);
% 
%     % Interpolation
%     y1Interp = interp1(x1, y1, xCommon, 'linear');
%     y2Interp = interp1(x2, y2, xCommon, 'linear');
% 
%     % Signed area via trapezoidal rule
%     area = trapz(xCommon, y2Interp - y1Interp);
% end

% function area = ComputeSignedAreaBetweenLines(x1, y1, x2, y2, hAxPatch, colorPatch)
% % Signed area between two (approximately linear) regression lines over
% % their overlapping x-domain, using endpoints only.
% % Positive if y2 is above y1; negative if the opposite.
% % Optionally plots a colored patch corresponding to the area.
% %
% % x1,y1 and x2,y2 can be any sampled points along each line.
% % colorPatch - RGB triplet or color string for patch
% 
%     % --- sanitize & sort ---
%     x1 = x1(:); y1 = y1(:);
%     x2 = x2(:); y2 = y2(:);
%     valid1 = isfinite(x1) & isfinite(y1);
%     valid2 = isfinite(x2) & isfinite(y2);
%     x1 = x1(valid1); y1 = y1(valid1);
%     x2 = x2(valid2); y2 = y2(valid2);
%     [x1, i1] = sort(x1); y1 = y1(i1);
%     [x2, i2] = sort(x2); y2 = y2(i2);
% 
%     if numel(x1) < 2 || numel(x2) < 2
%         area = 0; return;
%     end
% 
%     % --- common x-interval ---
%     xL = max(min(x1), min(x2));
%     xR = min(max(x1), max(x2));
%     if ~(xR > xL)
%         area = 0; return; % no overlap
%     end
% 
%     % --- evaluate each line at the endpoints of the common domain ---
%     y1L = interp1(x1, y1, xL, 'linear');
%     y1R = interp1(x1, y1, xR, 'linear');
%     y2L = interp1(x2, y2, xL, 'linear');
%     y2R = interp1(x2, y2, xR, 'linear');
% 
%     dyL = y2L - y1L;
%     dyR = y2R - y1R;
% 
%     % Fit simple line through the two endpoint samples
%     p1 = polyfit([xL, xR], [y1L, y1R], 1); % y1 = p1(1)*x + p1(2)
%     p2 = polyfit([xL, xR], [y2L, y2R], 1); % y2 = p2(1)*x + p2(2)
% 
%     den = p2(1) - p1(1); % slope difference
% 
%     % --- area and patch calculation ---
%     hold on
%     if abs(den) < eps
%         % Parallel lines: single trapezoid
%         area = ((dyL + dyR)/2) * (xR - xL);
% 
%         % Polygon for patch: top line y2, bottom line y1
%         X = [xL xR xR xL];
%         Y = [y2L y2R y1R y1L];
%         if nargin > 4 && ~isempty(colorPatch)
%             patch(hAxPatch, X, Y, colorPatch, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%         end
% 
%     else
%         % Check for intersection
%         xC = (p1(2) - p2(2)) / den; % intersection x
% 
%         if xC > xL && xC < xR
%             % Two trapezoids
%             areaLeft  = ((dyL + 0)/2) * (xC - xL);
%             areaRight = ((0 + dyR)/2) * (xR - xC);
%             area = areaLeft + areaRight;
% 
%             if nargin > 4 && ~isempty(colorPatch)
%                 % Left polygon (from xL to xC)
%                 y2left = interp1([xL xR], [y2L y2R], [xL xC]);
%                 y1left = interp1([xL xR], [y1L y1R], [xL xC]);
%                 patch(hAxPatch, [xL xC xC xL], [y2left(1) y2left(2) y1left(2) y1left(1)], ...
%                     colorPatch, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
% 
%                 % Right polygon (from xC to xR)
%                 y2right = interp1([xL xR], [y2L y2R], [xC xR]);
%                 y1right = interp1([xL xR], [y1L y1R], [xC xR]);
%                 patch(hAxPatch, [xC xR xR xC], [y2right(1) y2right(2) y1right(2) y1right(1)], ...
%                     colorPatch, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%             end
% 
%         else
%             % No crossing: single trapezoid
%             area = ((dyL + dyR)/2) * (xR - xL);
% 
%             if nargin > 4 && ~isempty(colorPatch)
%                 X = [xL xR xR xL];
%                 Y = [y2L y2R y1R y1L];
%                 patch(hAxPatch, X, Y, colorPatch, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%             end
%         end
%     end
% end




% function area = ComputeSignedAreaBetweenLines(x1, y1, x2, y2)
%     % Ensure input vectors are column vectors
%     x1 = x1(:); y1 = y1(:);
%     x2 = x2(:); y2 = y2(:);
% 
%     % 1. Interpolate both lines on a common fine grid
%     xCommon = linspace(max(min(x1), min(x2)), min(max(x1), max(x2)), 500);
% 
% 
% 
%     y1Interp = interp1(x1, y1, xCommon, 'linear');
% 
%     y2Interp = interp1(x2, y2, xCommon, 'linear');
% 
% 
%     % 2. Find intersection (sign change in difference)
%     diffY = y1Interp - y2Interp;
%     signChangeIdx = find(diffY(1:end-1) .* diffY(2:end) < 0, 1);
% 
%     if ~isempty(signChangeIdx)
%         % === CASE 1: Lines Cross ===
%         % Get the intersection point
%         xIntersect = interp1(diffY(signChangeIdx:signChangeIdx+1), ...
%                              xCommon(signChangeIdx:signChangeIdx+1), 0);
%         yIntersect = interp1(x1, y1, xIntersect, 'linear');  % or y2, same at crossing
% 
%         % Left triangle
%         A1 = polyarea( ...
%             [x1(1), x2(1), xIntersect], ...
%             [y1(1), y2(1), yIntersect]);
% 
%         % Right triangle
%         A2 = polyarea( ...
%             [x1(end), x2(end), xIntersect], ...
%             [y1(end), y2(end), yIntersect]);
% 
%         % Sign based on which line is higher at start and end
%         signLeft  = sign(y2(1) - y1(1));
%         signRight = sign(y2(end) - y1(end));
% 
%         area = signLeft*A1 + signRight*A2;
% 
%     else
%         % === CASE 2: No Crossing ===
%         % Create polygon from the 4 points
%         polyX = [x1(1), x2(1), x2(end), x1(end)];
%         polyY = [y1(1), y2(1), y2(end), y1(end)];
% 
%         areaVal = polyarea(polyX, polyY);
% 
%         % Sign based on average difference
%         signVal = sign(mean(y2 - y1));
% 
%         area = signVal * areaVal;
%         area = round(area, 2);
%     end
% end




% function [out1, out2] = ComputeSignedAreaOrStats(varargin)
%     % ComputeSignedAreaOrStats
%     % Usage:
%     %   area = ComputeSignedAreaOrStats(x1, y1, x2, y2)
%     %       -> computes signed area between two curves
%     %
%     %   [medianGP, stdGP] = ComputeSignedAreaOrStats(GlobalPositionCell)
%     %       -> computes median and std trajectory from a cell array of GlobalPositions
% 
%     if nargin == 1
%         % ====== CASE 1: GlobalPosition stats ======
%         GlobalPositionCell = varargin{1};
% 
%         % Find the maximum length among trajectories
%         maxLen = max(cellfun(@(g) size(g,1), GlobalPositionCell));
% 
%         % Pad trajectories with NaN so they align
%         allData = NaN(maxLen, numel(GlobalPositionCell), size(GlobalPositionCell{1},2));
%         for i = 1:numel(GlobalPositionCell)
%             len = size(GlobalPositionCell{i},1);
%             allData(1:len,i,:) = GlobalPositionCell{i};
%         end
% 
%         % Median and std (ignoring NaN padding)
%         medianGP = squeeze(nanmedian(allData,2));
%         stdGP    = squeeze(nanstd(allData,0,2));
% 
%         out1 = medianGP;
%         out2 = stdGP;
% 
%     elseif nargin == 4
%         % ====== CASE 2: Signed Area Between Curves ======
%         x1 = varargin{1}(:); y1 = varargin{2}(:);
%         x2 = varargin{3}(:); y2 = varargin{4}(:);
% 
% 
%         % Common fine grid
%         xCommon = linspace(max(min(x1), min(x2)), min(max(x1), max(x2)), 500);
% 
%         [x1Unique, idx] = unique(x1);   % get unique x and corresponding indices
%         y1Unique = y1(idx);             % keep y aligned with x
% 
%         y1Interp = interp1(x1Unique, y1Unique, xCommon, 'linear');
%         % y1Interp = interp1(x1, y1, xCommon, 'linear');
% 
%         [x2Unique, idx] = unique(x2);   % get unique x and corresponding indices
%         y2Unique = y2(idx);             % keep y aligned with x
% 
%         y2Interp = interp1(x2Unique, y2Unique, xCommon, 'linear');
%         % y2Interp = interp1(x2, y2, xCommon, 'linear');
% 
%         % Difference
%         diffY = y1Interp - y2Interp;
%         signChangeIdx = find(diffY(1:end-1) .* diffY(2:end) < 0, 1);
% 
%         if ~isempty(signChangeIdx)
%             % Lines cross
%             xIntersect = interp1(diffY(signChangeIdx:signChangeIdx+1), ...
%                                  xCommon(signChangeIdx:signChangeIdx+1), 0);
%             yIntersect = interp1(x1, y1, xIntersect, 'linear');
% 
%             A1 = polyarea([x1(1), x2(1), xIntersect], ...
%                           [y1(1), y2(1), yIntersect]);
%             A2 = polyarea([x1(end), x2(end), xIntersect], ...
%                           [y1(end), y2(end), yIntersect]);
% 
%             signLeft  = sign(y2(1) - y1(1));
%             signRight = sign(y2(end) - y1(end));
% 
%             area = signLeft*A1 + signRight*A2;
%         else
%             % No crossing
%             polyX = [x1(1), x2(1), x2(end), x1(end)];
%             polyY = [y1(1), y2(1), y2(end), y1(end)];
% 
%             areaVal = polyarea(polyX, polyY);
%             signVal = sign(mean(y2 - y1));
%             area = signVal * areaVal;
%         end
% 
%         out1 = area;
%         out2 = [];
% 
%     else
%         error('Invalid input: either pass (x1,y1,x2,y2) or {GlobalPositionCell}.');
%     end
% end



function plotSpeedLines(hAx, xLines, yRange, labels)
% plotSpeedLines Plot dashed vertical lines in 3D with text labels
%
% Usage:
%   plotSpeedLines(hAx, [x1, x2], [ymin, ymax], {'slow','fast'})
%
% Inputs:
%   hAx    - axes handle (e.g., gca or from subplot)
%   xLines - 1xN vector with x positions of the lines
%   yRange - 1x2 vector with [ymin, ymax] for the line length
%   labels - 1xN cell array with labels for each line

    if nargin < 4
        labels = arrayfun(@(i) sprintf('Line %d',i), 1:numel(xLines), 'UniformOutput', false);
    end

    hold(hAx, 'on');
    
    for i = 1:numel(xLines)
        % Line coordinates
        xVals = xLines(i) * ones(1, 10);
        yVals = linspace(yRange(1), yRange(2), 10);
        zVals = zeros(1, 10);

        % Plot line
        plot3(hAx, xVals, yVals, zVals, '--', 'LineWidth', 6, 'Color', [0 0 0]);  % doubled to match the enlarged tick numbers and labels

        % Place label at the top of the line, offset slightly in Y
        text(hAx, xVals(1)-0.03, yVals(end)-0.15, zVals(1), labels{i}, 'FontWeight', 'bold', 'FontSize', 20, 'Color', 'k', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    end
end


function [xi, yi] = findIntersections(x1, y1, x2, y2)
    % interpolate both curves onto a common grid
    x_common = linspace(max(min(x1),min(x2)), min(max(x1),max(x2)), 2000);
    y1i = interp1(x1, y1, x_common);
    y2i = interp1(x2, y2, x_common);

    % difference
    diff = y1i - y2i;

    % find where sign changes => intersection
    idx = find(diff(1:end-1).*diff(2:end) < 0);

    xi = [];
    yi = [];
    for k = 1:length(idx)
        % linear interpolation for better accuracy
        x0 = x_common(idx(k));
        x1_ = x_common(idx(k)+1);
        y0 = diff(idx(k));
        y1_ = diff(idx(k)+1);

        % zero-crossing location
        x_cross = x0 - y0*(x1_-x0)/(y1_-y0);
        y_cross = interp1(x1, y1, x_cross);

        xi(end+1) = x_cross;
        yi(end+1) = y_cross;
    end
end



function signType = ImprovementAreaSign(p1, p2, p3, p4)

segmentVector   =   p2 - p1;        % create the vector that goes through the first regression line
normalVector    =   [-segmentVector(2), segmentVector(1)];  % find the vector with direction normal to the first regression line (segment vector)
normalVector    =   normalVector / vecnorm(normalVector);   % normalize it
m_normal        =   normalVector(2) / normalVector(1);
mean_12         =   [mean([p1(1), p2(1)]), mean([p1(2), p2(2)])];   % find the points where you want the perpendicular line to pass through (middle point of first regression line)
c_12            =   mean_12(2) - m_normal * mean_12(1); % find the y-intercept
perpFunction    =   @(x) m_normal * x + c_12;  % create the anonymous function

x_Values        =   linspace(0, max([p1(1), p2(1), p3(1), p4(1)]), 100);
y_PerpValues    =   perpFunction(x_Values);

% same thing but now finding the vector parallel to the first regression line and passing throuhg the second regression line middle point, to then check for intersection
segmentVector       =   segmentVector / vecnorm(segmentVector);
m_parallel          =   segmentVector(2) / segmentVector(1);
mean_34             =   [mean([p3(1), p4(1)]), mean([p3(2), p4(2)])];
c_34                =   mean_34(2) - m_parallel * mean_34(1);
parallelFunction    =   @(x) m_parallel * x + c_34;

y_ParallValues      =   parallelFunction(x_Values);

% find the cross values
[x_cross, y_cross] = findIntersections(x_Values, y_PerpValues, x_Values, y_ParallValues);


if (norm(mean_12) < norm([x_cross, y_cross]))
    signType = -1;
else
    signType = 1;
end

end


