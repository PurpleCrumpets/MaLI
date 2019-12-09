function [y, derived] = lineTwoCircles(xdata,param)

% Describes the free surface of a rotating drum analytically, using one
% straight line and two tangent circles on either side.

% Notice: It is assumed that the slope of the line is not zero or close to
% zero.

%% Input

% xdata: x-coordinates of the points of the free surface, e.g. by masks

% param: parameters of the analytical description of the curve

%% Output

% y: calculated y-coordinates of the points of the free surface

% derived: values used for the calculation of y, dependent only on param


%% Define constants
tol = 1.e-4; % tolerance for slope values

%% Define basic variables

ksi1 = param(1); % left touching point x-coordinate
y1 = param(2); % left touching point y-coordinate
ksi2 = param(3); % right touching point x-coordinate
y2 = param(4); % right touching point y-coordinate
r1 = param(5); % left circle radius
r2 = param(6); % right circle radius
r12 = r1^2;
r22 = r2^2;

%% Define derived variables

s = (y2 - y1)/(ksi2 - ksi1); % slope of the line
angle = atand(s); % dynamic angle of repose, in degrees

% Warn if slope is zero
if abs(s) < tol
    warning('The slope is zero.')
end

% Construct a unit vector perpendicular to the line with positive x
unit_x = abs(s)/sqrt(s^2 + 1);
unit_y = -unit_x/s;

% [ksi_c1, y_c1]: first center coordinates
% [ksi_c2, y_c2]: second center coordinates
ksi_c1 = ksi1 - r1*unit_x;
y_c1 = y1 - r1*unit_y;
ksi_c2 = ksi2 + r2*unit_x;
y_c2 = y2 + r2*unit_y;

if nargout > 1
    derived = [angle s ksi_c1 y_c1 ksi_c2 y_c2];
end

%% Calculate output
y = zeros(size(xdata));

for ii = 1:numel(xdata)
    x = xdata(ii);
    
    if (x >= ksi1) && (x <= ksi2)
        y(ii) = y1 + s*(x - ksi1);
    elseif (x < ksi1)
        y(ii) = y_c1 - sign(s)*sqrt(r12 - (x - ksi_c1)^2);
    else
        y(ii) = y_c2 + sign(s)*sqrt(r22 - (x - ksi_c2)^2);
    end
    
end

% Warn if complex outputs have been produced
if ~isreal(y)
    warning('Complex-valued outputs.')
end