% Incomplete!

function drum_circle = drumCircle(masks)

% Estimates the position of the center of the drum and its radius (in
% pixels) in the image (masks), using the lowest color pixel from each
% column and fitting a least-square circle. The image should not have any
% noise below the free surface of the circles.

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

%% Extract the coordinates of the bottom surface
[X, Y] = bottomSurface(masks);

% The following command, which removes all redundant rows and columns from
% masks, is used in bottomSurface(masks):
% masks = remove_0_cols_rows(masks);

%% Find the circle

XY = [X; Y]';
drum_circle = CircleFitByPratt(XY);