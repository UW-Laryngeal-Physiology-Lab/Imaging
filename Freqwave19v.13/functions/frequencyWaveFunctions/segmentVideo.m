function segmentVideo

name = 1;
folder_name = uigetdir;
addpath(genpath(folder_name));
path = [folder_name filesep];
video = dir([path '*.avi']);
reader = VideoReader(video.name);
save_path = [path 'pics' filesep];
save = mkdir(save_path);

f = waitbar(0,'1','Name','Converting Video to Image Sequence...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
set(f, 'Position', [1 1 275 75]);
movegui(f,'center');
setappdata(f,'canceling',0);
timeest = [];

frames = reader.Duration*reader.FrameRate;
while hasFrame(reader) %&& name <= 200
    tic
    if getappdata(f,'canceling')
        break
    end
    guesstime = mean(timeest);
    estimatetime = guesstime*(frames-name);
    estMin = floor(estimatetime/60);
    estSec = mod(estimatetime,60);
    waitbar(name/frames,f,{'Please wait...',...
        ['Estimated time remaining: ',num2str(estMin), ' minutes, ', num2str(estSec), ' seconds']})
    img = readFrame(reader);
    %     img = rgb2gray(img);
    imwrite(img,[save_path 'PIC' num2str(name) '.png']);
    name = name+1;
    timeest = [timeest, toc];
    
end
disp('done');
delete(f);
end