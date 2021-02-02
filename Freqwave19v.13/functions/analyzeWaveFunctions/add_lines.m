function [X,Y] = add_lines(xi,yi)
% I = imrotate(imread(images{1}), rote);
% [h,w] = size(I);

glottis = max(xi)-min(xi);
perc = 0.10;
x = min(xi):perc*glottis:max(xi)
y = [sort(mean(yi):-perc*glottis:mean(yi)-3*perc*glottis,'ascend'), mean(yi)+perc*glottis:perc*glottis:mean(yi)+3*perc*glottis];
[X,Y] = meshgrid(x,y);
end

%{
points2 = [];
d=1;
for i=1:1:length(x)
    for j = 1:1:length(y)
        for k = length(points(1,:)):-2:1
            if points(index,k-1) >= x(i)-0.25*perc*glottis & points(index,k-1) <= x(i)+0.25*perc*glottis ...
                    & points(index,k) >= y(j)-0.25*perc*glottis & points(index,k) <= y(j)+0.25*perc*glottis
                points2(:,d:d+1) = points(:,k-1:k);
                d = d+2;
            else
%                 points(:,k-1:k) = [];
            end
        end
    end
    %}


%{
% I = imrotate(imread(images{index}), rote);
[h,w] = size(I);
salt=4:32:w;
a = ones(size(tracker));
for i=length(points(:,1)):-1:1
    for j = 1:1:length(salt)
        if points(i,1) >= salt(j)-2 & points(i,1) <= salt(j)+2
            %points(i,:) == [];
            a(i,1) = 0;
%             break
        end
    end
end

a = logical(a);
points = points(a,:);
tracker = tracker(a);
%}
