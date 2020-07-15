function [mask22,maskedbrownImage2,keeplowerredr]=funcion_segmentation(im)


im=uint8(im);
            [h w]=size(im);
            %% versión rápida
            
            lower_diagonal=triu(ones(h,w),-0);
            upper_diagonal=imcomplement(lower_diagonal);
            red=im(:,:,1);
            blue=im(:,:,3);
            %% UPPER
            
            [udx,udy]=find(upper_diagonal);
            ud=[udx,udy]-1;
            red1=double(reshape(red,1,[])');
            blue1=double(reshape(blue,1,[])');
            rb=[red1, blue1];
            [C] = intersect(rb,ud,'rows');
            indices = find(ismember(rb,C,'rows'));
            keepupperred=zeros(size(red1));
            keepupperred(indices)=1;
            keepupperredr=reshape(keepupperred,size(red));
            
            maskedpurpleImage2 = bsxfun(@times, im, cast(keepupperredr,class(im)));
            %% Lower
            keeplowerredr=imcomplement(keepupperredr);
            maskedbrownImage2 = bsxfun(@times, im, cast(keeplowerredr,class(im)));
            figure;subplot(1,3,1),imshow(im);subplot(1,3,2),imshow(maskedpurpleImage2);subplot(1,3,3),imshow(maskedbrownImage2);
            
            
    mask1=imgaussfilt(keepupperredr,15); 
%     imshow(keepupperredr);subplot(1,2,2);imshow(mask1);
    mask2=imgaussfilt(keeplowerredr,15);
%     imshow(keeplowerredr);subplot(1,2,2);imshow(mask2);
    mask11=mask1>0.4;%figure;imshow(mask11);
    mask22=mask2>0.6;%figure;imshow(mask22);
    
    %% quieres la mascara mask22 que es la marrón, con keep lower red
end