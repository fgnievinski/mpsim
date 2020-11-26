function c = nancorrcoefscalar_all (x, y)
  nx = size(x,2);
  ny = size(y,2);
  assert(nx==ny)
  c = NaN(1,nx);
  for j=1:nx
    c(j) = nancorrcoefscalar(x(:,j), y(:,j));
  end
end

