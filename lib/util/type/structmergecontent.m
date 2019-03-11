function s3 = structmergecontent (arg, s1, s2, varargin)
    [dim, F, arg] = structmergecontentarg (arg);
    switch (nargin-1)
    case 0
        s3 = struct();
    case 1
        s3 = structmergecontent1 (F, s1);
    case 2
        s1 = structmergecontent1 (F, s1);
        s2 = structmergecontent1 (F, s2);
        s3  = structmergecontent2 (dim, s1, s2);
    otherwise % > 2
        s1 = structmergecontent1 (F, s1);
        %s2 = structmergecontent (arg, s2, varargin{:});  % WRONG! 'MATLAB:recursionLimit'
        s2 = structmergecontent1 (F, s2);
        %for i=1:numel(varargin),  s2 = structmergecontent (arg, s2, varargin{i});  end  % WRONG!
        varargin = cellfun2(@(si) structmergecontent1 (F, si), varargin);
        for i=1:numel(varargin),  s2 = structmergecontent2 (dim, s2, varargin{i});  end
        s3 = structmergecontent2 (dim, s1, s2);
    end
end

function [dim, F, arg] = structmergecontentarg (arg)
    if ~iscell(arg),  arg = {arg};  end
    if isscalar(arg),  arg = [arg, {[]}];  end
    dim = arg{1};
    F = arg{2};
    if isempty(dim),  dim = 1;  end
    if isempty(F),  F = @(x) x;  end
    arg = {dim, F};
    assert(isnumeric(dim) && isscalar(dim))
end

function s = structmergecontent2 (dim, s1, s2)
    if isempty(s1),  s = s2;  return;  end
    if isempty(s2),  s = s1;  return;  end
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    if ~isequal(f1, f2) ...
    && ~isequal(sort(f1), sort(f2))
        error('MATLAB:structmergecontent:badFields', 'Non-matching fields.')
    end
    clear f2
    f = f1;
    s = struct();
    for i=1:length(f)
        if isstruct(s1.(f{i})) ...
        && isstruct(s2.(f{i}))
            s.(f{i}) = structmergecontent2 (dim, s1.(f{i}), s2.(f{i}));
            continue;
        end
        try
            s.(f{i}) = cat(dim, (s1.(f{i})), (s2.(f{i})));
        catch err
            %rethrow(err)
            error(err.identifier, '%s for field "%s".', err.message(1:end-1), f{i});
        end
    end
end

function s = structmergecontent1 (F, s)
    assert(isa(F, 'function_handle'))
    if isempty(s),  return;  end
    f = fieldnames(s);
    for i=1:length(f)
        if isstruct(s.(f{i}))
            s.(f{i}) = structmergecontent1 (F, s.(f{i}));
            continue;
        end
        s.(f{i}) = F(s.(f{i}));
    end
end

%!test
%! s1.a = 1;
%! s2.a = [];
%! s1.b = 2;
%! s2.b = 3;
%! s.a = [1];
%! s.b = [2 3];
%! ss = structmergecontent (2, s1, s2);
%! %ss, s  % DEBUG
%! myassert(ss, s)

%!test
%! % three input struct:
%! s1.a = 1;
%! s2.a = [];
%! s3.a = [pi; exp(1)];
%! s1.b = 2;
%! s2.b = 3;
%! s3.b = rand;
%! s.a = [1; pi; exp(1)];
%! s.b = [2; 3; s3.b];
%! ss = structmergecontent (1, s1, s2, s3);
%! %ss, s  % DEBUG
%! %ss.a, ss.b, s.a, s.b  % DEBUG
%! myassert(ss, s)

%!test
%! % catches a bug
%! s1.a.a = [1 2 3];
%! s.a.a = repmat({s1.a.a}, [5 1]);
%! ss = structmergecontent ({1 @tocell}, s1, s1, s1, s1, s1);
%! %ss.a, s.a  % DEBUG
%! myassert(ss, s)

%!test
%! % empty input structs:
%! s = struct();
%! ss = structmergecontent (1, struct(), struct(), struct());
%! myassert(ss, s)

%!test
%! % empty input structs:
%! s = struct();
%! ss = structmergecontent (1, struct(), struct(), struct());
%! myassert(ss, s)

%!test
%! % 'MATLAB:recursionLimit'
%! s0 = struct('a',1);
%! temp = repmat({s0}, [get(0,'RecursionLimit')+1, 1]);
%! s2 = structmergecontent(1, temp{:});
