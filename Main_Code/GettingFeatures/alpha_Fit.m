function [alphaFit, alphaFitR2, gammaFit] = alpha_Fit(MSD, error, param)
%limits = param.alpha2.limits;
%MSD = timeAv.MSD;
%Npoints = timeAv.Npoints;
%error = [];


TOT = size(MSD,2);

tt = ((1:param.maxLag)*param.del_time)';
ttL = log10(tt);

ini = find(tt>param.alpha2.limits(1),1);
fin = find(tt>=param.alpha2.limits(2),1);
vv = ini:fin;

MSD = MSD(vv,:);
ttL = ttL(vv);

if ~isempty(error)
    errL = log10(error(vv,:));
else
    errL = [];
end
alphaFit = nan(1,TOT);
alphaFitR2 = nan(1,TOT);
gammaFit = nan(1,TOT);
%%
NN = numel(vv);
for nn = 1:TOT
    yyL = log10(MSD(:,nn));
    
    %take out MSD smaller than the calculated error
    if ~isempty(errL)
        yyL(yyL<errL(1:param.maxLag,nn)) = nan;
    end
    
    %if ~any(isnan(yyL)) % make sure it is within the MSD valid range
        good = ~isnan(yyL);
        pp = polyfit(ttL(good),yyL(good),1);
        SSresid = sum((yyL(good)-polyval(pp, ttL(good))).^2);
        SStotal = (NN-1)*var(yyL(good));
        alphaFit(nn) = pp(1);
        alphaFitR2(nn) = 1 - SSresid/SStotal;
        gammaFit(nn) = 10.^pp(2);
    %end
end
