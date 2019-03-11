function c = frontal_mtimes_pt (A, b)
    b = frontal_pt(b);
    c = frontal_transpose(frontal_mtimes(A, frontal_transpose(b)));
    c = defrontal_pt(c);
end

% function c = frontal_mtimes_pt (A, b)
%     A = frontal(A);
%     b = frontal(b, 'pt');
%     %c = (A * b')';  % WRONG!
%     c = (A * b.').';
%     c = defrontal(c, 'pt');
% end

%!test
%! A = rand(3,3);
%! b = rand(1,3);
%! c = (A*b')';
%! c2 = frontal_mtimes_pt (A, b);
%! myassert(c2, c)

%!test
%! % NaNs in input:
%! A = rand(3,3);
%! b = rand(2,3);
%! b(1) = NaN;
%! c = (A*b')';
%! c2 = frontal_mtimes_pt (A, b);
%! %c, c2  % DEBUG
%! myassert(c2, c)

%!test
%! % NaNs in input:
%! A = rand(3,3,2);
%! A(1,1,1) = NaN;
%! b = rand(2,3);
%! for i=1:size(A,3)
%!     c(i,:) = (A(:,:,i)*b(i,:)')';
%! end
%! c2 = frontal_mtimes_pt (A, b);
%! %c, c2  % DEBUG
%! myassert(c2, c)

%!test
%! % complex-valued input
%! A = rand(3,3);
%! b = complex(rand(1,3));
%! c = transpose(A*transpose(b));
%! c2 = frontal_mtimes_pt (A, b);
%! myassert(c2, c)

