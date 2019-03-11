function answer = do_op (left, right, op)
    if isempty(left) || isempty(right)
        answer = blockdiag;
        return;
    end
    
    answer = blockdiag (...
        cellfun(str2func(op), diag(cell(left)), diag(cell(right)), ...
        'UniformOutput', false) );
end

