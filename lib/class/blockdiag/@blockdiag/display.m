function display (A)
    if ~isempty(A)
        temp = evalc('disp(diag(diag(A.data)));');
    else
        temp = '     {}\n \n';
    end
    fprintf([' \n%s =\n \n' temp], inputname(1));
end

%!test
%! % display ()

