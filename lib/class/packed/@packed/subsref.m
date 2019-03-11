function answer = subsref (A, s)
    error (check_subs (A, s, 'packed:subsref'));

    %% convert user indices to linear packed indices:
    [user_ind_pkd, ZERO_IND] = get_ind_pkd (A, s);
    
    %% calculate size of user matrix:
    temp = sparse(order(A), order(A));
    user_size = size(subsref(temp, s));

    %% get data:
    idx = (user_ind_pkd == ZERO_IND);    
    user_ind_pkd(idx) = uint32(1);  % set to any valid index.
        
    temp = A.data(user_ind_pkd);
    temp(idx) = cast(0, class(A));  % set zero triangular part.
    answer = reshape(temp, user_size);
        myassert(class(answer), class(A));

    user_ind_pkd(idx) = ZERO_IND;
        
    %% keep data packed, if possible:
    temp = reshape(user_ind_pkd, user_size);
    if ~issquare(temp),  return;  end
    % test only most probable cases:
    if issym_type (A) && issym (temp)
        answer = packed (answer, 'sym');
    elseif istri_type (A) && isup (A) && istriu(temp)
        answer = packed (answer, 'tri', 'u');
    elseif istri_type (A) && islow (A) && istril(temp)
        answer = packed (answer, 'tri', 'l');
    end
        
end

%!test
%! % subsref
%! warning('off', 'test:noFuncCall');

%!shared
%! A = packed([]);

%!error
%! % multiples references:
%! lasterr('', '');
%! A(1).abc{2}

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:improperIndexMatrixRef');

%!error
%! % cell ref.
%! lasterr('', '');
%! A{1}

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:cellRefFromNonCell');

%!error
%! % multiple cell ref.
%! % here it seems matlab uses the overloaded numel()
%! lasterr('', '');
%! A{1,1}

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:cellRefFromNonCell');

%!error
%! % struct. ref.
%! lasterr('', '');
%! A.data

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:nonStrucReference');

%!shared  % (just to clear previous %!shared)


%!shared
%! while true
%!     n = round(rand*10);
%!     if (n > 1),  break;  end
%! end
%! A_full = randsym(n);
%! A = packed(A_full);
%! myassert(ispacked(A));

%!error
%! lasterr('', '');
%! A(0, 0)

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:badsubscript');


%!error
%! lasterr('', '');
%! A(n+1, n+1)

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:badsubscript');


%!error
%! lasterr('', '');
%! A(1,1,2)

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:PackedSubLimitTwoDims');


%!error
%! lasterr('', '');
%! A(1,1,1);
%! A(1,1,1,1);
%! A(1,1,1,1,1);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:PackedSubLimitTwoDims');

%!shared  % (just to clear previous %!shared)


%!shared
%! A = packed([]);

%!error
%! lasterr('', '');
%! temp = A(1);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:badsubscript');

%!test
%! temp = A(:);
%! myassert (isempty(temp));
%! myassert (size(temp), [0, 1]);

%!test
%! temp = A(:, :);
%! myassert (isempty(temp));
%! myassert (size(temp), [0, 0]);

%!error
%! lasterr('', '');
%! temp = A(:, :, :);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:subsref:PackedSubLimitTwoDims');

%!shared  % (just to clear previous %!shared)


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
%!     while true
%!         n = round(10*rand);
%!         if (n > 2),  break;  end
%!     end
%! 
%!     if strcmp(type, 'sym')
%!         A_full = randsym(n);
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!         A_full = triu(rand(n));
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!         A_full = tril(rand(n));
%!     end
%!     
%!     if strcmp(precision, 'logical')
%!         A_full = round(A_full);
%!     end
%!     A_full = cast(A_full, precision);
%! 
%!     A = packed(A_full, type, uplow);
%!     myassert (ispacked(A));
%!     myassert (isa(A, precision));
%! 
%!     
%!     %% single index
%!     
%!     % single colon index:
%!     myassert (A_full(:), A(:));
%!     
%!     % single linear index:
%!     for i=1:ceil(numel(A)/5):numel(A);
%!         myassert (A_full(i), A(i));
%!     end
%!     
%!     % single linear index, multiple values:
%!     for i=1:ceil(numel(A)/5):numel(A);
%!         myassert (A_full(1:i), A(1:i));
%!     end
%!     
%!     % single matrix logical index:
%!     idx = rand(n) > 0.5;  myassert(islogical(idx));
%!     myassert (A_full(idx), A(idx));
%!     
%!     % single vector logical index:
%!     idx = rand(n, 1) > 0.5;
%!     myassert(islogical(idx));
%!     myassert (A_full(idx), A(idx));
%!
%!     % subscripts:
%!     for i=1:ceil(n/2):n
%!         for j=1:ceil(n/2):n
%!             myassert (A_full(i,j), A(i,j));
%!             
%!             % linear index:
%!             ind = sub2ind([n,n], i, j);
%!             myassert (A_full(ind), A(ind));
%!         end
%!     end
%! 
%!     % multiple subscripts:
%!     myassert (A_full(1:n,1:n), A(1:n,1:n));
%! 
%!     % colon index:
%!     myassert (A_full(:, :), A(:, :));
%!
%!     % matrix logical index:
%!     idx = rand(n) > 0.5;
%!     myassert(islogical(idx));
%!     myassert (A_full(idx), A(idx));
%! 
%!     % vector logical index:
%!     idx1 = rand(n, 1) > 0.5;
%!     idx2 = rand(n, 1) > 0.5;
%!     myassert(islogical(idx) & islogical(idx2));
%!     myassert (A_full(idx1, idx2), A(idx1, idx2));
%! 
%!     % mixed index types:
%!     ind = 1:(ceil(n/2));
%!     idx = rand(n, 1) > 0.5;
%! 
%!     myassert (A_full(ind, ind), A(ind, ind));
%!     myassert (A_full(ind, idx), A(ind, idx));
%!     myassert (A_full(ind,   :), A(ind,   :));
%!     myassert (A_full(idx, ind), A(idx, ind));
%!     myassert (A_full(idx, idx), A(idx, idx));
%!     myassert (A_full(idx,   :), A(idx,   :));
%!     myassert (A_full(  :, ind), A(  :, ind));
%!     myassert (A_full(  :, idx), A(  :, idx));
%!     myassert (A_full(  :,   :), A(  :,   :));
%! 
%!     myassert (A_full(ind, ind), A(ind, ind));
%!     myassert (A_full(idx, ind), A(idx, ind));
%!     myassert (A_full(  :, ind), A(  :, ind));
%!     myassert (A_full(ind, idx), A(ind, idx));
%!     myassert (A_full(idx, idx), A(idx, idx));
%!     myassert (A_full(  :, idx), A(  :, idx));
%!     myassert (A_full(ind,   :), A(ind,   :));
%!     myassert (A_full(idx,   :), A(idx,   :));
%!     myassert (A_full(  :,   :), A(  :,   :));
%! 
%! end
%! end
%! end


%!test
%! A = packed(cast(randsym(3), 'single'));
%! myassert (isa(A(:), 'single'));

%!test
%! A = packed(eye(4));
%! myassert (ispacked(A(1:2, 1:2)));
%! myassert (~ispacked(A(1:2,:)));
%! myassert (~ispacked(A(1:2, 3:4)));

%!test
%! warning('on', 'test:noFuncCall');

