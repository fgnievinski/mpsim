function answer = numel (A, varargin)
    switch nargin
    case 0
        error('packed:numel:notEnoughInputs', ...
        'Not enough input parameters.');
    case 1
        answer = order(A).^2;
    otherwise
        answer = 1;
        % I don't really know what to answer here.
        % See doc numel for background.
        % @packed/subsref.m doesn't support expressions such as 
        % A{index1,index2,...,indexN} or A.fieldname.
        % Still, numel(A, varargin) has to be greater than zero,
        % otherwise subsasgn.m will NOT receive a third parameter.
    end
end

%!test
%! A = packed(eye(2,2));
%! myassert (numel(A), 4);

%!test
%! A = packed(1);
%! myassert (numel(A), 1);

%!test
%! A = packed([]);
%! myassert (numel(A), 0);

%!test
%! A = packed;
%! myassert (numel(A), 0);

%!test
%! A = packed;
%! myassert(numel(A, 10), 1);

%!test
%! A = packed;
%! myassert(numel(A, 10, 'a'), 1);

