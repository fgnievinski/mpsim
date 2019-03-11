function [pv_list, pv_array] = struct2pv (s)
  p = fieldnames(s);
  v = struct2cell(s);
  pv_array = [p, v];
  pv_list = reshape(pv_array', [],1)';
end
