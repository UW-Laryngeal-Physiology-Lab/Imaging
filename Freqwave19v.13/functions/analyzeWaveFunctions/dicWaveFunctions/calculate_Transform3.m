function [all_tform] = calculate_Transform3(images, sorted, meshPts, u, v,count2,save, Tes, meshPts2)
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
    case 5
        transform_type = 'equiv-';
end

% affine transform pa
tform_vid = VideoWriter([save transform_type 'tform.mp4'], 'MPEG-4'); % uncompressed video file
tform_vid.FrameRate = 15;
open(tform_vid)

figure('units','normalized','outerposition',[0 0 1 1]);
ylim([5 35]);
xlim([-95 -40]);
zlim([1035 1065]);
set(gca, 'XDir','reverse')
colormap jet
k = 1;
fail = nan;
all_tform = {};

unit_tform = estimateGeometricTransform([0,0;1,0;0,1;1,1],[0,0;1,0;0,1;1,1],'affine');

for h=1:1:(length(images))
    
    x_shear = [];
    y_shear = [];
    x_strain = [];
    y_strain = [];
    tform = [];
    center = [];
    meshCenter = [];

    %I = rgb2gray(imread(images{k}));
    I = (imread(images{k}));

    for i = 1:1:length(sorted(:,1))
        meshCenter = [meshCenter; [mean(sorted{i,1}(h,1:2:end)), mean(sorted{i,1}(h,2:2:end))]];
        
        xo = sorted{i,1}(1,1:2:end);
        yo = sorted{i,1}(1,2:2:end);
        
        xf = sorted{i,1}(h,1:2:end);
        yf = sorted{i,1}(h,2:2:end);
        
        %%%% transform between xo and xf here for each square
        
        fixedPoints = [xo.',yo.'];
        movingPoints = [xf.',yf.'];
        
        % remove NaN. They cannot be handled by geometric estimation
        bro = isnan(movingPoints);
        for c=length(bro):-1:1
            if bro(c) == 1
                movingPoints(c,:) = [];
                fixedPoints(c,:) = [];
            end
        end

        if length(fixedPoints) >=3 & length(movingPoints)>=3
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
            tform = [tform;unit_tform];% to fill void. maybe make this nan 
            disp('Transform Failed')
        end
    end
    
    all_tform{h,1} = tform;
    
    normalize = ones(size(x_shear));
    x_strain = (1/2).*(x_strain.^2-normalize); %green strain
    y_strain = (1/2).*(y_strain.^2-normalize);
    
    equivalent = sqrt((3/2.*(x_strain.^2+y_strain.^2))+(3/4.*(x_shear.^2+y_shear.^2)));

    center_x = meshCenter(:,1);
    center_y = meshCenter(:,2);
    %%%%
%     center_x = reshape(center_x, v-1,u-1).';
%     center_y = reshape(center_y, v-1,u-1).';
%     center_z = reshape(center_z, v-1,u-1).';
%     
%     x_shear = reshape((x_shear), v-1,u-1).';
%     y_shear = reshape((y_shear), v-1,u-1).';
%     x_strain = reshape((x_strain), v-1,u-1).';
%     y_strain = reshape((y_strain), v-1,u-1).';


a = [];
b = [];

for g=1:1:length(meshPts2(:,1))
    a = [a;meshPts2{g,1}(h,1)];
    b = [b;meshPts2{g,1}(h,2)];
end

aa = double(reshape(a,[v,u]));
bb = double(reshape(b,[v,u]));
zz = double(zeros(size(bb)));
cc = zz;



    if count2 == 1
        imshow(cat(3, I, I, I)); hold on
        %surf(center_x,center_y,center_z, x_strain,'facecolor','interp','marker','none','edgecolor','k');
        %scatter3(center_x,center_y,center_z); 
        s = trisurf(Tes,aa,bb,cc);
        colordata = x_strain;
        %colordata = imgaussfilt(colordata,2)
        s.CData = colordata;
%         s.EdgeColor = 'interp'
        s.FaceAlpha = 0.5
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
%         ylim([0 40]);
%         xlim([-120 -40]);
%         zlim([1020 1095]);
%         set(gca, 'XDir','reverse')
        colorbar
        hh = colorbar;
        set(get(hh,'title'),'string','x-normal strain');
        caxis([-0.2,0.2]);
        view(2)
    elseif count2 == 2
        imshow(cat(3, I, I, I)); hold on
        
%         surf(center_x,center_y,center_z, y_strain,'facecolor','interp','marker','none','edgecolor','k');
        s = trisurf(Tes,aa,bb,cc);
        s.CData = y_strain;
        s.FaceAlpha = 0.5
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
%         ylim([0 40]);
%         xlim([-120 -40]);
%         zlim([1020 1095]);
%         set(gca, 'XDir','reverse')
        colorbar
        hh = colorbar;
        set(get(hh,'title'),'string','y-normal strain');
        caxis([-0.2,0.2]);
        view(2)
    elseif count2 == 3
        imshow(cat(3, I, I, I)); hold on

        % surf(center_x,center_y,center_z, x_shear,'facecolor','interp','marker','none','edgecolor','k');
        s = trisurf(Tes,aa,bb,cc);
        s.CData = x_shear;
        s.FaceAlpha = 0.5
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
%         ylim([0 40]);
%         xlim([-120 -40]);
%         zlim([1020 1095]);
%         set(gca, 'XDir','reverse')
        colorbar
        hh = colorbar;
        set(get(hh,'title'),'string','x-shear strain');
        caxis([-0.2,0.2]);
        view(2)
    elseif count2 == 4
        imshow(cat(3, I, I, I)); hold on

        % surf(center_x,center_y,center_z, y_shear,'facecolor','interp','marker','none','edgecolor','k');
        s = trisurf(Tes,aa,bb,cc);
        s.CData = y_shear;    
        s.FaceAlpha = 0.5
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
%         ylim([0 40]);
%         xlim([-120 -40]);
%         zlim([1020 1095]);
%         set(gca, 'XDir','reverse')
        colorbar
        hh = colorbar;
        set(get(hh,'title'),'string','y-shear strain');
        caxis([-0.2,0.2]);
        view(2)
    elseif count2 == 5
        imshow(cat(3, I, I, I)); hold on

        % surf(center_x,center_y,center_z, y_shear,'facecolor','interp','marker','none','edgecolor','k');
        s = trisurf(Tes,aa,bb,cc);
        s.CData = equivalent; 
        s.FaceAlpha = 0.5
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
%         ylim([0 40]);
%         xlim([-120 -40]);
%         zlim([1020 1095]);
%         set(gca, 'XDir','reverse')
        colorbar
        hh = colorbar;
        set(get(hh,'title'),'string','equivalent strain');
        caxis([-0.2,0.2]);
        view(2)
    end
    
    k = k+1;
    writeVideo(tform_vid,getframe(gcf));
    
    if h==300 % saves file after 300 frames
        close(tform_vid);
        break
    end
    
end
close(tform_vid);
