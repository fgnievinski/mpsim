function display (A)
    fprintf(' \n%s =\n \n', inputname(1));
    if ~isempty(A)
        disp(A.data);
    else
        fprintf('     []\n \n');
    end
end

%!test
