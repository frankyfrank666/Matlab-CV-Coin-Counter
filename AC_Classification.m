%%%%% 3. Perform k-means clustering of features for unsupervised learning classifier
cc = bwconncomp(msk_dil_erd);

rng(0);
cls_init=[]; cls=[]; totcount=[];
cls_init = kmeans(D,3);
cls_init

% relabel centroid classes based on average size of the objects in each class.
% smallest will be dime, next nickel, and largest quarter
A=[];
B=[];
C=[];

for i = 1:1:length(cls_init)
    size = length(cc.PixelIdxList{i});
    if cls_init(i) == 1
        A = [A,size];
    elseif cls_init(i) == 2
        B = [B,size];
    else
        C = [B,size];
    end
end
A = mean(A);
B = mean(B);
C = mean(C);

[~,st] = sort([A B C]);

% 2 => 1
% 3 => 2
% 1 => 3

classmap(st(1)) = 1;
classmap(st(2)) = 2;
classmap(st(3)) = 3;

cls = cls_init;
for i = 1:1:length(cls_init)
    cls(i) = classmap(cls_init(i));
end
cls

% Visualize the result
figure; imagesc(im);colormap(gray);
hold on;axis equal;

totcount = 0;
for i = 1:1:length(cls)
    x  = centroid(i,1);
    y  = centroid(i,2);
    [coinvalue,x_plot,y_plot,col] = AddCoinToPlotAndCount(x,y,cls(i));
    totcount = totcount + coinvalue;
end
title([num2str(totcount),' cents'])
