function out = mydateyear (varargin)
%MYDATEYEAR: Convert epoch interval to (decimal) years.
% 
% See also: mydateyearabs

    out = mydateday(varargin{:}) ./ 365.25;
end

%!shared
%! n = ceil(10*rand);
%! h = 100*rand(n,1);

%!test
%! %in_vec = [0 1 1  0 0 0];  % MATLAB's datenum returns 1, not 0.
%! in_vec = [0 1 0  0 0 0];
%! in = mydatenum(in_vec, true);
%! out = mydateyear(in);
%! out2 = mydateyear(in_vec);
%! myassert(out, 0, -sqrt(eps))
%! myassert(out2, 0, -sqrt(eps))

%!test
%! %in_vec = [0 1 1  0 0 0];  % MATLAB's datenum returns 1, not 0.
%! in_vec = [0 1 365.25  0 0 0];
%! in = mydatenum(in_vec, true);
%! out = mydateyear(in);
%! out2 = mydateyear(in_vec);
%! myassert(out, 1, -sqrt(eps))
%! myassert(out2, 1, -sqrt(eps))
