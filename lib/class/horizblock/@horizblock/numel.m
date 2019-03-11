function answer = numel (A, varargin)
    switch nargin
    case 0
        error('horizblock:numel:notEnoughInputs', ...
        'Not enough input parameters.');
    case 1
        if isempty(A.size)
            answer = 0;
        else
            answer = prod(A.size);
        end
    otherwise
        answer = 1;
        % I don't really know what to answer here.
        % See doc numel for background.
        % @horizblock/subsref.m doesn't support expressions such as 
        % A{index1,index2,...,indexN} or A.fieldname.
        % Still, numel(A, varargin) has to be greater than zero,
        % otherwise subsasgn.m will NOT receive a third parameter.
    end
end

%!test
%! A = horizblock(eye(2,2));
%! myassert (numel(A), 4);

%!test
%! A = horizblock(1);
%! myassert (numel(A), 1);

%!test
%! A = horizblock([]);
%! %numel(A)  % DEBUG
%! myassert (numel(A), 0);

%!test
%! A = horizblock;
%! myassert (numel(A), 0);

%!test
%! A = horizblock;
%! myassert(numel(A, 10), 1);

%!test
%! A = horizblock;
%! myassert(numel(A, 10, 'a'), 1);

