function results = curveProperties(vidmasks,framerate,model)

% Calculates the properties of the rotating drum that do not depend on the
% type of particles, for a given sequence of masks according to the chosen
% model.

% vidmasks: uint8 H x W x F matrix with values corresponding to colors:
% 1: red, 2: white, 0: background (black)

% (F: number of frames)

% framerate: in frames per second

% model: character, the nonlinear model chosen to describe the top free
% curve analytically
% Available models:
%   - 'noModel': The top free surface is described by a first order
%       polynomial. The function angle_of_repose_img.m is used.
%   - 'threeAngles': The top free surface is described by three consecutive
%       straight lines, smoothed at their intersections. The function
%       threeAngles.m is used.
%   - 'lineTwoCircles': The top free surface is described by one straight
%       line and two tangent circles on either side. The function
%       lineTwoCircles.m is used.

% results: structure with F elements, containing the following fields:
%   - time: double, the time of the corresponding frame (s)
%   - xdrum: the x-coordinate of the drum center (pixels)
%   - ydrum: the y-coordinate of the drum center (pixels)
%   - rdrum: the radius of the drum (pixels)
%   - angle_av: double, the average dynamic angle of repose, based on a
%       first order approximation of the free surface (degrees)
%   - R2lin: the coefficient of determination of the linear fit
% Additional fields if a model different from 'noModel' is chosen
%   - param: double vector, the parameters of the nonlinear model
%   - angle_nnl: double, the dynamic angle of repose in the middle section
%       of the drum, as calculated by the nonlinear model (degrees)
% Additional fields if 'threeAngles' model is chosen
%   - angle1, angle2: double, the dynamic angles from left to right
%       (degrees)
%   - radius1, radius2: double, the radii of curvature, from left to right
%       (pixels)
% Additional fields if 'lineTwoCircles' model is chosen
%   - radius1, radius2: double, the radii of curvature, from left to right
%       (pixels)

%% Check model validity
if strncmpi(model,'noModel',1)
    model = 'noModel';
elseif strncmpi(model,'threeAngles',1)
    model = 'threeAngles';
elseif strncmpi(model,'lineTwoCircles',1)
    model = 'lineTwoCircles';
else
    error('Invalid model.')
end

%% Calculate results
F = size(vidmasks,3);
first_frame = 1;

for fr = F:-1:1
    
    masks = vidmasks(:,:,fr);
    
    results(fr).time = (fr-1)/framerate;
    drum = drumCircle(masks);
    results(fr).xdrum = drum(1);
    results(fr).ydrum = drum(2);
    results(fr).rdrum = drum(3);
    [a_repose, ~, ~, ~, R2] = angle_of_repose_img(masks);
    results(fr).angle_av = a_repose;
    results(fr).R2lin = R2;
    
    if ~strncmpi(model,'noModel',1)
        
        if first_frame
            first_frame = 0;
            param = findFreeSurface(masks, model);
        else
            param = findFreeSurface(masks, model, param);
        end

        if strncmpi(model,'threeAngles',1)
            
            [~, derived] = threeAngles([],param);
            results(fr).angle1 = derived(1);
            results(fr).angle_nnl = derived(2);
            results(fr).angle2 = derived(3);
            results(fr).radius1 = derived(19);
            results(fr).radius2 = derived(20);      
            
        else % model: 'lineTwoCircles'
            
            [~, derived] = lineTwoCircles([],param);
            results(fr).angle_nnl = derived(1);
            results(fr).radius1 = param(5);
            results(fr).radius2 = param(6);            
            
        end
        
        results(fr).param = param;
        
    end
    
end