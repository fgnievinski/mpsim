function [out, idx] = zerononfinite (in)
    idx = ~isfinite(in);  % (NaN, Inf, etc)
    out = in;
    out(idx) = 0;
end

