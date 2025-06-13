function answer = issquare (S)
    temp = size(S);
    if (length(temp) > 2)
        answer = false;
        return;
    end
    answer = (temp(1) == temp(2));
end

%!test
%! S = eye(2,2);
%! myassert (issquare(S));

%!test
%! S = zeros(2,2);
%! myassert (issquare(S));

%!test
%! S = [1 2 2 1];
%! myassert (~issquare(S));

%!test
%! S = [];
%! myassert (issquare(S));

%!test
%! S = 1;
%! myassert (issquare(S));

