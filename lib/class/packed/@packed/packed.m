function answer = packed (A, type, uplow)
    if (nargin == 0)
        answer = create_packed ([], 0, '', '');
        return;
    elseif iscell(A)
        %warning('packed:packed:badData', ...
        %    'First parameter should be a square matrix or a vector.');
        answer = A;
        return;
    elseif ispacked(A)
        answer = A;
        return;
    elseif isempty(A)
        answer = create_packed (cast([], class(A)), 0, '', '');
        return;
    elseif isscalar(A)
        answer = A;
        return;
    elseif ~isvector(A) && ~issquare(A)
        %warning('packed:packed:badDataSize', ...
        %    'First parameter should be a square matrix or a vector.');
        answer = A;
        return;
    end
    
    if (nargin == 3)
        % do nothing.
    elseif isvector(A) && (nargin == 2)
        error('packed:packed:notEnoughInputs', ...
            ['When first parameter is a vector, type and uplow must'...
            ' be specified.']);
    elseif isvector(A) && (nargin == 1)
        %warning('packed:packed:notEnoughInputs', ...
        %    ['When first parameter is a vector, type and uplow must'...
        %    ' be specified.']);
        answer = A;
        return;
    elseif issquare(A) && (nargin == 2)
        if ~strncmpi(type, 'sym', 3)
            error('packed:packed:notEnoughInputs', ...
                ['When first parameter is a matrix, and type is not'...
                 ' ''sym'', uplow must be specified.']);
        end
        uplow = 'u';
    elseif issquare(A) && (nargin == 1)
        if istriu(A)
            type = 'tri';
            uplow = 'u';
        elseif istril(A)
            type = 'tri';
            uplow = 'l';
        elseif issym(A)
            type = 'sym';
            uplow = 'u';
        else
            % non-packable matrix (has no exploitable structure):
            answer = A;
            return;
        end
    else
        error ('packed:packed', 'Unknown case');
    end

    error(check_type_and_uplow(type, uplow));
    
    if isvector(A)
        data = A;
        % correct size?
        order = get_full_len_by_pkd_len (length(A));
        if isempty(order)
            error('packed:packed:dataSizeNotSquare', ...
                ['A vector having length %d cannot form'...
                ' the triangular part of a square matrix.'], ...
                length(A));
        end
    elseif issquare(A)
        if strncmpi(uplow, 'u', 1)
            idx = triu(true(size(A)));
        elseif strncmpi(uplow, 'l', 1)
            idx = tril(true(size(A)));
        end
        data = A(idx);
        % keep data complex if so:
        if ~isreal(A) && isreal(data),  data = complex(data);  end
        order = size(A, 1);
    end

    answer = create_packed (data, order, type, uplow);
end

function answer = create_packed (data, order, type, uplow)
    if ~isempty(type)
        myassert (length(type) >= 3);
        type = type(1:3);
    end
    if ~isempty(uplow)
        myassert (length(uplow) >= 1);
        uplow = uplow(1);
    end
    
    answer.data  = [];
    answer.order = [];
    answer.type  = [];
    answer.uplow = [];
    answer = class(answer, 'packed');
    answer.data  = full(data(:));
    answer.order = order;
    answer.type  = type;
    answer.uplow = uplow;
    
    % If we try to create the class from an already filled-in structure,
    % Matlab will make a copy of the data fields. To avoid duplicating
    % the data, we shall create the class from an empty but defined 
    % structure and fill it in afterwards.
end

