function A = frontal_transpose (A)
    A = permute(A, [2,1,3]);
end

%!test
%! for i=1:10
%! 
%! m = ceil(10*rand);
%! n = ceil(10*rand);
%! p = ceil(10*rand);
%! %disp([m,n,p])  % DEBUG
%! A = rand(m,n,p);
%! A = complex(A, A);
%! 
%! C = zeros([n,m,p]);
%! if (p == 1)
%!     C = transpose(A);
%! elseif (m==1 || n==1)
%!     C = reshape(A, n, m, p);
%! elseif (p < m)
%!     for k=1:p
%!         C(:,:,k) = transpose(A(:,:,k));
%!     end
%! else
%!     for i=1:m
%!         C(:,i,:) = reshape(A(i,:,:),[],1,p);
%!     end
%! end
%! 
%! myassert(C, frontal_transpose(A));
%! 
%! end

