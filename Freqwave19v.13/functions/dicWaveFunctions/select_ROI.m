function [meshPts, u, v] = select_ROI(images, data)

%I = rgb2gray(imread(images{1}));
I = (imread(images{1}));


x = data(1,1:2:end).';
y = data(1,2:2:end).';

figure(7)
imshow(I); hold on
scatter(x,y); hold on;
set(gca, 'YDir','reverse')

% imshow(I); hold on;
% plot(valid_tracked(:,1),valid_tracked(:,2),'r*','MarkerSize',5);hold on;

hood = 30;

[xx,yy] = ginput(2);
[xx,yy] = meshgrid(min(xx(1),xx(2)):hood:max(xx(1),xx(2)), min(yy(1),yy(2)):hood:max(yy(1),yy(2)));

mesh(xx,yy,zeros(size(yy)),'facecolor','none','marker','none','edgecolor','k'); hold off;


% find coordinates of meshgrid
meshPts = {};
[u,v] = size(xx);
k = 1;
for i=1:1:u
    for j=1:1:v
        meshPts{k,1} = [xx(i,j), yy(i,j)];
        k = k +1;
    end
end
meshPts