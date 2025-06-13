function out = isrealval (in)
  out = ~imag(in);  %= (imag(in) ~= 0);
end
