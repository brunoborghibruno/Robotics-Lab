%% BRUNO BORGHI - Integrate acceleration



%% Select the subjects' ID to be compared

subjectsList    =  ["E-5"];
maxSamples      =  1700000;                   % is the amount of samples required to clip the first 7 hours of recording




%% Save subjects Data


for count = 1:length(subjectsList)

    % visit 1
    name = subjectsList(count)+"_Visit1";
    [acceleration]  =  dataStorage(name);
    assignin('base',"acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1",acceleration(1:maxSamples, :));
    
    
    % visit 4
    name = subjectsList(count)+"_Visit4";
    [acceleration]  =  dataStorage(name);
    assignin('base',"acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4",acceleration(1:maxSamples, :));

    % visit 7
    name = subjectsList(count)+"_Visit7";
    [acceleration]  =  dataStorage(name);
    assignin('base',"acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7",acceleration(1:maxSamples, :));

end

%% Signal conversion

LSBvalue    =  0.0001;  % LSB = 5 / 2^16, because of a 5V ADC with 16bit resolution
baseline    =  0;



for count = 1:length(subjectsList)

    % visit 1
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1";
    acceleration    =   evalin('base', varName);
    assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1", signalConversion(acceleration, LSBvalue, baseline));
    
    
    % visit 4
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4";
    acceleration    =   evalin('base', varName);
    assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_4", signalConversion(acceleration, LSBvalue, baseline));

    % visit 7
    varName         =   "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7";
    acceleration    =   evalin('base', varName);
    assignin('base', "acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_7", signalConversion(acceleration, LSBvalue, baseline));

end






%% Normalization

timeStamp           =  1/64:1/64:length(("acc_raw_" + (matlab.lang.makeValidName(subjectsList(count))) + "_1"))/64;
timeStamp1          =  (timeStamp/60)/60; % hours




%% Velocity Calculation

velocitySignal    =  filteredData;
velocitySignal    =  cumtrapz(velocitySignal);


XvelocitySignal  =  XfilteredData;
XvelocitySignal  =  cumtrapz(XvelocitySignal);

YvelocitySignal  =  YfilteredData;
YvelocitySignal  =  cumtrapz(YvelocitySignal);

ZvelocitySignal  =  ZfilteredData;
ZvelocitySignal  =  cumtrapz(ZvelocitySignal);

subplotFunction([], velocitySignal, 1, 1, 1, 'Speed', 'Samples', 'Vel [m/s]', [], 1);

figure(2)
scatter3(XvelocitySignal, YvelocitySignal, ZvelocitySignal, '.', 'LineWidth', 2);
