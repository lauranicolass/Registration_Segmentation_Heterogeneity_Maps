function [mask2] = hacer_masks_bonitas_para_solapamiento6(im1)
hsvImage = rgb2hsv(im1); %get the hue saturation and value subimages
    vImage = hsvImage(:,:,3);
    vImage =adapthisteq(vImage);
    thresh = multithresh(vImage,9); %find the optimal treshold from the value image
    seg_I = imquantize(vImage,thresh(9));
    mask1=seg_I==1;
    B = imgaussfilt(double(mask1),2);
mask2 = imbinarize(B,'adaptive','Sensitivity',0.8);
    %mask2=B>0.015;
%   CC = bwconncomp(mask2);
%   numPixels = cellfun(@numel,CC.PixelIdxList); [~,idx] = max(numPixels);
%   emp=zeros(size(B));
%   emp(CC.PixelIdxList{idx}) = 1;
end


