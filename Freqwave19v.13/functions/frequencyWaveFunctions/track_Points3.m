function [all_tracked, point_validity] = track_Points3(pointTrackerArray, images, initial_points, startFrame, endFrame,rote)

f = waitbar(0,'1','Name','Tracking Points...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
set(f, 'Position', [1 1 275 75]);
movegui(f,'center');
setappdata(f,'canceling',0);

all_tracked = [];
nanList = [];
timeest = [];
offset = startFrame-1;
%offset = 0

for i = 1:1:length(pointTrackerArray)
    tic
    if getappdata(f,'canceling')
        break
    end
    guesstime = mean(timeest);
    estimatetime = guesstime*(length(pointTrackerArray)-i);
    estMin = floor(estimatetime/60);
    estSec = mod(estimatetime,60);
    waitbar(i/length(pointTrackerArray),f,{'Please wait...',...
        ['Estimated time remaining: ',num2str(estMin), ' minutes, ', num2str(estSec), ' seconds']})
    c = [];
    d = [];
    index = startFrame; % if index is set to 2 and offset is removed then can track all time points
    %index = 2;
    c(index-offset,:) = initial_points(i,:);
    d(index-offset,:) = 0;
    invalid_count = 1;
    index = index+1;
    while index<=(endFrame) % start at 2 because first image already read
        %I = rgb2gray(imread(images{i}));
        I = imrotate(imread(images{index}),rote);
        [points,point_validity,scores] = step(pointTrackerArray(i,1).pointTracker,I);
        
        if point_validity == 0;
            I = imrotate(imread(images{index-invalid_count}),rote);
            c(index-offset,:) = points;
            d(index-offset,:) = 1;
            last_valid = c((index-invalid_count)-offset,:);
%             trackerClone = clone(pointTrackerArray(i,1).pointTracker);
            release(pointTrackerArray(i,1).pointTracker);
            %pointTrackerArray(i,1).pointTracker = trackerClone;
            initialize(pointTrackerArray(i,1).pointTracker,last_valid,I);
            %c(index,:) = [nan nan]; % curve fit cannot have nan

            setPoints(pointTrackerArray(i,1).pointTracker, last_valid);
            index = index+1;
            invalid_count = invalid_count+1;
      
%             while point_validity == 0 & index<=endFrame
%                 I = (imread(images{index}));
%                 [points,point_validity,scores] = step(pointTrackerArray(i,1).pointTracker,I);
%                 c(index-offset,:) = points;
%                 setPoints(pointTrackerArray(i,1).pointTracker, last_valid);
%                 index = index+1;
%             end
        else
            c(index-offset,:) = points;
            d(index-offset,:) = 0;
            index = index+1;
        end
    end
    d = logical(d);
    for b=1:1:length(d)
        if d(b,1) == 1
            c(b,:) = [nan, nan];
        end
    end
    all_tracked = [all_tracked, c];
    %nanList = [nanList, d];
%     disp(num2str(i))
    timeest = [timeest, toc];
end
delete(f);
end


% all_tracked = []
% for i = 1:1:length(pointTrackerArray)
%     c = [];
%     c(1,:) = initial_points(i,:);
% 
%     for j=startFrame+1:1:endFrame % start at 2 because first image already read
%         %I = rgb2gray(imread(images{i}));
%         I = (imread(images{j}));
%         
%         [points,point_validity,scores] = step(pointTrackerArray(i,1).pointTracker,I);
%         c(j,:) = points;
%     end
%     all_tracked = [all_tracked, c];
%     disp(num2str(i))
% end



