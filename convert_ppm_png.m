function convert_ppm_png(folder)

% read_particle_vtk.m
% 
% Function to select all PPM images in a folder and convert them to PNG
% format. The older PPM images are then deleted.
%
%
% Tim Churchfield
%
% Last edited: 20/08/2019


%% Function Input Variables
% folder - Absolute path to directory containing ppm images to be converted


%% Get Directory Listing 
dir_list = fullfile(folder, ('*.ppm'));
ppm_images = dir(dir_list);


%% Convert Images and Remove Old File

parfor k = 1:length(ppm_images)
    
    % Image name and absolute path
    image_name = ppm_images(k).name;
    path_image_name = fullfile(folder,image_name);
    
    % New image name and absolute path
    image_name_new = strrep(image_name,'.ppm','.png');
    path_image_name_new = fullfile(folder,image_name_new);
    
    % Creating new image
    image_temp = imread(path_image_name);
    imwrite(image_temp,path_image_name_new);
    
    % Deleting old ppm image
    delete(path_image_name);
    
end

return