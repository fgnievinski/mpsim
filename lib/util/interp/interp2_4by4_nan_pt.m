function [z, num_valid] = interp2_4by4_nan_pt (X, Y, Z, x, y)
    [m,n,num_pts] = size(Z);
    z = NaN(num_pts,1);
    nan_idx = isnan(Z);

    %% points with no missing data are interpolated bicubically:
    notanynan_idx = ~(any(any(nan_idx,1),2));
    z(notanynan_idx) = interp2_4by4_cubic (...
        X(notanynan_idx,:), Y(notanynan_idx,:), ...
        Z(:,:,notanynan_idx), ...
        x(notanynan_idx), y(notanynan_idx));
    if all(notanynan_idx)
        num_valid = repmat(4*4,num_pts,1);
        return;
    end

    %% when there is a NaN, we discard the whole corresponding column and row:
    colnan_idx = any(nan_idx,1);
    rownan_idx = any(nan_idx,2);
    rowcolnan_idx = repmat(rownan_idx, [1,n,1]) | repmat(colnan_idx, [m,1,1]);
    num_valid = sum(sum(~rowcolnan_idx,1),2);

    %% points with all 4-by-4 nodes valid were already interp'ed bi-cubically:
    idx = (num_valid == 4*4);
    myassert(sum(idx) == sum(notanynan_idx))

    %% points with 3-by-3 nodes valid are to be interpolated bi-quadratically:
    idx = (num_valid == 3*3);
    if any(idx)
        N = sum(idx);
        idx_Z = repmat(idx, [m,n,1]) & ~rowcolnan_idx;
        idx_X = defrontal_pt(repmat(idx, [1,4]) & ~colnan_idx);
        idx_Y = defrontal_pt(frontal_transpose(repmat(idx, [4,1]) & ~rownan_idx));
        z(idx) = interp2_3by3_quadratic (...
            reshape(getel(X',idx_X'), 3,N)', ...
            reshape(getel(Y',idx_Y'), 3,N)', ...
            reshape(Z(idx_Z), [3,3,N]), ...
            x(idx), y(idx));
    end
    
    %% points with 2-by-2 nodes valid are to be interpolated bi-linearly:
    idx = (num_valid == 2*2);
    if any(idx)
        N = sum(idx);
        idx_Z = repmat(idx, [m,n,1]) & ~rowcolnan_idx;
        idx_X = defrontal_pt(repmat(idx, [1,4]) & ~colnan_idx);
        idx_Y = defrontal_pt(frontal_transpose(repmat(idx, [4,1]) & ~rownan_idx));
        z(idx) = interp2_2by2_linear (...
            reshape(getel(X',idx_X'), 2,N)', ...
            reshape(getel(Y',idx_Y'), 2,N)', ...
            reshape(Z(idx_Z), [2,2,N]), ...
            x(idx), y(idx));
    end

    %% points with no nodes valid are not to be interpolated:
    %idx = (num_valid == 0);  % (do nothing -- leave them as NaN.)

    num_valid = permute(num_valid, [3,2,1]);
end

%!test
%! n = 4;
%! N = 5;
%! Z = rand(n,n,N);
%! DX = rand;
%! DY = rand;
%! X = repmat(rand(N,1), 1,n) + repmat(DX.*(0:n-1), N, 1);
%! Y = repmat(rand(N,1), 1,n) + repmat(DY.*(0:n-1), N, 1);
%! x = randint(X(:,1), X(:,n));
%! y = randint(Y(:,1), Y(:,n));
%! z = NaN(N,1);
%! num_valid = NaN(N,1);
%! 
%! % first grid has south-west 3-by-3 valid:
%! i = 1;
%! Z(1,1,i) = NaN;
%! %Z(:,:,i), Z(2:4,2:4,i)  % DEBUG
%! x(i) = randint(X(i,2), X(i,4));
%! y(i) = randint(Y(i,2), Y(i,4));
%! z(i) = interp2_3by3_quadratic(X(i,2:4), Y(i,2:4), Z(2:4,2:4,i), x(i), y(i));
%! num_valid(i) = 3*3;
%! 
%! % second grid has north-east 3-by-3 valid:
%! i = 2;
%! Z(4,4,i) = NaN;
%! x(i) = randint(X(i,1), X(i,3));
%! y(i) = randint(Y(i,1), Y(i,3));
%! z(i) = interp2_3by3_quadratic(X(i,1:3), Y(i,1:3), Z(1:3,1:3,i), x(i), y(i));
%! num_valid(i) = 3*3;
%! 
%! % third grid has center 2-by-2 valid:
%! i = 3;
%! Z(1,1,i) = NaN;
%! Z(4,4,i) = NaN;
%! x(i) = randint(X(i,2), X(i,3));
%! y(i) = randint(Y(i,2), Y(i,3));
%! z(i) = interp2_2by2_linear (X(i,2:3), Y(i,2:3), Z(2:3,2:3,i), x(i), y(i));
%! num_valid(i) = 2*2;
%! 
%! % fourth grid has south-east 2-by-2 valid:
%! i = 4;
%! Z(1,4,i) = NaN;
%! Z(2,3,i) = NaN;
%! %Z(:,:,i)  % DEBUG
%! x(i) = randint(X(i,1), X(i,2));
%! y(i) = randint(Y(i,3), Y(i,4));
%! z(i) = interp2_2by2_linear (X(i,1:2), Y(i,3:4), Z(3:4,1:2,i), x(i), y(i));
%! num_valid(i) = 2*2;
%! 
%! % fifth grid has whole 4-by-4 valid:
%! i = 5;
%! z(i) = interp2_4by4_cubic (X(i,:), Y(i,:), Z(:,:,i), x(i), y(i));
%! num_valid(i) = 4*4;
%! 
%! tic = cputime;
%! [z2, num_valid2] = interp2_4by4_nan_pt (X, Y, Z, x, y);
%! toc = cputime - tic;
%! 
%! %[z, z2, z2-z]  % DEBUG
%! %[num_valid, num_valid2, num_valid2-num_valid]  % DEBUG
%! myassert(z2, z, -sqrt(eps));
%! myassert(num_valid2, num_valid);

