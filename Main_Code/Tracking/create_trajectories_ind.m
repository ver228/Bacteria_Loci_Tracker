function [positionsx,positionsy, indSparse] = create_trajectories_ind(dots,SET)

totpoints=0;
TOTFRAMES = numel(dots);

nParticles = zeros(size(dots));
for kk = 1:numel(nParticles)
    nParticles(kk) = dots{kk}.num;
end

ini = find(nParticles,1);
fin = find(nParticles,1,'last');
for nn = ini:fin%TOTFRAMES
    PFOUND=dots{nn}.num;
    
    %PARTICLE TRACK
    if nn==ini
        Ip= ini*ones(1,PFOUND); %time; index for the sparse matrix
        Jp = 1:PFOUND; %index for the sparse matrix
        Xp = dots{nn}.positionsx;
        Yp = dots{nn}.positionsy;
        Np = 1:PFOUND; %dot index in the dots structure
        
        
        PTOT=PFOUND;
        %allocated memory
        XT = nan(1,PFOUND*TOTFRAMES); 
        YT = nan(1,PFOUND*TOTFRAMES);
        
        NT = zeros(1,PFOUND*TOTFRAMES);
        JT = zeros(1,PFOUND*TOTFRAMES);
        IT = zeros(1,PFOUND*TOTFRAMES);
    else
        Xn = dots{nn}.positionsx;
        Yn = dots{nn}.positionsy;
        Nn = 1:PFOUND;
        
        %intRad = nan(1,PFOUND);
        Jn = zeros(1,PFOUND);
        
        isEmpty = true(size(Xp));
        D = nan(size(Xp));
        
        part2check = 1:PFOUND;
        while ~isempty(part2check)
            ind = part2check(1);
            dist = sqrt((Xp-Xn(ind)).^2+(Yp-Yn(ind)).^2);
            
            count = 1; smallDist = true;
            while Jn(ind)==0 && smallDist && count <= numel(dist) 
                [di ji] = min(dist); %find the closest match
                if dist(ji) > SET.MAXMOVE; %check the distance is not too large
                    smallDist = false;
                elseif isEmpty(ji) %check the index was not assigned before
                    isEmpty(ji) = false; %if the closest match was not used pick the closest particle
                    Jn(ind) = Jp(ji);
                    D(ji) = di;
                elseif di < D(ji)
                    co = find(Jn == Jp(ji));
                    Jn(co) = 0;
                    part2check(end+1) = co; %recheck this particle
                    
                    Jn(ind) = Jp(ji);
                    D(ji) = di;
                else
                    dist(ji) = nan; %check for the next min distance
                    count = count+1;
                end
            end
            part2check(1) = []; %remember to remove the particle from the check list
        end
        
        %{
        out = D>SET.MAXMOVE; %throw out particles whose close match is unrealistic
        %out = out | intRad > SET.INTVAR; %maximum intensity variation between frames
        Jp=Jn(~out);
        Xp=Xn(~out);
        Yp=Yn(~out);
        Np=Nn(~out);
        %}
        
        Jp=Jn; Xp=Xn; Yp=Yn; Np=Nn;
        %add new particle that didn't have a close match
        indNew=find(Jp==0);
        if ~isempty(indNew)
            N=numel(indNew);
            newInd=PTOT+(1:N);
            PTOT=PTOT+N;
            Jp(indNew)=newInd;
        end
        
        Ip=ones(size(Jp))*nn;
    end
    PFOUND=numel(Jp);
    if PFOUND==0
        break;
    else
        prevTotPoints=totpoints;
        totpoints=totpoints+PFOUND;
        newInd=(prevTotPoints+1):totpoints;
        IT(newInd)=Ip;
        JT(newInd)=Jp;
        YT(newInd)=Yp;
        XT(newInd)=Xp;
        %BT(newInd)=Bp;
        NT(newInd)=Np;
        %ST(newInd)=Sp;
        
    end
    %{
    figure
    imagesc(Ii)
    hold on
    plot(X,Y,'.k');
    %}
end
if totpoints~=0
IT(totpoints:end)=[];
JT(totpoints:end)=[];
YT(totpoints:end)=[];
XT(totpoints:end)=[];
%BT(totpoints:end)=[];
NT(totpoints:end)=[];
%ST(totpoints:end)=[];


positionsx=sparse(IT,JT,XT);
clear XT
positionsy=sparse(IT,JT,YT);
clear YT
indSparse = sparse(IT,JT,NT);


else
    positionsx=[];
    positionsy=[];
    indSparse = [];
end