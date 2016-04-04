function Ibb5 = segInt(Ibb4, Iph)
%Segmentation using intensity...
MINPIXCELL = 100;
LIM_SOLIDITY = 0.5;
L = bwlabel(Ibb4,4);
props = regionprops(L, 'Centroid', 'MinorAxisLength', ...
    'MajorAxisLength','Orientation', 'Solidity');
Ibb5 = zeros(size(L));
for kk = 1:numel(props)
    if props(kk).Solidity > LIM_SOLIDITY
        AA = [props(kk).MajorAxisLength, props(kk).MinorAxisLength, ...
            props(kk).Orientation, props(kk).Centroid(1), ...
            props(kk).Centroid(2)];
        [XX YY] = bacteriaShape2(AA);
        bot = floor(min(XX)); if bot<1, bot = 1; end
        top = ceil(max(XX)); if top>size(Iph,2), top = size(Iph,2); end
        JJ = bot:top;
        
        bot = floor(min(YY)); if bot<1, bot = 1; end
        top = ceil(max(YY)); if top>size(Iph,1), top = size(Iph,1); end
        II = bot:top;
        
        dI = repmat(II',size(JJ));
        dJ = repmat(JJ',size(II))';
        %ii = sub2ind(size(Iph),dI(:),dJ(:));
        IN = inpolygon(dJ,dI, XX,YY);
        indI = sub2ind(size(Iph), dI(IN), dJ(IN))';
        
        rot = [cosd(AA(3)), -sind(AA(3)); sind(AA(3)) cosd(AA(3))];
        
        posR = rot*[dJ(IN)';dI(IN)'];
        dJR = posR(1,:)- mean(posR(1,:));
        %dIR = posR(2,:)- mean(posR(2,:));
        
        r2 = ceil(props(kk).MajorAxisLength/2);
        binR = -r2:r2;
        dat = Iph(indI);
        [meanData,~,~] = binsSmooth(dJR,dat, binR, 2);
        medI = median(dat);
        MADI = median(abs(dat-medI));
        
        
        imL = L(II,JJ);
        imL(imL~=kk) = 0;
        
        
        NN = numel(binR);
        mm2 = ceil(0.4*NN);
        limM = mm2:(NN-mm2);
        
        out = meanData.Y>(medI+2*MADI)|isnan(meanData.Y);
        %ii1 = find(~out,1)-1;
        %ii2 = find(~out, 1, 'last')+1;
        
        divP = find(out(limM));
        if ~isempty(divP)
            
            divP = divP + limM(1)-1;
            [~,ii] = max(meanData.Y(divP));
            dRR = binR(divP(ii));
            
            CMd = props(kk).Centroid-[JJ(1),II(1)]+1;
            ang = -props(kk).Orientation;
            
            divCM = CMd + [dRR*cosd(ang) dRR*sind(ang)];
            r2 = props(kk).MinorAxisLength/2;
            angR = ang+90;
            divX = divCM(1)+[r2*cosd(angR) -r2*cosd(angR)];
            divY = divCM(2)+[r2*sind(angR) -r2*sind(angR)];
            
            
            indLine  = drawCutLine(divY, divX, size(imL));
            backL = imL(indLine);
            imL(indLine) = false;
            
            %make sure the figure is divided and the resulting division
            %is larger than MINPIXCELL
            cc = bwconncomp(imL,4);
            NN = cellfun(@numel, cc.PixelIdxList);
            if numel(NN) ~= 2
                imL(indLine) = backL;
            else
                dd = NN(1)/NN(2);
                if any(NN<MINPIXCELL) || dd>1.5 || dd < 0.667
                    imL(indLine) = backL;
                end
            end
            
            %{
        lim1 = CMd + [binR(ii1)*cosd(ang) binR(ii1)*sind(ang)];
        lim2 = CMd + [binR(ii2)*cosd(ang) binR(ii2)*sind(ang)];
        
        figure,
        imshow(imc,[])
        hold on
        plot(XX-JJ(1)+1,YY-II(1)+1)
        plot(divX, divY, 'g')
        
        plot(divCM(1), divCM(2), 'xr')
        plot(lim1(1), lim1(2), 'xr')
        plot(lim2(1), lim2(2), 'xr')
        disp(kk)
            %}
            
        end
        
        dum = Ibb5(II,JJ);
        Ibb5(II,JJ)= dum | imL;
    end
end
%Ibb5(indLine) = 0;
%figure, imshow(Ibb4)
%figure, imshow(Ibb5)

