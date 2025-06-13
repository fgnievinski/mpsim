function out = nanempty (in)
    if isempty(in)
        out = NaN;
    else
        out = in;
    end
end

