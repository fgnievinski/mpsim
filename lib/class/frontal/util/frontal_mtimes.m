function C = frontal_mtimes (A, B, force_helper)
    %C = bsxfun(@mtimes, A, B);  return;  % WRONG! bsxfun applies element-by-element binary operation only.
    if (nargin < 3) || isempty(force_helper),  force_helper = false;  end
    if force_helper && ( ~isreal(A) || ~isreal(B) )
        force_helper = false;
    end
    if force_helper
        C = frontal_mtimes_helper(A, B);
        return;
    end
    
    if isscalar(A) || isscalar(B)
        C = frontal_times(A, B);
        return;
    end

    disable_lp = true;  % case ((mC*nC) < p).
    
    [mA,nA,pA] = size(A);
    [mB,nB,pB] = size(B);

    if (nA ~= mB)
        error('frontal:mtimes:innerdim', ...
        'Inner matrix dimensions must agree.')
    end
    if ~( (pA == pB) || (pA == 1) || (pB == 1) )
        error ('frontal:mtimes:thirddim', ...
        'Third matrix dimensions must agree.')
    end

    mC = mA;
    nC = nB;
    p = max(pA, pB);
    
    if (pA == 0) || (pB == 0)
        C = zeros(mC,nC,0);
    elseif (p == 1)
        C = A * B;
    elseif (pA ~= pB) && (pB == 1)
        C = frontal_transpose(...
                frontal_mtimes(...
                    frontal_transpose(B), ...
                    frontal_transpose(A)));
    elseif (pA ~= pB) && (pA == 1) && (nB == 1)
        C = permute(A * permute(B, [1,3,2]), [1,3,2]);
    elseif (pA ~= pB) && (pA == 1) && ((mC*nC) < p)
        C = zeros(mC,nC,p);
        for i=1:mC, for j=1:nC %#ok<ALIGN>
            % following the definition of matrix product:
            C(i,j,:) = sum(repmat(reshape(A(i,:),nA,1),[1,1,p]) .* B(:,j,:),1);
        end, end
    elseif (pA ~= pB) && (pA == 1) && ((mC*nC) >= p)
        C = zeros(mC,nC,p);
        for k=1:p
            C(:,:,k) = A * B(:,:,k);
        end
    elseif ~disable_lp && ((mC*nC) < p)
        C = zeros(mC,nC,p);
        for i=1:mC, for j=1:nC  %#ok<ALIGN>
            % following the definition of matrix product:
            C(i,j,:) = sum(reshape(A(i,:,:),nA,1,p) .* B(:,j,:), 1);
            %% for more detailed profiling:
            %temp1 = A(i,:,:);
            %temp2 = reshape(temp1,nA,1,p);
            %temp3 = B(:,j,:);
            %temp4 = temp2 .* temp3;
            %C(i,j,:) = sum(temp4, 1);
        end, end
    %elseif ((mC*nC) >= p)
    else
        try 
            %try  N = maxNumCompThreads;  catch N = 1;  end
            N = 1;
            if (N == 1)
                C = frontal_mtimes_helper(A, B);
                return;
            end
            % if only cellfun were multi-threaded...
            ppp = doit (p, N);
            Ac = mat2cell(A, mA, nA, ppp);
            Bc = mat2cell(B, mB, nB, ppp);
            Cc = cellfun(@frontal_mtimes_helper, Ac, Bc, ...
                'UniformOutput',false);
            C = cell2mat(Cc);
        catch s
            if ~is_error_undefined_function (s) ...
            && ~any(strcmp(s.identifier, {...
                'frontal:mtimes:diffClasses', ...
                'frontal:mtimes:nonFloat', ...
                'frontal:mtimes:complex'}))
                rethrow(s);
            end
            %whos A B  % DEBUG
            C = zeros(mC,nC,p);
            for k=1:p
                C(:,:,k) = A(:,:,k) * B(:,:,k);
            end
        end
    end
end


%!test
%! % frontal_mtimes
%! warning('off', 'test:noFuncCall');

%!test
%! lasterror('reset')

%!error
%! frontal_mtimes(zeros(1,1,3), zeros(1,1,4));

%!test
%! s = lasterror;
%! myassert(s.identifier, 'frontal:mtimes:thirddim')


%!test
%! lasterror('reset')

%!error
%! frontal_mtimes(zeros(3,2,3), zeros(3,2,3));

%!test
%! s = lasterror;
%! myassert(s.identifier, 'frontal:mtimes:innerdim')


%!test
%! warning('on', 'test:noFuncCall');

%!shared
%!  p = ceil(10*rand);
%! mA = ceil(10*rand);
%! nA = ceil(10*rand);
%! mB = nA;  % inner dimension must agree.
%! nB = ceil(10*rand);
%! A = rand(mA, nA, p);
%! B = rand(mB, nB, p);
%! A1 = A(:,:,1);
%! B1 = B(:,:,1);
%! mC = mA;
%! nC = nB;
%! f = false;  % force_helper flag.
%! %f = true;  % force_helper flag.

%!test
%! % frontal matrices with only one page 
%! % can be treated as 2d matrices.
%! C = frontal_mtimes(A1, B1, f);
%! C2 = A1 * B1;
%! myassert (C, C2);

