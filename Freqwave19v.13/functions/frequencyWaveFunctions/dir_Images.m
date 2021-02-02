function [images, folder_name] = dir_Images(folder_name)

% folder_name = uigetdir;
% addpath(genpath(folder_name));

listing = dir(folder_name);

% remove imaginary folders that start with '.'
for k = length(listing):-1:1
    if strncmpi(listing(k).name,'.',1)
        listing(k)=[];
    elseif listing(k).isdir
        listing(k)=[];
    end
    
end

images = {listing.name};
for k = length(images):-1:1 
    images{k} = [listing(k).folder filesep listing(k).name];
end
images = sort_nat(images);

% [path, first_name, ext] = fileparts(images{1})
% 
% for k = length(images):-1:1 
%     images{k} = [path '\' images{k}]
% end
