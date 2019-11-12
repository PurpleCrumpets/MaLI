function C = circle(matrix_size,center,radius,class)

% Creates a square matrix of matrix_size
% which includes elements of a circle with given center and radius.
% The matrix elements equal 1 if they are inside or on
% the circle, otherwise they equal 0.

% center: contains the coordinates of the circle
% as [x0,y0]
% x0 = i (integer) means the line between i and (i+1) matrix row
% y0 = j (integer) means the line between j and (j+1) matrix column
% Non-integer values are linearly distributed.

% If the center is not given, the center of the matrix
% is chosen as the center of the circle.

% radius: the radius of the circle.
% If it is not given, the value is set to half the minimum size dimension.

% If neither the center nor the radius are given,
% the inscribed circle is formed.

if nargin < 4
    class = 'uint8';
end

matrix_size = floor(matrix_size);
C = ones(matrix_size,class);

if nargin < 3
    radius = min(matrix_size)/2;
end
radius2 = radius^2;

height = matrix_size(1);
if numel(matrix_size) < 2
    width = height;
else
    width = matrix_size(2);
end

% Coordinates of the center:
if nargin < 2
    x0 = height/2;
    y0 = width/2;
else
    x0 = center(1);
    y0 = center(2);
end

for x = 1:height
    for y = 1:width
        if (x-0.5-x0)^2 + (y-0.5-y0)^2 > radius2
            C(x,y) = 0;
        end
    end
end