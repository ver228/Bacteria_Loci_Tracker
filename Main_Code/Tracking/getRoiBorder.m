function Index=getRoiBorder(N,NPIXELS)
%get indexes (as logic subscripts) of the border around N pixels of a NPIXELS^2x1 array
%correspond to a NPIXELSxNPIXELS region (like the one produced by the
%function getroi2

TOT=NPIXELS^2;
Index=false(1,TOT);
ori=round(TOT/2);

for i=-N:N
    newPos=ori+N+i*NPIXELS;
    Index(newPos)=true;
    newNeg=ori-N+i*NPIXELS;
    Index(newNeg)=true;
    if i==-N || i==N
        Index(newNeg:newPos)=true;
    end
end
