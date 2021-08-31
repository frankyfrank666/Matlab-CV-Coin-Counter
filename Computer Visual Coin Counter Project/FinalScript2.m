% Define the filter size we will use in step 2:
filtsize = 85;

% Creating test image 'im' by splicing together two built in images.
% Also zero-padding (adding zeros around the border) with half the 
% filter size (filtsize) we will use so that the filter could be 
% centered on any actual image pixel, including those near the border.
% 'coins.png' contains bright nickels and dimes on a dark background
% 'eight.tif' contains dark quarters on a bright background, so we invert it
% to match 'coins.png'
im1 = imread('coins.png');
[r,c] = size(im1);
im2 = imread('eight.tif');
[r2,c2] = size(im2);
filtsizeh = floor(filtsize/2);
im = zeros(r+r2+filtsize,c+filtsize);
im(filtsizeh+1:filtsizeh+r+r2,filtsizeh+1:filtsizeh+c) = [im1;255-im2(:,1:c)];
[r,c] = size(im);
imagesc(im);colormap(gray);title('test image');axis equal;

% Initializing assessed/displayed variables as empty so that code is executable 
msk=[]; msk_dil=[]; msk_dil_erd=[]; centroid=[]; component_size=[]; 

%%%%% 1. Localize the centroid of each coin
% Otsu threshold
msk = OtsuThreshold(im);
figure; imagesc(msk); colormap(gray); title('Otsu'); axis equal;

% Dilate 9x9
msk_dil = imdilate(msk,ones(9,9));
figure; imagesc(msk_dil); colormap(gray); title('Dilated'); axis equal;

% Erode 23x23
msk_dil_erd = imerode(msk_dil,ones(23,23));
figure; imagesc(msk_dil_erd); colormap(gray); title('Eroded'); axis equal;


% Connected components to get centroids of coins:
cc = bwconncomp(msk_dil_erd);
props_struct = regionprops(cc);
centroid = zeros(length(props_struct),2);
component_size = zeros(length(props_struct),1);
for i=1:length(props_struct)
    centroid(i,:) = round(props_struct(i).Centroid);
    component_size(i) = props_struct(i).Area;
end


%%%%% 2. Measure features for each coin using a bank of matching filters
% make matching filters to create features
% Define diameters to use for filters
dimediameter = 31;
quarterdiameter = 51;
nickeldiameter = 41;

% Initialize assessed variables
D=[]; nickelfilter = []; dimefilter = []; quarterfilter = [];

% Use the MakeCircleMatchingFilter function to create matching filters for dimes, nickels, and quarters
% (This is in a separate Matlab grader problem. Save your work, 
%       complete the corresponding grader problem and embed the solution 
%       in the helper function list below.)
[dimefilter,xc,yc] = MakeCircleMatchingFilter(dimediameter,85);
[nickelfilter,x2c,y2c] = MakeCircleMatchingFilter(nickeldiameter,85);
[quarterfilter,x3c,y3c] = MakeCircleMatchingFilter(quarterdiameter,85);
figure;
subplot(1,3,1); imagesc(dimefilter); colormap(gray); title('dime filter'); axis tight equal;
subplot(1,3,2); imagesc(nickelfilter); colormap(gray); title('nickel filter'); axis tight equal;
subplot(1,3,3); imagesc(quarterfilter); colormap(gray); title('quarter filter'); axis tight equal;

% Evaluate each of the 3 matching filters on each coin to serve as 3 feature measurements 
D = zeros(size(centroid,1),3);

for i = 1:1:size(centroid,1)
    imx = centroid(i,1)
    imy = centroid(i,2)
     
    D(i,1) = corr(dimefilter(:),reshape(msk_dil_erd(imy + [(-yc+1):1:(yc-1)],imx + [(-xc+1):1:(xc-1)]),[length(dimefilter(:)),1]));
    D(i,2) = corr(nickelfilter(:),reshape(msk_dil_erd(imy + [(-y2c+1):1:(y2c-1)],imx + [(-x2c+1):1:(x2c-1)]),[length(nickelfilter(:)),1]));
    D(i,3) = corr(quarterfilter(:),reshape(msk_dil_erd(imy + [(-y3c+1):1:(y3c-1)],imx + [(-x3c+1):1:(x3c-1)]),[length(quarterfilter(:)),1]));
end

D

%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%%%
function [filter,xc,yc] = MakeCircleMatchingFilter(diameter,W)
% initialize filter
filter = zeros(W,W);
% define coordinates for the center of the WxW filter
xc = (W/2 +0.5);
yc = (W/2) +0.5;
% Use double-for loops to check if each pixel lies in the foreground of the circle
for i = 1:1:W
    for j = 1:1:W
        if sqrt((i-xc).^2 + (j-yc)^2) <= diameter/2
            filter(i,j) = 1;
        end
    end
end
end
function [msk,thrsh] = OtsuThreshold(im)
hst = imhist(im);
res = otsuthresh(hst);
thrsh = res*255;
msk = im>thrsh;
end