function s = check_type_and_uplow (type, uplow)
    s = [];
    
    if ~strncmpi(type, 'symmetric', 3) && ~strncmpi(type, 'triangular', 3)
        s.identifier = 'packed:packed:badType';
        s.message = sprintf(...
            ['Second parameter (type = %s) should start with '...
             '''sym'' or ''tri'' (symmetric or triangular).'], type);
        return;
    end
    
    if ~strncmpi(uplow, 'up', 1) && ~strncmpi(uplow, 'low', 1)
        s.identifier = 'packed:packed:badUplow';
        s.message = sprintf(...
            ['Third parameter (uplow = %s) should start with '...
             '''u'' or ''l''.'], uplow);
        return;
    end
end

%!error
%! lasterr('', '');
%! packed(1, 2, 3, 4);

%!test
%! % packed
%! s = lasterror;
%! myassert (strendi('tooManyInputs', s.identifier));

%!test
%! % if (nargin == 0):
%! A = packed;
%! myassert (ispacked (A));
%! myassert (isempty (A));
%! myassert (isa (A, 'double'));

%!test
%! % elseif iscell(A):
%! A = packed({1});
%! myassert (~ispacked (A));
%! myassert (iscell (A));

%!test
%! % elseif ispacked(A):
%! A = packed;
%! B = packed(A);
%! myassert (ispacked (B));
%! myassert (isequal (B, A));

%!test
%! % elseif isempty(A):
%! A = packed(single([]));
%! B = packed;
%! myassert (ispacked (A));
%! myassert (isempty (A));
%! myassert (isa (A, 'single'));
%! myassert (isequal (B, A));

%!test
%! % elseif isscalar(A):
%! A = packed(single([5]));
%! myassert (~ispacked (A));
%! myassert (isa (A, 'single'));
%! myassert (A, 5);

%!test
%! % elseif ~issquare(A) && ~isvector(A):
%! A = packed(zeros(3,2));
%! myassert (~ispacked (A));

%!error
%! % elseif isvector(A) && (nargin == 2)
%! lasterr('', '');
%! A = packed(zeros(3, 1), 'sym');

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:packed:notEnoughInputs');

%!test
%! % elseif isvector(A) && (nargin == 1)
%! A = packed(zeros(3, 1));
%! myassert (~ispacked (A));
    
%!error
%! % elseif issquare(A) && (nargin == 2) && ~strncmpi(type, 'sym', 3)
%! lasterr('', '');
%! A = packed(zeros(3, 3), 'tri');

%!test
%! s = lasterror;
%! s.message;
%! myassert (s.identifier, 'packed:packed:notEnoughInputs');

%!test
%! % elseif issquare(A) && (nargin == 2) && strncmpi(type, 'sym', 3)
%! n = 5;
%! A_full = randsym(n);
%! A_packed = packed (A_full, 'sym');
%! myassert (ispacked(A_packed));
%! myassert (issym(A_packed));
%! myassert (full(A_packed), A_full);

%!test
%! % elseif issquare(A) && (nargin == 1):
%! 
%! % non-packed matrix as parameter:
%! % (either full or sparse)
%! n = 100;
%! % packed storage requires less memory than 
%! % full or sparse storage only for 
%! % matrices larger than a threshold:
%! myassert (n >= 100);
%! 
%! for i=1:5
%!     switch i
%!     case 1
%!         % blank matrix:
%!         A_full = zeros(n, n);
%!         j = i;
%!     case 2
%!         % diagonal matrix:
%!         A_full = eye(n, n);
%!         j = i;
%!     case 3
%!         % upper triangular matrix:
%!         temp = rand(n);
%!         A_full = triu(temp);
%!         j = i;
%!     case 4
%!         % lower triangular matrix:
%!         temp = rand(n);
%!         A_full = tril(temp);
%!         j = i;
%!     case 5
%!         % symmetrical matrix:
%!         A_full = randsym(n);
%!         j = i;
%!     end
%!     
%!     A = packed (A_full);
%!     A_sparse = sparse (A_full);
%!     myassert (ispacked (A));
%! 
%!     a = whos('A');
%!     a_full = whos('A_full');
%!     a_sparse = whos('A_sparse');
%! 
%!     switch i
%!     case 1
%!         myassert (isblank(A));
%!         myassert(a.bytes < a_full.bytes);
%!         myassert(a.bytes > a_sparse.bytes);
%!     case 2
%!         myassert (isdiag(A));
%!         myassert(a.bytes < a_full.bytes);
%!         myassert(a.bytes > a_sparse.bytes);
%!     case 3
%!         myassert (istriu(A));
%!         myassert(a.bytes < a_full.bytes);
%!         myassert(a.bytes < a_sparse.bytes);
%!     case 4
%!         myassert (istril(A));
%!         myassert(a.bytes < a_full.bytes);
%!         myassert(a.bytes < a_sparse.bytes);
%!     case 5
%!         myassert (issym(A));
%!         myassert(a.bytes < a_full.bytes);
%!         myassert(a.bytes < a_sparse.bytes);
%!     end
%! 
%!     %% break structure (e.g., symmetry)
%!     % to make matrix non-packable:
%!     A_full(1,end) = 1;  A_full(end,1) = 2;
%!     A = packed (A_full);
%!     myassert (~ispacked (A));
%! end
%! myassert (j, i);  % assure all cases were visited

%!test
%! % elseif (nargin == 3)
%! n = 10;
%! for i=1:4
%!     switch i
%!     case 1
%!         % symmetrical matrix:
%!         A_full = randsym(n);
%!         A_vec = A_full(triu(true(n)));
%!         type = 'symmetric';
%!         uplow = 'u';
%!         j = i;
%!     case 2
%!         % symmetrical matrix:
%!         A_full = randsym(n);
%!         A_vec = A_full(tril(true(n)));
%!         type = 'sym';
%!         uplow = 'l';
%!         j = i;
%!     case 3
%!         % triangular matrix:
%!         A_full = triu(rand(n));
%!         A_vec = A_full(triu(true(n)));
%!         type = 'triangular';
%!         uplow = 'u';
%!         j = i;
%!     case 4
%!         % triangular matrix:
%!         A_full = tril(rand(n));
%!         A_vec = A_full(tril(true(n)));
%!         type = 'tri';
%!         uplow = 'l';
%!         j = i;
%!     end
%!     
%!     for k=1:2
%!         if (k == 1)
%!             % elseif (nargin == 3) && isvector(A)
%!             A = packed (A_vec, type, uplow);
%!         elseif (k == 2)
%!             % elseif (nargin == 3) && issquare(A)
%!             A = packed (A_full, type, uplow);
%!         end
%!         myassert (ispacked (A));
%!         myassert (isequal(A, A_full))
%!     
%!         switch i
%!         case 1
%!             myassert (issym(A));
%!         case 2
%!             myassert (issym(A));
%!         case 3
%!             myassert (istriu(A));
%!         case 4
%!             myassert (istril(A));
%!         end
%!     end
%! 
%! end
%! myassert (j, i);  % assure all cases were visited

%!test
%! A = packed(1, 'sym', 'u');
%! myassert (~ispacked(A));
%! myassert (A, 1);

%!test
%! A = packed([], 'sym', 'u');
%! myassert (isempty(A));
%! myassert (ispacked(A));

%!error
%! lasterr('', '');
%! packed(zeros(numeltriorder(10), 1), 'WRONG', 'u');

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:packed:badType');

%!error
%! lasterr('', '');
%! packed(zeros(numeltriorder(10), 1), 'sym', 'WRONG');

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:packed:badUplow');

%!error
%! lasterr('', '');
%! packed(zeros(numeltriorder(10)+1, 1), 'sym', 'u');

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:packed:dataSizeNotSquare');


%!test
%! % complex number with non-zero imaginary part:
%! A = packed(complex(eye(2), eye(2)));
%! myassert (~isreal(A));

%!test
%! % complex number with zero imaginary part:
%! A = packed(complex(eye(2)));
%! myassert (~isreal(A));

%!test
%! A_full = [1 NaN; NaN 1];
%! myassert (issym(A_full));
%! A = packed(A_full);
%! myassert (ispacked(A));
%! myassert (issym(A));
%! myassert (isequalwithequalnans(full(A), A_full));

