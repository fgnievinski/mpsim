function answer = isfrontal (in)
    answer = isa(in, 'frontal');
end

%!test
%! myassert(isfrontal(frontal([])))
%! myassert(~isfrontal([]))

