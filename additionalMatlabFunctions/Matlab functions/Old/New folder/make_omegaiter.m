%function 

% create_omegaiter.m
%
% Function to create a text file containing  
% Currently Linear Only
%
% Tim Churchfield
%
% Last edited: 04/09/2019


%% Function Input Variables
% filename   - Absolute path to VTK file, including file name


%% Function Output Variables
% vtk_output - Table containing data from VTK file with appropriate
%              headings
clc
clear
close


%% Obtain key
key = specify_path_cmd;
path_local_in  = char(key(1));
path_local_out = char(key(2));
path_hypnos    = char(key(3));
plink_cmd      = char(key(4));
psftp_cmd      = char(key(5));


%% Create Test Case
% 
ts = 0.00050;
% time = [0;1;30;31];
% rpm = [0;40;40;0];

%ts = 0.0000050;
time = [0;1;4];
rpm = [0;40;40];

rotvar = table(time,rpm);

%% Obtain Time-step Data from data.head
% ts = 0.0000050;
% 
% angularaccel = PI/2; % Angular acceleration at start-up (rad/s2)
% rpm = 40.0; % rpm of drum (rpm)
% numrot = 10.0; % Number of rot (-) (after reaching SS)
% acctime = 01.0; % Time to reach operational rpm (s) 
% 
% % Create time, rpm array
% time = numrot/
% 
% time = [0;1;49;50];
% rpm = [0;40;40;0];
% 
% rotvar = table(time,rpm);



%% Adding 
timesteps = round(rotvar.time./ts);
omega = rotvar.rpm.*(pi/30);
rotvar = addvars(rotvar,timesteps,'After','time');
rotvar = addvars(rotvar,omega,'After','rpm');


%% Convert to Rotational Velocity and Step Count Basis
coefficients = zeros(size(rotvar,1),2);
eqn_coefficients = cell(size(rotvar,1),1);

% Assuimg Linear Relationship
for i = 2:size(rotvar,1)
    
    coefficients(i,1) = (rotvar.omega(i)-rotvar.omega(i-1))/...
        (rotvar.timesteps(i)-rotvar.timesteps(i-1));
    coefficients(i,2) = rotvar.omega(i)-(coefficients(i,1)*...
        rotvar.timesteps(i));
    eqn_coefficients(i) = {coefficients(i,:)};
end

rotvar = addvars(rotvar,eqn_coefficients);


%% Creating Timestep/Omega Information
% Create empty array
omega_iter = zeros(rotvar.timesteps(end),2);


% Efficiently create omega_iter. If m in y=mx+c is 0, the loop can be
% skipped






if rotvar.eqn_coefficients{3,1}(1) == 0 && size(rotvar,1) == 3
    k = 2;
    for i = 1:(rotvar.timesteps(k))
        omega_iter(i,1) = i;
        omega_iter(i,2) = rotvar.eqn_coefficients{k,1}(1)*(i)+rotvar.eqn_coefficients{k,1}(2);
    end
    
    k = 3;
    for i = 1:(rotvar.timesteps(k))
        omega_iter(i,1) = i;
        omega_iter(i,2) = rotvar.eqn_coefficients{k,1}(1)*(i)+rotvar.eqn_coefficients{k,1}(2);
    end
        
else 
    j = 1;
    for k = 2:size(rotvar,1)
        disp(k-1);
        tic
        for i = j:(rotvar.timesteps(k))
            omega_iter(i,1) = i;
            omega_iter(i,2) = rotvar.eqn_coefficients{k,1}(1)*(i)+rotvar.eqn_coefficients{k,1}(2);
        end
        j = i;
        toc
    end
 
%     omega_iter1 = omega_iter;
%     tic
%     tf = isequal(omega_iter,omega_iter1);
%     toc
%     
end


% Add initial conditions 
% omega_iter = [0,0;omega_iter];

% Plot results
plot(omega_iter(:,1),omega_iter(:,2))

% Saving output
disp('Saving as omega_iter.txt.');
omega_iter_out = omega_iter(:,2);
save('omega_iter.txt','omega_iter_out','-ascii');


size_data = whos('omega_iter_out');
% if size_data.bytes >= 2/1e+9
%     disp('Saving output as compressed v7.3 MAT file...');
%     save([path_project project_name tail],'vtk_data_out','-v7.3');
% else
%     disp('Saving output to file...');
%     save([path_project project_name tail],'vtk_data_out');
% end
% disp('Output saved to file...');







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%coefficients = zeros(4,1);
%eqn_type = {'';'linear';'constant';'linear'};

%rotvar = table(time,rpm,eqn_type);


%%%%%%%%%%%%%%%%%%%%
% Converting to Rotational Velocity and Timestep Basis
% for i = 1:size(rotvar,1)
%     if strcmpi(rotvar.eqn_type(i),'linear')
%         disp('Linear');
%              
%     elseif strcmpi(rotvar.eqn_type(i),'constant')
%         disp('Constant')
% 
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%
% iteration = zeros(rotvar.timesteps(end),2);
% final = [];
% for j = 2:size(rotvar,1)
%     
%     iteration = zeros((rotvar.timesteps(j)-rotvar.timesteps(j-1)),2);
%     for i = rotvar.timesteps(j-1)+1:rotvar.timesteps(j)+1
%         iteration(i,1) = i-1;
%         iteration(i,2) = rotvar.eqn_coefficients{2,1}(1)*i...
%             +rotvar.eqn_coefficients{2,1}(2);
%     end
%     final = [final; iteration]; 
% end