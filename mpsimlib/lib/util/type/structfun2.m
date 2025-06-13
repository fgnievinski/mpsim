function out = structfun2 (fun, in, in2)
    if (nargin < 3)
        out = structfun(fun, in, 'UniformOutput',false);
        return;
    end
    fields = fieldnames(in);
    temp = struct2cell(in);
    temp2 = struct2cell(in2);
    temp = cellfun(fun, temp, temp2, 'UniformOutput',false);
    out = cell2struct(temp, fields);
end

%!test
%! in = struct('a',rand, 'b',rand);
%! out = struct('a',sin(in.a), 'b',sin(in.b));
%! out2 = structfun2(@sin, in);
%! out3 = structfun(@sin, in, 'UniformOutput',false);
%! %in, out, out2, out3  % DEBUG
%! myassert(isequal(out2, out, out))

%!test
%! in = struct('a',rand, 'b',rand);
%! in2= struct('a',rand, 'b',rand);
%! out = struct('a',sin(in.a+in2.a), 'b',sin(in.b+in2.b));
%! f = @(a,b) sin(a+b);
%! %in, out, structfun2(f, in, in2)  % DEBUG
%! myassert(isequal(out, structfun2(f, in, in2), out))

