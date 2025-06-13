function out = mat2cellrow (in)
  out = mat2cell(in, ones(1,size(in,1)));
end
