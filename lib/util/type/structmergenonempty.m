function s = structmergenonempty (s1, s2, algorithm)
    if (nargin < 3) || isempty(algorithm),  algorithm = 2;  end
    if isempty(s2),  s = s1;  return;  end
    if isempty(s1),  s = s2;  return;  end
    switch algorithm
    case 1
        s = structmergenonempty1(s1, s2);
    case 2
        s = structmergenonempty2(s1, s2);
    otherwise
        error('matlab:structmergenonempty:badAlg', ...
            'Unknowwn input algorithm.');
    end
    %s = feval(sprintf('structmergenonempty%d', algorithm), s1, s2);
end
%#ok<*DEFNU>

% TODO: merge structmerge and structmergenonempty.

function s = structmergenonempty2 (s1, s2)
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    for i=1:numel(f2)
        fi = f2{i};
        if ~any(strcmp(f1, fi))
            s1.(fi) = s2.(fi);
        elseif isempty(s1.(fi))
            s1.(fi) = s2.(fi);
        elseif isempty(s2.(fi))
            continue;
        elseif isstruct(s1.(fi)) && isstruct(s2.(fi))
            s1.(fi) = structmergenonempty2 (s1.(fi), s2.(fi));
        else
            s1.(fi) = s2.(fi);
        end
    end
    s = s1;
end

function s = structmergenonempty1 (s1, s2)
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    [idx, ind] = ismember(f2, f1);
    %assert(all(idx))
    if ~all(idx)
        s1b = structmerge(structinit(s2), s1);
        s2b = structmerge(structinit(s1), s2);
        s = structmergenonempty(s1b, s2b);
        return
    end        
    c1 = struct2cell(s1);
    c2 = struct2cell(s2);
    idx2 = cellfun(@isempty, c2);
    ind(idx2) = [];
    idx(idx2) = false;
    c = c1;  c(ind) = c2(idx);
    f = f1;
    s = cell2struct(c, f);
    
    f0 = intersect(f1(structfun(@isstruct, s1)), f2(structfun(@isstruct, s2)));
    for i=1:numel(f0)
        j  = strcmp(f,  f0{i});
        j1 = strcmp(f1, f0{i});
        j2 = strcmp(f2, f0{i});
        s.(f{j}) = structmergenonempty (s1.(f1{j1}), s2.(f2{j2}));
    end
end

%!shared
%! algorithm = 1;
%! algorithm = 2;
%! algorithm = [];

%!test
%! s1.a = 1;
%! s1.b = 2;
%! s2.a = [];
%! s2.b = 3;
%! s.a = 1;
%! s.b = 3;
%! ss = structmergenonempty (s1, s2, algorithm);
%! %ss, s  % DEBUG
%! myassert(ss, s)

%!test
%! % don't change order of fields:
%! s1.b = 2;
%! s1.a = 1;
%! s2.b = 3;
%! s2.a = pi;
%! s.b = 3;
%! s.a = pi;
%! ss = structmergenonempty (s1, s2, algorithm);
%! %ss, s  % DEBUG
%! myassert(ss, s)

%!test
%! % non-identical structures
%! s1.a = 1;
%! s1.b = 2;
%! s1.c = 1i;
%! s2.a = [];
%! s2.b = 3;
%! s2.d = pi;
%! s.a = 1;
%! s.b = 3;
%! s.c = 1i;
%! s.d = pi;
%! ss = structmergenonempty (s1, s2, algorithm);
%! %ss, s  % DEBUG
%! myassert(ss, s)

%!test
%! % sub-struct:
%! s1.a = 1;
%! s1.b = struct('c',pi);
%! s2.a = [];
%! s2.b = struct('c',[]);
%! s = s1;
%! ss = structmergenonempty (s1, s2, algorithm);
%! %ss, s  % DEBUG
%! %ss.b, s.b  % DEBUG
%! myassert(ss, s)
