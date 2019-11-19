function output = compareDataHead(path_input, pathRestart)

% compareDataHead.m
% 
% Function to compare the data.head input file to determine compatability
% when using a restart file with LIGGGHTS.
%
%
% Tim Churchfield
%
% Last edited: 15/11/2019

%% Variable Dictionary
% 
% -- Input --
%
% pathRestart - Path to directory containing the restart data.head file 
%               (not including data.head file name) 
% path_input  - Path for initialisation data.head file.(including
%               data.head file name)
%
% -- Output --
%
% output      - Logical specifying if primary simulation settings between
%               the two data.head files are the same (1 = yes, 0 = no). 
%
% -- Other --
% 
% commaCount  -
% init        - Values defined for primary simulation settings in
%               initialisation data.head file.
% restart     - Values defined for primary simulation settings in
%               restart data.head file.
% string      - Text holder.
% stringOut   - String of incompatible simulation settings.
% values      - matrix of values defined for each simulation setting 
%
%
%% Execution

% read restart data.head file
pathRestart = fullfile(pathRestart,'data.head');
restart = readDataHeadSimSettings(pathRestart);
values(1,:) = cell2mat(restart(2,:));

% read initialisation data.head file
init = readDataHeadSimSettings(path_input); 
values(2,:) = cell2mat(init(2,:));

% compare output
output = values(1,:) == values(2,:); % compare individual simultion settings

stringOut = '';
commaCount = 0;

for i = 1:length(output)
    if output(i) == 0
        commaCount = commaCount+1;
        if commaCount > 1
            string = [', ', char(restart{1,i})];
        else
            string = [' ', char(restart{1,i})];
        end
        stringOut = strcat(stringOut, string);
    end
end

if all(output)
    disp('test')
else
    string = ['Incompatible restart file selected! Please check ',...
        'the following simulation settings in your data.head file:',...
        stringOut, '.'];
    string = sprintf(string); 
    uiwait(warndlg(string));
    return
end
output = all(output);