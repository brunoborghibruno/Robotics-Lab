%% BRUNO BORGHI - subplot function for Speed vs Accuracy plot

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


function speedAccuracySubplotFunction(x, y, rowNumber, colNumber, subplotNumber, Title, xLabel, yLabel, xLines, colorNumb, xLimits, yLimits, Legend)


% colors = lines(length(subjectsList)); % built-in colormap with distinct colors

colors = [[0 0.4470 0.7410]; [0.6350 0.0780 0.1840]; [0.9290 0.6940 0.1250]; [0 0 0]]; % Blue, Red, Yellow, Black colors
titleSize = 20;
scatterSize = 100;


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
end

if nargin < 13
    Legend = [];
end

% remove NaN
finiteIndexes_Baseline  =   isfinite(y);
y                       =   y(finiteIndexes_Baseline);
x                       =   x(finiteIndexes_Baseline);  

% Logarithmic scale
y       = log(1./y);

% Perform linear regression on combined Baseline data
baselineCoeff           =   polyfit(x, y, 1);

% Define the range of speeds for plotting the fit line
speedRangeBaseline          =   linspace(min(x), max(x), 100);

% Evaluate the linear fit across the speed range
baselineFitLine         =   polyval(baselineCoeff, speedRangeBaseline);






subplot(rowNumber, colNumber, subplotNumber)
scatter(x, y, scatterSize, 'filled', 'MarkerFaceColor', colors, 'MarkerEdgeColor', 'none');
hold on
if nargin > 8 & ~isempty(xLines)
    xl = xline(xLines, '--');
end
title(Title, 'FontSize', titleSize+10);
xlabel(xLabel, 'FontSize', titleSize);
ylabel(yLabel, 'FontSize', titleSize);
if (~isempty(Legend))
    legend(Legend);
end
if (nargin > 10)
    xlim(xLimits);
    ylim(yLimits);
end



end




