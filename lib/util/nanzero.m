function out = nanzero (in)
    idx = (in == 0);
    out = in;
    out(idx) = NaN;
end

