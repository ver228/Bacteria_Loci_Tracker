function Ibb4 = segAngle(Ibb3)
MINPIXCELL = 50;
DELTA_R = 3; %number of adjacent pixels used to calculated the angle
MASK_CROSS = [0 1 0 1 0 1 0 1 0]';

perim = bwperim(Ibb3);
for kk = 2:(size(perim,1)-1)
    for jj = 2:(size(perim,2)-1)
        dum = perim( kk-1:kk+1,jj-1:jj+1);
        if all(dum(:) == MASK_CROSS)
            Ibb3(kk,jj) = 0;
        end
    end 
end
dat = regionprops(bwlabel(Ibb3,4),'BoundingBox', 'Image', 'Area', 'Solidity');

%%

Ibb4 = zeros(size(Ibb3));
for nM = 1:numel(dat)
    imc = dat(nM).Image;
    %
    if dat(nM).Area > MINPIXCELL*2 && dat(nM).Solidity<0.8
        %%
        imp = bwperim(imc);
        [xx yy] = find(imp);
        oriPerimN = numel(xx);
        % sort contour
        xxS = zeros(size(xx));
        yyS = zeros(size(yy));
        R2 = zeros(size(xx));
        ii = 1;
        xxS(1) = xx(1);
        yyS(1) = yy(1);
        xx(1) = [];
        yy(1) = [];
        while ~isempty(xx)
            RR = sqrt((xx-xxS(ii)).^2+(yy-yyS(ii)).^2);
            [R2(ii),po] = min(RR);
            ii = ii+1;
            %if ea<3
            xxS(ii) = xx(po);
            yyS(ii) = yy(po);
            xx(po) = [];
            yy(po) = [];
            %{
            else
                xxS(ii:end) = [];
                yyS(ii:end) = [];
                break;
            end
            %}
        end
        R2(end) = sqrt((xxS(1)-xxS(end)).^2+(yyS(1)-yyS(end)).^2);
        
        ii = find(R2>3); %a discontinous segment is counted like that if there are more than 3 pixels between points
        if ~isempty(ii)
            NN = numel(ii);
            L = zeros(size(R2));
            ii(end+1) = numel(L)+ii(1);
            
            %get indexes for discontious segments
            for kk = 1:NN
                v = (ii(kk)+1):ii(kk+1);
                change = v>numel(L);
                v(change) = v(change) - numel(L);
                L(v) = kk;
            end
            
            if NN > 2
                %consider if there are three different discontinous
                %segments
                R = zeros(1,NN);
                for ll = 1:NN
                    in1 = L==ll;
                    x1 = xxS(in1);
                    y1 = yyS(in1);
                    R(ll) = mean(x1).^2+mean(y1).^2;
                end
                [~,dumI] = sort(R);
                L_old = L;
                for ll = 1:NN
                    in1 = L_old==dumI(ll);
                    L(in1) = ll;
                    %hold on, plot(xxS(in1), yyS(in1))
                end
            end
            
            
            %
            in1 = L==1;
            x1 = xxS(in1);
            y1 = yyS(in1);
            for nn = 2:NN
                
                in2 = L==nn;
                x2 = xxS(in2);
                y2 = yyS(in2);
                
                minR12 = zeros(size(x1));
                indR12 = zeros(size(x1));
                for mm = 1:numel(x1);
                    R2 = sqrt((x1(mm)-x2).^2+(y1(mm)-y2).^2);
                    [minR12(mm) indR12(mm)]= min(R2);
                    %maybe there is a problem if 2 points are at the same distance...
                end
                [~,po] = min(minR12);
                cutA(1) = po;
                cutA(2) = indR12(po);
                minR12(indR12==cutA(2)) = nan;
                
                [co,po] = min(minR12);
                if ~isnan(co)
                    cutB(1) = po;
                    cutB(2) = indR12(po);
                else
                    cutB(1) = cutA(1);
                    cutB(2) = cutA(2);
                end
                
                
                %open the chain and join
                if cutA(2)>cutB(2)
                    if cutA(2) ~= numel(x2)
                        vv2 =  [cutA(2):numel(x2) 1:cutB(2)];
                    else
                        vv2 = cutB(2):-1:cutA(2);
                    end
                else
                    vv2 = [cutA(2):-1:1 numel(x2):-1:cutB(2)];
                end
                if numel(vv2) == 2, vv2 = vv2'; end %stupid fix, i think its a bug in matlab
                
                if cutA(1)<cutB(1)
                    if cutB(1)~=numel(x1)
                        vv1 =  [cutB(1):numel(x1) 1:cutA(1)];
                    else
                        vv1 = cutB(1):-1:cutA(1);
                    end
                else
                    vv1 = [cutB(1):-1:1 numel(x1):-1:cutA(1)];
                end
                if numel(vv1) == 2, vv1 = vv1'; end %stupid fix, i think its a bug in matlab
                
                
                x1 = [x1(vv1); x2(vv2)];
                y1 = [y1(vv1); y2(vv2)];
            end
            xxS = x1;
            yyS = y1;
            %}
        end
        %{
        figure, hold on
        plot(xxS, yyS, '.-')
        plot(xx, yy, 'xr')
        %}
        
        %%
        if numel(xxS)/oriPerimN >0.75
            
            %calculate angle between pixels, small angles should be points
            %of division
            
            ang = nan(size(xxS));
            
            NN = numel(xxS);
            %vmA = nan(NN,2);
            for nn = 1:NN
                vR = nn+DELTA_R;
                if vR > NN
                    vR = vR-NN;
                end
                vL = nn-DELTA_R;
                if vL<=0
                    vL = vL + NN;
                end
                
                v1 = [xxS(vR)-xxS(nn);yyS(vR)-yyS(nn)];
                v2 = [xxS(vL)-xxS(nn);yyS(vL)-yyS(nn)];
                R1 = sqrt(sum(v1.*v1));
                R2 = sqrt(sum(v2.*v2));
                ang(nn) = real(acos(sum((v1/R1).*(v2/R2))));
                
                %calculate the vector orientation, if it is inside the
                %cell, give a negative angle, and use it as possible point
                %of division
                vm = (v1+v2)/2;
                Rm = sum(vm.*vm);
                vm = vm./Rm;
                RR = ceil(abs(vm));
                RR(vm<0) = -RR(vm<0);
                VM = ceil([xxS(nn);yyS(nn)]-RR);
                
                if all(VM>0) && VM(1)<size(imp,1) && ...
                        VM(2)<size(imp,2)
                    if imc(VM(1),VM(2))
                        ang(nn) = -ang(nn);
                        %vmA(nn,:) = vm;
                    end
                end
            end
            %%
            vAng = find(ang<0&ang>-2); %angle must be negative (inside the cell), and angle must be smaller than 2rad
            
            % get groups of cut points that are connected
            lineL = zeros(size(vAng));
            dum = vAng;
            count = 0;
            for mm = 1:numel(lineL)
                if lineL(mm) == 0
                    count = count + 1;
                    lineL(mm) = count;
                end
                dum(mm) = nan;
                delR = vAng(mm) - dum;
                in = abs(delR)<=1;
                lineL(in) = lineL(mm);
            end
            %%
            
            
            % use only the point in the group with the smallest angle (largest netaive
            % angle)
            uLL = unique(lineL);
            divPoints = nan(size(uLL));
            for mm = 1:numel(uLL)
                in = find(lineL == uLL(mm));
                [~,co] = max(ang(vAng(in)));
                divPoints(mm) = vAng(in(co));
            end
            %%
            %{
            figure,
            imshow(imc')
            hold on
            plot(xxS, yyS, '.-')
            plot(xxS(vAng), yyS(vAng), 'xr')
            plot(xxS(divPoints),yyS(divPoints), 'or')
            %plot(xxS(divPoints2),yyS(divPoints2), 'og')
            %}
            %%
            % get the oposite point, inorder to do the cut.
            flagUsed = false(size(divPoints));
            vv = -10:10;
            NN_prev = 1;
            
            for mm = 1:numel(divPoints)
                if ~flagUsed(mm)
                    indDiv = divPoints(mm);
                    flagUsed(mm) = true;
                    R = sqrt((xxS(indDiv)-xxS(divPoints)).^2+...
                        (yyS(indDiv)-yyS(divPoints)).^2);
                    R(flagUsed) = nan;
                    [minR maybe] = min(R);
                    indLine = [];
                    if minR<10 && minR~=0
                        indTT = [indDiv divPoints(maybe)];
                        indLine = drawCutLine(xxS(indTT), yyS(indTT), size(imc));
                        dum = imc(indLine);
                        if sum(dum)/numel(dum)>0.85
                            flagUsed(maybe) = true;
                        else
                            indLine = [];
                        end
                    end
                    
                    if isempty(indLine)
                        %do not include the points of the contour that are next to
                        %the division point
                        if numel(vv)/numel(xxS)<0.5
                            ii = indDiv + vv;
                            bad = ii<=0;
                            ii(bad) = numel(xxS) + ii(bad);
                            bad = ii>numel(xxS);
                            ii(bad) = ii(bad)-numel(xxS);
                            xxD = xxS;
                            yyD = yyS;
                            xxD(ii) = nan;
                            yyD(ii) = nan;
                            RR = (xxS(indDiv)-xxD).^2+(yyS(indDiv)-yyD).^2;
                            [~,po] = min(RR);
                            
                            indTT = [indDiv po];
                            indLine = drawCutLine(xxS(indTT), yyS(indTT), size(imc));
                        end
                    end
                    
                    if ~isempty(indLine) && ~any(isnan(indLine))
                        % assing to cut data to the final image
                        imc(indLine) = 0;
                        %make sure the figure is divided and the resulting division
                        %is larger than MINPIXCELL
                        cc = bwconncomp(imc,4);
                        NN = cellfun(@numel, cc.PixelIdxList);
                        if any(NN <= MINPIXCELL) || cc.NumObjects<= NN_prev
                            imc(indLine) = 1;
                        else
                            NN_prev = cc.NumObjects;
                        end
                    end
                    
                end
                %figure, imshow(imc)
            end
            %}
            
            
        end
    end
    %}
    pix_II = floor(dat(nM).BoundingBox(1)+(1:dat(nM).BoundingBox(3)));
    pix_JJ = floor(dat(nM).BoundingBox(2)+(1:dat(nM).BoundingBox(4)));
    %figure, imshow(imc)
    
    dum = Ibb4(pix_JJ,pix_II);
    Ibb4(pix_JJ,pix_II)= dum | imc;
end
%%
%figure,imshow(Ibb3)
%figure,imshow(Ibb4)