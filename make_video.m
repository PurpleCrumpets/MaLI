function make_video(image_folder,frameRateInfo,project_name,target_folder)

% make_video.m
% 
% Function to create an AVI film from PNG images.
%
%
% Tim Churchfield
%
% Last edited: 12/11/2019


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


%% Obtain Frame Rate
if isa(frameRateInfo,'char') == 1 || isa(frameRateInfo,'string')
    fileID = fopen([frameRateInfo, 'data.head'],'r');
    
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
    
elseif isa(frameRateInfo,'double') == 1
    frameRate = frameRateInfo;
    
else
    warning('Input for frameRateInfo is not a valid input');
    
end

%% Prepare Workspace

% Check if Image Directory Exists
if ~isfolder(image_folder)
    error_msg = sprintf('Source file location does not exist: \n %s'...
        , image_folder); 
    uiwait(warndlg(error_msg));
    return;
end

% Provide target folder if not provided
if nargin < 4
    target_folder = image_folder;
end

% Provide project name
l = 0;
j = [];
while isempty(j)
    
    k = [];
    while isempty(k)
        
        if exist('project_name','var') == 0
%         if nargin < 3
            % Name Project
            if l == 1
                prompt = 'Please provide a new filename for the video: ';
            else
                prompt = 'Please provide a filename for the video: ';
            end
            str = input(prompt,'s');
            str1 = '.avi';
            project_name = strcat(str,str1);
        else
            project_name = strcat(project_name,'.avi');
        end
        
        % Check if project name contains a space
        if contains(project_name, ' ')
            fprintf('\n');
            disp('Video filename contains a space...'); 
            disp(['Please specify a new video filename '...
                '(use underscores ''_'' instead of spaces)...']);
            fprintf('\n');
            project_name = [];
        else
            k = 1;
        end
    end    

    % Check if Project already exists
    p = [];
    while isempty(p)
        if isfile(num2str([target_folder, project_name]))
            prompt = ['File name already exists' ...
                ', do you wish to overwrite? [Y/N/Cancel] '];
            overwrite = input(prompt,'s');
            if strcmpi(overwrite,'Y') || strcmpi(overwrite,'yes')
                disp('Overwriting existing file...');
                j = 1;
                p = 1;
            elseif strcmpi(overwrite,'N') || strcmpi(overwrite,'no')
                disp('File not created...');
                p = 1;
                j = [];
                l = 1;
                clear project_name
            elseif strcmpi(overwrite,'C') || strcmpi(overwrite,'cancel')
                disp('Video creation terminated...');
                return
            else
                disp('Invalid input, please try again');
            end
        else
            j = 1;
            p = 1;
        end
    end
end

disp(['Creating ' project_name '...']);
%% Sort Image File Names in png_files by Timestep

% % Get Directory Listing 
% dir_list = fullfile(image_folder, ('*.png'));
% png_files = dir(dir_list);
%  
% Q = regexp({png_files.name},'\d+','match');
% 
% num_files = length(png_files);
% ts = cell(num_files,1);
% 
% % Remove redundant 1st column in each nested cell if exists
% Q_size = size(Q{1},2);
% 
% if Q_size == 2
%     for i = 1:num_files
%         ts{i} = Q{i}{2};    
%     end
% elseif Q_size == 1
%         for i = 1:num_files
%         ts{i} = Q{i};    
%         end
%         ts = string(ts);
% end
% 
% ts = str2double(ts);
% [ts name_order] = sort(ts);
% 
% png_files = png_files(name_order);

%% Alternative Method to Sort Images 
% Get Directory Listing 

% image types
% imageType = {'ppm'; 'jpeg'; 'png'};
% 
% for i = 1:size(imageType,1)
%   imageStruct = dir(fullfile(pathProject,'images',['*.', imageType{i}]));
%   numFiles = length(imageStruct);
% 
%   if numFiles ~= 0
%       imageType = imageType{i};
%       break 
%   end
% end


% image types
imageType = {'ppm'; 'jpeg'; 'png'};

for i = 1:size(imageType,1)
    dir_list = fullfile(image_folder, (['*.',imageType{i}]));
    png_files = dir(dir_list);
    num_files = length(png_files);

    if num_files ~= 0
        imageType = imageType{i};
        break 
    end
end

if num_files == 0
    warning('No images found, failed to make video...');
    return 
end



% dir_list = fullfile(image_folder, ('*.png'));
% png_files = dir(dir_list);
% if isempty(png_files)
%     warning('No images found, failed to make video...');
%     return
% end
% num_files = length(png_files);

% Find leading repeating characters
test = char(png_files.name);
test = diff(test);
test = any(test,1);
test = find(test,1,'first');
common = png_files(1).name(1:test-1);

% Obtaining timesteps from image file names
image_names = {png_files.name};
timesteps = regexp(image_names,['(?<=' common ')\d*(?=\.', imageType, ')'],'match')';
timesteps = str2double(cat(1,timesteps{:}));

% Sorting png_files by timestep 
[~,timesteps_order] = sort(timesteps);
png_files = png_files(timesteps_order);


%% Create Video

% Open Video Writer
video = VideoWriter([target_folder,num2str(project_name)]);
video.FrameRate = frameRate;
open(video);

% Loop for adding all images to video
for frame_count = 1:num_files
    % Building full filename
    file_name = png_files(frame_count).name;
    full_file_name = fullfile(image_folder, file_name);
    
    % Display image name in command window 
%     fprintf(1, 'Now reading %s\n', full_file_name);

    % Display image in an axes control
    current_image = imread(full_file_name);
    
    % Writing frame to file
    writeVideo(video, current_image);
end

% Closing video writer to finish film
close(video);
close 
dis = ['File ', num2str(project_name), ' created'];
disp(dis);

return