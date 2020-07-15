% Example using lsqnonlin optimizer and registration error image 
% instead of value.

% clean
clear all; close all; clc;
load('H:\laura tfm\dataset_medium desp\dataset_medium desp\gastric\gastric_5\scale-15pc\resultado registro blobs 2\datatodosregistrobueno.mat')
datatodos1 = struct('folder', {datatodos(1:end).folder},'foldergname', {datatodos(1:end).foldergname}, 'name', {datatodos(1:end).name}, 'im_or', {datatodos(1:end).im_or}, 'im_resized', {datatodos(1:end).im_resized}, 'MOVINGREG_image', {datatodos(1:end).MOVINGREG_image}, 'blob_registrated', {datatodos(1:end).MOVINGREG_blob_registrated},'landmark_vector', {datatodos(1:end).MOVINGREG_landmark_vector},'landmark_image', {datatodos(1:end).MOVINGREG_landmark_image});
% foldersave=fullfile(folder,'resultado registro afinado');
% mkdir(foldersave);

for p=1:length(datatodos)
    p
  im=datatodos1(p).MOVINGREG_image;
  [mask2] = hacer_masks_bonitas_para_solapamiento(im);
  maskgorda=datatodos1(p).blob_registrated;
  mask=maskgorda.*mask2;
  maskedRgbImage = bsxfun(@times, im, cast(mask,class(im)));
  mgrey=rgb2gray(maskedRgbImage);
    %% keep:
    datatodos1(p).white_blob=mask;
    datatodos1(p).image2=maskedRgbImage;
    datatodos1(p).image2_grey=mgrey;
%     imwrite(mask, fullfile(foldersave,strcat(erase(datatodos(p).name,'.jpg'),'_whiteblobref.tif')));
end

C=imfuse( datatodos1(1).white_blob, datatodos1(2).white_blob);
figure;imshow(C,[]);hold on;
scatter(datatodos(1).MOVINGREG_landmark_vector(:,1),datatodos(1).MOVINGREG_landmark_vector(:,2)); hold on;scatter(datatodos(2).MOVINGREG_landmark_vector(:,1),datatodos(2).MOVINGREG_landmark_vector(:,2));title('before reg');

% Add all function paths
addpaths

%% Read two greyscale images of Lena
% I1=im2double(imresize(datatodos1(1).image2_grey,0.20));
% land1=datatodos(1).MOVINGREG_landmark_vector.*0.20;
% I2=im2double(imresize(datatodos1(2).image2_grey,0.20));
% land2=datatodos(2).MOVINGREG_landmark_vector.*0.20;
% [imblack2] = landvector2im(I2,land2);


I1or=im2double(datatodos1(2).image2_grey);
% land1=datatodos(2).MOVINGREG_landmark_vector;
I2or=im2double(datatodos1(1).image2_grey);
% land2=datatodos(1).MOVINGREG_landmark_vector;

load('H:\laura tfm\registro prueba bsplines\rect4.mat')
% [I2,rect2] = imcrop(I2or);
I2 = imcrop(I2or,rect2);
I1=imcrop(I1or,rect2);
% land1crop=imcrop(landvector2im(I1or,land1),rect2);
% [newlv1] = im2landvector(land1crop);
% land2crop=imcrop(landvector2im(I2or,land2),rect2);
% [newlv2] = im2landvector(land2crop);


%% b-spline grid spacing in x and y direction
Spacing=[10 10];

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
optim=optimset('Display','iter','MaxIter',40);

%% Reshape O_trans from a matrix to a vector.
sizes=size(O_trans); O_trans=O_trans(:);

%% Start the b-spline nonrigid registration optimizer
O_trans = lsqnonlin(@(x)bspline_registration_image(x,sizes,Spacing,I1s,I2s,type),O_trans,[],[],optim);

%% Reshape O_trans from a vector to a matrix
O_trans=reshape(O_trans,sizes);

%% Transform the input image with the found optimal grid.
Icor=bspline_transform(O_trans,I1,Spacing); 
% [Iland,T]=bspline_transform(O_trans,land1crop,Spacing,0);
% ilandb=logical(Iland);
% s = regionprops(ilandb,'Centroid');
% for i=1:length(s)
%     vectorc(i,:)=s(i).Centroid;
% end
% [meandist]=funciondistanciaslandmarks(newlv2,vectorc);
% vgrande=vectorc./0.20;
% lgrande=land1./0.20;
% [meandistgrande]=funciondistanciaslandmarks(vgrande,lgrande);
% figure;subplot(1,2,1);scatter(lgrande(:,1),lgrande(:,2));hold on;scatter(vgrande(:,1),vgrande(:,2));title('before non rigid');
% subplot(1,2,2);scatter(newlv2(:,1),newlv2(:,2));hold on;scatter(vectorc(:,1),vectorc(:,2));title('after non rigid');
%% Make a (transformed) grid image
Igrid=make_grid_image(Spacing,size(I1));
Igrid=bspline_transform(O_trans,Igrid,Spacing); 

%% Show the registration results
figure,
subplot(2,2,1), imshow(I1); title('input image 1');
subplot(2,2,2), imshow(I2); title('input image 2');
subplot(2,2,3), imshow(Icor); title('transformed image 1');
subplot(2,2,4), imshow(Igrid); title('grid');


% figure,
% subplot(2,2,1), imshow(I1);hold on;scatter(newlv1(:,1),newlv1(:,2));hold on  title('input image 1');
% subplot(2,2,2), imshow(I2);hold on;scatter(newlv2(:,1),newlv2(:,2));  title('input image 2');
% subplot(2,2,3), imshow(Icor); hold on;scatter(vectorc(:,1),vectorc(:,2));  title('transformed image 1');
% subplot(2,2,4), imshow(Igrid); title('grid');