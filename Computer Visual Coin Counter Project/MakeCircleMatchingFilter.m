% Creates a matching filter of size W x W with a circle being 
% forground mask of diameter

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