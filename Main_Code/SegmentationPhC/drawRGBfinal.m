function rgbI = drawRGBfinal(I, shapeData, isPhC)

if isPhC
    [A B] = robustMean2(I(:));
    bot = A-B*6;
    if bot<0, bot = 0; end
    top = A+B*6;
    if top > 65535, top = 65535; end
else
    bot = min(I(:));
    top = max(I(:));
end
I8 = uint8((I-bot)/(top-bot)*255);


Lc = zeros(size(I8)); %label with the contour coordinates
for kk = 1:shapeData.TOT
        AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
            shapeData.Angle(kk), shapeData.CM(1,kk), ...
            shapeData.CM(2,kk)];
        [XX,YY] = bacteriaShape2(AA);
        
        YY = round(YY);
        XX = round(XX);
        in = XX>0&YY>0&XX<=size(I8,2)&YY<=size(I8,1); 
        
        ii = sub2ind(size(I8), YY(in), XX(in));
        Lc(ii) = kk;
end

Ld = false(size(I8));
if isfield(shapeData, 'loci')
    xx = [];
    yy = [];
    for kk = 1:numel(shapeData.loci.N)
        if shapeData.loci.N(kk) ~= 0
            xx = [xx;shapeData.loci.X{kk}(:)];
            yy = [yy;shapeData.loci.Y{kk}(:)];
        end
    end
    ii = sub2ind(size(I8), yy, xx);
    Ld(ii) = true;
    Ld = bwmorph(Ld, 'dilate');
end

rgbI = repmat(I8, [1,1,3]);

dum = I8;
dum(Lc~=0) = 0; dum(Ld~=0) = 255;
rgbI(:,:,1) = dum;
dum(Lc~=0) = 255; dum(Ld~=0) = 0;
rgbI(:,:,2) = dum;
dum(Lc~=0) = 0; dum(Ld~=0) = 0;
rgbI(:,:,3) = dum;

%{
[A B] = robustMean2(Idot(:));

bot = A+6*B;
top = max(Idot(:));
I8dot = uint8((Idot-bot)/(top-bot)*200);
figure, imshow(I8dot)
hold on
plot(xx,yy, '.')
%}