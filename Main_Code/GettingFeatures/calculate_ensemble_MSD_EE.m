function assembleAv = calculate_ensemble_MSD_EE(Xmat, Ymat, Emat, maxLag)
assembleAv.MSD = nan(1,maxLag);
assembleAv.M4D = nan(1,maxLag);
assembleAv.MSD_err = nan(1,maxLag);
assembleAv.errMat = nan(1,maxLag);
assembleAv.MSDw = nan(1,maxLag);
assembleAv.errMatw = nan(1,maxLag);

for lag = 1:maxLag;
    delX = Xmat(lag,:);
    delY = Ymat(lag,:);
    delE = Emat(lag,:);
    
    out = isnan(delX)|isnan(delY)|isnan(delE);
    delX(out) = [];
    delY(out) = [];
    delE(out) = [];
    
    NN = numel(delX);
    
    X2 = delX.*delX;
    Y2 = delY.*delY;
    R2 = X2 + Y2;
    
    assembleAv.MSD(lag) = mean(R2);
    assembleAv.M4D(lag) = mean(R2.^2);
    assembleAv.MSD_err(lag) = sqrt(2*(mean(X2)*var(delX)+ mean(Y2)*var(delY))/NN);
    assembleAv.errMat(lag) = mean(delE);
    
    sigma = 1./delE;
    sigW = sum(sigma);
    assembleAv.MSDw(lag) = sum(R2.*sigma)./sigW;
    assembleAv.errMatw(lag) = numel(sigma)./sigW;
end

assembleAv.MME2 = nan(1,maxLag);
assembleAv.MME4 = nan(1,maxLag);
R2mat = Xmat.^2+Ymat.^2;
for lag = 1:maxLag;
    
    vec = max(R2mat(1:lag,:),[],1);
    vec(isnan(vec)) = [];
    assembleAv.MME2(:,lag) = mean(vec);
    assembleAv.MME4(:,lag) = mean(vec.^2);
end