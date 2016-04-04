function C_dyn = getAlphaDynErr(yy_real, tt_real, EXP_TIME)
C_dyn = nan(1,2);

good = yy_real>0;
if sum(good)/numel(good) <0.5, return, end

tt = tt_real./EXP_TIME;
dynErrFun = @(alpha,tt)(((tt+1).^(2+alpha)+(tt-1).^(2+alpha)-2*tt.^(2+alpha)-2)...
            ./ ((1+alpha).*(2+alpha)));
X2_all = @(C,tt, yy_real)(sum((log(yy_real) - log(C(2)*dynErrFun(C(1),tt))).^2));



X2 = @(C)(X2_all(C,tt(good),yy_real(good)));
C_dyn = fminsearch(X2, [0.4 1e-3]);
C_dyn(2) = C_dyn(2)/EXP_TIME^C_dyn(1);
            