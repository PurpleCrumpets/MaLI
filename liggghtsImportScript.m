%% liggghtsImportScript.m
%
% Script to download LIGGGHTS DEM project from the computing cluster. Once
% the data is downloaded, any images found are converted from PPM to PNG to
% reduce the total project size. The VTK files are imported into MATLAB 
% 
% Tim Churchfield
%
% Last Edited: 09/12/2019
%
%% Variable Dictionary




%% Prepare Workspace
clc
clear
close('all')
fclose('all');


%% User Input Variables
projectname = ''; 
download = 'yes'; % Yes -> re-downloads files from cluster, no -> opposite
%vtk_num = 'rotating';
%vtk_num = 'all';
vtk_num = 'both';


%% Load Paths and Primary Hypnos Commands
key = specify_path_cmd;
path_local_in  = char(key(1));
path_local_out = char(key(2));
path_hypnos    = char(key(3));
plink_cmd      = char(key(4));
psftp_cmd      = char(key(5));

%% Defining Directories
path_local_type = [path_local_out 'output\'];
path_plink      = [path_local_type 'plink_commands\'];
path_psftp      = [path_local_type 'psftp_commands\'];
path_hypnos_sim = [path_hypnos 'simulations/'];


%% Creating Local Directories
if ~exist(path_local_type,'dir')
    mkdir(path_local_type);
end

if ~exist(path_psftp,'dir')
    mkdir(path_psftp);
end

if ~exist(path_plink,'dir')
    mkdir(path_plink);
end


%% Checking if vtk_num Input is Valid
if exist('vtk_num','var') == 0
    vtk_num = 'all';
end

if strcmpi(vtk_num,'all') || strcmpi(vtk_num,'rotating') ...
        || strcmpi(vtk_num,'both')
else
    error_msg = 'Invalid vtk_num entry';
    uiwait(warndlg(error_msg));
end 


%% Checking if Hypnos Project Name Exists
if exist('projectname','var') == 0
    projectname = '';
end

if exist('download','var') == 0
    download = 'Yes';
end

if isempty(projectname) == 0
    cmd_name = 'plink_cmd_1.txt';
    string1 = cellstr(['if test -d ' path_hypnos_sim projectname...
        ' ; then echo "1" ; else  echo "0"; fi']);
    cmd = string1;

    command = mk_plink_cmd(cmd_name,cmd,path_plink);
    [~,cmd_out] = system(command);
    cmd_out = regexprep(cmd_out,'[\n\r]+','');

    if cmd_out == '0'
        error_msg = 'Project specified does not exist on Hypnos: \n %s';
        error_msg = sprintf(error_msg, projectname); 
        uiwait(warndlg(error_msg));
        return;
    end
    
else
    j = [];
    while isempty(j)
        
        % Current Projects on Hypnos
        disp('Looking for current projects...');

        cmd_name = 'plink_cmd_3.txt';
        string1 = cellstr(['cd ' path_hypnos_sim]);
        string2 = cellstr('ls');
        cmd = [string1; string2];

        command = mk_plink_cmd(cmd_name,cmd,path_plink);
        [~,cmd_out] = system(command);

        % Changing Hypnos command output format
        cmd_out = regexprep(cmd_out,'[\n\r]+',' ');
        cmd_out = split(cmd_out);
        disp('The current list of projects on Hypnos are as follows: ');
        fprintf('%s\n', cmd_out{:});

        % Providing a Project to download if not specified
        k = [];
        while isempty(k)
            prompt = ['Please provide a valid project to be '...
                'imported (one word): '];
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

        end

        % Checking if project exists on Hypnos    
        test = any(ismember(cmd_out,projectname),'all');

        if test == 0
            disp('Project does not exist on Hypnos...');
            fprintf('\n');
        else
            disp('Project found...');
            j = 1;
        end
    end   
end


%% Creating Local Project Directory
if ~exist(path_local_type, 'dir')
    mkdir(path_local_type);
end

if ~exist(path_psftp, 'dir')
    mkdir(path_psftp);
end

if ~exist(path_plink, 'dir')
    mkdir(path_plink);
end

% Checking 
mydir = [path_local_type projectname '\'];
if ~exist(mydir, 'dir')
    mkdir(mydir);
    p = 1;
else
    disp('This project folder already exists on your computer...');
    disp(['If you continue with the same project name,'... 
        ' all previous data will be deleted...']);
    disp(['Alternatively, a new folder will be made named using '... 
        'the datetime command...']);
    p = [];
end

if strcmpi(download,'Y') || strcmpi(download,'yes')
    while isempty(p)  
        prompt = 'Do you wish to overwrite the existing folder? (Y/N): ';
        overwrite = input(prompt,'s');

        if strcmpi(overwrite,'Y') || strcmpi(overwrite,'yes')
            disp('Overwriting existing directory...');
            disp(['Please be patient as this can take '...
                'some time...']);

                rmdir(mydir, 's');
                disp('Directory overwritten...');
                mkdir(mydir);

            j = 1;
            p = 1;

        elseif strcmpi(overwrite,'N') || strcmpi(overwrite,'no')
            disp('Creating new directory using current date...');

            currDate = strrep(datestr(datetime),':','_');
            currDate = strrep(currDate,' ','_');
            currDate = strrep(currDate,'-','_');

            mydir = [path_local_type projectname '_' currDate '\'];
            mkdir(mydir);

            p = 1;

        else
            disp('Invalid input, please try again');

        end    
    end
    
elseif ~strcmpi(download,'N') || ~strcmpi(download,'no')
    disp('Not re-downloading files from Cluster...');
else
    error_msg = 'Invalid redownload entry';
    uiwait(warndlg(error_msg));
    
end


%% Downloading Project Files
disp(['Downloading project files for ' projectname '...']);
disp('Please be patient...');

cmd_name = 'psftp_cmd_1.txt';
string1 = cellstr(['cd ' erase(path_hypnos_sim,'~/') projectname]);
string2 = cellstr(['lcd ' mydir]);
string3 = cellstr('mget -r post restart meshes images');
string4 = cellstr(['mget log.liggghts in.rotatingdrum data.head '...
    'imaging.data rpm_drum.txt ' projectname '_output.txt']);
cmd = [string1; string2; string3; string4];

command = mk_psftp_cmd(cmd_name,cmd,path_psftp);

if strcmpi(download,'Y') || strcmpi(download,'yes')
    [~,~] = system(command);
    disp('Project files downloaded...');
end


%% Converting Image Format
disp('Converting image format...');

path_images = [mydir 'images\'];
convert_ppm_png(path_images); 


%% Creating Video from Images
disp('Creating video...');

path_images = [mydir 'images\'];
frameRateInfo = mydir;
make_video(path_images,frameRateInfo,projectname);


%% Import and Save VTK Data
disp('Importing VTK Files...'); 
vtk_data_out = import_vtk(mydir,vtk_num);

%% Create Frequency Distribution of Moving Distance by Particle Type





%% Calling Imaging Function
return

id_drum = 0.144; % metres
% Imaging Plane
plane(1,:) = [0,-0.06,0]; % Point
plane(2,:) = [0,1,0];     % Normal Vector


iimage_drum = create_image(data,type_data,particle_properties,plane,id_drum);
