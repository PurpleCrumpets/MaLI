function C = colorcircle(color,matrix_size,center,radius)

% Creates a 3-D colored circle image based on the data.
% The background is black.

if nargin < 3
    A = circle(matrix_size);
elseif nargin < 4
    A = circle(matrix_size,center);
else
    A = circle(matrix_size,center,radius);
end

if isequal(color,'red')
    C(:,:,1) = 255*A;
    C(:,:,2) = 0;
    C(:,:,3) = 0;
elseif isequal(color,'white')
    A = 255*A;
    C = cat(3,A,A,A);
else
    msg = 'No valid color choice.';
    error(msg);
end