function x = imcols2x(cols)

% Converts the column numbers of an image to x coordinates.
% The x and y axes have the usual orientation and the origin is at the low
% left corner of the image. The resulting x and y are at the center of the
% corresponding pixels.

if ~isempty(cols)
    x = cols - 0.5;
else
    error('Empty input')
end