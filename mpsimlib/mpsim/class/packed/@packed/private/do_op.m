% TODO: add test cases checking if output is packed.
function answer = do_op (left, right, op)
    if isempty(left) || isempty(right)
        answer = packed([]);
        return;
    end
    
    A = left;
    B = right;

    if ispacked(A) && ispacked(B) ...
        && strcmp(A.uplow, B.uplow) ...
        && (   ( issym_type(A) && issym_type (B) ) ...
            || ( istri_type(A) && istri_type (B) && feval(op, 0, 0) == 0 ) )
        answer = A;
        answer.data = feval(op, A.data, B.data);
        
    elseif ispacked(A) && isscalar(B) ...
        && (     issym_type(A) ...
            || ( istri_type(A) && feval(op, 0, B) == 0 ) )
        answer = A;
        answer.data = feval(op, A.data, B);
    elseif ispacked(A) && issparse(B)
        ind = find(B);
        s.type = '()';  s.subs = {ind};
        a = subsref(A, s);
        b = full(B(ind));
        answer = feval(op, A, 0);
        answer = subsasgn (answer, s, feval(op, a, b));
        
    elseif ispacked(B) && isscalar(A) ...
        && (     issym_type(B) ...
            || ( istri_type(B) && feval(op, A, 0) == 0 ) )
        answer = B;
        answer.data = feval(op, A, B.data);
    elseif ispacked(B) && issparse(A)
        ind = find(A);
        s.type = '()';  s.subs = {ind};
        a = full(A(ind));
        b = subsref(B, s);
        answer = feval(op, 0, B);
        answer = subsasgn (answer, s, feval(op, a, b));
        
    else
        answer = feval(op, full(A), full(B));
    end
end

%!test
%! % do_op ()
%! warning('off', 'test:noFuncCall');
 
%!test
%! global DO_OP;  myassert (~isempty(DO_OP));  op = DO_OP;
%! myassert (isempty( feval(op, packed([]), 1) ));
 
%!test
%! global DO_OP;  myassert (~isempty(DO_OP));  op = DO_OP;
%! 
%! for type = {'tri', 'sym'},  type = type{:};
%! for uplow = {'u', 'l'},  uplow = uplow{:};
%! for left_precision = {...
%!     'double', 'single', ...
%!     'int8', 'uint8',  ...
%!     'int16', 'uint16',  ...
%!     'int32', 'uint32',  ...
%!     'logical', 'char'}
%!     left_precision = left_precision{:};
%! %for right_precision = {...
%! %    'double', 'single', ...
%! %    'int8', 'uint8',  ...
%! %    'int16', 'uint16',  ...
%! %    'int32', 'uint32',  ...
%! %    'logical', 'char'}
%! %    right_precision = right_precision{:};
%! %    'int64', 'uint64', ...  % Function 'transpose' is not defined for
%!                              % values of class 'uint64'.
%!     
%!     temp = cast(1, left_precision);
%!     try
%!         feval(op, temp, temp);
%!     catch
%!         s = lasterror;
%!         if strend('UndefinedFunction', s.identifier)
%!             continue;
%!         else
%!             rethrow(s)
%!         end
%!     end
%!     
%!     while true
%!         n = round(10*rand);
%!         if (n > 2),  break;  end
%!     end
%! 
%!     p = rand;
%!     
%!     if strcmp(type, 'sym')
%!         A_full = randsym(n);
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!         A_full = triu(rand(n));
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!         A_full = tril(rand(n));
%!     end
%! 
%!     if strcmp(left_precision, 'logical')
%!         A_full = round(A_full);
%!         p = round(p);
%!     end
%!     A_full = cast(A_full, left_precision);
%!     p = cast(p, left_precision);
%! 
%!     A = packed(A_full, type, uplow);
%!     myassert (ispacked(A));
%!     myassert (isa(A, left_precision));
%! 
%!     myassert (feval(op, A, p), feval(op, A_full, p));
%!     myassert (feval(op, p, A), feval(op, p, A_full));
%! 
%!     myassert (feval(op, A, 0), feval(op, A_full, 0));
%!     myassert (feval(op, 0, A),  feval(op, 0, A_full));
%! 
%!     myassert (feval(op, A, A_full), feval(op, A_full, A_full));
%!     myassert (feval(op, A_full, A), feval(op, A_full, A_full));
%! 
%!     myassert (feval(op, A, A), feval(op, A_full, A_full));
%! 
%!     if strcmp(left_precision, 'char'),  continue;  end
%!     try
%!         A_sparse = sparse(A_full);
%!     catch
%!         s = lasterror;
%!         if strend('UndefinedFunction', s.identifier)
%!             continue;
%!         else
%!             rethrow(s)
%!         end
%!     end
%!     myassert (feval(op, A, A_sparse), feval(op, A_full, A_sparse));
%!     myassert (feval(op, A_sparse, A), feval(op, A_sparse, A_full));
%!     
%! %end
%! end
%! end
%! end
    
%!test
%! warning('on', 'test:noFuncCall');

