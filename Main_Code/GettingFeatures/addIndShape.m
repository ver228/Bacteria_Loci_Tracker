function indMSD = addIndShape(shapeIndCell, shapeAll, trackID)
indMSD = cell(size(shapeIndCell.MA_coord));
for mm = 1:numel(shapeIndCell.cellID)
    lociN = shapeIndCell.lociN(mm);
    if isnan(lociN), lociN = 0; end
    
    if lociN ~= 0
        ind = find(trackID(1,:)==shapeIndCell.videoID(mm) & ...
            shapeAll.cellID == shapeIndCell.cellID(mm));
        if ~isempty(ind)
            if numel(ind)==1 && lociN == 1 %case one to one correspondence assign one loci
                indL = ind;
            else
                RR = zeros(numel(ind), lociN);
                xxM = shapeAll.absX(ind);
                yyM = shapeAll.absY(ind);
                xxL = shapeIndCell.absX{mm};
                yyL = shapeIndCell.absY{mm};
                
                for ll = 1:lociN
                    RR(:,ll) = (xxL(ll)-xxM).^2 + (yyL(ll)-yyM).^2;
                end
                
                indL = nan(1,lociN);
                [iM, iL]= find(RR<2); %i do not do too many checks but it should work
                indL(iL) = ind(iM);
                
            end
            indMSD{mm} = indL;
        else
            indMSD{mm} = nan(1,lociN);
        end
    end
end