function out = nanunique (in)
  in(isnan(in)) = [];
  out = unique(in);
end
