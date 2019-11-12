function command = mk_plink_cmd(cmd_name,cmd,mydir)

% mk_psftp_cmd.m
%
% Function to create a text file containing user-specified commands to be
% issued to plink, the PuTTY command-line connection tool. For the
% output 'command' to work correctly, the user must have installed
% PuTTY and its associated packages and have access to the Command Prompt
% within the Windows operating system. Pageant (PuTTY authentication agent)
% should be used to negate the need to enter a password on execution of the
% list of commands.
%
%
% Tim Churchfield
%
% Last edited: 04/11/2019


%% Function Input Variables
% cmd_name   - Specified name of plink file (ie plink_cmd_1.txt)
% cmd        - X*1 cell containing psftp sequential commands
% mydir      - Storage path for output file 


%% Function Output Variables
% command    - Output to be used with the MATLAB command 'system' to
%              initiate the file created. 'ssh username@clustername -b 
%              Absolute\path\to\file\cmd_name


%% Necessary Inputs
key = specify_path_cmd;
plink_cmd      = char(key(4));


path = [mydir cmd_name];
fileID = fopen(path,'wt+');
[m, ~] = size(cmd);

% Writing to File
for i = 1:m
    fprintf(fileID, '%s\n', cmd{i});
end

fclose(fileID);
command = [plink_cmd ' -m ' path];

return