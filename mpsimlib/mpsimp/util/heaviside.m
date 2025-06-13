function Y = heaviside (X)
    Y = false(size(X));
    Y(X > 0) = true;
end
