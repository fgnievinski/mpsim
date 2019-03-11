function display (A)
    fprintf(' \n%s =\n \n', inputname(1));
    if ~isempty(A)
        disp(full(A));
    else
        fprintf('     []\n \n');
    end
end

%!test
