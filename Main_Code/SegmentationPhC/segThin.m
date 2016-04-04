function Ibb2 = segThin(Ibb)
%Ibb = Ibb_bkp;
DIST2BRANCH = 5;
MINPIXCELL = 50;
%
Ibb2 = Ibb;
Ibb2 = bwmorph(Ibb2, 'majority');
for kk = 1:2
thin = bwmorph(Ibb2, 'thin', inf);
thin = bwmorph(thin, 'spur');
perim= bwperim(Ibb2);
out = thin&perim;
perim(out) = 0;
%out = imdilate(out, strel('disk', 1));
thin(out) = 0;
Ibb2(out) = 0;
end
%}

Ibb2 = bwmorph(Ibb2, 'hbreak');
Ibb2 = bwmorph(Ibb2, 'spur');
Ibb2 = bwmorph(Ibb2, 'clean');
%Ibb2 = bwmorph(Ibb2, 'majority');
%figure, imshow(Ibb)
%figure,imshow(Ibb2)


%[x y] = find(out);
%hold on, plot(y,x, '.')


%}
%%
dat = regionprops(Ibb2,'BoundingBox', 'Image', 'Area');
Ibb2 = zeros(size(Ibb2));
for nM = 1:numel(dat)
    imc = dat(nM).Image;
    %figure, imshow(imc)
    pix_II = floor(dat(nM).BoundingBox(1)+(1:dat(nM).BoundingBox(3)));
    pix_JJ = floor(dat(nM).BoundingBox(2)+(1:dat(nM).BoundingBox(4)));
    if dat(nM).Area > MINPIXCELL*2
        thinc = thin(pix_JJ,pix_II)&imc;
        perimc = perim(pix_JJ,pix_II)&imc;
        [xt yt] = find(thinc);
        [xp yp] = find(perimc);
        [XX YY] = find(imc);
        
        % get the number of neighbors in the thin line
        nNeighbour = zeros(size(xt));
        v = -1:1;
        for nn = 1:numel(xt)
            if xt(nn)>1 && yt(nn)>1 && ...
                    xt(nn)< dat(nM).BoundingBox(4) && yt(nn)< dat(nM).BoundingBox(3)
                dum = thinc(xt(nn)+v,yt(nn)+v);
                nNeighbour(nn) = sum(dum(:))-1;
            end
        end
        
        % get distance to from the thin line to the perimeter
        xp_dum = xp;
        yp_dum = yp;
        
        %{
        dist = zeros(size(xt));
        for nn = 1:numel(xt)
            delX = xt(nn) - xp_dum;
            delY = yt(nn) - yp_dum;
            R = sqrt(delX.*delX + delY.*delY);
            [dist(nn) ii] = min(R);
            R(ii) = nan;
            dist(nn) = dist(nn) + min(R);
        end
        narrow.in = find(dist<=2);%only use distance that are less or 1 from btw the perimeter and thin line
        %}
       %
        narrow.in = false(size(xt));
        for nn = 1:numel(xt)
            delX = xt(nn) - xp;
            delY = yt(nn) - yp;
            maybe = find(abs(delX)<=1&abs(delY)<=1);
            if numel(maybe>=2)
                NN = numel(maybe);
                dx = delX(maybe);
                dy = delY(maybe);
                distC = zeros(NN);
                for i = 1:NN
                    distC(i,:) = (dx(i)-dx).^2+(dy(i)-dy).^2;
                end
                distC = max(distC);
                
                if sum(distC>=2)>2
                    narrow.in(nn) = true;
                end
            end
        end
         %}   
        narrow.in = find(narrow.in);
        
        
        narrow.x = xt(narrow.in);
        narrow.y = yt(narrow.in);
        
        dum = narrow;
        lineL = zeros(size(narrow.x));
        count = 0;
        for kk = 1:numel(lineL)
            if lineL(kk) == 0
                count = count + 1;
                lineL(kk) = count;
            end
            delX = narrow.x(kk) - dum.x;
            delY = narrow.y(kk) - dum.y;
            R = sqrt(delX.*delX + delY.*delY);
            in = R<=2;
            lineL(in) = lineL(kk);
        end
        
        %
        %exclude from the analysis any data that is near end points (one
        %neighborg
        for kk = 1:numel(lineL)
            in = lineL == kk;
            nN = nNeighbour(narrow.in(in));
            if any(nN==1)
                lineL(in) = 0;
            end
        end
        %}
        
        %{
        %imshow(I(pix_JJ,pix_II),[])
        %imshow(I(pix_JJ,pix_II),[]), figure, imshow(imc)
        
        figure, hold on
        plot(xp,yp,'.y')
        plot(xt,yt,'.r')
        plot(narrow.x(lineL~=0),narrow.y(lineL~=0),'x')
        plot(xt(nNeighbour==1),yt(nNeighbour==1), 'or')
        plot(xt(nNeighbour>2),yt(nNeighbour>2), 'og')
        %plot(indL.x,indL.y,'.')
        axis equal
        %}
        
        %%
        vv = -2:2;
        indL.x = zeros(1,numel(vv)*count);
        indL.y = zeros(1,numel(vv)*count);
        
        in = nNeighbour>2;
        branchX = xt(in);
        branchY = yt(in);
        
        NN_prev = 1;
        for kk = 1:count
            in = lineL == kk;
            xxN = narrow.x(in);
            yyN = narrow.y(in);
            
            min2branch = Inf;
            min2branchI = Inf;
            
            for nn = 1:numel(xxN)
                R = sqrt((xxN(nn)-branchX).^2+(yyN(nn)-branchY).^2);
                [cc,~] = min(R);
                if min2branch>cc
                    min2branch = cc;
                    min2branchI = nn;
                end
            end
            
            if min2branch>DIST2BRANCH
                continue
            end
            %}
            xm = xxN(min2branchI);
            ym = yyN(min2branchI);
            
            if numel(xxN)<=2
                xxR = xt;
                yyR = yt;
                R = (xm-xxR).^2+(ym-yyR).^2;
                for pp = 1:3
                    [co po] = min(R);
                    xxN(end+1) = xxR(po);
                    yyN(end+1) = yyR(po);
                    R(po) = nan;
                end
            end
            MM = cov(xxN,yyN);
            if MM(1,2) ~= 0
                mm = MM(1,2)./MM(1,1);
                mm = -1/mm;
                if abs(mm)<=1
                    xx = vv + xm;
                    yy = mm*vv + ym;
                else
                    yy = vv + ym;
                    xx = vv/mm+xm;
                end
            else
                ii = find(diag(MM)==0);
                if numel(ii) > 2 || isempty(ii)
                    xx = [];
                    yy = [];
                elseif ii == 2
                    yy = vv + ym;
                    xx = ones(size(vv)) * xm;
                elseif ii == 1
                    xx = vv + xm;
                    yy = ones(size(vv)) * ym;
                end
            end
            xx = round(xx);
            yy = round(yy);
            out = xx<=0|yy<=0|xx>size(imc,1)|yy>size(imc,2);
            xx(out) = [];
            yy(out) = [];
            
            %{
            figure, hold on
            plot(xp,yp,'.y')
            plot(xt,yt,'.r')
            plot(xxN,yyN, 'x')
            plot(xm, ym, 'o')
            plot(xx, yy)
            axis equal
            %}
            %ii = (1:numel(vv))+(kk-1)*numel(vv);
            %indL.y(ii) = round(yy);
            %indL.x(ii) = round(xx);
            
            
            if ~isempty(xx)
                ii = sub2ind(size(imc), xx,yy);
                imc(ii) = 0;
                
                %make sure the figure is divided and the resulting division
                %is larger than MINPIXCELL
                cc = bwconncomp(imc,4);
                NN = cellfun(@numel, cc.PixelIdxList);
                if any(NN <= MINPIXCELL) || cc.NumObjects<= NN_prev 
                    imc(ii) = 1;
                else
                    NN_prev = cc.NumObjects;
                end
            end
            
            %}
        end
        
        %out = indL.x==0|indL.y==0|indL.x>size(imc,1)|indL.y>size(imc,2);
        %indL.x(out) = []; 
        %indL.y(out) = [];
        %figure, imshow(imc)
    end
    dum = Ibb2(pix_JJ,pix_II);
    Ibb2(pix_JJ,pix_II)= dum |  imc;
    
    %figure, imshow(I(pix_JJ,pix_II),[])
end
Ibb2 = bwmorph(Ibb2,'clean');
Ibb2 = bwmorph(Ibb2,'spur');
%figure, imshow(Ibb)
%figure, imshow(Ibb2)
