function [positionsx, positionsy, CM, validInd] = ...
    dedrift_correction(positionsx, positionsy, set_dedrift)
%load([expodatadir, 'TrackData_', strSSSS ,'.mat']); minTrackDedrift=50; minParticles=5;
if size(positionsx,1)<2
    CM = [];
    return
end


%CM = calculate_CM2(positionsx, positionsy, minTrackDedrift);
CM = calculate_CM2(positionsx, positionsy, set_dedrift);

if ~isempty(CM)
    ini = find(CM.n >= set_dedrift.minParticles & ~isnan(CM.x), 1);
    range = find(CM.n(ini:end) < set_dedrift.minParticles | isnan(CM.x(ini:end)), 1);
    if ~isempty(range)
        fin = ini+range-2;
    else
        fin = numel(CM.n);
    end
    
    validInd = false(1,numel(CM.n));
    validInd(ini:fin) = true;
else
    validInd = [];
end


for tt = 1:size(positionsx,1)
    if validInd(tt)
        in = find(positionsx(tt,:)); 
        positionsx(tt,in) = positionsx(tt,in) - CM.x(tt);
        positionsy(tt,in) = positionsy(tt,in) - CM.y(tt);
    end
end
positionsx(~validInd,:) = [];
positionsy(~validInd,:) = [];


