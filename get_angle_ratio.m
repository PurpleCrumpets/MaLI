% function [a_repose_avg] = get_angle(masks)

% get_angle.m
%
% Function to create obtain the average angle of repose for a set of ppm
% images produced during a LIGGGHTS DEM simulation
% Function to read VTK file from LIGGGHTS simulation and import the 
% data as a MATLAB table. As the output from the VTK file can change, the
% headings in the VTK file, and their ordere within the file must be
% checked against the function file. In its current form, the following
% variables are read into MATLAB sequentially:
%
%
% Tim Churchfield
%
% Last edited: 27/08/2019


clc
clear
close


%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_in  = char(key(1));
path_local_out = char(key(2));
path_hypnos    = char(key(3));
plink_cmd      = char(key(4));
psftp_cmd      = char(key(5));

projectname = '11_nP_40_rot1';


%% Obtain list of images from directory

if pathsep == ';' 
    image_folder = [path_local_out 'output\' projectname '\images\'];
%      image_folder = [path_local_out 'output\images\'];
%     image_folder = '.\test_images\'; % MATLAB
%         image_folder = 'D:\output\10_02\images';
    divider = '\';
elseif pathsep == ':'
    image_folder =  '~/Desktop/test_images'; % Octave 
    divider = '/';
else
    warning('Incorrect programming language type provided');
    return
end
dir_list = fullfile(image_folder, ('*.png'));
ppm_files = dir(dir_list);
num_files = length(ppm_files);

output = zeros(num_files,5);

for i = 1:num_files
    
    %% Import ppm image 
    ImPath = [ppm_files(i).folder divider ppm_files(i).name];
    Im = imread(ImPath);
    sum_all = size(Im,1)*size(Im,2);

    % Specify colour channels
    R = Im(:,:,1);
    G = Im(:,:,2);
    B = Im(:,:,3);


    %% Obtaining black pixels
    test1 = R == 0;
    test2 = G == 0;
    test3 = B == 0;

    ImBlack = and(test1,test2);
    ImBlack = and(ImBlack,test3);

    sum_black = sum(sum(ImBlack,1));


    %% Obtaining red pixels
    test1 = ~(R == G);
    test2 = ~(R == B);
    ImRed = or(test1,test2);

    sum_red = sum(sum(ImRed,1));


    %% Obtaining white pixels
    test1 = (R == G & R > 0 & G > 0);
    test2 = (R == B & R > 0 & B > 0);
    test3 = (G == B & G > 0 & B > 0);

    ImWhite = and(test1,test2);
    ImWhite = and(ImWhite,test3);

    sum_white = sum(sum(ImWhite,1));

    %% Test for unaccounted pixels
    missing = sum_all - (sum_black+sum_red+sum_white);

    if missing == 1
        warning([num2str(missing) ' pixel is not accounted for!']);
    elseif missing > 1
        warning([num2str(missing) ' pixels are not accounted for!']);
    end


    %% Output mask
    ImRed = ImRed*1;
    ImWhite = ImWhite*2;
    ImOut = ImRed+ImWhite;

    
    %% Obtain angle of repose for image 
    [a_repose, polyn, R2] = angle_of_repose_img(ImOut);
    
    
    %% Obtain PP:glass Ratio
    particleRatio = sum_red/sum_white;
    
    
    %% Results
    output(i,:) = [abs(a_repose), polyn, R2, particleRatio]; 
    
    
    
    
end

% Average dynamic angle of repose from images
a_repose_avg = sum(output(:,1))/num_files;
particleRatio_avg = sum(output(:,5))/num_files;

