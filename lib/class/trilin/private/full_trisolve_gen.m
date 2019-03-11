function X = full_trisolve_gen (B, Q, Q2)
    [s, B_m, B_n, Q_m, Q_n, clas] = full_trisolve_check_in (B, Q, Q2);
    error(s);
    func = [clas(1) 'getrs'];  B_i = 7;  info_i = 9;
    % now make it avoid copying Q & Q2:
    func = [func '(H, I, I, u, I, u, U, I, I)'];  B_i = 5;  info_i = 7;
      %disp(func)  % DEBUG
    if (B_m*B_n == 0)
        X = zeros(B_m, B_n, clas);
        return;
    end
    trans = 'N';
    info = zeros(1, 1, lapack_int_type());
    % sgetrs (&trans, &Q_n, &B_n, Q_data, &Q_m, p_data, B_data, &B_m, &info);
    % dgetrs (&trans, &Q_n, &B_n, Q_data, &Q_m, p_data, B_data, &B_m, &info);
    out = lapack(func, trans, Q_n, B_n, Q, Q_m, Q2, B, B_m, info);
    X = out{B_i};
    info = out{info_i};
    error(full_check_out(info, func), 'trisolve');
end

