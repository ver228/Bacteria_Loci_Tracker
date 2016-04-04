function [shapeAll, shapeIndCell] = ...
    getShapeAll(trackID, datadir, del_pix, postFixStr, findOrder, progressTextStr)

shapeAll = extract_ShapePropsMSD(trackID, datadir, ...
    del_pix,  progressTextStr, postFixStr,findOrder);

shapeIndCell = extract_ShapePropsCell(trackID, datadir, ...
    del_pix,  progressTextStr, postFixStr);

if ~isempty(shapeAll)
    strShapeAll = fieldnames(shapeAll);
    strShapeIndCell = fieldnames(shapeIndCell);
    
    % remove outliers in width
    MM = median(shapeIndCell.width);
    MAD = median(abs(shapeIndCell.width-MM));
    width_thresh = [MM MM-5*MAD MM+5*MAD];
    
    out = shapeAll.width>width_thresh(3) | shapeAll.width<width_thresh(2);
    for ii = 1:numel(strShapeAll), shapeAll.(strShapeAll{ii})(out) = nan; end
    
    out = shapeIndCell.width>width_thresh(3) | shapeIndCell.width<width_thresh(2);
    NNi = sum(out);
    for ii = 1:numel(strShapeIndCell),
        if iscell(shapeIndCell.(strShapeIndCell{ii}))
            shapeIndCell.(strShapeIndCell{ii})(out) = cell(1,NNi);
        else
            shapeIndCell.(strShapeIndCell{ii})(out) = nan;
        end
    end
    %%
    shapeIndCell.indMSD = addIndShape(shapeIndCell, shapeAll, trackID);
end