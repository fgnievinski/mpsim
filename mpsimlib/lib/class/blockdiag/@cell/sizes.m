function [answer1, answer2] = sizes (A)
    if (nargout < 2)
        answer1 = cellfun(@size, A, 'UniformOutput', false);
    else
        [answer1, answer2] = cellfun(@size, A, 'UniformOutput', true);
    end

    %I = cellfun('size', cell(A), 1);
    %J = cellfun('size', cell(A), 2);
    %if (nargout < 2)
    %    answer1 = reshape(num2cell([I(:), J(:)], 2), size(A, 1), size(A, 2));
    %elseif (nargout == 2)
    %    answer1 = I;
    %    answer2 = J;
    %end
end

%!test
%! myassert (isempty(sizes({})));
%! myassert (~isequal(sizes({}), {[0, 0]}));

%!shared
%! A = {[], pi; ones(2), ones(2,3)};

%!test
%! myassert (sizes(A), {[0,0], [1,1]; [2,2], [2,3]});

%!test
%! [I,J] = sizes(A);
%! myassert (I, [0, 1; 2, 2]);
%! myassert (J, [0, 1; 2, 3]);