%!test
%! % repeated frontal pages yield repeated frontal pages:
%! C = frontal_mtimes(repmat(A1, [1,1,p]), repmat(B1, [1,1,p]), f);
%! C2 = repmat(A1*B1, [1,1,p]);
%! %p, C, C2  % DEBUG
%! myassert (C, C2, -10*eps);

%!test
%! % matrix with only one frontal page can be multiplied with 
%! % matrix with multiple frontal pages.
%! myassert(frontal_mtimes(A1, B, f), frontal_mtimes(repmat(A1, [1,1,p]), B, f), -10*eps);
%! myassert(frontal_mtimes(A, B1, f), frontal_mtimes(A, repmat(B1, [1,1,p]), f), -10*eps);

%!test
%! % empty input, empty output.
%! myassert(isempty(frontal_mtimes([], [], f)))
%! C = frontal_mtimes(zeros(0,0,1), zeros(0,3,3), f);
%! myassert(isempty(C));
%! myassert(C, repmat(zeros(0,0)*zeros(0,3), [1,1,3]))

%!test
%! % empty input, non-empty output.
%! myassert(isempty(frontal_mtimes([], [], f)))
%! C = frontal_mtimes(zeros(2,0,3), zeros(0,3,3), f);
%! myassert(~isempty(C));
%! myassert(C, repmat(zeros(2,0)*zeros(0,3), [1,1,3]))

%!test
%! % frontal_mtimes
%! lasterror('reset')

%!error
%! % empty input still have to have inner dimensions in agreement.
%! frontal_mtimes(zeros(2,0), zeros(2,2), f);

%!test
%! % frontal_mtimes
%! s = lasterror;
%! myassert(s.identifier, 'frontal:mtimes:innerdim')


%!test
%! % alternative implementation:
%! function C = frontal_mtimes2 (A, B)
%!     for i=1:mC, for j=1:nC
%!         % following the definition of matrix product:
%!         C(i,j,:) = sum(reshape(A(i,:,:),nA,1,p) .* B(:,j,:), 1);
%!         %% for more detailed profiling:
%!         %temp1 = A(i,:,:);
%!         %temp2 = reshape(temp1,nA,1,p);
%!         %temp3 = B(:,j,:);
%!         %temp4 = temp2 .* temp3;
%!         %C(i,j,:) = sum(temp4, 1);
%!     end, end
%!     %% caught and fixed a bug with alternative implementation:
%!     %C = frontal_mtimes(ones(1,1,2), 3*ones(1,2,2), f);
%!     %myassert(C, repmat([3,3], [1,1,2]))
%!     %C = frontal_mtimes(ones(2,1,2), 3*ones(1,1,2), f);
%!     %myassert(C, repmat([3;3], [1,1,2]))
%! end
%! 
%! tic; C1 = frontal_mtimes (A,B,f); t1 = toc;
%! tic; C2 = frontal_mtimes2(A,B); t2 = toc;
%! 
%! myassert (C1, C2, -10*eps);
%! %[t1, t2, cputime_tol]

%!test
%! % there is an alternative implementation for the for i=1:p loop.
%! function C = frontal_mtimes2 (A, B)
%!     C = cell2mat(cellfun(@mtimes, ...
%!         mat2cell(A, m, n, ones(p,1)), ...
%!         mat2cell(B, m, n, ones(p,1)), ...
%!         'UniformOutput',false));
%! end
%! m = 3;
%! n = 3;
%! p = 10000/2;
%! A = repmat(eye(m,n), [1,1,p]);
%! B = rand(m,n,p);
%! %[mC*nC, p]  % DEBUG
%! 
%! tic; C1 = frontal_mtimes (A,B,f); t1 = toc;
%! tic; C2 = frontal_mtimes2(A,B); t2 = toc;
%! 
%! myassert (C1, C2, -10*eps);
%! %[t1, t2, cputime_res]  % DEBUG

%!test
%! % complex-valued input:
%! A1 = complex(A1, A1);
%! B1 = complex(B1, B1);
%! C = frontal_mtimes(A1, B1, f);
%! C2 = A1 * B1;
%! myassert (C, C2);

%!test
%! % A is a single frontal page & B is a frontal collection of column vectors,
%! % then the multiplication is faster than replicating A:
%! pA = 1;
%! pB = ceil(10*rand);
%! pB = 100000 + pB;
%! mA = ceil(10*rand);
%! nA = ceil(10*rand);
%! mB = nA;  % inner dimension must agree.
%! nB = 1;
%! A = repmat(rand(mA, nA, pA), [1,1,pB]);
%! B = rand(mB, nB, pB);
%! tol = 2*cputime_res() + sqrt(eps);
%! 
%! tic; C1 = frontal_mtimes (A,B,f); t1 = toc;
%! tic; C2 = frontal_mtimes (A(:,:,1),B); t2 = toc;
%! 
%! myassert (C1, C2, -10*eps);
%! [t1, t2, cputime_res]  % DEBUG
%! %myassert (t2 <= t1 || abs(t2-t1) <= 10*tol || f == true);

