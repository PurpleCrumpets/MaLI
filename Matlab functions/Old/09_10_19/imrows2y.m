function y = imrows2y(rows,height)

% Converts the row numbers of an image to y coordinates.
% The x and y axes have the usual orientation and the origin is at the low
% left corner of the image. The resulting x and y are at the center of the
% corresponding pixels.

% height: the number of rows of the image

if ~isempty(rows)
    y = height + 0.5 - rows;
else
    error('Empty input')
end