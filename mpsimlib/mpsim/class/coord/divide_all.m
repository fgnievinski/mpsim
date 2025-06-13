function c = divide_all (a, b)
    c = bsxfun(@rdivide, a, b);
    %c = times_all (a, 1./b);  % more memory intensive.
end

