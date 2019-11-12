function [y, derived] = threeAngles(xdata,param)

% Describes the free surface of a rotating drum analytically, using three
% consecutive straight lines, in general with different slopes, smoothed at
% their intersections.

%% Input

% xdata: x-coordinates of the points of the free surface, e.g. by masks

% param: parameters of the analytical description of the curve

%% Output

% y: calculated y-coordinates of the points of the free surface

% derived: values used for the calculation of y, dependent only on param


%% Define constants
tol = 1.e-4; % tolerance for slope values

%% Define basic variables
s1 = param(1); % left slope
s2 = param(2); % middle slope
s3 = param(3); % right slope
ksi0 = param(4); % left endpoint x-coordinate
y0 = param(5); % left endpoint y-coordinate
ksi1 = param(6); % left intersection point x-coordinate
ksi3 = param(7); % right endpoint x-coordinate
y3 = param(8); % right endpoint y-coordinate
ds1 = param(9); % left smoothing distance
ds2 = param(10); % right smoothing distance
ds12 = ds1^2;
ds22 = ds2^2;

%% Define derived variables

angle1 = atand(s1); % left angle, in degrees
angle2 = atand(s2); % middle angle, in degrees
angle3 = atand(s3); % rightmost angle, in degrees

y1 = y0 + s1*(ksi1 - ksi0); % left intersection height

inter2 = [s2, -1; s3, -1]\[s2*ksi1 - y1; s3*ksi3 - y3];
ksi2 = inter2(1); % right intersection point
y2 = inter2(2); % right intersection height

sm1 = sqrt(ds12/(1 + s1^2)); % first smoothing x-difference
sm2 = sqrt(ds12/(1 + s2^2)); % second smoothing x-difference
sm3 = sqrt(ds22/(1 + s2^2)); % third smoothing x-difference
sm4 = sqrt(ds22/(1 + s3^2)); % fourth smoothing x-difference

ksi4 = ksi1 - sm1; % first smoothing point
ksi5 = ksi1 + sm2; % second smoothing point
ksi6 = ksi2 - sm3; % third smoothing point
ksi7 = ksi2 + sm4; % fourth smoothing point
y4 = y0 + s1*(ksi4 - ksi0); % first smoothing point height
y5 = y1 + s2*(ksi5 - ksi1); % second smoothing point height
y6 = y1 + s2*(ksi6 - ksi1); % third smoothing point height
y7 = y3 + s3*(ksi7 - ksi3); % fourth smoothing point height

% [ksi_c1, y_c1]: first smoothing center coordinates
% [ksi_c2, y_c2]: second smoothing center coordinates

if abs(s1) < tol
    ksi_c1 = ksi4;
    y_c1 = y5 - (ksi4 - ksi5)/s2;
else
    cent1 = [1/s1, 1; 1/s2, 1]\[y4 + ksi4/s1; y5 + ksi5/s2];
    ksi_c1 = cent1(1);
    y_c1 = cent1(2);
end

if abs(s3) < tol
    ksi_c2 = ksi7;
    y_c2 = y6 - (ksi7 - ksi6)/s2;
else
    cent2 = [1/s2, 1; 1/s3, 1]\[y6 + ksi6/s2; y7 + ksi7/s3];
    ksi_c2 = cent2(1);
    y_c2 = cent2(2);
end

r1 = norm([ksi_c1 - ksi4, y_c1 - y4]); % first radius of curvature
r2 = norm([ksi_c2 - ksi7, y_c2 - y7]); % second radius of curvature
r12 = r1^2;
r22 = r2^2;

if nargout > 1
    derived = [angle1 angle2 angle3 y1 ksi2 y2 ksi4 y4 ksi5 y5 ksi6 y6...
        ksi7 y7 ksi_c1 y_c1 ksi_c2 y_c2 r1 r2];
end

%% Calculate output
y = zeros(size(xdata));

for ii = 1:numel(xdata)
    x = xdata(ii);
    
    if x <= ksi4
        y(ii) = y0 + s1*(x - ksi0);
    elseif (x > ksi4) && (x < ksi5)
        y(ii) = y_c1 + sign(y1 - y_c1)*sqrt(r12 - (x - ksi_c1)^2);
    elseif (x >= ksi5) && (x <= ksi6)
        y(ii) = y1 + s2*(x - ksi1);
    elseif (x > ksi6) && (x < ksi7)
        y(ii) = y_c2 + sign(y2 - y_c2)*sqrt(r22 - (x - ksi_c2)^2);
    elseif x >= ksi7
        y(ii) = y2 + s3*(x - ksi2);        
    end
    
end