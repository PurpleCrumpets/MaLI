%% Core Data
%
% input.m
%
% Script to provide the necessat information needed to utilise scripts that
% connec to the cluster.
%






%% Directory Set-up
% The MATLAB/LIGGGHTS functions utilise absolute paths to find the
% necessary files and folders they need or as save locations. In order for
% the functions to work as intended, the user must provide the absolute 
% path for the two primary working directories; one on the local computer
% and the other on the cluster. 


% Cluster Working Directory
%
% The working directory for the cluster MUST be the primary LIGGGHTS
% folder. In a default installation of LIGGGHTS, this is:~/LIGGGHTS-PUBLIC/
%
% Simulations are saved in ~/LIGGGHTS-PUBLIC/simulations/ under their 
% respective project name. If it doesn't already exist, the simulations
% directory is automatically created upon initialisation or restart of a 
% project.
% 
% The majority of files are uploaded from the local machine, with the only
% exception being the lmp_auto file; this is automatically retrieved from
% ~/LIGGGHTS-PUBLIC/src/, assuming it has already been created using the
% 'make auto' command that would have been run during the set-up of
% LIGGGHTS. 


% Local Computer Working Directory
%
% The working directory for the local computer is more flexible in its
% location. To prevent any unexpected behaviour, it is recommended that the
% chosen path contains no spaces in its address (underscores '_' are a good
% substitute.
%
% The same MATLAB script is used for initialising and restarting a
% simulation with the only difference being the additional restart file
% needed for the latter. To prevent any mix-up between the two, each uses a
% separate directory within the local working directory titled: 
% 'initialisation' and 'restart' respectively. These are both created and
% populated with the following items by the user:
%
% - job.script
% - job2.script
% - job3.script
% - template (a directory)
%
% The first three are bash scripts that are used by the cluster during the
% set-up of the simulation. The template directory contains all the ne





% Tim Churchfield
%
% Last Edited: 01/08/2019
%
%
%% Variable Dictionary
% path_local  - Absolute path to directory on local computer that the
% path_hypnos
% projectname
% ssh_cmd
% psftp_cmd


%% Preparing Workspace
clc
clear


%% Primary Information Needed for all Functions
path_local = 'M:\fwdf\members\church70\MATLAB_Integration\initialisation\'; % Must end: \
path_hypnos = '~/MYLIGGGHTS/simulations/'; % Must end: /
projectname = 'mc8'; 
% When projectname is not in use, please leave as: ''. Must be one word.
ssh_cmd = 'plink -no-antispoof -ssh church70@hypnos5';
psftp_cmd = 'psftp church70@hypnos5';

