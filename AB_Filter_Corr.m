% 2. Measure features for each coin using a bank of matching filters

% Define diameters to use for filters
nickeldiameter = 22;
dimediameter = 30;
quarterdiameter = 40;

D=[];
nickelfilter = [];
dimefilter = [];
quarterfilter =[];

[dimefilter,xc,yc] = MakeCircleMatchingFilter(dimediameter,85);
[nickelfilter,x2c,y2c] = MakeCircleMatchingFilter(nickeldiameter,85);
[quarterfilter,x3c,y3c] = MakeCircleMatchingFilter(quarterdiameter,85);
figure;
subplot(1,3,1); imagesc(dimefilter); colormap(gray); title('dime filter'); axis tight equal;
subplot(1,3,2); imagesc(nickelfilter); colormap(gray); title('nickel filter'); axis tight equal;
subplot(1,3,3); imagesc(quarterfilter); colormap(gray); title('quarter filter'); axis tight equal;

% Evaluate each of the 3 matching filters on each coin to serve as 3 feature measurements 
D = zeros(size(centroid,1),3);

% put each filter at center of each component, then cal the pair wise
% corrleation of 3 filters for each component

% Bad implementation (given)
% for i = 1:1:size(centroid,1)
%     imx = centroid(i,1);
%     imy = centroid(i,2);
%     
%     D(i,1) = corr(dimefilter(:),reshape(msk_dil_erd(imy + [(-yc+1):1:(yc-1)],imx + [(-xc+1):1:(xc-1)]),[length(dimefilter(:)),1]));
%     D(i,2) = corr(nickelfilter(:),reshape(msk_dil_erd(imy + [(-y2c+1):1:(y2c-1)],imx + [(-x2c+1):1:(x2c-1)]),[length(nickelfilter(:)),1]));
%     D(i,3) = corr(quarterfilter(:),reshape(msk_dil_erd(imy + [(-y3c+1):1:(y3c-1)],imx + [(-x3c+1):1:(x3c-1)]),[length(quarterfilter(:)),1]));
% end

% my implementation is better because it prevent
% large fit when large Filter overlaps two coins (ie 
% prevent making a small coin with very close neigbours look 
% bigger)
for i = 1:1:size(centroid,1)
    imx = centroid(i,1);
    imy = centroid(i,2);
    obj = objs(i);
    
    mask = zeros(size(msk_dil_erd));
    size(mask);
    tt = msk_dil_erd;
    rad = round((obj.EquivDiameter+6)/2);

    for j = imx-rad:1:imx+rad
        for k = imy-rad :1:imy+rad 
            rr =  sqrt((j-imx).^2 + (k-imy)^2);
            if rr <= rad+1
%                 rr <= rad+1 && rr >= rad-1
                mask(k,j) = 1;
            end
        end
    end
%     figure()
%     colormap(gray)
%     imagesc(tt)
    temp = mask .* msk_dil_erd;
    D(i,1) = corr(dimefilter(:),reshape(temp(imy + [(-yc+1):1:(yc-1)],imx + [(-xc+1):1:(xc-1)]),[length(dimefilter(:)),1]));
    D(i,2) = corr(nickelfilter(:),reshape(temp(imy + [(-y2c+1):1:(y2c-1)],imx + [(-x2c+1):1:(x2c-1)]),[length(nickelfilter(:)),1]));
    D(i,3) = corr(quarterfilter(:),reshape(temp(imy + [(-y3c+1):1:(y3c-1)],imx + [(-x3c+1):1:(x3c-1)]),[length(quarterfilter(:)),1]));
end

D

%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%%%
function [filter,xc,yc] = MakeCircleMatchingFilter(diameter,W)
    filter = zeros(W,W);
    % center of the WxW filter
    xc = W/2 +0.5;
    yc = W/2 +0.5;

    for i = 1:1:W
        for j = 1:1:W
            if sqrt((i-xc).^2 + (j-yc)^2) <= diameter/2
                filter(i,j) = 1;
            end
        end
    end
end
