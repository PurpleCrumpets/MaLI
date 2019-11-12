%% Title
%
% liggghts_initialisation_script.m
%
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
close
fclose('all');


%% User Input Variables
projectname = '';
restartSource = '11_nP_40_zoom_2';
tail = 'no';
% tail = 'yes';
% restartSource= 'useCurrentFile'; % Use restart files in template dir


%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_in  = char(key(1));
path_local_out = char(key(2));
path_hypnos    = char(key(3));
plink_cmd      = char(key(4));
psftp_cmd      = char(key(5));


%% Check if Local Input Path Exists
path_local_start = [path_local_in 'start\'];

if ~isfolder(path_local_start)
    error_msg = 'Local path specified for initialisation does not exist: \n %s';
    error_msg = sprintf(error_msg, path_local_start); 
    uiwait(warndlg(error_msg));
    return
end


%% Definine Local Directories
path_plink      = [path_local_start 'plink_commands\'];
path_psftp      = [path_local_start 'psftp_commands\'];

% Make ssh and psftp commands folder if they don't already exist
if ~exist(path_plink,'dir')
   mkdir(path_plink)
end

if ~exist(path_psftp,'dir')
   mkdir(path_psftp)
end


%% Check if Hypnos Path Exists 
cmd_name = 'plink_cmd_1.txt';
string1 = cellstr(['if test -d ' path_hypnos...
    ' ; then echo "1" ; else  echo "0"; fi']);
cmd = string1;

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,cmd_out] = system(command);
cmd_out = regexprep(cmd_out,'[\n\r]+','');

if cmd_out == '0'
    error_msg = 'Path specified for Hypnos does not exist: \n %s';
    error_msg = sprintf(error_msg, path_hypnos); 
    uiwait(warndlg(error_msg));
    return;
end

% Create 'simulations' directory if it doesn't exist
path_hypnos_sim = [path_hypnos 'simulations/'];

cmd_name = 'plink_cmd_2.txt';
string1 = cellstr(['cd ' path_hypnos]);
string2 = cellstr('mkdir -p simulations');
cmd = [string1; string2];

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,~] = system(command);


%% Determine Simulation Type
disp('Determining Simulation Type...');

path_input = 'start\template\data.head';
fileID = fopen(path_input,'r');

str = fgets(fileID);   
% Simulation Type
while ~startsWith(str,'variable simtype')
    str = fgets(fileID);
end
sim_type = sscanf(str,'variable simtype string "%s');
sim_type = sim_type(1:end-1);

fclose(fileID);

j = [];
while isempty(j)
    if strcmpi(sim_type,'i') || strcmpi(sim_type,'initialisation')
        disp('Initialisation simulation type selected...');
        sim_type = 'initialisation';
        j = 1;
     elseif strcmpi(sim_type,'r') || strcmpi(sim_type,'restart')
        disp('Restart simulation type selected...');
        sim_type = 'restart';
        j = 1;
    else
        error_msg = 'Invalid simulation type input: \n %s';
        error_msg = sprintf(error_msg, sim_type); 
        uiwait(warndlg(error_msg));
        return
    end
end


%% Current Projects
disp('Looking for current projects...');

cmd_name = 'plink_cmd_3.txt';
string1 = cellstr(['cd ' path_hypnos_sim]);
string2 = cellstr('ls');
cmd = [string1; string2];

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,cmd_out] = system(command);

% Change Hypnos command output format
cmd_out = regexprep(cmd_out,'[\n\r]+',' ');
cmd_out = split(cmd_out);
disp('The current list of projects on Hypnos are as follows: ');
fprintf('%s\n', cmd_out{:});


%% Name Project
if exist('projectname','var') == 0
    projectname = '';
end

