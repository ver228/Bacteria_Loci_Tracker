function CM = calculate_CM2(posX, posY, settings)
%posX = positionsx; posY = positionsy; settings = set_dedrift;
%settings.particlesUsed set it to [] to use all the particles
timeT = size(posX,1);
trackLegth = zeros(1,size(posX,2));
for np = 1:size(posX,2)
    ii = find(isnan(posX(:,np)));
    if ~isempty(ii)
        posX(ii,np) = 0;
        ii = [1;ii;timeT];
        [~,co] = max(diff(ii));
        posX(1:(ii(co)-1),np) = 0;
        posX((ii(co+1)+1):end,np) = 0;
    end
    trackLegth(np) = nnz(posX(:,np));
end

limR = nan(1,size(posX,2));
for np = 1:size(posX,2)
    xx = nonzeros(posX(:,np));
    if numel(xx) >= settings.minTrackDedrift
        yy = nonzeros(posY(:,np));
        
        limR(np) = (max(xx) - min(xx)).^2+(max(yy) - min(yy)).^2;
    end
end
[~,indLim] = sort(limR);

diffCM.x = zeros(1,timeT-1);
diffCM.y = zeros(1,timeT-1);
CM.n = zeros(1,timeT-1);

in = ~isnan(limR);
if settings.excludeBigMov
    mm = median(limR(in));
    mad = median(abs(limR(in)-mm));
    in = in & limR >= mm-3*mad & limR <= mm+3*mad;
end

for tt = 1:(timeT-1)
    ii = find(posX(tt+1,:)~=0 & posX(tt,:)~=0 & in);
    
    % this part it's not done since normally I put minParticles as empty
    if ~isempty(settings.particlesUsed) && numel(ii) > settings.particlesUsed
        [~,dum]= sort(limR(ii));
        ii = ii(dum);
        ii = ii(1:minParticles);
    end
        %}
    y0 = posY(tt,ii);
    yf = posY(tt+1,ii);
    x0 = posX(tt,ii);
    xf = posX(tt+1,ii);
    
    diffCM.x(tt) = mean(xf)-mean(x0);
    diffCM.y(tt) = mean(yf)-mean(y0);
    CM.n(tt) = nnz(x0);
end


%
%% this could work but if there is only sparse nan in diffCM.x would mess up everything.

CM.n = [CM.n(1) CM.n];
CM.x = zeros(1,timeT);
CM.y = zeros(1,timeT);

for tt = 1:(timeT-1)
    if ~isnan(diffCM.x(tt))
        if ~isnan(CM.x(tt))
            CM.x(tt+1) = CM.x(tt)+diffCM.x(tt);
            CM.y(tt+1) = CM.y(tt)+diffCM.y(tt);
        else
            CM.x(tt+1) = 0;
            CM.y(tt+1) = 0;
        end
    else
        CM.x(tt+1) = nan;
        CM.y(tt+1) = nan;
    end
end
if isnan(CM.x(2))
    CM.x(1) = nan;
    CM.y(1) = nan;
end


%}


%%
%figure, plot(CM.x, CM.y)
%figure, hold on, plot(limR), dum = find(~isnan(limR)); plot(dum, limR(dum), '.r')
