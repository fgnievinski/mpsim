function X = full_trisolve_sym (B, Q, Q2, uplow)
    if (nargin < 4),  uplow = [];  end
    [s, B_m, B_n, Q_m, Q_n, clas, uplow] = full_trisolve_check_in (B, Q, Q2, uplow);
    error(s);
    func = [clas(1) 'sytrs'];  B_i = 7;  info_i = 9;
    % now make it avoid copying Q:
    func = [func '(H, I, I, u, I, I, U, I, I)'];  B_i = 6;  info_i = 8;
      %disp(func)  % DEBUG
    if (B_m*B_n == 0)
        X = zeros(B_m, B_n, clas);
        return;
    end
    info = zeros(1, 1, lapack_int_type());
    % ssytrs (&uplow, &Q_n, &B_n, Q_data, &Q_m, p_data, B_data, &B_m, &info);
    % dsytrs (&uplow, &Q_n, &B_n, Q_data, &Q_m, p_data, B_data, &B_m, &info);
    out = lapack(func, uplow, Q_n, B_n, Q, Q_m, Q2, B, B_m, info);
    X = out{B_i};
    info = out{info_i};
    error(full_check_out(info, func), 'trisolve');
end

