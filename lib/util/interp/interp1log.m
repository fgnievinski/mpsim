function yi = interp1log (x, y, xi, method, extrapval, interp1which)
  if (nargin < 4) || isempty(method),  method = 'linear';  end
  if (nargin < 5) || isempty(extrapval)
    extrapval = 'extrap';  % see doc interp1
    if any(strend({'nearest','linear','v5cubic'}, method)),  extrapval = NaN;  end
  end
  %interp1default = @interp1;
  interp1default = @naninterp1;  % safer
  if (nargin < 6) || isempty(interp1which),  interp1which = interp1default;  end  
  
  if ~strstart('log', method)
    yi = interp1which(x, y, xi, method, extrapval);
    return;
  end  
  
  method(1:3) = [];
  yi = exp(interp1which(x, log(y), xi, method, extrapval));
end
