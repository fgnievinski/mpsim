function y = nancummax(x)
    y = cummax(x);
    y(isnan(x)) = NaN;
end
