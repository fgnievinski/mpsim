function answer = rcond2 (A)
     if issparse(A)
         answer = 1./condest(A,1);
     else
         answer = rcond(A);
     end
end

