function c = interleave (a, b, dim, num_a, num_b)
    if (nargin < 5),  num_b = 1;  end
    if (nargin < 4),  num_a = 1;  end
    if (nargin < 3) || isempty(dim),  dim = 1;    end
    if ischar(dim),  switch lower(dim)
        case {'row','rows'},  dim = 1;
        case {'col','columns'},  dim = 2;
    end, end
    myassert (nargin >= 2);

    myassert (dim ~= 1 || dim ~= 2);

    if isempty(a) && isempty(b)
        %c = [];  % WRONG!
        if iscell(a) && iscell(b)
            c = {};
        else
            c = [];
        end
        return;
    end
    
    [ma, na] = size(a);
    [mb, nb] = size(b);
    iscel = iscell(a) && iscell(b);
    
    %%%%%
    if (dim == 1)
        myassert (na, nb);
        myassert (ma/num_a, mb/num_b);

        mc = ma+mb;
        if iscel
            c = cell (mc, na);
        else
            c = zeros (mc, na);
        end

        pc = mc;
    elseif (dim == 2)
        myassert (ma, mb);
        myassert (na/num_a, nb/num_b);

        nc = na+nb;
        if iscel
            c = cell (ma, nc);
        else
            c = zeros (ma, nc);
        end

        pc = nc;
    end

    %%%%%
    idx_a = false(pc, 1);
    for k=1:num_a
        %ind_a = k:(num_a+num_b):pc;
        %idx_a(ind_a) = true;
        idx_a(k:(num_a+num_b):pc) = true;
    end
    idx_b = false(pc, 1);
    for k=1:num_b
        %ind_b = (num_a+k):(num_a+num_b):pc;
        %idx_b(ind_b) = true;
        idx_b((num_a+k):(num_a+num_b):pc) = true;
    end

    %%%%%
    if (dim == 1)
        c(idx_a, :) = a;
        c(idx_b, :) = b;
    elseif (dim == 2)
        c(:, idx_a) = a;
        c(:, idx_b) = b;
    end

end

%%%%%%%%%%%%%%%%%%%%
% Test block.

%!shared A, B
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
 
%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 1;
%! correct_answer = [...
%!     9 8 7 ;
%!     9 8 7 ;
%!     6 5 4 ;
%!     6 5 4 ;
%!     3 2 1 ;
%!     3 2 1 ;
%! ];
%! answer = interleave(B, B, dim);
%! myassert (answer == correct_answer);

%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! correct_answer = [...
%!     9 8 7 ;
%!     9 8 7 ;
%!     6 5 4 ;
%!     6 5 4 ;
%!     3 2 1 ;
%!     3 2 1 ;
%! ];
%! answer = interleave(B, B);
%! myassert (answer == correct_answer);

%!error
%! dim = 1;
%! interleave(A, B, dim)
 
%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 2;
%! correct_answer = [...
%!     9 9 8 8 7 7 ;
%!     6 6 5 5 4 4 ;
%!     3 3 2 2 1 1 ;
%! ];
%! answer = interleave(B, B, dim);
%! myassert (answer == correct_answer);
 
%!error
%! dim = 2;
%! interleave(A, B, dim)
 
%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 2;
%! correct_answer = [...
%!     0 1 9  2 9 8  0 1 7 ;
%!     3 4 6  5 9 5  0 1 4 ;
%!     6 7 3  8 9 2  0 1 1 ;
%! ];
%! answer = interleave(A, B, dim, 2, 1);
%! myassert (answer == correct_answer);

%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 2;
%! correct_answer = [...
%!     9 0 1  8 2 9  7 0 1 ;
%!     6 3 4  5 5 9  4 0 1 ;
%!     3 6 7  2 8 9  1 0 1 ;
%! ];
%! answer = interleave(B, A, dim, 1, 2);
%! myassert (answer == correct_answer);

%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 2;
%! correct_answer = [...
%!     0 1 0 1  2 9 2 9  0 1 0 1 ;
%!     3 4 3 4  5 9 5 9  0 1 0 1 ;
%!     6 7 6 7  8 9 8 9  0 1 0 1 ;
%! ];
%! answer = interleave(A, A, dim, 2, 2);
%! myassert (answer == correct_answer);

%!test
%! A = [...
%!     0 1 2 9 0 1 ;
%!     3 4 5 9 0 1 ;
%!     6 7 8 9 0 1 ;
%! ];
%! B = [...
%!     9 8 7 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! dim = 1;
%! correct_answer = [...
%!     9 8 7 ;
%!     9 8 7 ;
%!     6 5 4 ;
%!     
%!     6 5 4 ;
%!     3 2 1 ;
%!     9 8 7 ;
%!     
%!     3 2 1 ;
%!     6 5 4 ;
%!     3 2 1 ;
%! ];
%! answer = interleave(B, [B; B], dim, 1, 2);
%! myassert (answer == correct_answer);

%!test
%! dim = 2;
%! A = [1; 2; 3];
%! B = [3; 2; 1];
%! correct_answer = [1 3 ; 2 2 ; 3 1];
%! answer = interleave(A, B, dim);
%! myassert (answer == correct_answer);

