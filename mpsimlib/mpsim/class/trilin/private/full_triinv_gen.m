function X = full_triinv_gen (Q, Q2)
    [s, m, n, clas] = full_triinv_check_in (Q, Q2);
    error(s);
    func = [clas(1) 'getri'];  X_i = 2;  info_i = 7;  work_i = 5;
    %func = [func '(I, U, I, I, U, I, I)'];  X_i = 2;  info_i = 7;  work_i = 5;
    %func = [func '(I, U, I, I, u, I, I)'];  X_i = 2;  info_i = 6;  work_i = 4;  % EXPERIMENTAL --- WILL CRASH MATLAB!!!
    % so, yes, the work argument is being duplicated by lapack.c;
    % that's not optimum, but at least it's not too bad since work
    % is never too big -- at least I like to think so.
      %disp(func)  % DEBUG
    if (m*n == 0)
        X = zeros(m, n, clas);
        return;
    end
    info = zeros(1, 1, lapack_int_type());

    work = zeros(1, 1, clas);
    lwork = cast(-1, lapack_int_type());
    out = lapack(func, m, Q, n, Q2, work, lwork, info);
    info = out{info_i};
    error(full_trifactor_check_out(info, func));
    work = out{work_i};
    lwork = cast(work(1), lapack_int_type());
    work = zeros(lwork, 1, clas);
      %disp(lwork)  % DEBUG
    
    % sgetri (&n, data, &n, p_data, work, &lwork, &info);
    % dgetri (&n, data, &n, p_data, work, &lwork, &info);
    out = lapack(func, m, Q, n, Q2, work, lwork, info);
    X = out{X_i};
    info = out{info_i};
    error(full_check_out(info, func), 'triinv');
end

