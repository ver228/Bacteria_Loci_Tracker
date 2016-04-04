function showTracks_label(imList, positionsx,positionsy,min_dedrift_time)
if isempty(positionsx)
    return
end
ini = 0;
while ini<size(positionsx)
    ini = ini+1;
    if sum(nnz(positionsx(ini,:)))~=0
        break;
    end
end
        
figure,
if ~isempty(imList)
    I=imread(imList{ini});
    imshow(I,[])
end
hold on,
for i=1:size(positionsx,2)
    posX=nonzeros(positionsx(:,i));
    if numel(posX)>=min_dedrift_time
        posY=nonzeros(positionsy(:,i));
        plot(posX,posY)
        %text(posX(1),posY(1),num2str(i),'color','r','fontsize',8)
    end
end