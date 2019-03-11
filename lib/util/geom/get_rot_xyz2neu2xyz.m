function R_xyz = get_rot_xyz2neu2xyz (R_neu)
    R_xyz = get_rot_neu2xyz2neu (R_neu);
end

%!test
%! R_neu = rand(3,3);
%! pos_xyz = rand(1,3);
%! pos_neu = xyz2neu(pos_xyz);
%! pos2_neu = (R_neu * pos_neu')';
%! pos2_xyz = neu2xyz(pos2_neu);
%! R_xyz = get_rot_xyz2neu2xyz (R_neu);
%! pos2b_xyz = (R_xyz * pos_xyz')';
%! %[pos2_xyz; pos2b_xyz; pos2b_xyz-pos2_xyz]  % DEBUG
%! myassert(pos2b_xyz, pos2_xyz, -sqrt(eps()))

