function [x_left, x_right, y_left, y_right, RR] = topSurfacePointEdges(masks)

% Calculates the left and right edge points of the top free surface of a
% rotating drum, given masks. The output coordinates are given as x and y
% coordinates (NOT image columns / rows).
% Assumes that the ratio of drum radius over particle radius equals 36.
% A point is considered to belong to the top free surface (and not the drum
% circle surface) if its distance from the drum circle is more than a
% particle radius.
% The last output, RR, is the drum radius (in pixels)

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

%% Extract the coordinates of the free (top) and bottom surface
masks = remove_0_cols_rows(masks);
%[H,W] = size(masks);
[~,W] = size(masks);

[X, Ytop] = topSurface(masks);
[~, Ybot] = bottomSurface(masks);

%% Find drum circle
drum_circle = drumCircle(masks);
x0 = drum_circle(1); % center x-coordinate
y0 = drum_circle(2); % center y-coordinate
RR = drum_circle(3); % circle radius

ratio = 36; % drum radius over particle radius
r = RR / ratio; % particle radius

%% Find left point

distance = 0;
ii = 0;

while distance <= r
    ii = ii + 1;
    x = X(ii);
    y = Ytop(ii);
    distance = abs(norm([x - x0, y - y0]) - RR);
end

x_left = x;
y_left = y;

%% Find right point

distance = 0;
ii = floor(W/2);

while distance <= r
    ii = ii + 1;
    if ii > W
        x = X(W);
        break
    end
    x = X(ii);
    y = Ybot(ii);
    distance = abs(norm([x - x0, y - y0]) - RR);
end

x_right = x;
y_right = y;
