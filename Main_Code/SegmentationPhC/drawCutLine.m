function varargout = drawCutLine(xx, yy, imSize)
dx = xx(1)-xx(2);
dy = yy(1)-yy(2);
cmx = mean(xx);
cmy = mean(yy);

if abs(dx)>abs(dy)
    M = dy/dx;
    limR = round(abs(dx)/2+1);
    vv = -limR:limR;
    xxL = round(vv + cmx);
    yyL = round(M*vv +cmy);
else
    M = dx/dy;
    limR = round(abs(dy)/2+1);
    vv = -limR:limR;
    yyL = round(vv + cmy);
    xxL = round(M*vv +cmx);
end
out = xxL<=0|yyL<=0|xxL>imSize(1)|yyL>imSize(2);
xxL(out) = [];
yyL(out) = [];

if nargout == 2
    varargout{1} = xxL;
    varargout{2} = yyL;
else
    varargout{1} = sub2ind(imSize, xxL, yyL);
end