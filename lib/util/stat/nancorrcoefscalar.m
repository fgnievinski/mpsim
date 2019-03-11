function c = nancorrcoefscalar (x, y)
  idx = isnan(x) | isnan(y);
  c = corrcoefscalar(x(~idx), y(~idx));
end

