function [dim, ignore_nans, detrendit, weight] = nanstdur_aux (obs, dim, ignore_nans, detrendit, weight)
    if (nargin < 2) || isempty(dim),  dim = finddim(obs);  end
    if (nargin < 3) || isempty(ignore_nans),  ignore_nans = true;  end
    if (nargin < 4) || isempty(detrendit),  detrendit = true;  end
    if (nargin < 5) || isempty(weight),  weight = 1;  end
    if isscalar(weight),  weight = repmat(weight, size(obs));  end
    assert(isequal(size(weight), size(obs)))
    assert(isscalar(dim))
    assert(islogical(detrendit))
    assert(islogical(ignore_nans))
    assert(~islogical(dim))
end
