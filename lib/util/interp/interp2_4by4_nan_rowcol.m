function z = interp2_4by4_nan_rowcol (...
row_ind, col_ind, X_domain, Y_domain, Z, x, y)
    assert(isvector(X_domain) && isvector(Y_domain))
    if ( all(all(~isnan(row_ind))) && all(all(~isnan(col_ind))) )
        z = interp2_4by4_cubic (...
            X_domain(col_ind), Y_domain(row_ind), Z, x, y);
        return;
    end

    row_isnan = isnan(row_ind);
    col_isnan = isnan(col_ind);
    row_numnonnan = sum(~row_isnan, 2);
    col_numnonnan = sum(~col_isnan, 2);

    temp = [...
        4 4
        4 3
        3 4
        3 3
        3 2
        2 3
        2 2
    ];
    num_pts = size(Z,3);
    z = NaN(num_pts,1);
    idx_old = false(num_pts,1);
    for i=1:size(temp,1)
        [z2, idx] = interp2_4by4_nan_rowcol_helper (...
            row_ind, col_ind, X_domain, Y_domain, Z, x, y, ...
            temp(i,1), temp(i,2), ...
            row_isnan, col_isnan, row_numnonnan, col_numnonnan);
        z(idx) = z2;
        if all(idx | idx_old),  return;  end
        idx_old = idx;
    end
end

function [z2, idx] = interp2_4by4_nan_rowcol_helper (...
row_ind, col_ind, X_domain, Y_domain, Z, x, y, ...
m, n, row_isnan, col_isnan, row_numnonnan, col_numnonnan)
    idx = ( (row_numnonnan == m) & (col_numnonnan == n) );
    if ~any(idx),  z2 = [];  return;  end
    row_ind2 = row_ind(idx,:);
    col_ind2 = col_ind(idx,:);
    row_isnan2 = row_isnan(idx,:);
    col_isnan2 = col_isnan(idx,:);
    temp1 = repmat(frontal_transpose(frontal_pt(row_isnan2)), [1,4,1]);
    temp2 = repmat(frontal_pt(col_isnan2), [4,1,1]);
    temp = ~( temp1 | temp2 );
    Z2 = Z(:,:,idx);
    Z2 = reshape(Z2(temp), [m,n,sum(idx)]);
    X2 = reshape(X_domain(getel(col_ind2',~col_isnan2')), n,sum(idx))';
    Y2 = reshape(Y_domain(getel(row_ind2',~row_isnan2')), m,sum(idx))';
    z2 = interp2_mbyn (X2, Y2, Z2, x(idx), y(idx), m, n);
end

%!test
%! n = 4;
%! N = 6;
%! Z = rand(n,n,N);
%! DX = rand;
%! DY = rand;
%! p = 10;
%! X_domain = rand + DX.*(0:p-1);
%! Y_domain = rand + DY.*(0:p-1);
%! row_ind = min(ceil(p*rand), p-n) + repmat(1:n, N,1);
%! col_ind = min(ceil(p*rand), p-n) + repmat(1:n, N,1);
%! X = X_domain(col_ind);
%! Y = Y_domain(row_ind);
%! x = randint(X(:,1), X(:,n));
%! y = randint(Y(:,1), Y(:,n));
%! z = NaN(N,1);
%! 
%! % first grid has whole 4-by-4 valid:
%! i = 1;
%! z(i) = interp2_mbyn (X(i,:), Y(i,:), Z(:,:,i), x(i), y(i), 4, 4);
%! 
%! % second grid has south-west 3-by-3 valid:
%! i = 2;
%! row_ind(i,1) = NaN;
%! col_ind(i,1) = NaN;
%! x(i) = randint(X(i,2), X(i,4));
%! y(i) = randint(Y(i,2), Y(i,4));
%! z(i) = interp2_mbyn (X(i,2:4), Y(i,2:4), Z(2:4,2:4,i), x(i), y(i), 3, 3);
%! 
%! % third grid has north-east 3-by-3 valid:
%! i = 3;
%! row_ind(i,4) = NaN;
%! col_ind(i,4) = NaN;
%! x(i) = randint(X(i,1), X(i,3));
%! y(i) = randint(Y(i,1), Y(i,3));
%! z(i) = interp2_mbyn (X(i,1:3), Y(i,1:3), Z(1:3,1:3,i), x(i), y(i), 3, 3);
%! 
%! % fourth grid has center 2-by-2 valid:
%! i = 4;
%! row_ind(i,1) = NaN;
%! col_ind(i,1) = NaN;
%! row_ind(i,4) = NaN;
%! col_ind(i,4) = NaN;
%! x(i) = randint(X(i,2), X(i,3));
%! y(i) = randint(Y(i,2), Y(i,3));
%! z(i) = interp2_mbyn (X(i,2:3), Y(i,2:3), Z(2:3,2:3,i), x(i), y(i), 2, 2);
%! 
%! % fifth grid has south-east 2-by-2 valid:
%! i = 5;
%! row_ind(i,1) = NaN;
%! row_ind(i,2) = NaN;
%! col_ind(i,3) = NaN;
%! col_ind(i,4) = NaN;
%! x(i) = randint(X(i,1), X(i,2));
%! y(i) = randint(Y(i,3), Y(i,4));
%! z(i) = interp2_mbyn (X(i,1:2), Y(i,3:4), Z(3:4,1:2,i), x(i), y(i), 2, 2);
%! 
%! % sixth grid has north 3-by-4 valid:
%! i = 6;
%! row_ind(i,1) = NaN;
%! x(i) = randint(X(i,1), X(i,4));
%! y(i) = randint(Y(i,2), Y(i,4));
%! z(i) = interp2_mbyn (X(i,1:4), Y(i,2:4), Z(2:4,1:4,i), x(i), y(i), 3, 4);
%! 
%! tic = cputime;
%! %row_ind, col_ind, X_domain, Y_domain, Z, x, y  % DEBUG
%! z2 = interp2_4by4_nan_rowcol (row_ind, col_ind, X_domain, Y_domain, Z, x, y);
%! toc = cputime - tic;
%! 
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));

