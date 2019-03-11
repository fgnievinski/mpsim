function [rot, dir_nrml, dz_dx, dz_dy] = get_rotation_matrix3_local (slope, aspect, axial)
    if (nargin < 3) || isempty(axial),  axial = 0;  end
    
    [dz_dx, dz_dy, dir_nrml] = slopeaspect2horizgrad (slope, aspect);

    %rotb = get_rotation_matrix2_local([0 0 1], dir_nrml.cart);  % WRONG!
    rotb = get_rotation_matrix5_local (dir_nrml);
    
    if all(axial == 0),  rot = rotb;  return;  end
    
    %temp = axial;  % WRONG
    temp = -axial;
    %rota = get_rotation_matrix(3, temp);  % WRONG!
    rota = get_rotation_matrix_local(3, temp);
    %rota = eye(3);  % DEBUG

    %rot = frontal_mtimes(rotb, rota);  % WRONG!
    rot = frontal_mtimes(rota, rotb);  % axial rotation last.
end      

%test('snr_fwd_direction_local2')

%!test
%! % horizontal surface was having a problem which traced all the way back to cart2sph_local.
%! R = get_rotation_matrix3_local(0, 0, 0);
%! myassert(R, eye(3), -sqrt(eps()))

