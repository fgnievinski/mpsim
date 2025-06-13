function out = getfield1 (in, ignore_nonscalar)
    if (nargin < 2) || isempty(ignore_nonscalar),  ignore_nonscalar = false;  end
    f = fieldnames(in);
    if (numel(f) == 1),  out = in.(f{1});  return;  end
    if ignore_nonscalar,  out = in;  return;  end
    error('MATLAB:getfield1:nonScalar', 'Non-scalar fieldname list.');
end

%!test
%! in = struct('a',rand);
%! out = in.a;
%! out2 = getfield1(in);
%! %out2, out  % DEBUG
%! myassert(out2, out)