j = [];
while isempty(j)
    
    % Providing project name if it doesn't already exist
    k = [];
    while isempty(k)
        if isempty(projectname) == 1
            prompt = 'Please provide a name for the project (one word): ';
            projectname = input(prompt,'s');
            
            if contains(projectname, ' ')
                fprintf('\n');
                disp('Project name contains a space...'); 
                disp(['Please specify a new project name '...
                    '(use underscores ''_'' instead of spaces)...']);
                fprintf('\n');
                projectname = [];
            else
                k = 1;
            end
        else 
            k = 1;
        end
    end
    
    % Checking if project already exists on Hypnos    
    test = any(ismember(cmd_out,projectname),'all');

    if test == 1
        disp(['Project ' projectname ' already exists on Hypnos...']);
        disp(['If you continue, all output from the previous simulation'...
            ' will be deleted...']);
    end
    
    p = [];
    while isempty(p)    
        if test == 1
            prompt = 'Do you wish to overwrite the project? [Y/N] ';
            overwrite = input(prompt,'s');
                if strcmpi(overwrite,'Y') || strcmpi(overwrite,'yes')
                    disp('Overwriting existing directory...');
                    disp(['Please be patient as this can take '...
                        'some time...']);
                    j = 1;
                    p = 1;
                 elseif strcmpi(overwrite,'N') || strcmpi(overwrite,'no')
                    disp('File not created');
                    projectname = [];
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


%% Select Restart Files

if strcmpi(sim_type,'restart')
    
    % Create empty restartSource variable if it does not exist
    if exist('restartSource','var') == 0
        restartSource = '';
    end
    
    % Restart file source
    if isempty(restartSource) % yes it is empty, extract from output 
        disp('Extracting restart files obtained from output directory...')
        disp(['The current list of projects in the output directory'...
            ' are as follows: '])
        pathRestart = fullfile(path_local_out,'output');
        outputDir = dir(pathRestart);
        
        % Remove '.' and '..' entries
        outputDir = outputDir(~ismember({outputDir.name},{'.','..'}));
        
        outputList = cell(length(outputDir),1);
        for i = 1:length(outputDir)
            outputList{i} = outputDir(i).name;    
        end
        
        fprintf('%s\n', outputDir.name);
        fprintf('\n')
        
        j = [];
        while isempty(j)
            prompt = ['Please provide a project name to obtain restart '...
                'files from: '];
            restartSource = input(prompt,'s');

            % Check if valid input
             test = any(ismember(outputList,restartSource),'all');

            if test == 0
                disp(['Project: ' restartSource...
                    ' does not exist in output directory...']);
                disp(['Please provide a valid project name to obtain'...
                    ' restart from ...']);
            else
                pathRestart = fullfile(path_local_out,'output',...
                    restartSource); 
                j = 1;
            end
        end   
        
    elseif strcmpi(restartSource,'useCurrentFile') % use current file
        disp('Using stored restart files...')
        pathRestart = fullfile(path_local_in,'start','template');
                
    elseif ~isempty(restartSource) % use named output folder
        disp('Using named output directory for restart files...')
        pathRestart = fullfile(path_local_out,'output',restartSource);
        
    else % This shouldn't happen
        uiwait(warndlg('Invalid restartSource variable input'));
        return
        
    end
    
    % Check if restart file is compatible with configured settings
    disp('Checking restart file compatability with configured settings...')
    
    
    % Read data.head of submitted settings. Obtain info on periodic, 2D/3D
    % settings 
    
    
    % Check selected restart directory for the correctly named file 
    
end



%% Creating Simulation Directory and Sub-Directories
if test == 0
    disp('Creating new project directories...');
end

cmd_name = 'plink_cmd_4.txt';
string1 = cellstr(['cd ' path_hypnos_sim]);
string2 = cellstr(['rm -rf ' projectname]);
string3 = cellstr(['mkdir -p ' projectname '/{post,restart,images}']);
cmd = [string1; string2; string3];

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,~] = system(command);


%% Upload Input Files, job.scripts and Meshes
disp('Uploading input files, run scripts and meshes...');

cmd_name = 'psftp_cmd_1.txt';
string1 = cellstr(['cd ' erase(path_hypnos_sim,'~/') projectname '/']);
string2 = cellstr(['lcd ' path_local_start 'template']);
string3 = cellstr('mput -r meshes');

