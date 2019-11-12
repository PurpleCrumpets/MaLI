function [a_repose, X, Y, polyn, R2] = angle_of_repose_img(masks)
% Calculates the average dynamic angle of repose, in degrees, for one given
% image, represented by masks. The image should not have any noise above
% the free surface of the circles.

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

% Remark: the actual values of the elements of masks do not matter, as long
% as the background has the value 0 and the foreground (balls) have nonzero
% values.

%% Extract the coordinates of the top (not free) surface
[Xtop, Ytop] = topSurface(masks);

% The following command, which removes all redundant rows and columns from
% masks, is used in topSurface(masks):
% masks = remove_0_cols_rows(masks);

%% Extract the coordinates of the free surface edges
[x_left, x_right] = topSurfacePointEdges(masks);
Xfree = (Xtop >= x_left) & (Xtop <= x_right);
X = Xtop(Xfree);
Y = Ytop(Xfree);

%% Linear regression
[polyn,S] = polyfit(X,Y,1);
slope = polyn(1);
a_repose = atand(slope);

%https://de.mathworks.com/help/matlab/data_analysis/linear-regression.html
yfit = polyval(polyn,X);
yresid = Y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(Y)-1) * var(Y);
R2 = 1 - SSresid/SStotal;