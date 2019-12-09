%% calibrationAngleRangeScript.m
%
% Script to obtain the output angles of repose, and their corresponding
% interaction parameters from each simulation subdirectory from calibration
% using DEcalioc. A boxplot and line plot of the angles of repose are
% produced. 
% 
% Tim Churchfield
%
% Last Edited: 09/12/2019
%
%% Variable Dictionary
%
% -- Input --
%
% boxTitle          - figure title
% pathCalibration   - path to calibration simulation directory
% RPMLabel          - boxplot category headings
% xAxisLabel        - boxplot x-axis label
% yAxisLabel        - boxplot, line plot y-axis label
%
% -- Output --
%
% AverageOutputData - arithmetic (1) and geometric (2) mean angles 
% InputData         - matrix of input interaction parameters
% MaxMinInput       - interaction parameters for the minimum (1-6) and
%                     maximum (7-12) dynamic angles of repose
% OutputData        - matrix of ouput dynamic angles of repose
% SortedOutputData  - sorted dynamic angles of repose, each sorted
%                     separately 
%
% -- Other --
%
% i                 - loop counter
% idOutput          - rows of listing corresponding to MaxMinOuput
% j                 - loop counter
% listing           - contents of calibration simulation directory
% listingInput      - csv files in subdirectory
% listingOutput     - txt files in analysis subdirectory
% fileID            - file ID from fopen command
% pathInput         - path to input file
% pathOutput        - path to output file
% tline             - line from output data text file


%% Prepare Workspace
clc
% clear
close all
fclose('all');


%% User Input
pathCalibration = 'D:\calibration\DEcaliocTest\DEcalioc\optim\rotatingdrum20';
% pathCalibration = 'D:\calibration\DEcaliocTest\DEcalioc\optim\rotatingdrum35';
% pathCalibration = 'D:\calibration\DEcaliocTest\DEcalioc\optim\rotatingdrum50';

% Boxplot Settings
boxTitle = '20% Filling Degree Calibration Range';
% boxTitle = '35% Filling Degree Calibration Range';
% boxTitle = '50% Filling Degree Calibration Range';

RPMLabels = {'5 av','5 nnl','20 av','20 nnl','40 av','40 nnl'};
xAxisLabel = 'RPM, Angle Type';
yAxisLabel = 'Dynamic Angle of Repose (°)';


%% Data Path 
listing = dir(pathCalibration);
listing = listing(~ismember({listing.name},{'.','..'}));


%% Import Output Data
lengthList = 100; % length(listing);

OutputData = cell(lengthList,7);


for i = 1:lengthList
    pathOutput = fullfile(pathCalibration, listing(i).name, 'analysis');
    listingOutput = dir(fullfile(pathOutput, '*.txt'));
    fileID = fopen(fullfile(pathOutput, listingOutput.name),'r');
    
    % Read file results cell A
    j = 1;
    tline = fgetl(fileID);
    try
        OutputData{i,j} = str2double(tline);
    catch
        OutputData{i,j} = tline;
    end

    while ischar(tline)
        j = j+1;
        tline = fgetl(fileID);
        try
            OutputData{i,j} = str2double(tline);
        catch
            OutputData{i,j} = tline;
        end
    end
end

% Close file
fclose(fileID);

% Remove excess column
OutputData(:,end) = [];

% Convert to Matrix
OutputData = cell2mat(OutputData);

% Arithmetic Mean Angle
AverageOutputData(:,1) = mean(OutputData,1); 

% Geometric Mean Angle
AverageOutputData(:,2) = geomean(OutputData,1);

% Sort Results (all)
SortedOutputData = sort(OutputData);

% Sort Results (by first column)
SortedOutputDataColumn = sortrows(OutputData);

% Quartiles
QuartilesData = quantile(OutputData,3); 


%% Import Input Data

InputData = zeros(lengthList,21);

for i = 1:lengthList
    pathInput = fullfile(pathCalibration, listing(i).name);
    listingInput = dir(fullfile(pathInput, '*.csv'));
    InputData(i,:) = csvread(fullfile(pathInput, listingInput.name));
end


%% Max/Min Angles Inputs

idOutput = zeros(2,6);
MaxMinInput = zeros(12,21);


% Correspnding output rows of minimum angles
for i = 1:size(OutputData,2)
    [~,idOutput(1,i)] = ismember(SortedOutputData(1,i),OutputData(:,i));
end

for i = 1:size(OutputData,2)
    MaxMinInput(i,:) = InputData(idOutput(1,i),:); 
end

% Correspnding output rows of maximum angles
for i = 1:size(OutputData,2)
    [~,idOutput(2,i)] = ismember(SortedOutputData(end,i),OutputData(:,i));
end

for i = 1:size(OutputData,2)
    MaxMinInput((size(OutputData,2)+i),:) = InputData(idOutput(2,i),:); 
end


%% Figures

% create boxplots
figure(1);
boxplot(OutputData,RPMLabels)
title(boxTitle);
xlabel(xAxisLabel)
ylabel(yAxisLabel)

% Overlay means
hold on
plot(AverageOutputData(:,1), 'xk') 
plot(AverageOutputData(:,2), '+k') 
hold off
legend('Arithmetic','Geometric','Location','best')

% Simple Line Plot for all sorted
figure(2)
plot(SortedOutputData)
legend(RPMLabels,'Location','best')
xlabel('Sample (-)')
ylabel(yAxisLabel)
title([boxTitle, ': All Sorted'])

% Line plot for sorted by first column
figure(3)
plot(SortedOutputDataColumn)
legend(RPMLabels,'Location','best')
xlabel('Sample (-)')
ylabel(yAxisLabel)
title([boxTitle, ': Sorted by 5 RPM, Average'])

% figure(3)
% plot(sortedOutputData(1:10,:))
% legend(RPMLabels)
% xlabel('Sample (-)')
% ylabel(yAxisLabel)
% title(BoxTitle)

% Histograms
% for i = 1:size(A,2)
%     j = i+2;
%     figure(j)
%     histogram(A(:,i))
% end