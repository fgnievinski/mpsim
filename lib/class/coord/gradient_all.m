function c = gradient_all (F, h, force_slow)
    if (nargin < 2) || isempty(h),  h = 1;  end
    if (nargin < 3) || isempty(force_slow),  force_slow = false;  end    
    siz = size(F);
    siz2 = size(h);
    if isvector(F),  c = gradient (F, h);  return;  end
    if force_slow || isequaln(siz2, siz),  c = gradient_all_slow (F, h);  return;  end
    nh = prod(siz2);
    if (nh ~= 1) && (nh ~= siz(1))
        error('coord:gradient_all:badSize', ...
            ['Second input argument must be scalar or be a vector with '...
             'as many elements as rows in the first argument.']);
    end
    %c2 = gradient (F2, h);  % WRONG!
    F2 = reshape(F, [siz(1) prod(siz(2:end))]);
    %[~, c2] = gradient (F2, h);  % WRONG!
    [~, c2] = gradient (F2, 1, h);
    c = reshape(c2, siz);
end

function c = gradient_all_slow (F, h)
    if (nargin < 2) || isempty(h),  h = 1;  end
    [m,n,p] = size(F);
    c = NaN(m,n,p);
    for k=1:p
    for j=1:n
        c(:,j,k) = gradient(F(:,j,k), h);
    end
    end
end

%!test
%! siz = [4 3 2];
%! F = rand(siz);
%! h = rand();
%! %h = rand(siz(1),1);
%! %h = rand(siz(1)+1,1);  % WRONG!
%! c = gradient_all(F,h);
%! c2 = gradient_all(F,h,true);
%!   %max(abs(c2(:) - c(:)))  % DEBUG
%! myassert(c2, c);
