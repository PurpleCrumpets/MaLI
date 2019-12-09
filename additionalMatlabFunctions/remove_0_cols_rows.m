function [masks_short, corners] = remove_0_cols_rows(masks)

% Removes the columns and rows of masks which consist entirely of zero
% (background) values.
% Also returns the indices of the first and last nonzero column and row in
% masks.

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

if nargout > 1
    firstcol = find(any(masks),1); % first nonzero column
    firstrow = find(any(masks,2),1); % first nonzero row
    lastcol = find(any(masks),1,'last'); %last nonzero column
    lastrow = find(any(masks,2),1,'last'); %last nonzero row
    corners = [firstcol, lastcol, firstrow, lastrow];
end

masks_short=masks(any(masks,2),any(masks,1));