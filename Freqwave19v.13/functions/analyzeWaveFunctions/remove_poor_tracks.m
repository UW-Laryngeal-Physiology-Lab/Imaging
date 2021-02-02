function points = remove_poor_tracks(points)
[images,tot] = size(points);

for i=tot:-2:1
    if sum(isnan(points(:,i-1))) >= 0.7*images || sum(isnan(points(:,i))) >= 0.7* images
        points(:,i-1:i) = [];
    end
end
end
    