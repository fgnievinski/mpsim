% tries to find the first zero of f near x0, 
% to the left or to the right of x0.
%TODO: accept x0 vector.
function answer = fzerod(f, x0, dir, i_max)
    myassert(isa(f, 'function_handle'));
    myassert(isscalar(x0));
    if strcmp(dir, 'lower'),  dir = 'left';  end
    if strcmp(dir, 'upper'),  dir = 'right';  end
    if ~any(strcmp(dir, {'left', 'right'}))
        error('Dir %s unknown.', dir);
    end
    if (nargin < 4),  i_max = 500;  end
    
    delta = eps(x0);
    i = 1;
    answer = NaN;
    s = lasterror('reset');

    while true
        if strcmp(dir, 'left')
            xn = x0 - delta;
            x02 = [xn, x0];
        elseif strcmp(dir, 'right')
            xn = x0 + delta;
            x02 = [x0, xn];
        end
        if f(x0)==f(xn)
            % f is NOT function of x.
            %disp('hw!')  % DEBUG
            return;
        end
        try
            answer = fzero(f, x02);
            break
        catch
            s = lasterror;
            if ~strcmp(s.identifier, 'MATLAB:fzero:ValuesAtEndPtsSameSign')
                error(s);
            end
            if (i > i_max)
                return
            end
            i = i + 1;
            delta = delta + nthroot(eps(xn), i);
            %i, delta, answer, s.identifier, pause  % DEBUG
            %if isnan(answer), let it go.
        end
    end
end

%!test
%! % fzerod()
%! warning('Tested with trigonometric functions only.')

%!test
%! f = @(x) sin(x);
%! x0 = rand*20-10;  % rand # bet -10,+10
%! x0l = floor(x0./pi)*pi;
%! x0u =  ceil(x0./pi)*pi;
%! %f(x0l),  f(x0u)  % DEBUG
%! myassert(f(x0l), 0, -10*eps);
%! myassert(f(x0u), 0, -10*eps);
%! 
%! x0l2 = fzerod(f, x0, 'lower');
%! x0u2 = fzerod(f, x0, 'upper');
%! 
%! %[x0l, x0l2, x0l2-x0l]  % DEBUG
%! %[x0u, x0u2, x0u2-x0u]  % DEBUG
%! myassert(x0l, x0l2, -sqrt(eps))
%! myassert(x0u, x0u2, -sqrt(eps))

%!test
%! % constant function has no roots
%! answer = fzerod(@(x)1, rand, 'left');
%! myassert(isnan(answer))

%!test
%! % linear function has only one root.
%! % if there is one root to the left, there is none to the right.
%! f = @(x) rand*x;
%! myassert(fzerod(f,  2, 'left'), 0, -10*sqrt(eps))
%! myassert(isnan(fzerod(f,  2, 'right')))
%! myassert(isnan(fzerod(f, -2, 'left')))
%! myassert(fzerod(f, -2, 'right'), 0, -10*sqrt(eps))