if strcmpi(sim_type,'initialisation')
    string4 = cellstr(['mput runscript postscript in.rotatingdrum '...
        'data.head imaging.data rpm_drum.txt']);
else
    string4 = cellstr(['mput runscript postscript '...
        'in.rotatingdrumRestart imaging.data data.head rpm_drum.txt']);
end

string5 = cellstr(['lcd ' path_local_start]);
string6 = cellstr('mput job.script job2.script job3.script');
cmd = [string1; string2; string3; string4; string5; string6];

command = mk_psftp_cmd(cmd_name,cmd,path_psftp);
[~,~] = system(command);


%% Upload Restart Files if Required
if strcmpi(sim_type,'restart')
    disp('Uploading restart files...')
    
    cmd_name = 'psftp_cmd_2.txt';
    string1 = cellstr(['cd ' erase(path_hypnos_sim,'~/') projectname '/']);
    string2 = cellstr(['lcd ' pathRestart]);
    string3 = cellstr('mput -r restart');

    cmd = [string1; string2; string3];

    command = mk_psftp_cmd(cmd_name,cmd,path_psftp);
    [~,~] = system(command);       
end


%% Obtain lmp_auto File, Rename in.rotatingdrumRestart if Required
disp('Obtaining lmp_auto file from src directory...');

path_hypnos    = char(key(3));



cmd_name = 'plink_cmd_5.txt';
string1 = cellstr(['cp ', path_hypnos, 'src/lmp_auto ',...
    path_hypnos_sim, projectname]);
% string1 = cellstr(['find */src/lmp_auto -exec cp {} '...
%     path_hypnos_sim projectname '/ \;']);

if strcmpi(sim_type,'initialisation')
    cmd = string1;  
else
    disp('Renaming in.rotatingdrumRestart...');
    string2 = cellstr(['cd ' path_hypnos_sim projectname '/']);
    string3 = cellstr('mv in.rotatingdrumRestart in.rotatingdrum');
    cmd = [string1; string2; string3]; 
end

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,~] = system(command);


%% Obtain Runtime, Processing Cores
% disp('Obtaining runtime and processing cores information...');
% 
% path_input = [path_local_type 'template\inputs.txt'];
% fileID = fopen(path_input,'r');
% linenum = 4;
% walltime = textscan(fileID,'%{hh:mm:ss}T',1,'delimiter',' ',...
%     'headerlines',linenum-1);
% fseek(fileID,0,'bof');
% linenum = 7;
% processors = textscan(fileID,'%d',1,'delimiter','\n','headerlines',...
%     linenum-1);
% fclose(fileID);


%% Obtain Runtime, Processing Cores
disp('Obtaining runtime and processing cores information...');

path_input = [path_local_start 'template\data.head'];
fileID = fopen(path_input,'r');

str = fgets(fileID);   
% Walltime
while ~startsWith(str,'variable walltime')
    str = fgets(fileID);
end
walltime = sscanf(str,'variable walltime string "%s');
walltime = walltime(1:end-1);

% Processors
frewind(fileID); % Reset read position in data.head
while ~startsWith(str,'variable proc ')
    str = fgets(fileID);
end
processors = sscanf(str,'variable proc equal %d');

% Queue
frewind(fileID); % Reset read position in data.head
while ~startsWith(str,'variable queue ')
    str = fgets(fileID);
end
queue = sscanf(str,'variable queue string "%s');
queue = queue(1:end-1);

% Nodes
frewind(fileID); % Reset read position in data.head
while ~startsWith(str,'variable nodes ')
    str = fgets(fileID);
end
nodes = sscanf(str,'variable nodes equal %d');

mpi_Proc = processors*nodes;

% Close data.head
fclose(fileID);


%% Formatting job.script
% Converting run file format to be readable on Linux and editing them to
% include the correct runtime, processor count etc.
disp('Converting run file format and editing run files...');

cmd_name = 'plink_cmd_6.txt';

% Change path
string1 = cellstr(['cd ' path_hypnos_sim projectname]);
% Change file permissions, Linux compatability
string2 = cellstr(['chmod 755 job.script job2.script job3.script;'...
    ' sed -i ''s/\r//g'' job.script job2.script job3.script']);
