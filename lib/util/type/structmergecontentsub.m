function out = structmergecontentsub (in, dim, F)
  if isempty(in),  out = in;  return;  end
  if (nargin < 2),  dim = [];  end
  if (nargin < 3),  F = [];  end
  if isempty(F) && (isempty(in) || isscalar(in)),  out = in;  return;  end
  arg = {dim, F};
  fn1 = fieldnames(in);
  idx = structfun(@isstruct, in(1));
  fn1a = fn1( idx);
  fn1b = fn1(~idx);
  out = getfields(in, fn1b);
  for i=1:numel(fn1a)
    %disp(fn1a{i})  % DEBUG
    out.(fn1a{i}) = structmergecontent(arg, in.(fn1a{i}));
  end
end

