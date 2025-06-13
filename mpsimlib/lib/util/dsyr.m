function out = dsyr (x)
% 'DSYR(UPLO,N,ALPHA,X,INCX,A,LDA)'
    n = length(x);
    out = lapack('DSYR(h,i,d,d,i,D,i)', 'L',n,1.0,x,1,zeros(n),n);
    out = out + tril(out,-1)';
end

%! x = (1:3)';
%! tic, for i=1:10000,  A=x*x';  end, toc
%! tic, for i=1:10000,  A=dsyr(x);  end, toc

