function [timeAv, trackID, allMSD_mov] = extract_MSD_MEE_EE(track_results_dir, rows_in_group, param)
strData = {'errMat', 'MSD', 'M4D', 'Xmat', 'Ymat', 'Emat',...
    'MME2','MME4','Npoints', 'MSDw', 'errMatw', 'MLSD'};
timeAv = [];
allCM = cell(1,numel(rows_in_group));
trackID = [];


allMSD_mov = cell(numel(rows_in_group),numel(param.Nlag));

progressText(0,param.progressTextStr)
for kk = 1:numel(rows_in_group)
    progressText(kk/numel(rows_in_group))
    
    row_id = rows_in_group(kk);
    tracking_file = fullfile(track_results_dir, sprintf('TrackData_%i.mat', row_id));
    if exist(tracking_file, 'file')
        load(tracking_file, 'positionsx', 'positionsy');
        
        if ~isempty(positionsx) && size(positionsx,1) >= param.minTrackLength-param.iniFrame+1
            
            
            positionsx = positionsx(param.iniFrame:end,:);
            positionsy = positionsy(param.iniFrame:end,:);
            if size(positionsx,1) > param.maxTrackLength
                positionsx(param.maxTrackLength+1:end,:) = [];
                positionsy(param.maxTrackLength+1:end,:) = [];
            end
            %%
            nT = zeros(1, size(positionsx,2));
            for nn = 1:size(positionsx,2)
                nT(nn) = nnz(positionsx(:,nn))-sum(isnan(positionsx(:,nn)));
            end
            inS = nT>= param.minTrackLength;
            selectedParticles = find(inS);
            NP = numel(selectedParticles);
            
            NN = sum(spones(positionsx),2);
            tIni = find(NN,1);
            tFin = find(NN,1,'last');
            
            positionsx = positionsx(tIni:tFin,inS).*param.del_pix;
            positionsy = positionsy(tIni:tFin,inS).*param.del_pix;
            maxLag = min(param.maxLag,size(positionsx,1));
            %%
            if ~isempty(track_results_dir)
                load(tracking_file, 'SNRStats')
                if ~isempty(SNRStats)
                    INT = SNRStats.signal;
                    BGND = SNRStats.bgnd;
                    
                    INT = INT(param.iniFrame:end,:);
                    BGND = BGND(param.iniFrame:end,:);
                    
                    if size(positionsx,1) > param.maxTrackLength
                        INT(param.maxTrackLength+1:end,:) = [];
                        BGND(param.maxTrackLength+1:end,:) = [];
                    end
                    INT = INT(tIni:tFin,selectedParticles);
                    BGND = BGND(tIni:tFin,selectedParticles);
                    
                    %positionsE = calculate_posE2(INT, BGND, param.err, param.isEMgain);
                    positionsE = calculate_posE2_SNR(INT, BGND, param.err, param.isEMgain);
                else
                    continue
                end
            else
                positionsE = sparse(size(positionsx,1),size(positionsx,2));
            end
            
            
            %{
            [errMat, MSD, M4D, MSDw, errMatw,Xmat, ...
                Ymat, Emat, MME2, MME4, Npoints] = ...
                calculate_MSD_MME_EE(positionsx, positionsy, ...
                positionsE, maxLag);
            %}
            
            [errMat, MSD, M4D, MSDw, errMatw,Xmat, ...
                Ymat, Emat, MME2, MME4, Npoints, MLSD] = ...
                    calculate_MSD_MME_LOG(positionsx, positionsy, ...
                positionsE, maxLag);
            
            
            for nn = 1:numel(param.Nlag)
                allMSD_mov{kk,nn} =  calculate_Static_corr2(positionsx,positionsy,positionsE, ...
                    param.maxTrackLength, param.Nlag(nn));
            end
            
            if isempty(timeAv)
                tot = 0;
                
                buffSize = NP*numel(rows_in_group); %estimate the buffer size
                for ff = 1:numel(strData)
                    if strcmp(strData{ff},'Npoints')
                        dimSize = 1;
                    else
                        dimSize = param.maxLag;
                    end
                    timeAv.(strData{ff}) = nan(dimSize, buffSize);
                end
                trackID = nan(2, buffSize);
            end
            
            vData = (1:NP) + tot;
            tot = tot + NP;
            trackID(1,vData) = row_id*ones(1,NP);
            trackID(2,vData) = selectedParticles;
            for ff = 1:numel(strData)
                if ~strcmp(strData{ff},'Npoints')
                    timeAv.(strData{ff})(1:maxLag,vData) = eval(strData{ff});
                else
                    timeAv.(strData{ff})(:,vData) = eval(strData{ff});
                end
            end
        end
    end
end


if ~isempty(timeAv)
    for ff = 1:numel(strData)
        timeAv.(strData{ff})(:,(tot+1):end) = [];
    end
    trackID(:,(tot+1):end) = [];
    timeAv.MSDc = timeAv.MSD-timeAv.errMat;
end