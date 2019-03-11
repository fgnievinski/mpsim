function C = interleave_slow (A, B, dim, num_a, num_b)

    %%%%%%%%%%%%%%%%%%%%%%%
    % Default inputs.
    if (nargin < 3)  % only A, B were given
        dim = 1;
    end 
    if (nargin < 4)  % only A, B, dim were given
        num_a = 1;
    end 
    if (nargin < 5)  % only A, B, dim, num_a were given
        num_b = 1;
    end
        

    %%%%%%%%%%%%%%%%%%%%%%%
    % Check input.
    
    if (dim == 1)
        other_dim = 2;
    elseif (dim == 2)
        other_dim = 1;
    else
        error ( sprintf('Interleave along dimension %d is not supported.', dim) );
    end
        
    if (ndims(A) > 2 | ndims(B) > 2)
        error ('Interleave does not support matrices with more that two dimensions.');
    end
        
    if ( (size(A, dim) / num_a) ~= (size(B, dim) / num_b) )
        error( sprintf('Size of matrices along dimension %d should be compatible.', dim) ); 
    end
    
    if ( size(A, other_dim) ~= size(B, other_dim) )
        error( sprintf('Size of matrices along dimension %d should be equal.', other_dim) ); 
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%
    num_c = size(A, dim) + size(B, dim);
    other_num_c = size(A, other_dim);  % = size(B, other_dim)
   
    if (dim == 1)      % interleave_slow rows
        C = zeros(num_c, other_num_c);
    elseif (dim == 2)  % interleave_slow columns
        C = zeros(other_num_c, num_c);
    else
        % "Impossible" case.
        error ('Fatal error: dim ~= 1 & dim ~= 2.');
    end        
   
    
    %%%%%%%%%%%%%%%%%%%%%%%
    k = 1;  % controls whether we should add a row/column of A or B to C.
    i_a = 1;  % index for the rows/columns of A.
    i_b = 1;  % index for the rows/columns of B.
    for i_c = 1:num_c  % index for the rows/columns of C.
        %i_c  % debug
        %i_a  % debug
        %i_b  % debug
        %k  % debug
        if (k <= num_a)
            %'A'  % debug
            if (dim == 1)
                C(i_c, :) = A(i_a, :);
            elseif (dim == 2)
                C(:, i_c) = A(:, i_a);
            end
            i_a = i_a + 1;
        elseif (k <= (num_a + num_b))
            %'B'  % debug
            if (dim == 1)
                C(i_c, :) = B(i_b, :);
            elseif (dim == 2)
                C(:, i_c) = B(:, i_b);
            end
            i_b = i_b + 1;
        end
        k = k + 1;
        if (k > (num_a + num_b))
            k = 1;
        end
        %k    % debug
        %'\n'  % debug
    end

return;



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
%! answer = interleave_slow(B, B, dim);
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
%! answer = interleave_slow(B, B);
%! myassert (answer == correct_answer);

%!error
%! dim = 1;
%! interleave_slow(A, B, dim)
 
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
%! answer = interleave_slow(B, B, dim);
%! myassert (answer == correct_answer);
 
%!error
%! dim = 2;
%! interleave_slow(A, B, dim)
 
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
%! answer = interleave_slow(A, B, dim, 2, 1);
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
%! answer = interleave_slow(B, A, dim, 1, 2);
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
%! answer = interleave_slow(A, A, dim, 2, 2);
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
%! answer = interleave_slow(B, [B; B], dim, 1, 2);
%! myassert (answer == correct_answer);

%!test
%! dim = 2;
%! A = [1; 2; 3];
%! B = [3; 2; 1];
%! correct_answer = [1 3 ; 2 2 ; 3 1];
%! answer = interleave_slow(A, B, dim);
%! myassert (answer == correct_answer);

