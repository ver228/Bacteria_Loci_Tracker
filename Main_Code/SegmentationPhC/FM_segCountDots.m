function [shapeData, Idot] = FM_segCountDots(shapeData, DirOrImage, L, SET)

if ischar(DirOrImage) || iscell(DirOrImage)
    imList = getImList(DirOrImage);
    frame2av = 10;
    Idot = [];
    for kk = 1:frame2av
        I = double(imread(imList{kk}));
        if isempty(Idot)
            Idot = I;
        else
            Idot = Idot + I;
        end
    end
    Idot = Idot/frame2av;
else
    Idot = DirOrImage;
end
%%

IdotK = imfilter(Idot, SET.gKernel, 'replicate');
%%
bgMean = nan(size(IdotK));
bgStd = nan(size(IdotK));

Ls = imdilate(L,strel('disk', 2));
NN = max(L(:));
for nn = 1:NN
    inS = L==nn;
    in = Ls==nn;
    dat = Idot(inS);
    [locMean,locSTD] = robustMean2(dat);
    bgMean(in) = locMean;
    bgStd(in) = locSTD;
end

%%

fImg = locmax2d(IdotK,[3 3],1); %this function is maybe not the best
%get background values corresponding to local maxima
indF = (fImg ~= 0);

bgMeanMax = bgMean(indF);
bgStdMax = bgStd(indF);

[localMaxPosY,localMaxPosX] = find(indF);
localMaxAmp = fImg(indF);

pValue = 1 - stats_normcdf(localMaxAmp,bgMeanMax,bgStdMax);
keepMax = find(pValue < SET.alphaLocMax);

clear dat
dat.positionsx = localMaxPosX(keepMax);
dat.positionsy = localMaxPosY(keepMax);
numLocalMax = length(keepMax);

%{
figure
imshow(Idot,[]), hold on
plot(dat.positionsx, dat.positionsy, '.')
for kk = 1:numel(props)
    AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
            shapeData.Angle(kk), shapeData.CM(1,kk), shapeData.CM(2,kk)];
    %AA = [props(kk).MajorAxisLength, props(kk).MinorAxisLength, props(kk).Orientation,...
    %    props(kk).Centroid(1), props(kk).Centroid(2)];
    [XX YY] = bacteriaShape(AA, 1);
    plot(XX,YY)
end

figure, imshow(Ifm,[])
%}
%%
% look for local maxima inside the cell

shapeData.loci.X = cell(1, shapeData.TOT);
shapeData.loci.Y = cell(1, shapeData.TOT);
shapeData.loci.N = nan(1, shapeData.TOT);
shapeData.intensity.total = nan(1, shapeData.TOT);
shapeData.intensity.mean = nan(1, shapeData.TOT);
shapeData.intensity.median = nan(1, shapeData.TOT);

Lc = zeros(size(Idot)); %label with the contour coordinates
lociCount = zeros(1,numLocalMax);
for kk = 1:shapeData.TOT
    
    AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
        shapeData.Angle(kk), shapeData.CM(1,kk), ...
        shapeData.CM(2,kk)];
    [XX,YY] = bacteriaShape2(AA);
    in = inpolygon(dat.positionsx,dat.positionsy, XX,YY);
    shapeData.loci.X{kk} = dat.positionsx(in);
    shapeData.loci.Y{kk} = dat.positionsy(in);
    shapeData.loci.N(kk) = sum(in);
    lociCount(in) = lociCount(in) +1;
    
    bot = floor(min(XX)); if bot<1, bot = 1; end
    top = ceil(max(XX)); if top>size(Idot,2), top = size(Idot,2); end
    JJ = bot:top;
    
    bot = floor(min(YY)); if bot<1, bot = 1; end
    top = ceil(max(YY)); if top>size(Idot,1), top = size(Idot,1); end
    II = bot:top;
    
    dI = repmat(II',size(JJ));
    dJ = repmat(JJ',size(II))';
    %ii = sub2ind(size(Iph),dI(:),dJ(:));
    IN = inpolygon(dJ,dI, XX,YY);
    indI = sub2ind(size(Idot), dI(IN), dJ(IN))';
    shapeData.intensity.total(kk) = sum(Idot(indI));
    shapeData.intensity.mean(kk) = shapeData.intensity.total(kk)/numel(indI);
    shapeData.intensity.median(kk) = median(Idot(indI));
    
    YY = round(YY);
    XX = round(XX);
    in = XX>0&YY>0&XX<=size(Idot,2)&YY<=size(Idot,1);
    
    ii = sub2ind(size(Idot), YY(in), XX(in));
    Lc(ii) = kk;
    
end
%%

% count dots that are close to the polynomial but not inside
maskX = [-1 0 1;-1 0 1;-1 0 1];
maskY = maskX';

dumI = Lc;

for nn = 1:numLocalMax
    if lociCount(nn) == 0
        xx = round(dat.positionsx(nn))+maskX;
        yy = round(dat.positionsy(nn))+maskY;
        %out = xx<=0|xx>size(Idot,2)|yy<=0|yy>size(Idot,1);
        ind = sub2ind(size(Idot), yy, xx);
        
        dumI(ind) = 1;
        
        ii = Lc(ind(:));
        ii(ii==0) = [];
        ii = unique(ii);
        if ~isempty(ii)
            if numel(ii)>1
                ii = ii(round(rand*(numel(ii)-1))+1);
            end
            
            shapeData.loci.X{ii}(end+1) = dat.positionsx(nn);
            shapeData.loci.Y{ii}(end+1) = dat.positionsy(nn);
            shapeData.loci.N(ii) = shapeData.loci.N(ii)+1;
            lociCount(nn) = lociCount(nn) +1;
        end
    end
end

%{
figure,
imshow(Ip, [])

hold on
for kk = 1:shapeData.TOT
    if shapeData.AreaPix(kk)/shapeData.Area(kk)>0.5
        AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
            shapeData.Angle(kk), shapeData.CM(1,kk), ...
            shapeData.CM(2,kk)];
        [XX YY] = bacteriaShape2(AA);
        plot(XX,YY)
        
    end
end
in = lociCount ~= 0;
plot(dat.positionsx(in), dat.positionsy(in), '.r')
plot(dat.positionsx(~in), dat.positionsy(~in), '.b')
%}
