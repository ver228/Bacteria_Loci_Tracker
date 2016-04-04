function shapeData = segCorrection(Iph, L, checkOut)
MAXOUTLIER = 20;

if nargin==2
    checkOut = true;
end
if ~isa(Iph,'double')
    Iph = double(Iph);
end


props = regionprops(L, 'Centroid', 'MinorAxisLength', ...
    'MajorAxisLength','Orientation', 'Solidity', 'Area');

%figure, imshow(Iph,[]), hold on, dumI = nan(1,TOT);

TOT = numel(props);

shapeData = struct('Area', zeros(1,TOT), 'MinorAxis', zeros(1,TOT), ...
    'MajorAxis', zeros(1,TOT), 'Angle', ...
    zeros(1,TOT), 'CM', zeros(2,TOT));


badInd = false(1,TOT);
dumI = nan(1,TOT);
for kk = 1:TOT
    AA = [props(kk).MajorAxisLength, props(kk).MinorAxisLength, ...
        props(kk).Orientation, props(kk).Centroid(1), ...
        props(kk).Centroid(2)];
    %get image limit
    [XX YY] = bacteriaShape2(AA);
    bot = floor(min(XX)); if bot<1, bot = 1; end
    top = ceil(max(XX)); if top>size(Iph,2), top = size(Iph,2); end
    JJ = bot:top;
    
    bot = floor(min(YY)); if bot<1, bot = 1; end
    top = ceil(max(YY)); if top>size(Iph,1), top = size(Iph,1); end
    II = bot:top;
    
    % get data inside the polygon
    dI = repmat(II',size(JJ));
    dJ = repmat(JJ',size(II))';
    %ii = sub2ind(size(Iph),dI(:),dJ(:));
    IN = inpolygon(dJ,dI, XX,YY);
    indI = sub2ind(size(Iph), dI(IN), dJ(IN))';
    
    %rotated coordinates
    rot = [cosd(AA(3)), -sind(AA(3)); sind(AA(3)) cosd(AA(3))];
    
    posR = rot*[dJ(IN)';dI(IN)'];
    dJR = posR(1,:)- mean(posR(1,:));
    dIR = posR(2,:)- mean(posR(2,:));
    
    %get smoothed intensity
    dat = Iph(indI);
    medI = median(dat);
    MADI = median(abs(dat-medI));
    intLim = (medI+3*MADI);
    
    MinorAxis = segCorrection_helper(dIR, dat, props(kk).MinorAxisLength, intLim);
    MajorAxis = segCorrection_helper(dJR, dat, props(kk).MajorAxisLength, intLim);
    
    
    shapeData.MajorAxis(kk) = MajorAxis;
    shapeData.MinorAxis(kk) = MinorAxis;
    shapeData.CM(:,kk) = props(kk).Centroid;
    shapeData.Angle(kk) = props(kk).Orientation;
    r2 = MinorAxis/2;
    shapeData.Area(kk) = MajorAxis*r2+2*pi*r2^2;
    shapeData.AreaPix(kk) = props(kk).Area;
    
    if  checkOut
        if shapeData.AreaPix(kk)/shapeData.Area(kk) > 0.5 && shapeData.Area(kk)~=0
            AA = [MajorAxis, MinorAxis, props(kk).Orientation, ...
                props(kk).Centroid(1), props(kk).Centroid(2)];
            [XX YY] = bacteriaShape2(AA);
            
            bot = floor(min(XX)); if bot<1, bot = 1; end
            top = ceil(max(XX)); if top>size(Iph,2), top = size(Iph,2); end
            JJ = bot:top;
            
            bot = floor(min(YY)); if bot<1, bot = 1; end
            top = ceil(max(YY)); if top>size(Iph,1), top = size(Iph,1); end
            II = bot:top;
            
            % get data inside the polygon
            dI = repmat(II',size(JJ));
            dJ = repmat(JJ',size(II))';
            %ii = sub2ind(size(Iph),dI(:),dJ(:));
            IN = inpolygon(dJ,dI, XX,YY);
            indI = sub2ind(size(Iph), dI(IN), dJ(IN))';
            dumI(kk) = sum(Iph(indI)>intLim);
            
            if dumI(kk) >MAXOUTLIER
                badInd(kk) = true;
                
            end
        else
            badInd(kk) = true;
        end
    end
end
%%
dumStr = fieldnames(shapeData);
for kk = 1:numel(dumStr)
    shapeData.(dumStr{kk})(:,badInd) = [];
end
shapeData.TOT = TOT-sum(badInd);