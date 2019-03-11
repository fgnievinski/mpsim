function answer = get_rotation_matrix_local (varargin)
    answer = get_rot_neu2xyz2neu(get_rotation_matrix(varargin{:}));
end

%!#test
%! % get_rotation_matrix_local()
%! test('get_rot_neu2xyz2neu')

%!test
%! answer1 = cart2sph_local((get_rotation_matrix_local(3,  90) * sph2cart_local([45,  0, 1])')'),  myassert(answer1, [45,  90, 1], -sqrt(eps()))
%! answer2 = cart2sph_local((get_rotation_matrix_local(3, -90) * sph2cart_local([45,  0, 1])')'),  myassert(answer2, [45, -90, 1], -sqrt(eps()))
%! answer3 = cart2sph_local((get_rotation_matrix_local(3,  90) * sph2cart_local([45, 90, 1])')'),  myassert(answer3, [45, 180, 1], -sqrt(eps()))
%! answer4 = cart2sph_local((get_rotation_matrix_local(3, -90) * sph2cart_local([45, 90, 1])')'),  myassert(answer4, [45,   0, 1], -sqrt(eps()))
%! answer5 = cart2sph_local((get_rotation_matrix_local(3,  90) * sph2cart_local([45, 45, 1])')'),  myassert(answer5, [45, 135, 1], -sqrt(eps()))
%! answer6 = cart2sph_local((get_rotation_matrix_local(3, -90) * sph2cart_local([45, 45, 1])')'),  myassert(answer6, [45, -45, 1], -sqrt(eps()))

