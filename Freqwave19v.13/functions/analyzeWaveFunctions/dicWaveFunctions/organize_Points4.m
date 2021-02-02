function [sorted, meshPts] = organize_Points4(meshPts, data, u, v,Tes)

before = meshPts;
% organize all points within each grid cell
meshPts = reshape(meshPts, v, u)';
end_points = data;
sorted = cell(length(Tes),1); % size of triangles array Tes

no_point = zeros(size(end_points(:,1)));
for a=1:1:length(no_point)
    no_point(a) = nan;
end

a = [];
b = [];

for g=1:1:length(before(:,1))
    a = [a;before{g,1}(1,1)];
    b = [b;before{g,1}(1,2)];
end

aa = double(reshape(a,[v,u]));
bb = double(reshape(b,[v,u]));

all_x = aa(Tes);
all_y = bb(Tes);

Triangles = {};
for q = 1:1:length(all_x(:,1))
    Triangles{q,1} = [all_x(q,1), all_y(q,1)];
    Triangles{q,2} = [all_x(q,2), all_y(q,2)];
    Triangles{q,3} = [all_x(q,3), all_y(q,3)];
end

for i = 1:1:length(Triangles(:,1))
    meshTri = [Triangles{i,1}(1,1) Triangles{i,1}(1,2);...
        Triangles{i,2}(1,1) Triangles{i,2}(1,2);...
        Triangles{i,3}(1,1) Triangles{i,3}(1,2)];
    
    boxPoints = [];
    for k=length(data(1,:))-1:-2:1
        % top left corner and bottom right corner
        theta1_2 = calculate_Angle((meshTri(2,1)-meshTri(1,1)),(meshTri(2,2)-meshTri(1,2)));
        theta1_3 = calculate_Angle((meshTri(3,1)-meshTri(1,1)),(meshTri(3,2)-meshTri(1,2)));
        theta2_1 = calculate_Angle((meshTri(1,1)-meshTri(2,1)),(meshTri(1,2)-meshTri(2,2)));
        theta2_3 = calculate_Angle((meshTri(3,1)-meshTri(2,1)),(meshTri(3,2)-meshTri(2,2)));
        theta3_2 = calculate_Angle((meshTri(2,1)-meshTri(3,1)),(meshTri(2,2)-meshTri(3,2)));
        theta3_1 = calculate_Angle((meshTri(1,1)-meshTri(3,1)),(meshTri(1,2)-meshTri(3,2)));
        
        theta1 = calculate_Angle((end_points(1,k)-meshTri(1,1)),(end_points(1,k+1)-meshTri(1,2)));
        theta2 = calculate_Angle((end_points(1,k)-meshTri(2,1)),(end_points(1,k+1)-meshTri(2,2)));
        theta3 = calculate_Angle((end_points(1,k)-meshTri(3,1)),(end_points(1,k+1)-meshTri(3,2)));
        %theta4 = calculate_Angle((end_points(1,k)-meshBox(4,1)),(end_points(1,k+1)-meshBox(4,2)));
        
        if (theta1_2 <= theta1_3)
            % in between max and min of point 1
            between1 = 1;
        else
            between1 = 0;
        end
        
        if (theta2_1 <= theta2_3)
            % in between max and min of point 1
            between2 = 1;
        else
            between2 = 0;
        end
        
        if (theta3_1 <= theta3_2)
            % in between max and min of point 1
            between3 = 1;
        else
            between3 = 0;
        end
        
        % corners
        if ((end_points(1,k) == meshTri(1,1) && end_points(1,k+1) == meshTri(1,2))...
                | (end_points(1,k) == meshTri(2,1) && end_points(1,k+1) == meshTri(2,2))...
                | (end_points(1,k) == meshTri(3,1) && end_points(1,k+1) == meshTri(3,2)))
            boxPoints = [boxPoints, end_points(:,k), end_points(:,k+1)];
            % theta check
        elseif (between1 == 1 && between3 == 1)
            if ((theta1 >= min(theta1_2,theta1_3) && theta1 <= max(theta1_2,theta1_3))...
                    && (theta3 >= min(theta3_2,theta3_1) && theta3 <= max(theta3_2,theta3_1)))
                boxPoints = [boxPoints, end_points(:,k), end_points(:,k+1)]; %
            end
        elseif (between1 == 1 && between3 == 0)
            if ((theta1 >= min(theta1_2,theta1_3) | theta1 <= max(theta1_2,theta1_3))...
                    && (theta3 <= min(theta3_2,theta3_1) && theta3 >= max(theta3_2,theta3_1)))
                boxPoints = [boxPoints, end_points(:,k), end_points(:,k+1)]; %
            end
        elseif (between1 == 0 && between3 == 1)
            if ((theta1 <= min(theta1_2,theta1_3) | theta1 >= max(theta1_2,theta1_3))...
                    && (theta3 >= min(theta3_2,theta3_1) && theta3 <= max(theta3_2,theta3_1)))
                boxPoints = [boxPoints, end_points(:,k), end_points(:,k+1)]; %
            end
        elseif (between1 == 0 && between3 == 0)
            if ((theta1 <= min(theta1_2,theta1_3) && theta1 >= max(theta1_2,theta1_3))...
                    && (theta3 <= min(theta3_2,theta3_1) && theta3 >= max(theta3_2,theta3_1)))
                boxPoints = [boxPoints, end_points(:,k), end_points(:,k+1)]; %
            end
        end
    end
    
    if length(boxPoints(:,1)) <= 2
        boxPoints = no_point;
    end
    
    sorted{i,1} = boxPoints;
    
end
end
