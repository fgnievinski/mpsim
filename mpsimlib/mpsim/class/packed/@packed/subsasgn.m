function answer = subsasgn (A, s, B_original)
    myassert (ispacked(A));
    B = B_original;

    if (ndims(B) > 2), B = B(:);  end
    error (check_subs (A, s, 'packed:subsasgn', B));

    %% convert user indices to linear packed indices:
    [user_ind_pkd, ZERO_IND, user_idx] = get_ind_pkd (A, s);

    %% trying to resize matrix?
    if any(size(user_idx) > order(A))
        %answer = full(A);
        %answer(s.subs{:}) = B_original;
        answer = subsasgn(full(A), s, B_original);
        return;
    end        

    if isscalar(B),  B = repmat(B, size(user_ind_pkd));  end
    B = full(B(:));

    %% trying to set elements in zero triangular part to non-zero values?
    ZERO_IDX = (user_ind_pkd == ZERO_IND);
    if istri_type(A) && any(ZERO_IDX) && nnz(B(ZERO_IDX)) > 0
        % any(temp)  % trying to set elements in zero triang. part
        % nnz(B(temp)) > 0  % trying to set those elements to non-zero values
        answer = subsasgn(full(A), s, B_original);
        return;
    end

    %% trying to set symmetrical elements to different values?
    if issym_type(A) ...
      && ~( issym(user_idx) && issym_packed_values (user_ind_pkd, B) ) ...
      && ~issym_packed_values (...  
            [user_ind_pkd; user_ind_pkd], [B; A.data(user_ind_pkd)]) 
        % The first condition reads: if user specified values have 
        % symmetric positions and equal values in symmetric positions.
        % The second condition reads: if user specified values have NOT  
        % symmetric positions yet have, in combination with the values 
        % already present in the matrix, equal values in symmetric positions.
        % Please note that those two conditions above are negated.
        answer = subsasgn(full(A), s, B_original);
        return;
    end
        
    %% set data:
    answer = A;
    answer.data(user_ind_pkd(~ZERO_IDX)) = B(~ZERO_IDX);
    myassert (all(B(ZERO_IDX) == 0));
end

function answer = issym_packed_values (user_ind_pkd, values)
    temp = [double(user_ind_pkd), double(values)];
    answer =    size(unique(temp, 'rows'), 1) ...
             == size(unique(user_ind_pkd), 1);
end


%!test
%! % subsasgn
%! warning('off', 'test:noFuncCall');

%!test
%! A_full = [];
%! A = packed;
%! 
%! A_full(:) = pi;
%! A(:) = pi;
%! 
%! ispacked(A);
%! myassert (isempty(A_full));
%! myassert (isempty(A));
%! myassert (A, A_full);

%!test
%! A_full = [];
%! A = packed;
%! 
%! A_full(1) = pi;
%! A(1) = pi;
%! 
%! myassert (~ispacked(A));
%! myassert (A, A_full);

