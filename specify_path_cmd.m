function key = specify_path_cmd

% specify_path_cmd.m
%
% Function to provide the three primary paths needed for LIGGGHTS: the
% local input path, the local output path and the project path on Hypnos.
% Based on these three absolute paths, all other necessary directories are 
% found or created.
%
% The username for the user's Hypnos login is also specified, providing the
% necessary primary commands needed for giving commands to Hypnos and
% transferring data betweeen Hypnos and the local computer.
%
%
% Tim Churchfield
%
% Last edited: 05/11/2019


%% Function Output Variables
% path_local_in  - Absolute path to main input directory on local pc
% path_local_out - Absolute path to directory to contain the 'output'
%                  directory
% path_hypnos    - Absolute path to LIGGGHTS directory on cluster
% plink_cmd      - Primary Hypnos command for 
% psftp_cmd      - Primary Hypnos command for file transfer

%% Function Output Variables Format Example
% path_local_in  = 'M:\...\MATLAB_Integration\';              (Must end: \) 
% path_local_out = 'D:\';                                     (Must end: \)
% path_hypnos    = '~/LIGGGHTS-PUBLIC/';                      (Must end: /)

%% User Input
% Specify Username 
username = 'church70';

% Specify Absolute Paths
path_local_in = cellstr('M:\fwdf\members\church70\MaLI\'); % Must end: \
path_local_out = cellstr('D:\');                                       % Must end: \
path_hypnos = cellstr('~/MYLIGGGHTS/');                                % Must end: /

%% Create plink, psftp Commands
plink_cmd = cellstr(['plink -no-antispoof -ssh ' username '@hypnos5.fz-rossendorf.de']);
psftp_cmd = cellstr(['psftp ' username '@hypnos5.fz-rossendorf.de']);


%% Output Array

key = [path_local_in; path_local_out; path_hypnos; plink_cmd; psftp_cmd];

return