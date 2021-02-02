function [theta] = calculate_Angle(x, y)

if (x>0 && y>=0)
    theta = atan2(y,x);
elseif (x<0 && y>=0)
    theta = atan2(y,x);
elseif (x<0 && y<=0)
    theta = atan2(y,x)+2*pi;
elseif (x>0 && y<=0)
    theta = atan2(y,x)+2*pi;
elseif x==0 && y<0
    theta = pi*3/2;
elseif x==0 && y>0
    theta = pi/2;
elseif x==0 && y==0
    %theta = 0;
    theta = NaN;

end




