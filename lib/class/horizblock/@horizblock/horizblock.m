function answer = horizblock (varargin)
    answer = class(struct('data',[], 'num_blocks',[], 'size',[]), 'horizblock');
    answer.data = varargin;
    answer.num_blocks = nargin;
    answer.size = [0, 0];
    if (nargin == 0),  return;  end
    if length(unique(cellfun(@(c) size(c,1), varargin))) ~= 1
        error('MATLAB:horizblock:dimensionMismatch', ...
            'CAT arguments dimensions are not consistent.');
    end
    answer.size = [...
        unique(cellfun(@(c) size(c,1), varargin)), ...
        sum(cellfun(@(c) size(c,2), varargin))
    ];
end

%!test
%! A = horizblock;
%! myassert (isempty(A));
%! %myassert (ishorizblock(A));

%!test
%! temp = horizblock(zeros(2), ones(2));
%! myassert (cell(temp), {zeros(2), ones(2)});


%!error
%! lasterr ('', '');
%! horizblock(zeros(2), zeros(3));

%!test
%! % horizblock
%! s = lasterror;
%! myassert (s.identifier, 'MATLAB:horizblock:dimensionMismatch');

