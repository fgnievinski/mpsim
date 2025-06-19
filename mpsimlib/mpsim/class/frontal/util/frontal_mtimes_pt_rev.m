function c = frontal_mtimes_pt_rev (A, b, trans_A, trans_b, trans_c)
    if (nargin < 3),  trans_A = false;  end
    if (nargin < 4),  trans_b = false;  end
    if (nargin < 5),  trans_c = false;  end
    A = frontal(A);
    b = frontal(b, 'pt');
    if trans_A,  A = A.';  end
    if trans_b,  b = b.';  end
    c = (b * A);
    if trans_c,  c = c.';  end
    c = defrontal(c, 'pt');
end

%!test
%! A = rand(3,3);
%! b = rand(1,3);
%! c = (b * A);
%! c2 = frontal_mtimes_pt_rev (A, b);
%! myassert(c2, c)

%!test
%! % NaNs in input:
%! A = rand(3,3);
%! b = rand(2,3);
%! b(1) = NaN;
%! c = (b * A);
%! c2 = frontal_mtimes_pt_rev (A, b);
%! %c, c2  % DEBUG
%! myassert(c2, c)

%!test
%! % NaNs in input:
%! A = rand(3,3,2);
%! A(1,1,1) = NaN;
%! b = rand(2,3);
%! for i=1:size(A,3)
%!     c(i,:) = (b(i,:)*A(:,:,i));
%! end
%! c2 = frontal_mtimes_pt_rev (A, b);
%! %c, c2  % DEBUG
%! myassert(c2, c)

%!test
%! % complex-valued input, with transposes:
%! A = rand(3,3);
%! b = rand(1,3);
%! A = complex(A, A);
%! b = complex(b, b);
%! c = (b * A);
%! c2 = frontal_mtimes_pt_rev (A.', b, true, false, false);
%! %c, c2  % DEBUG
%! myassert(c2, c)

