clear;clc;close all
tic
mainf='C:\Users\luis\Desktop\Laura\ANHIR\lung-lobes_ - copia'; % copy directory of the dataset (sub-dataset)
filesm=dir(mainf);
filesm=filesm(3:length(filesm));%remove '.' and '..' directories
scaling_factor=0.25; 
%scaling factor for the images in case the code runs   
%slow or not enough memoty
for bio_folder=1:length(filesm)
    folder=fullfile(filesm(bio_folder).name,'scale-10pc'); %change this for the scale you want to use 
    %scale-10pc, scale-25pc, scale-50pc...
    currDate = strrep(datestr(datetime), ':', '_'); 
    currDate = strrep(currDate, '-', '_'); 
    foldersave=fullfile(filesm(bio_folder).folder,folder,strcat('Results_Barrido',currDate));
    mkdir(foldersave);
    % this creates a folder for saving the results with the date and hour
    % of the run
    images = dir(fullfile(filesm(bio_folder).folder,folder, '*.jpg'));
    
    %% creation of a curated dtrucutred with all the images and their landmarks:
    
    if isempty(images)
        images = dir(fullfile(folder, '*.png'));
        typesimages=erase({images(1:end).name},'.png');
    else
        typesimages=erase({images(1:end).name},'.jpg');
    end
    
    for im=1:length(images)
        fullFileName = fullfile(images(im).folder, images(im).name);
        im_original =(imread(fullFileName));
        images(im).or_image=im_original;
    end
    
    
    thelandmarks=dir(fullfile(filesm(bio_folder).folder,folder, '*.csv'));
    typeslandmarks=erase({thelandmarks(1:end).name},'.csv');
    
    [tf, idx] = ismember(typeslandmarks,typesimages);
    for i=1:length(idx)
        filecsv=readtable(fullfile(thelandmarks((i)).folder, thelandmarks((i)).name));
        images(idx(i)).landmarks=filecsv{:,2:3};
    end
    landmarks = {images.landmarks}.';
    nocsv=cellfun(@isempty,landmarks);
    newimagesnocsv=images(nocsv);
    images = images(~cellfun(@isempty,{images.landmarks}));
    images = [images; newimagesnocsv];
    
    
    
    % once we have the images ordered with respect to their landmark files, we
    %select the first image with landmark file as reference:
    
    orlandmark=images(1).landmarks;
    %% resizing of the images
    for p=1:length(images)
        
        %%scaling of the images
        im_original=images(p).or_image;
        [H,W]=size(im_original);
        
        im= imresize(im_original,scaling_factor);
        images(p).or_image_resized=im;
        
    end
    %% resizing of the landmark vectors
    for q=1:length(find(~cellfun(@isempty,{images.landmarks})))
        land=images(q).landmarks;
        images(q).or_landmark_resized= land.*scaling_factor;
    end
    %% rough segmentation of the images for the first part of the registration
    for p=1:length(images)
        
        hsvImage = rgb2hsv(images(p).or_image_resized); %get the hue saturation and value subimages
        vImage = hsvImage(:,:,3);
        thresh = multithresh(vImage,9); %find the optimal treshold from the value image
        seg_I = imquantize(vImage,thresh(8));
        mask=seg_I==1;  %get the actual mask
        se =strel('disk',5);
        dilatedI = imdilate(mask,se);
        % imshowpair(mask,dilatedI,'montage')
        BW2 = imfill(dilatedI,'holes');
        CC= bwconncomp(BW2);
        BW=zeros(size(BW2));
        numPixels = cellfun(@numel,CC.PixelIdxList); [biggest,idx] = max(numPixels); BW(CC.PixelIdxList{idx}) = 1;
        %figure;imshow(BW);
        binaryImage=BW;
        area0=sum(BW(:));
        [H1, W1]=size(BW);
        ratioarea= area0/(H1*W1);
        %% make sure segmentation is appropiate
        if ratioarea<0.15
            hsvImage = rgb2hsv(images(p).or_image_resized); %get the hue saturation and value subimages
            vImage = hsvImage(:,:,3);
            
            thresh = multithresh(vImage,9); %find the optimal treshold from the value image
            seg_I = imquantize(vImage,thresh(9));
            mask=seg_I==1;  %get the actual mask
            se =strel('disk',1);
            dilatedI = imdilate(mask,se);
%             imshowpair(mask,dilatedI,'montage')
            BW2 = imfill(dilatedI,'holes');
            CC= bwconncomp(BW2);
            BW=zeros(size(BW2));
            numPixels = cellfun(@numel,CC.PixelIdxList); [biggest,idx] = max(numPixels); BW(CC.PixelIdxList{idx}) = 1;
