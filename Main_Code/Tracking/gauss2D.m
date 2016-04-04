function zInt=gauss2D(coeff,TOTALPIX)
if nargin ==1
    J=[-2    -1     0     1     2    -2    -1     0     1     2  ...
        -2    -1     0     1     2    -2    -1     0     1   2 ...
        -2    -1     0     1     2];
    I=[-2    -2    -2    -2    -2    -1    -1    -1    -1    -1 ...
        0     0     0     0     0   1     1     1     1     1 ...
        2     2     2     2     2];
else
    I=repmat(-floor(TOTALPIX/2):floor(TOTALPIX/2),TOTALPIX,[]);
    J=I';
    I=reshape(I,1,[]);
    J=reshape(J,1,[]);
end

if numel(coeff)==5
    zInt=coeff(1).*exp(-((I-coeff(3)).^2+(J-coeff(4)).^2)./(2*coeff(2)^2))+coeff(5);
else
    zInt=coeff(1).*exp(-((I-coeff(3)).^2+(J-coeff(4)).^2)./(2*coeff(2)^2));
end




