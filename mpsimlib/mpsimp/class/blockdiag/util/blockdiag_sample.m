function X = blockdiag_sample (flag)
    if (nargin < 1),  flag = 'not square';  end

    D = {};
    N = 1 + ceil(10*rand);
    for i=1:N
        n = ceil(10*rand);
        if strcmp(flag, 'square'),  m = n;  else m = ceil(10*rand);  end
        D{i} = rand(m,n);
    end
    X = blockdiag(D);
end

%!test
%! myassert(isblockdiag(blockdiag_sample()))
%! myassert(isblockdiag(blockdiag_sample('square')))
%! myassert(issquare(blockdiag_sample('square')))

