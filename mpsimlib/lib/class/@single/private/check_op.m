function s = check_op (left, right, op, id_prefix)
    s = [];

    
    %%% check type compatibility:
    %t1 = 1;
    %t2 = 1;
    %if issparse(left),   t1 = sparse(t1);  end
    %if issparse(right),  t2 = sparse(t2);  end
    %t1 = cast(t1, class(left));
    %t2 = cast(t2, class(right));
    %try
    %    feval(op, t1, t2);
    %catch
    %    s = lasterror;
    %    if isfield (s, 'stack'),  s = rmfield (s, 'stack');  end
    %    s.identifier = strrep(s.identifier, 'MATLAB', id_prefix);
    %    return;
    %end

    
    %% check size compatibility:
    if ndims(left) > 2 || ndims(right) > 2
        s.identifier = [id_prefix 'dimagree'];
        s.message = 'Number of array dimensions must match for binary array op.';
        return;
    end
    
    t1 = sparse(size(left,1), size(left,2));
    t2 = sparse(size(right,1), size(right,2));
    try
        feval(op, t1, t2);
    catch
        s = lasterror;
        if isfield (s, 'stack'),  s = rmfield (s, 'stack');  end
        s.identifier = strrep(s.identifier, 'MATLAB', id_prefix);
        return;
    end
end

