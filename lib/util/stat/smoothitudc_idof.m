function idof = smoothitudc_idof (time, dof, itime, inum, dt, idof_method, ignore_self)
%SMOOTHITUDC_IDOF  Degree-of-freedom for running average (smoothitud).

  if (idof_method==0),  idof = [];  return;  end
  if isscalar(dof)
    idof_avg = dof;
    idof_sum = inum * dof;
  else
    [idof_sum, idof_avg] = smoothit (time, dof, dt, itime, {@nansum, @nanmean}, [], [], ignore_self);
  end
  if isempty(idof_method),  idof_method = 1;  end
  if all(dof == 1),  idof_method = 3;  end
  
  switch idof_method
  % result of 'low' is based on the number of observations contained in each moving window
  % the result of 'mid' is based on the input DOF for each observation, as a result of its own averaging.
  % the result of 'high' is based on the multiplication of the two above.
  case {'low','lo',2},   idof = inum     - 1;  % = idof_sum ./ idof_avg - 1;  
  case {'mid',1},        idof = idof_avg - 1;  % = idof_sum ./ inum - 1
  case {'high','hi',3},  idof = idof_sum - 1;
  otherwise,  error('smoothitdc:badDofMeth', 'Bad dof_method "%s".', idof_method);
  end
end
