function [out, idx] = zeronan (in)
    idx = isnan(in);
    out = in;
    out(idx) = 0;
end

