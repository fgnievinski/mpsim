function varargout = nanpolyfit (x, y, n)
    if isnan(n),  varargout(1:max(1,nargout)) = {[]};  return;  end
    idx = isnan(x) | isnan(y);
    if (sum(~idx) < (n+1)) && (nargout <= 1)
        varargout = {NaN(1,n+1)};
        return
    end
    x(idx) = [];
    y(idx) = [];
    [varargout{1:nargout}] = polyfit(x, y, n);
end