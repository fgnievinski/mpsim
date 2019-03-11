function [Q, Q2] = full_trifactor_sym (A, uplow)
    [s, m, n, clas, uplow] = full_trifactor_check_in (A, uplow);
    error(s);
    func = [clas(1) 'sytrf'];
    if (m*n == 0)
        Q = zeros(m, n, clas);
        Q2 = zeros(m, n, lapack_int_type());
        return;
    end
    info = zeros(1, 1);
    ipiv = zeros(m, 1, lapack_int_type());
    work = zeros(1, 1, clas);
    lwork = cast(-1, lapack_int_type());
    out = lapack(func, uplow, m, A, n, ipiv, work, lwork, info);
    info = out{5};
    error(full_trifactor_check_out(info, func));
    work = out{6};
    %class(work)  % DEBUG
    lwork = cast(work(1), lapack_int_type());
    work = zeros(lwork, 1, clas);
    % ssytrf (&uplow, &n, data, &n, ipiv, work, &lwork, &info);
    % dsytrf (&uplow, &n, data, &n, ipiv, work, &lwork, &info);
    %func  % DEBUG
    out = lapack(func, uplow, m, A, n, ipiv, work, lwork, info);
    Q = out{3};
    Q2 = out{5};
    info = out{8};
    error(full_trifactor_check_out(info, func));
    % avoid error "Undefined function or method 'minus' for input arguments of type 'int64'.":
    info = cast(info, clas);
end

