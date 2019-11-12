function frameRate = getFrameRate(projectPath)

% getFrameRate.m
% 
% Function to obtain frame rate from data.head project file.
%
% Tim Churchfield
%
% Last edited: 15/10/2019


%% Function Input Variables
% projectPath - absolute path to project directory containing data.head
%               file.


%% Function Output Variables
% frameRate   - Frame rate of images produced. 


%% Obtain Frame Rate
fileID = fopen(fullfile(projectPath,'data.head'),'r');

if fileID == -1
    error('data.head file cannot be opened');
end

str = fgets(fileID);  

% Thermo-step data
while ~startsWith(str,'variable thermostep')
    str = fgets(fileID);
end

frameRate = sscanf(str,'variable thermostep equal %f');
frameRate = 1/frameRate; 

fclose(fileID);
    

return