%             figure;imshow(BW);
            binaryImage=BW;
  
        end
  
        windowSize = 15;
        kernel = ones(windowSize) / windowSize ^ 2;
        blurryImage = conv2(single(binaryImage), kernel, 'same');
        binaryImage = blurryImage > 0.5; % Rethreshold
        %figure;imshow(binaryImage);
        BW3 = imfill(binaryImage,'holes');
        %figure;imshow(BW3);
        images(p).im_binary_mask=BW3;
    end
    
    or_image0=images(1).im_binary_mask;
    or_landmark0=images(1).or_landmark_resized;
    
    
    for p=2:length(find(~cellfun(@isempty,{images.landmarks})))
        %% distances
        otherlandmark=images(p).landmarks;
        [meand1]=funciondistanciaslandmarks(orlandmark,otherlandmark);
        images(p).landmark_distance_original=meand1;
        otherlandmark_res=images(p).or_landmark_resized;
        [meand2]=funciondistanciaslandmarks(or_landmark0,otherlandmark_res);
        images(p).landmark_distance_resized=meand2;
    end
    %% save segmented white blobs:
%     for p=1:length(images)
%         imwrite(images(p).im_binary_mask, fullfile(foldersave,strcat(erase(images(p).name,'.jpg'),'_whiteblob.tif')));
%     end
    %% un-comment for plots
    
