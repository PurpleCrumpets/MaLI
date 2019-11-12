function [param, xdata, ydata, ycalc, residual, iterations] =...
    findFreeSurface(masks, model, param0)

% Calculates the parameters that best describe the curve of the top free
% surface of a rotating drum.
% The curve is described analytically by one of the chosen models.
% The model parameters are calculated from the masks data using nonlinear
% least squares / the Levenberg-Marquardt algorithm.

% The assumption that the ratio of drum radius over ball radius is equal to
% 36 is used:
ratio = 36;

% Inputs:

% masks: uint8 H x W matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

% model: character, the model chosen to describe the curve analytically
% Available models:
%   - 'threeAngles': The top free surface is described by three consecutive
%       straight lines, smoothed at their intersections. The function
%       threeAngles.m is used.
%   - 'lineTwoCircles': The top free surface is described by one straight
%       line and two tangent circles on either side. The function
%       lineTwoCircles.m is used.

% param0: real vector, initial values for the parameters of the analytic
% curve, depending on the chosen model, same order as the output "param".
% If it is omitted, default initial values are used.

% Outputs:

% param: parameters of the analytic curve, as calculated from the nonlinear
% least squares function.
% If the model is 'threeAngles':
    % param(1): left slope
    % param(2): middle slope
    % param(3): right slope
    % param(4): left endpoint x-coordinate
    % param(5): left endpoint x-coordinate
    % param(6): left intersection point x-coordinate
    % param(7): right endpoint x-coordinate
    % param(8): right endpoint y-coordinate
    % param(9): left smoothing distance
    % param(10): right smoothing distance
% If the model is 'lineTwoCircles':
    % param(1): left touching point x-coordinate
    % param(2): left touching point y-coordinate
    % param(3): right touching point x-coordinate
    % param(4): right touching point y-coordinate
    % param(5): left circle radius
    % param(6): right circle radius

% xdata: x-coordinates of the top free surface derived from masks

% ydata: y-coordinates of the top free surface derived from masks

% ycalc: y-coordinates of the top free surface calculated analytically
% using param after the nonlinear least squares

% residual: value of the objective value at solution, real vector of the
% same size as xdata

% iterations: total number of iterations of the Levenberg-Marquardt
% algorithm


%% Check model validity
if strncmpi(model,'threeAngles',1)
    model = 'threeAngles';
elseif strncmpi(model,'lineTwoCircles',1)
    model = 'lineTwoCircles';
else
    error('Invalid model.')
end

%% Extract the coordinates of the top (free) surface from masks
[Xtop, Ytop] = topSurface(masks);
[x_left, x_right, y_left, y_right, RR] = topSurfacePointEdges(masks);
Xfree = (Xtop >= x_left) & (Xtop <= x_right);
xdata = Xtop(Xfree);
ydata = Ytop(Xfree);

%% Initial parameter values

% Default in case param0 is not provided.
% If 'threeAngles' model is chosen, the initial values are such that:
%   - the left and right endpoints coincide with those from masks,
%   - the x-coordinates of the intersection points are evenly spaced
%       between x_left and x_right,
%   - the left and right slopes are equal,
%   - the middle straight line amounts to 80% of the total height
%       difference,
%   - the smoothing distances are equal to the ball diameter.
% If 'lineTwoCircles' model is chosen, the initial values are such that:
%   - the two touching points coincide with those from masks,
%   - the two radii are one third of the drum radius.

if nargin < 3
    if strncmpi(model,'threeAngles',1)
        sl_av = (y_right - y_left)/(x_right - x_left); % average slope
        s1 = 0.3*sl_av; % left slope
        s2 = 2.4*sl_av; % middle slope
        s3 = s1; % right slope
        ksi1 = (2*x_left + x_right)/3; % left intersection point...
                                       % x-coordinate
        r = RR / ratio; % ball radius
        ds = 2*r; % smoothing distance

        param0 = [s1, s2, s3, x_left, y_left, ksi1, x_right, y_right,...
            ds, ds];
    else % strncmpi(model,'lineTwoCircles',1)
        r = RR/3; % curvature radius
        param0 = [x_left, y_left, x_right, y_right, r, r];
    end
end

%% Nonlinear least squares

% Choose model
fun = @(param,xdata)feval(model,xdata,param);
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt',...
    'Display','off');

[param,~,residual,~,optInfo] =...
    lsqcurvefit(fun,param0,xdata,ydata,[],[],options);
iterations = optInfo.iterations;
loop = 0;
disp('findFreeSurface.m called')
while optInfo.iterations > 2
    [param,~,residual,~,optInfo] =...
        lsqcurvefit(fun,param,xdata,ydata,[],[],options);
    iterations = iterations + optInfo.iterations;
    loop = loop+1;
    disp(['loop count: ', num2str(loop), ' Iterations: ', num2str(optInfo.iterations)])
end

ycalc = feval(model,xdata,param);
