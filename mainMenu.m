% Main menu for manipulating and visualizing measurement data
%% Add function paths, clear command window & variables
clc;
clear;
addpath('uiFuns');
addpath('dataFuns');
protDir = uigetdir('', 'Select Folder of protected functions');
addpath(protDir);

% Initialize variables
n = 14; % n^2 = number of S-parameters in measurements
dataPath = '';
measPaths = {};

%% Main menu loop
% Load menu text
menuText = fileread('menu.txt');
choice = 0;
while choice ~= 99
    disp(menuText);
    choice = input('Please enter your choice\n');
    switch choice
        case 1 % Select path to data
            dataPath = uigetdir('', 'Select path to measurement data');
        case 2 % Select measurements
            measPaths = uiSelectMeas(dataPath);
        case 3 % Load measurements
            dataSet = loadAllData( measPaths );
        case 4 % Plot loaded measurements
            uiHugePlot(dataSet);
        case 99
            disp('Goodbye');
        otherwise
            disp('Invalid choice');
    end
end