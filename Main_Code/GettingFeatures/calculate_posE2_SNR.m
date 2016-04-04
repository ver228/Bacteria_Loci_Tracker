function positionsE = calculate_posE2_SNR(INT, BGND, coeff, isEMgain)
%INT= SNRStats.signal; BGND= SNRStats.bgnd; isEMgain= flags.isEMgain(fp); param_bb = param.err;
II = find(INT);

if isEMgain %for the moment leave undefined if it is not emgain
    SNR = INT(II)./sqrt(INT(II)+BGND(II)-100)/sqrt(2);
    SNR(SNR<0) = nan;
    positionsE = coeff(2).*SNR.^coeff(1);
else
    positionsE = ones(size(II));
end
[II, JJ] = ind2sub(size(INT),II);
positionsE = sparse(II, JJ,positionsE, size(INT,1), size(INT,2));
