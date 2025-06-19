function [tok, rem] = strtok2 (str, delim)
    if (nargin < 2),  delim = sprintf(' \t\n');  end  % as per doc strtok
    assert(~iscell(str))
    str = rowvec(str);
    str = fliplr(str);
    [tok, rem] = strtok (str, delim);
    tok = fliplr(tok);
    rem = fliplr(rem);
end

%!test
%! str = 'abcd.efg.hi.j';  delim = '.';
%! rem = str;
%! [tok, rem] = strtok2 (rem, delim);
%!   myassert(tok, 'j')
%! [tok, rem] = strtok2 (rem, delim);
%!   myassert(tok, 'hi')
%! [tok, rem] = strtok2 (rem, delim);
%!   myassert(tok, 'efg')
%! [tok, rem] = strtok2 (rem, delim);
%!   myassert(tok, 'abcd')
