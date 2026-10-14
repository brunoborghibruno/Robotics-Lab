%% BRUNO BORGHI - Area Under the Curve

function  [AUC, CUMTRAP]  =  areaUnderTheCurve(acceleration, title)

AUC  =  trapz(abs(acceleration));

CUMTRAP  = cumtrapz(acceleration);


if nargin < 2 || isempty(title)


    subplotFunction([], acceleration, 1, 1, 1, ['AUC: ' , num2str(AUC)], 'Samples', 'Acc', [], 1);
    hold on
    xlabel('Time [s]');
    ylabel('Acceleration');

else

    subplotFunction([], acceleration, 1, 1, 1, ['AUC ', title, ': ', num2str(AUC)], 'Samples', 'Acc', [], 1);
    hold on
    xlabel('Time [s]');
    ylabel('Acceleration');

end

end