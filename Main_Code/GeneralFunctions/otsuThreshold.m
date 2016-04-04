function thresh=otsuThreshold(Im,N)
%Im = imBuff;
if nargin==1
    N=255;
end

%Im=Idum;
v=double(Im(:));
%bins=min(v):max(v);
bins=linspace(min(v),max(v),N);
yy=hist(v,bins);

bins=bins(end:-1:1);
yy=yy(end:-1:1);

N=numel(bins);

%varB=nan(1,N-1);
varW=nan(1,N-1);
totalPix=numel(v);

for p=1:(N-1)
    pixb=1:p;
    pixf=(p+1):N;
    
    nPixb=yy(pixb);
    nPixf=yy(pixf);
    
    Wb=sum(nPixb)/totalPix;
    Wf=sum(nPixf)/totalPix;
    
    totalPixb=sum(nPixb);
    mub=sum(nPixb.*pixb)./totalPixb;
    muf=sum(nPixf.*pixf)./(totalPix-totalPixb);
    
    sigb=sum((nPixb-mub).^2.*pixb)./totalPixb;
    sigf=sum((nPixf-muf).^2.*pixf)./(totalPix-totalPixb);
    
    %varB(p)=Wb*Wf*(mub-muf)^2;
    varW(p)=Wb*sigb+Wf*sigf;
end

[~,po]=min(varW);
thresh=bins(po);
%{
%imshow(Im>thresh)


f=@(x)((x-min(x))/(max(x)-min(x)));

figure, hold on
%plot(bins(1:end-1),f(varB))

%plot(bins,f(yy))

plot(bins(1:end-1),f(varW))
%}  
    
    