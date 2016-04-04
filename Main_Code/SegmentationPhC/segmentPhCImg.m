function segmentBacImg(I, expodatadirS, expodatadirSR, SET_PhC)
[bgnd, ~] = flat_field_correction(I,polVal);
I = I - bgnd;
I = I - min(I(:));


for ll = 0:1
    strFM = [strFM_prefix, 'a'+ll];
    strPhC = [strPhC_prefix , 'a'+ll];
    nameStrFM = sprintf('%s%s_%i.tif', expodatadirS, strFM,SSSS);
    nameStrPhC = sprintf('%s%s_%i.tif', expodatadirS, strPhC, SSSS);
    
    if exist(nameStrPhC, 'file')
        fprintf('Analyzing %s_%i.tif\n', strPhC,SSSS)
        
        clear Idot
        Iph = double(imread(nameStrPhC));
        [Ibg,Ibb] = segBasicSeg(Iph);
        
        Ibb = bwareaopen(Ibb,50,4);
        Ibb2 = segThin(Ibb);
        Ibb2 = bwareaopen(Ibb2,50,4);
        Ibb3 = segHoles(Ibb2);
        
        Ibb4 = segAngle(Ibb3);
        Ibb4 = bwareaopen(Ibb4,50,4);
        
        Ibb5 = segInt(Ibb4, Iph);
        L = bwlabel(Ibb5,4);
        shapeData = segCorrection(Iph, L);
        
        if ll == 0
            [shapeData,Idot] = FM_segCountDots(shapeData, imDir, L, SET_PhC);
        elseif ll == 1
            %use the final images to count dots (avoid problems with drifiting)
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
            [shapeData,Idot] = FM_segCountDots(shapeData, Idot, L, SET_PhC);
        end
        
        rgbI = drawRGBfinal(Iph, shapeData, true);
        dum = sprintf('%sseg_%i_%s.bmp',expodatadirSR,SSSS, strPhC);
        imwrite(rgbI, dum,'BMP')
        
        dum = sprintf('%sseg_%i_%s.mat',expodatadirSR,SSSS, strPhC);
        save(dum, 'L','Ibg', 'shapeData')
        
        if exist(nameStrFM, 'file')
            fprintf('Analyzing %s_%i.tif\n', strFM,SSSS)
            Ifm = double(imread(nameStrFM));
            [props,L] = FM_segmentation(Ifm, Ibg);
            shapeData = props2shapeData(props);
            
            
            [shapeData,Idot] = FM_segCountDots(shapeData, Idot, L, SET_PhC);
            rgbI = drawRGBfinal(Ifm, shapeData, false);
            dum = sprintf('%sseg_%i_%s.bmp',expodatadirSR,SSSS, strFM);
            imwrite(rgbI, dum,'BMP')
            dum = sprintf('%sseg_%i_%s.mat',expodatadirSR,SSSS, strFM);
            save(dum, 'L','Ibg', 'shapeData')
        end
    end
end

