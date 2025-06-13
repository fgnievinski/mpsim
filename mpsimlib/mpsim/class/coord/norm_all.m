%#eml
function answer = norm_all (v)
    answer = sqrt(sum(v.*conj(v), 2));
    %answer = sqrt(sum(v.^2, 2));  % WRONG!
end

%!test
%! vectors = [...
%!     0   0   0
%!     1   0   0
%!     0   1   0
%!     0   0   1
%!     1   1   1
%!     1   2   3
%! ];
%! correct_answer = [0; 1; 1; 1; sqrt(3); sqrt(1^2 + 2^2 + 3^2)];
%! answer = norm_all (vectors);
%! myassert (answer, correct_answer, -eps);

%!test
%! % 2-d vector:
%! myassert(norm_all([1, 0]), 1)

%!test
%! % frontal pages:
%! n = 5;
%! pos1 = rand(n,3);
%! pos2 = rand(n,3);
%! pos = cat(3, pos1, pos2);
%! rad1 = norm_all(pos1);
%! rad2 = norm_all(pos2);
%! rad = cat(3, rad1, rad2);
%! radb = norm_all(pos);
%! %max(abs(radb(:)-rad(:)))  % DEBUG
%! myassert(radb, rad)
%! %whos  % DEBUG

%!test
%! % complex-valued:
%! z = complex(rand, rand);
%! a1 = norm_all(z);
%! a2 = norm(z);
%! myassert(a1, a2)
