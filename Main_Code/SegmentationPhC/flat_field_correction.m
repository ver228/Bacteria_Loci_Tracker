function [bgnd, pp] = flat_field_correction(I,X)
imSize = size(I);

if nargin == 1
    X = 6;
end

if numel(X) == 1    
    X = getPolyVal(imSize, X);
end

if size(X,1) ~= numel(I)
    error('Invalid X matrix')
end

g = double(I(:));


aa = X'*X;

pp = aa\X'*g;

bgnd = X*pp;
bgnd = reshape(bgnd,imSize(1),[]);