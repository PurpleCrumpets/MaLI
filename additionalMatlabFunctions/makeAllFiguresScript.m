%% makeAllFiguresScript.m
%
% Script to merge 
% Script to connect to Hypnos using SSH to run a LIGGHTS DEM simulation.
% The simulation is periodically stopped and data stransferred to MATLAB by
% SCP. Analysis of the resulting images is conducted to determine if the 
% 
% Tim Churchfield
%
% Last Edited: 17/10/2019
%
%% Variable Dictionary




%% Prepare Workspace
clc
clear
close all
fclose('all');


%% User Input Variables

% General
% projectname = {'11_P_40_zoom_2';'11_nP_40_zoom_2';...
%                '11_P_02_zoom_2';'11_nP_02_zoom_2'};          

% projectname = {'11_P_40_rot1';'11_nP_40_rot1';...
%                '11_P_02_rot1';'11_nP_02_rot1'};


projectname = {'11_nP_40_rot1'}; % This file doesn't want to play ball 

% projectname = 'testShort';

% projectname = {'11_nP_02_rot1';'11_nP_02_zoom_2'};
           
dispFig = 'yes';
 remakeFig = 'no';
remakeFig = 'yes';

% getAngle function inputs
angleModel = 'threeAngles';

% freqDist function inputs
classes = 15;
timings = [0,100];
chartType = 'line';
VTKfile = 'rotating';
% chartType = 'bar';
% VTKfile = 'all';


%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_out = char(key(2));


%% Create Figure Data
numFig =  length(findobj('type','figure')); % Number of open figures
projectnameSize = size(projectname,1);

% Format project name
if strcmpi(remakeFig,'yes') || strcmpi(remakeFig,'y')
    disp('Figures made/remade');
    
    for j = 1:projectnameSize
        
        if isa(projectname,'char')
            projectnameLoop = projectname;
        else
            projectnameLoop = char(projectname(j));
        end

        disp(['Loop count ' num2str(j) ' (Project: ' projectnameLoop ')']);

        % freqDist
%         [~,~] = freqDist(projectnameLoop,VTKfile,timings,...
%             classes,chartType,dispFig);

        % getAngle
        [~,~] = getAngle(projectnameLoop,angleModel,dispFig);
        
        close all

    end
    
elseif strcmpi(remakeFig,'no') || strcmpi(remakeFig,'n')
    disp('Figures not made/remade');
    
else
    error('remakeFig input invalid')
    
end

%% Continue if More than One Project

if projectnameSize < 2
    return 
end


%% Merge getAngle Figures

newLegend = cell(2*projectnameSize,1); % Blank legend
figCount = numFig(end); % Original number of open figures

for i = 1:projectnameSize
    
    figCount = figCount+1;
    
    if isa(projectname,'char')
        projectnameLoop = projectname;
    else
        projectnameLoop = char(projectname(i));
    end
    
    pathProject = fullfile(path_local_out,'output',projectnameLoop);
    
    % vidmasks
    figStructVid(i) = openfig(fullfile(pathProject,'analysis',...
        [projectnameLoop '_anglePlot.fig']),'visible');
    
    % Update Legend
    newLegend{2*i-1,1} = [projectnameLoop ': Average'];
    newLegend{2*i,1} = [projectnameLoop ': Non-linear'];
    
end

% Merge Figures
if projectnameSize > 1
    for i = 2:projectnameSize
        L = findobj(i,'type','line');
        copyobj(L,findobj(1,'type','axes'));
        close(figStructVid(i))
    end
end

