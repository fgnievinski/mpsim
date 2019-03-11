function char = logical2char (logical, char_true, char_false)
  if (nargin < 2),  char_true  = 'true';  end
  if (nargin < 3),  char_false = 'false';  end
  assert(isscalar(logical))
  if ~islogical(logical),  assert(any(logical == [0 1]));  end
  if logical,  char = char_true;  else  char = char_false;  end
end
