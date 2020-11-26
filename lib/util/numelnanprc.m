function out = numelnanprc (in)
% returns the percentage of nans
  dim = finddim(in);
  numnan = sum(~isnan(in), dim);
  numel  = size(in, dim);
  out = 100*numnan./numel;
end