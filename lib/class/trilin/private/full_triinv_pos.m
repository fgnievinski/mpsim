function X = full_triinv_pos (Q, uplow)
    [s, m, n, clas] = full_triinv_check_in (Q, nan, uplow);
    error(s);
    func = [clas(1) 'potri'];  X_i = 3;  info_i = 5;
    if (m*n == 0)
        X = zeros(m, n, clas);
        return;
    end
    info = zeros(1, 1, lapack_int_type());
    % spotri (&uplow, &n, data, &n, &info);
    % dpotri (&uplow, &n, data, &n, &info);
    out = lapack(func, uplow, m, Q, n, info);
    X = out{X_i};
    info = out{info_i};
    error(full_check_out(info, func), 'triinv');
end

