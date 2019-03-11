function S = num2struct (A, fields, dim)
  if (nargin < 3) || isempty(dim),  dim = finddim(A);  end
  S = cell2struct(num2cell(A), fields, dim);
end
