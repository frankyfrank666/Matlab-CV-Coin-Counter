% Define the filter size used later
filtsize = 85;

% Creating test image 'im' by splicing together two built in images.
% zero pad all edges with half the filter size to make room for filters on coins near edges

% bright nickels and dimes on a dark background
im1 = imread('coins.png');
% dark quarters on a bright background, so we invert it (255 - col) 
im2 = imread('eight.tif');

% Use the load below if you can't find the two images in matlab
% load im1.mat
% load im2.mat

[r,c] = size(im1);
[r2,c2] = size(im2);

filtsizeh = floor(filtsize/2);
im = zeros(r+r2+filtsize,c+filtsize);
im(filtsizeh+1:filtsizeh+r+r2,filtsizeh+1:filtsizeh+c) = [im1; 255-im2(:,1:c)];
[r,c] = size(im);

% Display Grayscale orig Img
imagesc(im);
colormap(gray);
title('test image');
axis equal;


msk=[]; % Ostu mask
[msk,~] = OtsuThreshold(im);
figure; imagesc(msk); colormap(gray); title('Otsu'); axis equal;

msk_dil=[]; % Dialated mask (+8)
msk_dil = imdilate(msk,ones(8,8));
figure; imagesc(msk_dil); colormap(gray); title('Dilated'); axis equal;

msk_dil_erd=[];% Then erode mask (-19)
msk_dil_erd = imerode(msk_dil,ones(19,19));
figure; imagesc(msk_dil_erd); colormap(gray); title('Eroded'); axis equal;

% Find Centroids
component_size=[]; % num of components
component_size = bwconncomp(msk_dil_erd).NumObjects;

objs = regionprops(msk_dil_erd,"all");
centroid=[]; 
centroid = zeros(component_size,2);
for i = 1:1: component_size
    centroid(i,:) = round(objs(i).Centroid);
end

% disp centroids
hold on;
scatter(centroid(:,1),centroid(:,2));

%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%%%
function [msk,thrsh] = OtsuThreshold(img)
    % Define the Otsu threshold 'thrsh' using the histogram of img
%     imagesc(double(img));
%     colormap(gray);
    cnt = imhist(img);

    % Apply the threshold to 'img' to make 'msk'
    thrsh = otsuthresh(cnt);
    msk = img > thrsh*255;
    thrsh = thrsh * 255;
end

