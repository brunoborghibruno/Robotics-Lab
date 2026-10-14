%% BRUNO BORGHI - Movisens data folder

% The scripts live in Post Processing/Movisens (git repo), the data in ErrorFields/Movisens (one subfolder per visit)
function dataFolder = MovisensDataFolder()

dataFolder  =  fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'Movisens');

end
