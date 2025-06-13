function std = cov2std (cov)
  std = defrontal_pt(frontal_transpose(frontal_cov2std(cov)));
end  

