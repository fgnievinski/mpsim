function s = check_op (left, right, op, id_prefix)
    s = [];

    if ~isblockdiag(left) || ~isblockdiag(right)
        s.identifier = [id_prefix ':badInputClass'];
        s.message = 'Both operands should be of the same class.';
        return;
    end
    
    %% check size compatibility:
    myassert (ndims(left) <= 2 && ndims(right) <= 2);
    
    t1 = sparse(size(left,1), size(left,2));
    t2 = sparse(size(right,1), size(right,2));
    %whos t1 t2  % DEBUG
    try
        feval(op, t1, t2);
    catch
        s = lasterror;
        s.identifier = strrep(s.identifier, 'MATLAB', id_prefix);
        return;
    end

    if ~isequal(sizes(left), sizes(right))
        s.identifier = [id_prefix ':badInputSizes'];
        s.message = 'Each sub-matrix should have the same size.';
        return;
    end
end

