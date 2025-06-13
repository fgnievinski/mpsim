function z = plane_eval (pos_pt, pos_plane, third_arg)
    switch numel(third_arg)
    case 2
        z = plane_eval2 (pos_pt, pos_plane, third_arg);
    case 3
        z = plane_eval3 (pos_pt, pos_plane, third_arg);
    %otherwise
    end
end

function z = plane_eval2 (pos_pt, pos_plane, vec_zgrad)
    z = pos_plane(3) ...
        + vec_zgrad(1) .* (pos_pt(:,1) - pos_plane(1)) ...
        + vec_zgrad(2) .* (pos_pt(:,2) - pos_plane(2));
end

function z = plane_eval3 (pos_pt, pos_plane, dir_plane)
    z = pos_plane(3) - (1/dir_plane(3)) .* (...
        dir_plane(1) .* (pos_pt(:,1) - pos_plane(1)) + ...
        dir_plane(2) .* (pos_pt(:,2) - pos_plane(2))   ...
    );
end

%!shared
%! n = ceil(10*rand);
%! %n = 100;
%! pos_pt = rand(n,3);
%! pos_plane = rand(1,3);

%!test
%! % trivial case: horizontal plane.
%! dir_plane = [0,0,1];
%! z = repmat(pos_plane(:,3), n, 1);
%! z2 = plane_eval (pos_pt, pos_plane, dir_plane);
%! %[z, z2, z2 - z]  % DEBUG
%! myassert(z2, z, eps)  

%!test
%! % check that plane-evaluated points really are contained in the plane.
%! dir_plane = normalize_pt(rand(1,3));
%! pos_plane = 10 * rand(1,3);
%! pos_pt(:,3) = plane_eval (pos_pt, pos_plane, dir_plane);
%! temp = dot_all(minus_all(pos_pt, pos_plane), dir_plane);
%! %temp, max(abs(temp))  % DEBUG
%! myassert(temp, 0, -10*eps)  

