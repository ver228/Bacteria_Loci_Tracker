function axisR = segCorrection_helper(dIR, dat, oriAxis, intLim)
r2 = ceil(oriAxis/2);
binR = -r2:r2;

axisR = 0;
[Av,~,~] = binsSmooth(dIR,dat, binR, 2);
if isempty(Av.Y)
    return; 
end
while isnan(Av.Y(1)), 
    Av.Y(1) = [];
    if isempty(Av.Y), return; end
end
while isnan(Av.Y(end)), 
    Av.Y(end) = [];
end



in = ~(Av.Y>intLim|isnan(Av.Y));
ini = find(in,1);
fin = find(in,1, 'last');
    
if isempty(ini)||isempty(fin)
    axisR = 0;
else
    %
    if fin<numel(Av.Y)
        m = diff(Av.Y(fin+(0:1)));
        b = intLim - Av.Y(fin);
        fin = fin + b/m;
    else
        dum = Av.Y(fin+[0 -1 -2]);
        if any(dum(2:3)>dum(1))
            [~,co] = max(dum);
            fin = fin-(co-1);
        end
    end
    if ini>1
        m = diff(Av.Y(ini+([0 -1])));
        b = intLim - Av.Y(ini);
        ini = ini + b/m;
    else
        dum = Av.Y(ini+(0:2));
        if any(dum(2:3)>dum(1))
            [~,co] = max(dum);
            ini = ini+co-1;
        end
    end
    %}
    axisR = fin-ini+1;
end