function answer = horzcat (varargin)
    if length(unique(cellfun(@(c) size(c,1), varargin))) ~= 1 ...
    || length(unique(cellfun(@(c) size(c,3), varargin))) ~= 1
        error('MATLAB:blockdiag:dimensionMismatch', ...
            'CAT arguments dimensions are not consistent.');
    end

    %nargin, varargin  % DEBUG
    idx = cellfun(@isblockdiag, varargin);
    varargin(idx) = cellfun(@unblockdiag, varargin(idx), 'UniformOutput',false);
    myassert(~any(cellfun(@isblockdiag, varargin)));
    %varargin{:}  % DEBUG
    answer = horzcat(varargin{:});
end

%!test
%! % horzcat
%! temp = [1 blockdiag(1)];
%! myassert(~isblockdiag(temp))
%! myassert(temp, [1 1])

%!error
%! lasterr ('', '');
%! horzcat(blockdiag(zeros(2)), blockdiag(zeros(3)));

%!test
%! % horzcat
%! s = lasterror;
%! myassert (s.identifier, 'MATLAB:blockdiag:dimensionMismatch');

