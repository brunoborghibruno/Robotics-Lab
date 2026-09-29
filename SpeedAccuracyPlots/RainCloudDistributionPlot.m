

function RainCloudDistributionPlot(SingleSubjectProcessedData, linesOn, errorType, practicedDirections, namesToCompare)

if nargin < 3
    errorType = 'Max Error';
end

if nargin < 4
    practicedDirections = 1;
end


% EF, EA, SHAM
tempData = struct2cell(SingleSubjectProcessedData);
tempGroup = tempData;

for i = 1:length(tempData)
    tempGroup = struct2cell(tempData{i});
    for j = 1:length(tempGroup)
        if practicedDirections == 1
            Data{i}(j,1) = tempGroup{j}.(matlab.lang.makeValidName(namesToCompare(1)));
            if length(namesToCompare) > 1
                Data{i}(j,2) = tempGroup{j}.(matlab.lang.makeValidName(namesToCompare(2)));
            end
            if length(namesToCompare) > 2
                Data{i}(j,3) = tempGroup{j}.(matlab.lang.makeValidName(namesToCompare(3)));
            end
        end
    end
end

figure;

% Parametri grafici
scatterSizeDots     =   800;
markerSizeDotMedian =   40;
lineWidthScatter    =   4;
lineWidthBarraNera  =   8;
xpos                =   1:3;       % 3 tick asse X
width               =   0.35;      % larghezza massima della mezza-violin
npts                =   200;       % risoluzione densità
colSinistra         =   [0.2 0.2 0.2];
colL                =   [0.80, 0.30, 0.05];
colR                =   [0.85, 0.60, 0.10];
edgeC               =   'none';
alphaF              =   0.5;
medW                =   2;
hold on;
offset              =   0.03;  
lineC               =   [0.3 0.3 0.3];
bigTitleSize        =   90;
xLabelFontSize      =   80;
legendSize          =   30;
if practicedDirections == 1
    labelNames          =   {'Baseline - Interm Exp', 'Pre-Post Force On', 'Pre-Post Force Off'};
else
    labelNames          =   {'Unpracticed Baseline - Interm Exp', 'Unpracticed Pre-Post Force Off', 'Unpracticed Pre-Post Force On'};
end


