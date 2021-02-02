function [meshPts,Tes] = fit_Grid(images,meshPts, data, u, v)
%I = rgb2gray(imread(images{1}));
I = (imread(images{1}));

x = data(1,1:2:end).';
y = data(1,2:2:end).';

mag = [];
used_index = [];

for i=1:1:length(meshPts)
    for q = 1:1:length(x)
        mag(q,1) = sqrt((meshPts{i,1}(1)-x(q,1))^2 + (meshPts{i,1}(2)-y(q,1))^2);
    end
    [mini mag_index] = min(mag);
    used_index = [used_index; mag_index];
end

used_index;

grid_points = [];
other = cell(size(meshPts));

for i=1:1:length(used_index(:,1))
    %row = [x(used_index(i)),y(used_index(i)),z(used_index(i))];
    %row = [data(d,(used_index(i)*3)-2),data(d,(used_index(i)*3)-1),data(d,(used_index(i)*3)-0)]; % 1 corresponds to time
    row = [data(:,(used_index(i)*2)-1),data(:,(used_index(i)*2)-0)]; % 1 corresponds to time
    row2 = [data(1,(used_index(i)*2)-1),data(1,(used_index(i)*2)-0)]; % 1 corresponds to time
    meshPts{i} = row;
    other{i} = row2;
end

% plot the first grid
all = cell2mat(other(:,1));
a = double(all(:,1));
aa = double(reshape(a,[v,u]));
b = double(all(:,2));
bb = double(reshape(b,[v,u]));
zz = zeros(size(bb));

figure(8)
scatter(x,y); hold on;
set(gca, 'YDir','reverse'); hold on;
mesh(aa,bb,zz,'facecolor','none','marker','none','edgecolor','k'); hold off;

figure(9)
Tes = delaunay(aa,bb);
scatter(x,y); hold on;
set(gca, 'YDir','reverse'); hold on;
trisurf(Tes,aa,bb,zz,'Facecolor','interp','FaceAlpha',0.0,'EdgeColor','k'); hold off



% reform the grid based on grid_points

%{
for i=1:1:length(meshPts)
    meshPts{i} = grid_points(i,:);
end

x_fit = grid_points(:,1); % h and h+1 type of deal scan through all images
y_fit = grid_points(:,2);

x_fit = reshape(x_fit, v, u)';
y_fit = reshape(y_fit, v, u)';

figure; imshow(I); hold on;
plot(valid_tracked(:,1),valid_tracked(:,2),'r*','MarkerSize',5);hold on;
mesh(x_fit,y_fit, zeros(size(y_fit)),'facecolor','none','marker','none','edgecolor','w'); hold on;
%}
end