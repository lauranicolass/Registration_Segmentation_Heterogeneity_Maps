function [newlv] = im2landvector(inim)
[newrow1,newcol1] = find(inim==1);
newlv=[newcol1,newrow1];
end