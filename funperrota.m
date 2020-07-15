function rotacion = funperrota(i1, i2)
i3= imresize(i1,0.25);
i4= imresize(i2,0.25);


centroids3 = regionprops(i3);
[~,index] = sortrows([centroids3.Area].'); centroids3 = centroids3(index(end:-1:1)); clear index
bb3=centroids3(1).BoundingBox;
i3crop=imcrop(i3,[bb3(1)-20 bb3(2)-20 bb3(3)+50 bb3(4)+50]);
centroids3c = regionprops(i3crop);
c3=centroids3c(1).Centroid;
rotacion=struct;
ind=1;
for a=0:5:360
    B = imrotate(i4,a,'bicubic');
    
    centroids4 = regionprops(B);
    [~,index] = sortrows([centroids4.Area].'); centroids4 = centroids4(index(end:-1:1)); clear index
    bb4=centroids4(1).BoundingBox;
    i4crop=imcrop(B,[bb4(1)-20 bb4(2)-20 bb4(3)+50 bb4(4)+50]);
    centroids4c = regionprops(i4crop);
    [~,index] = sortrows([centroids4c.Area].'); centroids4c = centroids4c(index(end:-1:1)); clear index
    c4=centroids4c(1).Centroid;
    
    
    dispvector=c3-c4;
    
    Iout = imtranslate2(i4crop, dispvector,0,'linear',0);
    CC4=regionprops(Iout);
    [~,index] = sortrows([CC4.Area].'); CC4 = CC4(index(end:-1:1)); clear index
    bb4c=CC4(1).BoundingBox;
    i4crop2=imcrop(Iout,[bb4c(1)-20 bb4c(2)-20 bb4c(3)+50 bb4c(4)+50]);
   % C = imfuse(i3,i4crop2);figure;imshow(C)
    siz3=size(i3crop);
    siz4=size(i4crop2);
    diff=siz3-siz4;
    i3new=i3crop;
    i4new=i4crop2;
    % aquí titnes que incluir opcion de impar
    if diff(1)<0
        i3new= padarray(i3crop,[abs(floor(diff(1)/2)) 0],0);
    else
        i4new= padarray(i4crop2,[abs(floor(diff(1)/2)) 0],0);
    end
    if diff(2)<0
        i3new= padarray(i3new,[0 abs(floor(diff(2)/2))],0);
    else
        i4new= padarray(i4new,[0 abs(floor(diff(2)/2))],0);
    end
siz32=size(i3new);
siz42=size(i4new);

diff2=siz32-siz42;
if diff2(1)+diff2(2)>0
    if diff2(1)<0
        i3new= padarray(i3new,[abs(diff2(1)) 0],0,'pre');
    else
        i4new= padarray(i4new,[abs(diff2(1)) 0],0,'pre');
    end
    if diff2(2)<0
        i3new= padarray(i3new,[0 abs(diff2(2))],0,'pre');
    else
        i4new= padarray(i4new,[0 abs(diff2(2))],0,'pre');
    end    
end 
    
    
    % Compute correlation
    diff=corrcoef(double(i3new(:)),double(i4new(:)));
    diffc=diff(2,1);
    
    % Compute absolute differences
    diffo =imabsdiff(i3new,i4new);
    diffad=sum(diffo(:));
    


 %  
   rotacion(ind).i1= i1;
   rotacion(ind).i2= i2;
   rotacion(ind).i3= i3new;
   rotacion(ind).i4= i4new;
   rotacion(ind).angle= a;
   rotacion(ind).correlation= diffc;
   rotacion(ind).absdiff= diffad;
%  rotacion(ind).MI= diffmi;
ind=ind+1;
end
% figure;plot([rotacion.correlation])
% figure;plot([rotacion.absdiff])
end