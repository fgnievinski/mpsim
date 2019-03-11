function [Q, Q2] = full_trifactor_gen (A)
    [s, m, n, clas] = full_trifactor_check_in (A);
    error(s);
    func = [clas(1) 'getrf'];
    if (m*n == 0)
        Q = zeros(m, n, clas);
        Q2 = Q;
        return;
    end
    ipiv = zeros(min(m,n), 1, lapack_int_type());
    info = zeros(1, 1, lapack_int_type());
    % sgetrf (&m, &n, data, &m, ipiv, &info);
    % dgetrf (&m, &n, data, &m, ipiv, &info);
    %func  % DEBUG
    out = lapack(func, m, n, A, m, ipiv, info);
    Q = out{3};
    Q2 = out{5};
    info = out{6};
    error(full_trifactor_check_out(info, func));
end

