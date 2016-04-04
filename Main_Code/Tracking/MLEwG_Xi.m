function X2 = MLEwG_Xi(coeff,signal)
N=numel(signal);
if N==25
    E = gauss2D(coeff);
else
    E = gauss2D(coeff,sqrt(N));
end
X2 = sum(E) - sum(signal.*log(E));
