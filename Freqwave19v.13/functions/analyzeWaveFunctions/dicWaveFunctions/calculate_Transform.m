function [] = calculate_Transform(images, sorted, meshPts, u, v,count2,save)

% calculate geometric transform
switch count2
    case 1
        transform_type = 'xstrain-';
    case 2
        transform_type = 'ystrain-';
    case 3
        transform_type = 'xshear-';
    case 4
        transform_type = 'yshear-';
end


% affine transform pa
tform_vid = VideoWriter([save transform_type 'tform.avi'], 'Uncompressed AVI'); % uncompressed video file
tform_vid.FrameRate = 15;
open(tform_vid)

figure('units','normalized','outerposition',[0 0 1 1]);
colormap jet
k = 1;
fail = nan;

for h=1:2:length(images)*2 
    
    x_shear = [];
    y_shear = [];
    x_strain = [];
    y_strain = [];
    tform = [];
    center = [];
    meshCenter = [];

    %I = rgb2gray(imread(images{k}));
    I = (imread(images{k}));

    
    for i=1:1:u-1
        for j=1:1:v-1
            
            meshBox = [meshPts{i,j}(h) meshPts{i,j}(h+1);...
                meshPts{i,j+1}(h) meshPts{i,j+1}(h+1);...
                meshPts{i+1,j}(h) meshPts{i+1,j}(h+1);...
                meshPts{i+1,j+1}(h) meshPts{i+1,j+1}(h+1)];
            
            meshCenter = [meshCenter; [mean(meshBox(:,1)), mean(meshBox(:,2))]];
            
            xo = sorted{i,j}(:, 1);
            yo = sorted{i,j}(:, 2);
            
            xf = sorted{i,j}(:, h);
            yf = sorted{i,j}(:, h+1);
            
            %%%% transform between xo and xf here for each square
            
           fixedPoints = [xo,yo];
           movingPoints = [xf,yf];
           
           if length(xo)>=3
               t = estimateGeometricTransform(fixedPoints,movingPoints,'affine');
               x_shear = [x_shear;t.T(2,1)]; 
               y_shear = [y_shear;t.T(1,2)];
               x_strain = [x_strain;t.T(1,1)];%stretch ratio
               y_strain = [y_strain;t.T(2,2)];%stretch ratio
               tform = [tform;t];
           else 
               x_shear = [x_shear;fail];
               y_shear = [y_shear;fail];
               x_strain = [x_strain;fail];
               y_strain = [y_strain;fail];
           end        
        end
    end
    
    normalize = ones(size(x_shear));
    x_strain = (1/2).*(x_strain.^2-normalize); %green strain
    y_strain = (1/2).*(y_strain.^2-normalize);
    
    x_strain = x_strain + normalize;
    y_strain = y_strain + normalize;
    x_shear = x_shear + normalize;
    y_shear = y_shear + normalize;
    
    center_x = meshCenter(:,1);
    center_y = meshCenter(:,2);
    center_x = reshape(center_x, v-1,u-1).';
    center_y = reshape(center_y, v-1,u-1).';
    
    x_shear = reshape((x_shear), v-1,u-1).';
    y_shear = reshape((y_shear), v-1,u-1).';
    x_strain = reshape((x_strain), v-1,u-1).';
    y_strain = reshape((y_strain), v-1,u-1).';
    
    if count2 == 1
        imshow(cat(3, I, I, I)); hold on
        mesh(center_x,center_y,x_strain,'facecolor','interp','marker','none','edgecolor','interp'); hold off
        colorbar
        caxis([0.8,1.2]);
    elseif count2 == 2
        imshow(cat(3, I, I, I)); hold on
        mesh(center_x,center_y,y_strain,'facecolor','interp','marker','none','edgecolor','interp'); hold off
        colorbar
        caxis([0.8,1.2]);
    elseif count2 == 3
        imshow(cat(3, I, I, I)); hold on
        mesh(center_x,center_y,x_shear,'facecolor','interp','marker','none','edgecolor','interp'); hold off
        colorbar
        caxis([0.8,1.2]);
    elseif count2 == 4
        imshow(cat(3, I, I, I)); hold on
        mesh(center_x,center_y,y_shear,'facecolor','interp','marker','none','edgecolor','interp'); hold off
        colorbar
        caxis([0.8,1.2]);
    end
    
    k = k+1;
    writeVideo(tform_vid,getframe(gcf));
end
close(tform_vid);