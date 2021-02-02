function [sorted, meshPts] = organize_Points2(meshPts, valid_tracked, u, v)

% organize all points within each grid cell
meshPts = reshape(meshPts, v, u)';
end_points = valid_tracked;
sorted = cell(u-1,v-1);

no_point = zeros(size(end_points(1,:)));
for a=1:1:length(no_point)
    no_point(a) = nan;
end

for i=1:1:u-1
    for j=1:1:v-1
        
        meshBox = [meshPts{i,j}(1) meshPts{i,j}(2);...
            meshPts{i,j+1}(1) meshPts{i,j+1}(2);...
            meshPts{i+1,j}(1) meshPts{i+1,j}(2);...
            meshPts{i+1,j+1}(1) meshPts{i+1,j+1}(2)];
       
        boxPoints = [];
        for k=length(valid_tracked(:,1)):-1:1
           
            % top left corner and bottom right corner
            theta1_2 = calculate_Angle((meshBox(2,1)-meshBox(1,1)),(meshBox(2,2)-meshBox(1,2)));
            theta1_3 = calculate_Angle((meshBox(3,1)-meshBox(1,1)),(meshBox(3,2)-meshBox(1,2)));
            theta4_2 = calculate_Angle((meshBox(2,1)-meshBox(4,1)),(meshBox(2,2)-meshBox(4,2)));
            theta4_3 = calculate_Angle((meshBox(3,1)-meshBox(4,1)),(meshBox(3,2)-meshBox(4,2)));
           
            theta1 = calculate_Angle((end_points(k,1)-meshBox(1,1)),(end_points(k,2)-meshBox(1,2)));
            theta4 = calculate_Angle((end_points(k,1)-meshBox(4,1)),(end_points(k,2)-meshBox(4,2)));

           % top Left corner and bottom right corner
            theta1_4 = calculate_Angle((meshBox(4,1)-meshBox(1,1)),(meshBox(4,2)-meshBox(1,2)));
            theta4_1 = calculate_Angle((meshBox(1,1)-meshBox(4,1)),(meshBox(1,2)-meshBox(4,2)));
                    
            if (isequaln(theta1_2, NaN))
                theta1_2 = theta1_4;
            elseif (isequaln(theta1_3, NaN))
                theta1_3 = theta1_4;
            elseif (isequaln(theta4_2, NaN))
                theta4_2 = theta4_1;
            elseif (isequaln(theta4_3, NaN))
                theta4_3 = theta4_1;
            end
    
            if (theta1_2 <= theta1_3) 
                % in between max and min of point 1
                between1 = 1;        
            else
                between1 = 0;
            end
            
            if (theta4_2 >= theta4_3)
                % in between max and min of point 1
                between4 = 1;
            else
                between4 = 0;
            end
           
            % corners
            if ((end_points(k,1) == meshBox(1,1) && end_points(k,2) == meshBox(1,2))...
                    | (end_points(k,1) == meshBox(2,1) && end_points(k,2) == meshBox(2,2))...
                    | (end_points(k,1) == meshBox(3,1) && end_points(k,2) == meshBox(3,2))...
                    | (end_points(k,1) == meshBox(4,1) && end_points(k,2) == meshBox(4,2)))
                boxPoints = [boxPoints; end_points(k,:)];
            % theta check
            elseif (between1 == 1 && between4 == 1) 
                if ((theta1 >= min(theta1_2,theta1_3) && theta1 <= max(theta1_2,theta1_3))...
                        && (theta4 >= min(theta4_2,theta4_3) && theta4 <= max(theta4_2,theta4_3)))
                    boxPoints = [boxPoints; end_points(k,:)];
                end
            elseif (between1 == 1 && between4 == 0)
                if ((theta1 >= min(theta1_2,theta1_3) | theta1 <= max(theta1_2,theta1_3))...
                        && (theta4 <= min(theta4_2,theta4_3) && theta4 >= max(theta4_2,theta4_3)))
                    boxPoints = [boxPoints; end_points(k,:)];
                end
            elseif (between1 == 0 && between4 == 1)
                if ((theta1 <= min(theta1_2,theta1_3) | theta1 >= max(theta1_2,theta1_3))...
                        && (theta4 >= min(theta4_2,theta4_3) && theta4 <= max(theta4_2,theta4_3)))
                    boxPoints = [boxPoints; end_points(k,:)];
                end
            elseif (between1 == 0 && between4 == 0)
                if ((theta1 <= min(theta1_2,theta1_3) && theta1 >= max(theta1_2,theta1_3))...
                        && (theta4 <= min(theta4_2,theta4_3) && theta4 >= max(theta4_2,theta4_3)))
                    boxPoints = [boxPoints; end_points(k,:)];
                end
            end
        end
        
        if length(boxPoints(:,1)) <= 2
            boxPoints = no_point;
        end
        
        sorted{i,j} = boxPoints;
        
    end
end