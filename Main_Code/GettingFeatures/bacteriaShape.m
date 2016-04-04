function [XX YY POL]=bacteriaShape(AA,pix_step)
L=AA(1);
W=AA(2);
ang=-AA(3);
CMx=AA(4);
CMy=AA(5);

if nargin == 1
    pix_step=1;
end



dum=ceil(W*pi/2/pix_step);
stepAng=linspace(-90, 90, dum);

rr=W/2;
ll=(L-W)/2;
xr=rr*cosd(stepAng)+ll;
yr=rr*sind(stepAng);

stepLin=ceil((L-W)/pix_step);
xl=linspace(ll,-ll,stepLin);
yl=ones(size(xl))*rr;

xx=[xr xl -xr(end:-1:1) xl(end:-1:1)];
yy=[yr yl yr(end:-1:1) -yl];


R=[ cosd(ang) -sind(ang); sind(ang) cosd(ang)];
linF=R*[xx;yy];
XX=linF(1,:)+CMx;
YY=linF(2,:)+CMy;
if nargout ==3
    POL=[true(size(yr)),false(size(yl))];
    POL=[POL POL];
end