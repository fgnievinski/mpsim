function [As, endcond] = splinedesign2sa (bx, by, cs, x, y, endcond)
    [A, endcond] = splinedesign2a(bx, by, x, y, endcond);
    % the same A matrix is valid for each of the splines.
    % also the basis matrix does not depend on the value of coefficients, 
    % only their size.

    As = repmat({A}, size(cs));
end

%!shared
%! bx = sort(rand(2,1));
%! by = sort(rand(2,1));
%! c = rand(2,2);
%! endcond = [];
%! n = 10;
%! x = rand(n,1);
%! y = rand(n,1);

%!test
%! % single set of parameter corresponds to single call to spline2.
%! cs = {c};
%! As = splinedesign2sa (bx, by, cs, x, y, endcond);
%! A  = splinedesign2a  (bx, by, x, y, endcond);
%! As2 = {A};
%! myassert(As2,As);

%!test
%! % duplicated set of parameter corresponds to duplicated results.
%! cs = {c, c};
%! As = splinedesign2sa (bx, by, cs, x, y, endcond);
%! A  = splinedesign2a  (bx, by, x, y, endcond);
%! As2 = {A, A};
%! myassert(As2,As);

%!test
%! % general case.
%! ca = c;
%! cb = rand(size(c));
%! cs = {ca, cb};
%! As = splinedesign2sa (bx, by, cs, x, y, endcond);
%! Aa = splinedesign2a  (bx, by, x, y, endcond);
%! Ab = splinedesign2a  (bx, by, x, y, endcond);
%! As2 = {Aa, Ab};
%! myassert(As2,As);

%!test
%! % empty set of parameter corresponds empty output.
%! c = [];
%! cs = {c};
%! As = splinedesign2sa (bx, by, cs, x, y, endcond);
%! A  = splinedesign2a  (bx, by, x, y, endcond);
%! As2 = {A};
%! myassert(As2,As);

