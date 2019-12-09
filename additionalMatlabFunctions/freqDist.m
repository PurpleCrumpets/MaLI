function [out, histoFigure] = freqDist(projectname,VTKfile,timings,classes,chartType,dispFig)


% freqDist.m
%
% Function to create the relative frequency distribution of the moving 
% distance by particle type.
%
%
% Tim Churchfield
%
% Last edited: 15/10/2019


%% Function Input Variables



%% Function Output Variables
 


%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_out = char(key(2));


%% Load Data
pathProject = fullfile([path_local_out 'output'],projectname);
load(fullfile(pathProject,[projectname '_' VTKfile '_VTK_data.mat']));


%% Time Interval 
minTimeRow = find(vtk_data_out.data{1,1}.Time <= timings(1,1));
maxTimeRow = find(vtk_data_out.data{1,1}.Time >= timings(1,2));

if isempty(minTimeRow)
    minTimeRow = 1; % First row in table
else 
    minTimeRow = max(minTimeRow);
end

if isempty(maxTimeRow)
    maxTimeRow = size(vtk_data_out.data{1,1},1); % Last time in table
else
    maxTimeRow = min(maxTimeRow);
end

particleCount = size(vtk_data_out.type_data{1,1},1);
out = zeros(maxTimeRow-minTimeRow+1,4*particleCount);
minLim = minTimeRow-1; 

