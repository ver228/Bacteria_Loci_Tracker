function [errMat, MSD, M4D, MSDw, errMatw,Xmat, Ymat, Emat, MME2, MME4, Npoints, MLSD] = ...
    calculate_MSD_MME_LOG(positionsx, positionsy, positionsE, maxLag)

if isempty(positionsE)
    positionsE = sparse(size(positionsx,1),size(positionsx,2));
end


NP = size(positionsx,2);
errMat = nan(maxLag,NP);
MSD = nan(maxLag,NP);
errMatw = nan(maxLag,NP);
MSDw = nan(maxLag,NP);

M4D = nan(maxLag,NP);
Xmat = nan(maxLag,NP-1);
Ymat = nan(maxLag,NP-1);
Emat = nan(maxLag,NP-1);

MLSD = nan(maxLag,NP);

MME2 = zeros(maxLag,NP); %IT IS IMPORTANT THAT MME2 and MME4 ARE ZEROS
MME4 = zeros(maxLag,NP);
Npoints = nan(1,NP);
%%
for p = 1:NP
    %p = selectedParticles(p);
    [ii, ~, posX] = find(positionsx(:,p));
    posY = positionsy(ii,p);
    posE = positionsE(ii,p);
    
    %get number of points and maximum time lag
    Ntime = numel(posX);
    Npoints(p) = Ntime;
    maxLagInd = min(Ntime, maxLag);
    
    if ~isempty(Ntime)
        
        Xmat(1:(maxLagInd-1),p) = posX(2:maxLagInd)-posX(1);
        Ymat(1:(maxLagInd-1),p) = posY(2:maxLagInd)-posY(1);
        Emat(1:(maxLagInd-1),p) = (posE(2:maxLagInd)+posE(1))/2;
        %%
        %calculate MSD
        for lag = 1:maxLagInd
            delX = posX(lag+1:end)-posX(1:end-lag);
            delY = posY(lag+1:end)-posY(1:end-lag);
            E2 = (posE(lag+1:end)+posE(1:end-lag))/2;
            
            out = isnan(delX)|isnan(E2);
            delX(out) =[];
            delY(out) =[];
            E2(out) = [];
            
            X2 = delX.*delX;
            Y2 = delY.*delY;
            %NN = numel(delX);
            %MSD_err(lag,p) = sqrt(2*(mean(X2)*var(delX)+ mean(Y2)*var(delY))/NN);
            
            R2 = X2 + Y2;
            R2(isnan(R2)) = [];
            MSD(lag,p) = mean(R2);
            M4D(lag,p) = mean(R2.^2); % it is already power 2
            
            MLSD(lag,p) = geomean(R2);
            
            errMat(lag,p) = mean(E2);
            
            sigma = 1./E2;
            sigW = sum(sigma);
            MSDw(lag,p) = sum(sigma.*R2)./sigW;
            errMatw(lag,p) = numel(sigma)./sigW;
        end
        %%
        Nlag = zeros(maxLag,1);
        for tt = 1:(Ntime-1)
            R2 = (posX((tt+1):end)-posX(tt)).^2+(posY((tt+1):end)-posY(tt)).^2;
            Rmax = R2(1);
            for lag = 1:(maxLagInd-tt)
                Rmax = max(R2(lag),Rmax);
                Nlag(lag) = Nlag(lag) + 1;
                MME2(lag,p) = Rmax+ MME2(lag,p);
                MME4(lag,p) = Rmax.^2+ MME4(lag,p);
            end
        end
        MME2(:,p) = MME2(:,p)./Nlag;
        MME4(:,p) = MME4(:,p)./Nlag;
    end
end
