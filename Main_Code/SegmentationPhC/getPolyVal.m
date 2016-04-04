function X = getPolyVal(imSize, Kth)

tot=1;
NN=(Kth+1)*(Kth+2)/2;
CC=zeros(2,NN);
for k = 0:Kth
    for j = 0:k
        CC(1,tot)=k-j;
        CC(2,tot)=j;
        tot = tot+1;
    end
end

X = zeros(imSize(1)*imSize(2),NN);

tot = 1;
for i = 1:imSize(1)
    for j = 1:imSize(2)
        for n = 1:NN
            X(tot,n) = i^CC(1,n)*j^CC(2,n);
        end
        tot = tot+1;
    end
end
