clc
clear all
% % Initialization steps.
% clc;    % Clear the command window.
% close all;  % Close all figures (except those of imtool.)
% clear;  % Erase all existing variables. Or clearvars if you want.
% workspace;  % Make sure the workspace panel is showing.
% format long g;
% format compact;
% fontSize = 20;
% % Make a circular image mask.
% % Adapted from FAQ: http://matlab.wikia.com/wiki/FAQ#How_do_I_create_a_circle.3F
% % Create a logical image of a circle with specified
% % diameter, center, and image size.
% % First create the image.
% imageSizeX = 640;
% imageSizeY = 240;
% [columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% % Next create the circle in the image.
% centerX = 320;
% centerY = 120;
% radius = 70;
% circlePixels = (rowsInImage - centerY).^2 ...
%     + (columnsInImage - centerX).^2 <= radius.^2;
% % circlePixels is a 2D "logical" array.
% % Now, display it.
% subplot(2, 2, 2);
% image(circlePixels) ;
% axis image;
% title('Binary image of a circle', 'FontSize', fontSize);
% colormap([0 0 0; 1 1 1]);
% % Set up figure properties:
% % Enlarge figure to full screen.
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% % Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% % Give a name to the title bar.
% set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
% numPoints = 500;
% % Create pattern of random points with y = 1 to 11 and x = 0 to 32
% x = floor(imageSizeX * rand(1, numPoints)) + 1;
% y = floor(imageSizeY * 0.9 * rand(1, numPoints) + 0.1 * imageSizeY) + 1;
% % Create an image of gray
% grayLevel = 64; % Whatever you want between 0 and 255.
% grayImage = grayLevel * ones(imageSizeY, imageSizeX, 'uint8');
% for k = 1 : numPoints
%   grayImage(y(k), x(k)) = 255;
% end
% subplot(2, 2, 1);
% imshow(grayImage);
% axis on;
% title('Original Points', 'FontSize', fontSize);
% % Now mask the image
% grayImage(circlePixels) = grayLevel;
% subplot(2, 2, 3);
% imshow(grayImage);
% axis on;
% title('Masked Points', 'FontSize', fontSize);






% Create the scene
%   This example uses a random set of pixels to create a TrueColor image
scene = rand(100,100,3);
% Create the object image
%   This example uses a blend of colors from left to right, converted to a TrueColor image
%   Use repmat to replicate the pattern in the matrix
%   Use the "jet" colormap to specify the color space
obj = ind2rgb(repmat(1:64,64,1),jet(64));
% Display the images created in subplots
hf2 = figure('units','normalized','position',[.2 .2 .6 .6]);
axi1 = subplot(2,3,1);
iscene = image(scene);
axis off
title('Scene')
axi2 = subplot(2,3,4);
iobj = image(obj);
axis off
title('Object image')
% Now replace pixels in the scene with the object image
result = scene;
%   Define where you want to place the object image in the scene
rowshift = 20;
colshift = 0;
%   Perform the actual indexing to replace the scene's pixels with the object
result((1:size(obj,1))+rowshift, (1:size(obj,2))+colshift, :) = obj;
%   Display the results
ax3 = subplot(2,3,[2:3, 5:6]);
iresult = image(result);
axis off
hold on
title(sprintf('Using indexing to overlay images:\nresult is one image object'))