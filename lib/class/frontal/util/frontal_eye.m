function answer = frontal_eye (n, num_pts)
    answer = repmat(eye(n), [1,1,num_pts]);
end

%!test
%! myassert(eye(3), frontal_eye(3, 1));

