function mask = createMask(ImageStructRow)

% createmask.m
% 
% Function to create mask of particles from LIGGGHTS image.
%
% Tim Churchfield
%
% Last edited: 15/10/2019


%% Function Input Variables
% imageStructRow - row of structure of image files produced from 'dir'
%                  command


%% Function Output Variables
% mask          - int8 mask of image. 0 = black background, 
%                 1 = red polypropylene particles, 
%                 2 = white glass particles. 


%% Import Image
ImPath = fullfile(ImageStructRow.folder, ImageStructRow.name);
Im = imread(ImPath);
sum_all = size(Im,1)*size(Im,2);

% Specify colour channels
R = Im(:,:,1);
G = Im(:,:,2);
B = Im(:,:,3);


%% Obtain Black Pixels
test1 = R == 0;
test2 = G == 0;
test3 = B == 0;

ImBlack = and(test1,test2);
ImBlack = and(ImBlack,test3);

sum_black = sum(sum(ImBlack,1));


%% Obtain Red Pixels
test1 = ~(R == G);
test2 = ~(R == B);
maskRed = or(test1,test2);

sum_red = sum(sum(maskRed,1));


%% Obtain White Pixels
test1 = (R == G & R > 0 & G > 0);
test2 = (R == B & R > 0 & B > 0);
test3 = (G == B & G > 0 & B > 0);

maskWhite = and(test1,test2);
maskWhite = and(maskWhite,test3);

sum_white = sum(sum(maskWhite,1));


%% Test for Unaccounted Pixels
missing = sum_all - (sum_black+sum_red+sum_white);

if missing == 1
    warning([num2str(missing) ' pixel is not accounted for!']);
elseif missing > 1
    warning([num2str(missing) ' pixels are not accounted for!']);
end


%% Output Mask
maskRed = maskRed*1;
maskWhite = maskWhite*2;
mask = maskRed+maskWhite;
mask = cast(mask,'int8'); % Lower Memory Requirements


return