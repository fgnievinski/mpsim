function A = sphharmreal_design (pos_sph, n)
    A = sphharm_design (pos_sph, n);
    A = sphharm_design_complex2real (A);
end
