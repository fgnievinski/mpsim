function [std, dof, dof_original] = smoothitudc_dof (std, dof_original)
%SMOOTHITUDC_DOF: Expand uncertainties to uniform probability level at different degree of freedom.

  dof = dof_original;
  if isempty(dof) || all(dof==1),  return;  end
  conf = 0.68;
  %prob = get_prob (conf, tail);  % WRONG!
  %prob = get_prob (conf, 'right');  % WRONG!
  prob = get_prob (conf, 'two');
  factor_expand = tinv(prob, dof);
  factor_contract = norminv(prob);
  factor = divide_all(factor_expand, factor_contract);
  std = times_all(std, factor);
  dof(:) = 1;
  
end  
