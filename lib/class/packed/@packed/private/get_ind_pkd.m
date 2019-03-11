function [user_ind_pkd, ZERO_IND, user_idx] = get_ind_pkd (A, s)
    myassert(length(s) == 1);
    myassert(strcmp(s.type, '()'));
    myassert(length(s.subs) <= 2);
    if (length(s.subs) == 2)
        myassert(isscalar(s.subs{1}) || isvector(s.subs{1}));
        myassert(isscalar(s.subs{2}) || isvector(s.subs{2}));
    end
    
    user_idx = false(order(A));
    user_idx = subsasgn(user_idx, s, true);
    if any(size(user_idx) > order(A))
        % user is trying to resize matrix.
        user_ind_pkd = [];
        ZERO_IND = [];
        return;
    end
    if isempty(A),  user_idx = logical([]);  end  % do we really need this?

    temp = uint32(1):uint32(numeltri(A));
    all_ind_pkd = full(packed(temp, A.type, A.uplow));
        myassert(isa(all_ind_pkd, 'uint32'));
    ZERO_IND = uint32(0);  % invalid index pointing to zero triangular part.

    user_ind_pkd = all_ind_pkd(user_idx);
end

