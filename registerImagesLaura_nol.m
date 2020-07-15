function [MOVINGREG,tform,im2] = registerImagesLaura_nol(MOVING,FIXED,or_im)
%registerImages  Register grayscale images using auto-generated code from Registration Estimator app.
%  [MOVINGREG] = registerImages(MOVING,FIXED) Register grayscale images
%  MOVING and FIXED using auto-generated code from the Registration
%  Estimator app. The values for all registration parameters were set
%  interactively in the app and result in the registered image stored in the
%  structure array MOVINGREG.


%-----------------------------------------------------------
% Default spatial referencing objects

fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));
C=imfuse(MOVING,FIXED);
% figure;imshow(C,[]);title('before reg');
% Intensity-based registration
[optimizer, metric] = imregconfig('monomodal');
optimizer.GradientMagnitudeTolerance = 1.00000e-04;
optimizer.MinimumStepLength = 1.00000e-05;
optimizer.MaximumStepLength = 6.25000e-02;
optimizer.MaximumIterations = 100;
optimizer.RelaxationFactor = 0.800000;   



% Align centers
fixedCenterXWorld = mean(fixedRefObj.XWorldLimits);
fixedCenterYWorld = mean(fixedRefObj.YWorldLimits);
movingCenterXWorld = mean(movingRefObj.XWorldLimits);
movingCenterYWorld = mean(movingRefObj.YWorldLimits);
translationX = fixedCenterXWorld - movingCenterXWorld;
translationY = fixedCenterYWorld - movingCenterYWorld;

% Coarse alignment
initTform = affine2d();
initTform.T(3,1:2) = [translationX, translationY];

% Apply transformation
tform = imregtform(MOVING,movingRefObj,FIXED,fixedRefObj,'affine',optimizer,metric,'PyramidLevels',3,'InitialTransformation',initTform);
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', movingRefObj, 'SmoothEdges', true);
index=0;

D=imfuse(MOVINGREG.RegisteredImage,FIXED);
% figure;imshow(D,[]);title('after reg');



% Nonrigid registration
[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVINGREG.RegisteredImage,FIXED,100,'AccumulatedFieldSmoothing',1.0,'PyramidLevels',3);

% [MOVINGREG.Landmarks_im_final] = landvector2im(MOVINGREG.RegisteredImage,centroidsnon);
E=imfuse(MOVINGREG.RegisteredImage,FIXED);
% figure;imshow(E,[]);title('after reg nonrigid');


% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;


or_imr=or_im(:,:,1);
or_img=or_im(:,:,2);
or_imb=or_im(:,:,3);

or_imrr = imwarp(or_imr, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);
or_imrg = imwarp(or_img, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);
or_imrb = imwarp(or_imb, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);

or_imrr = imwarp(or_imrr,MOVINGREG.DisplacementField,'SmoothEdges', true);
or_imrg = imwarp(or_imrg ,MOVINGREG.DisplacementField,'SmoothEdges', true);
or_imrb = imwarp(or_imrb ,MOVINGREG.DisplacementField,'SmoothEdges', true);

im2(:,:,1)=or_imrr;
im2(:,:,2)=or_imrg;
im2(:,:,3)=or_imrb;
end