function out = rowvec (varargin)
  temp = colvec(varargin{:});
  %out = temp';  % WRONG!
  %out = temp.';  don't complex-conjgate.
  out = transpose(temp);  % clearer, safer.
end