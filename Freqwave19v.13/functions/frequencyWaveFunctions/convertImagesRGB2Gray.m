function convertImagesRGB2Gray

folder_name = uigetdir;
addpath(genpath(folder_name));
[images, folder_name] = dir_Images(folder_name);
path = [folder_name filesep];

save_path = [path 'Gray pics' filesep];
save = mkdir(save_path);
%%
f = waitbar(0,'1','Name','Converting Images rgb2gray...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
set(f, 'Position', [1 1 275 75]);
movegui(f,'center');
setappdata(f,'canceling',0);
timeest = [];

for name=1:1:length(images(1,:))
    tic
    if getappdata(f,'canceling')
        break
    end
    guesstime = mean(timeest);
    estimatetime = guesstime*(length(images(1,:))-name);
    estMin = floor(estimatetime/60);
    estSec = mod(estimatetime,60);
    waitbar(name/length(images(1,:)),f,{'Please wait...',...
        ['Estimated time remaining: ',num2str(estMin), ' minutes, ', num2str(estSec), ' seconds']})
    img = imread(images{name});
    img = rgb2gray(img);
    imwrite(img,[save_path 'GrayPIC' num2str(name) '.png']);
    timeest = [timeest, toc];
end
disp('done');
delete(f);
end