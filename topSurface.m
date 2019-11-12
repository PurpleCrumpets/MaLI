function [Xtop, Ytop] = topSurface(masks)

% Extracts the coordinates of the free (top) surface of a rotating drum,
% given masks. The output coordinates are given as x and y coordinates (NOT
% image columns / rows).

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

masks = remove_0_cols_rows(masks);
[H,W] = size(masks);

Xtop = imcols2x([1:W]);
rows = zeros(1,H);
for jj = 1:W
    rows(jj) = find(masks(:,jj),1);
end
Ytop = imrows2y(rows,H);