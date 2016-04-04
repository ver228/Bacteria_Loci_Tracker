function MSD_mov =  calculate_Static_corr2(positionsx,positionsy,positionsE, ...
    maxTrackLength, lag)
%maxTrackLength = param.maxTrackLength; lag = param.Nlag(nn);
dum = zeros(1,maxTrackLength-lag);
MSD_mov.X = dum;
MSD_mov.N= dum;
MSD_mov.X2= dum;
MSD_mov.Xc= dum;
MSD_mov.Nc= dum;
MSD_mov.X2c= dum;

for tt = 1:(size(positionsx,1)-lag)
    in = positionsx(tt+lag,:)~=0&positionsx(tt,:)~=0;
    R2 = (positionsx(tt+lag,in)-positionsx(tt,in)).^2 + ...
        (positionsy(tt+lag,in)-positionsy(tt,in)).^2;
    
    
    out = isnan(R2);
    
    if ~isempty(positionsE) && sum(in)~=0
        E2 = (positionsE(tt+lag,in)+positionsE(tt,in))/2;
        R2c = R2-E2;
        out = out|isnan(R2c);
        R2c(out) = [];
        
        MSD_mov.Xc(tt) = sum(R2c);
        MSD_mov.X2c(tt) = sum(R2c.^2);
        MSD_mov.Nc(tt) = numel(R2c);
    end
    
    R2(out) = [];
    MSD_mov.X(tt) = sum(R2);
    MSD_mov.X2(tt) = sum(R2.^2);
    MSD_mov.N(tt) = numel(R2);
    
end
