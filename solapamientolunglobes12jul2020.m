%% global
clear;clc,close all;
load('C:\Users\luis\Desktop\Laura\ANHIR\lung-lobes_\completa_global_local.mat')


for i=1:5:length(completa_local)
    completa_local(i).folder
    im10=completa_local(i).MOVINGREG_image; im1= hacer_masks_bonitas_para_solapamiento6_lobes(im10);
    im20=completa_local(i+1).MOVINGREG_image;im2= hacer_masks_bonitas_para_solapamiento6_lobes(im20);
    im30=completa_local(i+2).MOVINGREG_image;im3= hacer_masks_bonitas_para_solapamiento6_lobes(im30);
    im40=completa_local(i+3).MOVINGREG_image;im4= hacer_masks_bonitas_para_solapamiento6_lobes(im40);
    im50=completa_local(i+4).MOVINGREG_image;im5= hacer_masks_bonitas_para_solapamiento6_lobes(im50);
    
    
    allim=(logical(im1)+logical(im2)+logical(im3)+logical(im4)+logical(im5)).*logical(im1);
    
    
    numtotal=size(allim,1)*size(allim,2);
    numzero=find(allim==0);
    numnonzero=numtotal-length(numzero);
    
    
    num1=find(allim==1); rationum1=length(num1)/numnonzero
    num2=find(allim==2);rationum2=length(num2)/numnonzero
    num3=find(allim==3);rationum3=length(num3)/numnonzero
    num4=find(allim==4);rationum4=length(num4)/numnonzero
    num5=find(allim==5);rationum5=length(num5)/numnonzero
   
end


%% local


clear;clc,close all
 load('C:\Users\luis\Desktop\Laura\ANHIR\lung-lobes_\data\lung-lobes_4\local_jul09-20200709T163631Z-001\local_jul09\resultsmatrix.mat')
i=1;
    datatodos1(i).folder
    im10=datatodos1(i).white_blob; im1= im10;
    im20=datatodos1(i+1).theimage_local;im2= (im20~=0);
    im30=datatodos1(i+2).theimage_local;im3= (im30~=0);
    im40=datatodos1(i+3).theimage_local;im4= (im40~=0);
    im50=datatodos1(i+4).theimage_local;im5= (im50~=0);
    
    
    allim=(logical(im1)+logical(im2)+logical(im3)+logical(im4)+logical(im5)).*logical(im1);
    
    
    numtotal=size(allim,1)*size(allim,2);
    numzero=find(allim==0);
    numnonzero=numtotal-length(numzero);
    
    
    num1=find(allim==1); rationum1=length(num1)/numnonzero
    num2=find(allim==2);rationum2=length(num2)/numnonzero
    num3=find(allim==3);rationum3=length(num3)/numnonzero
    num4=find(allim==4);rationum4=length(num4)/numnonzero
    num5=find(allim==5);rationum5=length(num5)/numnonzero
   


