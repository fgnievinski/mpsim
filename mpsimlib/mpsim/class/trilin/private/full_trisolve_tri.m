function X = full_trisolve_tri (B, Q, uplow, trans)
    if (nargin < 3),  uplow = [];  end
    if (nargin < 4),  trans = [];  end
    [s, B_m, B_n, Q_m, Q_n, clas, uplow, trans] = full_trisolve_check_in (B, Q, NaN, uplow, trans);
    error(s);
    func = [clas(1) 'trtrs'];  B_i = 8;  info_i = 10;
    % now make it avoid copying Q:
    func = [func '(H, H, H, I, I, u, I, U, I, I)'];  B_i = 7;  info_i = 9;
      %disp(func)  % DEBUG
    if (B_m*B_n == 0)
        X = zeros(B_m, B_n, clas);
        return;
    end
    diag = 'N';
    info = zeros(1, 1, lapack_int_type());
    % strtrs (&uplow, &trans, &diag, &Q_n, &B_n, Q_data, &Q_m, B_data, &B_m, &info);
    % dtrtrs (&uplow, &trans, &diag, &Q_n, &B_n, Q_data, &Q_m, B_data, &B_m, &info);
    out = lapack(func, uplow, trans, diag, Q_n, B_n, Q, Q_m, B, B_m, info);
    X = out{B_i};
    info = out{info_i};
    error(full_check_out(info, func), 'trisolve');
end

