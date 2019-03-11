function idof = smoothitudc_idof (time, dof, itime, inum, dt, idof_method, ignore_self)
%SMOOTHITUDC_IDOF  Interpolation of degree-of-freedom for smooothitudc.

  if (idof_method==0),  idof = [];  return;  end
  if isscalar(dof)
    idof_sum = inum * dof;
  else
    [idof_sum, idof_avg] = smoothit (time, dof, dt, itime, {@nansum, @nanmean}, [], [], ignore_self);
  end
  if isempty(idof_method),  idof_method = 1;  end
  if all(dof == 1),  idof_method = 3;  end
  
  switch idof_method
  case {'low', 2},  idof = idof_sum ./ idof_avg - 1;
  case {'mid', 1},  idof = idof_sum ./ inum - 1;  % = idof_avg - 1;
  case {'hi',  3},  idof = idof_sum - 1;
  otherwise,  error('smoothitdc:badDofMeth', 'Bad dof_method "%s".', idof_method);
  end
end
