function I = whicheye(is_sparse, varargin)
    if is_sparse
        I = speye(varargin{:});
    else
        I =   eye(varargin{:});
    end
end

%!test
%! myassert(issparse(whicheye(true, 1)))
%! myassert(~issparse(whicheye(false, 1)))

