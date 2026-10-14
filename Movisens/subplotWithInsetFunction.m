%% BRUNO BORGHI  -  Data Subplots
% input file: - x: array with horizontal axis values (length = y matrix rows). Type zero if you only care about y values
%             - y: matrix with row = observations and columns = variables
%             - rowNumber: number of row of the subplot
%             - colNumber: same for columns
%             - subplotNumber: total number of suplot required (max 4)
%             - Title
%             - xLabel
%             - yLabel
%             - xLines: array with the values of the vertical x lines
%             - colorNumb: color number, to choose specific colors (if it's a vector, the second component indicate the transparency)


function cloudVolume = subplotWithInsetFunction(x, y, rowNumber, colNumber, subplotNumber, Title, xLabel, yLabel, xLines, colorNumb, xLimits, yLimits, Legend, raw_acc)



% colors = [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; [0.9290 0.6940 0.1250]; [0 0 0]]; % Blue, Red, Yellow, Black colors
colors = [
    0.0000  0.4470  0.7410;  % blue
    0.6350  0.0780  0.1840;  % dark red
    0.9290  0.6940  0.1250;  % yellow
    0.0000  0.0000  0.0000;  % black
    0.4660  0.6740  0.1880;  % green
    0.4940  0.1840  0.5560;  % purple
    0.3010  0.7450  0.9330   % cyan/teal
];
titleSize = 20;
cloudVolume = NaN;   % output: alpha-shape volume of raw_acc (only when the inset is drawn)

if nargin > 9  &  ~isempty(colorNumb)
    if (isscalar(colorNumb))
        if (colorNumb == 1)
            colors = colors(1, :);
        elseif (colorNumb == 2)
            colors = colors(2, :);
        elseif (colorNumb == 3)
            colors = colors(3, :);
        elseif (colorNumb == 4)
            colors = colors(4, :);
        end
    else
        if (colorNumb(1) == 1)
            colors = [colors(1, :), colorNumb(2)];
        elseif (colorNumb(1) == 2)
            colors = [colors(2, :), colorNumb(2)];
        elseif (colorNumb(1) == 3)
            colors = [colors(3, :), colorNumb(2)];
        elseif (colorNumb(1) == 4)
            colors = [colors(4, :), colorNumb(2)];
        elseif (colorNumb(1) == 5)
            colors = [colors(5, :), colorNumb(2)];
        elseif (colorNumb(1) == 6)
            colors = [colors(6, :), colorNumb(2)];
        elseif (colorNumb(1) == 7)
            colors = [colors(7, :), colorNumb(2)];
        end
    end
end

% if nargin < 13 
%     Legend = [];
% end





if (isempty(x))

    if (min(size(y)) > 1)
        for count = 1 : subplotNumber
            hAx = subplot(rowNumber, colNumber, count);
            plot(y(:,count), '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors(count, :));
            hold on
            if nargin > 8 & ~isempty(xLines)
                xl = xline(xLines, '--');
            end
            if ~isempty(Title)
                title(Title, 'FontSize', titleSize);
            end
            if ~isempty(xLabel)
                xlabel(xLabel, 'FontSize', titleSize);
            end
            if ~isempty(yLabel)
                ylabel(yLabel, 'FontSize', titleSize);
            end
            if (~isempty(Legend))
                legend(Legend);
            end
            if (nargin > 10)
                xlim(xLimits);
                ylim(yLimits);
            end
            set(hAx, 'box', 'off');
            set(hAx, 'Color', 'none');

        end
    else
        hAx = subplot(rowNumber, colNumber, subplotNumber);
        plot(y, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors);
        hold on
        if nargin > 8 & ~isempty(xLines)
            xl = xline(xLines, '--');
        end
        if ~isempty(Title)
            title(Title, 'FontSize', titleSize);
        end
        if ~isempty(xLabel)
            xlabel(xLabel, 'FontSize', titleSize);
        end
        if ~isempty(yLabel)
            ylabel(yLabel, 'FontSize', titleSize);
        end
        if (~isempty(Legend))
            legend(Legend);
        end
        if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
        end
        set(hAx, 'box', 'off');
        set(hAx, 'Color', 'none');
    end

else

    if (min(size(y)) > 1)
        for count = 1 : subplotNumber

            hAx = subplot(rowNumber, colNumber, count);
            plot(x, y(:,count), '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors(count, :));
            hold on
            if nargin > 8 & ~isempty(xLines)
                xl = xline(xLines, '--');
            end
            % xl = xline([marker]', '--', {'AccY start', 'AccY end', 'AccX start', 'AccX end', 'AccZ start', 'AccZ end',});
            % xl.LabelHorizontalAlignment = 'center';
            if ~isempty(Title)
                title(Title, 'FontSize', titleSize);
            end
            if ~isempty(xLabel)
                xlabel(xLabel, 'FontSize', titleSize);
            end
            if ~isempty(yLabel)
                ylabel(yLabel, 'FontSize', titleSize);
            end
            if (~isempty(Legend))
            legend(Legend);
            end
            if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
            end
            set(hAx, 'box', 'off');
            set(hAx, 'Color', 'none');
            % xline([x1(1)*64, x1(2)*64, x2(1)*64, x2(2)*64, x3(1)*64, x3(2)*64]);

        end
    else
        hAx = subplot(rowNumber, colNumber, subplotNumber);
        plot(x, y, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors);
        hold on
        if nargin > 8 & ~isempty(xLines)
            xl = xline(xLines, '--');
        end
        if ~isempty(Title)
            title(Title, 'FontSize', titleSize);
        end
        if ~isempty(xLabel)
            xlabel(xLabel, 'FontSize', titleSize);
        end
        if ~isempty(yLabel)
            ylabel(yLabel, 'FontSize', titleSize);
        end
        if (~isempty(Legend))
            legend(Legend);
        end
        if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
        end
        set(hAx, 'box', 'off');
        set(hAx, 'Color', 'none');
    end


end

if nargin > 13
    % Get the position of the current subplot axis
    mainAxPosition = get(hAx, 'Position');

    % Define the inset 1 position
    insetAx_Position = [mainAxPosition(1) + mainAxPosition(3) * 0.85, ...       % X post
                        mainAxPosition(2) + mainAxPosition(4) * 0.5, ...        % Y pos
                        mainAxPosition(3) * 0.4, ...                            % Width
                        mainAxPosition(4) * 0.4];                               % Height

    % Create a new inset axis
    insetAxes = axes('Position', insetAx_Position);
    hold(insetAxes, 'on');

    [cloudVolume] = cloudPointsVolumeAnalysis(raw_acc, []);
    set(gca, 'Color', 'none');
    axis equal;
    set(insetAxes, 'Color', 'none');
    set(insetAxes, 'XColor', 'none');
    set(insetAxes, 'YColor', 'none');
    set(insetAxes, 'ZColor', 'none');
    % hold(insetAxes, 'off');
    % hold(hAx, 'on');
end





end