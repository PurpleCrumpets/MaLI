function masks_short = remove_0_cols_rows(masks)

% Removes the columns and rows of masks which consist entirely of zero
% (background) values.

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

masks_short=masks(any(masks,2),any(masks,1));