%     figure;subplot(1,length(images),1);imshow(images(1).or_image_resized);hold on;scatter(images(1).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     for p=2:length(images)
%         subplot(1,length(images),p);imshow(images(p).or_image_resized);hold on;
%         if ~cellfun(@isempty,{images(p).landmarks})
%             scatter(images(p).or_landmark_resized(:,1),images(p).or_landmark_resized(:,2))
%         end
%     end
%     figure;subplot(1,length(images),1);imshow(images(1).im_binary_mask);hold on;scatter(images(1).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     for p=2:length(images)
%         subplot(1,length(images),p);imshow(images(p).im_binary_mask);hold on;
%         if ~cellfun(@isempty,{images(p).landmarks})
%             scatter(images(p).or_landmark_resized(:,1),images(p).or_landmark_resized(:,2))
%         end
%     end
%     
%     figure;
%     
%     subplot(2,2,1);imshow(images(1).or_image_resized);hold on;scatter(images(1).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     subplot(2,2,2);imshow(images(1).im_binary_mask);hold on;scatter(images(1).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     subplot(2,2,3);imshow(images(2).or_image_resized);hold on;scatter(images(2).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     subplot(2,2,4);imshow(images(2).im_binary_mask);hold on;scatter(images(2).or_landmark_resized(:,1),images(1).or_landmark_resized(:,2))
%     
    
    
    
    %% biopsy rotation
    im_original=or_image0;
    i1=images(1).or_image_resized;
    
    
    lv1=or_landmark0;
    for p=2:length(images)
        %% Find best rotation angle
        
        im2 =images(p).im_binary_mask;
        rotacion = funperrota(im_original, im2);
        correlation = [rotacion.correlation].';
        absdiff = [rotacion.absdiff].';
        [a,b]=max(correlation(:));
        angle(p)=rotacion(b).angle;
        
        %% rotate each image (mask and original) + landmarks
        i2=images(p).or_image_resized;
        if ~cellfun(@isempty,{images(p).landmarks})
            [i3new,i4new,i1new,i2new,dispvector,lv1new,lv2new,imblack1new,imblack2new] = rotation_l_octubre(im_original, im2,i1,i2,lv1,images(p).or_landmark_resized,rotacion(b).angle);
            [meand3]=funciondistanciaslandmarks(lv1new,lv2new);
            images(1).im_binary_mask_rotated=i3new;
            images(1).or_image_resized_rotated=i1new;
            images(p).or_image_resized_rotated=i2new;
            images(1).white_blob_rotated=i3new;
            images(p).white_blob_rotated=i4new;
            images(p).im_binary_mask_rotated=i2new;
            images(1).or_landmark_resized_rotated=lv1new;
            images(p).or_landmark_resized_rotated=lv2new;
            images(1).lv_im=imblack1new;
            images(p).lv_im=imblack2new;
            images(p).landmark_distance_rotated=meand3;
        else
            [i3new,i4new,i1new,i2new,dispvector] = rotation_nol_octubre(im_original, im2,i1,i2,rotacion(b).angle);
            images(1).im_binary_mask_rotated=i3new;
            images(1).or_image_resized_rotated=i1new;
            images(p).or_image_resized_rotated=i2new;
            images(1).white_blob_rotated=i3new;
            images(p).white_blob_rotated=i4new;
            images(p).im_binary_mask_rotated=i2new;
        end
        
%         imwrite(i4new, fullfile(foldersave,strcat(erase(images(p).name,'.jpg'),'_whiteblob_rotated.tif')));
%         imwrite(i2new, fullfile(foldersave,strcat(erase(images(p).name,'.jpg'),'_im_rotated.tif')));
    end
    
    
    close all;
    
    %% personalized global registration:
    FIXED=double(images(1).white_blob_rotated);
    lvim1=images(1).lv_im;
    
    %% barrido de parametros
    index=1;
    imagesstr=struct;
    for sgm=1.0e-5:8.0e-6:1.0e-4
        for smins=1.00000e-06:8.00000e-06:1.00000e-04
            for smaxs=0.001:0.001:0.01
                for srelax=0.1:0.1:0.9
                    sweep_GradientMagnitudeTolerance =sgm;
                    sweep_MinimumStepLength = smins;
                    sweep_MaximumStepLength = smaxs;
                    sweep_MaximumIterations = 100;
                    sweep_RelaxationFactor = srelax;
                    
                    for p=2:length(images)
                        MOVING=double(images(p).white_blob_rotated);
                        lvim2=images(p).lv_im;
                        or_im=images(p).or_image_resized_rotated;
                        
                        
                        if ~cellfun(@isempty,{images(p).landmarks})
                            [MOVINGREG,tform,im2] = registerImagesLaura_l_regularstep(MOVING,FIXED,or_im,lvim1,lvim2,sweep_GradientMagnitudeTolerance,sweep_MinimumStepLength,sweep_MaximumStepLength,sweep_RelaxationFactor);
                            images(p).MOVINGREG=MOVINGREG;
                            images(p).MOVINGREG_blob_registrated=logical(MOVINGREG.RegisteredImage);
                            images(p).MOVINGREG_image=im2;
                            images(p).MOVINGREG_landmark_vector=MOVINGREG.Landmarks_vector_final;
                            
                            orl=images(1).or_landmark_resized_rotated;
                            otherl=MOVINGREG.Landmarks_vector_final;
                            
                            [meand4]=funciondistanciaslandmarks(orl,otherl);
                            images(p).MOVINGREG_landmark_distance=meand4;
                            images(1).MOVINGREG_blob_registrated=FIXED;
                            images(1).MOVINGREG_image=images(1).or_image_resized_rotated;
                            images(1).MOVINGREG_landmark_vector=images(1).or_landmark_resized_rotated;
                            images(1).MOVINGREG_landmark_image=images(1).lv_im;
                            
                            
                            imagesstr(index).name=images(p).name;
                            imagesstr(index).ordist=images(p).landmark_distance_original;
                            imagesstr(index).dist=meand4;
                            imagesstr(index).sweep_GradientMagnitudeTolerance=sgm;
                            imagesstr(index).sweep_MinimumStepLength=smins;
                            imagesstr(index).sweep_MaximumStepLength=smaxs;
                            imagesstr(index).sweep_RelaxationFactor=srelax;
                        else
                            [MOVINGREG,tform,im2] = registerImagesLaura_nol_regularstep(MOVING,FIXED,or_im,sweep_GradientMagnitudeTolerance,sweep_MinimumStepLength,sweep_MaximumStepLength,sweep_RelaxationFactor);
                            images(p).MOVINGREG=MOVINGREG;
                            images(p).MOVINGREG_blob_registrated=logical(MOVINGREG.RegisteredImage);
                            images(p).MOVINGREG_image=im2;
                            images(1).MOVINGREG_blob_registrated=FIXED;
                            images(1).MOVINGREG_image=images(1).or_image_resized_rotated;
                            
                            imagesstr(index).name=images(p).name;
                            imagesstr(index).ordist=images(p).landmark_distance_original;
                            imagesstr(index).dist=meand4;
                            imagesstr(index).sweep_GradientMagnitudeTolerance=sgm;
                            imagesstr(index).sweep_MinimumStepLength=smins;
                            imagesstr(index).sweep_MaximumStepLength=smaxs;
                            imagesstr(index).sweep_RelaxationFactor=srelax;
                            
                        end
                       index=index+1; 
                    end
                end
            end
        end
    end

% figure;subplot(1,length(images),1);imshow(images(1).MOVINGREG_blob_registrated);hold on;scatter(images(1).MOVINGREG_landmark_vector(:,1),images(1).MOVINGREG_landmark_vector(:,2))
%     for p=2:length(images)
%         subplot(1,length(images),p);imshow(images(p).MOVINGREG_blob_registrated);hold on;
%         if ~cellfun(@isempty,{images(p).landmarks})
%             scatter(images(p).MOVINGREG_landmark_vector(:,1),images(p).MOVINGREG_landmark_vector(:,2))
%         end
%     end
%     
    
%     for p=1:length(images)
%         image=images(p).MOVINGREG_image;
%         baseFileName=strcat('rotated_registered_',images(p).name);
%         folder2=foldersave;
%         fullFileName = fullfile(folder2, baseFileName);
%         imwrite(image, fullFileName);
%     end
    
        save(fullfile(folder2, 'imagesregistrobueno_regularstep.mat'), 'images');  
        clearvars -except filesm bio_folder
end
toc
