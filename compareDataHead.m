function output = compareDataHead()

% compareDataHead.m
% 
% Function to compare two data.head input files to determine compatability
% when using a restart file with LIGGGHTS.
%
%
% Tim Churchfield
%
% Last edited: 14/11/2019


%% Function Input Variables
% image_folder  - Absolute path to directory containing images.
% frameRateInfo - Either specified frame rate (saved as double) or absolute
%                 path to data.head file where framerate is set based on
%                 the number of time-steps between images produced by 
%                 LIGGGHTS.
% project_name  - Name of video file created. If not included, the user is
%                 asked to provide a project name.
% target_folder - Output directory of video. If not included, the target
%                 directory is the same as the image directory