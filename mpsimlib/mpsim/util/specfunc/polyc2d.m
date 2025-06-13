function [d, n] = polyc2d (c)
    n = numel(c);
    d = n - 1;
    if (d < 0),  d = NaN;  end
end