for i = 1:numel(xpos)
    dataL       = Data{i}(:,1);  % gruppo "sinistra"
    dataR       = Data{i}(:,2);  % gruppo "destra"
    dataSingle  = Data{i}(:,3);  % gruppo a tutta sinistra
    xi = xpos(i);

    % Preallocate jitter arrays aligned with subjects
    nSubjects = size(Data{i},1);
    xJitterSingle = NaN(nSubjects,1);
    xJitterOn     = NaN(nSubjects,1);
    xJitterOff    = NaN(nSubjects,1);
    

    % ---- Estrema sinistra (dataSingle) ----
    y  = dataSingle(~isnan(dataSingle));
    if numel(y) > 1
        [f, yi] = ksdensity(y, 'NumPoints', npts);
        f = f./max(f); 
        centerX = xi - 13*offset; 
        xLeft  = centerX - f*(width/2);
        xRight = centerX + f*(width/2);

        patch([xLeft, fliplr(xRight)], [yi, fliplr(yi)], ...
              colSinistra, 'FaceAlpha', alphaF, 'EdgeColor', edgeC, 'LineWidth', 0.5);

        hold on;

        % Assign jitter positions subject-by-subject
        finterp = interp1(yi, f, y, 'linear','extrap'); 
        jitterSign = randi([0 1], size(y))*2 - 1;  
        xj = centerX + jitterSign .* (0.05 + 0.3*rand(size(y))).*(finterp*(width/2));
        xJitterSingle(~isnan(dataSingle)) = xj;

        scatter(xj, y, scatterSizeDots, 'MarkerFaceColor', [1 1 1], ...
                'MarkerEdgeColor', colSinistra, 'MarkerFaceAlpha', 0.8, ...
                'LineWidth', lineWidthScatter);

        q = prctile(y,[25 50 75]);
        plot([centerX, centerX], [q(1), q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(centerX, q(2), 'o', 'MarkerFaceColor', colSinistra, ...
             'MarkerEdgeColor', lineC, 'LineWidth', 1.5, 'MarkerSize', markerSizeDotMedian);

    end

    % ---- Half sinistra (dataL) ----
    y  = dataL(~isnan(dataL));
    if numel(y) > 1
        [f, yi] = ksdensity(y, 'NumPoints', npts);
        f = f./max(f);
        xLeft = (xi - offset) - f*width;   

        patch([xLeft, xi - offset], [yi, yi(end)], colL, ...
              'FaceAlpha', alphaF, 'EdgeColor', edgeC, 'LineWidth', 0.5);

        finterp = interp1(yi, f, y, 'linear','extrap');   
        xj = (xi) - (0.05 + 1*rand(size(y))).*(finterp*width);
        xJitterOn(~isnan(dataL)) = xj;

        scatter(xj, y, scatterSizeDots, 'MarkerFaceColor', [1 1 1], ...
                'MarkerEdgeColor', colL, 'MarkerFaceAlpha', 0.8, 'LineWidth', lineWidthScatter);

        q = prctile(y,[25 50 75]);
        plot([xi - offset, xi - offset], [q(1), q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(xi - offset, q(2), 'o', 'MarkerFaceColor', colL, ...
             'MarkerEdgeColor', lineC, 'LineWidth', 1.5,'MarkerSize', markerSizeDotMedian);
    end

    % ---- Half destra (dataR) ----
    y  = dataR(~isnan(dataR));
    if numel(y) > 1
        [f, yi] = ksdensity(y, 'NumPoints', npts);
        f = f./max(f);
        xRight = (xi + offset) + f*width;  

        patch([xi + offset, xRight], [yi(1), yi], colR, ...
              'FaceAlpha', alphaF, 'EdgeColor', edgeC, 'LineWidth', lineWidthScatter);

        finterp = interp1(yi, f, y, 'linear','extrap');   
        xj = (xi + offset) + (0.05 + 0.9*rand(size(y))).*(finterp*width);
        xJitterOff(~isnan(dataR)) = xj;

        scatter(xj, y, scatterSizeDots, 'MarkerFaceColor', [1 1 1], ...
                'MarkerEdgeColor', colR, 'MarkerFaceAlpha', 0.8, 'LineWidth', lineWidthScatter);

        q = prctile(y,[25 50 75]);
        plot([xi + offset, xi + offset], [q(1), q(3)], '-', 'Color', lineC, 'LineWidth', lineWidthBarraNera);
        plot(xi + offset, q(2), 'o', 'MarkerFaceColor', colR, ...
             'MarkerEdgeColor', lineC, 'LineWidth',1.5,'MarkerSize', markerSizeDotMedian);
    end

    % ---- Draw subject-level lines (NaN safe) ----
    if linesOn
        for s = 1:nSubjects
            % Baseline ↔ ForceOn
            if ~isnan(Data{i}(s,3)) && ~isnan(Data{i}(s,1))
                plot([xJitterSingle(s), xJitterOn(s)], [Data{i}(s,3), Data{i}(s,1)], '-', 'Color', [0 0 0 0.3], 'LineWidth', 1.5);
            end
            % ForceOn ↔ ForceOff
            if ~isnan(Data{i}(s,1)) && ~isnan(Data{i}(s,2))
                plot([xJitterOn(s), xJitterOff(s)], [Data{i}(s,1), Data{i}(s,2)], '-', 'Color', [0 0 0 0.3], 'LineWidth', 1.5);
            end
        end
    end
end

yline(0, '--', 'Color','b');

ylabel('Improvement Area', 'FontSize', xLabelFontSize, 'FontWeight','bold');

allY = cell2mat(cellfun(@(x) x(:), Data, 'UniformOutput', false));
allY = allY(~isnan(allY));

if isempty(allY)
    ylim([-1 1]);
else
    ymin = min(allY); ymax = max(allY);
    if ymin == ymax
        ymin = ymin - 1e-3; ymax = ymax + 1e-3;
    else
        padding = 0.3 * (ymax - ymin);
        ymin = ymin - padding; ymax = ymax + padding;
    end
    ylim([ymin ymax]);
end

if ~isempty(allY) && min(allY) < 0 && max(allY) > 0
    yticks(unique([get(gca,'YTick'), 0]));
end

set(gca, 'Color', 'none');
title({'Aggregate Group Analysis', errorType}, 'FontSize', bigTitleSize);

% Personalizzazione assi
set(gca, 'LineWidth', 2, 'XTick', xpos, 'XTickLabel', {'EF','EA','SHAM'}, 'FontSize', xLabelFontSize, 'FontWeight', 'bold', 'Box', 'off');                                 % toglie il riquadro superiore e destro


ax = gca;
ax.XAxis.Exponent = 0;   
ax.YAxis.Exponent = 0;   
ax.ZAxis.Exponent = 0;   

end
