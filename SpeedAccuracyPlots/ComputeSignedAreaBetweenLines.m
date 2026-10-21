function area = ComputeSignedAreaBetweenLines(vector2_x, vector2_y, vector1_x, vector1_y, hAxPatch, subplotNumberPatch, speedFeedback, fullRange)
% Signed area between two speed-accuracy regression lines (the Improvement Area).
% vector2 is the reference line (e.g. baseline), vector1 the line compared with it. Positive = vector1 sits
% on the more accurate side. fullRange = 1 uses the whole speed range, 0 only the speedFeedback range.
% With hAxPatch empty nothing is drawn and only the area is returned.
% Moved here from SpeedAccuracyCupolasSubplotMinimal.m so SpeedAccuracyDaysProgress.m can use it too.

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

            if ~isempty(hAxPatch)
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

            if ~isempty(hAxPatch)
                fill(hAxPatch, [x1, x2, x3, x4], [y1, y2, y3, y4], pickAreaColor(areaSign), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
            end
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

            if ~isempty(hAxPatch)
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

            if ~isempty(hAxPatch)
                fill(hAxPatch, [x1, x2, x3, x4], [y1, y2, y3, y4], pickAreaColor(areaSign), 'FaceAlpha', 0.45, 'EdgeColor', 'none');
            end
        end

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


