function [A, A2] = sphharm_design (pos_sph, n)
    A2 = sphharm_design2 (pos_sph, n);
    [s1, s2, s3] = size(A2);
    % keep only the lower-triangular part of each i-th frontal page A2(:,:,i), 
    % then make each i-th frontal page A2(:,:,i) a row column A(i,:):
    idx = repmat(tril(true(s1,s2)), [1,1,s3]);
    A = A2(idx);
    A = transpose(reshape(A, [], s3));
end

function A = sphharm_design2 (pos_sph, n)
    m = n;
    p = size(pos_sph, 1);

    lat = pos_sph (:,1) * pi/180;
    lon = pos_sph (:,2) * pi/180;

    expmlon = repmat(exp(complex(0, ...
           repmat(reshape(0:m, [1,m+1,1]), [1,1,p]) ...
        .* repmat(reshape(lon, [1,1,p]),   [1,m+1,1]) ...
        )),[n+1,1,1]);
    P = get_legendre_normal_assoc_func (n, sin(lat));
    A = expmlon .* P;
end

