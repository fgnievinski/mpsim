function out = mydatehour (varargin)
%MYDATEHOUR: Convert epoch interval to (decimal) hours.
    out = mydatesec(varargin{:}) ./ 3600;
end

%!shared
%! n = ceil(10*rand);
%! h = 100*rand(n,1);

%!test
%! in = h * 3600;
%! out = mydatehour(in);
%! %[h, out, out-h]  % DEBUG
%! myassert(out, h, -sqrt(eps()))

%!test
%! in = zeros(n,6);  in(:,4) = h;
%! out = mydatehour(in);
%! %[h, out, out-h]  % DEBUG
%! myassert(out, h, -sqrt(eps()))

