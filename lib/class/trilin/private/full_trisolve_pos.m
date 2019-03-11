function X = full_trisolve_pos (B, Q, uplow)
    if (nargin < 3),  uplow = [];  end
    [s, B_m, B_n, Q_m, Q_n, clas, uplow] = full_trisolve_check_in (B, Q, nan, uplow);
    error(s);
    func = [clas(1) 'potrs'];  B_i = 6;  info_i = 8;
    % now make it avoid copying Q:
    func = [func '(H, I, I, u, I, U, I, I)'];  B_i = 5;  info_i = 7;
      %disp(func)  % DEBUG
    if (B_m*B_n == 0)
        X = zeros(B_m, B_n, clas);
        return;
    end
    info = zeros(1, 1, lapack_int_type());
    % spotrs (&uplow, &Q_n, &B_n, Q_data, &Q_m, B_data, &B_m, &info);
    % dpotrs (&uplow, &Q_n, &B_n, Q_data, &Q_m, B_data, &B_m, &info);
    out = lapack(func, uplow, Q_n, B_n, Q, Q_m, B, B_m, info);
    X = out{B_i};
    info = out{info_i};
    error(full_check_out(info, func), 'trisolve');
end