% parfor k = (minTimeRow+1):maxTimeRow
for k = (minTimeRow+1):maxTimeRow
    distance = abs(vtk_data_out.data{1,1}.Data{k,1}.Position -...
        vtk_data_out.data{1,1}.Data{k-1,1}.Position);
   
    % 3D distance
    distance(:,4) = sqrt(sum(distance.^2,2));
    
    % Rearrange data to single row
    out(k-minLim,:) = reshape(distance.',1,[]);
end

% Add times
out = [vtk_data_out.data{1,1}.Time(minTimeRow:maxTimeRow),vtk_data_out.data{1,1}.Timestep(minTimeRow:maxTimeRow), out];


%% Heading Names
headings = cell(2,2+4*particleCount); 
headings(1:2,1:2) = {'Time','Timestep';'s','-'}; 
[headings{2,3:(2+4*particleCount)}] = deal('m'); % Distance units

for k = 1:particleCount

    headings(1,(4*k-1):(4*k+2)) = ...
        {['X_',num2str(vtk_data_out.type_data{1,1}.ID(k,1))],...
        ['Y_',num2str(vtk_data_out.type_data{1,1}.ID(k,1))],...
        ['Z_',num2str(vtk_data_out.type_data{1,1}.ID(k,1))],...
        ['D_',num2str(vtk_data_out.type_data{1,1}.ID(k,1))]}; 
    
end


%% Cumulative Distance
cumulativeDist = sum(out,1);
cumulativeDist = cumulativeDist(3:end);
cumulativeDist = reshape(cumulativeDist.',4,[])';

% Convert to table, add particle ID
cumulativeDist = array2table(cumulativeDist,'VariableNames',...
    {'X_Cumulative','Y_Cumulative','Z_Cumulative','M_Cumulative'});
cumulativeDist = [vtk_data_out.type_data{1,1}, cumulativeDist]; 
cumulativeDist.Properties.VariableUnits = {'-','-','m','m','m','m'};


%% Convert out to Table
out = array2table(out,'VariableNames',headings(1,:));
out.Properties.VariableUnits = headings(2,:);

Type1 = (cumulativeDist.Type == 1);
Type2 = (cumulativeDist.Type == 2);


%% Histogram Plots

% Labels
fig_legend = {'Polypropylene','Glass'};
fig_xlabel = 'Distance Travelled (m)';
fig_ylabel = 'Relative Frequency (%)';

% Histogram Chart
if strcmpi(dispFig,'yes') || strcmpi(dispFig,'y')
    histoFigure = figure('Position', get(0, 'Screensize')); 
else
    histoFigure = figure('Position', get(0, 'Screensize'),...
        'visible', 'off');
end

if strcmpi(chartType,'bar') % Histogram Bar Chart
    
    % X-Component
    subplot(2,2,1)
    histX1 = histogram(cumulativeDist.X_Cumulative(Type1),classes,...
        'Normalization','probability');
    hold on 
    histX2 = histogram(cumulativeDist.X_Cumulative(Type2),classes,...
        'Normalization','probability');
    title('X-Component');

    % Y-Component
    subplot(2,2,2)
    histY1 = histogram(cumulativeDist.Y_Cumulative(Type1),classes,...
        'Normalization','probability');
    hold on 
    histY2 = histogram(cumulativeDist.Y_Cumulative(Type2),classes,...
        'Normalization','probability');
    title('Y-Component');

    % Z-Component
    subplot(2,2,3)
    histZ1 = histogram(cumulativeDist.Z_Cumulative(Type1),classes,...
        'Normalization','probability');
    hold on 
    histZ2 = histogram(cumulativeDist.Z_Cumulative(Type2),classes,...
        'Normalization','probability');
    title('Z-Component');

    % Magnitude
    subplot(2,2,4)
    histM1 = histogram(cumulativeDist.M_Cumulative(Type1),classes,...
        'Normalization','probability');
    hold on 
    histM2 = histogram(cumulativeDist.M_Cumulative(Type2),classes,...
        'Normalization','probability');
    title('Magnitude');
    
elseif strcmpi(chartType,'line') % Histogram Line Plot
    
    Elements = zeros(8,classes);
    
    % X-Component data
    [Elements(1,:),edges(1,:)] = ...
        histcounts(cumulativeDist.X_Cumulative(Type1)...
        ,classes,'Normalization', 'probability');
    [Elements(2,:),edges(2,:)] = ...
        histcounts(cumulativeDist.X_Cumulative(Type2)...
        ,classes,'Normalization', 'probability');
    
    % Y-Component data
    [Elements(3,:),edges(3,:)] = ...
        histcounts(cumulativeDist.Y_Cumulative(Type1)...
        ,classes,'Normalization', 'probability');
    [Elements(4,:),edges(4,:)] = ...
        histcounts(cumulativeDist.Y_Cumulative(Type2)...
        ,classes,'Normalization', 'probability');
    
    % Z-Component data
    [Elements(5,:),edges(5,:)] = ...
        histcounts(cumulativeDist.Z_Cumulative(Type1)...
        ,classes,'Normalization', 'probability');
    [Elements(6,:),edges(6,:)] = ...
        histcounts(cumulativeDist.Z_Cumulative(Type2)...
        ,classes,'Normalization', 'probability');
    
    % Magnitude data
    [Elements(7,:),edges(7,:)] = ...
        histcounts(cumulativeDist.M_Cumulative(Type1)...
        ,classes,'Normalization', 'probability');
    [Elements(8,:),edges(8,:)] = ...
        histcounts(cumulativeDist.M_Cumulative(Type2)...
        ,classes,'Normalization', 'probability');
    
    % Add additonal point at relative frequency 0 at ends
    Tails = zeros(8,2);
    Elements = [Tails(:,1), Elements, Tails(:,2)];
    
    % Half Bin Width
    HalfBinWidth = (edges(:,2)-edges(:,1))/2;
    middleBin = zeros(8,classes+2);
    
    middleBin(:,1) = edges(:,1)-HalfBinWidth; 
    for i = 1:classes
        middleBin(:,i+1) = edges(:,i)+HalfBinWidth;
    end
    middleBin(:,classes+2) = middleBin(:,classes+1)+2*HalfBinWidth;
    
    % X-Component subplot
    subplot(2,2,1)
    plot(middleBin(1,:), Elements(1,:),middleBin(2,:), Elements(2,:));
    title('X-Component');
    
    % Y-Component subplot
    subplot(2,2,2)
    plot(middleBin(3,:), Elements(3,:),middleBin(4,:), Elements(4,:));
    title('Y-Component');
    
    % Z-Component subplot
    subplot(2,2,3)
    plot(middleBin(5,:), Elements(5,:),middleBin(6,:), Elements(6,:));
    title('Z-Component');
    
    % Magnitude subplot
    subplot(2,2,4)
    plot(middleBin(7,:), Elements(7,:),middleBin(8,:), Elements(8,:));
    title('Magnitude');

end

% Plot labels, legends, convert to percentage distribution
for i=1:4
    subplot(2,2,i)
    xlabel(fig_xlabel)
    ylabel(fig_ylabel)
    legend(fig_legend,'Location','Best');
    ytix = get(gca, 'YTick'); % Convert to percentage
    set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)
    set(gca,'XMinorTick','on','YMinorTick','on')
end

% Main title
projectTitle = insertBefore(projectname,"_","\");
sgtitle(['Project ' projectTitle ...
    ': Relative Frequency Distribution for Distance '...
    'Travelled by Particles'])


%% Create Anaylsis Directory
if ~exist(fullfile(pathProject,'analysis'), 'dir')
   mkdir(pathProject,'analysis')
end


%% Save Output

% Save png file
saveas(histoFigure, fullfile(pathProject,'analysis',...
    [projectname '_freqDist_1']),'png');

% Make .fig visable when re-opening upon saving
set(histoFigure, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');  
saveas(histoFigure, fullfile(pathProject,'analysis',...
    [projectname '_freqDist']), 'fig');

disp('Relative Frequency Distribtion Figure Saved!');

% Alternative save method for png
F    = getframe(histoFigure);
imwrite(F.cdata, fullfile(pathProject,'analysis',...
    [projectname '_freqDist_2.png']), 'png')

return


%% Surplus Code
% Plot labels, legends, convert to percentage distribution
% ax = findobj(histoFigure,'Type','Axes');
% for i=1:length(ax)
%     xlabel(ax(i),fig_xlabel)
%     ylabel(ax(i),fig_ylabel)
%     subplot(2,2,i)
%     legend(fig_legend,'Location','Best');
%     ytix = get(gca, 'YTick'); % Convert to percentage
%     set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)
% end