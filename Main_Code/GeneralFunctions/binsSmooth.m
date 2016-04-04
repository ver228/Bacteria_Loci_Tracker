function [meanData, dataS, bins]=binsSmooth(dataX,dataY,bins, minParticles)

if nargin==2 || isempty(bins) 
    bins = linspace(min(dataX),max(dataX),25);
end

if nargin == 3 || isempty(minParticles)
    minParticles = 10;
end

if numel(bins) == 1
    bins = linspace(min(dataX),max(dataX),bins);
end

meanData.X=nan(size(bins));
meanData.Y=nan(size(bins));
meanData.STD=nan(size(bins));
meanData.N = zeros(size(bins));

dataS = [];
dataS.X = {};
dataS.Y = {};
dataS.index = [];

if isempty(dataX) || isempty(dataY)
    disp('Data not valid');
    return;
end
index=zeros(size(dataX));
for i=1:numel(dataX)
    delta=abs(dataX(i)-bins);
    if ~isnan(delta)
        [~, index(i)]=min(delta);
    else
        index(i) = 0;
    end
end
%{
dum1=repmat(dataX,1,numel(bins));
dum2=repmat(bins,numel(dataX),1);    
delta=abs(dum1-dum2);
[trash index]=min(delta,[],2);
%}

dataS.index = index;
for i=1:numel(bins)
    dataS.X{i} = dataX(index==i);
    dataS.Y{i} = dataY(index==i);
    if numel(dataS.Y{i}) >= minParticles
        in = ~(isnan(dataS.X{i})|isnan(dataS.Y{i}));
        meanData.X(i) = mean(dataS.X{i}(in));
        meanData.Y(i) = mean(dataS.Y{i}(in));
        meanData.STD(i) = std(dataS.Y{i}(in));
        meanData.N(i) = sum(in);
    end
end

