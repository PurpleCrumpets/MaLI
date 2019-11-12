function [vtk_output] = read_type_vtk(filename)

% read_type_vtk.m
%
% Function to read VTK file from LIGGGHTS simulation and import the 
% data as a MATLAB table. As the output from the VTK file can change, the
% headings in the VTK file, and their ordere within the file must be
% checked against the function file. In its current form, the following
% variables are read into MATLAB sequentially:
%
% Points
% Vertices         (not retained)
% ID 
% Type             
% Velocity         (not retained)
% Force            (not retained)
% Radius           (not retained)
% Angular Velocity (not retained)
% Torque           (not retained)
%
%
% Tim Churchfield
%
% Last edited: 31/07/2019


%% Function Input Variables
% filename   - Absolute path to VTK file, including file name


%% Function Output Variables
% vtk_output - Table containing data from VTK file with appropriate
%              headings


%% Importing VTK File
fileID = fopen(filename,'r');

if fileID == -1
    error('VTK file cannot be opened');
end

str = fgets(fileID);   % -1 if only end-of-file marker

if ~strcmp(str(3:5), 'vtk')
    error('Not a valid VTK file');
end


%% Obtaining Number of Particles
while ~startsWith(str,'POINTS')
    str = fgets(fileID);
end

n_particles = sscanf(str,'%*s %d %*s', 1);


%% Obtaining Points
[A,cnt] = fscanf(fileID,'%f %f %f', 3*n_particles);

if cnt~=3*n_particles
    warning('Problem in reading points...');
end

points = (reshape(A, 3, cnt/3))';


%% Obtaining Vertices (not kept)
while ~startsWith(str,'VERTICES')
    str = fgets(fileID);
end

[A,cnt] = fscanf(fileID,'%i %i', 2*n_particles);

if cnt~=2*n_particles
    warning('Problem in reading vertices...');
end

vertices = (reshape(A, 2, cnt/2))';
vertices = vertices(:,2);


%% Obtaining IDs
while ~startsWith(str,'id')
    str = fgets(fileID);
end



[A,cnt] = fscanf(fileID,'%i', 1*n_particles);

if cnt~=1*n_particles
    warning('Problem in reading IDs...');
end

ID = (reshape(A, 1, cnt/1))';


%% Obtaining Particle Type (not kept)
while ~startsWith(str,'type')
    str = fgets(fileID);
end



[A,cnt] = fscanf(fileID,'%i', 1*n_particles);

if cnt~=1*n_particles
    warning('Problem in reading particle type...');
end

type = (reshape(A, 1, cnt/1))';


%% Obtaining Velocity
while ~startsWith(str,'v')
    str = fgets(fileID);
end


[A,cnt] = fscanf(fileID,'%f %f %f', 3*n_particles);

if cnt~=3*n_particles
    warning('Problem in reading velocity...');
end

velocity = (reshape(A, 3, cnt/3))';


%% Obtaining Force
while ~startsWith(str,'f')
    str = fgets(fileID);
end


[A,cnt] = fscanf(fileID,'%f %f %f', 3*n_particles);

if cnt~=3*n_particles
    warning('Problem in reading forces...');
end

force = (reshape(A, 3, cnt/3))';


%% Obtaining Radius (not kept)
while ~startsWith(str,'radius')
    str = fgets(fileID);
end


[A,cnt] = fscanf(fileID,'%f', 1*n_particles);

if cnt~=1*n_particles
    warning('Problem in reading radius...');
end

radius = (reshape(A, 1, cnt/1))';


%% Obtaining Omega
while ~startsWith(str,'omega')
    str = fgets(fileID);
end


[A,cnt] = fscanf(fileID,'%f', 3*n_particles);

if cnt~=3*n_particles
    warning('Problem in reading omega...');
end

omega = (reshape(A, 3, cnt/3))';


%% Obtaining Torque
while ~startsWith(str,'tq')
    str = fgets(fileID);
end



[A,cnt] = fscanf(fileID,'%f', 3*n_particles);

if cnt~=3*n_particles
    warning('Problem in reading torque...');
end

torque = (reshape(A, 3, cnt/3))';


%% Creating Output Table

% Combining Matrices
vtk_output = [ID type]; 

% Output as a Table
vtk_output = array2table(vtk_output);

% Adding Headings
vtk_output.Properties.VariableNames = {'ID','Type'};

% Sorting Data by ID
vtk_output = sortrows(vtk_output,1);

%% Output
fclose(fileID);
return
