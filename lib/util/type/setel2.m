function out = setel2 (in, idx, val2)
    if ischar(idx)
        eval(['val = val2(' idx ');']);
    elseif iscell(idx)
        s = struct();
        s.type = '()';
        s.subs = idx;
        val = subsref(val2, s);
    else
        val = val2(idx);
    end
    out = setel (in, idx, val);
end
