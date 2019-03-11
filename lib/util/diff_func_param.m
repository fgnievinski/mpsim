function answer = diff_func_param (f, param, h, reshapeit)
    if (nargin < 3),  h = [];  end
    if (nargin < 4) || isempty(reshapeit),  reshapeit = true;  end
    myassert (isvector(param));
    num_params = length(param);
    [answer, m, n] = diff_func2 (f, param, h);
    %[m,n,num_params,size(temp)]  % DEGUB
    if ~reshapeit,  return;  end
    answer = reshape(answer', [], num_params, m);
    % we DO assume one parameter is dependent on all other parameters.
end

%!test
%! % input and output vectors are column, not row, vectors;
%! % the Jacobian will be a 3d frontal matrix.
%! n = ceil(10*rand);
%! X = rand(n, 1);
%! p = rand(2, 1);
%! f = @(p) p(1)*X + p(2)*X;
%! answer = repmat(reshape(X, [1,1,n]), 1, 2)
%! answer2 = diff_func_param (f, p)
%! [answer, answer2, answer2-answer]  % DEBUG
%! myassert (answer2, answer, sqrt(eps));

%!test
%! n = ceil(10*rand);
%! ell = get_ellipsoid('grs80');
%! pt_cart = convert_to_cartesian (rand_pt_geod(n), ell);
%! param = 1e6*rand(7,1);
%! f = @(p) similarity (pt_cart, p);
%! answer = reshape(diff_func2 (f, param)', 3, 7, n);
%! answer2 = diff_func_param (f, param);
%! myassert (answer2, answer);
