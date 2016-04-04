function shapeAll = ...
    extract_ShapePropsMSD(trackID, datadir, del_pix,  progressTextStr, postFixStr, findOrder)
% del_pix = param.del_pix;nargin = 5;
IS_DEBUG = false;
strData = {'cellID', 'videoID', 'CMx', 'CMy', 'length', 'area','width',...
    'distWall','mA_coord','MA_coord', 'theta', 'lociN_msd', 'cellInt', 'absX', 'absY'};
    %coord is from the center of mass, 
    %coord2 takes zero as the pole that has the closer loci


for nn = 1:numel(strData)
    shapeAll.(strData{nn}) = nan(1, size(trackID,2));
end

if ~isempty(progressTextStr), progressText(0,progressTextStr), end

look = unique(trackID(1,:));
tot = 0;

for nn = 1:numel(look)
    if ~isempty(progressTextStr), progressText(nn/numel(look)), end
    SSSS = look(nn);
    
    clear shapeData
    
    if nargin >= 5
        dum = sprintf('%sseg_%i_%s.mat',datadir.segmentation,SSSS,postFixStr);
        
    else
        dum = sprintf('%sseg_%i.mat',datadir.segmentation,SSSS);
        findOrder = 'first';
    end
    if exist(dum,'file')
        tot = tot+1;
        load(dum,'shapeData')
        load(sprintf('%sTrackData_%i.mat',datadir.track,SSSS),'positionsx', 'positionsy');
        
        validI = trackID(1,:)==SSSS;
        selectedParticles = trackID(2,validI);
        xx = positionsx(:,selectedParticles);
        yy = positionsy(:,selectedParticles);
        
        %get first index of selected particles
        NP = numel(selectedParticles);
        xi=zeros(1,NP);
        yi=zeros(1,NP);
        for i = 1:NP
            dumI=find(xx(:,i),1,findOrder);
            xi(i)=xx(dumI,i);
            yi(i)=yy(dumI,i);
        end
        
        for kk = 1:numel(strData)
            shapeLoci.(strData{kk}) = nan(size(selectedParticles));
        end
        
        shapeLoci.videoID(:) = SSSS;
        
        if IS_DEBUG, figure, hold on, end
        for kk = 1:shapeData.TOT
            %if shapeData.AreaPix(kk)/shapeData.Area(kk)>0.5
                AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
                    shapeData.Angle(kk), shapeData.CM(1,kk), ...
                    shapeData.CM(2,kk)];
                [XX,YY,~] = bacteriaShape(AA);
                if IS_DEBUG, plot(XX,YY), end
                in = inpolygon(xi,yi, XX,YY);
                index = find(in);
                if ~isempty(index) %&& any(index==39)
                    
                    for mm = 1:numel(index)
                        ind = index(mm);
                        rad=sqrt((xi(ind)-XX).^2+(yi(ind)-YY).^2);
                        shapeLoci.distWall(ind)=min(rad);
                    end
                    shapeLoci.cellID(index) = kk;
                    
                    shapeLoci.CMx(index) = shapeData.CM(1,kk);
                    shapeLoci.CMy(index) = shapeData.CM(2,kk);
                    shapeLoci.length(index) = shapeData.MajorAxis(kk);
                    shapeLoci.width(index) = shapeData.MinorAxis(kk);
                    shapeLoci.area(index) = shapeData.Area(kk);
                    shapeLoci.theta(index) = shapeData.Angle(kk);
                    
                    if isfield(shapeData.intensity, 'median')
                    shapeLoci.cellInt(index) = shapeData.intensity.median(kk);
                    end
                    shapeLoci.lociN_msd(index) = numel(index);
                    
                    ang = shapeData.Angle(kk);
                    R=[cosd(ang) -sind(ang); sind(ang) cosd(ang)];
                    lin=R*[xi(index)-shapeLoci.CMx(index);yi(index)-shapeLoci.CMy(index)];
                    
                    shapeLoci.MA_coord(index)=lin(1,:);
                    shapeLoci.mA_coord(index)=lin(2,:);
                    
                    shapeLoci.absX(index)=xi(in);
                    shapeLoci.absY(index)=yi(in);
                    
                    
                end
            %end
        end
        
        for kk = 1:numel(strData)
            shapeAll.(strData{kk})(validI) = shapeLoci.(strData{kk});
        end
    end
end


if tot == 0
    shapeAll = [];
    fprintf('Segmented data not found\n')
else
    %shapeAll.nearPole = abs(shapeAll.MA_coord) > (shapeAll.length - shapeAll.width)/2;
    shapeAll.length = shapeAll.length*del_pix;
    shapeAll.area = shapeAll.area*del_pix^2;
    shapeAll.width = shapeAll.width*del_pix;
    shapeAll.distWall = shapeAll.distWall*del_pix;
    shapeAll.MA_coord = shapeAll.MA_coord*del_pix;
    shapeAll.mA_coord = shapeAll.mA_coord*del_pix;
end