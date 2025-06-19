function [out, idx] = nannonfinite (in)
    idx = ~isfinite(in);
    out = in;
    out(idx) = NaN;
end

