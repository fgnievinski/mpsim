function idx = get_diag_ind_pkd (n)
    myassert (isscalar(n));
    
    idx = zeros(n, 1);
    idx(1) = 1;
    for i=2:n
        idx(i) = idx(i-1) + i;
    end
end

%!test
%! while true
%!     n = round(10*rand);
%!     if (n > 1),  break;  end
%! end
%! value = rand;
%! data = zeros(n, 1);
%! data(get_diag_ind_pkd(n)) = value;
%! A_pkd = packed(data, 'sym', 'u');
%! myassert(isdiag(A_pkd));
%! myassert(isequal( A_pkd, packed(value.*eye(n)) ));

