function out = mat2cellcol (in)
  %out = transpose(cellfun2(@transpose, mat2cellrow(in')));
  [m,n] = size(in);
  rowDist = m;
  colDist = ones([1 n]);
  out = mat2cell(in, rowDist, colDist);
end
