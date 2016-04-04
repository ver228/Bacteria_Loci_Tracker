function shapeIndCell = extract_ShapePropsCell(trackID, datadir, del_pix,  progressTextStr, postFixStrS)
%postFixStrS = postFixStr{kk}; del_pix = param.del_pix;
strFields = {'cellID', 'videoID', 'area', 'length', 'width','mA_coord', 'MA_coord', ...
    'mA_coord2', 'MA_coord2', 'lociN', 'intensity', 'absX', 'absY'};
shapeIndCell = [];
for ii = 1:numel(strFields)
    shapeIndCell.(strFields{ii}) = [];
end

progressText(0,progressTextStr)
look = unique(trackID(1,:));

for nn = 1:numel(look)
    progressText(nn/numel(look))
    SSSS = look(nn);
    
    clear shapeData shapeMovie
    
    shapeMovie = [];
    
    if nargin == 5
        dum = sprintf('%sseg_%i_%s.mat',datadir.segmentation,SSSS,postFixStrS);
    else
        dum = sprintf('%sseg_%i.mat',datadir.segmentation,SSSS);
    end
    if exist(dum,'file')
        load(dum,'shapeData')
        
        dumC = cell(1,shapeData.TOT);
        shapeMovie.mA_coord = dumC;
        shapeMovie.MA_coord = dumC;
        shapeMovie.mA_coord2 = dumC;
        shapeMovie.MA_coord2 = dumC;
        
        shapeMovie.absX = dumC;
        shapeMovie.absY = dumC;
        
        
        shapeMovie.videoID = ones(1,shapeData.TOT)*SSSS;
        shapeMovie.cellID = 1:shapeData.TOT;
        
        %figure, hold on
        %axis([0 512 0 512])
        for kk = 1:shapeData.TOT
            if shapeData.loci.N(kk) ~=0
                xx = shapeData.loci.X{kk};
                yy = shapeData.loci.Y{kk};
                if size(xx,1) ~= 1
                    xx = xx';
                    yy = yy';
                end
                
                shapeMovie.absX{kk} = xx;
                shapeMovie.absY{kk} = yy;
                
                if numel(xx) > 1
                    AA = [shapeData.MajorAxis(kk), shapeData.MinorAxis(kk), ...
                        shapeData.Angle(kk), shapeData.CM(1,kk), ...
                        shapeData.CM(2,kk)];
                    
                    %find dot closest to pole
                    [XX, YY, POL] = bacteriaShape(AA);
                    minR = nan(size(xx));
                    for ii = 1:numel(xx)
                        delX = XX(POL)-xx(ii);
                        delY = YY(POL)-yy(ii);
                        minR(ii) = min(delX.*delX+delY.*delY);
                    end
                    [~,closest2Pole] = min(minR);
                    %{
                    plot(XX,YY,'b')
                    plot(xx,yy, '.r')
                    %}
                else
                    closest2Pole = 1;
                end
                
                ang = shapeData.Angle(kk);
                R=[cosd(ang) -sind(ang); sind(ang) cosd(ang)];
                lin=R*[xx- shapeData.CM(1,kk); yy-shapeData.CM(2,kk)];
                
                shapeMovie.MA_coord{kk} = lin(1,:);
                shapeMovie.mA_coord{kk} = lin(2,:);
                
                if lin(1,closest2Pole)<0
                    shapeMovie.MA_coord2{kk} = ...
                        lin(1,:)+shapeData.MajorAxis(kk)/2;
                else
                    shapeMovie.MA_coord2{kk} = ...
                        shapeData.MajorAxis(kk)/2-lin(1,:);
                end
                
                
                if lin(2,closest2Pole)<0
                    shapeMovie.mA_coord2{kk} = ...
                        lin(2,:)+shapeData.MinorAxis(kk)/2;
                else
                    shapeMovie.mA_coord2{kk} = ...
                        shapeData.MinorAxis(kk)/2-lin(2,:);
                end
                shapeMovie.MA_coord{kk} = shapeMovie.MA_coord{kk}*del_pix;
                shapeMovie.mA_coord{kk} = shapeMovie.mA_coord{kk}*del_pix;
                shapeMovie.MA_coord2{kk} = shapeMovie.MA_coord2{kk}*del_pix;
                shapeMovie.mA_coord2{kk} = shapeMovie.mA_coord2{kk}*del_pix;
                
                
            end
            
        end
        shapeMovie.length = shapeData.MajorAxis*del_pix;
        shapeMovie.width = shapeData.MinorAxis*del_pix;
        shapeMovie.area = shapeData.Area*del_pix*del_pix^2;
        shapeMovie.lociN = shapeData.loci.N;
        
        if isfield(shapeData.intensity, 'median')
            shapeMovie.intensity = shapeData.intensity.median;
        else
            shapeMovie.intensity = [];%nan(size(shapeMovie.lociN));
        end
        for ii = 1:numel(strFields)
            shapeIndCell.(strFields{ii}) = ...
                [shapeIndCell.(strFields{ii}) shapeMovie.(strFields{ii})];
        end
    end
end