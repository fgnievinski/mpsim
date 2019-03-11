function out = colvec (in, nonvec)
  if (nargin < 2) || isempty(nonvec),  nonvec = 'ignore';  end
  if islogical(nonvec),  nonvec = iif(@() nonvec, 'ignore', 'error');  end
  if ~myisvector(in) && ~isscalar(in) && ~isempty(in)
    switch nonvec
    case 'ignore',  out = in;  return;
    case 'error',  error('MATLAB:colvec:nonVec', 'Non-vector input.');
    case 'force',  % do nothing special.
    otherwise,  error('MATLAB:colvec:unkOpe', 'Unknown option "%s".', nonvec);
    end
  end
  out = in(:);
end

function out = myisvector (in)
    out = isvector(in) || isvector(squeeze(in));
end
