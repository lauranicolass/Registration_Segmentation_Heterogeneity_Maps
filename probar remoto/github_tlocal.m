

% clear
clc,clear;close all
p = genpath('C:\Users\luis\Desktop\Laura\githhub'); % make this the folder where you stored the codes
addpath(p)
addpath(genpath(fullfile(pwd,'nonrigid_version23')))
mainf=uigetdir; %folder with results from T_align_tglobal 
%(example:
%...\example_images\lung-lobes_1\scale-10pc\Results15Jul2020_222247"
load(fullfile(mainf,'imagesregistrobueno.mat'));
foldersave=fullfile(mainf,'results_Tlocal');
mkdir(foldersave);
addpath(foldersave)




dataimages = struct('folder', {images(1:end).folder},'foldergname', {images(1:end).foldergname}, 'name', {images(1:end).name}, 'im_or', {images(1:end).im_or}, 'im_resized', {images(1:end).im_resized}, 'MOVINGREG_image', {images(1:end).MOVINGREG_image}, 'blob_registrated', {images(1:end).MOVINGREG_blob_registrated},'landmark_vector', {images(1:end).MOVINGREG_landmark_vector},'landmark_image', {images(1:end).MOVINGREG_landmark_image});
% foldersave=fullfile(folder,'resultado registro afinado');
% mkdir(foldersave);


spacing=[30 30]; 
% change this as it best fits the image. 
% Lungs work well with [30 30] with 10 pc size. 
% Gastric works well with [50 50] in 10 pc size

nummaxiters=100;
resizingsize=1; % this will make the code run faster but it will give a worse result. For maximum accuracy, keep it at 1

%% we first perform a new exhaustive segmentation to recover all the details from the images
for p=1:length(datatodos)
    p
  im=dataimages(p).MOVINGREG_image;
  [mask2] = hacer_masks_bonitas_para_solapamiento6_lobes(im);
  maskblunt=dataimages(p).blob_registrated;
  mask=maskblunt.*mask2;
  maskedRgbImage = bsxfun(@times, im, cast(mask,class(im)));
  mgrey=rgb2gray(maskedRgbImage);
    %% keep:
    dataimages(p).white_blob=mask;
    dataimages(p).image2=maskedRgbImage;
    dataimages(p).image2_grey=mgrey;
%     imwrite(mask, fullfile(foldersave,strcat(erase(datatodos(p).name,'.jpg'),'_whiteblobref.tif')));
end

%% and apply the approach B-spline Grid, Image and Point based Registration
%%version 1.33.0.0 (1.36 MB) by Dirk-Jan Kroon: 
%%https://es.mathworks.com/matlabcentral/fileexchange/20057-b-spline-grid-image-and-point-based-registration
for k=2:length(dataimages)
C=imfuse( dataimages(1).white_blob, dataimages(k).white_blob);
figure;imshow(C,[]);
title('before local registration reg');

% Add all function paths


%% Read two greyscale images 
ressize=resizingsize;

I1=im2double(imresize(dataimages(k).image2_grey,ressize));

I2=im2double(imresize(dataimages(1).image2_grey,ressize));


%% b-spline grid spacing in x and y direction
Spacing=spacing;

%% Type of registration error used see registration_error.m
type='ld';

%% Make the Initial b-spline registration grid
[O_trans]=make_init_grid(Spacing,size(I1));

%% Convert all values tot type double
I1=double(I1); I2=double(I2); O_trans=double(O_trans); 

%% Smooth both images for faster registration
I1s=imfilter(I1,fspecial('gaussian',[20 20],5));
I2s=imfilter(I2,fspecial('gaussian',[20 20],5));

%% Optimizer parameters
optim=optimset('Display','iter','MaxIter',nummaxiters);

%% Reshape O_trans from a matrix to a vector.
sizes=size(O_trans); O_trans=O_trans(:);

%% Start the b-spline nonrigid registration optimizer
O_trans = lsqnonlin(@(x)bspline_registration_image(x,sizes,Spacing,I1s,I2s,type),O_trans,[],[],optim);

%% Reshape O_trans from a vector to a matrix
O_trans=reshape(O_trans,sizes);

%% Transform the input image with the found optimal grid.
Icor=bspline_transform(O_trans,I1,Spacing); 

%% Make a (transformed) grid image
Igrid=make_grid_image(Spacing,size(I1));
Igrid=bspline_transform(O_trans,Igrid,Spacing); 

%% Show the registration results
figure,
subplot(2,2,1), imshow(I1); title('input image 1');
subplot(2,2,2), imshow(I2); title('input image 2');
subplot(2,2,3), imshow(Icor); title('transformed image 1');
subplot(2,2,4), imshow(Igrid); title('grid');

saveas(gcf, fullfile(foldersave,'the results.tif'));
save(fullfile(foldersave, 'thegrid.mat'), 'O_trans');
save(fullfile(foldersave, 'theimage.mat'), 'Icor');
save(fullfile(foldersave, 'thelandmarkimage.mat'), 'Iland');
save(fullfile(foldersave, 'thelandmarkvector.mat'), 'vectorc');

dataimages(k).thegridmat_local=O_trans;
dataimages(k).theimage_local=Icor;
dataimages(k).thelandmarkimage_local=Iland;
dataimages(k).thelandmarkvector_local=vectorc;
dataimages(k).thelandmarkvector_localmaxim=maximizevc;
dataimages(k).thedistance_local=meandist;
end

save(fullfile(foldersave,'resultsmatrix.mat'), 'datatodos1'); 