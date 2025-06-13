function A_rcond = full_tricond_gen (A_norm, Q, Q2)
    [s, m, n, clas] = full_tricond_check_in (A_norm, Q, Q2);
    error(s);
    func = [clas(1) 'gecon'];  info_i = 9;  A_rcond_i = 6;
    %func = [func '(H, I, U, I, U, U, U, I, I)'];  info_i = 9;  A_rcond_i = 6;
    func = [func '(H, I, u, I, U, U, U, I, I)'];  info_i = 8;  A_rcond_i = 5;
      %disp(func)  % DEBUG
    if (m*n == 0)
        A_rcond = cast(Inf, clas);  % similar to rcond([])
        return;
    end
    norm = '1';
    A_rcond = zeros(1, 1, clas);
    work = zeros(4*n, 1, clas);
    iwork = zeros(n, 1, lapack_int_type());
    info = zeros(1, 1, lapack_int_type());
    % dgecon (&norm, &n, data, &m, A_norm_data, A_rcond_data, work, iwork, &info);
    % sgecon (&norm, &n, data, &m, A_norm_data, A_rcond_data, work, iwork, &info);
    %func  % DEBUG
    out = lapack(func, norm, n, Q, m, A_norm, A_rcond, work, iwork, info);
    A_rcond = out{A_rcond_i};
    info = out{info_i};
    error(full_check_out(info, func), 'tricond');
end

