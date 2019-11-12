%% make_omegaiter.m
%
% Script to create text file containing an alternating list of the rpm of
% the drum and the corresponding time that this occurs. The output is used
% in the LIGGGHTS simulation of the rotating drum. The file is saved in the
% 'template' folder.
% 
% It is assumed that the change inrpm between each time provided is linear,
% corresponding to a constant acceleration of the drum.
% 
% Tim Churchfield
%
% Last Edited: 06/09/2019
%
%
%% Variable Dictionary

% User Input Variables
% time          - points in time where drum rpm is specified (seconds)
% rpm           - rpm of drum at corresponding time (rpm)


% Output Variables
% output        - output array of alternating time, rpm of drum


% Other
% key           - return output of function specify_path_cmd
% path_local_in - absolute path to primary MATLAB/LIGGGHTS input directory
% steps         - size of array rpm


%% Prepare Workspace
clear 
close
clc


%% User Input
time = [0; 1; 3; 5; 6];
rpm  = [0;40;40;40; 0];

%% Loading Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_in  = char(key(1));


%% Test if Input is Valid
if ~(size(rpm,1) == size(time,1))
    warning('Size of rpm does not match time');
    return
end


%% Combine Arrays
steps = size(rpm,1);
output = zeros(2*steps,1);

for i = 1:steps 
    output(2*i-1) = time(i); % Save times
    output(2*i) = rpm(i);    % Save corresponding rpm of drum
end


%% Save Output to File
save([path_local_in 'start\template\rpm_drum.txt'],'output','-ascii');
disp('File rpm_drum.txt created!');

