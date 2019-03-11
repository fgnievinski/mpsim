% (this is just a interface for legacy code)
function perm = permittivity_soil_eval (moisture, type, interp_method)
  if (nargin < 2),  type = [];  end
  if (nargin < 3),  interp_method = [];  end
  temp = struct('name','soil', 'moisture',moisture, 'type',type, 'interp_method',interp_method);
  perm = get_permittivity(temp);
  perm = reshape(perm, size(moisture));
end

