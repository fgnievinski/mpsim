function out = myflip (in)
    %assert(isvector(in))  % WRONG!
    assert(isvector(in) || isempty(in))
    out = in(end:-1:1);
end

%!test
%! in = [1 2 3];
%! out = [3 2 1];
%! out2 = myflip (in);
%! myassert(out2, out)

%!test
%! in = [1 2 3]';
%! out = [3 2 1]';
%! out2 = myflip (in);
%! myassert(out2, out)

%!test
%! in = [];
%! out = [];
%! out2 = myflip (in);
%! myassert(out2, out)
