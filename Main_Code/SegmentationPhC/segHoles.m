function Ibb3 = segHoles(Ibb2)
MINPIXCELL = 50;

dat = regionprops(bwlabel(Ibb2,4),'BoundingBox', 'Image', 'Area', 'Solidity');
Ibb3 = zeros(size(Ibb2));
for nM = 1:numel(dat)
    imc = dat(nM).Image;
    if dat(nM).Area > MINPIXCELL*2 %&& dat(nM).Solidity<0.8
        [BB,~,NN] = bwboundaries(imc);
        if NN<numel(BB)
            NN_prev = 1;
            for nn = (NN+1):numel(BB)
                
                yy = BB{nn}(:,1);
                xx = BB{nn}(:,2);
                M = numel(xx);
                if M>9
                    dx = pdist(xx);
                    dy = pdist(yy);
                    rr = (dx.*dx+dy.*dy);
                    rr = stats_squareform(rr);
                    [val , vI] = max(rr); 
                    [~, co] = max(val);
                    indP = [vI(co), co];
                    xc1 = xx(indP)';
                    yc1 = yy(indP)';
                    indLine = [];
                    for ss = 1:numel(indP)
                        dx = xc1(ss)-BB{1}(:,2);
                        dy = yc1(ss)-BB{1}(:,1);
                        rr = (dx.*dx+dy.*dy);
                        [~,co] = min(rr);
                        
                        indLine = [indLine, ...
                            drawCutLine([yc1(ss) BB{1}(co,1)], ...
                            [xc1(ss) BB{1}(co,2)], size(imc))];
                    end
                    
                   
                    if ~isempty(indLine) && ~any(isnan(indLine))
                        % assing to cut data to the final image
                        imc(indLine) = false;
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
                    
                else
                    ind = sub2ind(size(imc), yy,xx); % fill if it has small holes
                    imc(ind) = true;
                end
            end
        end
    end
    
    pix_II = floor(dat(nM).BoundingBox(1)+(1:dat(nM).BoundingBox(3)));
    pix_JJ = floor(dat(nM).BoundingBox(2)+(1:dat(nM).BoundingBox(4)));
    
    dum = Ibb3(pix_JJ,pix_II);
    Ibb3(pix_JJ,pix_II)= dum | imc;
end

