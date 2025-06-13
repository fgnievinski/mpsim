function s = structmerge (s1, s2, varargin)
    if (nargin < 1) || isempty(s1),  s1 = struct();  end
    if (nargin < 2) || isempty(s2),  s2 = struct();  end
    algorithm = 2;
    switch algorithm
    case 1
        s = structmerge1(s1, s2);
    case 2
        s = structmerge2(s1, s2);
    otherwise
        error('matlab:structmerge:badAlg', ...
            'Unknowwn input algorithm.');
    end
    %s = feval(sprintf('structmerge%d', algorithm), s1, s2);
    if (nargin > 2),  s = structmerge (s, varargin{:});  end
end
%#ok<*DEFNU>

% TODO: merge structmerge and structmergenonempty.

function s = structmerge2 (s1, s2)
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    for i=1:numel(f2)
        fi = f2{i};
        if ~any(strcmp(f1, fi))
            s1.(fi) = s2.(fi);
        elseif isstruct(s1.(fi)) && isstruct(s2.(fi))
            s1.(fi) = structmerge2 (s1.(fi), s2.(fi));
        else
            s1.(fi) = s2.(fi);
        end
    end
    s = s1;
end

function s = structmerge1 (s1, s2)
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    
    f = cat(1, f1, f2);
    [f, ind] = unique(f);

    c1 = struct2cell(s1);
    c2 = struct2cell(s2);
    c = cat(1, c1, c2);
    c = c(ind);

	s = cell2struct (c, f);
    
    f0 = intersect(f1(structfun(@isstruct, s1)), f2(structfun(@isstruct, s2)));
    for i=1:numel(f0)
        j  = strcmp(f,  f0{i});
        j1 = strcmp(f1, f0{i});
        j2 = strcmp(f2, f0{i});
        s.(f{j}) = structmerge (s1.(f1{j1}), s2.(f2{j2}));
    end
end

%!test
%! % different field names:
%! s1.a = 1;
%! s2.b = 2;
%! s.a = s1.a;
%! s.b = s2.b;
%! s3 = structmerge (s1, s2);
%! myassert(s3, s)

%!test
%! % same field names: 2nd struct takes precedence:
%! s1.a = 1;
%! s2.a = [];
%! s1.b = 2;
%! s2.c = 3;
%! s.a = s2.a;
%! s.b = s1.b;
%! s.c = s2.c;
%! s3 = structmerge (s1, s2);
%! myassert(s3, s)

%!test
%! % same field names: ... unless both fields are structures:
%! s1.a.i = 1;
%! s1.a.ii = 2;
%! s1.b = 0;
%! s2.a.i = pi;
%! s.a.i = pi;
%! s.a.ii = 2;
%! s.b = 0;
%! s3 = structmerge (s1, s2);
%! myassert(s3, s)
