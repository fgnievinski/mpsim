function A = sum (A, dim)
    A1 = A.data(:,:,1);
    %whos A1  % DEBUG
    if (nargin < 2)
        dim = finddim(A1);
        %dim = finddim(A);  % WRONG!
    end
    if ischar(dim)
        error('frontal:sum:nonDouble', 'Non-double output not supported.');
    end
    A.data = sum (A.data, dim);
end

%!test
%! % test sum frontal
%! in = ones(1,1,3);
%! out = defrontal(sum(frontal(in)));
%! out2 = in;
%! out3 = sum(in);
%! %out, out2, out3  % DEBUG
%! myassert(out, out2)
%! %myassert(out, out3)  % WRONG!
