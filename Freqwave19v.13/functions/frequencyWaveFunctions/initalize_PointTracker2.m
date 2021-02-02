function [pointTrackerArray, initial_points, point_validity] = ... 
    initalize_PointTracker2(corners, I, NumPyramidLevels, MaxBidirectionalError, MaxIterations, BlockSize)

%I = rgb2gray(imread(images{1}));
% I = (imread(images{1}));


% pointTracker parameters
% NumPyramidLevels = 4;
% MaxBidirectionalError = 20;
% MaxIterations = 30;
% BlockSize = [15,15];

% % construct pointTracker object
% pointTracker = vision.PointTracker('NumPyramidLevels',NumPyramidLevels,...
%     'MaxBidirectionalError',MaxBidirectionalError, 'MaxIterations',...
%     MaxIterations,'BlockSize',BlockSize);
% 
% % initialize pointTracker object with detected points
% initial_points = corners.Location;
% initialize(pointTracker,initial_points,I);
% [initial_points,point_validity,scores] = step(pointTracker,I);
% setPoints(pointTracker, initial_points, point_validity);
% 


% PointTrackerArray ;
for i = 1:1:length(corners.Location)
    pointTrackerArray(i,1).pointTracker = vision.PointTracker('NumPyramidLevels',NumPyramidLevels,...
        'MaxBidirectionalError',MaxBidirectionalError, 'MaxIterations',...
        MaxIterations,'BlockSize',BlockSize);
    % initialize pointTracker object with detected points
    initial_points = corners.Location(i,:);
    initialize(pointTrackerArray(i,1).pointTracker,initial_points,I);
    [initial_points,point_validity,scores] = step(pointTrackerArray(i,1).pointTracker,I);
    setPoints(pointTrackerArray(i,1).pointTracker, initial_points, point_validity);
end
initial_points = corners.Location;

