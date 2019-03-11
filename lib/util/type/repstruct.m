function out = repstruct (in, varargin)
    fields = fieldnames(in);
    in = struct2cell(in);
    in = cellfun(@(x) repmat(x, varargin{:}), in, 'UniformOutput',false);
    out = cell2struct(in, fields);
end

%!test
%! in.a = 1;
%! in.b = 2;
%! m = 3;
%! n = 4;
%! out.a = repmat(in.a, m, n);
%! out.b = repmat(in.b, m, n);
%! %repstruct(in, m, n)  % DEBUG
%! myassert(repstruct(in, m, n), out)