% Apply new headings and legend
newLegend = insertBefore(newLegend,"_","\");
legend(newLegend)
title('')
sgtitle('Dynamic Angle of Repose Plot')

% Reset axes  
set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
set(gca, 'YTickMode', 'auto', 'YTickLabelMode', 'auto')

% New Colours for Plot
colours = distinguishable_colors(2*projectnameSize);
hline = findobj(gcf, 'type', 'line');
for i = 1:2*projectnameSize
    set(hline(i),'Color',colours(i,:))
end


%% Merge freqDist Figures

numFig(end+1) = length(findobj('type','figure')); % Number of open figures
newLegend = cell(2*projectnameSize,1); % Blank legend

if projectnameSize > 1
    
    figCount = 0;

    for j = projectnameSize:-1:1

        if isa(projectname,'char')
            projectnameLoop = projectname;
        else
            projectnameLoop = char(projectname(j));
        end

        pathProject = fullfile(path_local_out,'output',projectnameLoop);
        
        figureStructFreq(j) = openfig(fullfile(pathProject,'analysis',...
            [projectnameLoop '_freqDist.fig']),'invisible');
        
        % Update Legend
        newLegend{2*j-1,1} = [projectnameLoop ': PP'];
        newLegend{2*j,1} = [projectnameLoop ': Gl'];

        % Split subplots into own figure
        hAx = findobj(figureStructFreq(j),'type','axes'); % Number of subplots

        numFig(end+1) = length(findobj('type','figure'));
        
        for iAx = 1:length(hAx)
            figure
            numFig(end) = numFig(end)+1; % Current figure count
            figCount = figCount+1;
            fNew(figCount) = figure(numFig(end));
%             fNew(figCount) = figure(numFig(end),'visible','off');
            hNew(figCount) = copyobj(hAx(iAx),fNew(figCount));
            set(hNew(figCount),'pos',[0.13 0.11 0.775 0.815]) % default axes positon
        end
 
    end
    
    % Close unnecessary figures
    for j = projectnameSize:-1:1
        close(figureStructFreq(j))
    end
    numFig(end+1) = length(findobj('type','figure'));
    
    % New legend
    newLegend = insertBefore(newLegend,"_","\");
    
    % Merge Figures
    figOffset = numFig(end)-figCount;
    
    for i = 1:length(hAx)
        
        firstFig = figOffset+1+i; 
        
        if projectnameSize > 1
            for j = 1:(projectnameSize-1)
                secondFig = (4*j)+i;
                L = findobj(fNew(secondFig),'type','line');
                copyobj(L,findobj(fNew(i),'type','axes'));
                close(fNew(secondFig))
            end

            % Add legend 
            figure(firstFig)
            legend(newLegend,'Location','Best')
            
            % Reset Axes
            set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
            set(gca, 'YTickMode', 'auto', 'YTickLabelMode', 'auto')

            % Convert y-axis to percentage
            ytix = get(gca, 'YTick'); % Convert to percentage
            set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)      
        end

        % New Colours for Plot
        colours = distinguishable_colors(2*projectnameSize);
        hline = findobj(firstFig, 'type', 'line');
        for k = 1:2*projectnameSize
            set(hline(k),'Color',colours(k,:))
        end
        
    end  
    
    % Figure properties
    for i = 1:length(hAx)
        figure(fNew(i))
        ax(i) = gca;
        lgd(i) = findobj(fNew(i),'type','legend');
    end
        
    figOut = figure('Position', get(0, 'Screensize'));
     
    for i = 1:length(hAx)
        j = length(hAx)+1-i;
        copies = copyobj([ax(i),lgd(i)],figOut);
        subplot(2,2,j,copies(1))
        close(fNew(i))
    end
    
    sgtitle(['Relative Frequency Distribution for Distance travelled '...
        'by Particles'])

end
    

%% Visualise Mask
% test1 = vidmasks(:,:,1000);
% r = zeros(size(test1),'uint8');
% gb = zeros(size(test1),'uint8');
% 
% for j = 1:size(test1,2)
%     for i = 1:size(test1,1)
%         if test1(i,j) == 0 % Black
%             r(i,j) = 0;
%             gb(i,j) = 0;
%         elseif test1(i,j) == 1 % Red
%             r(i,j) = 256;
%             gb(i,j) = 0;
%         elseif test1(i,j) == 2 % White
%             r(i,j) = 256;
%             gb(i,j) = 256;
%         end
%     end
% end
% 
% rgbIm = cat(3,r,gb,gb);
% figure(2)
% imshow(rgbIm);

% projectnameSize = 1;
% for j = projectnameSize:-1:1
%     disp(num2str(j))
%     
% end 