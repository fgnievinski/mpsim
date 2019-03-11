function out = getlim (in)
  assert(isvector(in))
  out = [min(in), max(in)];
end
