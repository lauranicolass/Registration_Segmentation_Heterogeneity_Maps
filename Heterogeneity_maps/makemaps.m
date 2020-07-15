%% code for making the heterogeneity maps:

clc,clear;close all
p = genpath('C:\Users\luis\Desktop\Laura\githhub'); % make this the folder where you stored the codes
addpath(p)
mainf=uigetdir; %folder with results from T_align_tglobal 
%(example:
%...\example_images\lung-lobes_1\scale-10pc\Results15Jul2020_222247"
load(fullfile(mainf,'imagesregistrobueno.mat'));


im=images(1).MOVINGREG_image;
[mask] = make_masks_for_solap(im);
maskedRgbImage = bsxfun(@times, im, cast(mask,class(im)));

[mask2gaus1,maskedbrownImageRGB1,maskbrown1]=funcion_segmentation(maskedRgbImage);
im2=images(2).MOVINGREG_image;
im3=images(3).MOVINGREG_image;
im4=images(4).MOVINGREG_image;


[mask2] = make_masks_for_solap(im2);
maskedRgbImage2 = bsxfun(@times, im2, cast(mask2,class(im2)));
[mask2gaus2,maskedbrownImageRGB2,maskbrown2]=funcion_segmentation(maskedRgbImage2);
[mask3] = make_masks_for_solap(im3);
maskedRgbImage3 = bsxfun(@times, im3, cast(mask3,class(im3)));
[mask2gaus3,maskedbrownImageRGB3,maskbrown3]=funcion_segmentation(maskedRgbImage3);
[mask4] = make_masks_for_solap(im4);
maskedRgbImage4 = bsxfun(@times, im4, cast(mask4,class(im4)));
[mask2gaus4,maskedbrownImageRGB4,maskbrown4]=funcion_segmentation(maskedRgbImage4);







figure;
subplot(2,4,1);imshow(im,[]);title('CD4')
subplot(2,4,2);imshow(im2,[]);title('CD68')
subplot(2,4,3);imshow(im3,[]);title('CD1A')
subplot(2,4,4);imshow(im4,[]);title('CD8')

subplot(2,4,5);imshow(bsxfun(@times, im, cast(mask2gaus1,class(im))),[]);title('CD4')
subplot(2,4,6);imshow(bsxfun(@times, im2, cast(mask2gaus2,class(im2))),[]);title('CD68')
subplot(2,4,7);imshow(bsxfun(@times, im3, cast(mask2gaus3,class(im3))),[]);title('CD1A')
subplot(2,4,8);imshow(bsxfun(@times, im4, cast(mask2gaus4,class(im4))),[]);title('CD8')




maskagaus1=imcomplement(mask2gaus1);
maskagaus2=imcomplement(mask2gaus2);
maskagaus3=imcomplement(mask2gaus3);
maskagaus5=imcomplement(mask2gaus5);
maskl=logical(mask+mask2+mask3+mask5);

mapsbig2a=(maskagaus1+maskagaus2.*3+maskagaus3.*5+maskagaus5.*7)+mask;

mapsbig2amasked=mapsbig2a.*maskl;
figure;imshow(mapsbig2a,[]);

figure;
subplot(1,5,1);imshow(mapsbig2a,[]);colormap(jet(17));
subplot(1,5,2);imshow(maskagaus1,[]);colormap(jet(17));title('CC10')
subplot(1,5,3);imshow(maskagaus2.*3,[]);colormap(jet(17));title('KI67')
subplot(1,5,4);imshow(maskagaus3.*5,[]);colormap(jet(17));title('CD31')
subplot(1,5,5);imshow(maskagaus5.*7,[]);colormap(jet(17));title('Pro-SPC')