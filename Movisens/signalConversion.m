%% BRUNO BORGHI  -  Signal Conversion
% this function converts from ADC output of the accelerometer Movisens
% Move4 to a real value in g (gravitational acceleration)

function   [realSignal]  =  signalConversion(acc_raw, LSBvalue, baseline, unitMeasure)

if (nargin < 3 | isempty(baseline))
    baseline  =  0;
end

if (size(acc_raw, 2) == 3 | size(baseline,2) == 3)
    realSignal  =  zeros(length(acc_raw), 3);
    if (size(baseline, 2) == 3)
        realSignal(:,1)  =  ((acc_raw(:,1) - baseline(1)) * LSBvalue) * unitMeasure;
        realSignal(:,2)  =  ((acc_raw(:,2) - baseline(2)) * LSBvalue) * unitMeasure;
        realSignal(:,3)  =  ((acc_raw(:,3) - baseline(3)) * LSBvalue) * unitMeasure;
    else
        realSignal(:,1)  =  ((acc_raw(:,1) - baseline) * LSBvalue) * unitMeasure;
        realSignal(:,2)  =  ((acc_raw(:,2) - baseline) * LSBvalue) * unitMeasure;
        realSignal(:,3)  =  ((acc_raw(:,3) - baseline) * LSBvalue) * unitMeasure;
    end
else
    realSignal  =  ((acc_raw - baseline) * LSBvalue) * unitMeasure;
end

end