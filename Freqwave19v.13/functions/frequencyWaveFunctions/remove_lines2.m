function [points] = remove_lines2(points,images,index,rote)
I = imread(images{index}); 
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

end