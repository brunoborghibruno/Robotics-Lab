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


function subplotFunction(x, y, rowNumber, colNumber, subplotNumber, Title, xLabel, yLabel, xLines, colorNumb, xLimits, yLimits, Legend)



colors          =   [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; [0.9290 0.6940 0.1250]; [0 0 0]]; % Blue, Red, Yellow, Black colors
titleSize       =   25;
lineWidthValue  =   3;

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
        end
    end
elseif (subplotNumber == 1)
    colors = colors(1, :);
end

if nargin < 13 
    Legend = [];
end





if (isempty(x))

    if (min(size(y)) > 1)
        for count = 1 : subplotNumber
            subplot(rowNumber, colNumber, count)
            plot(y(:,count), '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors(count, :));
            hold on
            if nargin > 8 & ~isempty(xLines)
                xl              =   xline(xLines, '--', 'LineWidth', lineWidthValue);
            end
            title(Title, 'FontSize', titleSize+10);
            xlabel(xLabel, 'FontSize', titleSize);
            ylabel(yLabel, 'FontSize', titleSize);
            ax          = gca;
            ax.FontSize = titleSize;
            if (~isempty(Legend))
            legend(Legend);
            end
            if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
            end

        end
    else
        subplot(rowNumber, colNumber, subplotNumber)
        plot(y, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors);
        hold on
        if nargin > 8 & ~isempty(xLines)
            xl = xline(xLines, '--', 'LineWidth', lineWidthValue);
        end
        title(Title, 'FontSize', titleSize+10);
        xlabel(xLabel, 'FontSize', titleSize);
        ylabel(yLabel, 'FontSize', titleSize);
        ax          = gca;
        ax.FontSize = titleSize;
        if (~isempty(Legend))
            legend(Legend);
        end
        if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
        end
    end

else

    if (min(size(y)) > 1)
        for count = 1 : subplotNumber

            subplot(rowNumber, colNumber, count)
            plot(x, y(:,count), '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors(count, :));
            hold on
            if nargin > 8 & ~isempty(xLines)
                xl = xline(xLines, '--', 'LineWidth', lineWidthValue);
            end
            % xl = xline([marker]', '--', {'AccY start', 'AccY end', 'AccX start', 'AccX end', 'AccZ start', 'AccZ end',});
            % xl.LabelHorizontalAlignment = 'center';
            title(Title, 'FontSize', titleSize+10);
            xlabel(xLabel, 'FontSize', titleSize);
            ylabel(yLabel, 'FontSize', titleSize);
            ax          = gca;
            ax.FontSize = titleSize;
            if (~isempty(Legend))
            legend(Legend);
            end
            if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
            end
            % xline([x1(1)*64, x1(2)*64, x2(1)*64, x2(2)*64, x3(1)*64, x3(2)*64]);

        end
    else
        subplot(rowNumber, colNumber, subplotNumber)
        plot(x, y, '.-', 'MarkerSize', 6, 'LineWidth', 2, 'Color', colors);
        hold on
        if nargin > 8 & ~isempty(xLines)
            xl = xline(xLines, '--', 'LineWidth', lineWidthValue);
        end
        title(Title, 'FontSize', titleSize+10);
        xlabel(xLabel, 'FontSize', titleSize);
        ylabel(yLabel, 'FontSize', titleSize);
        ax          = gca;
        ax.FontSize = titleSize;
        if (~isempty(Legend))
            legend(Legend);
        end
        if (nargin > 10)
            xlim(xLimits);
            ylim(yLimits);
        end
    end


end





end