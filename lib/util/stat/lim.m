function out = lim (in)
  assert(isvector(in))
  out = [min(in), max(in)];
end
