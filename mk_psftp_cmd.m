function command = mk_psftp_cmd(cmd_name,cmd,mydir)

% mk_psftp_cmd.m
%
% Function to create a text file containing user-specified commands to be
% issued to PSFTP, the PuTTY SSH File transfer protocol client. For the
% output 'command' to work correctly, the user must have installed
% PuTTY and its associated packages and have access to the Command Prompt
% within the Windows operating system. Pageant (PuTTY authentication agent)
% should be used to negate the need to enter a password on execution of the
% list of commands.
%
%
% Tim Churchfield
%
% Last edited: 03/09/2019


%% Function Input Variables
% cmd_name   - Specified name of psftp file (ie psftp_cmd_1.txt)
% cmd        - X*1 cell containing psftp sequential commands
% mydir      - Storage path for output file 


%% Function Output Variables
% command    - Output to be used with the MATLAB command 'system' to
%              initiate the file created. 'psftp username@clustername -b 
%              Absoulte\path\to\file\cmd_name


%% Necessary Inputs
key = specify_path_cmd;
psftp_cmd      = char(key(5));

path = [mydir cmd_name];
fileID = fopen(path,'wt+');
[m, ~] = size(cmd);

% Writing to File
for i = 1:m
    fprintf(fileID, '%s\n', cmd{i});
end

fclose(fileID);
command = [psftp_cmd ' -b ' path];

return