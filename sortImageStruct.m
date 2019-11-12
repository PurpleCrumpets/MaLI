function output = sortImageStruct(imageStruct) 

% sortImageStruct.m
% 
% Function to reorder structure of image files by natural sort order.
%
% Tim Churchfield
%
% Last edited: 14/10/2019


%% Function Input Variables
% imageStruct - structure of image files produced from 'dir' command


%% Function Output Variables
% output      - structure of image files order by natural sort order 


%% Obtain image file extension
numFiles = length(imageStruct);
ext = cell(numFiles,1);
for i = 1:numFiles
    [~,~,ext{i}] = fileparts(imageStruct(i).name);
end

test = sum(strcmp(ext,ext(1)))/numFiles;
if test == 1
    ext = char(ext(1));
else
    warning('Multiple image file extensions found!')
    return
end


%% Find leading repeating characters
test = char(imageStruct.name);
test = diff(test);
test = any(test,1);
test = find(test,1,'first');
common = imageStruct(1).name(1:test-1);


%% Obtain timesteps from image file names
imageNames = {imageStruct.name};
timesteps = regexp(imageNames,['(?<=' common ')\d*(?=\' ext ')'],'match')';
timesteps = str2double(cat(1,timesteps{:}));


%% Sort ImageStruct by timestep 
[~,timesteps_order] = sort(timesteps);
output = imageStruct(timesteps_order);


return