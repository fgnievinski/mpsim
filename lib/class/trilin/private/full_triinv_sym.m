function X = full_triinv_sym (Q, Q2, uplow)
    [s, m, n, clas] = full_triinv_check_in (Q, Q2, uplow);
    error(s);
    func = [clas(1) 'sytri'];  X_i = 3;  info_i = 7;
    if (m*n == 0)
        X = zeros(m, n, clas);
        return;
    end
    info = zeros(1, 1, lapack_int_type());
    work = zeros(m, 1, clas);
    % ssytri (&uplow, &n, data, &n, p_data, work, &info);
    % dsytri (&uplow, &n, data, &n, p_data, work, &info);
    out = lapack(func, uplow, m, Q, n, Q2, work, info);
    X = out{X_i};
    info = out{info_i};
    error(full_check_out(info, func), 'triinv');
end