% Change path
string3 = cellstr(['cd ' path_hypnos_sim projectname]);
% Set number of processors
string4 = cellstr(['sed -i ''s/ppn=0/ppn=' num2str(processors)...
    '/'' job.script']);
% Set qsub submission name to project name
string5 = cellstr(['sed -i ''s/DEM/' projectname '/'' job.script']);
% Set number of processors for mpi
string6 = cellstr(['sed -i ''s/-np 0/-np '  num2str(mpi_Proc)...
    '/'' job.script']);
% Set simulation wall time
string7 = cellstr(['sed -i ''s/00:00:00/' walltime '/'' job.script']);
% Set path to simulation directory
string8 = cellstr(['sed -i ''s/cd path/cd ' replace(path_hypnos_sim,...
    '/','\/') projectname '\//'' job.script']);
% Set number of processor nodes
string9 = cellstr(['sed -i ''s/nodes=1/nodes=' num2str(nodes)...
    '/'' job.script']);
% Set qsub queue
string10 = cellstr(['sed -i ''s/-q default/-q ' queue '/'' job.script']);
% Set path to simulation directory (job2.script)
string11 = cellstr(['sed -i ''s/cd path/cd ' replace(path_hypnos_sim,...
    '/','\/') projectname '\//'' job2.script']);
% Set path to simulation directory (job3.script)
string12 = cellstr(['sed -i ''s/cd path/cd ' replace(path_hypnos_sim,...
    '/','\/') projectname '\//'' job3.script']);

cmd = [string1; string2; string3; string4; string5; string6;...
    string7; string8; string9; string10; string11; string12];

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,~] = system(command);


%% Initialising Simulation
disp('Initialising simulation...');

cmd_name = 'plink_cmd_7.txt';
string1 = cellstr(['cd ' path_hypnos_sim projectname]);
string2 = cellstr('/opt/torque/bin/qsub job.script');
cmd = [string1; string2];

command = mk_plink_cmd(cmd_name,cmd,path_plink);
[~,cmd_out] = system(command);

jobID = cmd_out;
jobID_num = strtok(jobID,'.');
disp(['Simulation job ID on cluster: ' num2str(jobID)]);

%% Checking if Output File Exists
disp('Looking for log file...');

cmd_name = 'plink_cmd_8.txt';
string1 = cellstr(['cd ' path_hypnos_sim projectname]);
string2 = cellstr('test -e log.liggghts && echo 1 || echo 0');
cmd = [string1; string2];

command = mk_plink_cmd(cmd_name,cmd,path_plink);

j = [];
i = '.';

while isempty(j)
    [~,cmd_out] = system(command);
    if str2double(cmd_out) == 1
        j = 1;
        disp('Log file found...');
        break
    end
    pause(1);
    fprintf('%s',i);
end


%% Tailing Log File and Error Checking
if strcmpi(tail,'Y') || strcmpi(tail,'yes')
    % Looking for Errors Messages in log.liggghts
    disp('Looking for errors messages (see external Terminal)...');

    cmd_name = 'plink_cmd_9.txt';
    string1 = cellstr(['cd ' path_hypnos_sim projectname]);
    string2 = cellstr('./job2.script');
    cmd = [string1; string2];

    command = mk_plink_cmd(cmd_name,cmd,path_plink);
    [~,~] = system([command '&']);

    % Tailing log.liggghts
    disp('Tailing log file...');

    cmd_name = 'plink_cmd_10.txt';
    string1 = cellstr(['cd ' path_hypnos_sim projectname]);
    string2 = cellstr('./job3.script');
    cmd = [string1; string2];

    command = mk_plink_cmd(cmd_name,cmd,path_plink);
    [~,~] = system(command, '-echo');

    % Terminating error checking upon finishing
    system('taskkill /IM "conhost.exe" /F > NUL &');
    disp('Simulation Complete!');
    
elseif strcmpi(tail,'N') || strcmpi(tail,'no') || ~exist('tail','var')
    disp(['Simulation ' projectname ' successfully initialised!']);
    
end