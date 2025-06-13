function answer = blockdiag (varargin)
    if (nargin > 1) && any(cellfun(@iscell, varargin))
        error ('blockdiag:blockdiag:tooManyCells', ...
            'Cell input is allowed only for one single parameter.');
    end

    if (nargin == 0)
        answer = blockdiag ({});
        return;
    elseif (nargin == 1 && isblockdiag(varargin{1}))
        answer = varargin{1};
        return;
    elseif (nargin == 1 && ~iscell(varargin{1}))
        answer = blockdiag ({varargin{1}});
        return;
    elseif ( nargin == 1 && iscell(varargin{1}) ...
        && ~(isvector(varargin{1}) || isempty(varargin{1})) )
        %error ('blockdiag:blockdiag:badInput', ...
        %    'Vector or empty argument only.');
        answer = varargin{1};
        return;
    elseif (nargin > 1)
        answer = blockdiag ({varargin{:}});  % = blockdiag (varargin);
        return;
    end
    
    myassert ( nargin == 1 && iscell(varargin{1}) ...
        && (isvector(varargin{1}) || isempty(varargin{1})) )

    [M,N] = sizes(varargin{1});
    size = [sum(M), sum(N)];
    num_blocks = length(varargin{1});
    M = repmat(M(:),  1, num_blocks);
    N = repmat(N(:)', num_blocks, 1);
    data = arrayfun(@(m,n) sparse(m,n), M, N, 'UniformOutput',false);
    data(logical(eye(num_blocks))) = varargin{1};
    %data = diag(varargin{1});
    %[i,j] = sizes(data);
    %size = [sum(diag(i)), sum(diag(j))];
    
    answer = class(struct('data',[], 'size',[]), 'blockdiag');
    answer.data = data;
    answer.size = size;
end

%!test
%! A = blockdiag;
%! myassert (isblockdiag(A));
%! myassert (isempty(A));

%!error
%! lasterr ('', '');
%! blockdiag({}, {});

%!test
%! s = lasterror;
%! myassert (s.identifier, 'blockdiag:blockdiag:tooManyCells');

%!test
%! lasterr ('', '');
%! temp = blockdiag(zeros(2), zeros(3,2));
%! myassert (cell(temp), {zeros(2) []; [] zeros(3,2)});

%!shared
%! A_cell = {1, [], []; [], ones(2), []; [], [], ones(3)};

%!test
%! A = blockdiag(1, ones(2), ones(3));
%! myassert (isblockdiag(A));
%! myassert (cell(A), A_cell);

%!test
%! A = blockdiag(blockdiag);
%! myassert (isblockdiag(A));
%! myassert (cell(A), {});

%!test
%! A = blockdiag({[1]});
%! myassert (isblockdiag(A));
%! myassert (cell(A), {[1]});
%! myassert ({[1]}, {1});

%!test
%! A = blockdiag({});
%! myassert (isblockdiag(A));
%! myassert (isempty(A));
%! myassert (cell(A), {});

%!test
%! A = blockdiag({1, ones(2), ones(3)});
%! myassert (isblockdiag(A));
%! myassert (cell(A), A_cell);

%!test
%! A = blockdiag(diag(A_cell));
%! myassert (isblockdiag(A));
%! myassert (cell(A), A_cell);

%!test
%! A = blockdiag(cell(2, 3));
%! myassert (~isblockdiag(A));
%! myassert (A, cell(2, 3));

%!test
%! A = blockdiag(eye(2), []);
%! myassert (isblockdiag(A));
