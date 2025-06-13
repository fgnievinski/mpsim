function c = minus_all (a, b)
    c = bsxfun(@minus, a, b);
    %c = plus_all (a, -b);  % takes twice as much memory.
end

