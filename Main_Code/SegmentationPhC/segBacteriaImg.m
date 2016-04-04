function [Iph, L, Ibg, shapeData] = segBacteriaImg(phc_file, SET_PhC, imDir)
%Segment phase contrast bacteria images.

if exist(phc_file, 'file')
    fprintf('Analyzing %s\n', phc_file)
    
    %% flat field correction and substraction of the background
    Iph = double(imread(phc_file));
    [bgnd, ~] = flat_field_correction(Iph, SET_PhC.polVal);
    Iph = Iph - bgnd;
    Iph = Iph - min(Iph(:));
    
    %% segment image
    [Ibg, Ibb] = segBasicSeg(Iph);
    
    Ibb = bwareaopen(Ibb,50,4);
    Ibb2 = segThin(Ibb);
    Ibb2 = bwareaopen(Ibb2,50,4);
    Ibb3 = segHoles(Ibb2);
    
    Ibb4 = segAngle(Ibb3);
    Ibb4 = bwareaopen(Ibb4,50,4);
    
    Ibb5 = segInt(Ibb4, Iph);
    L = bwlabel(Ibb5,4);
    shapeData = segCorrection(Iph, L);
    
    %use an average of the fluorescence images to count dots (avoid problems with drifiting)
    imList = getImList(imDir);
    frame2av = 15;
    Idot = [];
    for kk = 0:(frame2av-1)
        I = double(imread(imList{end-kk}));
        if isempty(Idot)
            Idot = I;
        else
            Idot = Idot + I;
        end
    end
    Idot = Idot/frame2av;
    [shapeData, ~] = FM_segCountDots(shapeData, Idot, L, SET_PhC);


    
end

