function [alphaFit,alphaFitR2] = alpha_Moving3(data, Npoints, error, param)
%data=timeAv.MSD; Npoints=timeAv.Npoints; error=[];
%data=datAv.geoM.MSD; Npoints=[]; error=[];
%param = param2;

TOT = size(data,2);

if param.maxLag>size(data,1)
    param.maxLag = size(data,1);
end
tt = ((1:param.maxLag)*param.del_time)';
ttL = log10(tt);

if ~isempty(error)
    errL = log10(error);
else
    errL = [];
end
binSize = numel(param.alpha.Bin) - 2*param.alpha.WStep;

alphaFit = nan(binSize,TOT);
alphaFitR2 = nan(binSize,TOT);
%
iniW = find(param.alpha.Bin > ttL(1),1) - 1;
if isempty(iniW), warning('alpha_Moving3: wrong param.alpha.Bin range'); return; end
%}

finW = find(param.alpha.Bin > ttL(end),1) - 1;
if isempty(finW), warning('alpha_Moving3: wrong param.alpha.Bin range'); return; end

%%
for nn = 1:TOT
    yy = data(1:param.maxLag,nn);
    yyL = log10(yy);
    
    %take out data smaller than the calculated error
    if ~isempty(errL)
        yyL(yyL<errL(1:param.maxLag,nn)) = nan;
    end
    
    %take out lag times that was calculated with less than 50% of the track
    %length
    if ~isempty(Npoints)
        iiLim = round(Npoints(nn)/2);
        iiLim = min(iiLim, param.maxLag);
    else
        iiLim = param.maxLag;
    end
    yyL((iiLim+1):end) = nan;
    
    %%
    for k = (iniW+param.alpha.WStep):(finW-param.alpha.WStep)
        [~,ini] = min(abs(ttL - param.alpha.Bin(k-param.alpha.WStep)));
        [~,fin] = min(abs(ttL - param.alpha.Bin(k+param.alpha.WStep)));
        v = ini:fin;
        
        if ~any(isnan(yyL(v))) % make sure it is within the MSD valid data
            pp = polyfit(ttL(v),yyL(v),1);
            
            SSresid = sum((yyL(v)-polyval(pp, ttL(v))).^2);
            SStotal = (numel(v)-1)*var(yyL(v));
            ii = k - param.alpha.WStep;
            alphaFit(ii,nn) = pp(1);
            alphaFitR2(ii,nn) = 1 - SSresid/SStotal;
        end
    end
end
