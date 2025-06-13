function out = frontal_diag (in)
    [m,n,p] = size(in);  %#ok<ASGLU>
    if (p==1),  out = diag(in);  return;  end  % faster
    %out = diag(in(:,:,1));  % WRONG! breaks w/ p==0
    out = diag(in(:,:,min(1,end)));
    out = repmat(out, [1,1,p]);
    for k=2:p
        out(:,:,k) = diag(in(:,:,k));        
    end
end

%!test
%! in = [];
%! out = diag(in)
%! out2 = frontal_diag (in)
%! myassert(out2, out)
%! out2 = frontal_diag (repmat(in, [1,1,2]))

%!test
%! in = eye(3);
%! out = diag(in)
%! out2 = frontal_diag (in)
%! myassert(out2, out)
%! out2 = frontal_diag (repmat(in, [1,1,2]))

%!test
%! in = ones(3,1);
%! out = diag(in)
%! out2 = frontal_diag (in)
%! myassert(out2, out)
%! out2 = frontal_diag (repmat(in, [1,1,2]))

%!#test
%! in = ones(3,1,0);
%! out = diag(in)
%! out2 = frontal_diag (in)
%! myassert(out2, out)
%! out2 = frontal_diag (repmat(in, [1,1,2]))
