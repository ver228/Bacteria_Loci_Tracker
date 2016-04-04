function dat = posible_peaks(Im, SET)
If = filter2(SET.gKernel,Im);
%GET BACKGROUND LEVELS
[bgMean , bgStd] = spatialMovAveBG(Im,size(If,1),size(If,2));

fImg = locmax2d(If,[3 3],1); %this function is not the best
%get background values corresponding to local maxima

indF = (fImg ~= 0);

if SET.isMask
    indF = indF & SET.MASKCELL;
end
bgMeanMax = bgMean(indF);
bgStdMax = bgStd(indF);

[localMaxPosY,localMaxPosX] = find(indF);
localMaxAmp = fImg(indF);

pValue = 1 - normcdf(localMaxAmp,bgMeanMax,bgStdMax);
keepMax = find(pValue < SET.alphaLocMax);

localMaxAmp = localMaxAmp(keepMax);
bgMeanMax = bgMeanMax(keepMax);
bgStdMax = bgStdMax(keepMax);
pValue = pValue(keepMax);
localMaxPosX = localMaxPosX(keepMax);
localMaxPosY = localMaxPosY(keepMax);

numLocalMax = length(keepMax);
%{
    %%
    figure, imshow(imageBuff(:,:,MEANCENTER),[]);
    hold on
    plot(localMaxPosX,localMaxPosY,'.')
    %%
%}

dat= struct('positionsx',localMaxPosX, 'positionsy',localMaxPosY, ...
    'max_int',localMaxAmp,'bkgd',bgMeanMax,'bgStd',bgStdMax,...
    'pValue',pValue, 'num',numLocalMax);