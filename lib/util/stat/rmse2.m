% calculate rmse removing one observation at a time.
function y = rmse2 (x)

    myassert(isvector(x));
    n = length(x);

    y = zeros(n, 1);
    for i=1:n
        idx = ( (1:n) ~= i );
        y(i) = norm(x(idx)) / sqrt(n-1);
        % n-1 comes from the fact that we have removed 1 observation
        % (otherwise it would be just n, from the rmse formula).
    end

end

%!test
%! answer = [...
%!     sqrt(    4*4+3*3)
%!     sqrt(5*5    +3*3)
%!     sqrt(5*5+4*4)
%! ] ./  sqrt(2);
%! %rmse2([5; 4; 3]) - answer  % DEBUG
%! myassert ( rmse2([5 4 3]), answer);

