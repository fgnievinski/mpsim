function A_rcond = full_tricond_sym (A_norm, Q, Q2, uplow)
    [s, m, n, clas, uplow] = full_tricond_check_in (A_norm, Q, Q2, uplow);
    error(s);
    func = [clas(1) 'sycon'];  info_i = 10;  A_rcond_i = 7;
    %func = [func '(H, I, U, I, U, U, U, U, I, I)'];  info_i = 10;  A_rcond_i = 7;
    func = [func '(H, I, u, I, U, U, U, U, I, I)'];  info_i = 9;  A_rcond_i = 6;
      %disp(func)  % DEBUG
    if (m*n == 0)
        A_rcond = cast(Inf, clas);  % similar to rcond([])
        return;
    end
    A_rcond = zeros(1, 1, clas);
    work = zeros(2*m, 1, clas);
    iwork = zeros(m, 1, lapack_int_type());
    info = zeros(1, 1, lapack_int_type());
    % ssycon (&uplow, &n, data, &m, p_data, A_norm_data, A_rcond_data, work, iwork, &info);
    % dsycon (&uplow, &n, data, &m, p_data, A_norm_data, A_rcond_data, work, iwork, &info);
    %func  % DEBUG
    out = lapack(func, uplow, n, Q, m, Q2, A_norm, A_rcond, work, iwork, info);
    A_rcond = out{A_rcond_i};
    info = out{info_i};
    error(full_check_out(info, func), 'tricond');
end

