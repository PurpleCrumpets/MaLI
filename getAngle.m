function [vidmasks, angleFigure] = getAngle(projectname,angleModel,dispFig)
%
% getAngle.m
%
% Script to create a sequence of masks from particle images produced by
% LIGGGHTS and obtain the angle of repose for each image. The change in the
% angle of repose is plotted with time.

% mention flaw in terms of reading image types when building structure
% 
% Tim Churchfield
%
% Last Edited: 16/10/2019
%
%% Variable Dictionary




%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_in  = char(key(1));
path_local_out = char(key(2));

pathProject = fullfile([path_local_out 'output'],projectname);


%% Obtain List of Images from Directory
if exist('imageType','var') == 0 || isempty(imageType) == 1
    imageType = {'ppm'; 'jpeg'; 'png'};
end


for i = 1:size(imageType,1)
    imageStruct = dir(fullfile(pathProject,'images',['*.', imageType{i}]));
    numFiles = length(imageStruct);

    if numFiles ~= 0
        imageType = imageType{i};
        break 
    end
end

if isempty(imageStruct)
    warning('No images found...')
    return
end 


%% Sort Images Chronologically 
imageStruct = sortImageStruct(imageStruct);


%% Obtain Image Resolution (memory preallocation purposes)
info = imfinfo(fullfile(imageStruct(1).folder, imageStruct(1).name));


%% Create Sequence of Masks
vidmasks = zeros(info.Height,info.Width,numFiles,'int8'); % Reduce mem req
parfor i = 1:numFiles
    vidmasks(:,:,i) = createMask(imageStruct(i));
end
    

%% Create Anaylsis Directory
if ~exist(fullfile(pathProject,'analysis'), 'dir')
   mkdir(pathProject,'analysis')
end


%% Save vidmasks
sizeVidmasks = whos('vidmasks');
tail = '_vidmasks.mat';

if sizeVidmasks.bytes >= 2e+9
    disp('Saving vidmasks as compressed v7.3 MAT file...');
    save(fullfile(pathProject,'analysis',...
        [projectname tail]),'vidmasks','-v7.3');
else
    disp('Saving vidmasks to MAT file...');
    save(fullfile(pathProject,'analysis',[projectname tail]),'vidmasks');
end


%% Get Frame Rate
frameRate = getFrameRate(pathProject);


%% Obtain Curve Properties
results = curveProperties(vidmasks,frameRate,angleModel);
% Made minor change to curveProperties to get the time right.


%% Plot Results

% Get plot colours
colors = distinguishable_colors(8);

% Create plot
if strcmpi(dispFig,'yes') || strcmpi(dispFig,'y')
    angleFigure = figure('Position', get(0, 'Screensize')); 
else
    angleFigure = figure('Position', get(0, 'Screensize'),...
        'visible', 'off');
end

hold on
plot([results.time],[results.angle_av],'Color',colors(1,:))
plot([results.time],[results.angle_nnl],'Color',colors(2,:));

% Labels, title and legend
xlabel('Time (s)')
ylabel('Dynamic Angle of Repose (°)')
legend('Average','Non-linear','Location','Best');
projectTitle = insertBefore(projectname,"_","\");
title([projectTitle ': Dynamic Angle of Repose with Time']);
set(gca,'XMinorTick','on','YMinorTick','on')

%% Save Figure

% Save png file
saveas(angleFigure, fullfile(pathProject,'analysis',...
    [projectname '_anglePlot_1']), 'png');

% Make .fig visable when re-opening upon saving
set(angleFigure, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
saveas(angleFigure, fullfile(pathProject,'analysis',...
    [projectname '_anglePlot']), 'fig'); 

% Alternative save method for png
F = getframe(angleFigure);
imwrite(F.cdata, fullfile(pathProject,'analysis',...
    [projectname '_anglePlot_2.png']), 'png');

disp('Dynamic Angle of Repose Figure Saved!');


%% load file test
% test = load(fullfile(pathProject,'analysis',[projectname tail]));
% test = test.vidmasks;

return