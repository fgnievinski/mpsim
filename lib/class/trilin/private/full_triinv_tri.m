function X = full_triinv_tri (Q, uplow)
    [s, m, n, clas] = full_triinv_check_in (Q, nan, uplow);
    error(s);
    func = [clas(1) 'trtri'];  X_i = 4;  info_i = 6;
    if (m*n == 0)
        X = zeros(m, n, clas);
        return;
    end
    diag = 'N';
    info = zeros(1, 1, lapack_int_type());
    % strtri (&uplow, &diag, &n, data, &n, &info);
    % dtrtri (&uplow, &diag, &n, data, &n, &info);
    out = lapack(func, uplow, diag, m, Q, n, info);
    X = out{X_i};
    info = out{info_i};
    error(full_check_out(info, func), 'triinv');
end

