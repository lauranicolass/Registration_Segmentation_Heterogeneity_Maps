function [afclose] = make_masks_for_solap(im1)
hsvImage = rgb2hsv(im1); %get the hue saturation and value subimages
    vImage = hsvImage(:,:,3);

    thresh = multithresh(vImage,12); %find the optimal treshold from the value image
    seg_I = vImage<0.90;
    mask1=seg_I==1;
    
    
    B = imgaussfilt(double(mask1),3);
    aa=logical(B);
    se=strel('disk',10);
    afopening=imopen(aa,se);
    maskend=afopening.*mask1;
    se2=strel('disk',2);
    afclose=imclose(maskend,se2);

end