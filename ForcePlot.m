%% BRUNO - Force Plot 
% This force plot is used with data collected from Unity, which uses a
% left-handed coordinate systems, so thats why Y and Z coordinates are
% inverted in plots


function ForcePlot(axObject, position, force, therapyForce, unit, transparency,patientMode)
if ~exist("patientMode") || isempty(patientMode), patientMode=false; else, patientMode=true; end


if ~exist('unit'), unit='cm'; end

if (nargin < 6)
    transparency = 1;
end


switch unit
        case 'm'
            displayUnitGain=1;
            unitString=" (m)";
        case 'cm'
            displayUnitGain=100;
            unitString=" (cm)";
end

displayForceUnitGain = 0.01;


%% Normalize Forces

% Calculate the magnitude for each vector (force and therapyForce) at each time step
forceMagnitude = sqrt(sum(force.^2, 2));          % Vector magnitudes for each row (sample)
therapyForceMagnitude = sqrt(sum(therapyForce.^2, 2));

% Find the maximum magnitude across both force and therapyForce
maxMagnitude = max([forceMagnitude; therapyForceMagnitude]);

% Avoid division by zero by replacing any zero magnitude with a small value
maxMagnitude(maxMagnitude == 0) = eps;

% Normalize both force and therapyForce by the common maximum magnitude
forceNorm = force ./ maxMagnitude;                      % Normalize force
therapyForceNorm = therapyForce ./ maxMagnitude;        % Normalize therapyForce

% Calculate the maximum vector magnitude across both force matrices
% maxForceMag = max(sqrt(sum(force.^2, 2)));
% maxTherapyForceMag = max(sqrt(sum(therapyForce.^2, 2)));
% maxMag = max([maxForceMag, maxTherapyForceMag]);  % Use the largest magnitude from both

%% Plot Forces


% Plot the forces
lsz=2;
index = 1 : size(position,1);
hold(axObject,"on")
if patientMode == false
    q1 = quiver3(axObject, displayUnitGain * position(index,1), displayUnitGain * position(index,3), displayUnitGain * position(index,2), displayUnitGain * displayForceUnitGain *  forceNorm(index,1), displayUnitGain * displayForceUnitGain *  forceNorm(index,3), displayUnitGain * displayForceUnitGain *  forceNorm(index,2), 'Color', [0.7500, 0.1250, 0.1],'LineWidth', lsz, 'MarkerSize',20,'ShowArrowHead','on', 'AutoScale', 'off');  % [0.7500 0.1250 0.1]
end
%set(q1,'AutoScale','on', 'AutoScaleFactor', 2);
q2 = quiver3(axObject, displayUnitGain * position(index,1), displayUnitGain * position(index,3), displayUnitGain * position(index,2), displayUnitGain * displayForceUnitGain *  therapyForceNorm(index,1), displayUnitGain * displayForceUnitGain *  therapyForceNorm(index,3), displayUnitGain * displayForceUnitGain *  therapyForceNorm(index,2), 'Color', [0, 0, 0],'LineWidth', lsz, 'MarkerSize',20,'ShowArrowHead','on', 'AutoScale', 'off');  % [0.7500 0.1250 0.1]
%set(q2,'AutoScale','on', 'AutoScaleFactor', 2);
axis(axObject,"equal");




%% Force - Velocity plot
% 
% figure (2)
% % plot(vecnorm((Data{485,1}.GlobalVelocity)'), 'LineWidth', 2);
% % hold on
% plot(vecnorm((Data{485,1}.GlobalRobotForce)'), 'LineWidth', 2);
% hold on
% yyaxis right
% plot(vecnorm((Data{485,1}.GlobalVelocity)'), 'LineWidth', 2);
% hold on
% 
% 
% fh = figure();
% fh.WindowState = 'maximized';

end