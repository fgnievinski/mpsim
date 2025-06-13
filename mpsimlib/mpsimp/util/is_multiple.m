function out = is_multiple (in, base)
  idx1 = isnan(in);
  idx2 = isnan(base);
  if ~any(idx1) && ~any(idx2)
    out = is_multiple_aux(in, base);
  elseif any(idx1) && ~any(idx2)
    out = NaN(size(in));
    out(~idx1) = is_multiple_aux(in(~idx1), base);
  elseif ~any(idx1) && any(idx2)
    out = NaN(size(in));
    out(~idx2) = is_multiple_aux(in, base(~idx2));
  elseif any(idx1) && any(idx2) && isequal(size(in), size(base))
    out = NaN(size(in));
    idx = idx1 | idx2;
    out(~idx) = is_multiple_aux(in(~idx), base(~idx));
  else
    error ('MATLAB:is_multiple:NaNTooMany', 'Unsupported case.')
  end
end

function out = is_multiple_aux (in, base)
	out = ~mod(in, base);
end

%!test
%! base = 5;
%! temp = [...
%!   0  1
%!   1  0
%!   2  0
%!   3  0
%!   4  0
%!   5  1
%!   6  0
%!   9  0
%!  10  1
%!  11  0
%!  -1  0
%!  -2  0
%!  -3  0
%!  -4  0
%!  -5  1
%!  -6  0
%!  -9  0
%! -10  1
%! -11  0
%! ];
%! in = temp(:,1);
%! out = temp(:,2);
%! out2 = is_multiple (in, base);
%!  %[in out out2 out2-out]  % DEBUG
%! myassert(out2, out)

%!test
%! assert(isnan(is_multiple(NaN, 1)))
%! assert(isnan(is_multiple(1, NaN)))
%! assert(isnan(is_multiple(NaN, NaN)))

