%% Candidate Number 244848

clc
clear all

filename = 'C:\Users\Joakim Torsvik\Downloads\MSc Data Science\Image Processing\Lab Project\images2\org_5.png';
mainFunction(filename)


%% Main function
function mainFunction(filename)
img = loadImage(filename);
circles = findCircles(img); % sub-function to find the circles in the image
while true
    a_img = correctImage(img, circles); % Warping the image so that it faces the right way
    color_matrix = findColors(a_img); % Finding the colors
    temp = unique(color_matrix);
    ii = [1, 1];
    if size(unique(temp)) == ii
        temp = randperm(length(circles));
        x = circles(:, 1);
        y = circles(:, 2);
        circles(:, 1) = x(temp);
        circles(:, 2) = y(temp);
    else
        break
    end
end
disp("COLOUR-MATRIX OF IMAGE:")
disp(color_matrix) % Color matrix
end

%% Sub-function to find the colors in the image
function s = findColors(img)
lab_img = rgb2lab(img); % Converting RGB colorspace to LAB
f = fspecial('average', 11); % Using mean-filter (f) to remove noise
lab_img = imfilter(lab_img, f);

c = [80 172 259 369]; % Coordinates (c) from where we find the colors

% Finding all 16 points 
color_points = zeros(16, 3);
count = 0;
for i = 1:4
    for j = 1:4
        count = count + 1;
        x = c(1, i);
        y = c(1, j);
        temp = lab_img(x:x + 56, y:y + 56, :);
        color_points(count, : ) = mean(reshape(temp, [], 3), 1);
    end
end

rgb_scale = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0]; % defining the colors in rgb
color_names = {'r', 'g', 'b', 'y'}; % r=red, g=green, b=blue, y=yellow
lab_scale = rgb2lab(rgb_scale); % converting the colors to lab

d = color_points - permute(lab_scale, [3 2 1]);
d = squeeze(sum(d.^2, 2));
[~, idx] = min(d, [], 2);
patchnames = color_names(idx);

s = strings(4);
count = 0;
for i = 1:4
    for j = 1:4
        count = count + 1;
        s(i, j) = patchnames(count);
    end
end
end


%% Correcting the image to a quadratic square

function [adjusted] = correctImage(img, c)
fixedPoint = [0 0; 0 length(img); length(img) 0; length(img) length(img);];
movingPoints = c;
r = imref2d(size(img));
tform = fitgeotrans(movingPoints, fixedPoint, 'projective');

adjusted = imwarp(img, tform, 'OutputView', r);
subplot(2, 2, 4)
imshow(adjusted)
title('Corrected')
end

%% Find Circles
function [c] = findCircles(img)
subplot(2, 2, 1)
imshow(img)
title('Input image')

grayscale = rgb2gray(img); % Set the image to grayscale
temp = grayscale < 0.09; % Increases intensity of dark points (circles) and and reduces other points
temp = imdilate(temp, ones(15)); 
temp = medfilt2(temp, [3 3]);
temp = imerode(temp, ones(15));
temp = medfilt2(temp, [3 3]);
bw_img = imdilate(temp, ones(15));

subplot(2, 2, 2)
imshow(bw_img)
title('Circles in image')

% Finding the Centroid, Major Axis, Minor Axis and the Orientation of the
% regions
rprops = regionprops(bw_img, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
subplot(2, 2, 3)
imshow(bw_img, 'InitialMagnification', 'fit')
title('Detected location of circles')

c = zeros(length(rprops), 2);
hold on
for i  = 1: length(rprops)
    minorAxis = rprops(i).MinorAxisLength/2;
    majorAxis = rprops(i).MajorAxisLength/2;
    xCentroid = rprops(i).Centroid(1);
    yCentroid = rprops(i).Centroid(2);
    c(i, 1) = xCentroid;
    c(i, 2) = yCentroid;

    % Hough transformation function
    theta = linspace(0, 2 * pi, 100);
    phi = deg2rad(-rprops(i).Orientation);
    x = xCentroid + majorAxis * cos(theta) * cos(phi) - minorAxis * sin(theta) * sin(phi);
    y = yCentroid + majorAxis * cos(theta) * sin(phi) - minorAxis * sin(theta) * cos(phi);
    plot(x, y, 'r', 'LineWidth', 2) % Plotting the circles
end
hold off
end

%% Importing the image and resizing it
function [img] = loadImage(filename)
img = imread(filename);
if isa(img, 'uint8')
    img = double(img) / 255; % Converts image into double
    img = imresize(img, [480 480]); % Fitting the images to the same size (480x480)
else
    error("Something is wrong");
end
end