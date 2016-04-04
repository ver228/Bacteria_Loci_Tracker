function dots = find_peaks_diffsub_av(SET)
%% Initialize parameters
imList=getImList(SET.imageDir);

if isempty(SET.numImagesRaw), 
    TOT_FRAMES = floor(numel(imList)/SET.integWindow); 
end

if SET.numImagesRaw < SET.integWindow
    error('Not enough images to make the frame average');
end


dots = cell(1,TOT_FRAMES);

for frame = 1:TOT_FRAMES
    fprintf('Analysing frame %i of %i ...\n', frame, TOT_FRAMES); 
    
    nDat = (frame-1)*SET.integWindow+1;
    Im = double(imread(imList{nDat}));
    for kk = 2:SET.integWindow
        Im = Im + double(imread(imList{nDat-1+kk}));
    end
    
    if SET.isMask == true && isempty(SET.MASKCELL)
        imF = fspecial('gaussian',35,10);
        Ibg = filter2(imF,Im);
        thresh = otsuThreshold(Ibg,1000);
        SET.MASKCELL = Im > thresh;
        SET.MASKCELL = bwareaopen(SET.MASKCELL,25);
        SET.MASKCELL = bwmorph(SET.MASKCELL,'dilate',3);
        SET.MASKCELL = bwfill(SET.MASKCELL, 'holes');
        
        %{
            % CHECK THAT SIGNAL IS AT LEAST ONE STD, AVOID GETTING NOISE
            A = mean(Im(SET.MASKCELL));
            [C D] = robustMean2(Im(~SET.MASKCELL));
            if A < C+D
                SET.MASKCELL = nan;
                fprintf('INVALID MOVIE\n');
                dots={};
                return;
            end
        %}
    end
    
    %dat = posible_peaksBG(Im, SET.MASKCELL, SET);
    dat = posible_peaks(Im, SET);
    
    %% get subpixel resolution
    [dots{frame} , ~] = getSubPix2(Im, dat, SET);
    
    %{
    fprintf('Number of dots found: %i\n', dots{frame}.num);
    if dots{frame}.num == 0
        emptyFrames = emptyFrames+1;
        if emptyFrames>SET.EMPTY_ALLOWED
            dots((frame+1):end)=[];
            dots{frame}=[];
            return;
        end
    end
    %}
end  


