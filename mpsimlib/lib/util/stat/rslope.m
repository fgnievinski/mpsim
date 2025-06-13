function s = rslope (x, y)
%RSLOPE: Robust slope estimator.

    if isempty(x),  s = NaN;  return;  end
    s = Theil_Sen_Regress (x, y);
end

