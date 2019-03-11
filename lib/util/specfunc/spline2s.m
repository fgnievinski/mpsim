function [zs, endcond, As] = spline2s (bx, by, cs, x, y, endcond, As)
    if (nargin < 7),  As = [];  end
    myassert(length(y) == length(x))
    myassert( iscell(cs) && (isvector(cs) || isempty(cs)) );
    siz = [length(by), length(bx)];
    sizs = cellfun(@size, cs, 'UniformOutput',false);
    myassert(sizs, repmat({siz}, size(cs)));
    if isempty(cs)
        zs = zeros(length(x), 0);
        return;
    end    
    
    if isempty(As)
        [A, endcond] = splinedesign2a (bx, by, x(:), y(:), endcond);
        As = repmat({A}, size(cs));
    end
    myassert(size(As), size(cs));

    zs = zeros(length(x), length(cs));
    for i=1:length(cs)
        [zs(:,i), endcond] = spline2(bx, by, cs{i}, x, y, endcond, As{i});
    end
    %TODO: support different breaks for each cs{i}?
end

%!shared
%! bx = sort(rand(2,1));
%! by = sort(rand(2,1));
%! c = rand(2,2);
%! endcond = [];
%! n = 100;
%! x = rand(n,1);
%! y = rand(n,1);

%!test
%! % single set of parameter corresponds to single call to spline2.
%! cs = {c};
%! zs = spline2s (bx, by, cs, x, y, endcond);
%! z = spline2(bx, by, c, x, y, endcond);
%! zs2 = z;
%! myassert(zs2, zs);

%!test
%! % duplicated set of parameter corresponds to duplicated results.
%! cs = {c, c};
%! zs = spline2s (bx, by, cs, x, y, endcond);
%! z = spline2(bx, by, c, x, y, endcond);
%! zs2 = [z, z];
%! myassert(zs2, zs);

%!test
%! % general case.
%! ca = c;
%! cb = rand(size(c));
%! cs = {ca, cb};
%! zs = spline2s (bx, by, cs, x, y, endcond);
%! za = spline2(bx, by, ca, x, y, endcond);
%! zb = spline2(bx, by, cb, x, y, endcond);
%! zs2 = [za, zb];
%! myassert(zs2, zs);

%!test
%! % single set of empty parameter corresponds to single columns of zeros, 
%! % not empty, output.
%! c = [];
%! cs = {c};
%! zs = spline2s ([], [], cs, x, y, endcond);
%! z = spline2([], [], c, x, y, endcond);
%! zs2 = z;
%! myassert(zs2, zs);

%!test
%! % multiple sets of empty parameters corresponds to multiple columns of zeros,
%! % not empty, output.
%! c = [];
%! cs = {c, c};
%! zs = spline2s ([], [], cs, x, y, endcond);
%! z = spline2([], [], c, x, y, endcond);
%! zs2 = [z, z];
%! myassert(zs2, zs);

%!test
%! % empty set of empty parameter corresponds to empty output.
%! cs = {};
%! zs = spline2s ([], [], cs, x, y, endcond);
%! myassert(isempty(zs))

%!test
%! % user-provided design matrix.
%! ca = c;
%! cb = rand(size(c));
%! cs = {ca, cb};
%! As = splinedesign2sa (bx, by, cs, x, y, endcond);
%! 
%! t = cputime;
%! zsa = spline2s (bx, by, cs, x, y, endcond);
%! ta = cputime - t;
%! 
%! t = cputime;
%! zsb = spline2s (bx, by, cs, x, y, endcond, As);
%! tb = cputime - t;
%! 
%! myassert(zsb, zsa)
%! 
%! % cputime_res applies to either t1 or t2 individually; 
%! % tol applies to t2-t1;
%! tol = 2*cputime_res + sqrt(eps);
%! %[tb, ta+tol]
%! myassert (tb <= (ta + tol));

