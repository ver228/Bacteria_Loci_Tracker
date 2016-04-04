function [roiInd outLim]=getroi2(pos,NPIXELS,IMSIZE)
%Get the index a region of NPIXELS centered on the coodinate given by pos
%IMSIZE, is the size of the image
%pos should be a Nx2 containing the coordinates of the center of the roi.
%outLim contains the data in pos, that is out of the image limits
%roiInd contains the index in an array of NPIXELS^2 x (size(pos,1)-numel(outLim))

BASICLIM=-floor(NPIXELS/2):floor(NPIXELS/2);
TOTALPIXELS=NPIXELS^2;
if size(pos,2)~=2
    pos=pos';
end



TOTALDOTS=size(pos,1);


dumX=repmat(BASICLIM,TOTALDOTS,NPIXELS);
dumY=repmat(BASICLIM,NPIXELS,1);
dumY=reshape(dumY,1,[]);
dumY=repmat(dumY,TOTALDOTS,1);
dumX=dumX+repmat(pos(:,2),1,TOTALPIXELS);
dumY=dumY+repmat(pos(:,1),1,TOTALPIXELS);

outLim=any(dumX>IMSIZE(2)|dumX<1|dumY>IMSIZE(1)|dumY<1,2);

dumX(outLim,:)=[];
dumY(outLim,:)=[];
roiInd=sub2ind(IMSIZE,dumY,dumX);