function yi = interp1nonemptynorscalar (x, Y, xi, interp_method, extrapval)
    if isempty(Y) || isscalar(Y),  yi = Y;  return;  end
  %interp1default = @interp1;
  interp1default = @naninterp1;  % safer
    try
      yi = interp1default(x, Y, xi, interp_method, extrapval);
    catch err
      if ~strcmpi(err.identifier, 'MATLAB:chckxy:NotEnoughPts'),  rethrow(err);  end
      yi = NaN(size(xi));
      return
    end
end
