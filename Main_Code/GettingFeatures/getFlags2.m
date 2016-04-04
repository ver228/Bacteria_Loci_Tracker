function flags = getFlags2(fileData, collectIndex)
TOT = numel(collectIndex);

flags.type = fileData.type(collectIndex);

flags.isCAA = flags.type == 1;
flags.isGlu = flags.type == 2;
flags.isGly = flags.type == 3;
flags.isFix = flags.type == 4;

flags.isAfter = false(1,TOT);
flags.ND = zeros(1,TOT);
flags.isEMgain = false(1,TOT);


for fp = 1:TOT
    SSSS = collectIndex(fp);
    flags.isAfter(fp)=~isempty(regexp(fileData.name{SSSS},'After','ONCE')); 
    
    
    dumS=fileData.extraInfo{SSSS};
    if ~isempty(dumS)
        ii=regexpi(dumS,'ND','ONCE');
        
        dd = dumS((ii+2):end);
        
        mm = find(dd=='_',1);
        if ~isempty(mm)
            dd = dd(1:(mm-1));
        end
        
        flags.ND(fp)=str2double(dd);
        
        ii=regexpi(dumS,'NoEM','ONCE');
        flags.isEMgain(fp)=isempty(ii);
    end
end