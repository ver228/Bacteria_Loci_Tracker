function [XX YY]=bacteriaShape2(AA)
%AA=[20 6 220 -1 1];
L = AA(1);
W = AA(2);
ang = -AA(3);
CMx = AA(4);
CMy = AA(5);

pix_step=1;


dum=ceil(W*pi/2/pix_step);
stepAng=linspace(-90, 90, dum);

rr=W/2;
ll=(L-W)/2;
xr=rr*cosd(stepAng)+ll;
yr=rr*sind(stepAng);

stepLin=ceil((L-W)/pix_step);
xl=linspace(ll,-ll,stepLin);
yl=ones(1,stepLin)*rr;

xx=[xr xl -xr(end:-1:1) xl(end:-1:1)];
yy=[yr yl yr(end:-1:1) -yl];


R=[ cosd(ang) -sind(ang); sind(ang) cosd(ang)];
linF=R*[xx;yy];
XX=linF(1,:)+CMx;
YY=linF(2,:)+CMy;

%{
plot(xx,yy,'r'),hold on
plot(XX,YY)
axis([-L L -L L])
%}

%ylim([-(rr+0.5) rr+0.5])

%{
M=tand(theta);
if theta>45&&theta<135
    M=1/M;
    CMx=AA(5);
    CMy=AA(4);
end

wCen(1,1)=(L-W)/(2*sqrt(M^2+1))+CMx;
wCen(1,2)=M*(wCen(1,1)-CMx)+CMy;
wCen(2,1)=-(L-W)/(2*sqrt(M^2+1))+CMx;
wCen(2,2)=M*(wCen(2,1)-CMx)+CMy;

wTan(1,1)=wCen(1,1) - M*(W/2)/sqrt(M^2+1);
wTan(1,2)=wCen(1,2) + (W/2)/sqrt(M^2+1);
wTan(2,1)=wCen(1,1)+M*(W/2)/sqrt(M^2+1);
wTan(2,2)=wCen(1,2)-(W/2)/sqrt(M^2+1);

wTan(3,1)=wCen(2,1) - M*(W/2)/sqrt(M^2+1);
wTan(3,2)=wCen(2,2) + (W/2)/sqrt(M^2+1);
wTan(4,1)=wCen(2,1)+M*(W/2)/sqrt(M^2+1);
wTan(4,2)=wCen(2,2)-(W/2)/sqrt(M^2+1);



XX=[];
YY=[];

%
xx=wTan(1,1):1:(wCen(1,1)+(W/2));
yy=sqrt((W/2)^2-(xx-wCen(1,1)).^2)+wCen(1,2);
XX=[XX,xx];
YY=[YY,yy];

xx=wTan(2,1):1:(wCen(1,1)+(W/2));
yy=-sqrt((W/2)^2-(xx-wCen(1,1)).^2)+wCen(1,2);
XX=[XX,xx];
YY=[YY,yy];

xx=(wCen(2,1)-(W/2)):1:wTan(3,1);
yy=sqrt((W/2)^2-(xx-wCen(2,1)).^2)+wCen(2,2);
XX=[XX,xx];
YY=[YY,yy];

xx=(wCen(2,1)-(W/2)):1:wTan(4,1);
yy=-sqrt((W/2)^2-(xx-wCen(2,1)).^2)+wCen(2,2);
XX=[XX,xx];
YY=[YY,yy];

XX=[XX,nan];
YY=[YY,nan];

xx=wTan(3,1):wTan(1,1);
yy=M*(xx-wTan(1,1))+wTan(1,2);
XX=[XX,xx];
YY=[YY,yy];

xx=wTan(4,1):wTan(2,1);
yy=M*(xx-wTan(4,1))+wTan(4,2);
XX=[XX,xx];
YY=[YY,yy];

YY=real(YY);

if theta>45&&theta<135
    dum=XX;
    XX=YY;
    YY=dum;
end

%}

%{
thet1=acosd((wTan(1,1)-wCen(1,1))/(W/2));
if wTan(1,2)-wCen(1,2)<0, thet1=-thet1; end
    
thet2=acosd((wTan(2,1)-wCen(1,1))/(W/2));
if wTan(2,2)-wCen(1,2)<0, thet2=-thet2; end

if thet1<thet2, thet=thet1:thet2; else thet=thet2:thet1; end

xx=(W/2)*cosd(thet)+wCen(1,1);
yy=(W/2)*sind(thet)+wCen(1,2);

plot(xx,yy,'.')

thet1=acosd((wTan(3,1)-wCen(2,1))/(W/2));
if wTan(3,2)-wCen(2,2)<0, thet1=360-thet1; end
    
thet2=acosd((wTan(4,1)-wCen(2,1))/(W/2));
if wTan(4,2)-wCen(2,2)<0, thet2=360-thet2; end

if thet1<thet2, thet=thet1:thet2; else thet=thet2:thet1; end

xx=(W/2)*cosd(thet)+wCen(2,1);
yy=(W/2)*sind(thet)+wCen(2,2);

plot(xx,yy,'.')
%}