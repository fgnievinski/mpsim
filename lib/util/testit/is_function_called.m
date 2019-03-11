function answer = is_function_called (line, func)
    % number of occurrences of each pattern:
    if is_octave()
        bow = '\b';
        eow = '\b';
    else
        bow = '\<';
        eow = '\>';
    end
    n1 = length( regexp(line, [bow func eow]) );
    n2 = length( regexp(line, ['''.*' bow func eow '.*''']) );
    answer = n1 > n2;
end

%!test
%! myassert(is_function_called ('test', 'test'));
%! myassert(is_function_called ('abc test', 'test'));
%! myassert(is_function_called ('test abc', 'test'));
%! myassert(is_function_called ('abc test abc', 'test'));
%! myassert(~is_function_called ('abctest', 'test'));
%! myassert(~is_function_called ('testabc', 'test'));
%! myassert(~is_function_called ('abc ''test'' abc', 'test'));
%! myassert(~is_function_called ('''abc test abc''', 'test'));
%! myassert(is_function_called ('''abc'' test abc', 'test'));
%! myassert(is_function_called ('abc test ''abc''', 'test'));

%!test
%! myassert(is_function_called(...
%!     'myassert (s.identifier, ''myassert:error'');', 'myassert'));
