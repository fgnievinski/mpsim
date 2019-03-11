function s2 = getfields (s, f2, return_non_existent, algorithm)
    if isempty(s) && ~isstruct(s),  s = struct();  end
    was_cell = true;  if ~iscell(f2),  f2 = {f2};  was_cell = false;  end
    if (nargin < 3) || isempty(return_non_existent),  return_non_existent = false;  end
    if (nargin < 4) || isempty(algorithm),  algorithm = 1;  end
    switch algorithm
    case 1
        s2 = getfields1 (s, f2, return_non_existent);
    case 2
        s2 = getfields2 (s, f2, return_non_existent);
    end
    if ~was_cell,  s2 = getfield1(s2);  end
end

function s2 = getfields1 (s, f2, return_non_existent)
    s2 = struct();
    for i=1:numel(f2)
        try
            s2.(f2{i}) = s.(f2{i});
        catch me
            if return_non_existent ...
            && any(strcmp(me.identifier, ...
                {'MATLAB:nonExistentField','Octave:invalid-indexing'}))
                s2.(f2{i}) = [];
                continue
            end
            rethrow(me)
        end
    end
end

function s2 = getfields2 (s, f2, return_non_existent)
    f = fieldnames(s);
    c = struct2cell(s);
    idx2 = ismember(f2, f);
    if ~all(idx2)
        if return_non_existent
            sb = structmerge(structempty(f2), s);
            s2 = getfields (sb, f2);
            return
        else
            temp = sprintf('''%s'', ', f2{~idx2});
            temp(end-1:end) = [];  % remove dangling "' "
            if is_octave()
                error('Octave:invalid-indexing', ...
                    'structure has no member ''%s''.', temp);
            else
                error('MATLAB:nonExistentField', ...
                    'Reference to non-existent field(s) %s.', temp);
            end
        end
    end
    [idx, loc] = ismember(f, f2);
    c2(loc(idx)) = c(idx);
    s2 = cell2struct(c2(:), f2(:), 1);
end

%!test
%! s = struct('a',rand, 'b',rand, 'c',rand);
%! f2 = {'a', 'c'};
%! s2 = struct('a',s.a, 'c',s.c);
%! s2b = getfields(s, f2);
%! %s2, s2b  % DEBUG
%! myassert(s2b, s2)

%!test
%! s = struct('a',rand, 'b',rand, 'c',rand);
%! s2 = struct('a',s.a);
%! s2b = getfields(s, {'a'});
%! %s2, s2b  % DEBUG
%! myassert(s2b, s2)
%! s2b = getfields(s, 'a');
%! assert(~isstruct(s2b))

%!test
%! % change order of fields:
%! s = struct('a',rand, 'b',rand, 'c',rand);
%! f2 = {'c', 'a'};
%! s2 = struct('c',s.c, 'a',s.a);
%! s2b = getfields(s, f2);
%! %s2, s2b  % DEBUG
%! myassert(s2b, s2)

