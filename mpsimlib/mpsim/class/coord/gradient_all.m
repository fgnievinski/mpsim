function c = gradient_all (F, h, dim)
    if (nargin < 2) || isempty(h),  h = 1;  end
    if (nargin < 3),  dim = [];  end
    if islogical(dim),  dim = double(dim);  end  % legacy interface
    if isvector(F)
        c = gradient (F, h);
        return;
    end
    siz = size(F);
    siz2 = size(h);
    if ~isempty(dim) || isequaln(siz2, siz)
        c = gradient_all_slow (F, h, dim);
        return;
    end
    nh = prod(siz2);
    if (nh ~= 1) && (nh ~= siz(1))
        error('coord:gradient_all:badSize', ...
            ['Second input argument must be scalar, a vector with '...
             'as many elements as rows in the first argument, '...
             'or as a grid of the same size as the first argument.']);
    end
    %c2 = gradient (F2, h);  % WRONG!
    F2 = reshape(F, [siz(1) prod(siz(2:end))]);
    %[~, c2] = gradient (F2, h);  % WRONG!
    [~, c2] = gradient (F2, 1, h);
    c = reshape(c2, siz);
end

%%
function c = gradient_all_slow (F, h, dim)
    if (nargin < 2) || isempty(h),  h = 1;  end
    if (nargin < 3),  dim = [];  end
    if isvector(h)
        if isempty(dim),  dim = finddim(h);  end
        get_h = @(i,j,k) h;
    else
        if isempty(dim),  dim = 1;  end
        switch dim
        case 1,  get_h = @(i,j,k) h(:,j,k);
        case 2,  get_h = @(i,j,k) h(i,:,k);
        case 3,  get_h = @(i,j,k) h(i,j,:);
        end
    end
    [m,n,p] = size(F);
    c = NaN(m,n,p);
    switch dim
    case 1
        for j=1:n
        for k=1:p
            c(:,j,k) = gradient(F(:,j,k), get_h([],j,k));
        end
        end
    case 2
        for i=1:m
        for k=1:p
            c(i,:,k) = gradient(F(i,:,k), get_h(i,[],k));
        end
        end
    case 3
        for i=1:m
        for j=1:n
            c(i,j,:) = gradient(F(i,j,:), get_h(i,j,[]));
        end
        end
    otherwise
        error('MATLAB:all:gradient:badInp', ...
            'Input of more the 3 dimensions is not supported.');
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
