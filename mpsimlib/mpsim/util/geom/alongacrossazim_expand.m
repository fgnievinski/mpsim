function [slope, aspect, azim, size_original] = alongacrossazim_expand (slope, aspect, azim)
  [slope, aspect, azim, size_original] = slopeaspectazim_expand (slope, aspect, azim);
end