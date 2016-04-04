function [Ibg,Ibb] = segBasicSeg(Iph)

Iph = double(Iph);
[robust_mean,~] = robustMean2(Iph(:));
thresh = robust_mean;
Id = Iph;
Id(Iph>thresh) = thresh;
        
hsobel = fspecial('sobel');
Ix=imfilter(Id,hsobel,'replicate');
Iy=imfilter(Id,hsobel','replicate');
Igrad=sqrt(Ix.^2+Iy.^2);
%Igrad=medfilt2(Igrad);
%figure, imshow(Igrad,[])
thresh = otsuThreshold(Igrad,1000);
Ibg = Igrad>thresh;

Ibg = bwmorph(Ibg,'close');
Ibg = imfill(Ibg, 'holes');
Ibg = bwareaopen(Ibg,50,4);

if nargout == 2
    hlog=fspecial('log',[7 7],5);
    Ilog = imfilter(Id,hlog,'replicate');
    Ibb = Ilog>0;
    Ibb(~Ibg) = 0;
    Ibb = ~bwareaopen(~Ibb,25,4);
end