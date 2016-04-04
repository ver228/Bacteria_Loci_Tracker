function SNRStats = calculate_snr2_av(positionsx, positionsy, imList, SET)
TOT_FRAMES = size(positionsx,1);

npixels = SET.TOTALPIX+2; %size of the ROI
borders=(npixels+1)/2; %THE NUMBER OF BORDERS TO BE CALCULATED

buffer=nnz(positionsx);
total=0;
time=zeros(1,buffer);
part=zeros(1,buffer);
signalraw=zeros(1,buffer);
bg2=zeros(1,buffer); %square of the background signal
bg=zeros(1,buffer); %background signal


progressText(0,'Calculating SNR')
for frame = 1:TOT_FRAMES
    progressText(frame/TOT_FRAMES)
    
    nDat = (frame-1)*SET.integWindow+1;
    Im = double(imread(imList{nDat}));
    for kk = 2:SET.integWindow
        Im = Im + double(imread(imList{nDat-1+kk}));
    end
    
    %REMEMBER THE MATRIX positionsx HAVE AN OFFSET SEQ_RANGE(1) WITH THE
    %MOVIES NUMBER
    [t p posx] = find(positionsx(frame,:));
    t=t*frame; %time vector
    posy = nonzeros(positionsy(frame,:))';
    
    bad = isnan(posx);
    posx(bad) = -1;
    posy(bad) = -1;
    
    
    pos = round([posy;posx]);
    if isempty(pos)
        SNRStats = [];
       return
    end
    
    [roiind, outlim] = getroi2(pos,npixels,size(Im));
    
    npar=size(roiind,1);
    ints=zeros(npar,borders,'double');
    intn2=zeros(npar,borders,'double');
    for b=1:borders
        indb=getRoiBorder(b-1,npixels); %get the border region b-1
        roib=roiind(:,indb);
        
        ints(:,b)=sum(Im(roib),2); %get the sum of each square
        intn2(:,b)=sum(Im(roib).^2,2); % get the squre of each square
    end
    
    s=zeros(size(t));
    b2=s;
    b=s;
    
    s(~outlim)=(ints(:,1)+ints(:,2))/9; %mean intensity
    b2(~outlim)=intn2(:,end)/(borders*(npixels-1)); %mean background square
    b(~outlim)=ints(:,end)/(borders*(npixels-1)); %mean background
    
    s(outlim)=nan;
    b2(outlim)=nan;
    b(outlim)=nan;
    
    npar=numel(t);
    signalraw((1:npar)+total)=s; %mean intensity
    bg2((1:npar)+total)=b2;
    bg((1:npar)+total)=b;
    part((1:npar)+total)=p;
    time((1:npar)+total)=t;
    total=total+npar;
end

signal=nan(size(signalraw));
noise=signal;
sbr=signal;
for n=1:size(positionsx,2)
    good=(part==n);
    N=sum(good);
    Nout=sum(isnan(signalraw(good)));
    if Nout/N<=0.1
        SR=signalraw(good);
        B2=bg2(good);
        B=bg(good);
        
        signal(good)=SR-B;
        noise(good)=sqrt(B2-B.^2); %background std
        sbr(good)=SR./B;
    else
        signal(good)=nan;
        noise(good)=nan; %background std
        sbr(good)=nan;
    end
end

%{
%This quantities can be calculated from the signal, bgnd and noise(although
maybe "noise" is not a good definition any way.
SNR=signal./noise;
SNR=sparse(time,part,SNR); %SNR as signal level above the background over std in the border
SNR2 = signal./sqrt(signalraw);
SNR2 = sparse(time,part,SNR2);
SBR=sparse(time,part,sbr); %Signal to background ratio
%}
bgnd = sparse(time,part,bg); %background 3 
noise=sparse(time,part,noise); %std in the border
signal=sparse(time,part,signal); %Intensity in the center above above the background
SNRStats=struct('signal',signal,'noise',noise, 'bgnd', bgnd); %,'SNR2',SNR2,'SBR', SBR, 'SNR',SNR);
    
