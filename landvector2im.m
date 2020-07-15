function [outim] = landvector2im(imsi,lv)
row1 = floor(lv(:,2));
col1 = floor(lv(:,1));
z   = 1;
outim = zeros(size(imsi)); % 2D image of zeros.
idx = sub2ind(size(outim),row1,col1);
outim(idx) = z;
end