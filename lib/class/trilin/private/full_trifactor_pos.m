function [Q, Q2] = full_trifactor_pos (A, uplow)
    [s, m, n, clas, uplow] = full_trifactor_check_in (A, uplow);
    error(s);
    func = [clas(1) 'potrf'];
    if (m*n == 0)
        Q = zeros(m, n, clas);
        Q2 = zeros(1, 1, clas);
        return;
    end
    info = zeros(1, 1);
    % spotrf (&uplow, &n, data, &n, &info);
    % dpotrf (&uplow, &n, data, &n, &info);
    %func  % DEBUG
    out = lapack(func, uplow, m, A, n, info);
    Q = out{3};
    info = out{5};
    error(full_trifactor_check_out(info, func));
    % avoid error "Undefined function or method 'minus' for input arguments of type 'int64'.":
    info = cast(info, clas);
    Q2 = info;
    if ( (info > 0) && (nargout < 2) )
        error('trilin:trifactor_pos:posdef', ...
            'Matrix must be positive definite.');
    end
    if ( (info > 0) && (nargout == 2) )
        Q = Q(1:info-1, 1:info-1);
    end    
end

