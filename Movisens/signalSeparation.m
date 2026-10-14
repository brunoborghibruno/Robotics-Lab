%% BRUNO BORGHI - signal separation

function [separatedSignal]   =  signalSeparation(signal, lowerRange, higherRange)

if (size(signal, 2) == 1)
separatedSignal  =  signal(lowerRange:higherRange);
elseif (size(signal, 2) == 3)
    separatedSignal  =  signal(lowerRange:higherRange, :);
end

end