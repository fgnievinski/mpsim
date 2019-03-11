function sec2 = roundn(sec, n)
    if (nargin < 2),  n = -2;  end

    sec2 = round(sec./10.^n).*10.^n;
end

%!test
%! myassert(roundn(11.11,  0), 11.00, -eps(11.11));
%! myassert(roundn(11.11, -1), 11.10, -eps(11.11));
%! myassert(roundn(11.11, -2), 11.11, -eps(11.11));
%! myassert(roundn(11.11),     11.11, -eps(11.11));
%! myassert(roundn(11.11, +1), 10.00, -eps(11.11));
%! myassert(roundn(11.11, +2), 00.00, -eps(11.11));

%!test
%! m = ceil(rand*10);
%! n = ceil(rand*10);
%! %roundn(repmat(11.11, m, n),  0)  % DEBUG
%! myassert(roundn(repmat(11.11, m, n),  0), repmat(11.00, m, n), -eps(11.11));
%! myassert(roundn(repmat(11.11, m, n), -1), repmat(11.10, m, n), -eps(11.11));
%! myassert(roundn(repmat(11.11, m, n), -2), repmat(11.11, m, n), -eps(11.11));
%! myassert(roundn(repmat(11.11, m, n)),     repmat(11.11, m, n), -eps(11.11));
%! myassert(roundn(repmat(11.11, m, n), +1), repmat(10.00, m, n), -eps(11.11));
%! myassert(roundn(repmat(11.11, m, n), +2), repmat(00.00, m, n), -eps(11.11));

%!test
%! % non-scalar input for n:
%! myassert(roundn(11.11,  [0, 1]), [11.00 10.00], -eps(11.11));
