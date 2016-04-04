function datAv = calculate_datAv(datAv,timeAv, fp, minTrackLength, strFields)
for nf = 1:numel(strFields)
    for tt = 1:minTrackLength
        yy = timeAv.(strFields{nf})(tt,:);
        out = isnan(yy);
        yy(out) = [];
        
        datAv.mean.(strFields{nf})(tt,fp) = mean(yy);
        
        yy(yy<0) = [];
        datAv.geoM.(strFields{nf})(tt,fp) = geomean(yy);
        
        %{
        out = isnan(err);
        yy(out) = [];
        err(out) = [];
        %weighted average
        sig = (1+ err./yy);
        factor = sum(1./sig);
        datAv.geoMW.(strFields{nf})(tt,fp) = exp(sum(log(yy)./sig)./factor);
        %}
    end
end
