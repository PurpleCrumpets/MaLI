function vtk_data_out = import_vtk(path_project,vtk_num)

% import_vtk.m
% 
% Function to import VTK files created by LIGGGHTS into MATLAB in a
% readable format. Additional information is obtained from the data.head
% file associated with the particular project.
%
%
% Tim Churchfield
%
% Last edited: 06/09/2019


%% Function Input Variables
% path_project - Absolute path for local project directory
% vtk_num      - Variable


%% Function Output Variables
% particle_files      - 
% data                -
% type_data           -
% particle_properties -
% particle_num        -
%


%% Import Raw VTK Data

% Import Particle Data
particle_files = dir([path_project 'post\particles_' '*.vtk']);
num_files_init = length(particle_files);

% Remove particles_boundingBox vtk files from list
test = logical.empty(0,num_files_init);

for k = 1:num_files_init
    test(k) = ~startsWith(particle_files(k).name,...
        'particles_boundingBox');   
end

particle_files = particle_files(test,:);
num_files_init = length(particle_files);

% Obtain list of time-steps
timesteps = {particle_files.name};
timesteps = regexp(timesteps,'(?<=particles_)\d*(?=\.vtk)','match')';
timesteps = str2double(cat(1,timesteps{:}));

% Sort VTK files by time-step
[~,timesteps_order] = sort(timesteps);
particle_files = particle_files(timesteps_order);

% New list of time-steps
timesteps = {particle_files.name};
timesteps = regexp(timesteps,'(?<=particles_)\d*(?=\.vtk)','match')';
timesteps = str2double(cat(1,timesteps{:}));

if strcmpi(vtk_num,'rotating')
    disp('Importing VTK files for the rotation of the drum...');

    % Obtain time-steps over which rotation of the drum occurs
    path = [path_project 'post\start_rotating.txt'];
    fileID = fopen(path,'r');
    rot_timings(1) = str2double(fgets(fileID)); 
    rot_timings(2) = str2double(fgets(fileID)); 
    
    % Close File
    fclose(fileID);
    
    test = any(timesteps(:) >= rot_timings(1) &...
        timesteps(:) <= rot_timings(2),2);
    
    % Includ initial stationary position
    test(find(test>0,1)) = 1;
    
    particle_files = particle_files(test);
     
elseif strcmpi(vtk_num,'all') || strcmpi(vtk_num,'both')
    disp('Importing all VTK files...');   
else
    warning(['Invalid input for vtk_num! Resorting to importing all '...
        'vtk files...']);
end

num_files = length(particle_files);


%% Import Data
data = cell(num_files,4);
timestep_data = zeros(num_files,1);
tic

parfor k = 1:num_files
    vtk_data = read_particle_vtk([path_project 'post\'...
        particle_files(k).name]);
    data{k,3} = vtk_data;
    % Saving time-step        
    timestep_data(k) = str2double(particle_files(k).name(11:end-4)); 
end

% Combine Data
parfor k = 1:num_files
    data{k,2} = timestep_data(k,1);
end
toc


%% Convert to Table
disp('Converting output to table...');
data = cell2table(data,'VariableNames',{'Time','Timestep','Data',...
    'Drum_Rotational_Velocity'});

% Sort Data
data = sortrows(data,2);


%% Obtain Timestep
disp('Obtaining input data from data.head...');

path = [path_project 'data.head'];
fileID = fopen(path,'r');
particle_properties = zeros(2,3);

str = fgets(fileID);   

% Time-step Data
while ~startsWith(str,'variable ts')
    str = fgets(fileID);
end
timestep = sscanf(str,'variable ts equal %f');
data.Time = timestep*data.Timestep;
frewind(fileID); % Reset read position in data.head

% Reset data.Time basis to 0 for 'rotating'
if strcmpi(vtk_num,'rotating')
    data.Time = data.Time - data.Time(1);   
end

% Radius Data
while ~startsWith(str,'variable radiusGL')
    str = fgets(fileID);
end
particle_properties(2,2) = sscanf(str,'variable radiusGL equal %f');
frewind(fileID);

while ~startsWith(str,'variable radiusPP')
    str = fgets(fileID);
end
particle_properties(1,2) = sscanf(str,'variable radiusPP equal %f');
frewind(fileID);

% Density Data
while ~startsWith(str,'variable densityGL')
    str = fgets(fileID);
