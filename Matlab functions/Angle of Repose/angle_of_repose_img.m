function [a_repose, polyn, R2] = angle_of_repose_img(masks)
% Calculates the average dynamic angle of repose, in degrees, for one given
% image, represented by masks. The image should not have any noise above
% the free surface of the circles.

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)


%% Extract the coordinates of the free (top) surface
masks = remove_0_cols_rows(masks);
[H,W] = size(masks);

X = imcols2x([1:W]);
rows = zeros(1,H);
for jj = 1:W
    rows(jj) = find(masks(:,jj),1);
end
Y = imrows2y(rows,H);

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