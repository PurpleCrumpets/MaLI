function output = readDataHeadSimSettings(pathDataHead)

% readDataHeadSimSettings.m
%
% Function to obtain the primary simulation settings from the data.head
% file of a LIGGGHTS simulation.
%
%
% Tim Churchfield
%
% Last edited: 18/11/2019

%% Variable Dictionary
% 
% -- Input --
%
% pathDataHead - Path for dat.head file (including file name). This can
%                be an absolute path or path relative to the function.
%
% -- Output --
%
% output      - Values defined for primary simulation settings in
%               data.head file.
%
% -- Other --
% fd          - File ID for data.head. 
% str         - String comtaining line from data.head.
%
%
%% Execution

% open data.head 
fd = fopen(pathDataHead,'r');
str = fgets(fd);   

% simdim 
while ~startsWith(str,'variable simdim ')
    str = fgets(fd);
end
output{1,1} = {'simdim'};
output{2,1} = sscanf(str,'variable simdim equal %d');
frewind(fd); % Reset read position in data.head

% periodicbb
while ~startsWith(str,'variable periodicbb ')
    str = fgets(fd);
end
output{1,2} = {'periodicbb'};
output{2,2} = sscanf(str,'variable periodicbb equal %d');
frewind(fd);

% proc 
while ~startsWith(str,'variable proc ')
    str = fgets(fd);
end
output{1,3} = {'proc'};
output{2,3} = sscanf(str,'variable proc equal %d');
frewind(fd);

% nodes
while ~startsWith(str,'variable nodes ')
    str = fgets(fd);
end
output{1,4} = {'nodes'};
output{2,4} = sscanf(str,'variable nodes equal %d');
frewind(fd);

% autoproc
while ~startsWith(str,'variable autoproc ')
    str = fgets(fd);
end
output{1,5} = {'autoproc'};
output{2,5} = sscanf(str,'variable autoproc equal %d');
frewind(fd);

% xproc
while ~startsWith(str,'variable xproc ')
    str = fgets(fd);
end
output{1,6} = {'xproc'};
output{2,6} = sscanf(str,'variable xproc equal %d');
frewind(fd);

% yproc
while ~startsWith(str,'variable yproc ')
    str = fgets(fd);
end
output{1,7} = {'yproc'};
output{2,7} = sscanf(str,'variable yproc equal %d');
frewind(fd);

% zproc
while ~startsWith(str,'variable zproc ')
    str = fgets(fd);
end
output{1,8} = {'zproc'};
output{2,8} = sscanf(str,'variable zproc equal %d');
frewind(fd);

% Close data.head
fclose(fd);