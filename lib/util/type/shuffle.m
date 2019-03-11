function out = shuffle (in)
  up = is_upper(in);
  lo = ~up;
  out = in;
  out(up) = lower(in(up));
  out(lo) = upper(in(lo));
end
