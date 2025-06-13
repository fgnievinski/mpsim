function c = fit2 (A, z, method, varargin)
    if (nargin < 3) || isempty(method),  method = 'backslash';  end
    switch lower(method)
    case {'backslash', 'qr'}
        c = A \ z(:);
    case 'cholesky'
        N = A' * A;
        u = A' * z(:);
        c = N \ u;
    case 'regularized cholesky'
        %disp('hw!')  % DEBUG
        N = A' * A;
        u = A' * z(:);
        C = varargin{1};
        if isscalar(C),  C = C * eye(size(A,2));  end
        C_inv = inv(C);
        N2 = N + C_inv;
        c = N2 \ u;
    case {'regularized backslash', 'regularized qr'}
        %disp('hw!')  % DEBUG
        % build augmented left- and right-hand sides,
        % where a priori state covariance matrix 
        % enters as an observation equation:
        m = size(A,2);
        C = varargin{1};
        if isscalar(C),  C = C * eye(m);  end
        C_chol = chol2(C, 'lower');
        C_chol_inv = C_chol \ eye(m);
        A2 = vertcat(C_chol_inv, A);
        z2 = vertcat(zeros(m,1), z(:));
        c = A2 \ z2;
        %% orthogonalize augmented design matrix:
        %[Q, R] = qr(A2, 0);
        %% solve linear system:
        %c = R \ (Q' * z2);
    case {'regularized iterative', 'iterative'}
        c = lsqr(A, z(:), varargin{:});
    otherwise
        error('matlab:fit2:unkMethod', 'Unknown method "%s".', method);
    end
end    

