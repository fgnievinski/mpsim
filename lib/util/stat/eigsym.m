function [V, d] = eigsym (A, k, force_sparse, discard_neg_small, discard_neg_all)
    if (nargin < 2) || isempty(k),  k = length(A);  end
    if (nargin < 3) || isempty(force_sparse),  force_sparse = false;  end
    if (nargin < 4) || isempty(discard_neg_small),  discard_neg_small = true;  end
    if (nargin < 5) || isempty(discard_neg_all),  discard_neg_all = false;  end
    assert(isscalar(k))
    force_dense = false;
    if isnan(force_sparse),  force_dense = true;  force_sparse = false;  end
    if ~force_dense && (k < length(A)) || force_sparse
        [V, D] = eigs(A, [], k, 'lm', struct('issym',true));
        %disp('hw1')  % DEBUG
    else
        [V, D] = eig(A);
        %disp('hw2')  % DEBUG
    end
    d = diag(D);
    if discard_neg_small
        d(-eps(class(d)) < d & d < 0) = 0;
    end
    if discard_neg_all
        d(d < 0) = 0;
    end
    %[d, ind] = sort(d, 'descend');
    %V = V(ind,:);
end

