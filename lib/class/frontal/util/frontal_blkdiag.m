function answer = frontal_blkdiag(varargin)
    if (nargin < 1),  answer = [];  return;  end
    if length(unique(cellfun(@(x) size(x,3), varargin))) ~= 1
        error('frontal:frontal_blkdiag:badSize', ...
            'All matrices should have the same number of frontal pages.');
    end
    siz = cellfun(@size, varargin(:), 'UniformOutput',false);
    siz = cell2mat(siz);
    temp = sum(siz, 1);  M = temp(1);  N = temp(2);
    try,  O = temp(3)/nargin;  catch,  O = 1;  end
    %if any(cellfun(@issparse, varargin))  % 3-d sparse matrices not supported.
    answer = zeros(M,N,O);
    temp = cumsum([[1 1]; siz(:,1:2)],1);
    ind_start = temp(1:end-1,:);
    ind_end   = temp(2:end,:)-1;
    %temp, ind_start, ind_end  % DEBUG
    for i=1:nargin
        if isempty(varargin{i}),  continue;  end
        I = ind_start(i,1):ind_end(i,1);
        J = ind_start(i,2):ind_end(i,2);
        %I, J, size(varargin{i})  % DEBUG
        %whos answer  % DEBUG
        answer(I,J,:) = varargin{i};
    end
end

%!shared
%! n = ceil(10*rand);

%!test
%! myassert(isempty(frontal_blkdiag()))

%!test
%! myassert(isempty(frontal_blkdiag([])))

%!test
%! A = ones(1,2,3);
%! A2 = frontal_blkdiag(A);
%! myassert(A2, A);

%!test
%! A = blkdiag(1, 2, 3);
%! A2 = frontal_blkdiag(1, 2, 3);
%! myassert(A2, A);

%!test
%! A = repmat(blkdiag(1, 2, 3), [1,1,n]);
%! A2 = frontal_blkdiag(...
%!     repmat(1, [1,1,n]), ...
%!     repmat(2, [1,1,n]), ...
%!     repmat(3, [1,1,n]));
%! myassert(A2, A)

%!test
%! % frontal_blkdiag ()
%! lasterror('reset')

%!error
%! A2 = frontal_blkdiag(...
%!     repmat(1, [1,1,n]), ...
%!     repmat(1, [1,1,n*2]));

%!test
%! % frontal_blkdiag ()
%! s = lasterror;
%! myassert(s.identifier, 'frontal:frontal_blkdiag:badSize')

