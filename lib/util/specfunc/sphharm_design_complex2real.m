function J_real = sphharm_design_complex2real (J_complex)
    J_real = interleave(real(J_complex), imag(J_complex), 2);
    J_real(:,2) = [];  % mean value is real-valued
    J_real(:,3) = [];  % degree/order 0,1 has no longitude dependence
end
