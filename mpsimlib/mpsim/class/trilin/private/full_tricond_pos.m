function A_rcond = full_tricond_pos (A_norm, Q, uplow)
    [s, m, n, clas, uplow] = full_tricond_check_in (A_norm, Q, nan, uplow);
    error(s);
    func = [clas(1) 'pocon'];  info_i = 9;  A_rcond_i = 6;
    %func = [func '(H, I, U, I, U, U, U, I, I)'];  info_i = 9;  A_rcond_i = 6;
    func = [func '(H, I, u, I, U, U, U, I, I)'];  info_i = 8;  A_rcond_i = 5;
      %disp(func)  % DEBUG
    if (m*n == 0)
        A_rcond = cast(Inf, clas);  % similar to rcond([])
        return;
    end
    A_rcond = zeros(1, 1, clas);
    work = zeros(3*m, 1, clas);
    iwork = zeros(m, 1, lapack_int_type());
    info = zeros(1, 1, lapack_int_type());
    % spocon (&uplow, &Q_n, Q_data, &Q_m, A_norm_data, A_rcond_data, work, iwork, &info);
    % dpocon (&uplow, &Q_n, Q_data, &Q_m, A_norm_data, A_rcond_data, work, iwork, &info);
    %func  % DEBUG
    out = lapack(func, uplow, n, Q, m, A_norm, A_rcond, work, iwork, info);
    A_rcond = out{A_rcond_i};
    info = out{info_i};
    error(full_check_out(info, func), 'tricond');
end

