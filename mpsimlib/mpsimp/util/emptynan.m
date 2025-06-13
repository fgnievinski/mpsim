function [out, idx] = emptynan (in)
    idx = isnan(in);
    out = in;
    out(idx) = [];
end

