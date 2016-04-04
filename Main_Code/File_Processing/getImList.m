function imList=getImList(imDir)
if iscell(imDir)
    imDir=char(imDir);
end

%Get file list in directory form
dum=dir(fullfile(imDir, '*.tif'));
imList=cell(1,numel(dum));

fileNN = zeros(size(dum));
for k = 1:numel(fileNN)
    
    ii = find(dum(k).name=='.',1, 'last');
    jj = find(dum(k).name>='0' & dum(k).name<='9',1);
    fileNN(k) = str2double(dum(k).name(jj:(ii-1)));
end
[~,fileII] = sort(fileNN);
fileII(isnan(fileII)) = [];
for i=1:numel(fileII)
   imList{i}=fullfile(imDir, dum(fileII(i)).name);
end
