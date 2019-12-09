% Make .avi film from .png images from Paraview 
clc
clear all

% Specifying Source Folder 
images_folder = ['M:\fwdf\members\church70\LIGGGHTS_Simulation\Backups\'...
    'Cluster_Simulations\Sim2\Images3D_2'];
if ~isfolder(images_folder)
    error_msg = sprintf('Source file location does not exist: \n %s'...
        , images_folder); 
    uiwait(warndlg(error_msg));
    return;
end

% Input Loop
j = [];
while isempty(j)
    
    % Naming Project
    prompt = 'Please provide a name for the project: ';
    str = input(prompt,'s');
    str1 = '.avi';
    str = strcat(str,str1);

    % Checking if Project already exists
    p = [];
    while isempty(p)
        if isfile(num2str(str))
            prompt = ['File name already exists' ...
                ', do you wish to continue? [Y/N] '];
            overwrite = input(prompt,'s');
            if overwrite == 'Y' || overwrite == 'y'
                disp('Overwriting existing file');
                j = 1;
                p = 1;
            elseif overwrite == 'N' || overwrite == 'n'
                disp('File not created');
                p = 1;
            else
                disp('Invalid input, please try again');
            end
        else
            j = 1;
            p = 1;
        end
    end
end

% Get Directory Listing 
dir_list = fullfile(images_folder, ('*.png'));
png_files = dir(dir_list);

% Opening Video Writer
video = VideoWriter(num2str(str));
video.FrameRate = 10;
open(video);

% Loop for adding all images to video
for frame_count = 1:length(png_files)
    % Building full filename
    file_name = png_files(frame_count).name;
    full_file_name = fullfile(images_folder, file_name);
    % Display image name in command window 
    fprintf(1, 'Now reading %s\n', full_file_name);
    % Display image in an axes control
    current_image = imread(full_file_name);
%     imshow(current_image); % Display image
%     drawnow; % Force display to update
    % Writing frame to file
    writeVideo(video, current_image);
end

% Closing video writer to finish film
close(video);
close 
dis = ['File ', num2str(str), ' created'];
disp(dis);