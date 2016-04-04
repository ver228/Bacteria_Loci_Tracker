function [posX,posY,posN] = ...
    join_tracks_ind(positionsx, positionsy, indSparse, settings)

% [posX posY JJ II NT] = join_tracks_ind(positionsx, positionsy, sparse(IT,JT,NT), settings)

if isempty(settings)
    settings.minSegment = 10;
    %{
    settings.maxDisplacement = 0.5; %max displacement to join tracks, in pixels
    %displacement of 1 is just to large, maybe it would be good to change
    %this depend on the current trajectory
    %}
    settings.maxBreak = 2; %max separation between the end and beggining of trajectories
    settings.maxNaN = 0.1; %maximum percentage of nan allowed
    settings.minTrackLength = 25; %min final track length
end
NP = size(positionsx,2);

%get initial and final index and coordinates
iniC = nan(3,NP);
finC = nan(3,NP);
for k = 1:NP
    [ini,~,xx] = find(positionsx(:,k),1);
    yy = positionsy(ini,k);
    iniC(:,k) = [ini, xx, yy];
    
    [fin,~,xx] = find(positionsx(:,k),1, 'last');
    yy = positionsy(fin,k);
    finC(:,k) = [fin, xx, yy];
end

%use only tracks with a given segment length
NL = finC(1,:) - iniC(1,:)+1;
valid = find(NL>=settings.minSegment);

finC = finC(:,valid);
iniC = iniC(:,valid);

totP = 0;
for k = 1:numel(valid)
    totP = totP + nnz(positionsx(:,valid(k)));
end

XX = nan(1,totP);
YY = nan(1,totP);
II = nan(1,totP);
JJ = nan(1,totP);
NT = nan(1,totP);

finTT = size(positionsx,1)-settings.minSegment; %final length to allow more trajectories

newTrack = true(size(valid));

tracksN = 0;
pointsN = 0;
for k = 1:numel(valid)
    if newTrack(k)
        np = valid(k);
        tracksN = tracksN + 1;
        
        vPos = iniC(1,k):finC(1,k);
        dum = numel(vPos);
        v = (1:dum) + pointsN;
        pointsN = pointsN + dum;
        
        
        delX = diff(positionsx(vPos,np));
        delY = diff(positionsy(vPos,np));
        R2 = delX.*delX+delY.*delY;
        settings.maxDisplacement = sqrt(mean(R2)+3*std(R2));
        
        II(v) = vPos;
        JJ(v) = tracksN;
        XX(v) = positionsx(vPos,np);
        YY(v) = positionsy(vPos,np);
        NT(v) = indSparse(vPos,np);
        
        
        if finC(1,k) < finTT
            
            oriFrame = k;
            
            while ~isempty(oriFrame)
                
                check = oriFrame:numel(valid);
                
                check = check(iniC(1,oriFrame:end) > finC(1,oriFrame) & newTrack(oriFrame:end));
                R = sqrt((finC(2,oriFrame) - iniC(2,check)).^2 + (finC(3,oriFrame) - iniC(3,check)).^2);
                good = check(R <= settings.maxDisplacement);
                
                if isempty(good)
                    newFrame = [];
                else
                    [A,co] = min(iniC(1,good)-finC(1,oriFrame));
                    if A > settings.maxBreak
                        newFrame = [];
                    else
                        newFrame = good(co);
                        newTrack(newFrame) = false;
                    end
                end
                
                if ~isempty(newFrame)
                    vPos = (finC(1,oriFrame)+1):(iniC(1,newFrame)-1);
                    if ~isempty(vPos)
                        dum = numel(vPos);
                        v = (1:dum) + pointsN;
                        pointsN = pointsN + dum;
                        
                        II(v) = vPos;
                        JJ(v) = tracksN;
                        XX(v) = nan;
                        YY(v) = nan;
                        NT(v) =nan;
                    end
                    
                    np = valid(newFrame);
                    vPos = iniC(1,newFrame):finC(1,newFrame);
                    dum = numel(vPos);
                    v = (1:dum) + pointsN;
                    pointsN = pointsN + dum;
                    
                    II(v) = vPos;
                    JJ(v) = tracksN;
                    XX(v) = positionsx(vPos,np);
                    YY(v) = positionsy(vPos,np);
                    NT(v) = indSparse(vPos,np);
                 end
                oriFrame = newFrame;
                
            end
        end
    end
end

posX = sparse(II,JJ,XX);
posY = sparse(II,JJ,YY);
posN = sparse(II,JJ,NT);

NP = size(posX,2);
in = false(size(NP));
for np = 1:NP
    xx = posX(:,np);
    bad = sum(isnan(xx));
    total = nnz(xx);
    in(np) = bad/total < settings.maxNaN && total> settings.minTrackLength;
end

posX = posX(:,in);
posY = posY(:,in);
posN = posN(:,in);




