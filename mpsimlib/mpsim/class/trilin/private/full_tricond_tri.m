function A_rcond = full_tricond_tri (A_norm, Q, uplow)
    [s, m, n, clas, uplow] = full_tricond_check_in (A_norm, Q, nan, uplow);
    error(s);
    func = [clas(1) 'trcon'];  info_i = 10;  A_rcond_i = 7;
    %func = [func '(H, H, H, I, U, I, U, U, I, I)'];  info_i = 10;  A_rcond_i = 7;
%    func = [func '(H, H, H, I, u, I, U, U, I, I)'];  info_i = 9;  A_rcond_i = 6;
      %disp(func)  % DEBUG
    if (m*n == 0)
        A_rcond = cast(Inf, clas);  % similar to rcond([])
        return;
    end
    norm = '1';
    diag = 'N';
    A_rcond = zeros(1, 1, clas);
    work = zeros(3*m, 1, clas);
    iwork = zeros(m, 1, lapack_int_type());
    info = zeros(1, 1, lapack_int_type());
    % strcon (&norm, &uplow, &diag, &n, data, &m, A_rcond_data, work, iwork, &info);
    % dtrcon (&norm, &uplow, &diag, &n, data, &m, A_rcond_data, work, iwork, &info);
    %func  % DEBUG
    out = lapack(func, norm, uplow, diag, n, Q, m, A_rcond, work, iwork, info);
    A_rcond = out{A_rcond_i};
    info = out{info_i};
    error(full_check_out(info, func), 'tricond');
end

