function varargout = xyz2neu (varargin)
    error(nargchk(1, Inf, nargin))
    if (nargin == 1) && (nargout <= 1)
        varargout{1} = varargin{1};
        if (size(varargin{1},2) < 2),  return;  end
        varargout{1}(:,[2 1]) = varargin{1}(:,[1 2]);
        return
    end
    nargout2 = nargin;
    if (nargin == 1)
        [m,n] = size(varargin{1});
        varargin = mat2cell(varargin{1}, m, ones(1,n));
        nargout2 = max(1, n);
        if (n == 0),  nargout2 = 0;  end
    end
    [varargout2{1:nargout2}] = xyz2neu11c (varargin{:});
    varargout = varargout2;
    if (nargout <= 1)
        varargout = {cell2mat(varargout)};
    end
end

function varargout = xyz2neu11c (varargin)
    varargout = varargin;
    if isempty(varargin), return;  end
    varargout([1,2]) = varargout([2,1]);
    %varargout(2) = varargin(1);
    %varargout(1) = varargin(2);
end

%!test
%! myassert(xyz2neu([1 2 3]), [2 1 3])
%! myassert(xyz2neu(1, 2, 3), [2 1 3])
%! [a,b,c] = xyz2neu([1 2 3]);  myassert([a b c], [2 1 3])
%! [a,b,c] = xyz2neu(1, 2, 3);  myassert([a b c], [2 1 3])
%! xyz2neu([]);

