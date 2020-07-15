Spacing=[50 50];
nummaxiters=100;
ressize=0.6;

for p=1:length(images)
    p
  im=images(p).MOVINGREG_image;
  [mask2] = hacer_masks_bonitas_para_solapamiento6_lobes(im);
  maskgorda=images(p).MOVINGREG_blob_registrated;
  mask=maskgorda.*mask2;
  maskedRgbImage = bsxfun(@times, im, cast(mask,class(im)));
  mgrey=rgb2gray(maskedRgbImage);
    %% keep:
    images(p).white_blob=mask;
    images(p).image2=maskedRgbImage;
    images(p).image2_grey=mgrey;
%     imwrite(mask, fullfile(foldersave,strcat(erase(datatodos(p).name,'.jpg'),'_whiteblobref.tif')));
end

for k=2:length(images)
C=imfuse( images(1).white_blob, images(k).white_blob);
figure;imshow(C,[]);hold on;
scatter(images(1).MOVINGREG_landmark_vector(:,1),images(1).MOVINGREG_landmark_vector(:,2)); 
hold on;scatter(images(k).MOVINGREG_landmark_vector(:,1),images(k).MOVINGREG_landmark_vector(:,2));
title('before reg');
end

grid2=load('C:\Users\luis\Desktop\Laura\ANHIR\lunglobesgrandeslocall1\local\thegrid_2.mat');grid2=grid2.O_trans;
grid3=load('C:\Users\luis\Desktop\Laura\ANHIR\lunglobesgrandeslocall1\local\thegrid_3.mat');grid3=grid3.O_trans;
grid4=load('C:\Users\luis\Desktop\Laura\ANHIR\lunglobesgrandeslocall1\local\thegrid_4.mat');grid4=grid4.O_trans;

I2=im2double(imresize(images(2).image2_grey,ressize));
I3=im2double(imresize(images(3).image2_grey,ressize));
I4=im2double(imresize(images(4).image2_grey,ressize));

Ilocal2=bspline_transform(grid2,I2,Spacing); 
Ilocal3=bspline_transform(grid2,I3,Spacing); 
Ilocal4=bspline_transform(grid2,I4,Spacing); 


figure;
subplot(2,3,1); C=imfuse( images(1).white_blob, images(2).white_blob);imshow(C,[]);
subplot(2,3,2); C=imfuse( images(1).white_blob, images(3).white_blob);imshow(C,[]);
subplot(2,3,3); C=imfuse( images(1).white_blob, images(4).white_blob);imshow(C,[]);
subplot(2,3,4); C=imfuse( images(1).white_blob, Ilocal2);imshow(C,[]);
subplot(2,3,5); C=imfuse( images(1).white_blob, Ilocal3);imshow(C,[]);
subplot(2,3,6); C=imfuse( images(1).white_blob, Ilocal4);imshow(C,[]);




%% create maps:
RGB2=images(2).MOVINGREG_image;
RGB2_r=(imresize(RGB2(:,:,1),ressize));RGB2_rlocal=bspline_transform(grid2,RGB2_r,Spacing); 
RGB2_g=(imresize(RGB2(:,:,2),ressize));RGB2_glocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB2_b=(imresize(RGB2(:,:,3),ressize));RGB2_blocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB2_local(:,:,1)=RGB2_rlocal;RGB2_local(:,:,2)=RGB2_glocal;RGB2_local(:,:,3)=RGB2_blocal;

RGB3=images(3).MOVINGREG_image;
RGB2_r=(imresize(RGB3(:,:,1),ressize));RGB2_rlocal=bspline_transform(grid2,RGB2_r,Spacing); 
RGB2_g=(imresize(RGB3(:,:,2),ressize));RGB2_glocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB2_b=(imresize(RGB3(:,:,3),ressize));RGB2_blocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB3_local(:,:,1)=RGB2_rlocal;RGB2_local(:,:,2)=RGB2_glocal;RGB2_local(:,:,3)=RGB2_blocal;

RGB4=images(4).MOVINGREG_image;RGB4_local=zeros(size(RGB4));
RGB2_r=(imresize(RGB4(:,:,1),ressize));RGB2_rlocal=bspline_transform(grid2,RGB2_r,Spacing); 
RGB2_g=(imresize(RGB4(:,:,2),ressize));RGB2_glocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB2_b=(imresize(RGB4(:,:,3),ressize));RGB2_blocal=bspline_transform(grid2,RGB2_g,Spacing);
RGB4_local=zeros(size(RGB2_r,1),size(RGB2_r,2),3);
RGB4_local(:,:,1)=RGB2_rlocal;RGB2_local(:,:,2)=RGB2_glocal;RGB2_local(:,:,3)=RGB2_blocal;


im2(:,:,1)=RGB2_rlocal;
im2(:,:,2)=RGB2_glocal;
im2(:,:,3)=RGB2_blocal;