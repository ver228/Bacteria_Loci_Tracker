function [trackAngDat, MSD_PC] =  calculate_AngMSD_PC(trackID,expodatadir,param)

look = unique(trackID(1,:));

if nargout >=2 
    MSD_PC.mA = nan(param.maxLag,size(trackID,2));
    MSD_PC.MA = nan(param.maxLag,size(trackID,2));
end

strEllipse = {'majorAxis','minorAxis','angle','CMx','CMy','eccentricity', 'vel_drift', 'a2', 'A2'};
for kk = 1:numel(strEllipse)
    trackAngDat.(strEllipse{kk}) = nan(1,size(trackID,2));
end

for nn =1:numel(look)
    
    SSSS = look(nn);
    inTrack = trackID(1,:) == SSSS;
    selectedParticles = trackID(2,inTrack);
    NP = numel(selectedParticles);
    
    %MSD FOR MINOR AND MAJOR AXIS
    ellipse_AA = nan(numel(strEllipse),NP);
    
    if nargout >=2
        msdmA = nan(param.maxLag,NP);
        msdMA = nan(param.maxLag,NP);
    end
    
    dum = sprintf('%sTrackData_%i.mat', expodatadir, SSSS);
    clear positionsx positionsy
    if exist(dum, 'file')
        load(dum);
        if param.isDedrift
            [positionsx, positionsy, ~] = ...
                dedrift_correction(positionsx, positionsy, set_dedrift);
        end
        
        if ~isempty(positionsx) && size(positionsx,1) - param.iniFrame + 1 > param.minTrackLength
            positionsx = positionsx(param.iniFrame:end,:);
            positionsy = positionsy(param.iniFrame:end,:);
            
            if size(positionsx,1) > param.maxTrackLength
                positionsx(param.maxTrackLength+1:end,:) = [];
                positionsy(param.maxTrackLength+1:end,:) = [];
            end
            
            positionsx = positionsx(:,selectedParticles).*param.del_pix;
            positionsy = positionsy(:,selectedParticles).*param.del_pix;
            
            maxLag = min(param.maxLag,size(positionsx,1));
            %whos positionsx
            for np = 1:numel(selectedParticles)
                [ii, ~, posX] = find(positionsx(:,np));
                posX = full(posX);
                posY = full(positionsy(ii,np));
                
                in = ~(isnan(posX)|isnan(posY));
                XX = posX(in);
                YY = posY(in);
                if numel(XX)<param.minTrackLength, 
                    continue
                end
                
                CMx = mean(XX);
                XX = XX-CMx;
                
                CMy = mean(YY);
                YY = YY-CMy;
                
                
                Dm = full([XX YY]);
                C = cov(Dm);
                [E,V] = eig(C);
                [eval, I] = sort(diag(V),'descend');
                evec = E(:,I);
                ecc = sqrt(1-eval(2)/eval(1));
                
                % as defined in Saxton 1993
                %a2 = eval(2).^2/eval(1).^2; %WRONG EVAL IS ALREADY SQUARED!!
                %A2 = (eval(1).^2-eval(2).^2).^2./(eval(1).^2+eval(2).^2).^2;
                a2 = eval(2)/eval(1);
                A2 = (eval(1)-eval(2)).^2./(eval(1)+eval(2)).^2;
                % Calculate orientation. (modified from regionprops.m)
                if (evec(1,1) == 0) && (evec(2,1) == 0)
                    ang = 0;
                else
                    ang = (180/pi) * atan(evec(2,1)/evec(1,1));
                end
                %}
                
                drift_vel = (XX(end)*evec(1,1) + YY(end)*evec(2,1)) - ...
                    (XX(1)*evec(1,1) + YY(1)*evec(2,1));
                
                drift_vel = abs(drift_vel)/numel(XX)/param.del_time;
                
                
                VV = sqrt(eval)*2; % get the real major and minor axis
                
                
                ellipse_AA(:,np) = [VV(1) VV(2) ang CMx CMy ecc drift_vel a2 A2]; %ellipse data
                
                if nargout >=2
                    %calculate MSD
                    maxLagInd = min(numel(ii), maxLag);
                    for lag = 1:maxLagInd
                        delX = posX(lag+1:end)-posX(1:end-lag);
                        delY = posY(lag+1:end)-posY(1:end-lag);
                        
                        out = isnan(delX);
                        delX(out) =[];
                        delY(out) =[];
                        
                        xx = mean(delX.*delX);
                        yy = mean(delY.*delY);
                        xy = mean(delX.*delY)*(2*sind(ang)*cosd(ang));
                        
                        msdmA(lag,np)=xx.*(sind(ang)^2)+yy.*(cosd(ang)^2)+xy;
                        msdMA(lag,np)=xx.*(cosd(ang)^2)+yy.*(sind(ang)^2)-xy;
                        
                    end
                end
            end
        end
    end
    if nargout >= 2
    MSD_PC.mA(:,inTrack) = msdmA;
    MSD_PC.MA(:,inTrack) = msdMA;
    end
    for kk = 1:numel(strEllipse)
        trackAngDat.(strEllipse{kk})(:,inTrack) = ellipse_AA(kk,:);
    end
    
end
