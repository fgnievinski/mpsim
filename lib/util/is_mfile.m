function answer = is_mfile (filename)
    len = length(filename);
    if (len < 3) 
        answer = false; 
        return 
    end
    answer = (filename([len-1 len]) == '.m');

%!test myassert (is_mfile('abc.m'));
%!test myassert (!is_mfile('abc.txt'));
%!test myassert (!is_mfile('.'));
%!test myassert (!is_mfile('.m'));
%!test myassert (is_mfile('x.m'));
