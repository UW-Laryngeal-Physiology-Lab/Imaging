function [corners, numPts] = find_Points3(I, MinQuality, FilterSize, CornerType,roibox)

switch CornerType
    case 1
        corners = detectHarrisFeatures(I,'MinQuality',MinQuality,...
            'FilterSize', FilterSize,'ROI',roibox);
        
        numPts = length(corners); % number of points you wish to track
        corners = corners.selectStrongest(numPts); % selects the 'best' points
    case 2
        corners = detectMinEigenFeatures(I,'MinQuality',MinQuality,...
            'FilterSize', FilterSize, 'ROI',roibox);
        
        numPts = length(corners); % number of points you wish to track
        corners = corners.selectStrongest(numPts); % selects the 'best' points
    case 3
        corners = detectFASTFeatures(I,'MinQuality',MinQuality,...
            'MinContrast', FilterSize, 'ROI',roibox);
        
        numPts = length(corners); % number of points you wish to track
        corners = corners.selectStrongest(numPts); % selects the 'best' points        
    case 4
        corners = detectBRISKFeatures(I,'MinQuality',MinQuality,...
            'MinContrast', FilterSize, 'ROI',roibox);
        
        numPts = length(corners); % number of points you wish to track
        corners = corners.selectStrongest(numPts); % selects the 'best' points 
end
