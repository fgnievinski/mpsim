function C = frontal_times (A, B)
    C = bsxfun(@times, A, B);
end

% %!test
% %! % frontal_times
% %! warning('off', 'test:noFuncCall');
% 
% %!test
% %! lasterror('reset')
% 
% %!error
% %! frontal_times(zeros(1,1,3), zeros(1,1,4));
% 
% %!test
% %! s = lasterror;
% %! myassert(s.identifier, 'frontal:times:thirddim')
% 
% 
% %!test
% %! warning('on', 'test:noFuncCall');


%!shared
%!  p = 1 + ceil(10*rand);
%! mA = 1;
%! nA = 1;
%! mB = ceil(10*rand);
%! nB = mB + ceil(10*rand);  % different than mB.
%! %p = 3;  mB = 8;  nB = 3;
%! %p, mB, nB  % DEBUG
%! A = rand(mA, nA, p);
%! B = rand(mB, nB, p);
%! A1 = A(:,:,1);
%! B1 = B(:,:,1);
%! 
%! % alternative implementation:
%! function C = frontal_times2 (A, B)
%!     [mA,nA,pA] = size(A);
%!     [mB,nB,pB] = size(B);
%!     myassert(pA == pB);  p = pA;
%!     if isequal([mA,nA], [1,1])  % A is a "scalar tube".
%!         C = zeros(mB,nB,p);
%!         for k=1:p
%!             C(:,:,k) = A(k) .* B(:,:,k);
%!         end
%!     elseif isequal([mB,nB], [1,1])
%!         C = frontal_times(B, A);
%!     end
%! end
%! function C = frontal_times3 (A, B)
%!     [mA,nA,pA] = size(A);
%!     [mB,nB,pB] = size(B);
%! 
%!     if isscalar(A) || isscalar(B)
%!         C = A .* B;
%!     elseif (pA ~= pB)
%!         error ('frontal:times:thirddim', ...
%!         'Third matrix dimensions must agree.')
%!     elseif isequal([mA,nA], [1,1]) % && (pA == pB)  % A is a "scalar tube".
%!         %disp('hw!')  % DEBUG
%!         C = zeros(mB,nB,pB);
%!         for i=1:mB
%!         for j=1:nB
%!             C(i,j,:) = A .* B(i,j,:);
%!         end
%!         end
%!     elseif isequal([mB,nB], [1,1]) % && (pA == pB)   % B is a "scalar tube"
%!         C = frontal_times(B, A);
%!     elseif isequal([mA,nA,pA], [mB,nB,pB])
%!         C = A .* B;
%!     else
%!         error('frontal:times:dimagree', ...
%!         'Matrix dimensions must agree.')
%!     end
%! end
%! 

%!test
%! % if isscalar(A)
%! C = frontal_times(A1, B);
%! C2 = A1 .* B;
%! myassert (C, C2);

%!test
%! % if isscalar(B)
%! C = frontal_times(B, A1);
%! C2 = B .* A1;
%! myassert (C, C2);

%!test
%! % elseif isequal([mA,nA], [1,1]) % && (pA == pB)  % A is a "scalar tube".
%! C = frontal_times(A, B);
%! C2 = frontal_times2(A, B);
%! C3 = frontal_times3(A, B);
%! myassert (C, C2);
%! myassert (C, C3);

%!test
%! % elseif isequal([mB,nB], [1,1]) % && (pA == pB)   % B is a "scalar tube"
%! C = frontal_times(B, A);
%! C2 = frontal_times2(B, A);
%! C3 = frontal_times3(A, B);
%! myassert (C, C2);
%! myassert (C, C3);

%!test
%! % elseif isequal([mA,nA,pA], [mB,nB,pB])
%! C = frontal_times(B, B);
%! C2 = B .* B;
%! myassert (C, C2);

%!test
%! % repeated frontal pages yield repeated frontal pages:
%! p = ceil(10*rand);
%! C = frontal_times(repmat(A1, [1,1,p]), repmat(B1, [1,1,p]));
%! C2 = repmat(A1.*B1, [1,1,p]);
%! myassert (C, C2);

%!test
%! % complex-valued input:
%! B = complex(B, B);
%! C = frontal_times(B, B);
%! C2 = B .* B;
%! myassert (C, C2);


