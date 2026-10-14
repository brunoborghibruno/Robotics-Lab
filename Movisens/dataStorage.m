%% BRUNO BORGHI - Data Storage

function  [acc_raw, angRate_raw, temp_raw, press_raw, SOC_raw, stepCount_raw, marker]  =  dataStorage(name)



fileExt         =  'bin';
functionFolder  =  MovisensDataFolder;    % ErrorFields/Movisens (the data, not this script folder)
prompt          =  {'INSERT NAME OF THE FOLDER WITH THE DATA : ', 'WRITE "csv" or "bin" TO MATCH THE DATA .ext : ', 'INSERT THE FOLDER PATH WITH THE FUNCTIONS AND DATA USED : '};
dlgtitle        =  'Input';
dims            =  1;
opts            =  'on';
if (nargin>0)
    definput        =  {name, fileExt, functionFolder};
else
    definput        =  {'E-1_Visit1', fileExt, functionFolder};
end
inputVariable   =  inputdlg(prompt, dlgtitle, dims, definput, opts);
folderName      =  inputVariable{1,1};
fileExt         =  char(inputVariable{2,1});
functionFolder  =  char(inputVariable{3,1});


% Creation of the right folder directiory name
folder  =  functionFolder + "/" + folderName;

% Insert in the actual path the functions needed to read the raw files (ExtractFromCSV.m and hrdload.m)
cd(char(functionFolder));
addpath(genpath(char(folder)));
% folderToRemove1  =  functionFolder + "/RawData";
% folderToRemove2  =  functionFolder + "/BackUp";
% rmpath(folderToRemove1);
% rmpath(folderToRemove2);
cd(functionFolder);

if (fileExt == 'csv')
    % Acceleration
    acc_raw = readmatrix('acc.csv');

    if (exist('AccForward.csv'))
        acc  =  [csvread('AccForward.csv'), csvread('AccRight.csv'), csvread('AccDown.csv')];
    end

    % Angular rate
    angRate_raw = readmatrix('angularrate.csv');
    angRate_raw = angRate_raw';

    % Temperature
    temp_raw  =  readmatrix('temp.csv');

    % Pressure
    press_raw  =  readmatrix('press.csv');

    % State of Charge
    SOC_raw  =  readmatrix('press.csv');

    % MovementAcc
    movAcc_raw  =  readmatrix('movementacceleration_live.csv');

    % StepCount
    stepCount_raw  =  readmatrix('stepcount_live.csv');

    % Marker
    if (exist('marker.csv'))
        marker_raw  =  readtable('marker.csv');
        marker  =  table2array(marker_raw(:,1));
    else
        marker = 0;
    end

else

    % Acceleration
    fileID   =  fopen('acc.bin', 'rb');
    count    =  [3 inf]; % 1st column = Z axis; 2nd column = X axis; 3rd column = -Y
    acc_raw  =  fread(fileID, count, 'int16')';  % uint64 is 64bits (8 bytes)


    if (exist('AccForward.csv'))
        acc  =  [csvread('AccForward.csv'), csvread('AccRight.csv'), csvread('AccDown.csv')];
    end

    % Angular Rate
    angRate_raw  =  fopen('angularrate.bin', 'rb');
    count      =  [3 inf];
    angRate_raw  =  fread(angRate_raw, count, '*int16');


    % Temperature
    temp_raw  =  fopen('temp.bin', 'rb');
    temp_raw  =  fread(temp_raw, '*int16');

    % Pressure
    press_raw  =  fopen('press.bin', 'rb');
    press_raw  =  fread(press_raw, '*int16');

    % State of Charge
    SOC_raw  =  fopen('press.bin', 'rb');
    SOC_raw  =  fread(SOC_raw, '*int16');

    % MovementAcc
    movAcc_raw  =  fopen('movementacceleration_live.bin', 'rb');
    movAcc_raw  =  fread(movAcc_raw, '*int16');

    % StepCount
    stepCount_raw  =  fopen('stepcount_live.bin', 'rb');
    stepCount_raw  =  fread(stepCount_raw, '*int16');

    % Marker
    if (exist('marker.csv'))
        marker_raw  =  readtable('marker.csv');
        marker  =  table2array(marker_raw(:,1));
    else
        marker = 0;
    end

end
end