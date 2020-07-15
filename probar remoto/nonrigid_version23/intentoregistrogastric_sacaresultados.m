clear;clc,close all
load('H:\laura tfm\dataset_medium desp\dataset_medium desp\gastric\gastric_5\scale-15pc\resultado registro blobs 2\datatodosregistrobueno.mat')
datatodos1 = struct('folder', {datatodos(1:end).folder},'foldergname', {datatodos(1:end).foldergname}, 'name', {datatodos(1:end).name}, 'im_or', {datatodos(1:end).im_or}, 'im_resized', {datatodos(1:end).im_resized}, 'MOVINGREG_image', {datatodos(1:end).MOVINGREG_image}, 'blob_registrated', {datatodos(1:end).MOVINGREG_blob_registrated},'landmark_vector', {datatodos(1:end).MOVINGREG_landmark_vector},'landmark_image', {datatodos(1:end).MOVINGREG_landmark_image});

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
%load stuff:
%grid:
load('H:\laura tfm\registro prueba bsplines\gridsd6.mat')
% rect:
load('H:\laura tfm\registro prueba bsplines\rect6.mat')

uiopen('H:\laura tfm\registro prueba bsplines\otros resultados 6.fig',1)

Spacing=[10 10];

I1or=im2double(datatodos1(2).image2_grey);

I2or=im2double(datatodos1(1).image2_grey);


I1=imcrop(I1or,rect2);
I2=imcrop(I2or,rect2);
Icor=bspline_transform(O_trans,I1,Spacing); 
figure;imshow(Icor);

%% prepare:
imor1=logical(I1);
imor2=logical(I2);
imnew1=logical(I2);
imnew2=logical(Icor);

%% dice:
diceor=dice(imor1, imor2);
dicenew=dice(imnew1, imnew2);

%% haus:
lmf=[];

[hausor, Dor]=NewHausdorffDist(imor1,imor2,lmf,'visualize');
[hausnew, Dnew]=NewHausdorffDist(imnew1,imnew2,lmf,'visualize');


A=imfuse(imnew1,imnew2);figure;imshow(A);title('new registration')
B=imfuse(imor1,imor2);figure;imshow(B);title('old registration')