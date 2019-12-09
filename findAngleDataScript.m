

clc
close all
clear
fclose('all');


%% User Input
basis.path = 'D:\calibration\DEcaliocTest\DEcalioc\optim\rotatingdrum35\0001jpa_45752';
optim.path = 'D:\calibration\DEcaliocTest\DEcalioc\optim\'; 


%% Execution
% Load basis parameter values
basis.parameters = csvread(fullfile(basis.path,'params.csv'));

% Get optim directory listing
optim.dir = dir(optim.path);
optim.dir = optim.dir(~ismember({optim.dir.name},{'.','..'}));

simName = {};
k = 1;

% Loop
for i = 1:length(optim.dir)
    listing = dir(fullfile(optim.path,optim.dir(i).name));
    listing = listing(~ismember({listing.name},{'.','..'}));
    
    for j = 1:length(listing)
        
        % Read parameters
        param = csvread(fullfile(optim.path,optim.dir(i).name,...
            listing(j).name,'params.csv'));
        
        % Compare parameters
        tf = isequal(basis.parameters, param);
        
        if tf == 1
            simName{k,1} = fullfile(optim.path,optim.dir(i).name,...
            listing(j).name);
            
            % open angleRepose.txt file
            fd = fopen(fullfile(simName{k,1},'analysis',[listing(j).name, '_angleRepose.txt']),'r');
            % Read file into cell A
            l = 1;
            tline = fgetl(fd);
            A{k,l} = str2num(tline);
            while ischar(tline)
                l = l+1;
                tline = fgetl(fd);
                try
                    A{k,l} = str2num(tline);
                catch
                    A{k,l} = tline;
                end
            end

            % Close file
            fclose(fd);
            
            % Increment simName count
            k = k+1;
        end         
    end     
end

% Remove redundant line, store results
A = A(:,1:(end-1));

% Stores results
results = [simName A];