%!test
%! for type = {'tri', 'sym'},  type = type{:};
%! for uplow = {'u', 'l'},  uplow = uplow{:};
%! for precision = {...
%!     'double', 'single', ...
%!     'int8', 'uint8',  ...
%!     'int16', 'uint16',  ...
%!     'int32', 'uint32',  ...
%!     'logical', 'char'}
%! %    'int64', 'uint64', ...  % Function 'transpose' is not defined for
%!                              % values of class 'uint64'.
%!     precision = precision{:};
%! 
%! while true
%!     n = round(10*rand);
%!     if (n > 2),  break;  end
%! end
%! 
%! p = rand;
%! 
%! if strcmp(type, 'sym')
%!     A_full = randsym(n);
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!     A_full = triu(rand(n));
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!     A_full = tril(rand(n));
%! end
%! 
%! if strcmp(precision, 'char') || strcmp(precision, 'logical')
%!     % to avoid warning msgs saying p was truncated in subsasgn.
%!     A_full = round(A_full);
%!     p = round(p);
%! end
%! A_full = cast(A_full, precision);
%! 
%! A = packed(A_full, type, uplow);
%! myassert (ispacked(A));
%! myassert (isa(A, precision));
%! 
%! 
%! %% if (ndims(B) > 2), B = B(:);  end
%! A_full2 = A_full;  A2 = A;
%! m = floor(nthroot(n, 3));
%!     myassert (m^3 <= n);
%! A_full2(1:m^3) = zeros(m, m, m);
%! A2(1:m^3) = zeros(m, m, m);
%! myassert (A2, A_full2);
%! 
%! %% if any(size(user_idx) > order(A))
%! A_full2 = A_full;  A2 = A;
%! A_full2(1:n+1, 1:n+1) = p;
%! A2(1:n+1, 1:n+1) = p;
%! myassert (~ispacked(A2));
%! myassert (A2, A_full2);
%! 
%! %% if isscalar(B),  B = repmat(B, size(user_ind_pkd));  end
%! A_full2 = A_full;  A2 = A;
%! A_full2(:,:) = p;
%! A2(:,:) = p;
%! myassert (A2, A_full2);
%! 
%! %% B = full(B(:));
%! A_full2 = A_full;  A2 = A;
%! lasterr ('', '');
%! try
%!     A_full2(:,:) = sparse(n,n);
%! catch
%!     s = lasterror; 
%!     if ~strend('unimplementedSparseType', s.identifier)
%!         rethrow(s);
%!     end
%!     
%!     % packed implementation should give the same error as full:
%!     lasterr ('', '');
%!     try
%!         A2(:,:) = sparse(n,n);
%!     catch
%!         s = lasterror; 
%!         if ~strend('unimplementedSparseType', s.identifier)
%!             rethrow(s);
%!         end
%!     end
%! end
%!      
%! %% if isup(A) && ...
%! %% if istri_type(A) && any(ZERO_IDX) && nnz(B(ZERO_IDX)) > 0
%! A_full2 = A_full;  A2 = A;
%! A_full2(end,1) = 1;
%! A2(end,1) = 1;
%! if strcmp(type, 'tri') && strcmp(uplow, 'u')
%!     myassert(~ispacked(A2));
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'sym')
%!     % A2 can be either packed or not.
%! end
%! myassert(A2, A_full2);
%! 
%! %% if islow(A) && ...
%! %% if istri_type(A) && any(ZERO_IDX) && nnz(B(ZERO_IDX)) > 0
%! A_full2 = A_full;  A2 = A;
%! A_full2(1, end) = 1;
%! A2(1, end) = 1;
%! if strcmp(type, 'tri') && strcmp(uplow, 'l')
%!     myassert(~ispacked(A2));
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'sym')
%!     % A2 can be either packed or not.
%! end
%! myassert(A2, A_full2);
%! 
%! %% if isup(A) && ...
%! %% if istri_type(A) && any(ZERO_IDX) && ~ (nnz(B(ZERO_IDX)) > 0)  % SEE NOT
%! A_full2 = A_full;  A2 = A;
%! A_full2(end,1) = 0;
%! A2(end,1) = 0;
%! if strcmp(type, 'tri') && strcmp(uplow, 'u')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'sym')
%!     % A2 can be either packed or not.
%! end
%! myassert(A2, A_full2);
%! 
%! %% if islow(A) && ...
%! %% if istri_type(A) && any(ZERO_IDX) && ~ (nnz(B(ZERO_IDX)) > 0)  % SEE NOT
%! A_full2 = A_full;  A2 = A;
%! A_full2(1, end) = 0;
%! A2(1, end) = 0;
%! if strcmp(type, 'tri') && strcmp(uplow, 'l')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'sym')
%!     % A2 can be either packed or not.
%! end
%! myassert(A2, A_full2);
%!
%! 
%! %% if issym_type(A) ...
%! %%   && ~( issym(user_idx) && issym_packed_values (user_ind_pkd, B) ) ...
%! A_full2 = A_full;  A2 = A;
%! idx = false(size(A));
%! idx(end,1) = true;
%! idx(1,end) = true;
%! B = [1, 1];
%! A_full2(idx) = B;
%! A2(idx) = B;
%! if strcmp(type, 'sym')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'tri')
%!     myassert(~ispacked(A2));
%! end
%! myassert(A2, A_full2);
%! 
%! %% if issym_type(A) ...
%! %%   && ~issym_packed_values (...  
%! %%         [user_ind_pkd; user_ind_pkd], [B; A.data(user_ind_pkd)]) 
%! A_full2 = A_full;  A2 = A;
%! idx = false(size(A));
%! idx(end,1) = true;
%! B = A_full(1,end);
%! A_full2(idx) = B;
%! A2(idx) = B;
%! if strcmp(type, 'sym')
%!     myassert(ispacked(A2));
%! elseif strcmp(type, 'tri')
%!     % do nothing.
%! end
%! myassert(A2, A_full2);
%! 
%! end
%! end
%! end

%!test
%! A = packed(eye(2), 'sym');
%! A_full = full(A);
%! ind = sub2ind(size(A), [1, 2], [2, 1]);
%! B = [0, 0.1];
%! A(ind) = B;
%! A_full(ind) = B;
%! myassert (A_full, [1 0; 0.1 1]);
%! myassert(~ispacked(A));
%! myassert (A, A_full);
%! % in issym_packed_values (), if we do simply
%! %     temp = [user_ind_pkd, values];
%! % values == B get wrongly downcasted to [0 0].

%!test
%! warning('on', 'test:noFuncCall');

