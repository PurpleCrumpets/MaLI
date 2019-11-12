%% save_Decalioc_optim
%
% Script to download LIGGGHTS DEM project from the computing cluster. Once
% the data is downloaded, any images found are converted from PPM to PNG to
% reduce the total project size. The VTK files are imported into MATLAB 
% 
% Tim Churchfield
%
% Last Edited: 18/09/2019
%
%% Variable Dictionary
%
% User Input
% project    - name of primary DEcalioc directory
% path       - local directory containing project
% sim_name   - name of LIGGGHTS model
%
% Output
% numFiles   - number of optimisation directories
% output     - matrix of optimisation results
% path_csv   - absoulte path to optimisation output file: params.csv 
% path_optim - absolute path to directory containing optimisation output
% str        - .csv output
%
% Other
% fileID     - load params.csv
% k          - loop count
% test       - test for empty rows in output

%% Prepare Workspace
clc
close all
clear

%% User Input
% project = 'DEcalioc1model';
% path = 'D:\DEcalioc_output\';
% sim_name = 'Lift100';

% project = 'DEcalioc1model_no_ts';
% path = 'D:\DEcalioc_output\';
% sim_name = 'Lift100';

project = 'DEcalioc2models';
path = 'D:\DEcalioc_output\';
sim_name = 'Lift100';
%sim_name = 'Lift102';

%% Obtain Output
path_optim = [path project '\DEcalioc\optim\' sim_name];

optim_dir = dir(path_optim);
numFiles = length(optim_dir);

output = zeros(numFiles,5);
for k = 1:numFiles
    path_csv = [path_optim '\' optim_dir(k).name '\params.csv']; 
    fileID = fopen(path_csv,'r');
    
    if fileID > -1
        str = fgets(fileID);
        str = str2double(split(str,','))';
        output(k,:) = str; 
        fclose(fileID);
    end
end

%% Remove Surplus Rows
test = all(output,2);
output = output(test,:);

%% Save Output
xlswrite([path_optim '\output.xlsx'],output);