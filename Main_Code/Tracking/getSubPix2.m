function [dat_m, out] = getSubPix2(Iraw, dat, SET)
imSize = size(Iraw);
mcSim = nan(5,dat.num);
for co = 1:dat.num
    vX=(dat.positionsx(co)-2):(dat.positionsx(co)+2);
    vY=(dat.positionsy(co)-2):(dat.positionsy(co)+2);
    if vX(1) >= 1 && vX(end) <= imSize(2) ...
            && vY(1) >= 1 && vY(end) <= imSize(1)
        S = Iraw(vY,vX);
        CINI=[dat.max_int(co),SET.sigma,0,0,dat.bkgd(co)];
        mcSim(:,co) = fminuit(SET.fun2fit,CINI,S(:)','-c',SET.cmd);
    end
end

dat_m = dat;
dat_m.positionsx = dat.positionsx + mcSim(3,:)';
dat_m.positionsy = dat.positionsy + mcSim(4,:)';
dat_m.fit_Sig = mcSim(2,:)';
dat_m.fit_I = mcSim(1,:)';
dat_m.fit_Bg = mcSim(5,:)';

out = mcSim(3,:).^2 + mcSim(4,:).^2 >= 2 | isnan(mcSim(4,:));

if any(out)
    dat_m.positionsx(out) =[];
    dat_m.positionsy(out) =[];
    dat_m.fit_Sig(out) =[];
    dat_m.fit_I(out) =[];
    dat_m.fit_Bg(out) =[];
    
    dat_m.max_int(out) =[];
    dat_m.bkgd(out) =[];
    dat_m.bgStd(out) =[];
    dat_m.pValue(out) =[];
    dat_m.num = dat_m.num - sum(out);
end