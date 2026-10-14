%% BRUNO BORGHI     



%% STORE THE DATA AND PLOT SPEED AND ACCELERATION

accelerationData_AllSessions    =   load('accelerometerData.mat');



%% Visit #1

acceleration_visit_1    =   accelerationData_AllSessions.accelerometerData.Visit1.AccelerationMagnitude;
speed_visit_1           =   accelerationData_AllSessions.accelerometerData.Visit1.Speed;



%% Visit #4

acceleration_visit_4    =   accelerationData_AllSessions.accelerometerData.Visit4.AccelerationMagnitude;
speed_visit_4           =   accelerationData_AllSessions.accelerometerData.Visit4.Speed;




%% Visit #7

acceleration_visit_7    =   accelerationData_AllSessions.accelerometerData.Visit7.AccelerationMagnitude;
speed_visit_7           =   accelerationData_AllSessions.accelerometerData.Visit7.Speed;


%% Calculate hours instead of samples

timeStamp           =  1/64:1/64:length(acceleration_visit_1)/64;
timeStamp1          =  (timeStamp/60)/60; % hours



%% Data plot



figure (1)

subplotFunction(timeStamp1, speed_visit_1, 1, 1, 1, 'Speed', 'Hours', 'Speed [m/s]', [], 1);
hold on
subplotFunction(timeStamp1, speed_visit_4, 1, 1, 1, 'Speed', 'Hours', 'Speed [m/s]', [], 2);
hold on
subplotFunction(timeStamp1, speed_visit_7, 1, 1, 1, 'Speed', 'Hours', 'Speed [m/s]', [], 3);
lgnd = legend('Visit #1', 'Visit #4', 'Visit #7');
lgnd.FontSize   =   20;



% print('SpeedPlotForVisit1_vs_Visit4_vs_Visit7', '-dpng', '-r600')
