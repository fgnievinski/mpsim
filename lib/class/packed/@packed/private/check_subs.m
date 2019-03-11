function e = check_subs (A, s, id_prefix, B)
    myassert (ispacked(A));
    
    e = [];

    %% check type compatibility:
    if (nargin >= 4)
        t1 = cast(zeros(2,2), class(A));
        t2 = cast(1, class(B));
        if issparse(B),  t2 = sparse(t2);  end
        try
            eval(['t1(1) = t2;']);
        catch
            e = lasterror;
            e.identifier = strrep(e.identifier, 'MATLAB', id_prefix);
            return;
        end
    end

    
    %% let @sparse do the error checking:
    try
        a = sparse(order(A), order(A));
        if (nargin >= 4)
            myassert (ndims(B) <= 2);
            b = sparse(size(B,1), size(B,2));
            subsasgn(a, s, b);
        else
            subsref(a, s);
        end
    catch
        e = lasterror;
        if strcmp(e.identifier, 'MATLAB:SparseSubLimitTwoDims')
            e.identifier = strrep(e.identifier, 'Sparse', 'Packed');
            e.message    = strrep(e.message,    'Sparse', 'Packed');
        end
        e.identifier = strrep(e.identifier, 'MATLAB', id_prefix);
        return;
    end
end

