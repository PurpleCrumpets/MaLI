function [iimage_drum] = create_image(data,type_data,particle_properties,plane,id_drum)

% create_image.m
%
% Function to take particle data extracted from a LIGGGHTS' VTK file and
% create a 2D image.
%
% Tim Churchfield
%
% Last edited: 12/08/2019


%% Function Input Variables
% data                - 
% type_data           -
% particle_properties - 
% plane               - 2x3 matrix defining the imaging plane. plane(1,1:3)
%                       defines a point on the plane and plane(2,1:3)
%                       defines a unit vector perpendicular to the plane.
% id_drum             - Internal diameter of drum (metres). Used to scale
%                       the particle based on the number of pixels in the
%                       vertical axis of the image.


%% Function Output Variables
% iimgae_drum - 2D image of particles in drum




%% Creating Selection Criteria

[particle_num, ~] = size(type_data);

% Determine distance from centre of particle to plane
coordinates = data.Data{end,1}.Position;

plane_vector = coordinates - plane(1,:);


% Need to calculate particle_num
plane_dist = zeros(particle_num,1);

for k = 1:particle_num
    plane_dist(k,1) = dot(plane_vector(k,:),plane(2,:));
end

% Selecting particles within one particle radius of plane
test = logical.empty(0,particle_num);

for k = 1:particle_num
    
    if table2array(type_data(k,2)) == 1
        test(k) = abs(plane_dist(k)) <=...
           table2array(particle_properties(1,2));
    elseif table2array(type_data(k,2)) == 2
        test(k) = abs(plane_dist(k)) <=...
           table2array(particle_properties(2,2));
    end
    
end

% Shortlist of particles to be imaged
imaging_data = data.Data{end,1}(test,:);
plane_dist = plane_dist(test,1);
[image_particle_num, ~] = size(imaging_data); 
 
% Coordinates, radius of circles to be created
image_coord = imaging_data.Position - plane_dist*plane(2,:);
image_coord(:,2) = -image_coord(:,2); % All og Y pos were negative
image_coord(:,3) = -image_coord(:,3); % All og Z pos were negative
image_radius = zeros(image_particle_num,1);
image_type = table2array(type_data(test,2));

for k = 1:image_particle_num
    if image_type(k,1) == 1
        image_radius(k,1) = sqrt((table2array(particle_properties(1,2)))^2-(abs(plane_dist(k)))^2);
    elseif image_type(k,1) == 2
        image_radius(k,1) = sqrt((table2array(particle_properties(2,2)))^2-(abs(plane_dist(k))^2));
    end
end


%% Converting 3D plane to new 2D CS if Required

% Checking if plane perpendicular to CS
test = all(plane(2,:),1);

if sum(test == 1) == 1
    if test(1) == 1
        image_coord_2D = image_coord(:,[2 3]);
        origin = plane(1,[3 2 1]);
    elseif test(2) == 1
        image_coord_2D = image_coord(:,[1 3]);
        origin = plane(1,[1 3 2]);
    elseif test(3) == 1
        image_coord_2D = image_coord(:,[1 2]);
        origin = plane(1,[1 2 3]);
    end
else
    % Converting CS
    origin = plane(1,:);
    % Calculate out-of-plane vector (local z)
    N = size(image_coord,1);

    % origin = plane(1,:);
    localz = cross(image_coord(2,:)-origin, image_coord(3,:)-origin);

    % Normalising
    unitz = localz/norm(localz,2);

    % Calculate local x vector in plane
    localx = image_coord(2,:)-origin;   
    unitx = localx/norm(localx,2);

    % Calculate local y
    localy = cross(localz, localx);  
    unity = localy/norm(localy,2); 

    % Assume transformation matrix
    T = [unitx(:), unity(:), unitz(:), origin(:); 0 0 0 1];
    C = [image_coord, ones(N,1)];
    image_coord_2D = T \ C';
    image_coord_2D = image_coord_2D(1:2,:)'; 
end


%% Creating Colour Image
image_resolution = [1920 1080]; % horizontal, vertical resolution

[columnsInImage, rowsInImage] = meshgrid(-image_resolution(1)/2:...
    image_resolution(1)/2,-image_resolution(2)/2:image_resolution(2)/2);

% Scaling Image based on ID of Drum
ppm = image_resolution(2)/id_drum;

image_drum   = false(size(columnsInImage,1),size(columnsInImage,2));

for k = 1:image_particle_num
    int =(rowsInImage - ppm*image_coord_2D(k,2)).^2 ...
        + (columnsInImage - ppm*image_coord_2D(k,1)).^2 ...
        <= (ppm*image_radius(k)).^2; 
    if image_type(k) == 1
        R = 1;
        G = 0;
        B = 0;
        int = cat(3,int*R,int*G,int*B);         
    elseif image_type(k) == 2
        R = 1;
        G = 1;
        B = 1;
        int = cat(3,int*R,int*G,int*B); 
    end
    image_drum = or(int,image_drum);
end

% Saving Images
iimage_drum = image(image_drum);

return