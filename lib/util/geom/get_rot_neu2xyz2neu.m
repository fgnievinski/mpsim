function R_neu = get_rot_neu2xyz2neu (R_xyz)
    R_same  = eye(3,3);
    R_cross = R_same([2;1;3],:);
    R_neu2xyz = R_cross;
    R_xyz2neu = R_cross;
    if (size(R_xyz,3) == 1)
        R_neu = R_xyz2neu * R_xyz * R_neu2xyz;
    else
        R_neu = frontal_mtimes(R_xyz2neu, frontal_mtimes(R_xyz, R_neu2xyz));
    end
end

%!test
%! R_xyz = rand(3,3);
%! pos_neu = rand(1,3);
%! pos_xyz = neu2xyz(pos_neu);
%! pos2_xyz = (R_xyz * pos_xyz')';
%! pos2_neu = xyz2neu(pos2_xyz);
%! R_neu = get_rot_neu2xyz2neu (R_xyz);
%! pos2b_neu = (R_neu * pos_neu')';
%! %[pos2_neu; pos2b_neu; pos2b_neu-pos2_neu]  % DEBUG
%! %R_xyz, R_neu  % DEBUG
%! myassert(pos2b_neu, pos2_neu, -sqrt(eps()))

