function out = setel (in, idx, val)
    out = in;
    if ischar(idx)
        eval(['out(' idx ') = val;']);
    elseif iscell(idx)
        s = struct();
        s.type = '()';
        s.subs = idx;
        out = subsasgn(in, s, val);
    else
        out(idx) = val;
    end
end