end
particle_properties(2,3) = sscanf(str,'variable densityGL equal %f');
frewind(fileID);

while ~startsWith(str,'variable densityPP')
    str = fgets(fileID);
end
particle_properties(1,3) = sscanf(str,'variable densityPP equal %f');

% Close File
fclose(fileID);


% Add Particle Type
particle_properties(:,1) = [1;2];


% Convert to Table
particle_properties = array2table(particle_properties,'VariableNames',...
    {'Type','Radius','Density'},'RowNames',{'PP','Glass'});


%% Create ID/Type Table
disp('Obtaining ID/Type Data...');
type_data = read_type_vtk([path_project 'post\particles_'...
    num2str(data.Timestep(end)) '.vtk']);
%[particle_num, ~] = size(type_data); 

% Obtain Number of Each Particle
particle_num(1,1) = sum(any(type_data.Type==1,2));
particle_num(2,1) = sum(any(type_data.Type==2,2));


% Add to particle_properties table
particle_properties = addvars(particle_properties,particle_num,...
    'After','Density','NewVariableNames','Count');


%% Obtain Drum Rotational Velocity
disp('Obtaining drum rotational velocity...');

path = [path_project 'post\drum_rotational_velocity.txt'];
fileID = fopen(path,'r');
data.Drum_Rotational_Velocity = str2double(data.Drum_Rotational_Velocity);
    
% Obtain all drum velocites from drum_rotational_velocity.txt   
str = zeros(num_files_init,1);

for k = 1:num_files_init
    str(k,1) = str2double(fgets(fileID));
end

% Save relevant drum velocities
if strcmpi(vtk_num,'rotating')
    str = str(test);   
end
data.Drum_Rotational_Velocity = str;

% Close File
fclose(fileID);


%% Create Table of Results
out{1} = particle_files;
out{2} = data;
out{3} = type_data;
out{4} = particle_properties;

vtk_data_out = table(out(1),out(2),out(3),out(4),...
    'VariableNames',{'particle_files','data','type_data',...
    'particle_properties'});


%% Save VTK Data for 'all' and 'rotating'
if pathsep == ';'  
    path = split(path_project,'\');
elseif pathsep == ':'
    path = split(path_project,'/');
end

project_name = char(path(end-1));
if strcmpi(vtk_num,'rotating')
    tail = '_rotating_VTK_data.mat';
else 
    tail = '_all_VTK_data.mat';
end

size_data = whos('vtk_data_out');
if size_data.bytes >= 2e+9
    disp('Saving VTK output as compressed v7.3 MAT file...');
    save([path_project project_name tail],'vtk_data_out','-v7.3');
else
    disp('Saving VTK output to file...');
    save([path_project project_name tail],'vtk_data_out');
end


%% Save Additional File if vtk_num = 'both'
if strcmpi(vtk_num,'both')
    disp('Saving additional VTK output of rotation of drum...');
    
    % Obtain time-steps over which rotation of the drum occurs
    path = [path_project 'post\start_rotating.txt'];
    fileID = fopen(path,'r');
    rot_timings(1) = str2double(fgets(fileID)); 
    rot_timings(2) = str2double(fgets(fileID)); 
    
    % Close File
    fclose(fileID);
    
    test = any(timesteps(:) >= rot_timings(1) &...
        timesteps(:) <= rot_timings(2),2);
    
    % Include initial stationary position
    test(find(test>0,1)) = 1;
    
    % Edit vtk_data_out to contain just rotation of drum
    vtk_data_out.particle_files{1,1} = vtk_data_out.particle_files{1,1}(test);
    vtk_data_out.data{1,1} = vtk_data_out.data{1,1}(test,:);
    
    % Reset data.Time basis to 0 for 'rotating'
    if strcmpi(vtk_num,'both')  
        vtk_data_out.data{1,1}.Time = vtk_data_out.data{1,1}.Time -...
            vtk_data_out.data{1,1}.Time(1);
    end
    
    
    
    % Save output
    size_data = whos('vtk_data_out');
    tail = '_rotating_VTK_data.mat';
    if size_data.bytes >= 2e+9
        disp('Saving VTK output as compressed v7.3 MAT file...');
        save([path_project project_name tail],'vtk_data_out','-v7.3');
    else
        disp('Saving VTK output to file...');
        save([path_project project_name tail],'vtk_data_out');
    end
    disp('All VTK output files saved...');
    
else
        disp('VTK output saved to file...');
end

return