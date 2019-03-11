function dim = finddim (x)
  dim = find(size(x) ~= 1, 1);
  if isempty(dim), dim = 1; end
end
