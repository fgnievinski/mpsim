function [L, U, P] = full_trisolve_gen_aux (Q, p)
    [m,n] = size(Q);
    o = min(m,n);
    L = tril(Q(:  ,1:o),-1) + eye(m,o);
    U = triu(Q(1:o,:  ));
    P = eye(m, m);
    for i=1:o
        temp = P(p(i),:);
        P(p(i),:) = P(i,:);
        P(i,:) = temp;
    end
end

