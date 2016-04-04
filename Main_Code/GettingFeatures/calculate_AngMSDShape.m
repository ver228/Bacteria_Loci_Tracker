function MSD_Shape = calculate_AngMSDShape(trackID, shapeAll,expodatadir,param)
%expodatadir = expodatadir{1};
look = unique(trackID(1,:));

MSD_Shape.mA = nan(param.maxLag,size(trackID,2));
MSD_Shape.MA = MSD_Shape.mA;

MSD_Shape.v_mA =  nan(1,size(trackID,2));
MSD_Shape.v_MA =  nan(1,size(trackID,2));
MSD_Shape.v_MAver2 =  nan(1,size(trackID,2));
MSD_Shape.Rg_MA =  nan(1,size(trackID,2));
MSD_Shape.Rg_mA =  nan(1,size(trackID,2));

MSD_Shape.crossCMx = false(1,size(trackID,2));
MSD_Shape.crossCMy = false(1,size(trackID,2));


for nn = 1:numel(look)
    SSSS = look(nn);
    in = trackID(1,:) == SSSS;
    selectedParticles = trackID(2,in);
    NP = numel(selectedParticles);
    
    %initialize to get the movie data
    msdmA = nan(param.maxLag,NP);
    msdMA = nan(param.maxLag,NP);
    
    ang_mov = shapeAll.theta(in);
    cellCMx = shapeAll.CMx(in).*param.del_pix;
    cellCMy = shapeAll.CMy(in).*param.del_pix;
    
    crossCM = false(2,NP);
    vCellDrift = nan(2,NP);
    vCellDriftXver2 = nan(1,NP);
    Rg_MA = nan(1,NP);
    Rg_mA = nan(1,NP);
    
    
    dum = sprintf('%sTrackData_%i.mat', expodatadir, SSSS);
    if exist(dum, 'file')
        load(dum);
        if ~isempty(positionsx) && size(positionsx,1) > param.maxTrackLength-param.iniFrame+1
            positionsx = positionsx(param.iniFrame:end,:);
            positionsy = positionsy(param.iniFrame:end,:);
            
            if size(positionsx,1) > param.maxTrackLength
                positionsx(param.maxTrackLength+1:end,:) = [];
                positionsy(param.maxTrackLength+1:end,:) = [];
            end
            
            positionsx = positionsx(:,selectedParticles).*param.del_pix;
            positionsy = positionsy(:,selectedParticles).*param.del_pix;
            maxLag = min(param.maxLag,size(positionsx,1));
            
            for np = 1:numel(selectedParticles)
                [ii, ~, posX] = find(positionsx(:,np));
                posY = positionsy(ii,np);
                
                ang = ang_mov(np); %the stored angle is already inverted...
                if ~isnan(ang)
                    maxLagInd = min(numel(ii), maxLag);
                    %rotate coordinates along cell major axis 
                    R = [cosd(ang) -sind(ang); sind(ang) cosd(ang)]; 
                    lin = R*[posX';posY'];
                    xR = lin(1,:); %major axis
                    yR = lin(2,:); %minor axis
                    for lag = maxLagInd:-1:1
                        delX = xR(lag+1:end)-xR(1:end-lag);
                        delY = yR(lag+1:end)-yR(1:end-lag);
                        out = isnan(delX);
                        delX(out) = [];
                        delY(out) = [];
                        
                        msdMA(lag,np) = mean(delX.*delX);
                        msdmA(lag,np) = mean(delY.*delY);
                    end
                    %ratius of gyration
                    Rg_MA(np) = std(xR,1);%sqrt(mean((xR-mean(xR)).^2));
                    Rg_mA(np) = std(yR,1);%sqrt(mean((yR-mean(yR)).^2));
                    
                    lin = R*[[posX(1),posX(end)]-cellCMx(np); ...
                        [posY(1),posY(end)]-cellCMy(np)];
                    xR = lin(1,:);
                    yR = lin(2,:);
                    
                    %calculate the drift velocity towards cell center or
                    %cell poles
                    
                    tt = numel(posX)*param.del_time;
                    if xR(end)*xR(1) > 0 %check that it does not pass through the center (sign change)
                        vCellDrift(1,np) = (abs(xR(end))-abs(xR(1)))/tt;
                    else
                        crossCM(1,np) = true;
                    end
                    
                    vD = (xR(end)-xR(1))/tt;
                    if xR(1)<0, vD = -vD; end
                    vCellDriftXver2(np) = vD;
                    
                    if yR(end)*yR(1) > 0 %check that it does not pass through the center (sign change)
                        vCellDrift(2,np) = (abs(yR(end))-abs(yR(1)))/tt;
                        crossCM(2,np) = true;
                    end
                end
            end
        end
    end
    MSD_Shape.MA(:,in) = msdMA;
    MSD_Shape.mA(:,in) = msdmA;
    MSD_Shape.v_MA(in) = vCellDrift(1,:);
    MSD_Shape.v_mA(in) = vCellDrift(2,:);
    MSD_Shape.v_MAver2(in) = vCellDriftXver2;
    MSD_Shape.crossCMx(in) = crossCM(1,:);
    MSD_Shape.crossCMy(in) = crossCM(2,:);
    MSD_Shape.Rg_MA(in) = Rg_MA;
    MSD_Shape.Rg_mA(in) = Rg_mA;
    
    
end